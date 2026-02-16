import '../components/core/audio_manager.dart';
import '../components/core/i18n.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class SettingsMenu extends StatefulWidget {
  final TowerGame game;

  const SettingsMenu({super.key, required this.game});

  @override
  State<SettingsMenu> createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  // Variáveis de estado locais para os sliders e checkbox
  late double _currentSfxVol;
  late double _currentBgmVol;
  late bool _isMutedMusic;
  late bool _isMutedSfx;

  @override
  void initState() {
    super.initState();
    // Puxa os valores iniciais lá do AudioManager
    _currentSfxVol = AudioManager.sfxVolume;
    _currentBgmVol = AudioManager.bgmVolume;
    _isMutedMusic = AudioManager.isMutedMusic;
    _isMutedSfx = AudioManager.isMutedSfx;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: widget.game.progress.languageNotifier,
      builder: (context, currentLang, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.7),
          body: Center(
            child: Container(
              width: 340, // Deixei um pouco mais largo para acomodar os sliders
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Pallete.azulEsc,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Pallete.branco, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'settings'.tr(),
                    style: const TextStyle(fontSize: 28, color: Pallete.branco, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.white30, height: 30, thickness: 1),

                  // --- SEÇÃO DE ÁUDIO ---
                  Text('audio'.tr(), style: const TextStyle(fontSize: 20, color: Pallete.amarelo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Checkbox MUDO Musica
                  CheckboxListTile(
                    title: Text('muteMusic'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18)),
                    value: _isMutedMusic,
                    activeColor: Pallete.vermelho,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    onChanged: (bool? value) {
                      setState(() {
                        _isMutedMusic = value ?? false;
                        AudioManager.toggleMuteMusic(_isMutedMusic);
                        widget.game.progress.saveSettings(widget.game);
                      });
                    },
                  ),

                  // Checkbox MUDO SFX
                  CheckboxListTile(
                    title: Text('muteSfx'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18)),
                    value: _isMutedSfx,
                    activeColor: Pallete.vermelho,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    onChanged: (bool? value) {
                      setState(() {
                        _isMutedSfx = value ?? false;
                        AudioManager.toggleMuteSfx(_isMutedSfx);
                        widget.game.progress.saveSettings(widget.game);
                      });
                    },
                  ),

                  // Slider MÚSICA
                  _buildVolumeSlider(
                    label: 'bgm_volume'.tr(),
                    icon: Icons.music_note,
                    value: _currentBgmVol,
                    isDisabled: _isMutedMusic,
                    onChanged: (val) {
                      setState(() {
                        _currentBgmVol = val;
                        AudioManager.updateBgmVolume(val);
                        widget.game.progress.saveSettings(widget.game);
                      });
                    },
                  ),

                  // Slider EFEITOS (SFX)
                  _buildVolumeSlider(
                    label: 'sfx_volume'.tr(),
                    icon: Icons.volume_up,
                    value: _currentSfxVol,
                    isDisabled: _isMutedSfx,
                    onChanged: (val) {
                      setState(() {
                        _currentSfxVol = val;
                        AudioManager.sfxVolume = val;
                        // Toca um sonzinho rápido pra testar o volume!
                        if (!_isMutedSfx) AudioManager.playSfx('dash.mp3'); 
                        widget.game.progress.saveSettings(widget.game);
                      });
                    },
                  ),

                  const Divider(color: Colors.white30, height: 30, thickness: 1),
                /*
                  // --- NOVA SEÇÃO: GRÁFICOS ---
                  Text('graphics'.tr(), style: const TextStyle(fontSize: 20, color: Pallete.amarelo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  CheckboxListTile(
                    title: Text('retro_effect'.tr(), style: const TextStyle(color: Colors.white, fontSize: 18)),
                    // Lê a variável direto do seu jogo!
                    value: widget.game.useCRTEffect, 
                    activeColor: Pallete.vermelho,
                    checkColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    onChanged: (bool? value) {
                      setState(() {
                        // Atualiza a variável no jogo em tempo real
                        widget.game.useCRTEffect = value ?? true;
                        widget.game.progress.saveSettings(widget.game);
                      });
                    },
                  ),
                
                  const Divider(color: Colors.white30, height: 30, thickness: 1),
                */
                  // --- SEÇÃO DE IDIOMA ---
                  Text('language'.tr(), style: const TextStyle(fontSize: 20, color: Pallete.amarelo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _langButton('pt', '🇧🇷 PT', currentLang),
                      _langButton('en', '🇺🇸 EN', currentLang),
                      _langButton('es', '🇪🇸 ES', currentLang),
                    ],
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.vermelho,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      widget.game.overlays.remove('SettingsMenu');
                    },
                    child: Text('close'.tr(), style: const TextStyle(fontSize: 18, color: Pallete.branco)),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  // Widget auxiliar para desenhar os Sliders de volume lindamente
  Widget _buildVolumeSlider({
    required String label, 
    required IconData icon, 
    required double value, 
    required bool isDisabled,
    required ValueChanged<double> onChanged
  }) {
    return Row(
      children: [
        Icon(icon, color: isDisabled ? Colors.white24 : Colors.white70, size: 24),
        const SizedBox(width: 10),
        SizedBox(
          width: 70, // Mantém o texto alinhado
          child: Text(label, style: TextStyle(color: isDisabled ? Colors.white24 : Colors.white, fontSize: 16)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            activeColor: isDisabled ? Colors.grey : Pallete.verdeCla,
            inactiveColor: Colors.white24,
            onChanged: isDisabled ? null : onChanged, // Desativa o slider se estiver mudo
          ),
        ),
      ],
    );
  }

  Widget _langButton(String langCode, String label, String currentLang) {
    bool isSelected = currentLang == langCode;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Pallete.verdeCla : Pallete.cinzaEsc,
        side: isSelected ? const BorderSide(color: Pallete.branco, width: 2) : BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      onPressed: () {
        widget.game.progress.changeLanguage(langCode);
      },
      child: Text(
        label, 
        style: TextStyle(fontSize: 16, color: isSelected ? Colors.white : Colors.white54)
      ),
    );
  }
}