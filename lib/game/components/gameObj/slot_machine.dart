import 'dart:math';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/gameObj/chest.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../tower_game.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';
import '../core/interact_button.dart';
import '../core/audio_manager.dart';
import '../effects/explosion_effect.dart';
import '../effects/floating_text.dart';
import 'collectible.dart';

class SlotMachine extends PositionComponent with HasGameRef<TowerGame> {
  bool _isInfoVisible = false;
  final double _interactRange = 60.0;
  InteractButton? _currentButton;
  TextComponent? _nameText;

  // Evitar que o jogador clique 10x por segundo acidentalmente
  double _cooldown = 0;

  SlotMachine({required Vector2 position}) 
    : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Hitbox física da máquina
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));

    // Visual da Máquina de Sangue (Uma bolsa de sangue ou cruz vermelha)
    add(GameSprite(
      imagePath: 'sprites/gameObjs/slot.png', 
      color: Pallete.laranja,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_cooldown > 0) _cooldown -= dt;

    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _interactRange) {
      if (!_isInfoVisible) {
        _showButton();
        _showText();
      }
    } else {
      if (_isInfoVisible) {
        _hideButton();
        _hideText();
      }
    }
  }

  void _showText() {
    _nameText = TextComponent(
      text: "5 moedas",
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 12, 
          color: Pallete.vermelho, 
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
        ),
      ),
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, -10),
    );
    add(_nameText!);
  }

  void _hideText() {
    if (_nameText != null) {
      remove(_nameText!);
      _nameText = null;
    }
  }

  void _showButton() {
    final screenSize = gameRef.camera.viewport.size;
    final hudPosition = Vector2(screenSize.x/2-(5*16),screenSize.y/2-(3.5*16));
    _isInfoVisible = true;
    
    _currentButton = InteractButton(
      position: hudPosition,
      onTrigger: _sort,
    ); 
    gameRef.camera.viewport.add(_currentButton!);
  }

  void _hideButton() {
    _isInfoVisible = false;
    if (_currentButton != null) {
      gameRef.camera.viewport.remove(_currentButton!);
      _currentButton = null;
    }
  }

  void explode(){
    final player = gameRef.player;
    int rng = Random().nextInt(100);

    CollectibleType item = CollectibleType.coin;
    bool temItem = true;

    if(rng < 35){
      item = CollectibleType.coin;
    }else if(rng >= 35 && rng < 55){
      item = CollectibleType.potion;
    }else if(rng >= 55 && rng < 70){
      item = CollectibleType.key;
    }else if(rng >= 70 && rng < 90){
      item = CollectibleType.bomba;
    }else if(rng >= 90 && rng < 95){
      gameRef.world.add(Chest(position: position.clone()));
      temItem = false;
    }else if(rng >= 95){
      gameRef.world.add(Chest(position: position.clone(),isLock: true));
      temItem = false;
    }
    

    // ignore: curly_braces_in_flow_control_structures
    if (temItem){
      final newItem = Collectible(
        position: Vector2(0, 10), 
        type: item,
      );
    
      gameRef.world.add(newItem);
      
      // Faz o item "cuspir" para longe da máquina (Usa a função pop que você já tem!)
      newItem.pop(Vector2(0, 20));
    }

    removeFromParent();
  }

  void _sort() {
    if (_cooldown > 0) return;
    _cooldown = 0.5; 

    final player = gameRef.player;

    if(gameRef.coinsNotifier.value >= 5)
    {
      player.collectCoin(-5); 
      player.slotMachine();
      
    }else{
      gameRef.world.add(FloatingText(
        text: "noCoin".tr(),
        position: player.position.clone() + Vector2(0, -30),
        color: Pallete.vermelho,
      ));
    }
      
  }
}