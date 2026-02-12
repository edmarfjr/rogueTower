import 'package:flutter/foundation.dart'; // Necessário para ValueNotifier
import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  static const String _soulsKey = 'player_souls';
  static const String _unlocksKey = 'unlocked_items';
  static const String _bankKey = 'bank_balance';

  final ValueNotifier<int> soulsNotifier = ValueNotifier(0);
  final ValueNotifier<int> bankNotifier = ValueNotifier(0);

  int get bankBalance => bankNotifier.value;
  
  List<String> unlockedItems = [];

  // Getter para facilitar o acesso ao valor int puro se precisar
  int get souls => soulsNotifier.value;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Atualiza o .value do notificador
    soulsNotifier.value = prefs.getInt(_soulsKey) ?? 0;
    bankNotifier.value = prefs.getInt(_bankKey) ?? 0;
    unlockedItems = prefs.getStringList(_unlocksKey) ?? [];
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
}