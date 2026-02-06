import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import './player.dart';
import '../core/game_icon.dart';
import 'collectible.dart';
import '../effects/floating_text.dart';

class UnlockableItem extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final String id;            
  final CollectibleType type;  
  final int soulCost;          
  
  bool _isUnlocked = false;

  UnlockableItem({
    required Vector2 position,
    required this.id,
    required this.type,
    required this.soulCost,
  }) : super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Verifica no save se já comprou
    _isUnlocked = gameRef.progress.isUnlocked(id);
    
    add(RectangleHitbox(isSolid: true));
    _updateVisuals();
  }

  void _updateVisuals() {
    // Remove visuais antigos para redesenhar
    removeAll(children.whereType<GameIcon>());
    removeAll(children.whereType<TextComponent>());

    if (_isUnlocked) {
      // VISUAL DESBLOQUEADO: Mostra o item normal
      add(GameIcon(
        icon: _getIconForType(type),
        color: _getColorForType(type), // Cor de item especial
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      ));
      
      // Texto "Free" ou "Take"
      _addText("Take", Colors.white);

    } else {
      // VISUAL BLOQUEADO: Cadeado ou Interrogação
      add(GameIcon(
        icon: Icons.lock,
        color: Colors.grey,
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      ));
      
      // Preço em Almas (Cor Azul para diferenciar de Ouro)
      _addText("$soulCost Souls", Colors.blueAccent);
    }
  }

  void _addText(String text, Color color) {
    add(TextComponent(
      text: text,
      textRenderer: TextPaint(style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 5),
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      if (_isUnlocked) {
        // --- JÁ COMPROU: PEGA O ITEM (Lógica de Collectible) ---
        _giveItem(other);
        removeFromParent();
        
      } else {
        // --- BLOQUEADO: TENTA COMPRAR COM ALMAS ---
        _tryUnlock(other);
      }
    }
  }

  Future<void> _tryUnlock(Player player) async {
    // Verifica se tem almas suficientes
    bool success = await gameRef.progress.spendSouls(soulCost);

    if (success) {
      // Sucesso!
      await gameRef.progress.unlockItem(id);
      _isUnlocked = true;
      _updateVisuals(); // Atualiza para mostrar o item
      
      gameRef.world.add(FloatingText(
        text: "Unlocked!",
        position: position + Vector2(0, -30),
        color: Colors.blueAccent,
      ));
    } else {
      // Falha
      gameRef.world.add(FloatingText(
        text: "Need Souls!",
        position: position + Vector2(0, -30),
        color: Pallete.vermelho,
      ));
      // Empurra player
      player.position += (player.position - position).normalized() * 20;
    }
  }

  void _giveItem(Player player) {
    Collectible.applyEffect(
      type: type, 
      game: gameRef
    );
  }

  IconData _getIconForType(CollectibleType type) {
      // Retorne o ícone certo (pode copiar do seu Collectible.dart)
      if (type == CollectibleType.damage) return Icons.gavel;
      if (type == CollectibleType.healthContainer) return Icons.favorite_outline;
      if (type == CollectibleType.shield) return Icons.gpp_bad;
      if (type == CollectibleType.fireRate) return Icons.double_arrow;
      return Icons.star;
  }

  Color _getColorForType(CollectibleType type) {
      // Retorne o ícone certo (pode copiar do seu Collectible.dart)
      if (type == CollectibleType.damage) return Pallete.azulCla;
      if (type == CollectibleType.healthContainer) return Pallete.vermelho;
      if (type == CollectibleType.shield) return Pallete.lilas;
      if (type == CollectibleType.fireRate) return Pallete.azulCla;
      return Pallete.branco;
  }
}