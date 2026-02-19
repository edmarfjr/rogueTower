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
import '../effects/explosion_effect.dart';

class Projectile extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  // --- PROPRIEDADES ORIGINAIS ---
  Vector2 direction; 
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

  // 4. ORBITAL
  final bool isOrbital;
  double _currentAngle = 0; 
  final double orbitalRadius;

  // 5. TELEGUIDADO (HOMING)
  final bool isHoming;
  final double homingTurnSpeed; // Quão rápido ele consegue fazer a curva (ex: 3.0)
  PositionComponent? _homingTarget; // O alvo atual travado
  final Vector2 _desiredDirection = Vector2.zero(); // Vetor sem lixo de memória

  // 6. PERFURANTE (PIERCING)
  final bool isPiercing;
  // A "Hit List": guarda quem essa bala já machucou para não dar dano duplo
  final Set<PositionComponent> _hitTargets = {};

  GameIcon? visual;
  double visualAngle = 0;

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
    // Novos Parâmetros
    this.canBounce = false,
    this.maxBounces = 2,
    this.explodes = false,
    this.explosionRadius = 60.0,
    this.splits = false,
    this.splitCount = 3,
    this.isOrbital = false,
    this.orbitalRadius = 50.0,
    this.isHoming = false,
    this.homingTurnSpeed = 4.0, // 4.0 é uma curva ágil, 1.0 é um míssil pesado
    this.isPiercing = false,
  }): super(position: position, size: size ?? Vector2.all(10), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    IconData icon = Icons.circle;
    if (explodes) {
      icon = Icons.brightness_high;
    } else if (isHoming) {
      icon = Icons.rocket_launch;
      visualAngle = -pi / 4; 
    } else {
      icon = Icons.circle;
    }

    visual = GameIcon(
      icon: icon, 
      color: isEnemyProjectile ? Pallete.vermelho : Pallete.amarelo,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(visual!);
    
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

    if (owner != null && !owner!.isMounted) {
      removeFromParent(); 
      return;
    }
    
    // --- LÓGICA HOMING (TELEGUIDADO) ---
    if (isHoming && !isOrbital) {
      _updateHomingTarget();
      
      if (_homingTarget != null && _homingTarget!.isMounted) {
        // 1. Descobre para onde o alvo está
        _desiredDirection.setFrom(_homingTarget!.position);
        _desiredDirection.sub(position);
        _desiredDirection.normalize();

        // 2. Faz a curva suavemente na direção do alvo (Matemática In-Place sem gerar lixo)
        direction.x += (_desiredDirection.x - direction.x) * (dt * homingTurnSpeed);
        direction.y += (_desiredDirection.y - direction.y) * (dt * homingTurnSpeed);
        direction.normalize();

        // Atualiza a rotação do sprite para ele "olhar" para onde está virando
        _updateRotation();
      }
    }

    // --- MOVIMENTO ---
    if (isOrbital) {
      _currentAngle += speed * dt;
      final double centerX = owner!.position.x ;
      final double centerY = owner!.position.y ;

      final newX = centerX + cos(_currentAngle) * orbitalRadius;
      final newY = centerY + sin(_currentAngle) * orbitalRadius;
    
      position.setValues(newX, newY);
    } else {
      position.addScaled(direction, speed * dt);
    }

    // --- VISUAL (PISCAR) ---
    _timer += dt;
    double flashSpeed = (_timer > dieTimer - 1) ? 0.1 : 0.2;
    
    if (_timer % flashSpeed < (flashSpeed / 2)){ 
      visual?.setColor(Pallete.amarelo);
    } else {
      isEnemyProjectile ? visual?.setColor(Pallete.vermelho) : visual?.setColor(Pallete.azulCla);
    }

    if (_timer >= dieTimer){
      kill(triggerEffects: true); 
    }
    
    if (position.length > 3000) removeFromParent();
  }

  // --- BUSCA O ALVO DO HOMING ---
  void _updateHomingTarget() {
    if (_homingTarget != null && _homingTarget!.isMounted) return;

    if (isEnemyProjectile) {
      _homingTarget = gameRef.player;
    } else {
      final enemies = gameRef.world.children.query<Enemy>();
      double closestDist = double.infinity;
      Enemy? bestTarget;

      for (final enemy in enemies) {
        // Ignora inimigos que a bala já atravessou!
        if (_hitTargets.contains(enemy)) continue;

        final dist = position.distanceToSquared(enemy.position);
        if (dist < closestDist) {
          closestDist = dist;
          bestTarget = enemy;
        }
      }
      _homingTarget = bestTarget;
    }
  }

  // --- MÉTODO CENTRAL DE MORTE ---
  void kill({bool triggerEffects = true}) {
    if (_isDead) return;
    _isDead = true;

    if (triggerEffects) {
      if (explodes) gameRef.world.add(Explosion(position: position, damagesPlayer:isEnemyProjectile, damage:damage));
      if (splits) _doSplit();
    }
    
    createExplosionEffect(gameRef.world, position, Pallete.laranja, count: 5);
    removeFromParent();
  }

  // --- LÓGICA DE CLUSTER (SPLIT) ---
  void _doSplit() {
    for (int i = 0; i < splitCount; i++) {
      double angle = (2 * pi / splitCount) * i; 
      Vector2 newDir = Vector2(cos(angle), sin(angle));
      
      gameRef.world.add(Projectile(
        position: position.clone(), // Adicionei .clone() para evitar bugs de referência de vetores
        direction: newDir,
        speed: speed * 0.8, 
        damage: damage / 2, 
        isEnemyProjectile: isEnemyProjectile,
        owner: owner,
        dieTimer: 1.0, 
        size: size / 1.5, 
        canBounce: false,
        explodes: false, 
        splits: false, 
        isHoming: isHoming, // Fragmentos herdam a habilidade de perseguir!
      ));
    }
  }

  // --- COLISÃO ---
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isDead) return;

    // Se o alvo já está na lista de atingidos, ignora completamente a colisão
    if (_hitTargets.contains(other)) return;

    final hitPos = intersectionPoints.firstOrNull ?? position;

    // 1. COLISÃO COM PAREDES (Paredes continuam bloqueando/rebatendo tiros perfurantes)
    if (other is Wall || other is ScreenHitbox) {
      if (canBounce && _bounceCount < maxBounces) {
        _handleBounce(other, hitPos);
        if (other is Wall) other.vida--; 
        return; 
      } 
      
      if (other is Wall) {
        other.vida--;
        if (other.vida <= 0) other.removeFromParent();
      }
      kill(); 
      return;
    }

    // 2. COLISÃO COM INIMIGOS / PLAYER
    if (isEnemyProjectile) {
      if (other is Player) {
        _hitTargets.add(other); // Anota na Hit List
        other.takeDamage(1);
        if (!isPiercing) kill(); // Só morre se não for perfurante
      }
    } else {
      if (other is Enemy && !other.isInvencivel && !other.isIntangivel) {
        _hitTargets.add(other); // Anota na Hit List
        other.takeDamage(damage);
        
        // Se a bala teleguiada perfurar, ela precisa esquecer esse alvo para buscar o próximo
        if (isPiercing && _homingTarget == other) {
          _homingTarget = null;
        }

        if (!isPiercing) kill();
      }
      
      if (apagaTiros && other is Projectile && !other.isEnemyProjectile) {
        _hitTargets.add(other);
        other.removeFromParent();
        if (!isPiercing) kill();
      }
    }
  }

  void _handleBounce(PositionComponent obstacle, Vector2 hitPos) {
    _bounceCount++;

    Vector2 relativePos = position - obstacle.position;
    
    if (relativePos.x.abs() > relativePos.y.abs()) {
      direction.x = -direction.x;
    } else {
      direction.y = -direction.y;
    }

    position += direction * 5;
    
    // Perde o "lock-on" ao bater na parede (dá chance do inimigo fugir se ele se esconder atrás do muro)
    _homingTarget = null; 

    _updateRotation();
  }

  void _updateRotation() {
    angle = atan2(direction.y, direction.x) + 1.54 + visualAngle; 
  }
}