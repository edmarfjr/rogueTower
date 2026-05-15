import 'dart:convert';

import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/character_class.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/tower_game.dart';
import 'package:flutter/foundation.dart'; // Necessário para ValueNotifier
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static const String _soulsKey = 'player_souls';
  static const String _unlocksKey = 'unlocked_items';
  static const String _bankKey = 'bank_balance';
  static const String _langKey = 'game_language';
  static const String _unlockedClassesKey = 'unlocked_classes';
  static const String _discoveredKey = 'discovered_items';
  
  // --- NOVA CHAVE DO BESTIÁRIO ---
  static const String _bestiaryKey = 'bestiary_kills'; 
  static const String _enemyKillsCountKey = 'enemy_kills_count';

  final ValueNotifier<int> soulsNotifier = ValueNotifier(0);
  final ValueNotifier<int> bankNotifier = ValueNotifier(0);

  final ValueNotifier<String> languageNotifier = ValueNotifier('en');

  static final ValueNotifier<bool> crtEnabled = ValueNotifier<bool>(true);

  int get bankBalance => bankNotifier.value;
  
  List<String> unlockedItems = [];
  List<String> discoveredItems = [];
  
  // --- LISTA DE INIMIGOS DESCOBERTOS ---
  List<String> bestiaryKills = [];
  Map<String, int> enemyKillCounts = {};
  

  // Getter para facilitar o acesso ao valor int puro se precisar
  int get souls => soulsNotifier.value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Atualiza o .value do notificador
    soulsNotifier.value = prefs.getInt(_soulsKey) ?? 0;
    bankNotifier.value = prefs.getInt(_bankKey) ?? 0;
    unlockedItems = prefs.getStringList(_unlocksKey) ?? [];
    discoveredItems = prefs.getStringList(_discoveredKey) ?? [];
    
    // CARREGA O BESTIÁRIO SALVO
    bestiaryKills = prefs.getStringList(_bestiaryKey) ?? [];

    String? killsJson = prefs.getString(_enemyKillsCountKey);
    if (killsJson != null) {
      // Converte o texto JSON salvo de volta para um Mapa do Dart
      enemyKillCounts = Map<String, int>.from(jsonDecode(killsJson));
    }
    

    // --- LÓGICA DO IDIOMA ---
    // Carrega o idioma salvo ou usa 'pt' como padrão
    String savedLang = prefs.getString(_langKey) ?? 'pt';
    languageNotifier.value = savedLang;
    
    // Aplica o idioma na classe I18n IMEDIATAMENTE ao carregar o jogo
    I18n.currentLanguage = savedLang;
  }

  // ... (MANTENHA OS MÉTODOS DE CLASSE, CRT E BANK IGUAIS AO SEU CÓDIGO) ...
  static Future<bool> isClassUnlocked(CharacterClass charClass) async {
    if (charClass.isUnlockedByDefault) return true;
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedList = prefs.getStringList(_unlockedClassesKey) ?? [];
    return unlockedList.contains(charClass.id);
  }

  static Future<bool> unlockClass(String classId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> unlockedList = prefs.getStringList(_unlockedClassesKey) ?? [];
    if (!unlockedList.contains(classId)) {
      unlockedList.add(classId);
      await prefs.setStringList(_unlockedClassesKey, unlockedList);
      return true; 
    }
    return false; 
  }

  static Future<void> changeCrtEffect(bool isEnabled, TowerGame game) async {
    crtEnabled.value = isEnabled;
    game.useCRTEffect = isEnabled; 
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useCRTEffect', isEnabled); 
  }

  Future<void> addSouls(int amount) async {
    soulsNotifier.value += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_soulsKey, soulsNotifier.value);
  }

  Future<bool> spendSouls(int amount) async {
    if (soulsNotifier.value >= amount) {
      soulsNotifier.value -= amount;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_soulsKey, soulsNotifier.value);
      return true;
    }
    return false;
  }

  Future<void> _saveBank() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_bankKey, bankNotifier.value);
  }

  Future<void> depositToBank(int amount) async {
    bankNotifier.value += amount;
    await _saveBank();
  }

  Future<bool> withdrawFromBank(int amount) async {
    if (bankNotifier.value >= amount) {
      bankNotifier.value -= amount;
      await _saveBank();
      return true;
    }
    return false;
  }

  Future<void> unlockItem(String itemId) async {
    if (!unlockedItems.contains(itemId)) {
      unlockedItems.add(itemId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_unlocksKey, unlockedItems);
    }
  }

  bool isUnlocked(String itemId) {
    return unlockedItems.contains(itemId);
  }

  Future<void> discoverItem(String itemId) async {
    if (!discoveredItems.contains(itemId)) {
      discoveredItems.add(itemId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_discoveredKey, discoveredItems);
    }
  }

  // ========================================================
  // --- NOVA FUNÇÃO: DESCOBRIR INIMIGO PELO PATH DA IMAGEM
  // ========================================================
  Future<void> discoverEnemy(String imagePath, {bool isBoss = false, bool isChamp = false}) async {
    String enemyId = '';
    if(isChamp){
      enemyId = 'champ$imagePath';
    }else{
      String fileName = imagePath.split('/').last;
      enemyId = fileName.replaceAll('.png', '');
    }
    

    // Se o inimigo já está 100% desbloqueado no bestiário, não precisamos fazer mais nada
    if (bestiaryKills.contains(enemyId)) return;

    // Incrementa a contagem de mortes deste ID específico (se for nulo, começa em 0 + 1)
    enemyKillCounts[enemyId] = (enemyKillCounts[enemyId] ?? 0) + 1;
    
    // Salva o novo placar no SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_enemyKillsCountKey, jsonEncode(enemyKillCounts));

    // Define a meta: 1 se for Boss, 10 se for inimigo comum
    int meta = isBoss ? 1 : isChamp? 5: 10;

    // Se bateu a meta, finalmente libera a visualização dele no diário!
    if (enemyKillCounts[enemyId]! >= meta) {
      bestiaryKills.add(enemyId);
      await prefs.setStringList(_bestiaryKey, bestiaryKills);
      //print("📖 BESTIÁRIO: O monstro '$enemyId' foi totalmente desbloqueado!");
    } //else {
     // print("⚔️ BESTIÁRIO: Progresso do '$enemyId' (${enemyKillCounts[enemyId]}/$meta)");
   // }
  }

  Future<void> changeLanguage(String lang) async {
    I18n.currentLanguage = lang; 
    languageNotifier.value = lang;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang); 
  }

  Future<void> loadSettings(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    
    AudioManager.sfxVolume = prefs.getDouble('sfxVolume') ?? 1.0;
    AudioManager.bgmVolume = prefs.getDouble('bgmVolume') ?? 0.5;
    
    bool mutedMusic = prefs.getBool('isMutedMusic') ?? false;
    AudioManager.toggleMuteMusic(mutedMusic);

    bool mutedSfx = prefs.getBool('isMutedSfx') ?? false;
    AudioManager.toggleMuteSfx(mutedSfx);

    bool savedCrt = prefs.getBool('useCRTEffect') ?? true;
    crtEnabled.value = savedCrt;
    game.useCRTEffect = savedCrt;
  }

  Future<void> saveSettings(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble('sfxVolume', AudioManager.sfxVolume);
    await prefs.setDouble('bgmVolume', AudioManager.bgmVolume);
    await prefs.setBool('isMutedMusic', AudioManager.isMutedMusic);
    await prefs.setBool('isMutedSfx', AudioManager.isMutedSfx);
  }
}