import 'dart:math';
import 'package:TowerRogue/game/components/core/game_icon.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import 'projectile.dart';

class OrbitalShield extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double angleOffset; // Diferença de ângulo para os escudos não ficarem um em cima do outro
  final double radius; // Distância do jogador
  final double speed ;   // Velocidade da rotação
  final bool isEnemy;
  final bool isFoice;
  final PositionComponent? owner;
  double _currentAngle = 0;

  OrbitalShield({
    required this.angleOffset, 
    this.isEnemy = false,
    this.isFoice = false, 
    this.owner,
    this.radius = 45,
    this.speed = 3,
    Vector2? size,
    }) : super(size: size ?? Vector2.all(12), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _currentAngle = angleOffset;
    
    // Visual do escudo
    if(isFoice){
      add(GameIcon(
        icon: MdiIcons.sickle,
        color: Pallete.lilas,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      ));
    }else{
      add(GameIcon(
        icon: MdiIcons.shield,
        color: Pallete.lilas,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      ));
    }

    // Colisor para detectar projéteis inimigos
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Movimento Circular: x = cos(a) * r, y = sin(a) * r
    _currentAngle += speed * dt;
    final playerCenter = owner?.position;
    
    position = Vector2(
      playerCenter!.x + cos(_currentAngle) * radius,
      playerCenter!.y + sin(_currentAngle) * radius,
    );
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if(isFoice){
      if (other is Enemy && !isEnemy) {
        other.takeDamage(gameRef.player.damage);
      }else if (other is Player && isEnemy) {
        other.takeDamage(1);
      }
    }else{
      if (other is Projectile ) {
        if (isEnemy && !other.isEnemyProjectile){
          other.removeFromParent(); 
        }else if (!isEnemy && other.isEnemyProjectile){
          other.removeFromParent(); 
        } 
      }
    }
    
  }
}