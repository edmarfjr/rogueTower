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
      speed: 0, // A velocidade é controlada pelo DashAttack
      iconData: Icons.navigation,
      originalColor: Pallete.amarelo,
      // Dasher é especial: o movimento é controlado pelo ataque
      movementBehavior: FollowPlayerBehavior(), // Fallback (ou criar um StationaryBehavior)
      attackBehavior: DashAttackBehavior(),
    );
  }

  // --- EXEMPLO DE INIMIGO MISTO (NOVO!) ---
  static Enemy createCrazyShooter(Vector2 pos) {
    // Um inimigo que quica na parede (Bouncer) E atira (Shooter)
    return Enemy(
      position: pos,
      hp: 50,
      speed: 100,
      iconData: Icons.psychology,
      originalColor: Pallete.rosa,
      movementBehavior: BouncerBehavior(),
      attackBehavior: ProjectileAttackBehavior(interval: 2.0), // Atira rápido
    );
  }
}