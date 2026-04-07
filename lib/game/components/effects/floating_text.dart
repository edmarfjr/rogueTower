import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

class FloatingText extends TextComponent {
  double duration;

  FloatingText({
    required String text,
    required Vector2 position,
    this.duration = 1.0,
    TextPaint? paint, // 1. Mudamos para TextPaint? (pode ser nulo) e tiramos o valor padrão
    Color color = Colors.white,
    double fontSize = 16,
  }) : super(
          text: text,
          position: position,
          anchor: Anchor.center,
          priority: 1500, 
          // 2. A Mágica: Se 'paint' for nulo, usa o 'Pallete.textoPadrao'
          textRenderer: paint ?? Pallete.textoPadrao, 
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