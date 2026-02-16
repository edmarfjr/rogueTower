import 'dart:math';

import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class Bomb extends PositionComponent with HasGameRef<TowerGame> {
  double _timer = 0;
  final double duration;
  final double damage;
  Bomb({required Vector2 position, this.duration = 2.0, this.damage = 10}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    
    add(GameIcon(
      icon: MdiIcons.bomb, 
      color: Pallete.cinzaEsc,
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
    if (_timer >= duration) {
      gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, apagaTiros: true, radius:100));
      removeFromParent();
    }
  }

}