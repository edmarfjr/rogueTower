import 'dart:math';

import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../effects/target_reticle.dart';
import 'enemy.dart';
import '../core/game_icon.dart';
import '../projectiles/mortar_shell.dart';
import '../effects/floating_text.dart';

class MortarEnemy extends Enemy {
  double _cooldown = 4.0; // Atira a cada 4 segundos
  double _timer = Random().nextDouble()*4.0;
  
  // Distância ideal (ele foge se o player chegar muito perto)
  final double _keepDistance = 250.0; 

  MortarEnemy({required Vector2 position}) : super(position: position) {
    hp = 20; 
    speed = 0; // Lento
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Visual
    originalColor = Pallete.rosa;
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());
    add(GameIcon(
      icon: Icons.architecture, // Parece uma torre/catapulta
      color: originalColor,
      size: size,
    ));
  }

  @override
  void behavior(double dt) {
    _timer += dt;
    final player = gameRef.player;
    final dist = position.distanceTo(player.position);

    // 1. IA DE MOVIMENTO (Tenta manter distância)
    if (dist < _keepDistance) {
      // Foge do player
      final dir = (position - player.position).normalized();
      position += dir * speed * dt;
    } else if (dist > _keepDistance + 100) {
      // Se aproxima se estiver muito longe
      final dir = (player.position - position).normalized();
      position += dir * speed * dt;
    }
    // Se estiver na distância ideal, fica parado.

    // 2. IA DE TIRO
    if (_timer >= _cooldown && dist < 600) {
      _fireMortar();
      _timer = 0;
    }
  }

  void _fireMortar() {
    // Trava a posição ONDE O PLAYER ESTÁ AGORA
    final target = gameRef.player.position.clone();
    double flightTime = 1.5;
    // Adiciona uma imprecisão para não ser impossível (opcional)
    // target.x += (Random().nextDouble() - 0.5) * 40;
    // target.y += (Random().nextDouble() - 0.5) * 40;
      
    //gameRef.world.add(FloatingText(text: "Target Locked!", position: position + Vector2(0,-20), color: Colors.red));
    gameRef.world.add(TargetReticle(
      position: target,
      duration: flightTime, // Dura exatamente o mesmo tempo do voo
      radius: 30,           // Mesmo raio da Explosão.dart
    ));
    gameRef.world.add(MortarShell(
      startPos: position.clone(),
      targetPos: target,
      flightDuration: flightTime, // 1.5 segundos para a bomba cair
    ));
  }
}