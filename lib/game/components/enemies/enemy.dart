import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart'; // Para acessar o player via gameRef
import '../game_icon.dart';
import '../pallete.dart';
import '../gameObj/wall.dart';
import '../floating_text.dart';
import '../effects/explosion.dart';

class Enemy extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  double hp = 30;
  double speed = 80;
  bool rotaciona = false;
  
  // Controle de dano visual
  bool _isHit = false;
  double _hitTimer = 0;

  Enemy({required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: Icons.pest_control_rodent,
      color: Pallete.vermelho,
      size: size,
      anchor: Anchor.center,
      position: size / 2, // <--- O segredo está aqui
    ));

    add(RectangleHitbox(
      size: size * 0.8, // Opcional: hitbox um pouco menor
      anchor: Anchor.center,
      position: size / 2, // <--- E aqui
      isSolid: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    behavior(dt);
    handleHitEffect(dt);

    // --- NOVA LÓGICA DE FLIP ---
    final player = gameRef.player;
    final visual = children.whereType<GameIcon>().first;

    // Se o player está à esquerda (x menor), flipa para esquerda (-1)
    if (player.position.x < position.x) {
      visual.scale = Vector2(-1, 1);
    } else {
      visual.scale = Vector2(1, 1);
    }
    // ---------------------------
  }

  void behavior(double dt) {
    behaviorFollowPlayer(dt);
  }

  void behaviorFollowPlayer(double dt) {
    // Acessa a posição do jogador através do gameRef
    final player = gameRef.player;
    
    // Calcula vetor direção até o player
    final direction = (player.position - position).normalized();

    if(rotaciona){final visual = children.whereType<GameIcon>().firstOrNull;
      if (visual != null) 
      {
        visual.angle = atan2(direction.y, direction.x) + (pi / 2);
      }
    }
    
    
    // Move
    position += direction * speed * dt;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    if (other is Wall) {
      // 1. Colisão com Parede (Empurra para fora)
      final separation = (position - other.position).normalized();
      position += separation * 2.0; 
    } 
    else if (other is Enemy) {
      // 2. Colisão com outro Inimigo (Empurra suavemente para não sobrepor)
      // Isso cria o efeito de "boids" ou multidão, evitando que fiquem todos no mesmo pixel
      final separation = (position - other.position).normalized();
      
      // Empurrão menor (1.0) para ser suave, senão eles ficam tremendo
      position += separation * 1.0; 
    }
  }

  void takeDamage(double damage) {
    if (hp <= 0) return;
    hp -= damage;
    _isHit = true; // Ativa efeito de "piscar"
    _hitTimer = 0.1; // Tempo que fica branco

    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position.clone() + Vector2(0, -10), // Aparece um pouco acima da cabeça
      color: Colors.white, // Ou amarelo para Crítico
      fontSize: 14,
    ));

    if (hp <= 0) {
      createExplosion(gameRef.world, position, Pallete.vermelho, count: 15);
      removeFromParent();
      // Aqui você poderia dropar moedas ou tocar som de morte
    }
  }

  void handleHitEffect(double dt) {
    if (_isHit) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        _isHit = false;
        // Retorna a cor normal (se estivéssemos usando TintEffect seria mais elegante, 
        // mas para MVP, o flash é sutil ou pode ser ignorado por enquanto)
      }
    }
  }
}