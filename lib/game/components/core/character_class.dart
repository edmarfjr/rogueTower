import 'dart:math';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'pallete.dart';

class CharacterClass {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  final double accessoryOffsetX;
  final double accessoryOffsetY;
  final double accessorySize;
  final double acessoryAngle;
  final bool flipAccessoryBase;
  final bool semAcessorio;
  final bool mudaIcone;

  // Atributos Base
  final int maxHp;
  final int maxDash;
  final double speed;
  final double damage;
  final double fireRate;
  final double critChance;
  final double critDamage;
  final double dashCooldown;
  final double attackRange;
  final double dot;
  final int stackBonus;
  final bool noDamage;

  final String bltImage;
  final double bltSize;
  final double bltSpeed;
  final String weaponImage;
  final bool armaBalanca;

  // Bônus Passivos (Flags)
  final bool isShotgun;
  final int startingBombs; 
  final int startingKeys;
  final int startingShield;
  final bool isBomber;

  final bool isUnlockedByDefault;
  final String unlockConditionText;

  final List<CollectibleType> startingItems;
  final List<CollectibleType> itemsExcluidos;

  const CharacterClass({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.maxHp,
    required this.maxDash,
    required this.speed,
    required this.damage,
    required this.fireRate,
    required this.critChance,
    required this.critDamage,
    required this.dashCooldown,
    required this.attackRange,
    this.dot = 1.0,
    this.stackBonus = 0,
    this.isShotgun = false,
    this.startingBombs = 0,
    this.startingShield = 0,
    this.startingKeys = 0,
    this.accessoryOffsetX = 0,
    this.accessoryOffsetY = 0,
    this.accessorySize = 24.0,
    this.acessoryAngle = 0,
    this.flipAccessoryBase = false,
    this.isUnlockedByDefault = true, 
    this.unlockConditionText = "",
    this.startingItems = const [],
    this.itemsExcluidos = const [],
    this.semAcessorio = false,
    this.mudaIcone = false,
    this.isBomber = false,
    this.noDamage = false,
    this.bltImage = 'sprites/projeteis/blt.png',
    this.bltSize = 6.0,
    this.bltSpeed = 300,
    this.weaponImage='',
    this.armaBalanca = false,
  });

  Vector2 get accessoryOffset => Vector2(accessoryOffsetX, accessoryOffsetY);
}

// --- O CATÁLOGO DE PERSONAGENS ---
class CharacterRoster {
  static final List<CharacterClass> classes = [
    CharacterClass(
      id: "guerreiro",
      name: "guerreiro".tr(),
      description: "guerreiroDesc".tr(),
      icon: MdiIcons.sword,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      accessorySize: 24.0,
      flipAccessoryBase: true,
      color: Pallete.cinzaCla, 
      maxHp: 4,
      maxDash: 2,
      speed: 75.0,
      damage: 10.0,
      fireRate: 0.4,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.2,
      bltSpeed: 650,
      startingShield: 1,
      bltImage: 'sprites/projeteis/corte.png',
      weaponImage: 'sprites/projeteis/espada.png',
      armaBalanca: true,
      bltSize: 12.0,
    ),
    CharacterClass(
      id: 'piromante',
      name: "piromante".tr(),
      description: "piromanteDesc".tr(),
      icon: MdiIcons.fire, 
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      accessorySize: 24.0,
      color: Pallete.laranja,
      maxHp: 4, 
      maxDash: 2,
      speed: 75.0, 
      damage: 10.0, 
      noDamage: true,
      fireRate: 0.05, 
      critChance: 5,
      critDamage: 2,
      dashCooldown: 3.0,
      startingItems: [
        CollectibleType.fogo, 
        CollectibleType.dotBook
      ],
      itemsExcluidos: [
        //CollectibleType.damage,
        //CollectibleType.audacious,
        //CollectibleType.steroids,
        //CollectibleType.activeConvBruta,
        CollectibleType.activeRitualDagger,
        CollectibleType.goldDmg,
        CollectibleType.mine,
      ],
      stackBonus: 5,
      dot: 2,
      attackRange: 0.6,
      bltImage: 'sprites/projeteis/fogo.png',
    ),
    CharacterClass(
      id: 'ladino',
      name: "ladino".tr(),
      description: "ladinoDesc".tr(),
      icon: MdiIcons.knifeMilitary, 
      accessorySize: 12.0,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      acessoryAngle: pi/2,
      color:  Pallete.lilas,
      maxHp: 2, 
      maxDash: 3,
      speed: 110.0, 
      damage: 8.0,
      fireRate: 0.25, 
      critChance: 25, 
      critDamage: 2.5,
      dashCooldown: 1.0, 
      startingBombs: 1,
      startingKeys: 1,
      attackRange: 0.5,
      isUnlockedByDefault: true,
      bltImage: 'sprites/projeteis/adaga.png',
      unlockConditionText: "ladinoCond".tr(),
    ),
    CharacterClass(
      id: 'arqueiro',
      name: "arqueiro".tr(),
      description: "arqueiroDesc".tr(),
      icon: MdiIcons.bowArrow, 
      accessorySize: 24.0,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      acessoryAngle: pi/2,
      color:  Pallete.verdeEsc,
      maxHp: 4, 
      maxDash: 2,
      speed: 90.0, 
      damage: 10.0,
      fireRate: 0.5, 
      critChance: 5, 
      critDamage: 1.5,
      dashCooldown: 2.0, 
      attackRange: 1.0,
      isUnlockedByDefault: true,
      unlockConditionText: "arqueiroCond".tr(),
      bltImage: 'sprites/projeteis/flecha.png',
      weaponImage: 'sprites/projeteis/arco.png',
      bltSize: 4.0,
    ),
    CharacterClass(
      id: 'exterminador',
      name: "exterminador".tr(),
      description: "exterminadorDesc".tr(),
      icon: MdiIcons.sunglasses, 
      accessorySize: 6.0,
      accessoryOffsetX: 18.0, 
      accessoryOffsetY: 3.0,
      color:  Pallete.lilas,
      maxHp: 4, 
      maxDash: 2,
      speed: 75.0, 
      damage: 10.0,
      fireRate: 0.5, 
      critChance: 5, 
      critDamage: 1.5,
      dashCooldown: 2.0, 
      attackRange: 0.2,
      isShotgun: true,
      isUnlockedByDefault: false,
      weaponImage: 'sprites/projeteis/escopeta.png',
      unlockConditionText: "exterminadorCond".tr(),
      itemsExcluidos: [
        CollectibleType.tripleShot,
      ],
    ),
    CharacterClass(
      id: "defensor",
      name: "defensor".tr(),
      description: "defensorDesc".tr(),
      icon: MdiIcons.shield,
      accessoryOffsetX: 8.0, 
      accessoryOffsetY: 15.0,
      accessorySize: 16.0,
      color: Pallete.lilas, 
      maxHp: 4,
      maxDash: 2,
      speed: 75.0,
      damage: 10.0,
      fireRate: 0.4,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.7,
      startingShield: 2,
      startingItems: [
        CollectibleType.orbitalShield,
      ],
      isUnlockedByDefault: false,
      unlockConditionText: "defensorCond".tr(),
    ),
    CharacterClass(
      id: "licantropo",
      name: "licantropo".tr(),
      description: "licantropoDesc".tr(),
      icon: MdiIcons.dogSide,
      semAcessorio: true,
      accessoryOffsetX: 8.0, 
      accessoryOffsetY: 15.0,
      accessorySize: 16.0,
      color: Pallete.marrom, 
      maxHp: 4,
      maxDash: 2,
      speed: 75.0,
      damage: 10.0,
      fireRate: 0.4,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.7,
      startingItems: [
        CollectibleType.activeLicantropia,
      ],
      itemsExcluidos: [
        CollectibleType.activeUnicorn,
        CollectibleType.activePacmen,
      ],
      isUnlockedByDefault: true,
      bltImage: 'sprites/projeteis/arranhao.png',
      unlockConditionText: "licantropoCond".tr(),
    ),
    CharacterClass(
      id: "multidao",
      name: "multidao".tr(),
      description: "multidaoDesc".tr(),
      icon: MdiIcons.humanQueue,
      semAcessorio: true,
      mudaIcone: true,
      color: Pallete.branco, 
      maxHp: 6,
      maxDash: 2,
      speed: 75.0,
      damage: 10.0,
      fireRate: 0.8,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.7,
      startingItems: [
        CollectibleType.molotov,
      ],
      itemsExcluidos: [
        CollectibleType.tripleShot,
        CollectibleType.mine,
        CollectibleType.laser,
        CollectibleType.homing,
        CollectibleType.activeHoming,
      ],
      isUnlockedByDefault: true,
      unlockConditionText: "multidaoCond".tr(),
    ),
    CharacterClass(
      id: "bomberman",
      name: "bomberman".tr(),
      description: "bombermanDesc".tr(),
      icon: MdiIcons.bomb,
      accessoryOffsetX: 18.0, 
      accessoryOffsetY: 3.0,
      accessorySize: 24.0,
      color: Pallete.lilas, 
      maxHp: 4,
      maxDash: 2,
      speed: 75.0,
      damage: 10.0,
      fireRate: 0.8,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.7,
      isBomber: true,
      startingItems: [
        CollectibleType.activeKamikaze,
      ],
      itemsExcluidos: [
        CollectibleType.tripleShot,
        CollectibleType.mine,
        CollectibleType.laser,
        CollectibleType.homing,
        CollectibleType.activeHoming,
      ],
      isUnlockedByDefault: true,
      unlockConditionText: "bombermanCond".tr(),
    ),
    CharacterClass(
      id: "debug",
      name: "debug".tr(),
      description: "debug".tr(),
      icon: MdiIcons.bug,
      accessoryOffsetX: 30.0, 
      accessoryOffsetY: 10.0,
      accessorySize: 24.0,
      flipAccessoryBase: true,
      color: Pallete.marrom, 
      maxHp: 4,
      maxDash: 2,
      speed: 75.0,
      damage: 100.0,
      fireRate: 0.4,
      critChance: 5,
      critDamage: 1.5,
      dashCooldown: 2.5,
      attackRange: 0.7,
      startingShield: 1,
      startingBombs: 5,
      startingKeys: 5,
    ),
  ];

  static CharacterClass getClassById(String? id) {
    if (id == null) return classes.first; // Retorna o Guerreiro por defeito se for nulo

    for (var charClass in classes) {
      if (charClass.id == id) {
        return charClass;
      }
    }
    
    // Se não encontrar o ID (por exemplo, se mudou o nome da classe num update), retorna a primeira
    return classes.first; 
  }

}