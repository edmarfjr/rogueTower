import 'dart:math';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/gameObj/familiar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; 
import '../effects/explosion_effect.dart';
import '../enemies/enemy.dart';
import '../gameObj/player.dart';
import '../gameObj/wall.dart';

class LaserBeam extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double damage;
  final double maxLength;
  double currentLength;
  double larguraLaser;
  double angleRad; 
  bool isEnemyProjectile;
  bool isMoving;
  double speed;
  double dirMove = 0;
  
  double dmgTmr = 0;
  double dmgTime;
  
  double _timer = 0;
  double chargeTime; 
  double fireTime;   
  bool _hasFired = false;

  final PositionComponent? owner;
  PositionComponent? target;

  RectangleHitbox? _hitbox;

  bool critico = true;

  Color cor;
  bool refratado;

  bool followsOwnerMov;
  bool invisivel = false;
  bool _canDamageThisFrame = false;

  bool atravessa;
  bool chains;
  int chainCount;
  int maxChains;

  bool isFreeze;
  bool isBurn;
  bool isPoison;
  bool isBleed;
  bool isCharm;
  bool isParalised;
  bool isFear;


  LaserBeam({
    required Vector2 position,
    required this.angleRad,
    this.target,
    this.damage = 1,
    double length = 400,
    this.larguraLaser = 8,
    this.chargeTime = 1,
    this.fireTime = 1,
    this.dmgTime = 0.3,
    this.owner,
    this.isEnemyProjectile = false,
    this.isMoving = false,
    this.followsOwnerMov = false,
    this.speed = 0.025,
    this.cor = Pallete.vermelho,
    this.refratado = false,
    this.invisivel = false,
    this.atravessa = false,
    this.chains = false,
    this.chainCount = 0,
    this.maxChains = 4,
    this.isFreeze = false,
    this.isBurn = false,
    this.isPoison = false,
    this.isBleed = false,
    this.isCharm = false,
    this.isParalised = false,
    this.isFear = false,
  }): maxLength = length, 
      currentLength = length, 
      super(position: position, anchor: Anchor.centerLeft);

  @override
  Future<void> onLoad() async {
    angle = angleRad;
    priority = 500; 
    if (owner is Enemy) critico = false;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (owner != null && !owner!.isMounted) {
      removeFromParent(); 
      return;
    }

    _timer += dt;
    
    // --- LÓGICA DE DISPARO E DANO CONTÍNUO ---
    if (_timer >= chargeTime && !_hasFired) {
      _fire();
      AudioManager.playSfx('laser.mp3');
      dmgTmr = 0; 
    }

    if (_hasFired) {
      if(dmgTmr > 0){
        dmgTmr -= dt;
        _canDamageThisFrame = false; 
      } else {
        _canDamageThisFrame = true; 
        dmgTmr = dmgTime; 
      }
    }

    // --- MÁGICA DA MOVIMENTAÇÃO E MIRA ---
    
    // 1. A ORIGEM: O laser sempre acompanha o dono (se ele existir)
    if (owner != null) {
      position = owner!.position.clone();
    }

    // 2. A MIRA: Regras de rotação centralizadas e unificadas
    if (target != null && target!.isMounted) {
      // Usa o absoluteCenter para mirar perfeitamente no meio do alvo!
      final directionVector = target!.absoluteCenter - absolutePosition;
      angle = atan2(directionVector.y, directionVector.x);
      
    } else if (followsOwnerMov && owner != null) {
      // Se não tem alvo, mas o laser deve seguir pra onde o dono anda
      Vector2 velocity = Vector2.zero();
      
      // Coleta a velocidade dependendo de quem é o dono
      if (owner is Player) velocity = (owner as Player).velocity;
      if (owner is Familiar) velocity = (owner as Familiar).velocity;

      // Só muda a mira se ele estiver andando
      if (velocity.length > 1.0) {
        angle = atan2(velocity.y, velocity.x);
      }
      
    } else if (isMoving && _hasFired) {
      // Se for um laser de "varredura" inimigo que só fica girando
      if(dirMove == 0){
         dirMove = Random().nextBool() ? 1 : -1; 
      }
      angle += speed * dirMove;
    }

    // --- ATUALIZA O TAMANHO (Raycast) ---
    if(!atravessa) _updateLaserLength(); 

    // --- FINALIZAÇÃO ---
    if (_timer >= chargeTime + fireTime) {
      removeFromParent();
    }
  }

  Enemy? _findNextTarget(Enemy currentEnemy) {
    double jumpRange = 150.0; 
    Enemy? closest;
    double minDistance = jumpRange;

    for (final enemy in gameRef.world.children.whereType<Enemy>()) {
      if (enemy == currentEnemy || !enemy.isMounted) continue;

      double dist = currentEnemy.absoluteCenter.distanceTo(enemy.absoluteCenter);
      if (dist < minDistance) {
        minDistance = dist;
        closest = enemy;
      }
    }
    return closest;
  }

  void _updateLaserLength() {
    final directionVector = Vector2(cos(absoluteAngle), sin(absoluteAngle));
    final ray = Ray2(origin: absolutePosition, direction: directionVector);

    final result = gameRef.collisionDetection.raycast(
      ray,
      maxDistance: maxLength,
      ignoreHitboxes: [
        if (_hitbox != null) _hitbox!, 
        if (owner != null) ...owner!.children.whereType<ShapeHitbox>(), 
      ],
    );

    if (result != null && result.hitbox != null) {
      final hitParent = result.hitbox!.parent;
      
      if (hitParent is Wall || result.hitbox is ScreenHitbox || hitParent is Enemy || hitParent is Player
      || hitParent is Familiar && hitParent.type == FamiliarType.prisma) {
        currentLength = result.distance!;
      } else {
        currentLength = maxLength;
      }
    } else {
      currentLength = maxLength; 
    }

    if (_hitbox != null) {
      _hitbox!.size.x = currentLength;
    }
  }

  void _fire() {
    _hasFired = true;
    _hitbox = RectangleHitbox(
      position: Vector2(0, -larguraLaser/2), 
      size: Vector2(currentLength, larguraLaser), 
      isSolid: true,
      collisionType: CollisionType.active, 
    );
    add(_hitbox!);
    
    gameRef.camera.viewfinder.position += Vector2(Random().nextDouble() * 2, Random().nextDouble() * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if(invisivel) return;
    
    if (!_hasFired) {
      double opacity = (_timer * 10).toInt() % 2 == 0 ? 0.3 : 0.6;
      final paintWarning = Paint()
        ..color = Pallete.vermelho.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = false;

      canvas.drawLine(Offset.zero, Offset(currentLength, 0), paintWarning);
    } else {
      final paintGlow = Paint()
        ..color = cor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = larguraLaser * 0.8
        ..isAntiAlias = false; 

      final paintCore = Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.fill
        ..strokeWidth = larguraLaser / 5
        ..isAntiAlias = false;

      double x = 4;
      if(owner!=null){
        x = owner!.size.x/2;
        if(owner! is Player && gameRef.player.arma != null){
          x = owner!.size.x/2 + 8;
        }
      } 
      canvas.drawLine(Offset(x, 0), Offset(currentLength, 0), paintGlow);
      canvas.drawLine(Offset(x, 0), Offset(currentLength, 0), paintCore);
      canvas.drawCircle(Offset(currentLength, 0), larguraLaser/2, paintGlow);
      canvas.drawCircle(Offset(currentLength, 0), larguraLaser/2, paintCore);
    }
  }

  void refrata(Vector2 hitPos) {
    if (refratado) return; 
    refratado = true;

    List<double> angs = [-0.2, -0.1, 0.2, 0.1];
    for (int i = 0; i < angs.length; i++) {
      double angleOffset = angs[i];
      Color novaCor = Pallete.branco;
      switch (i) {
        case 0: novaCor = Pallete.azulCla; break;
        case 1: novaCor = Pallete.verdeCla; break;
        case 2: novaCor = Pallete.amarelo; break;
        case 3: novaCor = Pallete.vermelho; break;
      }

      double newAngle = angleRad + angleOffset;

      double tempoRestante = (chargeTime + fireTime) - _timer;
      if (tempoRestante <= 0) tempoRestante = 0.1;

      gameRef.world.add(LaserBeam(
        position: hitPos.clone(), 
        angleRad: newAngle,
        damage: damage,
        length: maxLength,
        chargeTime: 0, 
        fireTime: tempoRestante, 
        owner: owner,
        isEnemyProjectile: isEnemyProjectile,
        cor: novaCor,
        refratado: true
      ));
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollision(intersectionPoints, other);
    final hitPos = intersectionPoints.firstOrNull ?? position;
    
    if(_canDamageThisFrame){
      if (isEnemyProjectile) {
        if (other is Player) {
          createExplosionEffect(gameRef.world, hitPos, cor, count: 15);
          other.takeDamage(1); 
        }
      } 
      else {
        if (other is Enemy) {
          target ??= other;
          createExplosionEffect(gameRef.world, hitPos, cor, count: 15);
          other.takeDamage(damage, critico: critico);
          if(isBurn)other.setBurn();
          if(isFreeze)other.setFreeze();
          if(isPoison)other.setPoison(alastra: gameRef.player.isPoisonAlastra || gameRef.player.tempPoisonAlastra);
          if(isBleed)other.setBleed();
          if(isCharm)other.setCharm();
          if(isParalised)other.setParalise();
          if(isFear)other.setFear();

          if (chainCount < maxChains && chains) {
            final nextEnemy = _findNextTarget(other);
            if (nextEnemy != null) {
              final direction = nextEnemy.absoluteCenter - other.absoluteCenter;
              final angleToNext = atan2(direction.y, direction.x);
              
              gameRef.world.add(LaserBeam(
                position: other.absoluteCenter.clone(),
                angleRad: angleToNext,
                damage: damage * 0.8,
                chains: true,
                chainCount: chainCount + 1,
                maxChains: maxChains,
                fireTime: 0.15,
                chargeTime: 0,
                cor: Pallete.azulCla,
                larguraLaser: larguraLaser * 0.9,
                owner: null,
                refratado: true,
              ));
            }
          }
        }
      } 
      
      if (other is ScreenHitbox) {
        createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
      }
      
      if (other is Wall) {
        other.vida--;
        if (other.vida <= 0) other.removeFromParent();
        createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
      }
    }
  }
}