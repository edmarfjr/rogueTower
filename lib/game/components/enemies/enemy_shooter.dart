import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import '../gameObj/projectile.dart';
import '../game_icon.dart';

class ShooterEnemy extends Enemy {
  double _shootTimer = 0;
  final double shootInterval = 2.0; 

  ShooterEnemy({required Vector2 position}) : super(position: position) {
    speed = 50; 
    hp = 20;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Remove o visual antigo (Rato)
    // Usamos toList() para criar uma cópia da lista e evitar erro de modificação durante iteração
    children.whereType<GameIcon>().toList().forEach((icon) => icon.removeFromParent());
    
    // Adiciona visual novo (Robô)
    add(GameIcon(
      icon: Icons.adb, 
      color: Colors.purple, 
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  // --- CORREÇÃO PRINCIPAL AQUI ---
  
  // Em vez de mexer no update(), nós sobrescrevemos o "cérebro" do inimigo (behavior).
  // O super.update() do Enemy já chama o behavior(). 
  // Ao sobrescrevermos aqui, impedimos que a lógica de "seguir player" do pai seja executada.
  @override
  void behavior(double dt) {
    _behaviorShooter(dt);
  }

  // Lógica específica do Atirador
  void _behaviorShooter(double dt) {
    final player = gameRef.player;
    final distance = position.distanceTo(player.position);
    final direction = (player.position - position).normalized();

    // 1. MOVIMENTO (IA de Manter Distância)
    if (distance > 220) {
      // Longe demais: Aproxima
      position += direction * speed * dt;
    } else if (distance < 150) {
      // Perto demais: Foge (Kiting)
      position -= direction * (speed * 0.8) * dt;
    }
    // Se estiver entre 150 e 220, ele fica parado mirando.

    // 2. ATAQUE
    _shootTimer -= dt;
    if (_shootTimer <= 0) {
      _shoot(direction);
      _shootTimer = shootInterval;
    }
  }

  void _shoot(Vector2 direction) {
    // Verifica se o jogo ainda está ativo antes de adicionar
    if (gameRef.isRemoved) return;

    gameRef.world.add(Projectile(
      position: position + direction * 20, 
      direction: direction,
      damage: 1, 
      isEnemyProjectile: true, 
    ));
  }
}