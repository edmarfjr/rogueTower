import 'package:flame/components.dart';
import 'package:flame/src/game/notifying_vector2.dart';
import 'package:flutter/material.dart';

class GameIcon extends PositionComponent {
  final IconData icon;
  Color color;

  GameIcon({
    required this.icon,
    required this.color,
    required Vector2 super.size,
    Vector2? scale, 
    Anchor super.anchor = Anchor.center,
    super.position,
  }) {
    if (scale != null) {
      this.scale.setFrom(scale);
    }
  } 

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    textAlign: TextAlign.center,
  );

  void setColor(Color newColor) {
    color = newColor;
    _updatePainter(); 
  }

  @override
  Future<void> onLoad() async {
    _updatePainter();
  }

  void _updatePainter() {
    _textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        color: color,
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
    if (_textPainter.width == 0) {
      _updatePainter();
    }

    final offset = Offset(
      (size.x - _textPainter.width) / 2,
      (size.y - _textPainter.height) / 2,
    );
    
    _textPainter.paint(canvas, offset);
  }
  
}