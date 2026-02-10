import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/game_icon.dart';
import '../enemies/enemy.dart'; 
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../../tower_game.dart';
import '../gameObj/player.dart';
import '../effects/explosion.dart';

class Projectile extends PositionComponent with HasGameRef<TowerGame>,CollisionCallbacks {
  final Vector2 direction;
  final double speed; 
  final double damage;
  final bool isEnemyProjectile;
  double _timer = 0.0;

  final PositionComponent? owner;

  Projectile({
    required Vector2 position, 
    required this.direction,
    this.damage = 10,
    this.speed = 300,
    this.owner,
    this.isEnemyProjectile = false,
    Vector2? size,
  }): super(position: position, size: size ?? Vector2.all(10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: Icons.circle, 
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

    if (owner != null && !owner!.isMounted) {
      removeFromParent(); // O tiro some junto
      return;
    }
    
    position += direction * speed * dt;

    // Remove o projétil se sair muito da tela (otimização)
    if (position.length > 2000) removeFromParent();

    final visual = children.whereType<GameIcon>().firstOrNull;
    _timer += dt;
    if (_timer % 0.2 < 0.1){
      
      visual?.setColor(Pallete.amarelo);
    }else{
      isEnemyProjectile? visual?.setColor(Pallete.vermelho): visual?.setColor(Pallete.azulCla) ;
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    final hitPos = intersectionPoints.firstOrNull ?? position;
    
    if (isEnemyProjectile) {
      if (other is Player) {
        createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
        other.takeDamage(1); // Jogador toma 1 de dano (1 coração)
        removeFromParent();
      }
    } 
    else {
      if (other is Enemy) {
        createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
        other.takeDamage(damage);
        removeFromParent();
      }
    } 
    
    if (other is ScreenHitbox) {
      createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
      removeFromParent();
    }
    if (other is Wall) {
      other.vida--;
      if (other.vida <=0) other.removeFromParent();
      createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
      removeFromParent(); 
    }
  }
}