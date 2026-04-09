//import 'dart:math';

import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/projectiles/bomb.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:towerrogue/game/components/projectiles/web.dart';
import 'package:flame/components.dart';
//import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
      speed: 50,
      isDummy: true,
      hbSize: Vector2(8,16),
      image: "sprites/inimigos/dummy.png",
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
      hp: hpBossMedio * (0.5 + (phase*0.5)),
      position: pos,
      speed: 50,
      soul: 250, 
      image: "sprites/inimigos/agiota.png",
      size: Vector2.all(32), 
      originalColor: Pallete.laranja,
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
      hp: hpFraco * (0.5 + (phase*0.5)),
      speed: 50,
      hbSize: Vector2(12,9),
      hbOffset: Vector2(0, 4),
      image: "sprites/inimigos/rat.png",
      originalColor: Pallete.marrom,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0),       
    );
  }

  static Enemy createFungi(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpFraco * (0.5 + (phase*0.5)),
      speed: 0,
      weight: 5,
      image: "sprites/inimigos/mushroom.png",
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
      hp: hpFraco * (0.5 + (phase*0.5)),
      speed: 50,
      weight: 5,
      image: "sprites/inimigos/mushroom.png",
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
      hp: hpFraco * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(12,12),
      rotates: true,
      image: "sprites/inimigos/bug.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 30,
      weight: 1.2,
      hbSize: Vector2(14,14),
      //flipOposto: true,
      image: "sprites/inimigos/snail.png",
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
      hp: hpMinimo * (0.5 + (phase*0.5)),
      speed: 50,
      isMinion: true,
      voa: true,
      rotates: true,
      hbSize: Vector2(8,10),
      image: "sprites/inimigos/bee.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 0,
      weight: 2.0,
      image: "sprites/inimigos/beehive.png",
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
      hp: hpMinimo * (0.5 + (phase*0.5)),
      isMinion: true,
      speed: 60,
      size: Vector2.all(16),
      hbSize: Vector2(10,9),
      image: "sprites/inimigos/slimeP.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(14,12),
      image: "sprites/inimigos/slime.png",
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
      hp: hpBossFraco * (0.5 + (phase*0.5)), 
      position: Vector2(0, -100),
      speed: 40,
      soul: 100,
      image: "sprites/inimigos/ratKing.png",
      size: Vector2.all(32),
      hbSize: Vector2(28,18),
      hbOffset: Vector2(0, 8), 
      originalColor: Pallete.laranja,
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 50,
      hbSize: Vector2(14,14),
      voa: true,
      image: "sprites/inimigos/bat.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      weight: 1.2,
      rotates: true,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/spider.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 40,
      voa: true,
      hbSize: Vector2(14,14),
      hasGhostEffect: true,
      image: "sprites/inimigos/ghost.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 0,
      weight: 100,
      hbSize: Vector2(8,14),
      image: "sprites/inimigos/coffin.png",
      originalColor: Pallete.marrom,
      movementBehavior: IdleBehavior(),
      attackBehavior: LaserAttackBehavior(interval: 2.5,),
    );
  }

  static Enemy createMare(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(14,14),
      hasGhostEffect: true,
      image: "sprites/inimigos/mare.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 50,
      hasGhostEffect: true,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/headless.png",
      originalColor: Pallete.lilas,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 90, 
        chargeSpeed: 200, 
        prepTime: 0.6,
      ),
    );
  }

  static EnemyBoss createGhostKnight(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "ghostKnight".tr(),
      hp: hpBossMedio * (0.5 + (phase*0.5)), 
      position: Vector2(0, -100),
      speed: 50,
      soul: 250, 
      hasFlail: true,
      image: "sprites/inimigos/dullahan.png",
      hasGhostEffect: true,
      size: Vector2.all(32), 
      originalColor: Pallete.lilas,
      behaviorChangeInterval: 4.0,
      
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements:[
          FollowPlayerBehavior(),
        ],
        phase1Attacks: [
          ChargeAttackBehavior(
            detectRange: 180, 
            chargeSpeed: 200, 
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
            detectRange: 250, 
            chargeSpeed: 200, 
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 40, 
      weight: 2.0,
      hbSize: Vector2(8,14),
      image: "sprites/inimigos/knight.png",
      originalColor: Pallete.lilas, 
      movementBehavior: RandomWanderBehavior(), 
      attackBehavior: JumpAttackBehavior(
        jumpRange: 100,    
        minRange: 25,      
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(8,14),
      image: "sprites/inimigos/pawn.png",
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
      hp: hpResistente * (0.5 + (phase*0.5)),
      speed: 0,
      hbSize: Vector2(8,14),
      weight: 100,
      image: "sprites/inimigos/rook.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(8,14),
      image: "sprites/inimigos/bishop.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      hbSize: Vector2(8,14),
      speed: 30,
      image: "sprites/inimigos/king.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(8,14),
      image: "sprites/inimigos/queen.png",
      originalColor: Pallete.lilas,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: SpinnerAttackBehavior(interval: 2.5, isChangeDir: true),
    );
  }

  static EnemyBoss createTruQueen(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "truQueen".tr(),
      hp: hpBossForte * (0.5 + (phase*0.5)), 
      position: Vector2(0, -100),
      speed: 60,
      soul: 300, 
      hbSize: Vector2(16,32),
      image: "sprites/inimigos/trueQueen.png",
      hasGhostEffect: true,
      size: Vector2.all(32), 
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
          jumpRange: 150,    
          minRange: 25,      
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 0,
      hbSize: Vector2(14,14),
      image:"sprites/inimigos/rabbit.png",
      originalColor: Pallete.cinzaCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: JumpAttackBehavior(
        jumpRange: 100,    
        minRange: 25,      
        jumpDuration: 1.0, 
        cooldown: 1.0, 
        isRandomJump: true,
        randomJumpRadius: 75.0,
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 50,
      hasGhostEffect: true,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/unicorn.png",
      originalColor: Pallete.bege,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 90, 
        chargeSpeed: 200, 
        prepTime: 0.6,   
      ),
    );
  }

  static Enemy createBird(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      voa: true,
      image: "sprites/inimigos/bird.png",
      hbSize: Vector2(12,12),
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
      hp: hpTanque * (0.5 + (phase*0.5)),
      speed: 50,
      hbSize: Vector2(14,10),
      weight: 3.0,
      image: "sprites/inimigos/elephant.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 30,
      hbSize: Vector2(14,16),
      image: "sprites/inimigos/snake.png",
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
      hp: hpResistente * (0.5 + (phase*0.5)),
      speed: 30,
      hbSize: Vector2(14,10),
      hasShield: true,
      image: "sprites/inimigos/tortoise.png",
      originalColor: Pallete.marrom,
      movementBehavior: RandomWanderBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 3.0, speed:4, isOrbital: true, orbitalRadius: 60.0, isBurst: true, burstCount: 5, burstDelay: 0.3),
    );
  }

  static EnemyBoss createBeast(Vector2 pos, {int phase = 1}) {
    return EnemyBoss(
      bossName: "beast".tr(),
      hp: hpBossForte * (0.5 + (phase*0.5)), 
      position: Vector2(0, -100),
      speed: 50,
      image:"sprites/inimigos/besta.png",
      hbSize: Vector2(22,22),
      soul: 300, 
      hasGhostEffect: true,
      size: Vector2.all(32), 
      originalColor: Pallete.bege,
      behaviorChangeInterval: 4.0,
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements: [
          FollowPlayerBehavior(), 
          IdleBehavior(),                  
        ],
        phase1Attacks: [
          JumpAttackBehavior(
            jumpRange: 100,    
            minRange: 25,      
            jumpDuration: 0.5, 
            cooldown: 0.5, 
            isRandomJump: true,
            randomJumpRadius: 75.0,
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
            jumpRange: 150,    
            minRange: 25,      
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 30,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/jellyfish.png",
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
      hp: hpTanque * (0.5 + (phase*0.5)),
      speed: 0,
      weight: 3,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/anemona.png",
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
      hp: hpMedio * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(14,10),
      image: "sprites/inimigos/fish.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 50,
      hbSize: Vector2(14,14),
      image: "sprites/inimigos/dolphin.png",
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
      hp: hpForte * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(14,10),
      image: "sprites/inimigos/shark.png",
      originalColor: Pallete.cinzaCla,
      movementBehavior: FollowPlayerBehavior(),
      attackBehavior: ChargeAttackBehavior(
        detectRange: 90, 
        chargeSpeed: 100, 
        prepTime: 0.6,   
      ),
    );
  }

  static Enemy createTurtle(Vector2 pos,{bool noChamp = false, int champType = 0, int phase = 1}) {
    return Enemy(
      position: pos,
      noChamp: noChamp,
      championType: champType,
      hp: hpTanque * (0.5 + (phase*0.5)),
      speed: 40,
      hbSize: Vector2(14,14),
      hasShield: true,
      image: "sprites/inimigos/turtle.png",
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
      hp: hpBossForte * (0.5 + (phase*0.5)), 
      position: Vector2(0, -100),
      speed: 70,
      image: "sprites/inimigos/megalodon.png",
      soul: 350, 
      size: Vector2.all(32), 
      originalColor: Pallete.cinzaCla,
      behaviorChangeInterval: 4.0,
        // --- COMPORTAMENTOS DA FASE 1 ---
        phase1Movements: [
          RandomWanderBehavior(),   
        ],
        phase1Attacks: [
          ChargeAttackBehavior(
            detectRange: 150, 
            chargeSpeed: 100, 
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
            detectRange: 90, 
            chargeSpeed: 200, 
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