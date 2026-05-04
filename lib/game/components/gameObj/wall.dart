import 'dart:math';

import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';

class Wall extends PositionComponent with HasGameRef<TowerGame> {
  int vida;
  bool isDetalhe;
  Wall({required Vector2 position,
        this.vida = 3,
        this.isDetalhe = false
  }) : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {

    final rng = Random();

    if(isDetalhe){
      final int currLevel = gameRef.currentLevelNotifier.value;
      add(GameSprite(
        imagePath: 'sprites/tileset/detalhe.png',
        size: size,
        color: _getLevelColor(currLevel), 
        anchor: Anchor.center,
        position: size / 2
      ));

      priority = -1000;

    }else{
      List<String> possibleIcons = [
        'sprites/tileset/bloqueio.png', 
        'sprites/tileset/mushroom.png', 
        'sprites/tileset/estalagmite.png', 
      ];

      if (gameRef.currentLevel == 2){
        possibleIcons = [
          'sprites/tileset/flor.png', 
          'sprites/tileset/pinheiro.png', 
          'sprites/tileset/moita.png', 
        ];
      } else if (gameRef.currentLevel == 3){
        possibleIcons = [
          'sprites/tileset/tumulo.png',
          'sprites/tileset/ossos.png',    
          'sprites/tileset/cruz.png',    
        ];
      } else if (gameRef.currentLevel == 4){
        possibleIcons = [
          'sprites/tileset/tabuleiro.png',
          'sprites/tileset/dama.png',
          'sprites/tileset/cartas.png',
        ];
      } else if (gameRef.currentLevel == 5){
        possibleIcons = [
          'sprites/tileset/bloqueio.png', 
          'sprites/tileset/anemona.png',
          'sprites/tileset/alga.png', 
        ];
      } else if (gameRef.currentLevel == 6){
        possibleIcons = [
          'sprites/tileset/crate.png', 
          'sprites/tileset/weaponRack.png', 
          'sprites/tileset/toten.png',
        ];
      } else if (gameRef.currentLevel == 7){
        possibleIcons = [
          'sprites/tileset/crate2.png', 
          'sprites/tileset/barril.png', 
          'sprites/tileset/tanque.png', 
        ];
      } else if (gameRef.currentLevel == 8){
        possibleIcons = [
          'sprites/tileset/ponta.png', 
          'sprites/tileset/tentaculo.png', 
          'sprites/tileset/espiral.png', 
        ];
      }

      final String icon = possibleIcons[rng.nextInt(possibleIcons.length)];
      
      // Visual: Um bloco sólido (ícone de grade ou quadrado)
      add(GameSprite(
        imagePath: icon, // Parecido com tijolos ou pedras
        color: Pallete.cinzaEsc,     // Cor de pedra
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

      priority = position.y.toInt();
    }
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Pallete.marrom;      
      case 2: return Pallete.verdeEsc; 
      case 3: return Pallete.cinzaCla; 
      case 4: return Pallete.lilas; 
      case 5: return Pallete.azulCla; 
      case 6: return Pallete.marrom; 
      case 7: return Pallete.azulCla; 
      case 8: return Pallete.rosa; 
      default: return Pallete.azulEsc;
    }
  } 

  void takeDamage(){
    vida--;
    if (vida<=0){
      die();
    }
  }

  void die(){
    int rnd = Random().nextInt(100);
    if(rnd <= 5){
      final newItem = Collectible(
            position: position.clone(), 
            type: CollectibleType.coinUm,
          );
        
      gameRef.world.add(newItem);
      
      newItem.pop(Vector2(0, 0));
    }
    removeFromParent();
  }

}