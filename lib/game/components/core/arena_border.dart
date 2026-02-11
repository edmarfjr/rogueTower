import 'package:TowerRogue/game/tower_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'pallete.dart';

class ArenaBorder extends PositionComponent with HasGameRef<TowerGame> {
  final double wallThickness;
  final double radius;

  ArenaBorder({
    required Vector2 size,
    this.wallThickness = 10.0,
    this.radius = 220.0,
  }) : super(
          size: size,
          anchor: Anchor.center,
          position: Vector2.zero(), // Assume que o mundo é centralizado no 0,0
        );

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Pallete.marrom;      
      case 2: return Pallete.cinzaEsc; 
      default: return Colors.white;
    }
  }      

  @override
  void render(Canvas canvas) {
    int currLevel = gameRef.currentLevelNotifier.value;
    // Define a cor e o estilo da borda
    final paint = Paint()
      ..color = _getLevelColor(currLevel)
      ..style = PaintingStyle.stroke // Apenas o contorno
      ..strokeWidth = wallThickness;

    // Cria o retângulo arredondado (RRect)
    // Ajustamos o rect para considerar a grossura da borda, para ela crescer "para fora" ou alinhar corretamente
    final rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    canvas.drawRRect(rrect, paint);
  }
}