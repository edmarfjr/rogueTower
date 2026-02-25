import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'pallete.dart'; // Ajuste o import da sua paleta de cores

class CharacterClass {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  final double accessoryOffsetX;
  final double accessoryOffsetY;
  final double accessorySize;
  final double acessoryAngle;
  final bool flipAccessoryBase;

  // Atributos Base
  final int maxHp;
  final double speed;
  final double damage;
  final double fireRate;
  final double critChance;
  final double critDamage;
  final double dashCooldown;
  final double attackRange;
  final double dot;
  final int stackBonus;

  // Bônus Passivos (Flags)
  final bool isPiercing; 
  final bool isBurn;
  final int startingBombs; 
  final int startingKeys;
  final int startingShield;

  const CharacterClass({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.maxHp,
    required this.speed,
    required this.damage,
    required this.fireRate,
    required this.critChance,
    required this.critDamage,
    required this.dashCooldown,
    required this.attackRange,
    this.dot = 1.0,
    this.stackBonus = 0,
    this.isPiercing = false,
    this.isBurn = false,
    this.startingBombs = 0,
    this.startingShield = 0,
    this.startingKeys = 0,
    this.accessoryOffsetX = 0,
    this.accessoryOffsetY = 0,
    this.accessorySize = 24.0,
    this.acessoryAngle = 0,
    this.flipAccessoryBase = false,
  });

  Vector2 get accessoryOffset => Vector2(accessoryOffsetX, accessoryOffsetY);
}

// --- O CATÁLOGO DE PERSONAGENS ---
class CharacterRoster {
  static final List<CharacterClass> classes = [
    CharacterClass(
      name: "GUERREIRO",
      description: "Equilibrado e resistente. Perfeito para iniciantes.",
      icon: MdiIcons.sword,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      accessorySize: 24.0,
      flipAccessoryBase: true,
      color: Pallete.lilas, // Ou Pallete.azul
      maxHp: 8, // 4 Corações
      speed: 150.0,
      damage: 10.0,
      fireRate: 0.4,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 150,
    ),
    CharacterClass(
      name: "LADINO",
      description: "Frágil, porém mortal. Focado em acertos críticos e esquivas rápidas.",
      icon: MdiIcons.knifeMilitary, // Requer MdiIcons
      accessorySize: 12.0,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      acessoryAngle: pi/2,
      color:  Pallete.verdeCla,
      maxHp: 4, // 2 Corações apenas!
      speed: 220.0, // Muito rápido
      damage: 8.0,
      fireRate: 0.25, // Atira muito rápido
      critChance: 25, // 25% de chance de crítico base!
      critDamage: 2.5,
      dashCooldown: 1.0, // Dash carrega rápido
      startingBombs: 1,
      startingKeys: 1,
      attackRange: 200,
    ),
    CharacterClass(
      name: "MAGO",
      description: "Lento, mas seus feitiços queimam inimigos.",
      icon: MdiIcons.magicStaff, // Varinha mágica
      accessoryOffsetX: 30.0, // <-- Fica assim agora!
      accessoryOffsetY: 10.0,
      accessorySize: 24.0,
      color: Pallete.rosa,
      maxHp: 6, // 3 Corações
      speed: 130.0, // Mais lento
      damage: 15.0, // Dano alto
      fireRate: 0.6, // Atira devagar
      critChance: 5,
      critDamage: 2,
      dashCooldown: 3.0,
      isBurn: true, 
      stackBonus: 5,
      dot: 1.5,
      startingShield: 1, // Começa com 1 de escudo
      attackRange: 250,
    ),
  ];
}