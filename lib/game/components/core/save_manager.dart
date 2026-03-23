import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart'; // NECESSÁRIO PARA O ICONDATA E COLOR
import '../../tower_game.dart'; 

class SaveManager {
  static const String _saveKey = 'active_run_state';

  static Future<void> saveRun(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> serializedItems = game.player.getAcquiredItemsList().map((item) {
      return {
        'name': item.name,
        'description': item.description,
        'iconCodePoint': item.icon.codePoint, 
        'iconFontFamily': item.icon.fontFamily, 
        'iconFontPackage': item.icon.fontPackage,
        'colorValue': item.color.value,
      };
    }).toList();

    final Map<String, dynamic> runData = {
      // --- PROGRESSO DO MUNDO ---
      'level': game.currentLevelNotifier.value,
      'room': game.currentRoomNotifier.value,

      'coins': game.coinsNotifier.value,
      'keys': game.keysNotifier.value,
      'souls': game.progress.soulsNotifier.value,

      'usouBomba': game.usouBomba,
      
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
      
    };

    String jsonString = jsonEncode(runData);
    await prefs.setString(_saveKey, jsonString);
    print("💾 Run salva com sucesso (Nível ${game.currentLevelNotifier.value}, Sala ${game.currentRoomNotifier.value})!");
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
    game.usouBomba = runData['usouBomba'] ?? false;

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
    // Limpa a lista atual para garantir que não vai duplicar itens ao carregar
    game.player.getAcquiredItemsList().clear();
    
    final List<dynamic>? savedItems = runData['acquiredItems'];
    if (savedItems != null) {
      for (var itemMap in savedItems) {
        // Remonta o IconData e a Cor a partir dos números salvos
        IconData recoveredIcon = IconData(
          itemMap['iconCodePoint'],
          fontFamily: itemMap['iconFontFamily'],
          fontPackage: itemMap['iconFontPackage'],
        );
        Color recoveredColor = Color(itemMap['colorValue']);

        game.player.setAcquiredItemsList(
          itemMap['type'],
          itemMap['name'],
          itemMap['description'],
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
    game.player.stackBonus = (runData['stackBonus'] ?? 0).toInt();
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
    
    print("Run (Nível ${game.currentLevelNotifier.value}) carregada com sucesso com todos os itens!");
    return runData['playerClassId'];
  }

  static Future<bool> hasSavedRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }

  static Future<void> clearSavedRun() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
    print("Save da run deletado (Game Over).");
  }
}