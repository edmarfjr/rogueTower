import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  // Configurações de Volume (0.0 a 1.0)
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.5;

  static bool _isMutedMusic = false;
  static bool get isMutedMusic => _isMutedMusic;
  static bool _isMutedSfx = false;
  static bool get isMutedSfx => _isMutedSfx;

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
    ]);
    
    // Configura o loop de música global
    FlameAudio.bgm.initialize();
  }

  /// Toca um efeito sonoro curto
  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    // CORREÇÃO 2: Adicionamos o 'sfx/' aqui. 
    // Assim, se você chamar AudioManager.playSfx('dash.mp3'), ele acha certinho!
    FlameAudio.play('sfx/$filename', volume: sfxVolume);
  }

  /// Toca música de fundo em loop
  static void playBgm(String filename) {
    if (_isMutedMusic) return;
    // CORREÇÃO 3: Mudamos de 'sfx/' para 'music/' para as músicas de fundo
    FlameAudio.bgm.play('music/$filename', volume: bgmVolume);
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
      // playBgm('tema_principal.mp3'); 
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