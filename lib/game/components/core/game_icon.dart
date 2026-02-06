import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameIcon extends PositionComponent {
  final IconData icon;
  
  // Mudança 1: Tornamos a cor privada e mutável (sem 'final')
  Color _color; 

  GameIcon({
    required this.icon,
    required Color color, // Recebe a cor inicial
    super.size,
    super.position,
    super.anchor = Anchor.center,
  }) : _color = color; // Inicializa a variável privada

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  // --- MÉTODO NOVO: Necessário para o Boss piscar ao tomar dano ---
  void setColor(Color newColor) {
    _color = newColor;
    _updatePainter(); // Força o redesenho com a nova cor
  }

  @override
  Future<void> onLoad() async {
    _updatePainter();
  }

  void _updatePainter() {
    _textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: _color, // Mudança 2: Usa a cor mutável
        fontSize: size.x, 
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        height: 1.0, 
      ),
    );
    _textPainter.layout();
  }

  @override
  void render(Canvas canvas) {
    // Segurança extra
    if (_textPainter.width == 0) {
      _updatePainter();
    }

    // SUA LÓGICA DE ALINHAMENTO (MANTIDA)
    // Isso garante que o ícone fique centralizado na Hitbox
    final offset = Offset(
      (size.x - _textPainter.width) / 2,
      (size.y - _textPainter.height) / 2,
    );
    
    _textPainter.paint(canvas, offset);
  }
}