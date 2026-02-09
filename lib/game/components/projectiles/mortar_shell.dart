import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import 'explosion.dart'; 

class MortarShell extends PositionComponent with HasGameRef<TowerGame> {
  final Vector2 startPos;
  final Vector2 targetPos;
  final double flightDuration;
  
  double _timeElapsed = 0;
  final double _maxHeight = 150.0;
  // Referência para o visual para podermos girá-lo
  late GameIcon _visualChild; 

  MortarShell({
    required this.startPos,
    required this.targetPos,
    this.flightDuration = 1.2,
  }) : super(position: startPos, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Criamos o visual
    _visualChild = GameIcon(
      icon: Icons.circle, 
      color: Pallete.lilas,
      size: Vector2.all(12),
      anchor: Anchor.center,
      // Importante: posição relativa ao centro do pai
      position: size / 2, 
    );
    
    // Adicionamos como filho
    add(_visualChild);
    priority = 100; 
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeElapsed += dt;

    double progress = _timeElapsed / flightDuration;

    if (progress >= 1.0) {
      _explode();
      return;
    }

    // --- CÁLCULO DA POSIÇÃO (Move o componente PAI) ---
    Vector2 groundPosition = startPos + (targetPos - startPos) * progress;
    double heightOffset = sin(progress * pi) * _maxHeight;

    position.x = groundPosition.x;
    position.y = groundPosition.y - heightOffset;
    
    // --- CÁLCULO DA ROTAÇÃO (Gira apenas o FILHO visual) ---
    // ⚠️ VERIFIQUE SE VOCÊ REMOVEU 'angle += ...' DAQUI ⚠️
    
    // Gira apenas o ícone filho:
    _visualChild.angle += dt * 15; 
  }
  
  void _explode() {
    // Força a explosão no alvo exato
    gameRef.world.add(Explosion(position: targetPos));
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Como o componente pai (MortarShell) não está girando, 
    // o eixo Y aqui aponta sempre para baixo na tela.
    
    double progress = _timeElapsed / flightDuration;
    if (progress > 1) progress = 1;
    
    double currentHeight = sin(progress * pi) * _maxHeight;

    // Desenha a sombra
    canvas.drawOval(
      Rect.fromCenter(
        // size.x/2 e size.y/2 é o centro exato do componente
        // Somamos a altura no Y para desenhar no chão
        center: Offset(size.x/2, size.y/2 + currentHeight), 
        width: 12 - (currentHeight * 0.02), // Sombra diminui um pouco com a altura
        height: 8 - (currentHeight * 0.02)
      ), 
      Paint()..color = Pallete.azulEsc,
    );
    
    super.render(canvas); // Desenha o filho (ícone girando) por cima da sombra
  }
}