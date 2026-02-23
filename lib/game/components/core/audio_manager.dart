import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

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

  // Guarda os sons rápidos pré-carregados na memória
  static final Map<String, AudioPool> _sfxPools = {};

  // ==========================================
  // RESOLVEDOR DE CAMINHOS (WEB VS MOBILE)
  // ==========================================
  static String _resolveSfxPath(String filename) {
    if (kIsWeb) {
      return 'sfx/mp3/$filename'; 
    } else {
      String wavName = filename.replaceAll('.mp3', '.wav');
      return 'sfx/wav/$wavName'; 
    }
  }

  /// Inicializa e pré-carrega sons importantes para evitar lag na primeira vez
  static Future<void> init() async {
    // 1. Configura o contexto de áudio global
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, // O SEGREDO AQUI: Não roubar o foco!
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient, // Mistura o áudio
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
    
    // 2. Configura o loop de música global PRIMEIRO
    FlameAudio.bgm.initialize();

    // 3. Cria as "Pools" APLICANDO a função de resolver o caminho!
    _sfxPools['shoot.mp3'] = await FlameAudio.createPool(_resolveSfxPath('shoot.mp3'), minPlayers: 1, maxPlayers: 4);
    _sfxPools['hit.mp3'] = await FlameAudio.createPool(_resolveSfxPath('hit.mp3'), minPlayers: 1, maxPlayers: 3);
    _sfxPools['dash.mp3'] = await FlameAudio.createPool(_resolveSfxPath('dash.mp3'), minPlayers: 1, maxPlayers: 2);
    _sfxPools['collect.mp3'] = await FlameAudio.createPool(_resolveSfxPath('collect.mp3'), minPlayers: 1, maxPlayers: 2);
    _sfxPools['explosion.mp3'] = await FlameAudio.createPool(_resolveSfxPath('explosion.mp3'), minPlayers: 1, maxPlayers: 3);
    _sfxPools['laser.mp3'] = await FlameAudio.createPool(_resolveSfxPath('laser.mp3'), minPlayers: 1, maxPlayers: 4);
    _sfxPools['enemyShot.mp3'] = await FlameAudio.createPool(_resolveSfxPath('enemyShot.mp3'), minPlayers: 1, maxPlayers: 4);
    _sfxPools['enemy_die.mp3'] = await FlameAudio.createPool(_resolveSfxPath('enemy_die.mp3'), minPlayers: 1, maxPlayers: 3);

    // 4. Carrega o resto aplicando também na lista do loadAll
    await FlameAudio.audioCache.loadAll([
      _resolveSfxPath('game_over.mp3'), // Efeito sonoro convertido
      'music/8bit_menu.mp3',            // Músicas continuam puras
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
        // A chave do dicionário continua sendo o nome original .mp3
        if (_sfxPools.containsKey(filename)) {
          _sfxPools[filename]!.start(volume: sfxVolume);
        } else {
          // APLICAÇÃO da conversão caso toque um som fora das pools
          FlameAudio.play(_resolveSfxPath(filename), volume: sfxVolume);
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
  }
}