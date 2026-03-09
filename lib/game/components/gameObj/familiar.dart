import 'dart:math';

import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/projectiles/projectile.dart';
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
  atira
}

class Familiar extends PositionComponent with HasGameRef<TowerGame> {
  double followDistance = 0;//120.0; 
  double speed = 0; 
  final FamiliarType type;
  final Vector2 _tempDirection = Vector2.zero(); 
  double _attackTimer = 0;
  double fireRate = 2;
  final Player player;
  double offsetX;
  double offsetY;

  Familiar({
    required Vector2 position ,
    required this.type,
    required this.player,
    this.followDistance = 50,
    this.speed = 200.0,
    this.offsetX = 0,
    this.offsetY = 0,
    }) : super(position: position , size: Vector2.all(32), anchor: Anchor.center) {
    priority = 10; 
  }

  @override
  Future<void> onLoad() async {

    IconData icon;
    Color cor;  

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
    }


    add(GameIcon(
      icon: icon,
      color: cor, 
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final playerPos = gameRef.player.position  + Vector2(offsetX,offsetY) ;
    final dist = position.distanceTo(playerPos);

    if (dist > followDistance) {
      final direction = (playerPos - position).normalized();
      position += direction * speed * dt;
    }

    if(type == FamiliarType.atira){
      _handleAutoAttack(dt);
    }
  }

  void _handleAutoAttack(double dt) {
    _attackTimer += dt;
    double fRate = fireRate;
    if (_attackTimer < fRate) return;

    final enemies = gameRef.world.children.query<Enemy>();
    Enemy? target;
    double closestDist = double.infinity;//attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (/* dist <= attackRange && */ dist < closestDist) {
        closestDist = dist;
        target = enemy;
      }
    }

    if (target != null) {
      _attackTimer = 0;
      _shootAt(target);
      
      
    }
  }

  void _shootAt(Enemy target, {double angleOffset = 0}) {
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

}