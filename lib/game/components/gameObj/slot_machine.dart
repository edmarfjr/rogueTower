import 'dart:math';
import 'package:TowerRogue/game/components/core/i18n.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
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
    : super(position: position, size: Vector2.all(40), anchor: Anchor.center);

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
    add(GameIcon(
      icon: MdiIcons.slotMachine, 
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
    final hudPosition = Vector2(screenSize.x - 150, screenSize.y - 170);
    _isInfoVisible = true;
    
    _currentButton = InteractButton(
      position: hudPosition,
      onTrigger: _donate,
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

  void _donate() {
    // 1. Previne spam de cliques
    if (_cooldown > 0) return;
    _cooldown = 0.5; // Meio segundo de cooldown entre doações

    final player = gameRef.player;

    // 2. Verifica se o jogador tem vida maior que 0 (Permitimos suicídio tático!)
    if (player.healthNotifier.value > 0 || player.artificialHealthNotifier.value > 0) {
      
      // 3. Aplica o Dano (Usa a sua função padrão de dano)
      if(gameRef.coinsNotifier.value >= 5)
      {
        player.collectCoin(-5); 
      
      // Feedback visual do custo
        gameRef.world.add(FloatingText(
          text: "-5 MOEDAS",
          position: player.position.clone() + Vector2(0, -30),
          color: Pallete.vermelho,
        ));

        // 4. Efeito Visual de Sangue jorrando da máquina
        createExplosionEffect(gameRef.world, position.clone(), Pallete.branco, count: 15);
        AudioManager.playSfx('hit.mp3'); 

        int rng = Random().nextInt(100);

        var item;

        if (rng > 40){
          if(rng < 50){
            item = CollectibleType.coinUm;
          }else if(rng >= 50 && rng < 60){
            item = CollectibleType.coin;
          }else if(rng >= 60 && rng < 70){
            item = CollectibleType.bomba;
          }else if(rng >= 70 && rng < 80){
            item = CollectibleType.key;
          }else if(rng >= 80 && rng < 90){
            item = CollectibleType.potion;
          }else if(rng >= 90 && rng < 98){
            var pool = retornaItensComuns(player);
            item = pool.first;
          }else if(rng >= 98){
            gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:true, damage:1, radius:60));
          }
        }else{
          return;
        }

        // ignore: curly_braces_in_flow_control_structures
        if (item != null){
          final newItem = Collectible(
            position: Vector2(0, 10), 
            type: item,
          );
        
          gameRef.world.add(newItem);
          
          // Faz o item "cuspir" para longe da máquina (Usa a função pop que você já tem!)
          newItem.pop(Vector2(0, 20));
        }
      }else{
        gameRef.world.add(FloatingText(
        text: "noCoin".tr(),
        position: player.position.clone() + Vector2(0, -30),
        color: Pallete.vermelho,
      ));
      }
      
    }
  }
}