import 'dart:math';

import 'package:flame/events.dart';

import '../core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import 'player.dart';
import '../core/game_icon.dart';
import 'collectible.dart';

class Chest extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool _isOpen = false;
  
  // Guardamos a referência do ícone para trocar (fechado -> aberto)
  GameIcon? _iconComponent;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 60.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão

  Chest({required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Visual (Baú Fechado)
    _updateIcon(Icons.lock, Pallete.marrom); // Dourado escuro

    // 2. Hitbox Sólida (Player não atravessa o baú)
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));
  }

  void _updateIcon(IconData icon, Color color) {
    if (_iconComponent != null) _iconComponent!.removeFromParent();
    
    _iconComponent = GameIcon(
      icon: icon,
      color: color,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_iconComponent!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Calcula distância para o Player
    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _pickupRange) {
      if (!_isInfoVisible) _showInfo();
    } else {
      if (_isInfoVisible) _hideInfo();
    }
  }

  void _showInfo() {
    _isInfoVisible = true;
   

    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);


    // 3. Botão de Pegar
    final btn = PickupButton(
      onPressed: _openChest,
      size: Vector2(80, 24),
    )..position = Vector2(0, -50); 

    _infoGroup.add(btn);

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
  }


  void _openChest() {
    if (gameRef.keysNotifier.value <= 0) {
      return;
    }
    _isOpen = true;
    
    // Consome a chave
    gameRef.keysNotifier.value--;
    
    // Muda visual
    _updateIcon(Icons.lock_open, const Color(0xFFF0E68C)); 
    
    final rng = Random();

    // 1. Defina aqui QUAIS itens podem sair do baú
    // (Coloque os nomes dos seus 5 upgrades aqui dentro)
    final List<CollectibleType> possibleRewards = [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.healthContainer,
      CollectibleType.steroids,
      CollectibleType.cafe,  
      CollectibleType.keys,
      CollectibleType.dash,
      CollectibleType.sanduiche,
    ];
    if (!gameRef.player.isBerserk) possibleRewards.add(CollectibleType.berserk);
    if (!gameRef.player.isAudaz) possibleRewards.add(CollectibleType.audacious);
    if (!gameRef.player.isFreeze) possibleRewards.add(CollectibleType.freeze);
    if (!gameRef.player.magicShield) possibleRewards.add(CollectibleType.magicShield);

    // 2. Sorteia um índice aleatório da lista (0 até o tamanho da lista - 1)
    // rng.nextInt(N) retorna um número de 0 a N-1.
    final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];

    // 3. Cria o item sorteado
    gameRef.world.add(Collectible(
      position: position + Vector2(0, 40),
      type: lootType,
    ));

    print("Baú aberto! Dropou: $lootType");
  }
  
}

// =============================================================================
// COMPONENTE DO BOTÃO
// =============================================================================
class PickupButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  PickupButton({required this.onPressed, required Vector2 size}) 
    : super(size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Desenha o fundo do botão
    final paintBg = Paint()..color = Pallete.verdeCla;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintBg);

    // Desenha borda
    final paintBorder = Paint()..color = Pallete.branco..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintBorder);

    // Texto "PEGAR" ou Ícone de Mão
    const textStyle = TextStyle(color: Pallete.branco, fontSize: 12, fontWeight: FontWeight.bold);
    const textSpan = TextSpan(text: "PEGAR", style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}