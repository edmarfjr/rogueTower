import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; // Ajuste imports

import '../enemies/enemy.dart';

class Explosion extends PositionComponent with HasGameRef<TowerGame> {
  final double radius;
  final double damage;
  final bool damagesPlayer; // Se true, machuca player. Se false, machuca inimigos.

  double _timer = 0;
  final double _duration = 0.2; // Explosão rápida

  Explosion({
    required Vector2 position,
    this.radius = 60,
    this.damage = 1,
    this.damagesPlayer = true,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 20; // Fica por cima de tudo
    
    // Toca som se tiver
    // AudioManager.playSfx('explosion.wav');

    // VERIFICA DANO INSTANTÂNEO AO NASCER
    if (damagesPlayer) {
      final player = gameRef.player;
      if (player.position.distanceTo(position) <= radius) {
        player.takeDamage(damage.toInt());
      }
    } else {
      // Se quiser que exploda inimigos (fogo amigo), implemente aqui
      final enemies = gameRef.world.children.query<Enemy>();
      for(final e in enemies){
         if (e.position.distanceTo(position) <= radius) {
            e.takeDamage(damage * 5); // Explosão dói mais em inimigos
         }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Progresso de 0.0 a 1.0
    double progress = _timer / _duration; 
    
    // Círculo expandindo
    double currentRadius = radius * (0.2 + (0.8 * progress));
    
    // Opacidade diminuindo (fading out)
    double opacity = 1.0 - progress;
    if (opacity < 0) opacity = 0;

    final paint = Paint()
      ..color = Pallete.vermelho
      ..style = PaintingStyle.fill;
      
    final paintBorder = Paint()
      ..color = Pallete.amarelo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset.zero, currentRadius, paint);
    canvas.drawCircle(Offset.zero, currentRadius, paintBorder);
  }
}