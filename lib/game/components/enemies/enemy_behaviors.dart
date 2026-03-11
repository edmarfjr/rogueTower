import 'dart:math';
import 'dart:ui';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/gameObj/familiar.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/projectiles/bomb.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:flutter/material.dart';
import '../gameObj/wall.dart';
import 'package:flame/components.dart';
import '../../tower_game.dart';
import 'enemy.dart';
import '../projectiles/projectile.dart';
import '../projectiles/laser_beam.dart';
import '../projectiles/mortar_shell.dart';
import '../projectiles/web.dart';
import '../effects/target_reticle.dart';
import '../effects/path_effect.dart';
import '../effects/explosion_effect.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';

typedef EnemyBuilder = Enemy Function(Vector2);
typedef HazardBuilder = PositionComponent Function(Vector2 position, Enemy owner);

// --- HELPER DE AGGRO---
PositionComponent getEnemyTarget(Enemy enemy) {
  if (enemy.isCharmed) {
    final allEnemies = enemy.gameRef.world.children.whereType<Enemy>();
    
    Enemy? closestEnemy;
    double shortestDist = double.infinity;

    for (var other in allEnemies) {
      // Procura inimigos que NÃO sejam ele mesmo e que NÃO estejam hipnotizados
      if (other != enemy && !other.isCharmed && other.isMounted) {
        double dist = enemy.position.distanceTo(other.position);
        if (dist < shortestDist) {
          shortestDist = dist;
          closestEnemy = other;
        }
      }
    }

    // Se achou um alvo inimigo, ataca ele! 
    // Se a sala estiver limpa (ou só tiver aliados), ele segue o jogador amigavelmente.
    return closestEnemy ?? enemy.gameRef.player; 
  }
  final player = enemy.gameRef.player;
  bool bombLure = false;
  
  PositionComponent bestTarget = player;
  double shortestDist = enemy.position.distanceTo(player.position);

  for (var familiar in player.familiars) {
    if (familiar.isMounted && familiar.type == FamiliarType.decoy) {
      double dist = enemy.position.distanceTo(familiar.position);
      if (dist < shortestDist) {
        shortestDist = dist;
        bestTarget = familiar;
      }
    }
  }
/*
  final decoyBombs = enemy.gameRef.world.children.whereType<Bomb>();
  
  for (var bomb in decoyBombs) {
    double dist = enemy.position.distanceTo(bomb.position);
    
    // Se o inimigo estiver dentro da área de atração da bomba,
    // e ela estiver mais perto que o jogador/familiar, ele vai nela!
    if (bomb.isDecoy && dist <= bomb.attractionRadius && dist < shortestDist) {
      shortestDist = dist;
      bestTarget = bomb;
      bombLure = true;
      
    }
  }

  if (bombLure){
    enemy.isBombLured = true;
  }else{
    enemy.isBombLured = false;
  }
  */
  return bestTarget;
}

// --- INTERFACES ---

abstract class MovementBehavior {
  late Enemy enemy;
  void update(double dt);
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

abstract class AttackBehavior {
  late Enemy enemy;
  void update(double dt);
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

abstract class DeathBehavior {
  late Enemy enemy;
  void onDeath();
}

// --- MOVIMENTOS (MOVEMENT BEHAVIORS) ---

class IdleBehavior extends MovementBehavior {
  @override
  void update(double dt) {}
}

class FollowPlayerBehavior extends MovementBehavior {
  final Vector2 _direction = Vector2.zero();
  final double speedMod;

  FollowPlayerBehavior({this.speedMod = 1});
  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    final target = getEnemyTarget(enemy);
    
    _direction
      ..setFrom(target.position) 
      ..sub(enemy.position)      
      ..normalize();             
    
    if (enemy.rotates) {
      if (enemy.visual != null) enemy.visual!.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
    }
    
    enemy.position.addScaled(_direction, enemy.speed * speedMod * dt);
  }
}

class GoToCenterBehavior extends MovementBehavior {
  final Vector2 _direction = Vector2.zero();
  Vector2 _target = Vector2.zero();

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    _direction
      ..setFrom(_target)
      ..sub(enemy.position)      
      ..normalize();             
    
    if (enemy.rotates) {
      if (enemy.visual != null) enemy.visual!.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
    }
    if (enemy.position.distanceTo(_target) > 10){
      enemy.position.addScaled(_direction, enemy.speed * dt);
    }
  }
}

class KeepDistanceBehavior extends MovementBehavior {
  final double minDistance;
  final double maxDistance;

  final Vector2 _direction = Vector2.zero();

  KeepDistanceBehavior({this.minDistance = 150, this.maxDistance = 250});

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    final target = getEnemyTarget(enemy); // Puxa o Player ou o Decoy!
    final distance = enemy.position.distanceTo(target.position);
    
    _direction
      ..setFrom(target.position) 
      ..sub(enemy.position)      
      ..normalize();             

    if (enemy.rotates) {
      if (enemy.visual != null) enemy.visual!.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
    }

    if (distance > maxDistance) {
      enemy.position.addScaled(_direction, enemy.speed * dt);
    } else if (distance < minDistance) {
      enemy.position.addScaled(-_direction, (enemy.speed * 0.8) * dt);
    }
  }
}

class RandomWanderBehavior extends MovementBehavior {
  Vector2 _target = Vector2.zero();
  final Vector2 _direction = Vector2.zero();
  final Vector2 _tempCalc = Vector2.zero(); 
  final Random _rng = Random(); 

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    if (_target == Vector2.zero() || enemy.position.distanceTo(_target) < 10) {
      _pickNewTarget();
    }

    _direction
      ..setFrom(_target)       
      ..sub(enemy.position)    
      ..normalize();           

    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) {
        visual.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
      }
    }

    enemy.position.addScaled(_direction, enemy.speed * dt);
  }

  void _pickNewTarget({Vector2? pushAwayFrom}) {
    double w = TowerGame.gameWidth / 2 - 40; 
    double h = TowerGame.gameHeight / 2 - 40;

    if (pushAwayFrom != null) {
      double baseAngle = atan2(pushAwayFrom.y, pushAwayFrom.x);
      double noise = (_rng.nextDouble() - 0.5) * (pi / 1.5); 
      double finalAngle = baseAngle + noise;

      double dist = 100 + _rng.nextDouble() * 100;
      _target.setValues(
        enemy.position.x + cos(finalAngle) * dist,
        enemy.position.y + sin(finalAngle) * dist,
      );
    } else {
      _target.setValues(
        (_rng.nextDouble() * 2 * w) - w, 
        (_rng.nextDouble() * 2 * h) - h
      );
    }

    _target.x = _target.x.clamp(-w, w);
    _target.y = _target.y.clamp(-h, h);
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
     if (other is Web || other is PoisonPuddle) return;
     if (other.position.distanceTo(_target) > other.position.distanceTo(enemy.position)) return;

     _tempCalc.setFrom(enemy.position);
     _tempCalc.sub(other.position);
     _pickNewTarget(pushAwayFrom: _tempCalc);
  }
}

class BouncerBehavior extends MovementBehavior {
  Vector2 _velocity = Vector2.zero();

  @override
  void update(double dt) {
    if (_velocity == Vector2.zero()) {
       final rng = Random();
       double angle = rng.nextDouble() * 2 * pi;
       _velocity = Vector2(cos(angle), sin(angle)) * enemy.speed;
    }
    
    enemy.position += _velocity * dt;
    _checkBounds();
  }

  void _checkBounds() {
    double halfWidth = enemy.size.x / 2;
    double halfHeight = enemy.size.y / 2;

    double rightLimit = (TowerGame.gameWidth / 2) - halfWidth;
    double leftLimit = -(TowerGame.gameWidth / 2) + halfWidth;
    double topLimit = -(TowerGame.gameHeight / 2) + halfHeight;
    double bottomLimit = (TowerGame.gameHeight / 2) - halfHeight;

    if (enemy.position.x >= rightLimit) {
      _velocity.x = -_velocity.x.abs(); 
      enemy.position.x = rightLimit;      
    } 
    else if (enemy.position.x <= leftLimit) {
      _velocity.x = _velocity.x.abs();  
      enemy.position.x = leftLimit;       
    }

    if (enemy.position.y >= bottomLimit) {
      _velocity.y = -_velocity.y.abs(); 
      enemy.position.y = bottomLimit;     
    } 
    else if (enemy.position.y <= topLimit) {
      _velocity.y = _velocity.y.abs();  
      enemy.position.y = topLimit;        
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall) {
      final myRect = enemy.toAbsoluteRect();
      final otherRect = other.toAbsoluteRect();
      final intersection = myRect.intersect(otherRect);

      if (intersection.width < intersection.height) {
         if (_velocity.x > 0 && enemy.position.x < other.position.x) {
            _velocity.x = -_velocity.x; 
         }
         else if (_velocity.x < 0 && enemy.position.x > other.position.x) {
            _velocity.x = -_velocity.x; 
         }
      } else {
         if (_velocity.y > 0 && enemy.position.y < other.position.y) {
            _velocity.y = -_velocity.y; 
         }
         else if (_velocity.y < 0 && enemy.position.y > other.position.y) {
            _velocity.y = -_velocity.y; 
         }
      }
    }
  }
}

// --- ATAQUES (ATTACK BEHAVIORS) ---

class NoAttackBehavior extends AttackBehavior {
  @override
  void update(double dt) {}
}

class ProjectileAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  double speed;
  late Vector2 size;
  
  final bool isShotgun;
  final bool is2shot;
  final bool isOrbital;
  final double orbitalRadius;
  final bool isStraight;
  final bool isHoming;
  final bool isBoomerang;

  final bool isBurst;
  final int burstCount;       
  final double burstDelay;    

  bool _isBurstActive = false;
  int _burstShotsFired = 0;
  double _burstTimer = 0;

  ProjectileAttackBehavior({
    this.interval = 2.0,
    this.speed = 200,
    this.isShotgun = false,
    this.is2shot = false,
    this.isOrbital = false,
    this.isStraight = true,
    this.isBurst = false,
    this.isHoming = false,
    this.isBoomerang = false,
    this.burstCount = 3,
    this.burstDelay = 0.2,
    this.orbitalRadius = 50.0,
    Vector2? size,
  }) {
    this.size = size ?? Vector2.all(10);
  }

  @override
  void update(double dt) {
    if (!enemy.isMounted) return;

    if (_isBurstActive) {
      _burstTimer += dt;
      if (_burstTimer >= burstDelay) {
        _triggerShotPattern(); 
        _burstShotsFired++;
        _burstTimer = 0; 

        if (_burstShotsFired >= burstCount) {
          _isBurstActive = false;
          _burstShotsFired = 0;
          _timer = 0; 
        }
      }
      return; 
    }

    _timer += dt;
    if (_timer >= interval) {
      if (isBurst) {
        _isBurstActive = true;
        _burstShotsFired = 0;
        _burstTimer = burstDelay; 
      } else {
        _triggerShotPattern();
        _timer = 0;
      }
    }
  }

  void _triggerShotPattern() {
    final target = getEnemyTarget(enemy); // Puxa o Player ou o Decoy!
    final direction = (target.position - enemy.position).normalized();

    if (is2shot) {
      _fireBullet(direction, 0.2);
      _fireBullet(direction, -0.2);
    } else {
      _fireBullet(direction, 0); 
      
      if (isShotgun) {
        _fireBullet(direction, 0.3);
        _fireBullet(direction, -0.3);
      }
    }
  }

  void _fireBullet(Vector2 baseDir, double angleOffset) {
    AudioManager.playSfx('enemyShot.mp3');
    
    double x = baseDir.x * cos(angleOffset) - baseDir.y * sin(angleOffset);
    double y = baseDir.x * sin(angleOffset) + baseDir.y * cos(angleOffset);
    final newDir = Vector2(x, y);
    
    if(!isStraight){
      double angleOffset = Random().nextDouble() * 0.2;
      double x = newDir.x * cos(angleOffset) - newDir.y * sin(angleOffset);
      double y = newDir.x * sin(angleOffset) + newDir.y * cos(angleOffset);
      newDir.setValues(x, y);
    }

    enemy.gameRef.world.add(Projectile(
      position: enemy.position + newDir * 20,
      direction: newDir,
      damage: enemy.isCharmed? enemy.gameRef.player.damage/2 : 1,
      speed: speed,
      size: size,
      owner: enemy,
      isOrbital: isOrbital,
      orbitalRadius: orbitalRadius,
      isHoming: isHoming,
      isBoomerang: isBoomerang,
      dieTimer: isBoomerang ? 1.0 : 3.0,
      isEnemyProjectile: !enemy.isCharmed,
    ));
  }
}

class MortarAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  final double minRange = 600;
  final bool isPoison;
  final double explosionRadius;
  final bool isBarragem;
  final int numMortars;

  MortarAttackBehavior({
    this.interval = 4.0, 
    this.isPoison = false, 
    this.isBarragem = false,
    this.numMortars = 10,
    this.explosionRadius = 60.0
  });

  @override
  void update(double dt) {
    if (enemy == null) return; 

    _timer += dt;
    final target = getEnemyTarget(enemy); 
    final dist = enemy.position.distanceTo(target.position);

    if (_timer >= interval && dist < minRange) {
      _timer = 0;
      
      if (isBarragem) {
        _fireBarrage();
      } else {
        _fireSingleMortar(target.position);
      }
    }
  }

  void _fireSingleMortar(Vector2 targetPos) {
    final target = targetPos.clone();
    AudioManager.playSfx('enemyShot.mp3');
    _spawnMortar(target, 1.5);
  }

  void _fireBarrage() {
    final rng = Random();
    AudioManager.playSfx('enemyShot.mp3'); 

    for (int i = 0; i < numMortars; i++) {
      double randomX = (rng.nextDouble() * 320) - 160; 
      double randomY = (rng.nextDouble() * 560) - 280; 
      Vector2 randomTarget = Vector2(randomX, randomY);
      double variedFlightTime = 1.2 + (rng.nextDouble() * 1.3);

      _spawnMortar(randomTarget, variedFlightTime);
    }
  }

  void _spawnMortar(Vector2 target, double flightTime) {
    enemy.gameRef.world.add(TargetReticle(
      position: target,
      duration: flightTime,
      owner: enemy,
      radius: explosionRadius,
    ));
    
    enemy.gameRef.world.add(MortarShell(
      startPos: enemy.position.clone(),
      targetPos: target,
      owner: enemy,
      flightDuration: flightTime,
      isPoison: isPoison,
      explosionRadius: explosionRadius,
      isPlayer: enemy.isCharmed,
      damage: enemy.isCharmed? enemy.gameRef.player.damage : 1,
    ));
  }
}

class LaserAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  bool _isShooting = false;
  bool isMoving;
  final bool isShotgun;
  
  LaserAttackBehavior({this.interval = 3.0, this.isMoving = false, this.isShotgun = false});

  @override
  void update(double dt) {
    _timer += dt;

    if (_isShooting) {
      enemy.canMove = false; 
      if (_timer > 1.2) {
        _isShooting = false;
        enemy.canMove = true; 
        _timer = 0;
      }
      return;
    }

    final target = getEnemyTarget(enemy); 
    final dist = enemy.position.distanceTo(target.position);
    
    if (_timer >= interval && dist < 350) {
      _isShooting = true;
      _timer = 0;
      
      final dir = (target.position - enemy.position).normalized();
      final angle = atan2(dir.y, dir.x);

      criaLaser(dir,angle);
      if (isShotgun) {
        criaLaser(dir,angle+0.2);
        criaLaser(dir,angle-0.2);
      }
    }
  }

  void criaLaser(Vector2 dir,ang)
  {
    enemy.gameRef.world.add(LaserBeam(
      position: enemy.position + (dir * 10),
      angleRad: ang,
      owner: enemy,
      isMoving: isMoving,
      isEnemyProjectile: !enemy.isCharmed,
      damage: enemy.isCharmed? enemy.gameRef.player.damage : 1,
    ));
  }
}

class SpinnerAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  late Vector2 size;
  final bool isDiagonal;
  final bool isChangeDir;
  final bool isBoomerang;
  final bool isSpiral;

  final int projectilesPerWave;
  final double spinSpeed; 
  
  double _currentAngle = 0;
  bool _isNextDiagonal = false; 

  SpinnerAttackBehavior({
    this.interval = 1.5, 
    this.isDiagonal = false, 
    this.isChangeDir = false,
    this.isBoomerang = false,
    this.isSpiral = false,
    this.projectilesPerWave = 4, 
    this.spinSpeed = 0.4,
  Vector2? size,
  }) {
    this.size = size ?? Vector2.all(10);
  }

  @override
  void update(double dt) {
    if (enemy == null || enemy!.isFreeze) return; 

    _timer += dt;
    if (_timer >= interval) {
      AudioManager.playSfx('enemyShot.mp3');
      
      if (isSpiral) {
        _shootSpiral();
      } else {
        _shootCrossOrDiagonal();
      }
          
      _timer = 0;
    }
  }

  void _shootSpiral() {
    for (int i = 0; i < projectilesPerWave; i++) {
      double angle = _currentAngle + (i * (2 * pi / projectilesPerWave));
      Vector2 direction = Vector2(cos(angle), sin(angle));
      _spawnProjectile(direction);
    }
    _currentAngle += spinSpeed; 
  }

  void _shootCrossOrDiagonal() {
    List<Vector2> directions;

    if (isDiagonal || (_isNextDiagonal && isChangeDir)) {
      directions = [Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1)];
    } else {
      directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)];
    }

    if (isChangeDir) {
      _isNextDiagonal = !_isNextDiagonal;
    }

    for (var dir in directions) {
      _spawnProjectile(dir);
    }
  }

  void _spawnProjectile(Vector2 dir) {
    enemy!.gameRef.world.add(Projectile(
      position: enemy!.position + dir * 20,
      direction: dir,
      damage: enemy.isCharmed? enemy.gameRef.player.damage/2 : 1,
      speed: 200,
      size: size,
      owner: enemy,
      isBoomerang: isBoomerang,
      dieTimer: isBoomerang ? 1.0 : 3.0,
      isEnemyProjectile: !enemy.isCharmed,
    ));
  }
}

class DashAttackBehavior extends AttackBehavior {
  int _state = 0; 
  double _timer = 0;
  Vector2 _dashDir = Vector2.zero();
  bool _hitProcessed = false; 

  @override
  void update(double dt) {
    _hitProcessed = false; 
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;

    if (_state == 0) { 
      enemy.canMove = false; 
      
      if (_timer < 0.5) { 
         final target = getEnemyTarget(enemy); 
         _dashDir = (target.position - enemy.position).normalized();
         if(visual != null) visual.angle = atan2(_dashDir.y, _dashDir.x) + enemy.rotateOff;
      } else { 
         if (_timer < 0.6) { 
            enemy.gameRef.world.add(PathEffect(
              position: enemy.position.clone(),
              angleRad: atan2(_dashDir.y, _dashDir.x),
              owner: enemy,
            ));
         }
      }
      
      _timer += dt;
      if (_timer >= 1.0) {
        _state = 1; 
        _timer = 0;
        if(visual != null) visual.setColor(Pallete.vermelho);
      }
      
    } else if (_state == 1) { 
       enemy.position += _dashDir * 350 * dt; 
       
       if(_checkArenaImpact()) {
          _triggerBonk();
       }
       
    } else if (_state == 2) { 
       _timer += dt;
       if (_timer >= 1.0) {
         _state = 0; 
         _timer = 0;
         enemy.canMove = true;
         if(visual != null) visual.setColor(Pallete.amarelo);
       }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_state == 1 && other is Wall && !_hitProcessed) {
       _triggerBonk();
       _hitProcessed = true;
    }
  }

  void _triggerBonk() {
    _state = 2; 
    _timer = 0;
    enemy.position -= _dashDir * 20; 
    enemy.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
  }

  bool _checkArenaImpact() {
    bool hit = false;
    double halfW = TowerGame.gameWidth / 2;
    double halfH = TowerGame.gameHeight / 2;
    double r = enemy.size.x / 2;

    if (enemy.position.x <= -halfW + r || enemy.position.x >= halfW - r) {
      hit = true;
    }
    if (enemy.position.y <= -halfH + r || enemy.position.y >= halfH - r) {
      hit = true;
    }
    return hit;
  }
}

class ChargeAttackBehavior extends AttackBehavior {
  final double detectRange; 
  final double chargeSpeed; 
  final double prepTime;    
  
  int _state = 0; 
  double _timer = 0;
  Vector2 _chargeDir = Vector2.zero();

  ChargeAttackBehavior({
    this.detectRange = 200,
    this.chargeSpeed = 350,
    this.prepTime = 0.5,
  });

  @override
  void update(double dt) {
    final target = getEnemyTarget(enemy);
    final visual = enemy.visual;

    if (_state == 0) {
      double dist = enemy.position.distanceTo(target.position);
      
      if (dist <= detectRange) {
        _state = 1;
        _timer = 0;
        enemy.canMove = false; 
        visual?.setColor(Pallete.vermelho);
      }
    }
    else if (_state == 1) {
      _timer += dt;
      
      _chargeDir = (target.position - enemy.position).normalized();
      
      if (visual != null && !enemy.rotates) {
         if (target.position.x < enemy.position.x) visual.scale.x = -1;
         else visual.scale.x = 1;
      }

      if (_timer >= prepTime) {
        _state = 2; 
        _timer = 0;
      }
    }
    else if (_state == 2) {
      _timer += dt;
      enemy.position += _chargeDir * chargeSpeed * dt;

      if (_timer >= 1.0) {
        _stopCharge();
      }
    }
    else if (_state == 3) {
      _timer += dt;
      if (_timer >= 1.5) { 
        _state = 0; 
        _timer = 0;
        enemy.canMove = true; 
        visual?.setColor(enemy.originalColor); 
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_state == 2) { 
      if (other is Wall) {
        enemy.position -= _chargeDir * 10;
        _stopCharge();
      }
      
      // Se bater no jogador ou no decoy, também para o charge
      final target = getEnemyTarget(enemy);
      if (other == target) {
         _stopCharge();
      }
    }
  }

  void _stopCharge() {
    _state = 3; 
    _timer = 0;
    enemy.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.cinzaEsc);
  }
}

class JumpAttackBehavior extends AttackBehavior {
  final double jumpRange;
  final double minRange;
  final double jumpDuration;
  final double cooldown;
  final double impactRadius;
  final double maxJumpHeight; 

  final bool isRandomJump; 
  final double randomJumpRadius; 

  final bool isExplosionOnLand;
  final bool is4ShotOnLand;

  late PositionComponent _cachedTarget; 

  bool _isJumping = false;
  double _timer = 0;
  Vector2 _startPos = Vector2.zero();
  Vector2 _targetPos = Vector2.zero();

  CircleComponent? _shadow;

  JumpAttackBehavior({
    this.jumpRange = 250,
    this.minRange = 50,
    this.jumpDuration = 0.8,
    this.cooldown = 2.5,
    this.impactRadius = 60,
    this.maxJumpHeight = 120.0, 
    this.isRandomJump = false, 
    this.randomJumpRadius = 100.0,
    this.isExplosionOnLand = true, 
    this.is4ShotOnLand = false, 
  });

  @override
  void update(double dt) {
    if (!enemy.isMounted) return;
    _cachedTarget = getEnemyTarget(enemy); 

    if (_isJumping) {
      _timer += dt;
      double progress = (_timer / jumpDuration).clamp(0.0, 1.0);

      enemy.position.x = lerpDouble(_startPos.x, _targetPos.x, progress)!;
      enemy.position.y = lerpDouble(_startPos.y, _targetPos.y, progress)!;

      double arc = sin(progress * pi);
      double heightFactor = sin(progress * pi);
      
      if (enemy.visual != null) {
        enemy.visual!.position.y = (enemy.size.y / 2) - (arc * maxJumpHeight);
        enemy.scale = Vector2.all(1.0 + (heightFactor * 0.5));
      }

      if (_shadow != null) {
        _shadow!.scale = Vector2.all(1.0 - (arc * 0.6)); 
        _shadow!.paint.color = Pallete.cinzaEsc;
      }

      if (progress >= 1.0) {
        _land();
      }
    } else {
      _timer += dt;

      if (_timer >= cooldown) {
        if (isRandomJump) {
          _startJump(_getRandomTarget());
        } else {
          double dist = enemy.position.distanceTo(_cachedTarget.position);

          if (dist <= jumpRange && dist >= minRange) {
            _startJump(_cachedTarget.position);
          }
        }
      }
    }
  }

  Vector2 _getRandomTarget() {
    final rng = Random();
    double angle = rng.nextDouble() * 2 * pi;
    double dist = (rng.nextDouble() * randomJumpRadius) + 30; 
    
    Vector2 offset = Vector2(cos(angle), sin(angle)) * dist;
    Vector2 target = enemy.position + offset;

    double halfW = TowerGame.gameWidth / 2 - 20;
    double halfH = TowerGame.gameHeight / 2 - 20;
    
    target.x = target.x.clamp(-halfW, halfW);
    target.y = target.y.clamp(-halfH, halfH);

    return target;
  }

  void _startJump(Vector2 target) {
    _isJumping = true;
    enemy.isIntangivel = true;
    _timer = 0;
    enemy.canMove = false;
    
    _startPos = enemy.position.clone();
    _targetPos = target.clone();

    if (!isRandomJump){
      enemy.gameRef.world.add(TargetReticle(
        position: target,
        duration: jumpDuration,
        radius: impactRadius,
      ));
    }
    
    _shadow = CircleComponent(
      radius: enemy.size.x / 2.5,
      position: enemy.size / 2, 
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
      priority: -1, 
    );
    _shadow!.scale.y = 0.5; 
    enemy.add(_shadow!);
  }

  void _land() {
    _isJumping = false;
    enemy.isIntangivel = false;
    _timer = 0;
    enemy.canMove = true;

    _shadow?.removeFromParent();
    _shadow = null;
    
    if (enemy.visual != null) {
      enemy.visual!.position.y = enemy.size.y / 2; 
    }
    enemy.scale = Vector2.all(1.0);

    if (isExplosionOnLand){
      createExplosionEffect(enemy.gameRef.world, enemy.position, Colors.orange, count: 15);
      
      
      if (enemy.position.distanceTo(_cachedTarget.position) <= impactRadius) {
        if (_cachedTarget is Player) {
           (_cachedTarget as Player).takeDamage(1);
        }else if (_cachedTarget is Enemy) {
           (_cachedTarget as Enemy).takeDamage(enemy.gameRef.player.damage/2);
        }
        
        Vector2 pushDir = (_cachedTarget.position - enemy.position).normalized();
        _cachedTarget.position += pushDir * 30;
      }
    }else if (is4ShotOnLand){
      List<Vector2> directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)];
      for (var dir in directions) {
        enemy.gameRef.world.add(Projectile(
          position: enemy.position + dir * 20,
          direction: dir,
          damage: enemy.isCharmed? enemy.gameRef.player.damage/2 : 1,
          speed: 200,
          owner: enemy,
          isEnemyProjectile: !enemy.isCharmed,
        ));
      } 
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_isJumping) return; 
    super.onCollision(intersectionPoints, other);
  }
}

class SummonAttackBehavior extends AttackBehavior {
  final double interval;
  final int maxMinions;
  final EnemyBuilder minionBuilder; 
  
  double _timer = 0;
  final List<Enemy> _minions = []; 

  SummonAttackBehavior({
    required this.minionBuilder, 
    this.interval = 4.0, 
    this.maxMinions = 3
  });

  @override
  void update(double dt) {
    if (enemy == null) return;

    _minions.removeWhere((e) => !e.isMounted || e.hp <= 0);

    if (_minions.length < maxMinions) {
      _timer += dt;
      if (_timer >= interval) {
        _summonMinion();
        _timer = 0; 
      }
    } else {
      _timer = 0; 
    }
  }

  void _summonMinion() {
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;
    visual?.setColor(Pallete.rosa);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (enemy.isMounted) visual?.setColor(enemy.originalColor);
    });

    final rng = Random();
    double offsetX = (rng.nextDouble() * 60) - 30; 
    double offsetY = (rng.nextDouble() * 60) - 30;
    Vector2 spawnPos = enemy.position + Vector2(offsetX, offsetY);

    // --- AQUI A MÁGICA ACONTECE ---
    // Usamos a função variável para criar o inimigo específico
    final minion = minionBuilder(spawnPos);
    
    // Configurações extras opcionais (se quiser forçar que minions sejam menores)
    // minion.scale = Vector2.all(0.8); 
    
    enemy.gameRef.world.add(minion);
    _minions.add(minion);

    createExplosionEffect(enemy.gameRef.world, spawnPos, Pallete.cinzaCla, count: 5);
  }
}

class DropHazardBehavior extends AttackBehavior {
  final double interval;
  final HazardBuilder hazardBuilder; // A função que cria o objeto
  double _timer = 0;

  DropHazardBehavior({
    required this.hazardBuilder, // Obrigatório: O que soltar?
    this.interval = 3.0,
  });

  @override
  void update(double dt) {
    _timer += dt;
    
    if (_timer >= interval) {
      // Verifica se o inimigo ainda existe antes de tentar soltar algo
      if (enemy.isMounted) {
        _dropHazard();
        _timer = 0;
      }
    }
  }

  void _dropHazard() {
    // 1. Usa a função builder para criar o objeto na posição atual
    final hazard = hazardBuilder(enemy.position.clone(), enemy);
    
    // 2. Adiciona ao mundo
    enemy.gameRef.world.add(hazard);
  }
}

// --- MORTES (DEATH BEHAVIORS) ---

// 1. Padrão: Apenas morre (dá almas e somem)
class NoDeathEffect extends DeathBehavior {
  @override
  void onDeath() {
    // Nada acontece (além da lógica padrão do Enemy)
  }
}

// 2. Explosão: Cria dano em área ao morrer (Kamikaze)
class ExplosionDeathBehavior extends DeathBehavior {
  final int damage;
  final double radius;

  ExplosionDeathBehavior({this.damage = 10, this.radius = 60});

  @override
  void onDeath() {
    // Efeito Visual
    createExplosionEffect(enemy.gameRef.world, enemy.position, Pallete.vermelho, count: 20);

    // Lógica de Dano em Área (AOE)
    // Verifica se o player está perto
    final player = enemy.gameRef.player;
    if (player.position.distanceTo(enemy.position) <= radius) {
       player.takeDamage(damage);
    }
    
    // Opcional: Dano em outros inimigos (Fogo Amigo)
    // ...
  }
}

// 3. Projéteis: Solta tiros em todas as direções (Bullet Hell)
class ProjectileBurstDeathBehavior extends DeathBehavior {
  final int projectileCount;
  
  ProjectileBurstDeathBehavior({this.projectileCount = 8});

  @override
  void onDeath() {
    double step = (2 * pi) / projectileCount;

    for (int i = 0; i < projectileCount; i++) {
      double angle = step * i;
      Vector2 dir = Vector2(cos(angle), sin(angle));
      
      enemy.gameRef.world.add(Projectile(
        position: enemy.position,
        direction: dir,
        damage: enemy.isCharmed? enemy.gameRef.player.damage/2 : 1,
        speed: 150,
        owner: enemy,
        isEnemyProjectile: !enemy.isCharmed,
      ));
    }
  }
}

// 4. Invocação: O inimigo se divide em outros (Slime Split)
class SpawnOnDeathBehavior extends DeathBehavior {
  final int count;
  final EnemyBuilder minionBuilder;

  SpawnOnDeathBehavior({required this.minionBuilder, this.count = 2});

  @override
  void onDeath() {
    for (int i = 0; i < count; i++) {
      // Pequena variação na posição para não nascerem empilhados
      Vector2 offset = Vector2(
        (Random().nextDouble() - 0.5) * 50,
        (Random().nextDouble() - 0.5) * 50,
      );
      
      final minion = minionBuilder(enemy.position + offset);
      
      // Opcional: Minions nascem menores/mais fracos
      //minion.scale = Vector2.all(0.7);
      //minion.hp = minion.hp / 2;
      
      enemy.gameRef.world.add(minion);
    }
  }
}