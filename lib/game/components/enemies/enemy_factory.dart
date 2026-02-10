import 'dart:math';

import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:TowerRogue/game/components/projectiles/web.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'enemy.dart';
import 'enemy_behaviors.dart';
import '../core/pallete.dart';

class EnemyFactory {
  
  static Enemy createStandard(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 30,
      speed: 100,
      iconData: Icons.pest_control_rodent,
      originalColor: Pallete.vermelho,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),       
    );
  }

  static Enemy createShooter(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 20,
      speed: 50,
      iconData: Icons.adb,
      originalColor: Pallete.lilas,
      movementBehavior: KeepDistanceBehavior(minDistance: 150, maxDistance: 220),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),
    );
  }

  static Enemy createSpinner(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 25,
      speed: 50,
      iconData: Icons.sync,
      originalColor: Pallete.rosa,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 1.5),
    );
  }
  
  static Enemy createMortar(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 20,
      speed: 0,
      weight: 1000,
      iconData: Icons.fort,
      originalColor: Pallete.laranja,
      movementBehavior: KeepDistanceBehavior(minDistance: 250, maxDistance: 350),
      attackBehavior: MortarAttackBehavior(interval: 4.0),
    );
  }

  static Enemy createLaser(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 0,
      iconData: MdiIcons.ethereum,
      originalColor: Pallete.azulCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: LaserAttackBehavior(interval: 3.0),
    );
  }
  
  static Enemy createBouncer(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 20,
      speed: 120,
      weight:10,
      iconData: Icons.sports_baseball,
      originalColor: Pallete.verdeCla,
      movementBehavior: BouncerBehavior(),
      attackBehavior: NoAttackBehavior(), 
    );
  }

  static Enemy createDasher(Vector2 pos) {
     return Enemy(
      position: pos,
      hp: 40,
      speed: 80, 
      animado: false,
      iconData: Icons.navigation,
      originalColor: Pallete.amarelo,
      // Dasher é especial: o movimento é controlado pelo ataque
      movementBehavior: FollowPlayerBehavior(), 
      attackBehavior: DashAttackBehavior(),
    );
  }

  static Enemy createBee(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 10,
      speed: 100,
      voa: true,
      rotates: true,
      rotateOff: pi/4,
      iconData: MdiIcons.bee,
      originalColor: Pallete.amarelo,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),       
    );
  }

  static Enemy createBeeHive(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 35,
      speed: 0,
      weight: 2.0,
      iconData: MdiIcons.beehiveOutline,
      originalColor: Pallete.laranja,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SummonAttackBehavior(
        minionBuilder: (p) => EnemyFactory.createBee(p), 
        interval: 3.5, 
        maxMinions: 4,
      ),
      deathBehavior: SpawnOnDeathBehavior(
        count: 3,
        minionBuilder: (p) => EnemyFactory.createBee(p),
      ),
    );
  }

  static Enemy createCrazyShooter(Vector2 pos) {
    // Um inimigo que quica na parede (Bouncer) E atira (Shooter)
    return Enemy(
      position: pos,
      hp: 50,
      speed: 100,
      iconData: Icons.psychology,
      originalColor: Pallete.rosa,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0), 
    );
  }

  static Enemy createSpider(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 25,
      speed: 100,
      weight: 1.2,
      rotates: true,
      iconData: MdiIcons.spider,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 2.5,
        hazardBuilder: (p) => Web(position: p, duration: 8.0),
      ),
    );
  }

  static Enemy createSnail(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 60,
      weight: 1.2,
      iconData: MdiIcons.snail,
      originalColor: Pallete.verdeCla,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 0.8, // Mais rápido
        hazardBuilder: (p) => PoisonPuddle(position: p, duration: 5.0, damage: 1),
      ),
    );
  }

  static Enemy createSlimeP(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 20,
      speed: 120,
      size: Vector2.all(24),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.verdeCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior()   
    );
  }

  static Enemy createSlimeM(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 50,
      speed: 80,
      iconData: MdiIcons.cloud,
      originalColor: Pallete.verdeCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),   
      deathBehavior: SpawnOnDeathBehavior(
        count: 4,
        minionBuilder: (p) => EnemyFactory.createSlimeP(p),
      ),    
    );
  }

  static Enemy createKingSlime1(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 200,
      speed: 100,
      size: Vector2.all(80),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(30)),
      deathBehavior: SpawnOnDeathBehavior(
        count: 2,
        minionBuilder: (p) => EnemyFactory.createKingSlime2(p),
      ),    
    );
  }

  static Enemy createKingSlime2(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 100,
      speed: 150,
      size: Vector2.all(64),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(20)), 
      deathBehavior: SpawnOnDeathBehavior(
        count: 2,
        minionBuilder: (p) => EnemyFactory.createKingSlime3(p),
      ),    
    );
  }

  static Enemy createKingSlime3(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 50,
      speed: 180,
      size: Vector2.all(32),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),
    //  deathBehavior: SpawnOnDeathBehavior(
     //   count: 2,
     //   minionBuilder: (p) => EnemyFactory.createSlimeP(p),
     // ),    
    );
  }

}