import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../core/game_icon.dart';

// 1. Adicionado "with HasPaint" para permitir efeitos de opacidade (OpacityProvider)
class GhostParticle extends PositionComponent with HasPaint {
  final IconData icon;
  final Color color;
  final Vector2 particleScale; // 2. Renomeado para não conflitar com a propriedade interna

  GhostParticle({
    required this.icon,
    required this.color,
    required Vector2 position,
    required Vector2 size,
    Vector2? scale, // Agora aceita nulo para facilitar a chamada
    required Anchor anchor,
  })  : particleScale = scale ?? Vector2.all(1), // Se for nulo, vira (1,1)
        super(
          position: position,
          size: size,
          anchor: anchor,
        );

  @override
  Future<void> onLoad() async {
    // 3. Aplica o scale no componente pai usando setFrom
    scale.setFrom(particleScale);

    // Adiciona o ícone visual
    add(GameIcon(
      icon: icon,
      color: color,
      size: size,
      // Passamos Vector2.all(1) aqui porque o 'scale' já foi aplicado no pai (GhostParticle)
      scale: Vector2.all(1), 
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Efeito de desaparecer (Fade Out)
    // Funciona agora devido ao mixin HasPaint
    add(OpacityEffect.fadeOut(
      EffectController(duration: 0.3, curve: Curves.easeOut),
      onComplete: () => removeFromParent(),
    ));

    // Faz a partícula subir levemente
    add(MoveByEffect(
      Vector2(0, -5),
      EffectController(duration: 0.3),
    ));
  }
}