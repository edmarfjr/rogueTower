import 'package:TowerRogue/game/components/core/game_icon.dart';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class InteractButton extends PositionComponent with TapCallbacks {
  final VoidCallback onTrigger;

  // Pega o tamanho real da tela neste exato frame
    //final screenSize = gameRef.camera.viewport.size;
    // Define a posição no canto inferior direito
    //final hudPosition = Vector2(screenSize.x - 200, screenSize.y - 200);

  // AGORA ELE EXIGE RECEBER A POSIÇÃO NA HORA DE SER CRIADO!
  InteractButton({required this.onTrigger, required Vector2 position}) 
      : super(size: Vector2(35, 35), anchor: Anchor.center, position: position);

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
  void onTapDown(TapDownEvent event) {
    onTrigger();
  }
}