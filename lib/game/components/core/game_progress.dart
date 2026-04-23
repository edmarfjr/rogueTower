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

  final ValueNotifier<int> soulsNotifier = ValueNotifier(0);
  final ValueNotifier<int> bankNotifier = ValueNotifier(0);

  final ValueNotifier<String> languageNotifier = ValueNotifier('en');

  int get bankBalance => bankNotifier.value;
  
  List<String> unlockedItems = [];
  List<String> discoveredItems = [];

  // Getter para facilitar o acesso ao valor int puro se precisar
  int get souls => soulsNotifier.value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Atualiza o .value do notificador
    soulsNotifier.value = prefs.getInt(_soulsKey) ?? 0;
    bankNotifier.value = prefs.getInt(_bankKey) ?? 0;
    unlockedItems = prefs.getStringList(_unlocksKey) ?? [];
    discoveredItems = prefs.getStringList(_discoveredKey) ?? [];

    // --- LÓGICA DO IDIOMA ---
    // Carrega o idioma salvo ou usa 'pt' como padrão
    String savedLang = prefs.getString(_langKey) ?? 'pt';
    languageNotifier.value = savedLang;
    
    // Aplica o idioma na classe I18n IMEDIATAMENTE ao carregar o jogo
    I18n.currentLanguage = savedLang;
  }

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
     // print("🎉 Nova classe desbloqueada no Save: $classId");
      
      return true; 
    }
    
    return false; 
  }

  Future<void> addSouls(int amount) async {
    // Atualiza o notificador (o HUD vai ver isso instantaneamente)
    soulsNotifier.value += amount;
    
    // Salva no disco
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

  // Depositar: Aumenta o saldo do banco e salva
  Future<void> depositToBank(int amount) async {
    bankNotifier.value += amount;
    await _saveBank();
  }

  // Sacar: Diminui o saldo do banco e salva (retorna true se sucesso)
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
     // print("📖 Novo item catalogado no Diário: $itemId");
    }
  }

  Future<void> changeLanguage(String lang) async {
    languageNotifier.value = lang;
    I18n.currentLanguage = lang; // Atualiza a classe de traduções
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang); // Salva no disco
  }

  Future<void> loadSettings(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carrega o Áudio (se não existir, usa os valores padrão: 1.0, 0.5, false)
    AudioManager.sfxVolume = prefs.getDouble('sfxVolume') ?? 1.0;
    AudioManager.bgmVolume = prefs.getDouble('bgmVolume') ?? 0.5;
    
    bool mutedMusic = prefs.getBool('isMutedMusic') ?? false;
    AudioManager.toggleMuteMusic(mutedMusic);

    bool mutedSfx = prefs.getBool('isMutedSfx') ?? false;
    AudioManager.toggleMuteSfx(mutedSfx);

    // Carrega os Gráficos
    game.useCRTEffect = prefs.getBool('useCRTEffect') ?? true;
  }

  // --- SALVAR CONFIGURAÇÕES ---
  // Chame isso sempre que o jogador mexer em algum slider ou checkbox
  Future<void> saveSettings(TowerGame game) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setDouble('sfxVolume', AudioManager.sfxVolume);
    await prefs.setDouble('bgmVolume', AudioManager.bgmVolume);
    await prefs.setBool('isMutedMusic', AudioManager.isMutedMusic);
    await prefs.setBool('isMutedSfx', AudioManager.isMutedSfx);
    await prefs.setBool('useCRTEffect', game.useCRTEffect);
  }
}