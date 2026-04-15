import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

// Função auxiliar para criar explosões
void createExplosionEffect(World world, Vector2 position, Color color, {int count = 10, double lifespan = 0.6, double velocity = 200}) {
  final rng = Random();

  // OTIMIZAÇÃO: Cria o Paint uma única vez fora do loop
  final paint = Paint()..color = color
                      ..isAntiAlias = false; 
                      

  final particleSystem = ParticleSystemComponent(
    particle: Particle.generate(
      count: count,
      lifespan: lifespan,
      generator: (i) {
        final speed = Vector2(
          (rng.nextDouble() - 0.5) * velocity,
          (rng.nextDouble() - 0.5) * velocity,
        );

        return AcceleratedParticle(
          position: position.clone(),
          speed: speed,
          child: ComputedParticle(
            renderer: (canvas, particle) {
              // OTIMIZAÇÃO: Apenas altera a opacidade do Paint existente
              // Em vez de criar um novo Paint().
              paint.color = color.withOpacity(1 - particle.progress);
              //paint.color = color;
              canvas.drawCircle(Offset.zero, 2 * (1 - particle.progress), paint);
              //canvas.drawRect(
              //  const Rect.fromLTWH(-2, -2, 4, 4), // Usa const para evitar alocação
              //  paint,
              //);
            },
          ),
        );
      },
    ),
  );

  world.add(particleSystem);
}