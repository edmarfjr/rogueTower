import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart';
import '../../tower_game.dart'; // Ajuste o import do seu jogo

class MagicShieldEffect extends PositionComponent with HasGameRef<TowerGame> {
  
  double _timer = 0;
  
  // Tintas para o efeito neon
  final Paint _paintRing1 = Paint()
    ..color = Pallete.azulCla.withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2); // Brilho

  final Paint _paintRing2 = Paint()
    ..color = Pallete.verdeCla.withValues(alpha: 0.5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  MagicShieldEffect({required Vector2 size}) 
      : super(size: size, anchor: Anchor.center, position: size / 2);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    
    // Efeito de Pulsar (Scale) suave
    // Vai de 1.0 a 1.1 e volta
    double scalePulse = 1.0 + (sin(_timer * 3) * 0.05);
    scale = Vector2.all(scalePulse);
    
    // Rotação lenta do componente inteiro
    angle += dt * 0.5;
  }

  @override
  void render(Canvas canvas) {
    // Raio base (um pouco maior que o player)
    double radius = (size.x / 2) + 5;

    // Anel 1: Tracejado (Desenhamos arcos soltos)
    // Gira no sentido horário (usando o angle do componente)
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: radius),
      0, pi / 2, false, _paintRing1
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(size.x/2, size.y/2), radius: radius),
      pi, pi / 2, false, _paintRing1
    );

    // Anel 2: Linha sólida interna
    // Para girar ao contrário, salvamos o estado do canvas, giramos e restauramos
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(-_timer * 2); // Gira rápido anti-horário
    canvas.drawCircle(Offset.zero, radius * 0.8, _paintRing2);
    canvas.restore();
  }
}