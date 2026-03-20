import 'dart:math';

import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/gameObj/wall.dart';
import 'package:TowerRogue/game/components/projectiles/projectile.dart';
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
}

class Familiar extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  GameIcon? visual;
  double followDistance;//120.0; 
  double speed; 
  final FamiliarType type;
  final Vector2 _tempDirection = Vector2.zero(); 
  double _attackTimer = 0;
  double fireRate;
  final Player player;
  double offsetX;
  double offsetY;
  double detectRadius = 600;
  bool retorna;

  double _currentAngle = 0;
  double radius;
  final double angleOffset; 
  
  PositionComponent? target;

  final Set<PositionComponent> _entitiesList = {};

  Vector2 _velocity = Vector2.zero();

  double _colorTimer = 0;
  final double _colorChangeInterval = 0.2;

  final bool noVisual;

  double _dmgTmr = 0;

  Familiar({
    required Vector2 position ,
    required this.type,
    required this.player,
    this.followDistance = 50,
    this.speed = 100.0,
    this.offsetX = 0,
    this.offsetY = 0,
    this.angleOffset = 0, 
    this.retorna = true,
    this.fireRate = 2,
    this.radius = 32,
    this.noVisual = false,
    }) : super(position: position , size: Vector2.all(32), anchor: Anchor.center) {
    priority = 10; 
  }

  @override
  Future<void> onLoad() async {

    _currentAngle = angleOffset;

    IconData icon;
    Color cor;  
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
      case FamiliarType.fly:
        icon = MdiIcons.candy;
        cor = Pallete.amarelo.withOpacity(0.7);
        detectRadius = 150;
        speed = 4;
        size = Vector2.all(16);
        ang = pi/4;
      case FamiliarType.turret:
        icon = MdiIcons.towerFire;
        cor = Pallete.vermelho.withOpacity(0.7);
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
      case FamiliarType.bouncer:
        speed = 150;
        icon = MdiIcons.weatherTornado;
        cor = Pallete.branco.withOpacity(0.7);
      case FamiliarType.eye:
        icon = MdiIcons.eyeCircle;
        radius = 48;
        speed = 3;
        cor = Pallete.rosa.withOpacity(0.7);
        fireRate = 0.5;
      case FamiliarType.prisma:
        icon = MdiIcons.triangle;
        radius = 64;
        speed = 2;
        cor = Pallete.branco.withOpacity(0.7);
      default:
        icon = MdiIcons.fire;
        cor = Pallete.branco.withOpacity(0.7);
    }

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

    if(type == FamiliarType.block && speed !=  player.moveSpeed){
      speed = player.moveSpeed;
    }

    if(type == FamiliarType.fly){
      
      PositionComponent? target = getTarget();
    
      if (target != null) {
        speed = 150;
        final targetPos = target.position;
        final direction = (targetPos - position).normalized();
        position += direction * speed * dt;
      }else{
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

    }else if(type == FamiliarType.eye || type == FamiliarType.prisma){
      _currentAngle += speed * dt;
      
        double centerX;
        double centerY;

        centerX = playerPos.x;
        centerY = playerPos.y;

        // Cálculo da nova posição
        final newX = centerX + cos(_currentAngle) * radius;
        final newY = centerY + sin(_currentAngle) * radius;
        
        position.setValues(newX, newY);

        if(type == FamiliarType.eye)_handleAutoAttack(dt);
    
    }else if(type == FamiliarType.glitch || type == FamiliarType.dmgBuff || type == FamiliarType.bouncer){
      if (_velocity == Vector2.zero()) {
        final rng = Random();
        double angle = rng.nextDouble() * 2 * pi;
        _velocity = Vector2(cos(angle), sin(angle)) * speed;
      }
      
      position += _velocity * dt;
      _checkBounds();

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
      position = player.position.clone() + player.velocityDash.normalized() * 50;
      angle = atan2(player.velocityDash.y, player.velocityDash.x);
    }else{
      if (dist > followDistance) {
        final direction = (playerPos - position).normalized();
        position += direction * speed * dt;
      }

      if(type == FamiliarType.atira || type == FamiliarType.turret){
        _handleAutoAttack(dt);
      }
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
              entity.takeDamage(player.damage/2,critico: false);
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

  void _checkBounds() {
    double limitX = TowerGame.gameWidth/2 - size.x;
    double limitY = TowerGame.gameHeight/2 - size.y;

    double arenaBorder = 10;

    double rightLimit = limitX - arenaBorder;
    double leftLimit = -limitX + arenaBorder;
    double topLimit = -limitY + arenaBorder;
    double bottomLimit = limitY - arenaBorder;

    if (position.x >= rightLimit) {
      _velocity.x = -_velocity.x.abs(); 
      position.x = rightLimit;      
    } 
    else if (position.x <= leftLimit) {
      _velocity.x = _velocity.x.abs();  
      position.x = leftLimit;       
    }

    if (position.y >= bottomLimit) {
      _velocity.y = -_velocity.y.abs(); 
      position.y = bottomLimit;     
    } 
    else if (position.y <= topLimit) {
      _velocity.y = _velocity.y.abs();  
      position.y = topLimit;        
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // --- DESENHO DA AURA DE GELO ---
    if (type == FamiliarType.freeze || type == FamiliarType.dmgBuff || type == FamiliarType.circProt) {
      final center = Offset(size.x / 2, size.y / 2);

      Color cor = visual!.color;
      
      // Fundo azul clarinho transparente
      final fillPaint = Paint()
        ..color = cor.withOpacity(0.1)
        ..style = PaintingStyle.fill;
        
      // Borda azul mais forte
      final borderPaint = Paint()
        ..color = cor.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, detectRadius, fillPaint);
      canvas.drawCircle(center, detectRadius, borderPaint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(type == FamiliarType.fly &&  other is Enemy && !other.isIntangivel){
      other.takeDamage(gameRef.player.damage * 2);
      retorna = false;
      removeFromParent();
    }
    if(type == FamiliarType.eye && type == FamiliarType.bouncer && type == FamiliarType.finger &&  other is Enemy && !other.isIntangivel){
      other.takeDamage(gameRef.player.damage);
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

    if(type == FamiliarType.glitch){
      if(other is Enemy){
        setRndStatus(other);
      }
      if (other is Wall) {
        final myRect = toAbsoluteRect();
        final otherRect = other.toAbsoluteRect();
        final intersection = myRect.intersect(otherRect);

        if (intersection.width < intersection.height) {
          if (_velocity.x > 0 && position.x < other.position.x) {
              _velocity.x = -_velocity.x; 
          }
          else if (_velocity.x < 0 && position.x > other.position.x) {
              _velocity.x = -_velocity.x; 
          }
        } else {
          if (_velocity.y > 0 && position.y < other.position.y) {
              _velocity.y = -_velocity.y; 
          }
          else if (_velocity.y < 0 && position.y > other.position.y) {
              _velocity.y = -_velocity.y; 
          }
        }
      }
    }
    if(type == FamiliarType.prisma){
      if(other is Projectile && !other.isEnemyProjectile){
        other.refrata();
      }
    }
    
  }

  PositionComponent? getTarget(){
    final enemies = gameRef.world.children.query<Enemy>();
    PositionComponent? target ;
    double closestDist = double.infinity;//attackRange;

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
    
    if (target != null) {
      _attackTimer = 0;
      _shootAt(target);
    }
  }

  void _shootAt(PositionComponent target, {double angleOffset = 0}) {
    // Calculo da direção livre de lixo de memória
    _tempDirection.setFrom(target.position);
    _tempDirection.sub(position);
    _tempDirection.normalize();

    double x = _tempDirection.x * cos(angleOffset) - _tempDirection.y * sin(angleOffset);
    double y = _tempDirection.x * sin(angleOffset) + _tempDirection.y * cos(angleOffset);
    _tempDirection.setValues(x, y);

    double dmg = player.damage;
   //double aRange = 1.0;

    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: _tempDirection.clone(), 
      damage: dmg, 
      speed: 500,
      size: Vector2.all(10),
      iniPosition: position.clone(),
    ));
  }

  @override
  void onRemove() {
    // Garante que todos voltem ao normal caso o familiar seja destruído
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

}