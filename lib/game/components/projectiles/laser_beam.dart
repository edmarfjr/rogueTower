import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; 
import '../effects/explosion.dart';
import '../enemies/enemy.dart';
import '../gameObj/player.dart';
import '../gameObj/wall.dart';
//import '../../audio_manager.dart'; 

class LaserBeam extends PositionComponent with HasGameRef<TowerGame>,CollisionCallbacks {
  final double damage;
  final double length;
  final double angleRad; // Ângulo do tiro
  bool isEnemyProjectile;

  // Configuração de Tempo
  double _timer = 0;
  double chargeTime; // Tempo "mirando" (aviso)
  double fireTime;   // Tempo causando dano
  bool _hasFired = false;

  final PositionComponent? owner;

  LaserBeam({
    required Vector2 position,
    required this.angleRad,
    this.damage = 1,
    this.length = 400,
    this.chargeTime = 1,
    this.fireTime = 0.3,
    this.owner,
    this.isEnemyProjectile = false,
  }) : super(position: position, anchor: Anchor.centerLeft);

  @override
  Future<void> onLoad() async {
    // Aplica a rotação
    angle = angleRad;
    
    // Prioridade alta para desenhar por cima do chão/inimigos
    priority = 10; 
  }

  @override
  void update(double dt) {
    super.update(dt);

     if (owner != null && !owner!.isMounted) {
      removeFromParent(); // O tiro some junto
      return;
    }

    _timer += dt;
    // FASE 1: DISPARAR (Acabou o tempo de carga)
    if (_timer >= chargeTime && !_hasFired) {
      _fire();
    }

    // FASE 2: DESTRUIR (Acabou o tempo de fogo)
    if (_timer >= chargeTime + fireTime) {
      removeFromParent();
    }
  }

  void _fire() {
    _hasFired = true;
    
    // Toca som (se tiver configurado)
    // AudioManager.playSfx('laser.wav'); 
    
    // Adiciona a Hitbox LETAL agora
    // (A hitbox é um retângulo longo e estreito)
    add(RectangleHitbox(
      position: Vector2(0, -10), // Centraliza no Y (se a altura visual for 20)
      size: Vector2(length, 20), 
      isSolid: true,
      collisionType: CollisionType.passive, // O player bate nele
    ));
    
    // Screen Shake leve para impacto
    gameRef.camera.viewfinder.position += Vector2(Random().nextDouble() * 2, Random().nextDouble() * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (!_hasFired) {
      // --- VISUAL DE CARGA (Aviso) ---
      // Linha fina que pisca
      double opacity = (_timer * 10).toInt() % 2 == 0 ? 0.3 : 0.6;
      
      final paintWarning = Paint()
        ..color = Pallete.vermelho.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Desenha linha da origem (0,0) até o alcance (length, 0)
      canvas.drawLine(Offset.zero, Offset(length, 0), paintWarning);

    } else {
      // --- VISUAL DE DISPARO (Laser Real) ---
      
      // 1. Brilho Externo (Glow)
      final paintGlow = Paint()
        ..color = Pallete.vermelho.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); 

      // 2. Núcleo Branco
      final paintCore = Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;

      canvas.drawLine(Offset.zero, Offset(length, 0), paintGlow);
      canvas.drawLine(Offset.zero, Offset(length, 0), paintCore);
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    final hitPos = intersectionPoints.firstOrNull ?? position;
    
    if (isEnemyProjectile) {
      if (other is Player) {
        createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
        other.takeDamage(1); // Jogador toma 1 de dano (1 coração)
        removeFromParent();
      }
    } 
    else {
      if (other is Enemy) {
        createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
        other.takeDamage(damage);
        removeFromParent();
      }
    } 
    
    if (other is ScreenHitbox) {
      createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
      removeFromParent();
    }
    if (other is Wall) {
      other.vida--;
      if (other.vida <=0) other.removeFromParent();
      createExplosion(gameRef.world, hitPos, Pallete.laranja, count: 5);
      removeFromParent(); 
    }
  }
}