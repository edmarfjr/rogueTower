import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Configurações de Volume (0.0 a 1.0)
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.5;
  static DateTime _lastSfxTime = DateTime.now();

  static bool _isMutedMusic = false;
  static bool get isMutedMusic => _isMutedMusic;
  static bool _isMutedSfx = false;
  static bool get isMutedSfx => _isMutedSfx;

  static String currMusic = '';

  /// Inicializa e pré-carrega sons importantes para evitar lag na primeira vez
  static Future<void> init() async {
    // CORREÇÃO 1: O cache precisa saber exatamente em qual subpasta o arquivo está!
    await FlameAudio.audioCache.loadAll([
      'sfx/shoot.mp3',
      'sfx/hit.mp3',
      'sfx/dash.mp3',
      'sfx/collect.mp3',
      'sfx/enemy_die.mp3',
      'sfx/game_over.mp3',
      'sfx/explosion.mp3',
      'sfx/laser.mp3',
      'sfx/enemyShot.mp3',
      'music/8bit_menu.mp3',
      'music/funny_bit.mp3',  
      'music/retro_plat.mp3',
    ]);
    
    // Configura o loop de música global
    FlameAudio.bgm.initialize();
  }

  /// Toca um efeito sonoro curto
  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    final now = DateTime.now();
    // Só toca se passou 50ms desde o último som igual
    if (now.difference(_lastSfxTime).inMilliseconds > 50) {
      FlameAudio.play('sfx/$filename');
      _lastSfxTime = now;
    }
  }

  /// Toca música de fundo em loop
  static void playBgm(String filename) {
    if (_isMutedMusic) return;
    // CORREÇÃO 3: Mudamos de 'sfx/' para 'music/' para as músicas de fundo
    FlameAudio.bgm.play('music/$filename', volume: bgmVolume);
    currMusic = filename;
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
  }
  
  static void toggleMuteMusic(bool mute) {
    _isMutedMusic = mute;
    if (_isMutedMusic) {
      FlameAudio.bgm.stop();
    } else {
      // Opcional: Coloque o nome da sua música principal aqui para ela voltar a tocar
       playBgm(currMusic); 
    }
  }

  static void toggleMuteSfx(bool mute) {
    _isMutedSfx = mute;
  }

  // Função para mudar o volume da música e já aplicar na música tocando agora
  static void updateBgmVolume(double volume) {
    bgmVolume = volume;
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    }
  }

  static void updateSfxVolume(double volume) {
    sfxVolume = volume;
  }
  
}