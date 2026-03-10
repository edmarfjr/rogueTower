import 'dart:math';

import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:TowerRogue/game/components/projectiles/projectile.dart';
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
  final PositionComponent? owner;
  final bool splits;
  final int splitCount;
  final bool isDecoy;
  final double attractionRadius = 150;

  late final Vector2 direction;
  Bomb({required Vector2 position, 
        this.duration = 2.0, 
        this.damage = 10, 
        this.isMine = false, 
        this.isEnemy = false, 
        this.owner,
        this.splits = false,
        this.splitCount = 8,
        this.isDecoy = false,
        Vector2? direction}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center) {
    this.direction = direction ?? Vector2.zero();
  }

  @override
  Future<void> onLoad() async {
    
    add(GameIcon(
      icon: isMine ? MdiIcons.mine : MdiIcons.bomb, 
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
    /*if(isDecoy){
      add(CircleComponent(
        radius: attractionRadius,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 2,
      ));
    }*/
  }

   @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    if (isDecoy){
      final enemies = gameRef.world.children.whereType<Enemy>();
    
      for (var enemy in enemies) {
        double dist = position.distanceTo(enemy.position);

        if (dist <= attractionRadius) {
          // Hackeia a mente do inimigo!
          enemy.lureTarget = this; 
        } else if (enemy.lureTarget == this) {
          // Se o inimigo for empurrado para fora do raio, ele acorda da hipnose
          enemy.lureTarget = null; 
        }
      }
    }

    if (_timer >= duration && !isMine) {
      if (isEnemy) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:true, damage:damage, radius:100));
      } else {
        gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, radius:100));
      }

      if(splits){
        _doSplit();
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
      if (!isEnemy && other is Enemy && !other.isIntangivel) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, radius:60));
        removeFromParent();
      }else if (isEnemy && other is Player) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:true, damage:1, radius:60));
        removeFromParent();
      }
    }
  }

  void _doSplit() {
    for (int i = 0; i < splitCount; i++) {
      double angle = (2 * pi / splitCount) * i; 
      Vector2 newDir = Vector2(cos(angle), sin(angle));
      
      gameRef.world.add(Projectile(
        position: position.clone(), 
        direction: newDir,
        speed: 500 * 0.8, 
        damage: damage / 3, 
        isEnemyProjectile: isEnemy,
        owner: owner,
        dieTimer: 1.0, 
        size: Vector2.all(10), 
        canBounce: false,
        explodes: false, 
        splits: false, 
      ));
    }
  }


}