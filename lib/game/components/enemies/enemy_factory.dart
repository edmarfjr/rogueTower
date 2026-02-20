import 'dart:math';

import 'package:TowerRogue/game/components/core/i18n.dart';
import 'package:TowerRogue/game/components/projectiles/bomb.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:TowerRogue/game/components/projectiles/web.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'enemy.dart';
import 'enemy_boss.dart';
import 'enemy_behaviors.dart';
import '../core/pallete.dart';

class EnemyFactory {

  static Enemy createDummy(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 1000,
      speed: 0,
      isDummy: true,
      hbSize: Vector2(16,32),
      iconData: MdiIcons.humanMale,
      originalColor: Pallete.bege,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),       
    );
  }

  // inimigos fase 1
  
  static Enemy createRat(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 30,
      speed: 100,
      hbSize: Vector2(24,18),
      hbOffset: Vector2(0, 4),
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
      hbSize: Vector2(24,24),
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
      hbSize: Vector2(26,26),
      flipOposto: true,
      iconData: MdiIcons.snail,
      originalColor: Pallete.verdeCla,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 0.5, 
        hazardBuilder: (p) => PoisonPuddle(position: p, duration: 5.0, damage: 1),
      ),
    );
  }

  static Enemy createBee(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 15,
      speed: 100,
      voa: true,
      rotates: true,
      hbSize: Vector2(16,16),
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
      hp: 50,
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
      hbSize: Vector2(20,18),
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
      hbSize: Vector2(28,24),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.verdeCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),   
      deathBehavior: SpawnOnDeathBehavior(
        count: 3,
        minionBuilder: (p) => EnemyFactory.createSlimeP(p),
      ),    
    );
  }

  static EnemyBoss createRatKing(Vector2 pos) {
    return EnemyBoss(
      bossName: "reiRato".tr(),
      hp: 500, // Vida da Fase 1
      position: Vector2(0, -100),
      speed: 80,
      soul: 100,
      iconData: Icons.pest_control_rodent,
      size: Vector2.all(64),
      hbSize: Vector2(56,36),
      hbOffset: Vector2(0, 8), 
      originalColor: Pallete.vermelho,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        movementBehavior: RandomWanderBehavior(),
        attackBehavior: ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(15), isShotgun: true),
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movement: FollowPlayerBehavior(),
        phase2Attack: ProjectileAttackBehavior(interval: 5.0, isBurst: true, burstCount: 10, burstDelay: 0.1, isStraight:false, size: Vector2.all(20)),
        phase2Attack2: SummonAttackBehavior(
          minionBuilder: (p) => EnemyFactory.createRat(p), 
          interval: 3.0, 
          maxMinions: 4,
        ),
    );
  }

  static Enemy createKingSlime1(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 200,
      speed: 80,
      soul: 60,
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
      soul: 25,
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
      soul: 10,
      size: Vector2.all(32),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.vermelho,
      movementBehavior: BouncerBehavior(),
      attackBehavior: NoAttackBehavior(),  
    );
  }

// inimigos fase 2

  static Enemy createBat(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 45,
      speed: 100,
      hbSize: Vector2(28,16),
      voa: true,
      iconData: MdiIcons.bat,
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 1.5),
    );
  }

  static Enemy createSpider(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 45,
      speed: 80,
      weight: 1.2,
      rotates: true,
      hbSize: Vector2(28,28),
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
      hp: 60,
      speed: 80,
      voa: true,
      hbSize: Vector2(26,28),
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
      hp: 70,
      speed: 0,
      weight: 100,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.coffin,
      originalColor: Pallete.marrom,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: LaserAttackBehavior(interval: 2.5,),
    );
  }

  static Enemy createMere(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 60,
      speed: 80,
      hbSize: Vector2(28,28),
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
      hp: 70,
      speed: 100,
      hasGhostEffect: true,
      hbSize: Vector2(28,28),
      iconData: MdiIcons.horseHuman,
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,
      ),
    );
  }

  static Enemy createHorseManBoss(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 700,
      speed: 100,
      soul: 250, 
      hasGhostEffect: true,
      size: Vector2.all(80),
      iconData: MdiIcons.horseHuman,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,    
      ),
      attack2Behavior: MortarAttackBehavior(interval: 3.0),
    );
  }

  static EnemyBoss createGhostKnight(Vector2 pos) {
    return EnemyBoss(
      bossName: "ghostKnight".tr(),
      hp: 700, // Vida da Fase 1
      position: Vector2(0, -100),
      speed: 100,
      soul: 250, 
      iconData: MdiIcons.horseHuman,
      hasGhostEffect: true,
      size: Vector2.all(64), // O dobro do tamanho de um inimigo normal!
      originalColor: Pallete.vermelho,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        movementBehavior: FollowPlayerBehavior(),
        attackBehavior: ChargeAttackBehavior(
          detectRange: 180, 
          chargeSpeed: 400, 
          prepTime: 0.6,    
        ),
        attack2Behavior: MortarAttackBehavior(interval: 3.0),
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movement: FollowPlayerBehavior(),
        phase2Attack: ProjectileAttackBehavior(interval: 5.0, isBurst: true, burstCount: 10, burstDelay: 0.1, isStraight:false, size: Vector2.all(20)),
        phase2Attack2: ChargeAttackBehavior(
          detectRange: 360, 
          chargeSpeed: 400, 
          prepTime: 0.6,    
        ),
    );
  }

  // inimigos fase 3

  static Enemy createChessKnight(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 70,
      speed: 80, 
      weight: 2.0,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessKnight, 
      originalColor: Pallete.lilas, 
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
      hp: 60,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessPawn,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, is2shot: true),
    );
  }

  static Enemy createChessRook(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 120,
      speed: 0,
      hbSize: Vector2(16,28),
      weight: 100,
      iconData: MdiIcons.chessRook,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: MortarAttackBehavior(interval: 2.0),
    );
  }

  static Enemy createChessBishop(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessBishop,
      originalColor: Pallete.lilas,
      movementBehavior: BouncerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isDiagonal: true),
    );
  }

  static Enemy createChessKing(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 100,
      hbSize: Vector2(16,28),
      speed: 60,
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 3, isChangeDir: true),
    );
  }

  static Enemy createChessQueen(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessQueen,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
    );
  }

  static Enemy createChessQueenBoss(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 1200,
      speed: 80,
      soul: 300,
      size: Vector2.all(80),
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
      attack2Behavior: MortarAttackBehavior(interval: 3.0),
    );
  }

  static EnemyBoss createTruQueen(Vector2 pos) {
    return EnemyBoss(
      bossName: "truQueen".tr(),
      hp: 1200, // Vida da Fase 1
      position: Vector2(0, -100),
      speed: 80,
      soul: 300, 
      hbSize: Vector2(34,54),
      iconData: MdiIcons.chessQueen,
      hasGhostEffect: true,
      size: Vector2.all(64), // O dobro do tamanho de um inimigo normal!
      originalColor: Pallete.bege,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        movementBehavior: FollowPlayerBehavior(),
        attackBehavior: SpinnerAttackBehavior(interval: 2.5),
        attack2Behavior: MortarAttackBehavior(interval: 3.0),
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movement: BouncerBehavior(),
        phase2Attack: SpinnerAttackBehavior(interval: 2, isChangeDir: true),
        phase2Attack2: JumpAttackBehavior(
          jumpRange: 300,    
          minRange: 50,      
          jumpDuration: 1.0, 
          cooldown: 3,     
        ),
    );
  }

   // inimigos fase 4

   static Enemy createRabbit(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 0,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.rabbit,
      originalColor: Pallete.cinzaCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: JumpAttackBehavior(
        jumpRange: 200,    
        minRange: 50,      
        jumpDuration: 1.0, 
        cooldown: 1.0, 
        isRandomJump: true,
        randomJumpRadius: 150.0,
        isExplosionOnLand: false,
        is4ShotOnLand: true,    
      ),
    );
  }

  static Enemy createUnicorn(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 100,
      speed: 100,
      hasGhostEffect: true,
      hbSize: Vector2(24,24),
      iconData: MdiIcons.unicorn,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,   
      ),
    );
  }

  static Enemy createBird(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      voa: true,
      iconData: MdiIcons.bird,
      hbSize: Vector2(24,24),
      originalColor: Pallete.azulCla,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, is2shot: true),
    );
  }

  static Enemy createElephant(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 200,
      speed: 90,
      hbSize: Vector2(24,20),
      weight: 3.0,
      iconData: MdiIcons.elephant,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),
    );
  }

  static Enemy createSnake(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 100,
      speed: 90,
      hbSize: Vector2(26,30),
      iconData: MdiIcons.snake,
      originalColor: Pallete.verdeEsc,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: MortarAttackBehavior(isPoison: true, interval: 3.0),
    );
  }

  static Enemy createTortoise(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 100,
      speed: 50,
      hbSize: Vector2(26,20),
      hasShield: true,
      iconData: MdiIcons.tortoise,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, speed:4, isOrbital: true, orbitalRadius: 60.0, isBurst: true, burstCount: 5, burstDelay: 0.3),
    );
  }

  static Enemy createRabbitBoss(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 1500,
      speed: 0,
      size: Vector2.all(80),
      soul: 350,
      iconData: MdiIcons.rabbit,
      originalColor: Pallete.vermelho,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: JumpAttackBehavior(
        jumpRange: 200,    
        minRange: 50,      
        jumpDuration: 1.0, 
        cooldown: 1.0, 
        isRandomJump: true,
        randomJumpRadius: 150.0,
        isExplosionOnLand: false,
        is4ShotOnLand: true,    
      ),
      attack2Behavior: ProjectileAttackBehavior(interval: 3.0, isBurst: true, burstCount: 10, burstDelay: 0.3, isStraight: false),
    );
  }

  static EnemyBoss createBeast(Vector2 pos) {
    return EnemyBoss(
      bossName: "beast".tr(),
      hp: 1500, // Vida da Fase 1
      position: Vector2(0, -100),
      speed: 0,
      iconData: MdiIcons.rabbit,
      hbSize: Vector2(50,50),
      soul: 300, 
      hasGhostEffect: true,
      size: Vector2.all(64), // O dobro do tamanho de um inimigo normal!
      originalColor: Pallete.bege,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        movementBehavior: FollowPlayerBehavior(),
        attackBehavior: JumpAttackBehavior(
          jumpRange: 200,    
          minRange: 50,      
          jumpDuration: 1.0, 
          cooldown: 1.0, 
          isRandomJump: true,
          randomJumpRadius: 150.0,
          isExplosionOnLand: false,
          is4ShotOnLand: true,    
        ),
        attack2Behavior: ProjectileAttackBehavior(interval: 3.0, isBurst: true, burstCount: 10, burstDelay: 0.3, isStraight: false),
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movement: BouncerBehavior(),
        phase2Attack: ProjectileAttackBehavior(interval: 3.0, isBurst: true, burstCount: 20, burstDelay: 0.075, isStraight: false),
        phase2Attack2: JumpAttackBehavior(
          jumpRange: 300,    
          minRange: 50,      
          jumpDuration: 1.0, 
          cooldown: 3,     
        ),
    );
  }

  // inimigos fase 5

   static Enemy createJellyfish(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 60,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.jellyfish,
      originalColor: Pallete.azulCla,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(
        interval: 2.0, 
        isChangeDir: true,
        isBoomerang: true,
      ),
    );
  }

  static Enemy createFishBowl(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 0,
      weight: 3,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.fishbowl,
      originalColor: Pallete.azulCla,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: LaserAttackBehavior(
        interval: 3.0, 
        isShotgun: true, 
      ),
    );
  }

  static Enemy createFish(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.fish,
      originalColor: Pallete.azulCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(
        interval: 2.5, 
        isShotgun: true, 
        isBoomerang: true,
      ),
    );
  }

  static Enemy createDolphin(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.dolphin,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(
        interval: 2.5, 
        isShotgun: true, 
        size: Vector2.all(20),
        speed: 150,
      ),
    );
  }

  static Enemy createShark(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.shark,
      originalColor: Pallete.cinzaCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,   
      ),
    );
  }

  static Enemy createTurtle(Vector2 pos) {
    return Enemy(
      position: pos,
      hp: 80,
      speed: 80,
      hbSize: Vector2(26,26),
      hasShield: true,
      iconData: MdiIcons.turtle,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(
        interval: 2.5, 
        isBurst: true, 
        burstCount: 5, 
        burstDelay: 0.2,
        isStraight: false,
      ),
    );
  }

  static EnemyBoss createMegalodon(Vector2 pos) {
    return EnemyBoss(
      bossName: "megalodon".tr(),
      hp: 1800, // Vida da Fase 1
      position: Vector2(0, -100),
      speed: 100,
      iconData: MdiIcons.shark,
      hbSize: Vector2(50,50),
      soul: 350, 
      size: Vector2.all(64), // O dobro do tamanho de um inimigo normal!
      originalColor: Pallete.cinzaCla,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        movementBehavior: RandomWanderBehavior(),
        attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,   
      ),
        attack2Behavior: DropHazardBehavior(
        interval: 1.5, 
        hazardBuilder: (p) => Bomb(position: p, duration: 3.0, damage: 1, isEnemy: true),
      ),
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movement: FollowPlayerBehavior(),
          phase2Attack: ChargeAttackBehavior(
          detectRange: 180, 
          chargeSpeed: 400, 
          prepTime: 0.6,   
        ),
          phase2Attack2: DropHazardBehavior(
          interval: 1.5, 
          hazardBuilder: (p) => Bomb(position: p, duration: 3.0, damage: 1, isEnemy: true, isMine: true),
        ),
    );
  }

}
