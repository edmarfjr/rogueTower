import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';

class InteractButton extends PositionComponent with TapCallbacks, HasGameRef<TowerGame> {
  final VoidCallback onTrigger;

  InteractButton({required this.onTrigger}) 
      : super(size: Vector2(80, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Fica acima de tudo no mundo
    priority = 100; 

    // Fundo do botão (Estilo Balão de Fala)
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white,
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    // Borda
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Texto "ABRIR" ou Ícone
    add(TextComponent(
      text: "ABRIR",
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
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