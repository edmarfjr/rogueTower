import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/material.dart';

class GameIcon extends PositionComponent {
  final IconData icon;
  Color color;

  GameIcon({
    required this.icon,
    required this.color,
    required Vector2 size,
    Vector2? scale, // Agora é opcional (sem o 'required')
    Anchor anchor = Anchor.center,
    Vector2? position,
  }) : super(
          size: size,
          anchor: anchor,
          position: position,
        ) {
    // Se um scale foi passado no construtor, aplica ele
    if (scale != null) {
      this.scale.setFrom(scale);
    }
  } // Inicializa a variável privada

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  // --- MÉTODO NOVO: Necessário para o Boss piscar ao tomar dano ---
  void setColor(Color newColor) {
    color = newColor;
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
        color: color, // Mudança 2: Usa a cor mutável
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