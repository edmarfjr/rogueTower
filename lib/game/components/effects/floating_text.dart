import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  double duration;

  FloatingText({
    required String text,
    required Vector2 position,
    this.duration = 1,
    Color color = Colors.white,
    double fontSize = 16,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          priority: 1500, 
          textRenderer: TextPaint(
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(blurRadius: 2, color: Pallete.preto, offset: Offset(1, 1)),
              ],
            ),
          ),
        );

  @override
  Future<void> onLoad() async {
    add(MoveEffect.by(
      Vector2(0, -30),
      EffectController(duration: duration, curve: Curves.easeOut),
    ));

    add(RemoveEffect(
      delay: duration,
    ));
  }
}