import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';

class BestiaryEntry {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final double baseHealth;
  final double speed;
  final Color cor;
  final bool isChamp;

  BestiaryEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.baseHealth,
    required this.speed,
    required this.cor,
    this.isChamp = false
  });
}

// Lista completa gerada a partir da EnemyFactory
final List<BestiaryEntry> fullBestiary = [
  // --- INICIAIS / ESPECIAIS ---
  BestiaryEntry(
    id: 'champ1',
    name: 'champ1Name'.tr(),
    description: 'champ1Descr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/dummy.png',
    baseHealth: 2.5,
    speed: 1,
    cor: Pallete.vermelho,
    isChamp: true
  ),
  BestiaryEntry(
      id: 'champ2',
      name: 'champ2Name'.tr(),
      description: 'champ2Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.lilas,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ3',
      name: 'champ3Name'.tr(),
      description: 'champ3Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1.5,
      cor: Pallete.amarelo,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ4',
      name: 'champ4Name'.tr(),
      description: 'champ4Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.azulCla,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ5',
      name: 'champ5Name'.tr(),
      description: 'champ5Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.verdeEsc,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ6',
      name: 'champ6Name'.tr(),
      description: 'champ6Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.laranja,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ7',
      name: 'champ7Name'.tr(),
      description: 'champ7Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.branco.withOpacity(0.2),
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ8',
      name: 'champ8Name'.tr(),
      description: 'champ8Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.cinzaCla,
      isChamp: true
  ),
  BestiaryEntry(
      id: 'champ9',
      name: 'champ9Name'.tr(),
      description: 'champ9Descr'.tr(),
      imagePath: 'assets/images/sprites/inimigos/dummy.png',
      baseHealth: 2,
      speed: 1,
      cor: Pallete.rosa,
      isChamp: true
  ),
  BestiaryEntry(
    id: 'dummy',
    name: 'dummyName'.tr(),
    description: 'dummyDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/dummy.png',
    baseHealth: 1000.0,
    speed: 50.0,
    cor: Pallete.bege,
  ),
  BestiaryEntry(
    id: 'agiota',
    name: 'agiotaName'.tr(), // Ou "agiota".tr() se você preferir
    description: 'agiotaDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/agiota.png',
    baseHealth: 1200.0, // hpBossMedio
    speed: 50.0,
    cor: Pallete.laranja,
  ),

  // --- FASE 1: MASMORRA CLÁSSICA ---
  BestiaryEntry(
    id: 'rat',
    name: 'ratName'.tr(),
    description: 'ratDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/rat.png',
    baseHealth: 30.0, // hpFraco
    speed: 50.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'mushroom',
    name: 'mushroomName'.tr(),
    description: 'mushroomDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/mushroom.png',
    baseHealth: 30.0, // hpFraco
    speed: 0.0,
    cor: Pallete.rosa,
  ),
  BestiaryEntry(
    id: 'worm',
    name: 'wormName'.tr(),
    description: 'wormDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/worm.png',
    baseHealth: 30.0, // hpFraco
    speed: 50.0,
    cor: Pallete.vinho,
  ),
  BestiaryEntry(
    id: 'bug',
    name: 'bugName'.tr(),
    description: 'bugDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/bug.png',
    baseHealth: 30.0, // hpFraco
    speed: 40.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'snail',
    name: 'snailName'.tr(),
    description: 'snailDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/snail.png',
    baseHealth: 50.0, // hpMedio
    speed: 30.0,
    cor: Pallete.verdeCla,
  ),
  BestiaryEntry(
    id: 'bee',
    name: 'beeName'.tr(),
    description: 'beeDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/bee.png',
    baseHealth: 15.0, // hpMinimo
    speed: 50.0,
    cor: Pallete.amarelo,
  ),
  BestiaryEntry(
    id: 'beehive',
    name: 'beehiveName'.tr(),
    description: 'beehiveDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/beehive.png',
    baseHealth: 30.0, // hpFraco
    speed: 0.0,
    cor: Pallete.laranja,
  ),
  BestiaryEntry(
    id: 'slimeP',
    name: 'slimePName'.tr(),
    description: 'slimePDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/slimeP.png',
    baseHealth: 15.0, // hpMinimo
    speed: 60.0,
    cor: Pallete.verdeCla,
  ),
  BestiaryEntry(
    id: 'slime',
    name: 'slimeName'.tr(),
    description: 'slimeDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/slime.png',
    baseHealth: 50.0, // hpMedio
    speed: 40.0,
    cor: Pallete.verdeCla,
  ),
  BestiaryEntry(
    id: 'ratKing',
    name: 'ratKingName'.tr(),
    description: 'ratKingDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/ratKing.png',
    baseHealth: 1000.0, // hpBossFraco
    speed: 40.0,
    cor: Pallete.laranja,
  ),

  // --- FASE 2: ANIMAIS / SELVA ---
  BestiaryEntry(
    id: 'rabbit',
    name: 'rabbitName'.tr(),
    description: 'rabbitDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/rabbit.png',
    baseHealth: 50.0 * 2, // hpMedio
    speed: 0.0,
    cor: Pallete.cinzaCla,
  ),
  BestiaryEntry(
    id: 'unicorn',
    name: 'unicornName'.tr(),
    description: 'unicornDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/unicorn.png',
    baseHealth: 70.0 * 2, // hpForte
    speed: 50.0,
    cor: Pallete.bege,
  ),
  BestiaryEntry(
    id: 'bird',
    name: 'birdName'.tr(),
    description: 'birdDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/bird.png',
    baseHealth: 50.0 * 2, // hpMedio
    speed: 40.0,
    cor: Pallete.azulCla,
  ),
  BestiaryEntry(
    id: 'elephant',
    name: 'elephantName'.tr(),
    description: 'elephantDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/elephant.png',
    baseHealth: 120.0 * 2, // hpTanque
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'snake',
    name: 'snakeName'.tr(),
    description: 'snakeDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/snake.png',
    baseHealth: 50.0 * 2, // hpMedio
    speed: 30.0,
    cor: Pallete.verdeEsc,
  ),
  BestiaryEntry(
    id: 'tortoise',
    name: 'tortoiseName'.tr(),
    description: 'tortoiseDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/tortoise.png',
    baseHealth: 100.0 * 2, // hpResistente
    speed: 30.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'besta',
    name: 'bestaName'.tr(),
    description: 'bestaDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/besta.png',
    baseHealth: 2000.0 * 2, // hpBossForte
    speed: 50.0,
    cor: Pallete.bege,
  ),


  // --- FASE 3: CEMITÉRIO / TERROR ---
  BestiaryEntry(
    id: 'bat',
    name: 'batName'.tr(),
    description: 'batDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/bat.png',
    baseHealth: 50.0 * 3, // hpMedio
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'spider',
    name: 'spiderName'.tr(),
    description: 'spiderDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/spider.png',
    baseHealth: 50.0 * 3, // hpMedio
    speed: 40.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'ghost',
    name: 'ghostName'.tr(),
    description: 'ghostDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/ghost.png',
    baseHealth: 70.0 * 3, // hpForte
    speed: 40.0,
    cor: Pallete.cinzaCla,
  ),
  BestiaryEntry(
    id: 'coffin',
    name: 'coffinName'.tr(),
    description: 'coffinDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/coffin.png',
    baseHealth: 70.0 * 3, // hpForte
    speed: 0.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'mare',
    name: 'mareName'.tr(),
    description: 'mareDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/mare.png',
    baseHealth: 70.0 * 3, // hpForte
    speed: 40.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'headless',
    name: 'headlessName'.tr(),
    description: 'headlessDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/headless.png',
    baseHealth: 70.0 * 3, // hpForte
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'dullahan',
    name: 'dullahanName'.tr(),
    description: 'dullahanDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/dullahan.png',
    baseHealth: 1200.0 * 3, // hpBossMedio
    speed: 50.0,
    cor: Pallete.lilas,
  ),

  // --- FASE 4: XADREZ / REALEZA ---
  BestiaryEntry(
    id: 'knight',
    name: 'knightName'.tr(),
    description: 'knightDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/knight.png',
    baseHealth: 70.0 * 4, // hpForte
    speed: 40.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'pawn',
    name: 'pawnName'.tr(),
    description: 'pawnDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/pawn.png',
    baseHealth: 50.0 * 4, // hpMedio
    speed: 40.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'rook',
    name: 'rookName'.tr(),
    description: 'rookDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/rook.png',
    baseHealth: 100.0 * 4, // hpResistente
    speed: 0.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'bishop',
    name: 'bishopName'.tr(),
    description: 'bishopDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/bishop.png',
    baseHealth: 50.0 * 4, // hpMedio
    speed: 40.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'king',
    name: 'kingName'.tr(),
    description: 'kingDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/king.png',
    baseHealth: 50.0 * 4, // hpMedio
    speed: 30.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'queen',
    name: 'queenName'.tr(),
    description: 'queenDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/queen.png',
    baseHealth: 70.0 * 4, // hpForte
    speed: 40.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'trueQueen',
    name: 'trueQueenName'.tr(),
    description: 'trueQueenDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/trueQueen.png',
    baseHealth: 2000.0 * 4, // hpBossForte
    speed: 60.0,
    cor: Pallete.bege,
  ),

  // --- FASE 5: AQUÁTICA ---
  BestiaryEntry(
    id: 'jellyfish',
    name: 'jellyfishName'.tr(),
    description: 'jellyfishDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/jellyfish.png',
    baseHealth: 50.0 * 5, // hpMedio
    speed: 30.0,
    cor: Pallete.azulCla,
  ),
  BestiaryEntry(
    id: 'anemona',
    name: 'anemonaName'.tr(),
    description: 'anemonaDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/anemona.png',
    baseHealth: 120.0 * 5, // hpTanque
    speed: 0.0,
    cor: Pallete.azulCla,
  ),
  BestiaryEntry(
    id: 'fish',
    name: 'fishName'.tr(),
    description: 'fishDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/fish.png',
    baseHealth: 50.0 * 5, // hpMedio
    speed: 40.0,
    cor: Pallete.azulCla,
  ),
  BestiaryEntry(
    id: 'dolphin',
    name: 'dolphinName'.tr(),
    description: 'dolphinDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/dolphin.png',
    baseHealth: 70.0 * 5, // hpForte
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'shark',
    name: 'sharkName'.tr(),
    description: 'sharkDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/shark.png',
    baseHealth: 70.0 * 5, // hpForte
    speed: 40.0,
    cor: Pallete.cinzaCla,
  ),
  BestiaryEntry(
    id: 'turtle',
    name: 'turtleName'.tr(),
    description: 'turtleDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/turtle.png',
    baseHealth: 120.0 * 5, // hpTanque
    speed: 40.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'megalodon',
    name: 'megalodonName'.tr(),
    description: 'megalodonDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/megalodon.png',
    baseHealth: 2000.0 * 5, // hpBossForte
    speed: 70.0,
    cor: Pallete.cinzaCla,
  ),

  // --- ORCS / TRIBAL ---
  BestiaryEntry(
    id: 'orcShaman',
    name: 'orcShamanName'.tr(),
    description: 'orcShamanDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/orcShaman.png',
    baseHealth: 50.0 * 6, // hpMedio
    speed: 40.0,
    cor: Pallete.verdeEsc,
  ),
  BestiaryEntry(
    id: 'goblin',
    name: 'goblinName'.tr(),
    description: 'goblinDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/goblin.png',
    baseHealth: 30.0 * 6, // hpFraco
    speed: 40.0,
    cor: Pallete.verdeCla,
  ),
  BestiaryEntry(
    id: 'orc',
    name: 'orcName'.tr(),
    description: 'orcDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/orc.png',
    baseHealth: 70.0 * 6, // hpForte
    speed: 40.0,
    cor: Pallete.verdeCla,
  ),
  BestiaryEntry(
    id: 'orcBerserk',
    name: 'orcBerserkName'.tr(),
    description: 'orcBerserkDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/orcBerserk.png',
    baseHealth: 70.0 * 6, // hpForte
    speed: 60.0,
    cor: Pallete.vermelho,
  ),
  BestiaryEntry(
    id: 'warg',
    name: 'wargName'.tr(),
    description: 'wargDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/warg.png',
    baseHealth: 50.0 * 6, // hpMedio
    speed: 50.0,
    cor: Pallete.marrom,
  ),
  BestiaryEntry(
    id: 'orcDefensor',
    name: 'orcDefensorName'.tr(),
    description: 'orcDefensorDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/orcDefensor.png',
    baseHealth: 120.0 * 6, // hpTanque
    speed: 30.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'orcChief',
    name: 'orcChiefName'.tr(),
    description: 'orcChiefDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/orcChief.png',
    baseHealth: 2000.0 * 6, // hpBossForte
    speed: 40.0,
    cor: Pallete.verdeEsc,
  ),

  // --- CYBERPUNK / MECÂNICA ---
  BestiaryEntry(
    id: 'turret1',
    name: 'turret1Name'.tr(),
    description: 'turret1Descr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/turret1.png',
    baseHealth: 30.0 * 7, // hpFraco
    speed: 0.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'turret2',
    name: 'turret2Name'.tr(),
    description: 'turret2Descr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/turret2.png',
    baseHealth: 50.0 * 7, // hpMedio
    speed: 0.0,
    cor: Pallete.vermelho,
  ),
  BestiaryEntry(
    id: 'drone',
    name: 'droneName'.tr(),
    description: 'droneDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/drone.png',
    baseHealth: 50.0 * 7, // hpMedio
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'cyborg',
    name: 'cyborgName'.tr(),
    description: 'cyborgDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/cyborg.png',
    baseHealth: 70.0 * 7, // hpForte
    speed: 30.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'tank',
    name: 'tankName'.tr(),
    description: 'tankDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/tank.png',
    baseHealth: 50.0 * 7, // hpMedio
    speed: 30.0,
    cor: Pallete.azulCla,
  ),
  BestiaryEntry(
    id: 'tank2',
    name: 'tank2Name'.tr(),
    description: 'tank2Descr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/tank2.png',
    baseHealth: 50.0 * 7, // hpMedio
    speed: 30.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'mecha',
    name: 'mechaName'.tr(),
    description: 'mechaDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/mecha.png',
    baseHealth: 2000.0 * 7, // hpBossForte
    speed: 40.0,
    cor: Pallete.lilas,
  ),

  // --- LOVECRAFT / CÓSMICO ---
  BestiaryEntry(
    id: 'olho',
    name: 'olhoName'.tr(),
    description: 'olhoDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/olho.png',
    baseHealth: 30.0 * 8, // hpFraco
    speed: 50.0,
    cor: Pallete.rosa,
  ),
  BestiaryEntry(
    id: 'cultista',
    name: 'cultistaName'.tr(),
    description: 'cultistaDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/cultista.png',
    baseHealth: 50.0 * 8, // hpMedio
    speed: 30.0,
    cor: Pallete.amarelo,
  ),
  BestiaryEntry(
    id: 'starspawn',
    name: 'starspawnName'.tr(),
    description: 'starspawnDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/starspawn.png',
    baseHealth: 50.0 * 8, // hpMedio
    speed: 40.0,
    cor: Pallete.verdeEsc,
  ),
  BestiaryEntry(
    id: 'elder',
    name: 'elderName'.tr(),
    description: 'elderDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/elder.png',
    baseHealth: 50.0 * 8, // hpMedio
    speed: 40.0,
    cor: Pallete.bege,
  ),
  BestiaryEntry(
    id: 'rastejante',
    name: 'rastejanteName'.tr(),
    description: 'rastejanteDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/rastejante.png',
    baseHealth: 70.0 * 8, // hpForte
    speed: 30.0,
    cor: Pallete.vinho,
  ),
  BestiaryEntry(
    id: 'deepone',
    name: 'deeponeName'.tr(),
    description: 'deeponeDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/deepone.png',
    baseHealth: 70.0 * 8, // hpForte
    speed: 50.0,
    cor: Pallete.lilas,
  ),
  BestiaryEntry(
    id: 'olhoBoss',
    name: 'olhoBossName'.tr(),
    description: 'olhoBossDescr'.tr(),
    imagePath: 'assets/images/sprites/inimigos/olhoBoss.png',
    baseHealth: 1200.0 * 8, // hpBossMedio
    speed: 40.0,
    cor: Pallete.lilas,
  ),
];