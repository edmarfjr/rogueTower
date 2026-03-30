import 'dart:math';

import 'package:towerrogue/game/components/effects/explosion_effect.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/gameObj/wall.dart';
import 'package:towerrogue/game/components/projectiles/laser_beam.dart';
import 'package:towerrogue/game/components/projectiles/mortar_shell.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';

enum FamiliarType {
  decoy,
  block,
  atira,
  fly,
  turret,
  freeze,
  glitch,
  dmgBuff,
  circProt,
  finger,
  bouncer,
  eye,
  prisma,
  refletor,
  dummy,
  gemini,
  aranha,
  turretRotate,
  lanca,
}

class Familiar extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  GameIcon? visual;
  double followDistance;//120.0; 
  double speed; 
  final FamiliarType type;
  final Vector2 _tempDirection = Vector2.zero(); 
  double _attackTimer = 0;
  double fireRate;
  double _meleeTimer = 0;
  double meleeRate;
  bool rotateShot = false;
  double rotateAng = 0;
  bool multiShot = false;
  int multiShotNumber = 8;
  final Player player;
  double offsetX = 0;
  double offsetY = 0;
  double offX = 0;
  double offY = 0;
  double detectRadius = 600;
  bool retorna;

  double _currentAngle = 0;
  double radius;
  double angleOffset; 

  double dmg = 10;
  
  PositionComponent? target;

  final Set<PositionComponent> _entitiesList = {};

  Vector2 velocity = Vector2.zero();

  double _colorTimer = 0;
  final double _colorChangeInterval = 0.2;

  final bool noVisual;

  double _dmgTmr = 0;

  // Variáveis de Animação
  double _walkTimer = 0;
  final double _bounceSpeed = 15.0;     
  final double _bounceAmplitude = 0.15;

  //status dummy
  bool noDamage = false;
  bool isOrbitalShot = false;
  bool isHeavyShot = false;
  bool isWave = false;
  bool isSaw = false;
  bool isBoomerang = false;
  bool hasAntimateria = false;
  bool isHoming = false;
  bool canBounce = false;
  bool isSpectral = false;
  bool isPiercing = false;
  bool isShootSplits = false;
  bool goldShot = false;
  double aRange = 1.0;
  bool isLaser = false;
  bool isMorteiro = false;

  //corrente do gemini
  final List<ChainNode> _chainNodes = []; 
  final int _numLinks = 8; 
  final double _targetLinkLength = 16.0; 
  final double _gravity = 80.0; 

  // --- VARIÁVEIS DE KNOCKBACK ---
  final Vector2 knockbackVelocity = Vector2.zero();
  final double _knockbackFriction = 1500.0;

  //variaveis random wander
  final Vector2 _target = Vector2.zero();
  final Vector2 _direction = Vector2.zero();
  double moveTmr = 0;
  double moveDur = 2; 
  final Random _rng = Random();

  Familiar({
    required Vector2 position ,
    required this.type,
    required this.player,
    this.followDistance = 50,
    this.speed = 100.0,
    this.offX = 0,
    this.offY = 0,
    this.angleOffset = 0, 
    this.retorna = true,
    this.fireRate = 2,
    this.radius = 32,
    this.noVisual = false,
    this.meleeRate = 0.3,
    }) : super(position: position , size: Vector2.all(32), anchor: Anchor.center) {
    priority = 10; 
  }

  @override
  Future<void> onLoad() async {

    IconData icon = MdiIcons.fire;
    Color cor = Pallete.branco;
    double ang = 0;

    switch(type){
      case FamiliarType.decoy:
        icon = Icons.directions_walk;
        cor = Pallete.cinzaCla.withOpacity(0.7);
      case FamiliarType.block:
        icon = MdiIcons.fire;
        cor = Pallete.azulCla.withOpacity(0.7);
      case FamiliarType.atira:
        icon = MdiIcons.fire;
        cor = Pallete.vermelho.withOpacity(0.7);
        dmg = player.damage / 2 ;
        followDistance = 30;
        offsetY = -32;
        offsetX = -16; 
      case FamiliarType.fly:
        icon = MdiIcons.candy;
        cor = Pallete.amarelo.withOpacity(0.7);
        detectRadius = 150;
        speed = 4;
        size = Vector2.all(16);
        ang = pi/4;
        dmg = player.damage * 3 ;
      case FamiliarType.turret:
        icon = MdiIcons.floorLampTorchiereVariant;
        cor = Pallete.vermelho.withOpacity(0.7);
        dmg = player.damage ;
      case FamiliarType.turretRotate:
        icon = MdiIcons.floorLampTorchiereVariant;
        cor = Pallete.azulCla.withOpacity(0.7);
        dmg = player.damage;
        fireRate = player.fireRate;
        hasAntimateria = player.hasAntimateria;
        canBounce      = player.canBounce;
        isSpectral     = player.isSpectral;
        isPiercing     = player.isPiercing;
        isShootSplits  = player.isShootSplits;
        goldShot       = player.goldShot;
        rotateShot = true;
      case FamiliarType.freeze:
        detectRadius = 100;
        icon = MdiIcons.snowflake;
        cor = Pallete.azulCla.withOpacity(0.7);
      case FamiliarType.glitch:
        speed = 150;
        icon = MdiIcons.circleOpacity;
        cor = Pallete.azulCla.withOpacity(0.7);
      case FamiliarType.dmgBuff:
        speed = 80;
        detectRadius = 80;
        icon = MdiIcons.satelliteVariant;
        cor = Pallete.vermelho.withOpacity(0.7);
      case FamiliarType.circProt:
        speed = 200;
        detectRadius = 60;
        icon = MdiIcons.circleDouble;
        cor = Pallete.branco.withOpacity(0.7);
        followDistance = 0;
      case FamiliarType.finger:
        icon = MdiIcons.handPointingRight;
        cor = Pallete.bege.withOpacity(0.7);
        dmg = player.damage/10;
        fireRate = 0.6;
      case FamiliarType.bouncer:
        speed = 150;
        icon = MdiIcons.weatherTornado;
        cor = Pallete.branco.withOpacity(0.7);
        dmg = player.damage * 2 ;
      case FamiliarType.eye:
        icon = MdiIcons.eyeCircle;
        radius = 48;
        speed = 3;
        cor = Pallete.rosa.withOpacity(0.7);
        fireRate = 0.5;
        dmg = player.damage / 2 ;
      case FamiliarType.prisma:
        icon = MdiIcons.triangle;
        radius = 64;
        speed = 2;
        cor = Pallete.branco.withOpacity(0.7);
      case FamiliarType.refletor:
        icon = MdiIcons.mirrorVariant;
        radius = 64;
        speed = 2;
        cor = Pallete.cinzaCla.withOpacity(0.7);
      case FamiliarType.dummy:
        followDistance = 100;
        icon = MdiIcons.humanMale;
        cor = Pallete.bege;
        dmg = player.damage;
        fireRate = player.fireRate;
        speed = player.moveSpeed;
        noDamage       = player.noDamage;
        isOrbitalShot  = player.isOrbitalShot;
        isHeavyShot    = player.isHeavyShot;
        isWave         = player.isWave;
        isSaw          = player.isSaw;
        isBoomerang    = player.isBoomerang;
        hasAntimateria = player.hasAntimateria;
        isHoming       = player.isHoming;
        canBounce      = player.canBounce;
        isSpectral     = player.isSpectral;
        isPiercing     = player.isPiercing;
        isShootSplits  = player.isShootSplits;
        goldShot       = player.goldShot;
        aRange = player.attackRange;
        isLaser = player.isLaser;
        isMorteiro = player.isMorteiro;
      case FamiliarType.gemini:
        icon = Icons.directions_walk;
        detectRadius = 200;
        speed = 150;
        cor = Pallete.branco.withOpacity(0.7);

        final Vector2 startPos = gameRef.player.absoluteCenter;
        final Vector2 endPos = absoluteCenter;
        
        for (int i = 0; i < _numLinks; i++) {
          // Cria nós interpolados em linha reta no início
          double progress = i / (_numLinks - 1);
          Vector2 nodePos = startPos + (endPos - startPos) * progress;
          _chainNodes.add(ChainNode(nodePos));
        }
      case FamiliarType.aranha:
        icon = MdiIcons.spider;
        dmg = player.damage * 2 ;
        size = Vector2.all(24);
        detectRadius = 200;
        speed = 150;
        moveDur = 0.5;
        cor = Pallete.azulCla.withOpacity(0.7);
      case FamiliarType.lanca:
        icon = MdiIcons.spear;
        cor = Pallete.cinzaCla.withOpacity(0.7);
        dmg = player.damage * 2;
        fireRate = 0.6;
        ang = pi/4;
      //default:
      //  icon = MdiIcons.fire;
      //  cor = Pallete.branco.withOpacity(0.7);
    }
    
    _currentAngle = angleOffset;

    offsetX += offX;
    offsetY += offY;

    if(!noVisual){
      visual=GameIcon(
        icon: icon,
        color: cor, 
        size: size,
        anchor: Anchor.center,
        position: size / 2,
      );

      add(visual!);
      visual!.angle = ang;
    }
    
    if(type == FamiliarType.freeze || type == FamiliarType.circProt){
      add(CircleHitbox(
          radius: detectRadius,
          anchor: Anchor.center,
          position: size / 2, // Centrado no familiar
          isSolid: true, // Falso para não bloquear o movimento físico de ninguém!
        ));
    }else{
      add(RectangleHitbox(
        size: size , 
        anchor: Anchor.center,
        position: size / 2 , 
        isSolid: true,
      ));
    }
    
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPos = gameRef.player.position  + Vector2(offsetX,offsetY) ;
    final dist = position.distanceTo(playerPos);
    PositionComponent? target = getTarget();

    if(type == FamiliarType.block && speed !=  player.moveSpeed){
      speed = player.moveSpeed;
    }

    if(type == FamiliarType.fly){
      _animateMovement(dt);
      
      if (target != null) {
        speed = 150;
        segueAlvo(dt,target);
      }else{
        speed = 4;
        orbitar(dt,playerPos);
      }

    }else if(type == FamiliarType.gemini) {
      const double maxTetherDistance = 250.0; 
      _handleKnockBack(dt);

      if(knockbackVelocity.isZero()){
        if (target != null && dist < maxTetherDistance) {
          _animateMovement(dt);
          segueAlvo(dt, target);
        } else {
          if (dist > followDistance) {
            _animateMovement(dt);
            segueAlvo(dt, player);
          }
        }
      }

      _handleChains(dt);
    }else if(type == FamiliarType.aranha) {
      _handleKnockBack(dt);
      _animateMovement(dt);
  
      if(knockbackVelocity.isZero()){
        if (target != null) {
          segueAlvo(dt,target);
        } else {
          moveAleatorio(dt);
        }
      }
    }else if(type == FamiliarType.eye || type == FamiliarType.prisma || type == FamiliarType.refletor){
      orbitar(dt,playerPos);

      if(type == FamiliarType.eye)_handleAutoAttack(dt);
    
    }else if(type == FamiliarType.glitch || type == FamiliarType.dmgBuff || type == FamiliarType.bouncer){
      _animateMovement(dt);
      moveBounce(dt);

      if (visual != null && type == FamiliarType.glitch) {
        _colorTimer += dt;
        
        if (_colorTimer >= _colorChangeInterval) {
          
          _colorTimer = 0;

          List<Color> cores=[
            Pallete.vermelho,
            Pallete.azulCla,
            Pallete.verdeCla,
            Pallete.rosa,
            Pallete.lilas,
            Pallete.amarelo,
            Pallete.laranja,
            Pallete.cinzaCla,
            Pallete.branco,
            Pallete.marrom,
            Pallete.bege,
            Pallete.vinho,
            Pallete.verdeEsc,
          ];
          
          final rng = Random();
          Color cor = cores[rng.nextInt(cores.length)];

          visual!.setColor(cor);
        }
      }
    }else if(type == FamiliarType.circProt){
      position = player.position.clone();
    }else if(type == FamiliarType.finger){
      velocity = player.velocity;
      position = player.position.clone() + player.velocityDash.normalized() * 50;
      angle = atan2(player.velocityDash.y, player.velocityDash.x);
      criaLaserDirecional(dt, Vector2(cos(angle),sin(angle)),dmg,0,fireRate,50);

    }else if(type == FamiliarType.lanca){
      velocity = player.velocity;
      position = player.position.clone() + player.lastAttackDirection.normalized() * 50;
      angle = atan2(player.lastAttackDirection.y, player.lastAttackDirection.x);
    }else{
      if (dist > followDistance) {
        _animateMovement(dt);
        segueAlvo(dt, player);
      }

      if(type == FamiliarType.atira || type == FamiliarType.turret || type == FamiliarType.turretRotate|| type == FamiliarType.dummy){
        _handleAutoAttack(dt);
      }
    }

    //familiares melee
    if(type == FamiliarType.eye || type == FamiliarType.bouncer || type == FamiliarType.lanca
     || type == FamiliarType.gemini){
        _meleeTimer += dt;
     }
    

    if (type == FamiliarType.freeze || type == FamiliarType.circProt) {
      final List<PositionComponent> toRemove = [];

      for (final entity in _entitiesList) {
        if (!entity.isMounted) {
          toRemove.add(entity);
          continue;
        }
        if (type == FamiliarType.circProt){
          _dmgTmr += dt;
          if(_dmgTmr >= 1.0){
            if (entity is Enemy){
              _dmgTmr = 0;
              entity.takeDamage(dmg*gameRef.player.familiarDmg,critico: false);
            }
          }
        }

        double distance = absoluteCenter.distanceTo(entity.absoluteCenter);

        if (distance > detectRadius + 10.0) {
          if (type == FamiliarType.freeze){
            if (entity is Enemy){
              entity.freezeTimer = entity.freezeDuration;
            }
            if (entity is Projectile) entity.speed *= 2.0;
          }
          
          
          toRemove.add(entity); 
        }
      }
      _entitiesList.removeAll(toRemove);
    }
    if (type == FamiliarType.dmgBuff) {
      double distance = absoluteCenter.distanceTo(player.absoluteCenter);
      if (distance > detectRadius + 10.0) {
        player.dmgBuff = false;
      }
    }

  }

  void segueAlvo(double dt, PositionComponent? alvo){
    final targetPos = alvo!.position;
    final direction = (targetPos - position).normalized();
    position += direction * speed * dt;
  }

  void orbitar(double dt, Vector2 playerPos){
    _currentAngle += speed * dt;

    double centerX;
    double centerY;

    centerX = playerPos.x;
    centerY = playerPos.y;

    // Cálculo da nova posição
    final newX = centerX + cos(_currentAngle) * radius;
    final newY = centerY + sin(_currentAngle) * radius;

    position.setValues(newX, newY);
  }

  void moveAleatorio(double dt){
    if (_target == Vector2.zero() || position.distanceTo(_target) < 10 || moveTmr >= moveDur) {
      moveTmr = 0;
      _pickNewTarget();
    }
    _direction
      ..setFrom(_target)       
      ..sub(position)    
      ..normalize();

    moveTmr += dt;

    if (visual != null) {
      visual!.angle = atan2(_direction.y, _direction.x) + angleOffset;
    }  

    position.addScaled(_direction, speed * dt);
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
        position.x + cos(finalAngle) * dist,
        position.y + sin(finalAngle) * dist,
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

  void moveBounce(double dt){
    if (velocity == Vector2.zero()) {
      final rng = Random();
      double angle = rng.nextDouble() * 2 * pi;
      velocity = Vector2(cos(angle), sin(angle)) * speed;
    }
    
    position += velocity * dt;
    _checkBounds();
  }

  void _checkBounds() {
    double limitX = TowerGame.gameWidth/2 - size.x;
    double limitY = TowerGame.gameHeight/2 - size.y;

    double arenaBorder = 10;

    double rightLimit = limitX - arenaBorder;
    double leftLimit = -limitX + arenaBorder;
    double topLimit = -limitY + arenaBorder;
    double bottomLimit = limitY - arenaBorder;

    if (position.x >= rightLimit) {
      velocity.x = -velocity.x.abs(); 
      position.x = rightLimit;      
    } 
    else if (position.x <= leftLimit) {
      velocity.x = velocity.x.abs();  
      position.x = leftLimit;       
    }

    if (position.y >= bottomLimit) {
      velocity.y = -velocity.y.abs(); 
      position.y = bottomLimit;     
    } 
    else if (position.y <= topLimit) {
      velocity.y = velocity.y.abs();  
      position.y = topLimit;        
    }
  }

  void _animateMovement(double dt) {
    double facingDirection = visual!.scale.x.sign; 
    if (velocity.x < -0.1) facingDirection = -1.0;
    if (velocity.x > 0.1) facingDirection = 1.0;

    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

    if (!velocity.isZero()) {
      _walkTimer += dt * _bounceSpeed;

      double wave = sin(_walkTimer);
      currentScaleY = 1.0 + (wave * _bounceAmplitude); 
      currentScaleX = 1.0 - (wave * _bounceAmplitude * 0.5); 
      currentAngle = cos(_walkTimer) * 0.1; 
      
    } else {
      _walkTimer = 0;
    }

    visual!.scale.setValues(facingDirection * currentScaleX, currentScaleY);
    visual!.angle = currentAngle; 

  }

  @override
  void render(Canvas canvas) {
    if (type == FamiliarType.freeze || type == FamiliarType.dmgBuff || type == FamiliarType.circProt) {
      final center = Offset(size.x / 2, size.y / 2);

      Color cor = visual!.color;
      
      final fillPaint = Paint()
        ..color = cor.withOpacity(0.1)
        ..style = PaintingStyle.fill;
        
      final borderPaint = Paint()
        ..color = cor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, detectRadius, fillPaint);
      canvas.drawCircle(center, detectRadius, borderPaint);
    }
    if (type == FamiliarType.gemini ) {
      if (_chainNodes.isEmpty) {
        super.render(canvas);
        return;
      }

      // --- RENDERIZAÇÃO DA CORRENTE DINÂMICA (Segmentada) ---
      final paintChain = Paint()
        ..color = Pallete.branco.withOpacity(0.7) // Uma cor mais clara para o reflexo do metal
        //..style = PaintingStyle.fill;
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      for (int i = 0; i < _chainNodes.length - 1; i++) {
        /* //desenhar circulos
        final node = _chainNodes[i];
        Vector2 localPos = absoluteToLocal(node.position);
        final centerOffset = Offset(localPos.x, localPos.y);
        canvas.drawCircle(centerOffset, 4, paintChain);
        */
        // desenhar linhas
        final A = _chainNodes[i];
        final B = _chainNodes[i + 1];
        Vector2 localA = absoluteToLocal(A.position);
        Vector2 localB = absoluteToLocal(B.position);
        final start = Offset(localA.x, localA.y);
        final end = Offset(localB.x, localB.y);
        canvas.drawLine(start, end, paintChain..strokeCap = StrokeCap.round);
      }
    }

    super.render(canvas);
  }

  void setKnockBack(other) {
    Vector2 knockbackDir = (position - other.position).normalized();
          
    double forcaDoEmpurrao = 150.0; 

    knockbackVelocity.setFrom(knockbackDir * forcaDoEmpurrao * 2);
  
    if(other is Enemy)other.knockbackVelocity.setFrom(-knockbackDir * forcaDoEmpurrao);
  }

  void _handleKnockBack(double dt) {
    if (!knockbackVelocity.isZero()) {
      // 1. Move o personagem na direção do empurrão
      position.addScaled(knockbackVelocity, dt);
      
      // 2. Aplica o atrito (freio)
      double drop = _knockbackFriction * dt;
      if (knockbackVelocity.length > drop) {
        // Reduz a velocidade mantendo a mesma direção
        knockbackVelocity.setFrom(knockbackVelocity - knockbackVelocity.normalized() * drop);
      } else {
        // Parou completamente
        knockbackVelocity.setZero();
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if((type == FamiliarType.fly || type == FamiliarType.aranha) &&  other is Enemy && !other.isIntangivel){
      other.takeDamage(dmg*gameRef.player.familiarDmg);
      retorna = false;
      createExplosionEffect(gameRef.world, absoluteCenter, visual!.color, count: 6);
      removeFromParent();
    }
    if(other is Enemy && !other.isIntangivel && (type == FamiliarType.eye || type == FamiliarType.bouncer || type == FamiliarType.lanca
     || type == FamiliarType.gemini) && _meleeTimer >= meleeRate){
      _meleeTimer = 0;
      other.takeDamage(dmg*gameRef.player.familiarDmg);
      setKnockBack(other);
    }
    if (type == FamiliarType.freeze || type == FamiliarType.circProt) {
      if (!_entitiesList.contains(other)) {
        
        if (other is Enemy) {
          //other.speed *= 0.5; 
          if (type == FamiliarType.freeze)other.setFreeze();
          _entitiesList.add(other);
        } 
        else if (other is Projectile && other.isEnemyProjectile) {
          if (type == FamiliarType.freeze){
            other.speed *= 0.5;
            _entitiesList.add(other);
          }else{
            double rnd = Random().nextDouble();
            if(rnd <= 0.3)other.refletir();
          }
        }
        
      }
    }
    if (type == FamiliarType.dmgBuff) {
      if(other is Player){
        other.dmgBuff = true;
      }
    }
    
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if(type == FamiliarType.glitch || type == FamiliarType.bouncer){
      if(other is Enemy){
        if(type == FamiliarType.glitch)setRndStatus(other);
        if(type == FamiliarType.bouncer)bounceOf(other);
      }
      if (other is Wall) {
        bounceOf(other);
      }
    }
    if(type == FamiliarType.prisma){
      if(other is Projectile && !other.isEnemyProjectile){
        other.refrata();
      }
      if (other is LaserBeam) {
      final hitPos = intersectionPoints.firstOrNull ?? position;
      other.refrata(hitPos); 
    }
    }
    if(type == FamiliarType.refletor){
      if(other is Projectile && !other.isEnemyProjectile){
        other.refletir();
      }
    }
    
  }

  PositionComponent? getTarget(){
    final enemies = gameRef.world.children.query<Enemy>();
    PositionComponent? target ;
    double closestDist = double.infinity;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if ( dist <= detectRadius &&  dist < closestDist) {
        closestDist = dist;
        target = enemy;
      }
    }
    return target;
  }

  void _handleAutoAttack(double dt) {
    _attackTimer += dt;
    double fRate = fireRate;
    if (_attackTimer < fRate) return;

    PositionComponent? target = getTarget();
    
    if(multiShot){
      _attackTimer = 0;
      for (int i = 0; i < multiShotNumber; i++) {
        double angle = i*(2*pi/multiShotNumber); 
        Vector2 newDir = Vector2(cos(angle), sin(angle));
        criaTiro(newDir);
      }
    }else if(rotateShot){
        _attackTimer = 0;
        Vector2 newDir = Vector2(cos(rotateAng), sin(rotateAng));
        criaTiro(newDir);
        rotateAng += pi/4;
    }else{
       if (target != null) {
        _attackTimer = 0;
        if(isMorteiro){
          gameRef.world.add(MortarShell(
            startPos: position.clone(),
            targetPos: target.position.clone(),
            owner: this,
            flightDuration: 1,
            damage: dmg * 2 *gameRef.player.familiarDmg,
            isFire: true,
            explosionRadius: 100,
            isPlayer: true,
          ));
        }else if(isLaser){
          final dir = (target.position - position.clone()).normalized();
          final angle = atan2(dir.y, dir.x);
          criaLaser(dir,angle,target);
        }else{
          _shootAt(target);
        }
        
      }
    }
    
  }

  void criaLaser(Vector2 dir,ang,target)
  {
    
    gameRef.world.add(LaserBeam(
      position: position + (dir * 10),
      angleRad: ang,
      chargeTime: 0,
      fireTime: fireRate,
      owner: this,
      damage: dmg*gameRef.player.familiarDmg
    ));
  }

  void criaLaserDirecional(double dt, Vector2 dir,dmg,chargeTime,durTime,largura)
  {
    _attackTimer += dt;
    double fRate = fireRate;
    if (_attackTimer < fRate) return;
    _attackTimer = 0;
    final angle = atan2(dir.y, dir.x); 

    gameRef.world.add(LaserBeam(
      position: position + (dir * 10),
      angleRad: angle,
      larguraLaser: largura,
      length: 800,
      chargeTime: chargeTime,
      fireTime: durTime,
      followsOwnerMov: true,
      dmgTime: 0.2,
      owner: this,
      damage: dmg,
      invisivel: true,
      atravessa: true,
    ));
  }
  

  void _shootAt(PositionComponent target, {double angleOffset = 0}) {
    // Calculo da direção livre de lixo de memória
    _tempDirection.setFrom(target.position);
    _tempDirection.sub(position);
    _tempDirection.normalize();

    double x = _tempDirection.x * cos(angleOffset) - _tempDirection.y * sin(angleOffset);
    double y = _tempDirection.x * sin(angleOffset) + _tempDirection.y * cos(angleOffset);
    _tempDirection.setValues(x, y);

    criaTiro(_tempDirection);

   //double aRange = 1.0;

    /*
    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: _tempDirection.clone(), 
      damage: dmg, 
      speed: 500,
      size: Vector2.all(10),
      iniPosition: position.clone(),
    ));
    */
    
    
  }

  void criaTiro(dir){
    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: dir, 
      damage: noDamage? 0 : dmg*gameRef.player.familiarDmg, 
      speed: isOrbitalShot ? 4.0 : isHeavyShot ? 250 : isWave ? 350 : isSaw ? 50 : 500,
      size: isHeavyShot ? Vector2.all(30) : Vector2.all(10),
      dieTimer: isBoomerang ? 1.0 : isOrbitalShot ? 2 : isSaw ? aRange*1.5 : aRange,
      apagaTiros: hasAntimateria,
      isHoming: isHoming,
      iniPosition: position.clone(),
      canBounce: canBounce,
      isSpectral: isSpectral,
      isPiercing: isPiercing,
      isOrbital: isOrbitalShot,
      isBoomerang: isBoomerang,
      splits: isShootSplits,
      splitCount: Random().nextInt(3) + 1,
      goldShot: goldShot,
      isWave: isWave,        
      maxRadius: 150,      
      growthRate: 100,      
      sweepAngle: pi / 1.5, 
      isSaw: isSaw,
    ));
  }

  @override
  void onRemove() {
    if (type == FamiliarType.freeze) {
      for (final entity in _entitiesList) {
        if (entity is Enemy) entity.speed *= 2.0;
        if (entity is Projectile) entity.speed *= 2.0;
      }
      _entitiesList.clear();
    }
    super.onRemove();
  }
  
  void setRndStatus(Enemy other) {
    int rng = Random().nextInt(7);
    switch (rng){
      case 0:
        other.setBleed();
        break;
      case 1:
        other.setBurn();
        break;
      case 2:
        other.setFreeze();
        break;
      case 3:
        other.setConfuse();
        break;
      case 4:
        other.setCharm();
        break;
      case 5:
        other.setEncolhido();
        break;
      case 6:
        other.takeDamage(gameRef.player.damage*3);
        break;
    }    
  }
  
  void bounceOf(PositionComponent other) {
    final myRect = toAbsoluteRect();
    final otherRect = other.toAbsoluteRect();
    final intersection = myRect.intersect(otherRect);

    if (intersection.width < intersection.height) {
      if (velocity.x > 0 && position.x < other.position.x) {
          velocity.x = -velocity.x; 
      }
      else if (velocity.x < 0 && position.x > other.position.x) {
          velocity.x = -velocity.x; 
      }
    } else {
      if (velocity.y > 0 && position.y < other.position.y) {
          velocity.y = -velocity.y; 
      }
      else if (velocity.y < 0 && position.y > other.position.y) {
          velocity.y = -velocity.y; 
      }
    }
  }
  
  void _handleChains(double dt) {
    if (_chainNodes.isEmpty) return;

    // --- MÁGICA DA FÍSICA VERLET ---

    // 1. Fixar as Pontas
    // O primeiro nó está sempre preso ao centro absoluto do jogador
    _chainNodes.first.position.setFrom(gameRef.player.absoluteCenter);
    // O último nó está sempre preso ao centro absoluto do familiar
    _chainNodes.last.position.setFrom(absoluteCenter);

    // 2. Atualizar Nós Intermediários (Inércia + Gravidade)
    for (int i = 1; i < _chainNodes.length - 1; i++) {
      final node = _chainNodes[i];
      Vector2 velocity = node.position - node.oldPosition;
      
      // TRAVA DE SEGURANÇA 1: Impede que a corrente exploda se houver teleporte
      if (velocity.length > 50.0) {
        velocity.scaleTo(50.0); 
      }
      
      velocity.scale(0.97); // Fricção
      node.oldPosition.setFrom(node.position);
      node.position += velocity;
      node.position += Vector2(0, _gravity * dt * dt); 
    }

    // 3. Resolver Restrições (Satisfazer o comprimento fixo de cada elo)
    const int constraintIterations = 15;
    for (int iter = 0; iter < constraintIterations; iter++) {
      for (int i = 0; i < _chainNodes.length - 1; i++) {
        final A = _chainNodes[i];
        final B = _chainNodes[i + 1];

        Vector2 delta = B.position - A.position;
        double dist = delta.length;
        
        // TRAVA DE SEGURANÇA 2: Anti-divisão por zero
        if (dist <= 0.0001) {
          delta = Vector2(0.001, 0.0); 
          dist = delta.length;
        }

        // --- A MATEMÁTICA CORRIGIDA AQUI! ---
        // (Tamanho Ideal - Tamanho Atual) / Tamanho Atual
        double diffRatio = (_targetLinkLength - dist) / dist;
        
        // Vetor de translação exato que eles precisam se mover
        Vector2 translate = delta * diffRatio;

        bool aFixed = (i == 0);
        bool bFixed = (i + 1 == _chainNodes.length - 1);

        if (aFixed && !bFixed) {
          B.position += translate * 1.0; 
        } else if (!aFixed && bFixed) {
          A.position -= translate * 1.0; 
        } else if (!aFixed && !bFixed) {
          // Agora sim: empurra A para um lado e B para o outro CORRETAMENTE!
          A.position -= translate * 0.5;
          B.position += translate * 0.5;
        }
      }
    }
  }

}

class ChainNode {
  Vector2 position;
  Vector2 oldPosition; // Usado para calcular velocidade (Verlet)

  ChainNode(this.position) : oldPosition = position.clone();
}