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

  // inimigos fase 1
  
  static Enemy createRat(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 30,
      speed: 100,
      iconData: Icons.pest_control_rodent,
      originalColor: Pallete.vermelho,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),       
    );
  }

  static Enemy createFungi(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 25,
      speed: 0,
      weight: 5,
      iconData: MdiIcons.mushroom,
      originalColor: Pallete.rosa,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2),
    );
  }
  
  static Enemy createBug(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 20,
      speed: 80,
      rotates: true,
      iconData: Icons.bug_report,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: MortarAttackBehavior(interval: 3.0),
    );
  }

  static Enemy createSnail(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 60,
      weight: 1.2,
      flipOposto: true,
      iconData: MdiIcons.snail,
      originalColor: Pallete.verdeCla,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 0.8, // Mais rápido
        hazardBuilder: (p) => PoisonPuddle(position: p, duration: 5.0, damage: 1),
      ),
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
      speed: 80,
      size: Vector2.all(80),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(30)),
      attack2Behavior: MortarAttackBehavior(interval: 4.0),
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
      speed: 100,
      size: Vector2.all(64),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(20)), 
      attack2Behavior: MortarAttackBehavior(interval: 4.0),
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
      speed: 120,
      size: Vector2.all(32),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: NoAttackBehavior(),
    //  deathBehavior: SpawnOnDeathBehavior(
     //   count: 2,
     //   minionBuilder: (p) => EnemyFactory.createSlimeP(p),
     // ),    
    );
  }

// inimigos fase 2

  static Enemy createBat(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 25,
      speed: 100,
      iconData: MdiIcons.bat,
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 1.5),
    );
  }

  static Enemy createSpider(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 25,
      speed: 80,
      weight: 1.2,
      rotates: true,
      iconData: MdiIcons.spider,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 2.5,
        hazardBuilder: (p) => Web(position: p, duration: 8.0),
      ),
      attack2Behavior: ProjectileAttackBehavior(interval: 2.5)
    );
  }

  static Enemy createGhost(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 80,
      hasGhostEffect: true,
      iconData: MdiIcons.ghost,
      originalColor: Pallete.cinzaCla,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),
    );
  }

  static Enemy createCoffin(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 0,
      weight: 100,
      iconData: MdiIcons.coffin,
      originalColor: Pallete.marrom,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: LaserAttackBehavior(interval: 2.5,),
    );
  }

  static Enemy createMere(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 80,
      hasGhostEffect: true,
      iconData: MdiIcons.horseVariantFast,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, isShotgun: true),
    );
  }

  static Enemy createHorseMan(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 100,
      hasGhostEffect: true,
      iconData: MdiIcons.horseHuman,
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, // Só ataca se chegar perto
        chargeSpeed: 400, // Muito rápido no ataque
        prepTime: 0.6,    // 0.6s de aviso antes de correr
      ),
    );
  }

  static Enemy createHorseManBoss(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 500,
      speed: 100,
      hasGhostEffect: true,
      size: Vector2.all(80),
      iconData: MdiIcons.horseHuman,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, // Só ataca se chegar perto
        chargeSpeed: 400, // Muito rápido no ataque
        prepTime: 0.6,    // 0.6s de aviso antes de correr
      ),
      attack2Behavior: MortarAttackBehavior(interval: 3.0),
    );
  }

  // inimigos fase 3

  static Enemy createChessKnight(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 45,
      speed: 80, 
      weight: 2.0,
      iconData: MdiIcons.chessKnight, 
      originalColor: Pallete.cinzaEsc, 
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: JumpAttackBehavior(
        jumpRange: 200,    
        minRange: 50,      
        jumpDuration: 1.0, 
        cooldown: 2.5,     
      ),
    );
  }

  static Enemy createChessPawn(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 40,
      speed: 80,
      iconData: MdiIcons.chessPawn,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, is2shot: true),
    );
  }

  static Enemy createChessRook(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 60,
      speed: 0,
      weight: 100,
      iconData: MdiIcons.chessRook,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: MortarAttackBehavior(interval: 2.0),
    );
  }

  static Enemy createChessBishop(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 60,
      speed: 80,
      iconData: MdiIcons.chessBishop,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: BouncerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isDiagonal: true),
    );
  }

  static Enemy createChessKing(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 60,
      speed: 60,
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 3, isChangeDir: true),
    );
  }

  static Enemy createChessQueen(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 50,
      speed: 80,
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
    );
  }

  static Enemy createChessQueenBoss(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 500,
      speed: 80,
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.cinzaEsc,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
      attack2Behavior: MortarAttackBehavior(interval: 3.0),
    );
  }

}
