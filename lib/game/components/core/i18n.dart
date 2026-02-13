class I18n {
  // Idioma padrão do jogo
  static String currentLanguage = 'pt'; 

  // O Dicionário: Um Mapa que liga a Sigla do Idioma -> Chave da Frase -> Texto Final
  static final Map<String, Map<String, String>> _strings = {
    'pt': {
      'paused': 'PAUSADO',
      'continue': 'Continuar',
      'main_menu': 'Menu Principal',
      'health': 'Vida',
      'gold': 'Ouro',
      'souls': 'Almas',
      'location': 'Local',
      'fire_rate': 'Vel. Tiro',
      'lvl': 'Nvl',
      'room': 'Sala',
    },
    'en': {
      'paused': 'PAUSED',
      'continue': 'Continue',
      'main_menu': 'Main Menu',
      'health': 'Health',
      'gold': 'Gold',
      'souls': 'Souls',
      'location': 'Location',
      'fire_rate': 'Fire Rate',
      'lvl': 'Lvl',
      'room': 'Room',
    },
    'es': {
      'paused': 'PAUSADO',
      'continue': 'Continuar',
      'main_menu': 'Menú Principal',
      'health': 'Salud',
      'gold': 'Oro',
      'souls': 'Almas',
      'location': 'Lugar',
      'fire_rate': 'Vel. Disparo',
      'lvl': 'Niv',
      'room': 'Sala',
    }
  };

  // Função mágica que busca a palavra. Se não achar, retorna a própria chave.
  static String tr(String key) {
    return _strings[currentLanguage]?[key] ?? key;
  }
}

// (Opcional) Uma Extension para deixar o código super limpo:
// Isso permite você escrever 'paused'.tr() no seu código!
extension TranslationExtension on String {
  String tr() {
    return I18n.tr(this);
  }
}