import 'dart:math';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/game_icon.dart';
import '../enemies/enemy.dart'; 
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../../tower_game.dart';
import '../gameObj/player.dart';
import '../effects/explosion.dart'; // Certifique-se que sua explosão visual está aqui

class Projectile extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  // --- PROPRIEDADES ORIGINAIS ---
  Vector2 direction; // Removi o 'final' para permitir reflexão (bounce)
  final double speed; 
  final double damage;
  final bool isEnemyProjectile;
  final bool apagaTiros;
  final PositionComponent? owner;
  
  double _timer = 0.0;
  final double dieTimer;

  // --- NOVOS COMPORTAMENTOS OPCIONAIS ---
  
  // 1. REBATER (BOUNCE)
  final bool canBounce;
  final int maxBounces;
  int _bounceCount = 0;

  // 2. EXPLODIR (AREA DAMAGE)
  final bool explodes;
  final double explosionRadius;

  // 3. DIVIDIR (CLUSTER/SPLIT)
  final bool splits;
  final int splitCount;

  // Flag para evitar loop de morte (ex: explodir duas vezes no mesmo frame)
  bool _isDead = false;

  Projectile({
    required Vector2 position, 
    required this.direction,
    this.damage = 10,
    this.speed = 300,
    this.owner,
    this.isEnemyProjectile = false,
    this.apagaTiros = false,
    this.dieTimer = 3.0,
    Vector2? size,
    // Novos Parâmetros (com valores padrão 'desligados')
    this.canBounce = false,
    this.maxBounces = 2,
    this.explodes = false,
    this.explosionRadius = 60.0,
    this.splits = false,
    this.splitCount = 3,
  }): super(position: position, size: size ?? Vector2.all(10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Adiciona o Ícone
    add(GameIcon(
      icon: explodes ? Icons.brightness_high : Icons.circle, // Ícone diferente se for explosivo
      color: isEnemyProjectile ? Pallete.vermelho : Pallete.amarelo,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
    
    // Hitbox um pouco menor que o sprite
    add(CircleHitbox(
      radius: size.x / 2.5,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true, 
    ));

    _updateRotation();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isDead) return;

    // Removemos a verificação "owner.isMounted" para que a bala não suma 
    // se o atirador morrer antes dela acertar o alvo.
    
    // Movimento
    position += direction * speed * dt;

    // Visual (Piscar)
    final visual = children.whereType<GameIcon>().firstOrNull;
    _timer += dt;
    
    // Pisca mais rápido se estiver perto de expirar
    double flashSpeed = (_timer > dieTimer - 1) ? 0.1 : 0.2;
    
    if (_timer % flashSpeed < (flashSpeed / 2)){ 
      visual?.setColor(Pallete.amarelo);
    } else {
      isEnemyProjectile ? visual?.setColor(Pallete.vermelho) : visual?.setColor(Pallete.azulCla);
    }

    // Tempo de vida acabou
    if (_timer >= dieTimer){
      kill(triggerEffects: true); // Explode se morrer por tempo? (Opcional: true/false)
    }
    
    // Longe demais
    if (position.length > 3000) removeFromParent();
  }

  // --- MÉTODO CENTRAL DE MORTE ---
  void kill({bool triggerEffects = true}) {
    if (_isDead) return;
    _isDead = true;

    if (triggerEffects) {
      if (explodes) gameRef.world.add(Explosion(position: position, damagesPlayer:isEnemyProjectile, damage:damage));
      if (splits) _doSplit();
    }
    
    // Efeito visual padrão de impacto (fagulhas)
    createExplosion(gameRef.world, position, Pallete.laranja, count: 5);
    
    removeFromParent();
  }
  // --- LÓGICA DE CLUSTER (SPLIT) ---
  void _doSplit() {
    for (int i = 0; i < splitCount; i++) {
      // Cria vetores em ângulos aleatórios ou fixos
      double angle = (2 * pi / splitCount) * i; // Distribui em círculo
      Vector2 newDir = Vector2(cos(angle), sin(angle));
      
      gameRef.world.add(Projectile(
        position: position,
        direction: newDir,
        speed: speed * 0.8, // Fragmentos mais lentos
        damage: damage / 2, // Fragmentos mais fracos
        isEnemyProjectile: isEnemyProjectile,
        owner: owner,
        dieTimer: 1.0, // Vida curta
        size: size / 1.5, // Menores
        // Importante: Fragmentos não devem se dividir ou explodir de novo para evitar crash
        canBounce: false,
        explodes: false, 
        splits: false, 
      ));
    }
  }

  // --- COLISÃO ---
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isDead) return;

    final hitPos = intersectionPoints.firstOrNull ?? position;

    // 1. COLISÃO COM PAREDES (Rebater ou Morrer)
    if (other is Wall || other is ScreenHitbox) {
      
      // Se pode rebater e ainda tem "vidas" de rebote
      if (canBounce && _bounceCount < maxBounces) {
        _handleBounce(other, hitPos);
        if (other is Wall) other.vida--; // Opcional: Rebater também danifica a parede
        return; // <--- NÃO MORRE, RETORNA
      } 
      
      // Se não rebater:
      if (other is Wall) {
        other.vida--;
        if (other.vida <= 0) other.removeFromParent();
      }
      kill(); // Morre (explode/split)
      return;
    }

    // 2. COLISÃO COM INIMIGOS / PLAYER
    if (isEnemyProjectile) {
      if (other is Player) {
        other.takeDamage(1);
        kill(); 
      }
    } else {
      if (other is Enemy && !other.isInvencivel) {
        other.takeDamage(damage);
        kill();
      }
      if (apagaTiros && other is Projectile && !other.isEnemyProjectile) {
        other.removeFromParent();
        kill();
      }
    }
  }

  void _handleBounce(PositionComponent obstacle, Vector2 hitPos) {
    _bounceCount++;

    // Lógica simples de reflexão Arcade (Inverter Eixo)
    // Calcula vetor normal baseado na posição relativa entre o centro da bala e o centro da parede
    Vector2 relativePos = position - obstacle.position;
    
    // Se a distância X for maior, batemos nas laterais (esquerda/direita) -> Inverte X
    // Se a distância Y for maior, batemos no topo/baixo -> Inverte Y
    if (relativePos.x.abs() > relativePos.y.abs()) {
      direction.x = -direction.x;
    } else {
      direction.y = -direction.y;
    }

    // Afasta um pouco o projétil da parede para não grudar (tunneling)
    position += direction * 5;
    
    // Atualiza o ângulo visual
    _updateRotation();
  }

  void _updateRotation() {
    angle = atan2(direction.y, direction.x) + 1.54; // Ajuste do seu sprite
  }
}