import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// Função auxiliar para criar explosões
void createExplosion(World world, Vector2 position, Color color, {int count = 10}) {
  final rng = Random();

  // Cria um componente de sistema de partículas
  final particleSystem = ParticleSystemComponent(
    particle: Particle.generate(
      count: count,
      lifespan: 0.6, // Duração da explosão (segundos)
      generator: (i) {
        // Gera vetores aleatórios para as partículas voarem
        final speed = Vector2(
          (rng.nextDouble() - 0.5) * 200, // Velocidade X (-100 a 100)
          (rng.nextDouble() - 0.5) * 200, // Velocidade Y (-100 a 100)
        );

        // AceleratedParticle faz a partícula se mover
        return AcceleratedParticle(
          position: position.clone(),
          speed: speed,
          // ComputedParticle nos permite desenhar o que quisermos (quadradinhos)
          child: ComputedParticle(
            renderer: (canvas, particle) {
              final paint = Paint()..color = color.withOpacity(1 - particle.progress);
              // Desenha um quadradinho que diminui com o tempo
              canvas.drawRect(
                Rect.fromCenter(center: Offset.zero, width: 4, height: 4),
                paint,
              );
            },
          ),
        );
      },
    ),
  );

  world.add(particleSystem);
}