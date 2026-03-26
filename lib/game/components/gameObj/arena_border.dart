import 'package:towerrogue/game/tower_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart';

class ArenaBorder extends PositionComponent with HasGameRef<TowerGame> {
  final double wallThickness;
  final double radius;

  // 1. CACHE DA TINTA: Criada apenas uma vez na vida útil do objeto
  final Paint _borderPaint = Paint()..style = PaintingStyle.stroke;

  // 2. CACHE DAS FORMAS: Calculadas apenas uma vez
  late final Rect _rect;
  late final RRect _rRect;

  // Variável de controle para não atualizar a cor à toa
  int _lastLevel = -1;

  ArenaBorder({
    required Vector2 size,
    this.wallThickness = 10.0,
    this.radius = 220.0,
  }) : super(
          size: size,
          anchor: Anchor.center,
          position: Vector2.zero(), 
          priority: -10000,
        ) {
    // Configura a espessura da linha
    _borderPaint.strokeWidth = wallThickness;

    // Pré-calcula a matemática geométrica na hora que a arena é criada
    _rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );
    
    _rRect = RRect.fromRectAndRadius(_rect, Radius.circular(radius));
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Pallete.marrom;      
      case 2: return Pallete.cinzaEsc; 
      case 3: return Pallete.azulEsc; 
      case 4: return Pallete.verdeEsc; 
      case 5: return Pallete.azulCla; 
      default: return Pallete.azulEsc;
    }
  }  
  

  @override
  void update(double dt) {
    super.update(dt);
    
    // 3. ATUALIZAÇÃO CONDICIONAL: 
    // Muda a cor da tinta apenas se o nível tiver mudado, sem recriar o Paint()
    final int currLevel = gameRef.currentLevelNotifier.value;
    if (currLevel != _lastLevel) {
      _lastLevel = currLevel;
      _borderPaint.color = _getLevelColor(currLevel);
    }
  }

  @override
  void render(Canvas canvas) {
    // 4. RENDERIZAÇÃO LIMPA: 
    // Agora o render só faz o que ele deve fazer: desenhar! (Zero alocação de memória)
    canvas.drawRRect(_rRect, _borderPaint);
  }
}