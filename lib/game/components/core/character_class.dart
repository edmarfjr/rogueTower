import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'pallete.dart'; // Ajuste o import da sua paleta de cores

class CharacterClass {
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  // Atributos Base
  final int maxHp;
  final double speed;
  final double damage;
  final double fireRate;
  final double critChance;
  final double critDamage;
  final double dashCooldown;
  final double attackRange;

  // Bônus Passivos (Flags)
  final bool isPiercing; // Mago começa varando inimigos
  final int startingBombs; // Engenheiro/Ladino começa com bombas?
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
    this.isPiercing = false,
    this.startingBombs = 0,
    this.startingShield = 0,
    this.startingKeys = 0,
  });
}

// --- O CATÁLOGO DE PERSONAGENS ---
class CharacterRoster {
  static final List<CharacterClass> classes = [
    const CharacterClass(
      name: "GUERREIRO",
      description: "Equilibrado e resistente. Perfeito para iniciantes.",
      icon: Icons.shield,
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
      icon: MdiIcons.ninja, // Requer MdiIcons
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
      description: "Lento, mas seus feitiços perfuram múltiplos inimigos.",
      icon: MdiIcons.autoFix, // Varinha mágica
      color: Pallete.rosa,
      maxHp: 6, // 3 Corações
      speed: 130.0, // Mais lento
      damage: 15.0, // Dano alto
      fireRate: 0.6, // Atira devagar
      critChance: 5,
      critDamage: 2,
      dashCooldown: 3.0,
      isPiercing: true, // Tiro atravessa os inimigos nativamente!
      startingShield: 1, // Começa com 1 de escudo
      attackRange: 250,
    ),
  ];
}