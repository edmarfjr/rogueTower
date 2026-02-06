import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart'; 
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../effects/floating_text.dart';
//import '../effects/explosion.dart'; // Certifique-se que existe ou remova se não usar

class Enemy extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  double hp = 30;
  double speed = 80;
  bool rotaciona = false;
  int soul = 1;
  
  // --- CONTROLE DE DANO VISUAL ---
  bool _isHit = false;
  double _hitTimer = 0;
  late Color originalColor; // <--- 1. Variável para lembrar a cor original
  // -------------------------------

  // Variáveis de Animação
  double _animTimer = 0;
  final double _animSpeed = 12.0;       
  final double _animAmplitude = 0.1;    
  Vector2 _lastPosition = Vector2.zero(); 

  Enemy({required Vector2 position}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Define a cor padrão deste inimigo
    // (Filhos podem sobrescrever isso se setarem a cor antes ou no seu próprio onLoad)
    originalColor = Pallete.vermelho; 

    add(GameIcon(
      icon: Icons.pest_control_rodent,
      color: originalColor, // <--- Usa a variável
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    ));

    add(RectangleHitbox(
      size: size * 0.8, 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));
    _lastPosition = position.clone();
  }

  @override
  void update(double dt) {
    super.update(dt);
    behavior(dt);
    _animateEnemy(dt);
    _lastPosition.setFrom(position);
    
    // Chama o controle do efeito visual a cada frame
    handleHitEffect(dt);
  }

  // ... (behavior e behaviorFollowPlayer mantidos iguais) ...
  void behavior(double dt) { behaviorFollowPlayer(dt); }
  void behaviorFollowPlayer(double dt) {
     final player = gameRef.player;
     final direction = (player.position - position).normalized();
     if(rotaciona){
       final visual = children.whereType<GameIcon>().firstOrNull;
       if (visual != null) visual.angle = atan2(direction.y, direction.x) + (pi / 2);
     }
     position += direction * speed * dt;
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      final separation = (position - other.position).normalized();
      position += separation * 2.0; 
    } else if (other is Enemy) {
      final separation = (position - other.position).normalized();
      position += separation * 1.0; 
    }
  }

  // --- LÓGICA DE DANO ATUALIZADA ---
  void takeDamage(double damage) {
    if (hp <= 0) return;
    hp -= damage;
    
    // 2. ATIVA O FLASH BRANCO
    if (!_isHit) { // Só aplica se já não estiver piscando (evita travar no branco)
        _isHit = true; 
        _hitTimer = 0.1; // Pisca por 100ms
        
        // Pinta de Branco
        children.whereType<GameIcon>().firstOrNull?.setColor(Colors.white);
    }

    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position.clone() + Vector2(0, -10), 
      color: Colors.white, 
      fontSize: 14,
    ));

    if (hp <= 0) {
      // Efeito de Morte
      // createExplosion(...); 
      
      gameRef.progress.addSouls(soul);
      
      removeFromParent();
    }
  }

  // --- RESTAURAÇÃO DA COR ---
  void handleHitEffect(double dt) {
    if (_isHit) {
      _hitTimer -= dt;
      
      if (_hitTimer <= 0) {
        _isHit = false;
        // 3. VOLTA PARA A COR ORIGINAL
        children.whereType<GameIcon>().firstOrNull?.setColor(originalColor);
      }
    }
  }

  // ... (_animateEnemy mantido igual) ...
  void _animateEnemy(double dt) {
    // (Sua lógica de animação corrigida anteriormente continua aqui...)
    final visual = children.whereType<GameIcon>().firstOrNull;
    if (visual == null) return;
    
    final player = gameRef.player;
    double facing = 1.0;
    if (!rotaciona) {
        if (player.position.x < position.x) facing = -1.0; 
        else facing = 1.0;
    }

    double displacement = position.distanceTo(_lastPosition);
    if (displacement > 0.1) {
      _animTimer += dt * _animSpeed;
      double wave = sin(_animTimer);
      double scaleY = 1.0 + (wave * _animAmplitude); 
      double scaleX = 1.0 - (wave * _animAmplitude * 0.5);
      visual.scale = Vector2(facing * scaleX, scaleY);
    } else {
      _animTimer = 0;
      visual.scale = Vector2(facing, 1.0);
    }
  }
}