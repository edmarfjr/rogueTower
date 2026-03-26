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

class BloodMachine extends PositionComponent with HasGameRef<TowerGame> {
  bool _isInfoVisible = false;
  final double _interactRange = 60.0;
  InteractButton? _currentButton;
  TextComponent? _nameText;

  // Evitar que o jogador clique 10x por segundo acidentalmente
  double _cooldown = 0;

  BloodMachine({required Vector2 position}) 
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
      icon: MdiIcons.bloodBag, 
      color: Pallete.vermelho,
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
      text: "DOAR SANGUE\n(-1 HP)",
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
      player.takeDamage(1); 
      
      // Feedback visual do custo
      gameRef.world.add(FloatingText(
        text: "-1 HP",
        position: player.position.clone() + Vector2(0, -30),
        color: Pallete.vermelho,
      ));

      // 4. Efeito Visual de Sangue jorrando da máquina
      createExplosionEffect(gameRef.world, position.clone(), Pallete.vermelho, count: 15);
      AudioManager.playSfx('hit.mp3'); 

      // 5. MÁGICA DA RECOMPENSA: Gera um item comum
      final pool = retornaItensComuns(player); // Da sua classe collectible.dart
      
      if (pool.isNotEmpty) {
        pool.shuffle();
        
        final newItem = Collectible(
          position: Vector2(0, 10), 
          type: pool.first,
        );
        
        gameRef.world.add(newItem);
        
        // Faz o item "cuspir" para longe da máquina (Usa a função pop que você já tem!)
        newItem.pop(Vector2(0, 20));
      }
    }
  }
}