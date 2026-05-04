import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
//import 'package:flutter/material.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';
//import '../core/interact_button.dart';

class BankAtm extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  //InteractButton? _currentButton;
  double _cooldown = 0;
  final double _interactRange = 32;
  bool _isInfoVisible = false;

  BankAtm({required Vector2 position})
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual: Um cofre ou caixa eletrônico
    add(GameSprite(
      imagePath: 'sprites/gameObjs/banco.png', // Ou Icons.savings
      color: Pallete.laranja,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Hitbox
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));

    priority = position.y.toInt();
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
      }
    } else {
      if (_isInfoVisible) {
        _hideButton();
      }
    }
  }

  void _showButton() {
    if(gameRef.canInteractNotifier.value) return;
    if(gameRef.interactIsItem.value) return;
    gameRef.onInteractAction = (){
        // Lógica de abrir o menu
        gameRef.pauseEngine();
        gameRef.overlays.add('bank_menu');
        
        // Esconde o botão logo após clicar para limpar a tela
        _hideButton(); 
      };
    gameRef.canInteractNotifier.value = true;
  }

  void _hideButton() {
    gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;
  }
}