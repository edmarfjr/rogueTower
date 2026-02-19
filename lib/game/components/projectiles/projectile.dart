import 'dart:math';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

  late final Vector2 iniPosition;
  
  double _timer = 0.0;
  final double dieTimer;

  // --- COMPORTAMENTOS OPCIONAIS ---
  final bool canBounce;
  final int maxBounces;
  int _bounceCount = 0;

  final bool explodes;
  final double explosionRadius;

  final bool splits;
  final int splitCount;

  final bool isOrbital;
  double _currentAngle = 0; 
  final double orbitalRadius;

  final bool isHoming;
  final double homingTurnSpeed; 
  PositionComponent? _homingTarget; 
  final Vector2 _desiredDirection = Vector2.zero(); 

  final bool isPiercing;
  final Set<PositionComponent> _hitTargets = {};

  final bool isSpectral;

  // 7. BUMERANGUE (BOOMERANG)
  final bool isBoomerang;
  bool _isReturning = false; // Controle de ida e volta

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
    this.canBounce = false,
    this.maxBounces = 2,
    this.explodes = false,
    this.explosionRadius = 60.0,
    this.splits = false,
    this.splitCount = 3,
    this.isOrbital = false,
    this.orbitalRadius = 50.0,
    this.isHoming = false,
    this.homingTurnSpeed = 4.0, 
    this.isPiercing = false,
    this.isSpectral = false,
    this.isBoomerang = false, // Novo Parâmetro!
    Vector2? iniPosition,
  }): super(position: position, size: size ?? Vector2.all(10), anchor: Anchor.center) {
    this.iniPosition = iniPosition?.clone() ?? position.clone();
  }

  @override
  Future<void> onLoad() async {
    IconData icon = Icons.circle;
    Color color = isEnemyProjectile ? Pallete.vermelho : Pallete.amarelo;
    if (explodes) {
      icon = Icons.brightness_high;
    } else if (isBoomerang) {
      icon = MdiIcons.boomerang; 
      color = Pallete.marrom;
    } else if (isHoming) {
      icon = Icons.rocket_launch;
      visualAngle = -pi / 4; 
    }

    visual = GameIcon(
      icon: icon, 
      color: color,
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

    _timer += dt;

    if (owner != null && !owner!.isMounted) {
      if (!isBoomerang) {
        removeFromParent(); 
        return;
      }
    }

    // --- LÓGICA DO BUMERANGUE ---
    if (isBoomerang) {
      visualAngle += 15 * dt; 
      // Garante que a rotação visual funcione mesmo sem o homing
      if (!isHoming || _isReturning) _updateRotation();

      if (!_isReturning && _timer >= dieTimer / 2) {
        _isReturning = true;
        _hitTargets.clear(); 
        _homingTarget = null; 
      }

      if (_isReturning) {
        Vector2 targetPos = (owner != null && owner!.isMounted) 
            ? owner!.position 
            : iniPosition;
            
        _desiredDirection.setFrom(targetPos);
        _desiredDirection.sub(position);

        if (_desiredDirection.length2 < 400) { 
          removeFromParent();
          return;
        }

        _desiredDirection.normalize();
        
        // --- AQUI ESTÁ A MUDANÇA ---
        // Em vez de fazer a curva suave, ele aponta DIRETAMENTE para o alvo
        // criando uma linha reta de retorno perfeita.
        direction.setFrom(_desiredDirection);
      }
    }
    
    // --- LÓGICA HOMING (TELEGUIDADO) ---
    if (isHoming && !isOrbital && !_isReturning) {
      _updateHomingTarget();
      
      if (_homingTarget != null && _homingTarget!.isMounted) {
        _desiredDirection.setFrom(_homingTarget!.position);
        _desiredDirection.sub(position);
        _desiredDirection.normalize();

        direction.x += (_desiredDirection.x - direction.x) * (dt * homingTurnSpeed);
        direction.y += (_desiredDirection.y - direction.y) * (dt * homingTurnSpeed);
        direction.normalize();

        if (!isBoomerang) _updateRotation();
      }
    }

    // --- MOVIMENTO ---
    if (isOrbital) {
      _currentAngle += speed * dt;
      final double centerX = iniPosition.x ;
      final double centerY = iniPosition.y ;

      final newX = centerX + cos(_currentAngle) * orbitalRadius;
      final newY = centerY + sin(_currentAngle) * orbitalRadius;
    
      position.setValues(newX, newY);
    } else {
      position.addScaled(direction, speed * dt);
    }

    // --- VISUAL (PISCAR) ---
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

  void _updateHomingTarget() {
    if (_homingTarget != null && _homingTarget!.isMounted) return;

    if (isEnemyProjectile) {
      _homingTarget = gameRef.player;
    } else {
      final enemies = gameRef.world.children.query<Enemy>();
      double closestDist = double.infinity;
      Enemy? bestTarget;

      for (final enemy in enemies) {
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

  void _doSplit() {
    for (int i = 0; i < splitCount; i++) {
      double angle = (2 * pi / splitCount) * i; 
      Vector2 newDir = Vector2(cos(angle), sin(angle));
      
      gameRef.world.add(Projectile(
        position: position.clone(), 
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
        isHoming: isHoming, 
        isPiercing: isPiercing,
        isBoomerang: isBoomerang, // Fragmentos bumerangues também ficam muito loucos
      ));
    }
  }

  // --- COLISÃO ---
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (_isDead) return;

    if (_hitTargets.contains(other)) return;

    final hitPos = intersectionPoints.firstOrNull ?? position;

    // 1. COLISÃO COM PAREDES
    if (!isSpectral && (other is Wall || other is ScreenHitbox)) {
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
        _hitTargets.add(other); 
        other.takeDamage(1);
        
        // Bumerangue perfura alvos vivos naturalmente!
        if (!isPiercing && !isBoomerang) kill(); 
      }
    } else {
      if (other is Enemy && !other.isInvencivel && !other.isIntangivel) {
        _hitTargets.add(other); 
        other.takeDamage(damage);
        
        if ((isPiercing || isBoomerang) && _homingTarget == other) {
          _homingTarget = null;
        }

        // Bumerangue perfura inimigos para conseguir voltar
        if (!isPiercing && !isBoomerang) kill();
      }
      
      if (apagaTiros && other is Projectile && !other.isEnemyProjectile) {
        _hitTargets.add(other);
        other.removeFromParent();
        if (!isPiercing && !isBoomerang) kill();
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
    
    _homingTarget = null; 

    _updateRotation();
  }

  void _updateRotation() {
    angle = atan2(direction.y, direction.x) + 1.54 + visualAngle; 
  }
}