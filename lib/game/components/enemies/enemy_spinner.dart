import 'dart:math';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import '../gameObj/wall.dart';
import '../projectiles/projectile.dart';
import '../core/game_icon.dart';

class SpinnerEnemy extends Enemy {
  // Movimento Aleatório
  Vector2 _moveTarget = Vector2.zero();
  //double _moveTimer = 0;
  
  // Tiro
  double _shootTimer = Random().nextDouble() * 3;
  final double shootInterval = 1.5;

  SpinnerEnemy({required Vector2 position}) : super(position: position) {
    speed = 50;
    hp = 25;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    originalColor = Pallete.rosa;
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());

    // Visual: Algo que remete a girar
    add(GameIcon(
      icon: Icons.sync, // Ou Icons.cyclone
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2
    ));
    
    _pickNewTarget();
  }

  void _pickNewTarget() {
    // Escolhe um ponto aleatório próximo dentro da arena
    final rng = Random();
    double x = (rng.nextDouble() * 300) - 150; // Ajuste conforme tamanho da arena
    double y = (rng.nextDouble() * 400) - 200;
    _moveTarget = Vector2(x, y);
  }

  @override
  void behavior(double dt) {
    // 1. MOVIMENTO ALEATÓRIO
    // Move em direção ao alvo atual
    final direction = (_moveTarget - position).normalized();
    final distance = position.distanceTo(_moveTarget);

    if (distance < 10) {
      // Chegou! Escolhe novo alvo
      _pickNewTarget();
    } else {
      position += direction * speed * dt;
    }
    
    // Se bater na parede, escolhe novo alvo (tratado no onCollision, mas aqui garante fluxo)

    // 2. ATIRAR EM 4 DIREÇÕES
    _shootTimer -= dt;
    if (_shootTimer <= 0) {
      _shootCross();
      _shootTimer = shootInterval;
      
      // Efeito visual de girar
      final visual = children.whereType<GameIcon>().firstOrNull;
      visual?.angle += pi / 4; 
    }
  }

  void _shootCross() {
    if (gameRef.isRemoved) return;
    
    // Norte, Sul, Leste, Oeste
    final directions = [
      Vector2(0, -1),
      Vector2(0, 1),
      Vector2(-1, 0),
      Vector2(1, 0),
    ];

    for (var dir in directions) {
      gameRef.world.add(Projectile(
        position: position + dir * 20,
        direction: dir,
        damage: 1,
        speed: 200,
        owner: this,
        isEnemyProjectile: true,
      ));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      // Se bateu na parede, muda de ideia imediatamente
      _pickNewTarget();
    }
  }
}