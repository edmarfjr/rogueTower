import 'dart:math';

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
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (_isOpen) return;

    if (other is Player) {
      // Verifica se o jogador tem chaves
      if (gameRef.keysNotifier.value > 0) {
        _openChest();
      } else {
        // Opcional: Efeito visual/sonoro de "trancado"
        print("Precisa de uma chave!");
      }
    }
  }

  void _openChest() {
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
    ];
    if (!gameRef.player.isBerserk) possibleRewards.add(CollectibleType.berserk);
    if (!gameRef.player.isAudaz) possibleRewards.add(CollectibleType.audacious);
    if (!gameRef.player.isFreeze) possibleRewards.add(CollectibleType.freeze);

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