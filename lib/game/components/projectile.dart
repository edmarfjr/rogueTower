import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:tower/game/components/game_icon.dart';
import 'enemies/enemy.dart'; // Importante para reconhecer o inimigo
import 'pallete.dart';
import 'wall.dart';
import '../tower_game.dart';
import 'player.dart';
import 'explosion.dart';

class Projectile extends PositionComponent with HasGameRef<TowerGame>,CollisionCallbacks {
  final Vector2 direction;
  final double speed = 200; // Um pouco mais rápido que antes
  final double damage;
  final bool isEnemyProjectile;

  Projectile({
    required Vector2 position, 
    required this.direction,
    this.damage = 10,
    this.isEnemyProjectile = false,
  }): super(position: position, size: Vector2.all(10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: isEnemyProjectile ? Icons.navigation : Icons.circle, 
      color: isEnemyProjectile ? Pallete.vermelho : Pallete.amarelo,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    add(CircleHitbox(
      radius: 5,
      anchor: Anchor.center,
      position: size / 2, // Centraliza a hitbox de colisão
    ));

    // A rotação (angle) é aplicada no PAI (Projectile), então os filhos giram junto corretamente
    angle = atan2(direction.y, direction.x) + 1.54;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * speed * dt;

    // Remove o projétil se sair muito da tela (otimização)
    if (position.length > 2000) removeFromParent();
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    final hitPos = intersectionPoints.firstOrNull ?? position;
    createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
    // Se bater num inimigo
    if (isEnemyProjectile) {
      if (other is Player) {
        other.takeDamage(1); // Jogador toma 1 de dano (1 coração)
        removeFromParent();
      }
    } 
    // 3. Se for tiro do PLAYER
    else {
      if (other is Enemy) {
        other.takeDamage(damage);
        removeFromParent();
      }
    } 
    
    if (other is ScreenHitbox) {
      removeFromParent();
    }
    if (other is Wall) {
      removeFromParent(); // Tiro explode na parede
    }
  }
}