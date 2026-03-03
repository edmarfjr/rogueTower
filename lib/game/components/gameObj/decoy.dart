import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';

class Decoy extends PositionComponent with HasGameRef<TowerGame> {
  final double followDistance = 120.0; 
  final double speed = 200.0; 

  Decoy({required Vector2 position}) : super(position: position, size: Vector2.all(32), anchor: Anchor.center) {
    priority = 10; 
  }

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: Icons.directions_walk,
      color: Pallete.cinzaCla.withOpacity(0.7), 
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPos = gameRef.player.position;
    final dist = position.distanceTo(playerPos);

    if (dist > followDistance) {
      final direction = (playerPos - position).normalized();
      position += direction * speed * dt;
    }
  }
}