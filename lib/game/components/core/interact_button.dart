import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';

class InteractButton extends PositionComponent with TapCallbacks, HasGameRef<TowerGame> {
  final VoidCallback onTrigger;
  String text;

  InteractButton({required this.onTrigger, this.text = "PEGAR"}) 
      : super(size: Vector2(80, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Fica acima de tudo no mundo
    priority = 100; 

    // Fundo do botão (Estilo Balão de Fala)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Pallete.azulEsc,
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    // Borda
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Pallete.lilas
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Texto "ABRIR" ou Ícone
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
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Executa a ação quando clicado
    onTrigger();
  }
}