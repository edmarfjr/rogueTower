import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // NECESSÁRIO PARA O ICONDATA E COLOR
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import '../../tower_game.dart'; 

class SaveManager {
  static const String _saveKey = 'active_run_state';

  static Future<void> saveRun(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> serializedItems = game.player.getAcquiredItemsList().map((item) {
      return {
        // CORREÇÃO 1: Salvando o ENUM como String!
        'type': item.type.name, 
        
        'name': item.name,
        'description': item.description,
        'iconCodePoint': item.icon, 
        'colorValue': item.color.value,
      };
    }).toList();

    final Map<String, dynamic> runData = {
      // --- PROGRESSO DO MUNDO ---
      'level': game.currentLevelNotifier.value,
      'room': game.currentRoomNotifier.value,
      'salasLimpas': game.salasLimpas.toList(),

      'coins': game.coinsNotifier.value,
      'keys': game.keysNotifier.value,
      'souls': game.progress.soulsNotifier.value,

      'usouBomba': game.usouBomba,

      'difficultyMultiplier': game.difficultyMultiplier,
      'chanceChampBonus': game.chanceChampBonus,
      
      // Vida e Recursos do Jogador
      'hp': game.player.healthNotifier.value,
      'maxHp': game.player.maxHealth,
      'shield': game.player.shieldNotifier.value,
      'bombs': game.player.bombNotifier.value,
      'dash': game.player.dashNotifier.value,
      'playerClassId': game.selectedClass.id,

      // --- INVENTÁRIO DE ARTEFATOS ---
      'acquiredItems': serializedItems,

      // --- ATRIBUTOS NUMÉRICOS BASE ---
      'attackRange': game.player.attackRange,
      'damage': game.player.damage,
      'critChance': game.player.critChance,
      'critDamage': game.player.critDamage,
      'fireRate': game.player.fireRate,
      'fireRateInicial': game.player.fireRateIni,
      'moveSpeed': game.player.moveSpeed,
      'dashDuration': game.player.dashDuration,
      'dashSpeed': game.player.dashSpeed,
      'dashCooldown': game.player.dashCooldown,
      'invincibilityDuration': game.player.invincibilityDuration,
      'stackBonus': game.player.stackBonus,
      'bltSize': game.player.bltSize,
      'knockbackForce': game.player.knockbackForce,
      'sorte': game.player.sorte,
      
      // --- FLAGS E POWER-UPS (BOOLEANOS) ---
      'isBerserk': game.player.isBerserk,
      'isAudaz': game.player.isAudaz,
      'isFreeze': game.player.isFreeze,
      'isBebado': game.player.isBebado,
      'hasOrbShield': game.player.hasOrbShield,
      'hasFoice': game.player.hasFoice,
      'magicShield': game.player.magicShield,
      'hasShield': game.player.hasShield,
      'revive': game.player.revive,
      'pegouRevive': game.player.pegouRevive,
      'hasAntimateria': game.player.hasAntimateria,
      'isHoming': game.player.isHoming,
      'canBounce': game.player.canBounce,
      'isPiercing': game.player.isPiercing,
      'isSpectral': game.player.isSpectral,
      'isBurn': game.player.isBurn,
      'isPoison': game.player.isPoison,
      'isPoisonAlastra': game.player.isPoisonAlastra,
      'hasChaveNegra': game.player.hasChaveNegra,
      'isConcentration': game.player.isConcentration,
      'isOrbitalShot': game.player.isOrbitalShot,
      'isMineShot': game.player.isMineShot,
      'defensiveBurst': game.player.defensiveBurst,
      'isKinetic': game.player.isKinetic,
      'isHeavyShot': game.player.isHeavyShot,
      'hasCupon': game.player.hasCupon,
      'isBoomerang': game.player.isBoomerang,
      'isBleed': game.player.isBleed,
      'criaPocaVeneno': game.player.criaPocaVeneno,
      'fireDash': game.player.fireDash,
      'isDashDamages': game.player.isDashDamages,
      'isShotgun': game.player.isShotgun,
      'tripleShot': game.player.tripleShot,
      'isMorteiro': game.player.isMorteiro,
      'hasBattery': game.player.hasBattery,
      'hasShieldRegen': game.player.hasShieldRegen,
      'maxArtificialHealth': game.player.maxArtificialHealth,
      'artificialHealthNotifier': game.player.artificialHealthNotifier.value,
      'isShootSplits': game.player.isShootSplits,
      'confuseOnCrit': game.player.confuseOnCrit,
      'isBombSplits':game.player.isBombSplits,
      'isBombDecoy':game.player.isBombDecoy,
      'charmOnCrit':game.player.charmOnCrit,
      'isFreezeDash':game.player.isFreezeDash,
      'goldDmg':game.player.goldDmg,
      'shieldCrit':game.player.shieldCrit,
      'isCritHeal':game.player.isCritHeal,
      'isLaser':game.player.isLaser,
      'isWave':game.player.isWave,
      'isSaw':game.player.isSaw,
      'noDamage':game.player.noDamage,
      'explodeHit':game.player.explodeHit,
      'restock':game.player.restock,
      'isGlitterBomb':game.player.isGlitterBomb,
      'goldShot':game.player.goldShot,
      'clusterShot':game.player.clusterShot,
      'evasao':game.player.evasao,
      'primeiroInimigoPocaVeneno':game.player.primeiroInimigoPocaVeneno,
      'adrenalina':game.player.adrenalina,
      'eutanasia':game.player.eutanasia,
      'killCharge':game.player.killCharge,
      'voo':game.player.voo,
      'cardinalShot':game.player.cardinalShot,
      'animContrario':game.player.animContrario,
      'hurtPac':game.player.hurtPac,
      'zodiacAquarius':game.player.zodiacAquarius,
      'zodiacAries':game.player.zodiacAries,
      'zodiacCancer':game.player.zodiacCancer,
      'zodiacLeo':game.player.zodiacLeo,
      'zodiacLibra':game.player.zodiacLibra,
      'zodiacPisces':game.player.zodiacPisces,
      'zodiacTaurus':game.player.zodiacTaurus,
      'zodiacVirgo':game.player.zodiacVirgo,
      'zodiac':game.player.zodiac,
      'tempZodiacAquarius':game.player.tempZodiacAquarius,
      'tempZodiacAries':game.player.tempZodiacAries,
      'tempZodiacCancer':game.player.tempZodiacCancer,
      'tempZodiacLeo':game.player.tempZodiacLeo,
      'tempZodiacLibra':game.player.tempZodiacLibra,
      'tempZodiacPisces':game.player.tempZodiacPisces,
      'tempZodiacTaurus':game.player.tempZodiacTaurus,
      'tempZodiacVirgo':game.player.tempZodiacVirgo,
      'defensiveFairys':game.player.defensiveFairys,
      'itemExtraBoss':game.player.itemExtraBoss,
      'tempDmgGoldBonus':game.player.tempDmgGoldBonus,
      'tempDmgBonus':game.player.tempDmgBonus,
      'bombaBuracoNegro':game.player.bombaBuracoNegro,
      'retribuicao':game.player.retribuicao,
      'refletirChance':game.player.refletirChance,
      'adagaChance':game.player.adagaChance,
      'glifoEquilibrio':game.player.glifoEquilibrio,
      'bltFireHazard':game.player.bltFireHazard,
      'bltBuracoNegro':game.player.bltBuracoNegro,
      'bltSparks':game.player.bltSparks, // CORREÇÃO 2: Estava salvo como bltBuracoNegro duas vezes
      'isParalised':game.player.isParalised,
      'isFear':game.player.isFear,
      'rainbowShot':game.player.rainbowShot,
      'masterOrb':game.player.masterOrb,
      'armaImage':game.player.armaImage,
      'armaAng':game.player.armaAng,
      'armaCor':game.player.armaCor.value,
      'classImage':game.player.classImage,
      'classColor':game.player.classColor.value,
    };

    String jsonString = jsonEncode(runData);
    await prefs.setString(_saveKey, jsonString);
  }

  static Future<String?> loadRun(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (!prefs.containsKey(_saveKey)) return null;

    String? jsonString = prefs.getString(_saveKey);
    if (jsonString == null) return null;

    final Map<String, dynamic> runData = jsonDecode(jsonString);

    // --- CARREGA PROGRESSO DO MUNDO ---
    game.currentLevelNotifier.value = runData['level'] ?? 1;
    game.currentRoomNotifier.value = runData['room'] ?? 1;

    if (runData['salasLimpas'] != null) {
      game.salasLimpas = (runData['salasLimpas'] as List).map((e) => e as int).toSet();
    } else {
      game.salasLimpas = {}; 
    }

    game.usouBomba = runData['usouBomba'] ?? false;
    game.difficultyMultiplier = runData['difficultyMultiplier'] ?? 1.0;
    game.chanceChampBonus = runData['chanceChampBonus'] ?? 0.0;

    // Carrega Economia
    game.coinsNotifier.value = runData['coins'] ?? 0;
    game.keysNotifier.value = runData['keys'] ?? 0;
    game.progress.soulsNotifier.value = runData['souls'] ?? 0;

    // Carrega Recursos
    game.player.maxHealth = runData['maxHp'] ?? 6;
    game.player.healthNotifier.value = runData['hp'] ?? 6;
    game.player.shieldNotifier.value = runData['shield'] ?? 0;
    game.player.bombNotifier.value = runData['bombs'] ?? 0;
    game.player.dashNotifier.value = runData['dash'] ?? 1;

    // --- CARREGA INVENTÁRIO DE ARTEFATOS ---
    game.player.getAcquiredItemsList().clear();
    
    final List<dynamic>? savedItems = runData['acquiredItems'];
    if (savedItems != null) {
      for (var itemMap in savedItems) {
        String recoveredIcon = itemMap['iconCodePoint'] ?? '';
        
        // CORREÇÃO 3: Proteção contra cores antigas que possam ter sido salvas como null
        int savedColorValue = itemMap['colorValue'] ?? Colors.white.value;
        Color recoveredColor = Color(savedColorValue);

        // CORREÇÃO 4: Onde o erro do tipo Null estava acontecendo!
        // Transformando a string salva de volta para o Enum
        String tipoSalvoStr = itemMap['type'] as String? ?? 'passiva'; // Mude 'passiva' para o tipo padrão real
        
        CollectibleType recoveredType = CollectibleType.values.firstWhere(
          (e) => e.name == tipoSalvoStr,
          orElse: () => CollectibleType.values.first, // Pega o primeiro da lista como salvaguarda
        );

        game.player.setAcquiredItemsList(
          recoveredType, // <- Passando o enum convertido!
          itemMap['name'] ?? '',
          itemMap['description'] ?? '',
          recoveredIcon,
          recoveredColor,
        );
      }
    }

    // --- CARREGA ATRIBUTOS NUMÉRICOS BASE ---
    game.player.attackRange = (runData['attackRange'] ?? 200).toDouble();
    game.player.damage = (runData['damage'] ?? 10.0).toDouble();
    game.player.critChance = (runData['critChance'] ?? 5).toDouble();
    game.player.critDamage = (runData['critDamage'] ?? 2.0).toDouble();
    game.player.fireRate = (runData['fireRate'] ?? 0.4).toDouble();
    game.player.fireRateIni = (runData['fireRateInicial'] ?? 0.4).toDouble();
    game.player.moveSpeed = (runData['moveSpeed'] ?? 150.0).toDouble();
    game.player.dashDuration = (runData['dashDuration'] ?? 0.2).toDouble();
    game.player.dashSpeed = (runData['dashSpeed'] ?? 450).toDouble();
    game.player.dashCooldown = (runData['dashCooldown'] ?? 2.5).toDouble();
    game.player.invincibilityDuration = (runData['invincibilityDuration'] ?? 0.5).toDouble();
    game.player.bltSize = (runData['bltSize'] ?? 0.5).toDouble();
    game.player.knockbackForce = (runData['knockbackForce'] ?? 0.5).toDouble();
    game.player.stackBonus = (runData['stackBonus'] ?? 0).toInt();
    game.player.sorte = (runData['sorte'] ?? 0).toInt();
    game.player.maxArtificialHealth = (runData['maxArtificialHealth'] ?? 0).toInt();
    game.player.artificialHealthNotifier.value = (runData['artificialHealthNotifier'] ?? 0).toInt();
    game.player.velocity.setZero();
    game.player.resetAttackTimer();
    game.player.unicornTmr = 0;

    // --- CARREGA FLAGS E POWER-UPS ---
    game.player.isBerserk = runData['isBerserk'] ?? false;
    game.player.isAudaz = runData['isAudaz'] ?? false;
    game.player.isFreeze = runData['isFreeze'] ?? false;
    game.player.isBebado = runData['isBebado'] ?? false;
    game.player.hasOrbShield = runData['hasOrbShield'] ?? false;
    game.player.hasFoice = runData['hasFoice'] ?? false;
    game.player.magicShield = runData['magicShield'] ?? false;
    game.player.hasShield = runData['hasShield'] ?? false;
    game.player.revive = runData['revive'] ?? false;
    game.player.pegouRevive = runData['pegouRevive'] ?? false;
    game.player.hasAntimateria = runData['hasAntimateria'] ?? false;
    game.player.isHoming = runData['isHoming'] ?? false;
    game.player.canBounce = runData['canBounce'] ?? false;
    game.player.isPiercing = runData['isPiercing'] ?? false;
    game.player.isSpectral = runData['isSpectral'] ?? false;
    game.player.isBurn = runData['isBurn'] ?? false;
    game.player.isPoison = runData['isPoison'] ?? false;
    game.player.isPoisonAlastra = runData['isPoisonAlastra'] ?? false;
    game.player.hasChaveNegra = runData['hasChaveNegra'] ?? false;
    game.player.isConcentration = runData['isConcentration'] ?? false;
    game.player.isOrbitalShot = runData['isOrbitalShot'] ?? false;
    game.player.isMineShot = runData['isMineShot'] ?? false;
    game.player.defensiveBurst = runData['defensiveBurst'] ?? false;
    game.player.isKinetic = runData['isKinetic'] ?? false;
    game.player.isHeavyShot = runData['isHeavyShot'] ?? false;
    game.player.hasCupon = runData['hasCupon'] ?? false;
    game.player.isBoomerang = runData['isBoomerang'] ?? false;
    game.player.isBleed = runData['isBleed'] ?? false;
    game.player.criaPocaVeneno = runData['criaPocaVeneno'] ?? false;
    game.player.fireDash = runData['fireDash'] ?? false;
    game.player.isDashDamages = runData['isDashDamages'] ?? false;
    game.player.isShotgun = runData['isShotgun'] ?? false;
    game.player.tripleShot = runData['tripleShot'] ?? false;
    game.player.isMorteiro = runData['isMorteiro'] ?? false;
    game.player.hasBattery = runData['hasBattery'] ?? false;
    game.player.hasShieldRegen = runData['hasShieldRegen'] ?? false;
    game.player.isShootSplits = runData['isShootSplits'] ?? false;
    game.player.confuseOnCrit = runData['confuseOnCrit'] ?? false;
    game.player.isBombSplits = runData['isBombSplits'] ?? false;
    game.player.isBombDecoy = runData['isBombDecoy'] ?? false;
    game.player.charmOnCrit = runData['charmOnCrit'] ?? false;
    game.player.isFreezeDash = runData['isFreezeDash'] ?? false;
    game.player.goldDmg = runData['goldDmg'] ?? false;
    game.player.shieldCrit = runData['shieldCrit'] ?? false;
    game.player.isCritHeal = runData['isCritHeal'] ?? false;
    game.player.isUnicorn = false;
    game.player.isLaser = runData['isLaser'] ?? false;
    game.player.isWave = runData['isWave'] ?? false;
    game.player.isSaw = runData['isSaw'] ?? false;
    game.player.noDamage = runData['noDamage'] ?? false;
    game.player.explodeHit = runData['explodeHit'] ?? false;
    game.player.restock = runData['restock'] ?? false;
    game.player.isGlitterBomb = runData['isGlitterBomb'] ?? false;
    game.player.goldShot = runData['goldShot'] ?? false;
    game.player.clusterShot = runData['clusterShot'] ?? false;
    game.player.evasao = runData['evasao'] ?? false;
    game.player.primeiroInimigoPocaVeneno = runData['primeiroInimigoPocaVeneno'] ?? false;
    game.player.adrenalina = runData['adrenalina'] ?? false;
    game.player.eutanasia = runData['eutanasia'] ?? false;
    game.player.killCharge = runData['killCharge'] ?? false;
    game.player.voo = runData['voo'] ?? false;
    game.player.cardinalShot = runData['cardinalShot'] ?? false;
    game.player.animContrario = runData['animContrario'] ?? false;
    game.player.hurtPac = runData['hurtPac'] ?? false;
    game.player.zodiacAquarius = runData['zodiacAquarius'] ?? false;
    game.player.zodiacAries = runData['zodiacAries'] ?? false;
    game.player.zodiacCancer = runData['zodiacCancer'] ?? false;
    game.player.zodiacLeo = runData['zodiacLeo'] ?? false;
    game.player.zodiacLibra = runData['zodiacLibra'] ?? false;
    game.player.zodiacPisces = runData['zodiacPisces'] ?? false;
    game.player.zodiacTaurus = runData['zodiacTaurus'] ?? false;
    game.player.zodiacVirgo = runData['zodiacVirgo'] ?? false;
    game.player.tempZodiacAquarius = runData['tempZodiacAquarius'] ?? false;
    game.player.tempZodiacAries = runData['tempZodiacAries'] ?? false;
    game.player.tempZodiacCancer = runData['tempZodiacCancer'] ?? false;
    game.player.tempZodiacLeo = runData['tempZodiacLeo'] ?? false;
    game.player.tempZodiacLibra = runData['tempZodiacLibra'] ?? false;
    game.player.tempZodiacPisces = runData['tempZodiacPisces'] ?? false;
    game.player.tempZodiacTaurus = runData['tempZodiacTaurus'] ?? false;
    game.player.tempZodiacVirgo = runData['tempZodiacVirgo'] ?? false;
    game.player.zodiac = runData['zodiac'] ?? false;
    game.player.defensiveFairys = runData['defensiveFairys'] ?? false;
    game.player.itemExtraBoss = runData['itemExtraBoss'] ?? false;
    game.player.tempDmgGoldBonus = (runData['tempDmgGoldBonus'] ?? 0).toInt();
    game.player.tempDmgBonus = (runData['tempDmgBonus'] ?? 0).toInt();
    game.player.bombaBuracoNegro = runData['bombaBuracoNegro'] ?? false;
    game.player.retribuicao = runData['retribuicao'] ?? false;
    game.player.refletirChance = runData['refletirChance'] ?? false;
    game.player.adagaChance = runData['adagaChance'] ?? false;
    game.player.glifoEquilibrio = runData['glifoEquilibrio'] ?? false;
    game.player.bltFireHazard = runData['bltFireHazard'] ?? false;
    game.player.bltBuracoNegro = runData['bltBuracoNegro'] ?? false;
    game.player.bltSparks = runData['bltSparks'] ?? false;
    game.player.isParalised = runData['isParalised'] ?? false;
    game.player.isFear = runData['isFear'] ?? false;
    game.player.rainbowShot = runData['rainbowShot'] ?? false;
    game.player.masterOrb = (runData['masterOrb'] ?? 1.0).toDouble();
    game.player.classImage = (runData['classImage'] ?? '');
    
    int? savedColorValueClass = runData['classColor'] as int?;
    int? savedColorValueArma = runData['armaCor'] as int?;
    
    game.player.armaAng = (runData['armaAng'] ?? 0).toDouble();
    game.player.armaImage = (runData['armaImage'] ?? '');

    if (savedColorValueClass != null) {
      game.player.classColor = Color(savedColorValueClass); 
    } else {
      game.player.classColor = Pallete.branco; 
    }

    if (savedColorValueArma != null) {
      game.player.armaCor = Color(savedColorValueArma); 
    } else {
      game.player.armaCor = Pallete.branco; 
    }
    
   // print("Run (Nível ${game.currentLevelNotifier.value}) carregada com sucesso com todos os itens!");
    return runData['playerClassId'];
  }

  static Future<bool> hasSavedRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  static Future<void> clearSavedRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
   // print("Save da run deletado (Game Over).");
  }
}