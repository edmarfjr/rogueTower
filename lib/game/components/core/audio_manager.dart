import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.5;
  
  static final Map<String, DateTime> _lastSfxTimes = {};

  static bool _isMutedMusic = false;
  static bool get isMutedMusic => _isMutedMusic;
  static bool _isMutedSfx = false;
  static bool get isMutedSfx => _isMutedSfx;

  static bool _isBgmPlaying = false;
  static String _currentBgm = '';

  // Voltando para o sistema nativo e otimizado do Flame!
  static final Map<String, AudioPool> _sfxPools = {};

  static String _resolveSfxPath(String filename) {
    if (kIsWeb) {
      return 'sfx/mp3/$filename'; 
    } else {
      String wavName = filename.replaceAll('.mp3', '.wav');
      return 'sfx/wav/$wavName'; 
    }
  }

  static Future<void> _loadPool(String filename, int max) async {
    try {
      String path = _resolveSfxPath(filename);
      // Cria a pool otimizada pelo motor C++ nativo do celular
      _sfxPools[filename] = await FlameAudio.createPool(path, minPlayers: 1, maxPlayers: max);
    } catch (e) {
      print("⚠️ AVISO: Falha ao carregar Pool para '$filename'. Erro: $e");
    }
  }

  static Future<void> init() async {
    final audioContext = AudioContext(
      android: const AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: false,
        contentType: AndroidContentType.sonification,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.none, 
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback, 
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
    FlameAudio.bgm.initialize();

    // Carrega os sons de batalha
    await _loadPool('shoot.mp3', 4);
    await _loadPool('hit.mp3', 3);
    await _loadPool('dash.mp3', 2);
    await _loadPool('collect.mp3', 2);
    await _loadPool('explosion.mp3', 3);
    await _loadPool('laser.mp3', 4);
    await _loadPool('enemyShot.mp3', 4);
    await _loadPool('enemy_die.mp3', 3);

    // Carrega músicas e sons de menu
    try {
      await FlameAudio.audioCache.loadAll([
        _resolveSfxPath('game_over.mp3'),
        'music/8bit_menu.mp3',            
        'music/funny_bit.mp3',  
        'music/retro_plat.mp3',
      ]);
    } catch (e) {
      print("⚠️ AVISO: Falha ao carregar do Cache. Erro: $e");
    }
  }

  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    
    // Normaliza a chave para buscar o item correto no Mapa (ex: shoot.wav vira shoot.mp3)
    String poolKey = filename.replaceAll('.wav', '.mp3');

    final now = DateTime.now();
    final lastTime = _lastSfxTimes[poolKey] ?? DateTime.fromMillisecondsSinceEpoch(0);

    if (now.difference(lastTime).inMilliseconds > 50) {
      try {
        if (_sfxPools.containsKey(poolKey)) {
          _sfxPools[poolKey]!.start(volume: sfxVolume);
        } else {
          FlameAudio.play(_resolveSfxPath(filename), volume: sfxVolume);
        }
        _lastSfxTimes[poolKey] = now;
      } catch (e) {
         print("Erro ao tocar SFX ($filename): $e");
      }
    }
  }

  static void playBgm(String filename) {
    if (_isMutedMusic) return;
    if (_isBgmPlaying && _currentBgm == filename) return; 

    if (_isBgmPlaying) FlameAudio.bgm.stop();
  
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