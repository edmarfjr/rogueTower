import 'package:TowerRogue/game/components/core/game_icon.dart';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';

class InteractButton extends PositionComponent with TapCallbacks, HasGameRef<TowerGame> {
  final VoidCallback onTrigger;
  String text;

  InteractButton({required this.onTrigger, this.text = "!"}) 
      : super(size: Vector2(40, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Fica acima de tudo no mundo
    priority = 100; 

    // Fundo do botão (Estilo Balão de Fala)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Pallete.cinzaEsc,
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    // Borda
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Pallete.cinzaCla
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      anchor: Anchor.center,
      position: size / 2,
    ));

    add(GameIcon(
      icon: MdiIcons.exclamationThick, 
      color: Pallete.amarelo, 
      size: size/2,
      anchor: Anchor.center, 
      position: size / 2 + Vector2(0,-5),    
    ));
    /* Texto "ABRIR" ou Ícone
    add(TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Pallete.branco,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: size / 2,
    ));
    */
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Executa a ação quando clicado
    onTrigger();
  }
}