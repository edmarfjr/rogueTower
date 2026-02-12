import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class Wall extends PositionComponent with HasGameRef<TowerGame> {
  int vida = 3;
  Wall({required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {

    final rng = Random();

    List<IconData> possibleIcons = [
      Icons.grid_view, 
      Icons.terrain
    ];

    if (gameRef.currentLevel == 2){
      possibleIcons = [
        MdiIcons.graveStone,
        MdiIcons.skullCrossbones
      ];
    }

    final IconData icon = possibleIcons[rng.nextInt(possibleIcons.length)];
    
    // Visual: Um bloco sólido (ícone de grade ou quadrado)
    add(GameIcon(
      icon: icon, // Parecido com tijolos ou pedras
      color: Colors.grey,     // Cor de pedra
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
}