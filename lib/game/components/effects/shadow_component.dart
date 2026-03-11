import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ShadowComponent extends PositionComponent {
  ShadowComponent({required Vector2 parentSize}) {
    // A sombra é mais larga que alta (formato oval)
    size = Vector2(parentSize.x * 0.7, parentSize.y * 0.25); 
    
    // Fica ancorada exatamente no meio da base do "Pai" (Jogador/Inimigo/Baú)
    anchor = Anchor.center;
    position = Vector2(parentSize.x / 2, parentSize.y); 
    
    // Priority negativa garante que a sombra fique SEMPRE atrás do personagem
    priority = -500; 
  }

  @override
  void render(Canvas canvas) {
    // Cor preta com 30% de opacidade
    final paint = Paint()..color = Pallete.azulEsc.withOpacity(0.9);
    canvas.drawOval(size.toRect(), paint);
  }
}