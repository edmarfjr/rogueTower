import 'dart:math';

import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/projectiles/bomb.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:towerrogue/game/components/projectiles/web.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'enemy.dart';
import 'enemy_boss.dart';
import 'enemy_behaviors.dart';
import '../core/pallete.dart';

class EnemyFactory {

  // --- DEFINIÇÕES GERAIS DE HP (Base) ---
  static const double hpMinimo = 20.0;
  static const double hpFraco = 30.0;
  static const double hpMedio = 50.0;
  static const double hpForte = 70.0;
  static const double hpMuitoForte = 80.0;
  static const double hpResistente = 100.0;
  static const double hpTanque = 120.0;
  static const double hpSuperTanque = 200.0;

  // --- DEFINIÇÕES DE HP PARA BOSSES ---
  static const double hpBossFraco = 1000.0;
  static const double hpBossMedio = 1500.0;
  static const double hpBossForte = 2000.0;
  static const double hpBossMuitoForte = 2500.0;
  static const double hpBossTanque = 3000.0;


  static Enemy createDummy(Vector2 pos,{int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: true,
      championType: champType,
      hp: 1000, // Dummy geralmente não escala, então mantive fixo
      speed: 100,
      isDummy: true,
      hbSize: Vector2(16,32),
      iconData: MdiIcons.humanMale,
      originalColor: Pallete.bege,
      movementBehavior: IdleBehavior(),
      attackBehavior: NoAttackBehavior(),       
      dropList: [
        CollectibleType.familiarDummy,
      ],
    );
  }

  static EnemyBoss createAgiota(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "agiota".tr(),
      hp: hpBossMedio * phase,
      position: Vector2(0, -100),
      speed: 100,
      soul: 250, 
      iconData: MdiIcons.accountTie,
      size: Vector2.all(64), 
      originalColor: Pallete.vermelho,
      dropList: [
        CollectibleType.boloDinheiro,
        CollectibleType.goldDmg
      ],
      behaviorChangeInterval: 4.0,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements:[
          FollowPlayerBehavior(),
        ],
        phase1Attacks: [
          ProjectileAttackBehavior(interval: 2.0, isBurst: true, burstCount: 10, burstDelay: 0.1, isStraight:false, size: Vector2.all(20)),
          MortarAttackBehavior(interval: 2.0),
        ],
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movements:[
          FollowPlayerBehavior(speedMod: 1.2),
        ],
        phase2Attacks: [
          ProjectileAttackBehavior(interval: 2.0, isBurst: true, burstCount: 10, burstDelay: 0.1, isStraight:false, size: Vector2.all(20)),
          MortarAttackBehavior(interval: 3.0,isBarragem: true),
          SpinnerAttackBehavior(interval: 0.8, projectilesPerWave: 16, isSpiral: true), 
        ],
        
    );
  }

  // inimigos fase 1
  
  static Enemy createRat(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpFraco * phase,
      speed: 100,
      hbSize: Vector2(24,18),
      hbOffset: Vector2(0, 4),
      iconData: Icons.pest_control_rodent,
      originalColor: Pallete.vermelho,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),       
    );
  }

  static Enemy createFungi(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpFraco * phase,
      speed: 0,
      weight: 5,
      iconData: MdiIcons.mushroom,
      originalColor: Pallete.rosa,
      movementBehavior: IdleBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 4),
    );
  }

  static Enemy createFungi2(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpFraco * phase,
      speed: 100,
      weight: 5,
      iconData: MdiIcons.mushroom,
      originalColor: Pallete.vinho,
      movementBehavior: UnderGroundWanderBehavior(cimaDur: 2),
      attackBehavior: ProjectileAttackBehavior(interval: 4),
    );
  }
  
  static Enemy createBug(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMinimo * phase,
      speed: 80,
      hbSize: Vector2(24,24),
      rotates: true,
      iconData: Icons.bug_report,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: MortarAttackBehavior(interval: 3.0),
    );
  }

  static Enemy createSnail(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 60,
      weight: 1.2,
      hbSize: Vector2(26,26),
      flipOposto: true,
      iconData: MdiIcons.snail,
      originalColor: Pallete.verdeCla,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 0.5, 
        hazardBuilder: (p, owner) => PoisonPuddle(
                                position: p, 
                                duration: 5.0, 
                                damage: 1,
                                isPlayer : owner.isCharmed 
                              ),
      ),
    );
  }

  static Enemy createBee(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: true,
      hp: hpMinimo * phase,
      speed: 100,
      isMinion: true,
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

  static Enemy createBeeHive(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 0,
      weight: 2.0,
      iconData: MdiIcons.beehiveOutline,
      originalColor: Pallete.laranja,
      movementBehavior: IdleBehavior(),
      attackBehavior: SummonAttackBehavior(
        minionBuilder: (p) => EnemyFactory.createBee(p, phase: phase), // Repassa a fase!
        interval: 3.5, 
        maxMinions: 4,
      ),
      deathBehavior: SpawnOnDeathBehavior(
        count: 3,
        minionBuilder: (p) => EnemyFactory.createBee(p, noChamp: true, phase: phase), // Repassa a fase!
      ),
    );
  }

  static Enemy createSlimeP(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: true,
      hp: hpMinimo * phase,
      isMinion: true,
      speed: 120,
      size: Vector2.all(24),
      hbSize: Vector2(20,18),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.verdeCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior()   
    );
  }

  static Enemy createSlimeM(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      hbSize: Vector2(28,24),
      iconData: MdiIcons.cloud,
      originalColor: Pallete.verdeCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),   
      deathBehavior: SpawnOnDeathBehavior(
        count: 3,
        minionBuilder: (p) => EnemyFactory.createSlimeP(p, noChamp: true, phase: phase), // Repassa a fase!
      ),    
    );
  }

  static EnemyBoss createRatKing(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "reiRato".tr(),
      hp: hpBossFraco * phase, 
      position: Vector2(0, -100),
      speed: 80,
      soul: 100,
      iconData: Icons.pest_control_rodent,
      size: Vector2.all(64),
      hbSize: Vector2(56,36),
      hbOffset: Vector2(0, 8), 
      originalColor: Pallete.vermelho,
      behaviorChangeInterval: 3.0,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements: [
        FollowPlayerBehavior(speedMod: 0.75), 
        IdleBehavior(),                 
      ],
      phase1Attacks: [
        ProjectileAttackBehavior(interval: 2.0, size: Vector2.all(15), isShotgun: true), 
        SpinnerAttackBehavior(interval: 0.8, projectilesPerWave: 16, isSpiral: true), 
      ],
       
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movements: [
        FollowPlayerBehavior(speedMod: 1.2), 
        GoToCenterBehavior(),                  
      ],
      phase2Attacks: [
        ProjectileAttackBehavior(interval: 1.0, size: Vector2.all(15), isBurst: true, burstCount: 15, burstDelay: 0.05),
        SpinnerAttackBehavior(interval: 1, size: Vector2.all(15), isSpiral: true, projectilesPerWave: 24),
        MortarAttackBehavior(interval:1, isBarragem: true, isPoison: true),
        SummonAttackBehavior(
          minionBuilder: (p) => EnemyFactory.createRat(p, noChamp: true, phase: phase), // Repassa a fase!
          interval: 1.0, 
          maxMinions: 4,
        ),
      ]
        
    );
  }

// inimigos fase 2

  static Enemy createBat(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 100,
      hbSize: Vector2(28,16),
      voa: true,
      iconData: MdiIcons.bat,
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 1.5),
    );
  }

  static Enemy createSpider(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      weight: 1.2,
      rotates: true,
      hbSize: Vector2(28,28),
      iconData: MdiIcons.spider,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: DropHazardBehavior(
        interval: 2.5,
        hazardBuilder: (p,owner) => Web(position: p, duration: 8.0),
      ),
      attack2Behavior: ProjectileAttackBehavior(interval: 2.5)
    );
  }

  static Enemy createGhost(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
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

  static Enemy createCoffin(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
      speed: 0,
      weight: 100,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.coffin,
      originalColor: Pallete.marrom,
      movementBehavior: IdleBehavior(),
      attackBehavior: LaserAttackBehavior(interval: 2.5,),
    );
  }

  static Enemy createMere(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
      speed: 80,
      hbSize: Vector2(28,28),
      hasGhostEffect: true,
      iconData: MdiIcons.horseVariantFast,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, isShotgun: true),
    );
  }

  static Enemy createHorseMan(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
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

  static EnemyBoss createGhostKnight(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "ghostKnight".tr(),
      hp: hpBossMedio * phase, 
      position: Vector2(0, -100),
      speed: 100,
      soul: 250, 
      hasFlail: true,
      iconData: MdiIcons.horseHuman,
      hasGhostEffect: true,
      size: Vector2.all(64), 
      originalColor: Pallete.vermelho,
      behaviorChangeInterval: 4.0,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements:[
          FollowPlayerBehavior(),
        ],
        phase1Attacks: [
          ChargeAttackBehavior(
            detectRange: 380, 
            chargeSpeed: 400, 
            prepTime: 0.6,    
          ),
          MortarAttackBehavior(interval: 2.0),
        ],
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movements:[
          FollowPlayerBehavior(),
        ],
        phase2Attacks: [
          ProjectileAttackBehavior(interval: 2.0, isBurst: true, burstCount: 10, burstDelay: 0.1, isStraight:false, size: Vector2.all(20)),
          MortarAttackBehavior(interval: 3.0),
          ChargeAttackBehavior(
            detectRange: 500, 
            chargeSpeed: 400, 
            prepTime: 0.6,    
          ),
        ],
        
    );
  }

  // inimigos fase 3

  static Enemy createChessKnight(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
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

  static Enemy createChessPawn(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessPawn,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, is2shot: true),
    );
  }

  static Enemy createChessRook(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpResistente * phase,
      speed: 0,
      hbSize: Vector2(16,28),
      weight: 100,
      iconData: MdiIcons.chessRook,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: MortarAttackBehavior(interval: 2.0),
    );
  }

  static Enemy createChessBishop(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessBishop,
      originalColor: Pallete.lilas,
      movementBehavior: BouncerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isDiagonal: true),
    );
  }

  static Enemy createChessKing(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      hbSize: Vector2(16,28),
      speed: 60,
      iconData: MdiIcons.chessKing,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 3, isChangeDir: true),
    );
  }

  static Enemy createChessQueen(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
      speed: 80,
      hbSize: Vector2(16,28),
      iconData: MdiIcons.chessQueen,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
    );
  }

  static EnemyBoss createTruQueen(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "truQueen".tr(),
      hp: hpBossForte * phase, 
      position: Vector2(0, -100),
      speed: 120,
      soul: 300, 
      hbSize: Vector2(34,54),
      iconData: MdiIcons.chessQueen,
      hasGhostEffect: true,
      size: Vector2.all(64), 
      originalColor: Pallete.bege,
      behaviorChangeInterval: 4.0,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
      phase1Movements: [
        FollowPlayerBehavior(), 
        BouncerBehavior(),            
      ],
      phase1Attacks: [
        SpinnerAttackBehavior(interval: 2.5, isSpiral: true, projectilesPerWave: 12),
        MortarAttackBehavior(interval: 3.0, isBarragem: true),
      ],
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
      phase2Movements: [
        BouncerBehavior(speedMod:2),            
      ],
      phase2Attacks: [
        SpinnerAttackBehavior(interval: 1, isChangeDir: true, isSpiral: true, projectilesPerWave: 12),
        JumpAttackBehavior(
          jumpRange: 300,    
          minRange: 50,      
          jumpDuration: 1.0, 
          cooldown: 2,     
        ),
        MortarAttackBehavior(interval: 3.0, isBarragem: true),
      ]
    );
  }

   // inimigos fase 4

   static Enemy createRabbit(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
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

  static Enemy createUnicorn(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
      speed: 100,
      hasGhostEffect: true,
      hbSize: Vector2(24,24),
      iconData: MdiIcons.unicorn,
      originalColor: Pallete.bege,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 180, 
        chargeSpeed: 400, 
        prepTime: 0.6,   
      ),
    );
  }

  static Enemy createBird(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      voa: true,
      iconData: MdiIcons.bird,
      hbSize: Vector2(24,24),
      originalColor: Pallete.azulCla,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0, is2shot: true),
    );
  }

  static Enemy createElephant(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpTanque * phase,
      speed: 100,
      hbSize: Vector2(24,20),
      weight: 3.0,
      iconData: MdiIcons.elephant,
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: NoAttackBehavior(),
    );
  }

  static Enemy createSnake(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 90,
      hbSize: Vector2(26,30),
      iconData: MdiIcons.snake,
      originalColor: Pallete.verdeEsc,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: MortarAttackBehavior(isPoison: true, interval: 3.0),
    );
  }

  static Enemy createTortoise(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpResistente * phase,
      speed: 50,
      hbSize: Vector2(26,20),
      hasShield: true,
      iconData: MdiIcons.tortoise,
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, speed:4, isOrbital: true, orbitalRadius: 60.0, isBurst: true, burstCount: 5, burstDelay: 0.3),
    );
  }

  static EnemyBoss createBeast(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "beast".tr(),
      hp: hpBossForte * phase, 
      position: Vector2(0, -100),
      speed: 0,
      iconData: MdiIcons.rabbit,
      hbSize: Vector2(50,50),
      soul: 300, 
      hasGhostEffect: true,
      size: Vector2.all(64), 
      originalColor: Pallete.bege,
      behaviorChangeInterval: 4.0,
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements: [
          FollowPlayerBehavior(), 
          IdleBehavior(),                  
        ],
        phase1Attacks: [
          JumpAttackBehavior(
            jumpRange: 200,    
            minRange: 50,      
            jumpDuration: 0.5, 
            cooldown: 0.5, 
            isRandomJump: true,
            randomJumpRadius: 150.0,
            isExplosionOnLand: false,
            is4ShotOnLand: true,    
          ),
          SpinnerAttackBehavior(interval: 1.0, isSpiral: true ,projectilesPerWave: 16), 
          ProjectileAttackBehavior(interval: 3.0, isBurst: true, burstCount: 10, burstDelay: 0.3, isStraight: false),
        ],
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movements: [
          FollowPlayerBehavior(), 
          BouncerBehavior(),    
          FollowPlayerBehavior(),              
        ],
        phase2Attacks: [
          ProjectileAttackBehavior(interval: 3.0, isBurst: true, burstCount: 20, burstDelay: 0.075, isStraight: false),
          SpinnerAttackBehavior(interval: 0.8, isSpiral: true, projectilesPerWave: 24), 
            JumpAttackBehavior(
            jumpRange: 300,    
            minRange: 50,      
            jumpDuration: 1.0, 
            cooldown: 3,     
          ),
        ],
    );
  }

  // inimigos fase 5

   static Enemy createJellyfish(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
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

  static Enemy createFishBowl(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpTanque * phase,
      speed: 0,
      weight: 3,
      hbSize: Vector2(26,26),
      iconData: MdiIcons.fishbowl,
      originalColor: Pallete.azulCla,
      movementBehavior: IdleBehavior(),
      attackBehavior: LaserAttackBehavior(
        interval: 3.0, 
        isShotgun: true, 
      ),
    );
  }

  static Enemy createFish(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * phase,
      speed: 80,
      hbSize: Vector2(26,20),
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

  static Enemy createDolphin(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
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

  static Enemy createShark(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * phase,
      speed: 80,
      hbSize: Vector2(28,18),
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

  static Enemy createTurtle(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpTanque * phase,
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

  static EnemyBoss createMegalodon(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "megalodon".tr(),
      hp: hpBossForte * phase, 
      position: Vector2(0, -100),
      speed: 120,
      iconData: MdiIcons.shark,
      hbSize: Vector2(50,50),
      soul: 350, 
      size: Vector2.all(64), 
      originalColor: Pallete.cinzaCla,
      behaviorChangeInterval: 4.0,
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements: [
          RandomWanderBehavior(),   
        ],
        phase1Attacks: [
          ChargeAttackBehavior(
            detectRange: 300, 
            chargeSpeed: 400, 
            prepTime: 0.6,   
          ),
          DropHazardBehavior(
            interval: 0.5, 
            hazardBuilder: (p,owner) => Bomb(position: p, duration: 3.0, damage: 1, isEnemy: true),
          ),
        ],
        
        // --- ATIVANDO A FASE 2 ---
        hasSecondForm: true,
        
        // --- COMPORTAMENTOS DA FASE 2 ---
        phase2Movements: [
          FollowPlayerBehavior(),    
        ],
        phase2Attacks: [
          ChargeAttackBehavior(
            detectRange: 180, 
            chargeSpeed: 400, 
            prepTime: 0.6,   
          ),
            DropHazardBehavior(
            interval: 1.5, 
            hazardBuilder: (p,owner) => Bomb(position: p, duration: 3.0, damage: 1, isEnemy: true, isMine: true),
          ),
        ],
       
    );
  }

}