import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';

class TargetReticle extends PositionComponent with HasGameRef<TowerGame> {
  final double duration;
  final double radius;
  
  double _timer = 0;

  TargetReticle({
    required Vector2 position,
    required this.duration,
    this.radius = 60,
  }) : super(position: position, size: Vector2.all(radius * 2), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 0; // Fica no chão
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // --- CORREÇÃO AQUI ---
    // Calculamos onde é o CENTRO exato do componente visual
    final center = Offset(size.x / 2, size.y / 2);

    double progress = _timer / duration;
    
    // 1. FUNDO (Usamos 'center' em vez de Offset.zero)
    final paintArea = Paint()
      ..color = Pallete.vermelho.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, radius, paintArea);

    // 2. O "X" (Calculado a partir do 'center')
    final paintX = Paint()
      ..color = Pallete.vermelho.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    double xSize = radius * 0.4;
    
    // Linha 1 do X
    canvas.drawLine(
      Offset(center.dx - xSize, center.dy - xSize), 
      Offset(center.dx + xSize, center.dy + xSize), 
      paintX
    );
    
    // Linha 2 do X
    canvas.drawLine(
      Offset(center.dx + xSize, center.dy - xSize), 
      Offset(center.dx - xSize, center.dy + xSize), 
      paintX
    );

    // 3. ANEL DE TEMPO
    double currentRingRadius = radius * (1.0 - progress);
    
    if (currentRingRadius > 0) {
      final paintRing = Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, currentRingRadius, paintRing);
    }
  }
}