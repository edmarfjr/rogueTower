import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; 
//import '../../audio_manager.dart'; 

class PathEffect extends PositionComponent with HasGameRef<TowerGame>,CollisionCallbacks {

  final double length;
  final double angleRad; // Ângulo do tiro


  // Configuração de Tempo
  double _timer = 0;
  double duration;
  final PositionComponent? owner;

  PathEffect({
    required Vector2 position,
    required this.angleRad,
    this.length = 400,
    this.duration = 1,
    this.owner,
  }) : super(position: position, anchor: Anchor.centerLeft);

  @override
  Future<void> onLoad() async {
    // Aplica a rotação
    angle = angleRad;
    
    // Prioridade alta para desenhar por cima do chão/inimigos
    priority = 10; 
  }

  @override
  void update(double dt) {
    super.update(dt);

     if (owner != null && !owner!.isMounted) {
      removeFromParent(); // O tiro some junto
      return;
    }

    _timer += dt;

    // FASE 2: DESTRUIR (Acabou o tempo de fogo)
    if (_timer >= duration) {
      removeFromParent();
    }
  }


  @override
  void render(Canvas canvas) {
    super.render(canvas);

      
      final paintWarning = Paint()
        ..color = Pallete.vermelho.withValues(alpha:0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12;

      // Desenha linha da origem (0,0) até o alcance (length, 0)
      canvas.drawLine(Offset.zero, Offset(length, 0), paintWarning);
  }

}