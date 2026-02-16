import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// Função auxiliar para criar explosões
void createExplosionEffect(World world, Vector2 position, Color color, {int count = 10, double lifespan = 0.6, double velocity = 200}) {
  final rng = Random();

  // Cria um componente de sistema de partículas
  final particleSystem = ParticleSystemComponent(
    particle: Particle.generate(
      count: count,
      lifespan: lifespan, // Duração da explosão (segundos)
      generator: (i) {
        // Gera vetores aleatórios para as partículas voarem
        final speed = Vector2(
          (rng.nextDouble() - 0.5) * velocity, // Velocidade X (-velocity a velocity)
          (rng.nextDouble() - 0.5) * velocity, // Velocidade Y (-velocity a velocity)
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