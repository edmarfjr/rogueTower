import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../pallete.dart';
import 'enemy.dart';
import '../wall.dart';
import '../game_icon.dart';

enum DasherState { aiming, dashing, recovering }

class DasherEnemy extends Enemy {
  DasherState _state = DasherState.aiming;
  Vector2 _dashDirection = Vector2.zero();
  double _timer = 0;
  
  final double aimDuration = 1.0;     
  final double recoverDuration = 1.0; 
  final double dashSpeed = 350;       

  // LIMITES DA ARENA (Mesmos do Bouncer)
  final double limitX = 170; 
  final double limitY = 310; 

  DasherEnemy({required Vector2 position}) : super(position: position) {
    hp = 40; 
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());
    
    add(GameIcon(
      icon: Icons.navigation, 
      color: Pallete.laranja,
      size: size,
      anchor: Anchor.center,
      position: size / 2
    ));
  }

  @override
  void behavior(double dt) {
    final visual = children.whereType<GameIcon>().firstOrNull;

    switch (_state) {
      case DasherState.aiming:
        // MIRA (Igual antes)
        final player = gameRef.player;
        _dashDirection = (player.position - position).normalized();
        
        // Rotaciona visualmente (opcional, ajustando ângulo)
        if (visual != null) {
          // --- ROTAÇÃO ---
          // atan2(y, x) calcula o ângulo baseado no vetor.
          // Somamos (pi / 2) porque o ícone Icons.navigation aponta para CIMA,
          // mas o ângulo 0 matemático aponta para a DIREITA.
          visual.angle = atan2(_dashDirection.y, _dashDirection.x) + (pi / 2);
        }

        _timer += dt;
        if (_timer >= aimDuration) {
          _state = DasherState.dashing;
          if (visual != null) visual.setColor(Pallete.vermelho);
        }
        break;

      case DasherState.dashing:
        // MOVIMENTO
        position += _dashDirection * dashSpeed * dt;

        if (visual != null) {
           visual.angle = atan2(_dashDirection.y, _dashDirection.x) + (pi / 2);
        }
        // --- NOVO: CHECAGEM DE BORDAS ---
        if (_checkArenaCollision()) {
          _hitWall(); // Bateu na borda! Para tudo.
        }
        break;

      case DasherState.recovering:
        _timer += dt;
        if (_timer >= recoverDuration) {
          _state = DasherState.aiming;
          _timer = 0;
          if (visual != null) visual.setColor(Pallete.amarelo);
        }
        break;
    }
  }

  // Função auxiliar que retorna TRUE se bateu na borda
  bool _checkArenaCollision() {
    bool hit = false;

    // Borda Esquerda
    if (position.x <= -limitX) {
      position.x = -limitX + 1; // Empurra pra dentro
      hit = true;
    } 
    // Borda Direita
    else if (position.x >= limitX) {
      position.x = limitX - 1;
      hit = true;
    }

    // Borda Cima
    if (position.y <= -limitY) {
      position.y = -limitY + 1;
      hit = true;
    } 
    // Borda Baixo
    else if (position.y >= limitY) {
      position.y = limitY - 1;
      hit = true;
    }

    return hit;
  }

  // Lógica unificada de "Bater na Parede"
  void _hitWall() {
    if (_state == DasherState.dashing) {
      _state = DasherState.recovering;
      _timer = 0;
      
      // Empurra um pouco para trás da direção que veio (efeito de impacto)
      position -= _dashDirection * 10;
      
      // Opcional: Efeito visual ou som de "BONK!"
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // Colisão com Paredes INTERNAS (Obstáculos)
    if (other is Wall) {
      _hitWall();
    } 
    else {
      super.onCollision(intersectionPoints, other);
    }
  }
}