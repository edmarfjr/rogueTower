import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  FloatingText({
    required String text,
    required Vector2 position,
    Color color = Colors.white,
    double fontSize = 16,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          priority: 100, // Garante que desenha em cima de tudo
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              shadows: [
                // Sombra preta para garantir leitura em qualquer fundo
                const Shadow(blurRadius: 2, color: Colors.black, offset: Offset(1, 1)),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    // 1. Efeito de Subir (Move para cima 30 pixels em 0.6 segundos)
    add(MoveEffect.by(
      Vector2(0, -30),
      EffectController(duration: 0.6, curve: Curves.easeOut),
    ));

    // 2. Efeito de Sumir (Remove do jogo após 0.6 segundos)
    add(RemoveEffect(
      delay: 0.6,
    ));
  }
}