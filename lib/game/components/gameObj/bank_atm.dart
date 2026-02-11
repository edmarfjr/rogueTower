import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/interact_button.dart';

class BankAtm extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  InteractButton? _currentButton;

  BankAtm({required Vector2 position})
      : super(position: position, size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual: Um cofre ou caixa eletrônico
    add(GameIcon(
      icon: Icons.account_balance, // Ou Icons.savings
      color: Colors.amberAccent,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Hitbox
    add(RectangleHitbox(
      size: size, 
      isSolid: true, // Player bate nela
    ));

    add(CircleHitbox(
      radius: 60, // Raio de detecção (maior que o objeto)
      anchor: Anchor.center,
      position: size / 2,
      isSolid: false, // Player atravessa (apenas gatilho)
    ));
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other == gameRef.player) {
      _showButton();
    }
  }

  // Quando o Player SAI da área
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other == gameRef.player) {
      _hideButton();
    }
  }

  void _showButton() {
    // Evita criar duplicados
    if (_currentButton != null) return;

    _currentButton = InteractButton(
      onTrigger: () {
        // Lógica de abrir o menu
        gameRef.pauseEngine();
        gameRef.overlays.add('bank_menu');
        
        // Esconde o botão logo após clicar para limpar a tela
        _hideButton(); 
      },
    );

    // Posiciona o botão ACIMA do banco (no eixo Y negativo)
    _currentButton!.position = Vector2(size.x / 2, -40); 
    
    add(_currentButton!);
  }

  void _hideButton() {
    if (_currentButton != null) {
      _currentButton!.removeFromParent();
      _currentButton = null;
    }
  }
}