import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class UnlockNotification extends PositionComponent {
  final String message;
  double _timer = 0;
  final double _lifespan = 3.5; // O texto fica na tela por 3.5 segundos

  late TextPaint _textPaint;

  UnlockNotification({
    required this.message,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center) {
    // Prioridade altíssima para garantir que o texto apareça na frente 
    // dos inimigos, tiros, poças e paredes.
    priority = 100; 
  }

  @override
  Future<void> onLoad() async {
    // Define o estilo do texto (Dourado, Grande e com Sombra)
    _textPaint = TextPaint(
      style: const TextStyle(
        color: Pallete.laranja, // Cor de "Item Épico"
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2)),
          Shadow(color: Colors.black87, blurRadius: 2, offset: Offset(-1, -1)),
        ],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Faz o texto flutuar para cima constantemente (15 pixels por segundo)
    position.y -= 15 * dt;

    if (_timer >= _lifespan) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    // 1. Calcula a opacidade: 
    // Fica 100% visível, e no último 1.5 segundo começa a sumir (fade out)
    double currentOpacity = 1.0;
    if (_timer > _lifespan - 1.5) {
      currentOpacity = (_lifespan - _timer) / 1.5;
      currentOpacity = currentOpacity.clamp(0.0, 1.0);
    }

    // 2. Aplica a opacidade na cor e desenha
    final paintWithOpacity = _textPaint.copyWith(
      (style) => style.copyWith(
        color: style.color?.withOpacity(currentOpacity),
      ),
    );

    // 3. Desenha no centro do componente
    paintWithOpacity.render(
      canvas,
      message,
      Vector2.zero(),
      anchor: Anchor.center,
    );
  }
}