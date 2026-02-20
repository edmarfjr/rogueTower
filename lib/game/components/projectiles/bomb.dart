import 'dart:math';

import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class Bomb extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  double _timer = 0;
  final double duration;
  final double damage;
  final bool isMine;
  final bool isEnemy;
  late final Vector2 direction;
  Bomb({required Vector2 position, 
        this.duration = 2.0, 
        this.damage = 10, 
        this.isMine = false, 
        this.isEnemy = false, 
        Vector2? direction}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center) {
    this.direction = direction ?? Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    
    add(GameIcon(
      icon: isMine ? MdiIcons.disc : MdiIcons.bomb, 
      color: isEnemy ? Pallete.vermelho : isMine ?Pallete.verdeEsc:Pallete.lilas,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Hitbox Sólida
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));
  }

   @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= duration && !isMine) {
      if (isEnemy) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:true, damage:damage, radius:100));
      } else {
        gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, radius:100));
      }
      
      removeFromParent();
    }
    if (isMine && _timer <= duration/4) {
      // Movimento Lento
      position.addScaled(direction, 200 * dt);
    }
  }

@override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (isMine){
      if (!isEnemy && other is Enemy) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, radius:60));
        removeFromParent();
      }else if (isEnemy && other is Player) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:true, damage:1, radius:60));
        removeFromParent();
      }
    }
  }

}