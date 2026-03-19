import 'dart:math';

import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
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
  freeze
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

  final Set<PositionComponent> _slowedEntities = {};

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
      default:
        icon = MdiIcons.fire;
        cor = Pallete.branco.withOpacity(0.7);
    }


    visual=GameIcon(
      icon: icon,
      color: cor, 
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(visual!);

    visual!.angle = ang;

    if(type == FamiliarType.freeze){
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
        speed = 4;
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

    }else{
      if (dist > followDistance) {
        final direction = (playerPos - position).normalized();
        position += direction * speed * dt;
      }

      if(type == FamiliarType.atira || type == FamiliarType.turret){
        _handleAutoAttack(dt);
      }
    }

    if (type == FamiliarType.freeze) {
      final List<PositionComponent> toRemove = [];

      for (final entity in _slowedEntities) {
        // 1. Se o inimigo ou tiro morreu/foi destruído, apenas removemos da lista
        if (!entity.isMounted) {
          toRemove.add(entity);
          continue;
        }

        // 2. Calcula a distância real entre os centros
        double distance = absoluteCenter.distanceTo(entity.absoluteCenter);

        // 3. Se ele saiu do círculo (colocamos +10 de margem para o efeito não "piscar" na borda)
        if (distance > detectRadius + 10.0) {
          
          // Devolve a velocidade normal
          if (entity is Enemy){
            entity.freezeTimer = entity.freezeDuration;
            
            //print('saiu freeze $distance - $detectRadius ');
            // entity.speed *= 2.0;
          }
          if (entity is Projectile) entity.speed *= 2.0;
          
          toRemove.add(entity); // Marca para remover da lista
        }
      }

      // Limpa todos os que saíram ou morreram
      _slowedEntities.removeAll(toRemove);
    }

  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // --- DESENHO DA AURA DE GELO ---
    if (type == FamiliarType.freeze) {
      final center = Offset(size.x / 2, size.y / 2);
      
      // Fundo azul clarinho transparente
      final fillPaint = Paint()
        ..color = Pallete.azulCla.withOpacity(0.1)
        ..style = PaintingStyle.fill;
        
      // Borda azul mais forte
      final borderPaint = Paint()
        ..color = Pallete.azulCla.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, detectRadius, fillPaint);
      canvas.drawCircle(center, detectRadius, borderPaint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if(type == FamiliarType.fly && other is Enemy && !other.isIntangivel){
      other.takeDamage(gameRef.player.damage * 2);
      retorna = false;
      removeFromParent();
    }
    if (type == FamiliarType.freeze) {
      if (!_slowedEntities.contains(other)) {
        
        if (other is Enemy) {
          //other.speed *= 0.5; 
          other.setFreeze();
          _slowedEntities.add(other);
        } 
        else if (other is Projectile && other.isEnemyProjectile) {
          other.speed *= 0.5;
          _slowedEntities.add(other);
        }
        
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    // --- LÓGICA DE ENTRAR NA AURA ---
    
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
    double aRange = 1.0;

    
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
      for (final entity in _slowedEntities) {
        if (entity is Enemy) entity.speed *= 2.0;
        if (entity is Projectile) entity.speed *= 2.0;
      }
      _slowedEntities.clear();
    }
    super.onRemove();
  }

}