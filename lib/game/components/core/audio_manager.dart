import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class AudioManager {
  static double sfxVolume = 1.0;
  static double bgmVolume = 0.5;

  static bool _isMutedMusic = false;
  static bool get isMutedMusic => _isMutedMusic;
  static bool _isMutedSfx = false;
  static bool get isMutedSfx => _isMutedSfx;

  static bool _isBgmPlaying = false;
  static String _currentBgm = '';

  static final Map<String, AudioSource> _sfxSources = {};

  static String _resolveSfxPath(String filename) {
    if (kIsWeb) {
      return 'sfx/mp3/$filename'; 
    } else {
      String wavName = filename.replaceAll('.mp3', '.wav');
      return 'sfx/wav/$wavName'; 
    }
  }

  static Future<void> _loadSfx(String filename) async {
    try {
      String resolvedPath = _resolveSfxPath(filename);
      String fullPath = 'assets/audio/$resolvedPath';
      AudioSource source = await SoLoud.instance.loadAsset(fullPath);
      _sfxSources[filename] = source;
    } catch (e) {
      //print("Erro SoLoud: $e");
    }
  }

  static Future<void> init() async {
    FlameAudio.bgm.initialize();

    if (kIsWeb) {
      try {
        await FlameAudio.audioCache.loadAll([
          _resolveSfxPath('shoot.mp3'),
          _resolveSfxPath('hit.mp3'),
          _resolveSfxPath('dash.mp3'),
          _resolveSfxPath('collect.mp3'),
          _resolveSfxPath('explosion.mp3'),
          _resolveSfxPath('laser.mp3'),
          _resolveSfxPath('enemyShot.mp3'),
          _resolveSfxPath('enemy_die.mp3'),
          _resolveSfxPath('door_open.mp3'),
          _resolveSfxPath('game_over.mp3'),
          _resolveSfxPath('earth.mp3'),
          _resolveSfxPath('fire.mp3'),
          _resolveSfxPath('ice.mp3'),
          _resolveSfxPath('pickUp.mp3'),
          _resolveSfxPath('poison.mp3'),
          _resolveSfxPath('powerUp.mp3'),
          _resolveSfxPath('thunder.mp3'),
          _resolveSfxPath('water.mp3'),
          _resolveSfxPath('wind.mp3'),
          _resolveSfxPath('block.mp3'),
          _resolveSfxPath('charge.mp3'),
          _resolveSfxPath('hitHurt.mp3'),
          _resolveSfxPath('flesh.mp3'),
          _resolveSfxPath('fear.mp3'),
          _resolveSfxPath('heal.mp3'),
          'music/8bit_menu.mp3',            
          'music/funny_bit.mp3',  
          'music/retro_plat.mp3',
        ]);
      } catch (e) {
        // print("AVISO: Falha ao carregar SFX no cache da Web");
      }
    } else {
      await SoLoud.instance.init();

      await _loadSfx('shoot.mp3');
      await _loadSfx('hit.mp3');
      await _loadSfx('dash.mp3');
      await _loadSfx('collect.mp3');
      await _loadSfx('explosion.mp3');
      await _loadSfx('laser.mp3');
      await _loadSfx('enemyShot.mp3');
      await _loadSfx('enemy_die.mp3');
      await _loadSfx('door_open.mp3');

      try {
        await FlameAudio.audioCache.loadAll([
          _resolveSfxPath('game_over.mp3'),
          'music/8bit_menu.mp3',            
          'music/funny_bit.mp3',  
          'music/retro_plat.mp3',
        ]);
      } catch (e) { }
    }
  }

  static void playSfx(String filename) {
    if (_isMutedSfx) return;
    //print("Tocando SFX: $filename");
    if (kIsWeb) {
      try {
        FlameAudio.play(_resolveSfxPath(filename), volume: sfxVolume);
      } catch (e) { }
      return; 
    }

    String poolKey = filename.replaceAll('.wav', '.mp3');
    try {
      if (_sfxSources.containsKey(poolKey)) {
        SoLoud.instance.play(_sfxSources[poolKey]!, volume: sfxVolume);
      }
    } catch (e) { }
  }


  static void playBgm(String filename) {
    if (_currentBgm == filename && _isBgmPlaying && !_isMutedMusic) return; 
    _currentBgm = filename; 
    if (_isMutedMusic) return;

    FlameAudio.bgm.stop(); 
    try {
      FlameAudio.bgm.play('music/$filename', volume: bgmVolume);
      _isBgmPlaying = true;
    } catch (e) { }
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
    _isBgmPlaying = false;
  }

  static void pauseBgm(){
    FlameAudio.bgm.pause();
  }

  static void resumeBgm(){
    if (!_isMutedMusic) FlameAudio.bgm.resume();
  }
  
  static void toggleMuteMusic(bool mute) {
    _isMutedMusic = mute;
    if (_isMutedMusic) {
      FlameAudio.bgm.pause(); 
      _isBgmPlaying = false;
    } else {
      if (_currentBgm.isNotEmpty) playBgm(_currentBgm); 
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