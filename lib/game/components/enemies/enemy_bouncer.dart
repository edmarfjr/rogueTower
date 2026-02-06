import 'dart:math';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import '../gameObj/wall.dart';
import '../core/game_icon.dart';

class BouncerEnemy extends Enemy {
  Vector2 _velocity = Vector2.zero();

  // Defina aqui os limites da sua arena (ajuste conforme seu FixedResolutionViewport)
  // Se sua tela é 360 de largura, vai de -180 a +180.
  // Vamos dar uma margem de segurança (padding) para ele não entrar na parede.
  final double limitX = 170; 
  final double limitY = 310; 

  BouncerEnemy({required Vector2 position}) : super(position: position) {
    speed = 120; // Um pouco mais rápido para ser desafiador
    hp = 20;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    originalColor = Pallete.verdeCla;
    // Visual
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());
    add(GameIcon(
      icon: Icons.sports_baseball, 
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2
    ));

    // Direção inicial aleatória
    final rng = Random();
    double angle = rng.nextDouble() * 2 * pi;
    _velocity = Vector2(cos(angle), sin(angle)) * speed;
  }

  @override
  void behavior(double dt) {
    // 1. Aplica o movimento
    position += _velocity * dt;

    // 2. Verifica se bateu nas bordas da tela
    _checkArenaBounds();
  }

  void _checkArenaBounds() {
    // Rebate nas Paredes Laterais (X)
    if (position.x <= -limitX) {
      _velocity.x = _velocity.x.abs(); // Força velocidade positiva (direita)
      position.x = -limitX + 1;        // Desgruda da parede
    } 
    else if (position.x >= limitX) {
      _velocity.x = -_velocity.x.abs(); // Força velocidade negativa (esquerda)
      position.x = limitX - 1;          // Desgruda da parede
    }

    // Rebate nas Paredes Verticais (Y)
    if (position.y <= -limitY) {
      _velocity.y = _velocity.y.abs(); // Força pra baixo
      position.y = -limitY + 1;
    } 
    else if (position.y >= limitY) {
      _velocity.y = -_velocity.y.abs(); // Força pra cima
      position.y = limitY - 1;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // Lógica para Obstáculos Internos (Paredes do Labirinto)
    if (other is Wall) {
      final collisionNormal = (position - other.position).normalized();
      
      if (collisionNormal.x.abs() > collisionNormal.y.abs()) {
        // Colisão Horizontal
        _velocity.x = -_velocity.x;
        position.x += collisionNormal.x.sign * 5; // Empurrãozinho
      } else {
        // Colisão Vertical
        _velocity.y = -_velocity.y;
        position.y += collisionNormal.y.sign * 5; // Empurrãozinho
      }
    }
  }
}