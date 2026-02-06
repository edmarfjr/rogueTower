import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../game_icon.dart';

class Wall extends PositionComponent with HasGameRef<TowerGame> {
  Wall({required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual: Um bloco sólido (ícone de grade ou quadrado)
    add(GameIcon(
      icon: Icons.grid_view, // Parecido com tijolos ou pedras
      color: Colors.grey,     // Cor de pedra
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Hitbox Sólida
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));
  }
}