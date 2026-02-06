import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Dust extends CircleComponent {
  double _lifeTime = 0.5; // Dura meio segundo
  final double _decayRate = 2.0; // Velocidade que diminui

  Dust({required Vector2 position})
      : super(
          radius: Random().nextDouble() * 5 + 3, // Tamanho aleatório entre 3 e 8
          position: position,
          anchor: Anchor.center,
          priority: 9, // Desenha embaixo do Player (que geralmente é priority 10+)
        ) {
    // Cor cinza/branca aleatória
    int shade = 200 + Random().nextInt(55);
    paint = Paint()..color = Color.fromARGB(150, shade, shade, shade);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Reduz o tempo de vida
    _lifeTime -= dt;

    // 2. Diminui o tamanho (escala)
    radius -= dt * 10; 
    if (radius < 0) radius = 0;

    // 3. Diminui a Opacidade (Fade out)
    // Pega a opacidade atual e reduz
    double currentOpacity = paint.color.opacity;
    currentOpacity -= dt * _decayRate;
    
    if (currentOpacity <= 0 || _lifeTime <= 0) {
      removeFromParent(); // Tchau!
    } else {
      // Atualiza a cor com nova opacidade
      paint.color = paint.color.withOpacity(currentOpacity);
    }
  }
}