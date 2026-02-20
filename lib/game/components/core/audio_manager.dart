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

  static bool _isBgmPlaying = false;
  static String _currentBgm = '';

  // --- O SEGREDO DA PERFORMANCE: POOLS DE ÁUDIO ---
  // Guarda os sons rápidos pré-carregados na memória
  static final Map<String, AudioPool> _sfxPools = {};

  /// Inicializa e pré-carrega sons importantes para evitar lag na primeira vez
  static Future<void> init() async {
    // 1. Configura o loop de música global PRIMEIRO
    FlameAudio.bgm.initialize();

    // 2. Cria os "Pools" para sons que tocam muito rápido/várias vezes.
    // maxPlayers: 4 significa que no máximo 4 tiros tocam no mesmo milissegundo. 
    // Isso impede estourar o limite de áudio do Android e desligar a música.
    _sfxPools['shoot.mp3'] = await FlameAudio.createPool('sfx/shoot.mp3', minPlayers: 1, maxPlayers: 4);
    _sfxPools['hit.mp3'] = await FlameAudio.createPool('sfx/hit.mp3', minPlayers: 1, maxPlayers: 3);
    _sfxPools['dash.mp3'] = await FlameAudio.createPool('sfx/dash.mp3', minPlayers: 1, maxPlayers: 2);
    _sfxPools['collect.mp3'] = await FlameAudio.createPool('sfx/collect.mp3', minPlayers: 1, maxPlayers: 2);
    _sfxPools['explosion.mp3'] = await FlameAudio.createPool('sfx/explosion.mp3', minPlayers: 1, maxPlayers: 3);
    _sfxPools['laser.mp3'] = await FlameAudio.createPool('sfx/laser.mp3', minPlayers: 1, maxPlayers: 4);
    _sfxPools['enemyShot.mp3'] = await FlameAudio.createPool('sfx/enemyShot.mp3', minPlayers: 1, maxPlayers: 4);
    _sfxPools['enemy_die.mp3'] = await FlameAudio.createPool('sfx/enemy_die.mp3', minPlayers: 1, maxPlayers: 3);

    // 3. Carrega o resto normalmente (músicas e sons raros como morte do boss)
    await FlameAudio.audioCache.loadAll([
      'sfx/game_over.mp3',
      'music/8bit_menu.mp3',
      'music/funny_bit.mp3',  
      'music/retro_plat.mp3',
    ]);
  }

  /// Toca um efeito sonoro curto
  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    
    final now = DateTime.now();
    // Só toca se passou 50ms desde o último som (Evita estouro de áudio se 10 inimigos morrerem no mesmo frame)
    if (now.difference(_lastSfxTime).inMilliseconds > 50) {
      try {
        // Se o som estiver no nosso Pool de alta performance, usa o Pool!
        if (_sfxPools.containsKey(filename)) {
          _sfxPools[filename]!.start(volume: sfxVolume);
        } else {
          // Se for um som mais raro, toca da forma tradicional (adicionando o volume que faltava)
          FlameAudio.play('sfx/$filename', volume: sfxVolume);
        }
        _lastSfxTime = now;
      } catch (e) {
         print("Erro ao tocar SFX: $e");
      }
    }
  }

  /// Toca música de fundo em loop
  static void playBgm(String filename) {
    if (_isMutedMusic) return;
    if (_isBgmPlaying && _currentBgm == filename) {
      return; 
    }

    if (_isBgmPlaying) {
      FlameAudio.bgm.stop();
    }
  
    try {
      FlameAudio.bgm.play('music/$filename', volume: bgmVolume);
      _isBgmPlaying = true;
      _currentBgm = filename;
    } catch (e) {
      print("Erro ao tocar BGM: $e");
    }
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
    _isBgmPlaying = false;
    _currentBgm = '';
  }
  
  static void toggleMuteMusic(bool mute) {
    _isMutedMusic = mute;
    if (_isMutedMusic) {
      FlameAudio.bgm.stop();
    } else {
       playBgm(_currentBgm.isNotEmpty ? _currentBgm : '8bit_menu.mp3'); 
    }
  }

  static void toggleMuteSfx(bool mute) {
    _isMutedSfx = mute;
  }

  static void updateBgmVolume(double volume) {
    bgmVolume = volume;
    if (FlameAudio.bgm.isPlaying) {
      FlameAudio.bgm.audioPlayer.setVolume(volume);
    }
  }

  static void updateSfxVolume(double volume) {
    sfxVolume = volume;
    // Opcional: Atualizar o volume base de todos os pools não é estritamente necessário 
    // porque nós passamos o sfxVolume no método .start() do pool ali em cima!
  }
}