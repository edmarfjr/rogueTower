import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/pallete.dart';

class ElectricSpark extends Component {
  final Vector2 startPoint;
  final Vector2 endPoint;
  double lifespan = 0.1; // O raio dura apenas 100ms (1 décimo de segundo)
  final Random _random = Random();
  late Path _lightningPath;

  ElectricSpark({
    required this.startPoint,
    required this.endPoint,
  }) {
    _generateLightning();
  }

  @override
  int get priority => 80;

  void _generateLightning() {
    _lightningPath = Path();
    _lightningPath.moveTo(startPoint.x, startPoint.y);

    int segments = 4; // Quantas "quebras" o raio vai ter no caminho
    Vector2 delta = endPoint - startPoint;
    Vector2 step = delta / segments.toDouble();

    Vector2 currentPoint = startPoint.clone();

    // Cria as quinas do raio
    for (int i = 1; i < segments; i++) {
      currentPoint += step;
      // Adiciona um desvio aleatório (ruído) no eixo X e Y
      double offsetX = (_random.nextDouble() - 0.5) * 20; // Força da tremedeira
      double offsetY = (_random.nextDouble() - 0.5) * 20;
      _lightningPath.lineTo(currentPoint.x + offsetX, currentPoint.y + offsetY);
    }

    // Liga até o ponto final
    _lightningPath.lineTo(endPoint.x, endPoint.y);
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifespan -= dt;
    
    // Opcional: Se quiser que o raio "vibre" enquanto estiver vivo, 
    // descomente a linha abaixo para regerar o formato a cada frame.
    // _generateLightning();

    if (lifespan <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final glowPaint = Paint()
      ..color = Pallete.azulCla.withOpacity(0.6) 
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus; 

    final corePaint = Paint()
      ..color = Pallete.branco
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(_lightningPath, glowPaint);
    canvas.drawPath(_lightningPath, corePaint);
  }
}