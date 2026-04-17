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

  // --- MAPA DO NOVO MOTOR C++ ---
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
      // O SoLoud precisa do caminho completo a partir da pasta assets
      String fullPath = 'assets/audio/$resolvedPath';
      
      // Carrega o áudio direto para a memória RAM (C++)
      AudioSource source = await SoLoud.instance.loadAsset(fullPath);
      _sfxSources[filename] = source;
    } catch (e) {
      //print("⚠️ AVISO: Falha ao carregar SFX no SoLoud para '$filename'. Erro: $e");
    }
  }

  static Future<void> init() async {
    // 1. INICIALIZA O MOTOR C++ DE ALTA PERFORMANCE
    await SoLoud.instance.init();

    // 2. Mantém o motor antigo APENAS para a música de fundo
    FlameAudio.bgm.initialize();

    // 3. Pré-carrega os tiros e explosões na RAM instantânea
    await _loadSfx('shoot.mp3');
    await _loadSfx('hit.mp3');
    await _loadSfx('dash.mp3');
    await _loadSfx('collect.mp3');
    await _loadSfx('explosion.mp3');
    await _loadSfx('laser.mp3');
    await _loadSfx('enemyShot.mp3');
    await _loadSfx('enemy_die.mp3');

    // Carrega as Músicas e áudios longos no motor padrão
    try {
      await FlameAudio.audioCache.loadAll([
        _resolveSfxPath('game_over.mp3'),
        'music/8bit_menu.mp3',            
        'music/funny_bit.mp3',  
        'music/retro_plat.mp3',
      ]);
    } catch (e) {
      //print("AVISO: Falha ao carregar Músicas do Cache. Erro: $e");
    }
  }

  static void playSfx(String filename) {
    
    if (_isMutedSfx) return;
    
    String poolKey = filename.replaceAll('.wav', '.mp3');

    try {
      if (_sfxSources.containsKey(poolKey)) {
        SoLoud.instance.play(_sfxSources[poolKey]!, volume: sfxVolume);
      } else {
         //print("ALERTA: O som '$filename' não foi pré-carregado no init()!");
      }
    } catch (e) {
       //print("Erro ao tocar SFX ($filename) no SoLoud: $e");
    }
  }

  static void playBgm(String filename) {
    // 1. A TRAVA DE SEGURANÇA: Se já está tocando a mesma música, ignora!
    if (_currentBgm == filename && _isBgmPlaying && !_isMutedMusic) {
      return; 
    }

    // 2. Salva a intenção (importante para o unmute saber o que tocar)
    _currentBgm = filename; 

    // Se estiver mudo, registamos qual seria a música, mas saímos antes de tocar
    if (_isMutedMusic) return;

    // 3. Para qualquer música antiga antes de começar a nova
    FlameAudio.bgm.stop(); 
  
    try {
      FlameAudio.bgm.play('music/$filename', volume: bgmVolume);
      _isBgmPlaying = true;
     // print('tocando $filename');
    } catch (e) {
     //print("Erro ao tocar BGM: $e");
    }
  }

  static void stopBgm() {
    FlameAudio.bgm.stop();
    _isBgmPlaying = false;
    //_currentBgm = '';
   // print('parou musica');
  }

  static void pauseBgm(){
    FlameAudio.bgm.pause();
  }

  static void resumeBgm(){
    if (!_isMutedMusic) {
      FlameAudio.bgm.resume();
    }
  }
  
  static void toggleMuteMusic(bool mute) {
    _isMutedMusic = mute;
    
    if (_isMutedMusic) {
      // Ao invés de parar do zero, pausamos. Assim o unmute é mais suave.
      FlameAudio.bgm.pause(); 
      _isBgmPlaying = false;
    } else {
      // Desmutou! Se temos uma música salva na memória, ela volta a tocar
      if (_currentBgm.isNotEmpty) {
        // Usamos o playBgm em vez do resume para garantir que o volume aplique corretamente
        playBgm(_currentBgm); 
      }
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