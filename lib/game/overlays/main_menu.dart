import 'package:towerrogue/game/components/core/ad_manager.dart';
import 'package:towerrogue/game/components/core/save_manager.dart';
import 'package:flutter/material.dart';
import '../components/core/i18n.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class MainMenu extends StatelessWidget {
  final TowerGame game;

  const MainMenu({super.key, required this.game});

  // --- NOVA FUNÇÃO DE DIÁLOGO DE CONFIRMAÇÃO ---
  Future<void> _confirmarNovoJogo(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Obriga o jogador a escolher uma opção
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Pallete.preto,
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Pallete.branco, width: 2),
            borderRadius: BorderRadius.zero, // Mantém o estilo pixelado/quadrado
          ),
          title: Text(
            'play'.tr().toUpperCase(), // "NOVO JOGO"
            textAlign: TextAlign.center,
            style: const TextStyle(color: Pallete.branco, fontWeight: FontWeight.bold, fontSize: 30),
          ),
          content: Text(
            'confirm_new_game_message'.tr(), // "Isso apagará seu jogo salvo. Continuar?"
            textAlign: TextAlign.center,
            style: const TextStyle(color: Pallete.branco, fontSize: 20),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fecha sem fazer nada
              child: Text(
                'no'.tr().toUpperCase(),
                style: const TextStyle(color: Pallete.amarelo, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            TextButton(
              onPressed: () async {
                await SaveManager.clearSavedRun(); // Apaga o save
                if (context.mounted) {
                  Navigator.of(context).pop(); // Fecha o diálogo
                  game.overlays.add('CharacterSelectionMenu'); // Inicia o jogo
                }
              },
              child: Text(
                'yes'.tr().toUpperCase(),
                style: const TextStyle(color: Pallete.amarelo, fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/sprites/mainMenu.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.none,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Text(
                      'ROGUE TOWER',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Pallete.branco,
                        letterSpacing: 4,
                        shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  FutureBuilder<bool>(
                    future: SaveManager.hasSavedRun(),
                    builder: (context, snapshot) {
                      final bool hasSave = snapshot.data ?? false;

                      return Column(
                        children: [
                          if (hasSave) ...[
                            _buildMenuButton(
                              context,
                              text: 'continue'.tr(),
                              onPressed: () async {
                                AdManager.loadRewardedAd();
                                game.continueGame();
                              },
                            ),
                            const SizedBox(height: 15),
                          ],

                          // --- BOTÃO PLAY ALTERADO ---
                          _buildMenuButton(
                            context,
                            text: 'play'.tr(),
                            onPressed: () async {
                              AdManager.loadRewardedAd();
                              if (hasSave) {
                                // Se tem save, abre o diálogo de confirmação
                                _confirmarNovoJogo(context);
                              } else {
                                // Se não tem save, vai direto para seleção
                                game.overlays.add('CharacterSelectionMenu');
                              }
                            },
                          ),
                          const SizedBox(height: 15),

                          _buildMenuButton(
                            context,
                            text: 'settings'.tr(),
                            onPressed: () => game.overlays.add('SettingsMenu'),
                          ),
                          const SizedBox(height: 15),

                          _buildMenuButton(
                            context,
                            text: 'colecao'.tr(),
                            onPressed: () => game.overlays.add('DiaryScreen'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Color? bgColor,
    Color textColor = Pallete.branco,
  }) {
    bgColor ??= Pallete.preto.withAlpha(0);
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 24,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}