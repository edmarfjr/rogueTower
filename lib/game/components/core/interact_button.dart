import 'package:towerrogue/game/components/core/game_icon.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InteractButton extends PositionComponent with TapCallbacks, KeyboardHandler {
  final VoidCallback onTrigger;
  double pressTmr = 0.0 ;
  // Pega o tamanho real da tela neste exato frame
    //final screenSize = gameRef.camera.viewport.size;
    // Define a posição no canto inferior direito
    //final hudPosition = Vector2(screenSize.x - 200, screenSize.y - 200);

  // AGORA ELE EXIGE RECEBER A POSIÇÃO NA HORA DE SER CRIADO!
  InteractButton({required this.onTrigger, required Vector2 position}) 
      : super(size: Vector2(40,40), anchor: Anchor.center, position: position);

  @override
  Future<void> onLoad() async {
    priority = 1000; // Prioridade bem alta para ficar acima de todos os HUDs

    add(CircleComponent(
      radius: size.x,
      paint: Paint()..color = Pallete.branco.withValues(alpha: 0.2),
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    add(CircleComponent(
      radius: size.x,
      paint: Paint()
        ..color = Pallete.branco.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      anchor: Anchor.center,
      position: size / 2,
    ));

    add(GameIcon(
      icon: MdiIcons.exclamationThick, 
      color: Pallete.amarelo, 
      size: size / 2,
      anchor: Anchor.center, 
      position: size / 2,    
    ));
  }
  @override
  void update(double dt) {
    if(pressTmr > 0) pressTmr -=dt;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if(pressTmr <= 0){
      pressTmr = 0.3;
      onTrigger();
    }
    
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {

    if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
      onTrigger();
    }
    return true;
    
  }

}