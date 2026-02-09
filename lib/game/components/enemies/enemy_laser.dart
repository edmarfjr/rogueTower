import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
//import '../Projectiles/projectile.dart';
import '../core/game_icon.dart';
import 'dart:math';
import '../projectiles/laser_beam.dart';

class LaserEnemy extends Enemy {
  bool _isShooting = false;
  double _shootTimer = Random().nextDouble()*3.0;
  final double shootInterval = 3.0; 

  LaserEnemy({required Vector2 position}) : super(position: position) {
    speed = 0; 
    hp = 40;
  }

  @override
  Future<void> onLoad() async {
    
    await super.onLoad();
    originalColor = Pallete.azulCla;
    // Remove o visual antigo (Rato)
    // Usamos toList() para criar uma cópia da lista e evitar erro de modificação durante iteração
    children.whereType<GameIcon>().toList().forEach((icon) => icon.removeFromParent());
    
    // Adiciona visual novo (Robô)
    add(GameIcon(
      icon: Icons.cell_tower, 
      color: originalColor, 
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
    _shootTimer += dt;

    if (_isShooting) {
      // --- MODO ATIRANDO: FICA PARADO ---
      // O LaserBeam dura 0.9s total (0.6 carga + 0.3 fogo).
      // Vamos esperar 1.2s para garantir e dar uma pausa.
      if (_shootTimer > 1.2) { 
        _isShooting = false;
        _shootTimer = 0; // Reinicia ciclo
      }
      return; // Não anda enquanto atira!
    }

    // --- MODO ANDANDO ---
    // Chama o movimento padrão da classe pai
    behaviorFollowPlayer(dt);

    // Checa se pode atirar
    final dist = position.distanceTo(gameRef.player.position);
    
    // Se passou o tempo E está perto (menos de 350px)
    if (_shootTimer >= shootInterval && dist < 350) {
      _startLaserAttack();
    }
  }

  void _startLaserAttack() {
    _isShooting = true;
    _shootTimer = 0; // Reseta timer para controlar a duração do ataque

    final player = gameRef.player;
    
    // Calcula o ângulo para o player AGORA
    final direction = (player.position - position).normalized();
    final angle = atan2(direction.y, direction.x);

    // Cria o Laser no mundo
    gameRef.world.add(LaserBeam(
      position: position + (direction * 10), // Nasce um pouquinho na frente
      angleRad: angle,
      owner: this,
      isEnemyProjectile: true,
    ));
  }
}