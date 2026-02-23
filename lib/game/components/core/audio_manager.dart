import 'package:flame_audio/flame_audio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioManager {
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.5;
  
  // CORREÇÃO 1: Agora cada som tem seu próprio cronômetro para evitar que um bloqueie o outro
  static final Map<String, DateTime> _lastSfxTimes = {};

  static bool _isMutedMusic = false;
  static bool get isMutedMusic => _isMutedMusic;
  static bool _isMutedSfx = false;
  static bool get isMutedSfx => _isMutedSfx;

  static bool _isBgmPlaying = false;
  static String _currentBgm = '';

  static final Map<String, AudioPool> _sfxPools = {};

  static String _resolveSfxPath(String filename) {
    if (kIsWeb) {
      return 'sfx/mp3/$filename'; 
    } else {
      String wavName = filename.replaceAll('.mp3', '.wav');
      return 'sfx/wav/$wavName'; 
    }
  }

  // --- FUNÇÃO AUXILIAR PARA CARREGAR POOLS COM SEGURANÇA ---
  static Future<void> _safeLoadPool(String filename, int min, int max) async {
    try {
      String resolvedPath = _resolveSfxPath(filename);
      _sfxPools[filename] = await FlameAudio.createPool(resolvedPath, minPlayers: min, maxPlayers: max);
    } catch (e) {
      // Se um arquivo estiver faltando, ele te avisa qual é, mas NÃO trava o jogo!
      print("⚠️ AVISO: Falha ao carregar o som '$filename'. Verifique se o arquivo existe na pasta correta. Erro: $e");
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
        category: AVAudioSessionCategory.ambient, 
        options: const {
          AVAudioSessionOptions.mixWithOthers,
        },
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
    FlameAudio.bgm.initialize();

    // CORREÇÃO 2: Carrega cada som de forma independente. 
    // Se o 'dash.wav' não existir, ele pula e carrega o 'hit.wav' normalmente.
    await _safeLoadPool('shoot.mp3', 1, 4);
    await _safeLoadPool('hit.mp3', 1, 3);
    await _safeLoadPool('dash.mp3', 1, 2);
    await _safeLoadPool('collect.mp3', 1, 2);
    await _safeLoadPool('explosion.mp3', 1, 3);
    await _safeLoadPool('laser.mp3', 1, 4);
    await _safeLoadPool('enemyShot.mp3', 1, 4);
    await _safeLoadPool('enemy_die.mp3', 1, 3);

    // Carrega os sons normais soltos
    try {
      await FlameAudio.audioCache.loadAll([
        _resolveSfxPath('game_over.mp3'),
        'music/8bit_menu.mp3',            
        'music/funny_bit.mp3',  
        'music/retro_plat.mp3',
      ]);
    } catch (e) {
      print("⚠️ AVISO: Falha ao carregar os áudios secundários do Cache. Erro: $e");
    }
  }

  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    
    final now = DateTime.now();
    // Busca o último tempo em que ESTE som específico tocou
    final lastTime = _lastSfxTimes[filename] ?? DateTime.fromMillisecondsSinceEpoch(0);

    if (now.difference(lastTime).inMilliseconds > 50) {
      try {
        if (_sfxPools.containsKey(filename)) {
          _sfxPools[filename]!.start(volume: sfxVolume);
        } else {
          FlameAudio.play(_resolveSfxPath(filename), volume: sfxVolume);
        }
        
        // Atualiza o tempo apenas deste som
        _lastSfxTimes[filename] = now;
      } catch (e) {
         print("Erro ao tocar SFX ($filename): $e");
      }
    }
  }

  // ... (o resto dos métodos de música e volume continuam exatamente iguais) ...
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