import 'dart:math';
import 'package:TowerRogue/game/components/core/ad_manager.dart';
import 'package:TowerRogue/game/components/core/save_manager.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';

import '../components/core/i18n.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class MainMenu extends StatelessWidget {
  final TowerGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título do Jogo
              const Padding(
                padding: EdgeInsets.only(top: 20.0, bottom: 30.0),
                child: Text(
                  'TOWER OF ICONS',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Pallete.branco,
                    letterSpacing: 4,
                    shadows: [Shadow(blurRadius: 10, color: Colors.white24)],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 60),
              _buildFlexibleBackgroundArt(context),
              const SizedBox(height: 40),

              // ========================================================
              // O FUTURE BUILDER: Decide quais botões mostrar baseado no Save
              // ========================================================
              FutureBuilder<bool>(
                future: SaveManager.hasSavedRun(),
                builder: (context, snapshot) {
                  // Se ainda está carregando a resposta do celular, mostra os botões padrões
                  // Se já carregou, verifica se é true ou false.
                  final bool hasSave = snapshot.data ?? false;

                  return Column(
                    children: [
                      // --- BOTÃO CONTINUAR (Só aparece se existir Save!) ---
                      if (hasSave) ...[
                        _buildMenuButton(
                          context,
                          text: 'continue'.tr(), // Crie essa chave de tradução (ex: 'Continuar')
                          bgColor: Pallete.branco, // Destaque visual
                          textColor: Colors.black,
                          onPressed: () async {
                            AdManager.loadRewardedAd();
                            await SaveManager.loadRun(game);
                            
                            // Remove o menu da tela para o jogo voltar a rodar com os status carregados
                            game.overlays.remove('MainMenu'); 
                            game.resumeEngine(); 
                            game.overlays.add('HUD');
                            game.startLevel();
                            // Se a sua engine pausa quando o menu abre, descomente a linha abaixo:
                             
                          },
                        ),
                        const SizedBox(height: 15),
                      ],

                      // --- BOTÃO NOVO JOGO / JOGAR ---
                      _buildMenuButton(
                        context,
                        // Se tem save, vira "Novo Jogo" (para o jogador saber que vai sobrescrever).
                        // Se não tem, fica apenas "Jogar"
                        text: 'play'.tr(), 
                        bgColor: Pallete.branco,
                        textColor: Colors.black,
                        onPressed: () async {
                          AdManager.loadRewardedAd();
                          if (hasSave) {
                            // Se o cara apertou "Novo Jogo" tendo um save antigo, a gente limpa!
                            await SaveManager.clearSavedRun(); 
                          }
                          //game.startGame(); 
                          game.overlays.add('CharacterSelectionMenu');
                        },
                      ),

                      const SizedBox(height: 15),

                      // --- BOTÃO CONFIGURAÇÕES ---
                      _buildMenuButton(
                        context,
                        text: 'settings'.tr(),
                        bgColor: Pallete.branco,
                        textColor: Colors.black,
                        onPressed: () => game.overlays.add('SettingsMenu'),
                      ),

                      const SizedBox(height: 15),

                      // botao diario
                      _buildMenuButton(
                        context,
                        text: 'colecao'.tr(),
                        bgColor: Pallete.branco,
                        textColor: Colors.black,
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
    );
  }

  // --- FUNÇÃO AUXILIAR ATUALIZADA (Agora aceita cor de fundo) ---
  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Color bgColor = Colors.white,
    Color textColor = Colors.black,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ... (Sua função _buildFlexibleBackgroundArt continua exatamente igual!) ...
  Widget _buildFlexibleBackgroundArt(BuildContext context) {
    const double sceneHeight = 350;
    return SizedBox(
      height: sceneHeight,
      width: double.infinity, 
      child: Stack(
        alignment: Alignment.bottomCenter, 
        clipBehavior: Clip.none, 
        children: [
          Positioned(
            top: -120,
            right: MediaQuery.of(context).size.width / 2 - 80,
            child: Icon(MdiIcons.moonWaxingCrescent, color: Pallete.amarelo.withOpacity(0.3), size: 100),
          ),
          Positioned(
            bottom: 20, 
            right: MediaQuery.of(context).size.width / 2 - 200, 
            child:  Icon(
              MdiIcons.chessRook,
              size: 400,
              color: Pallete.cinzaEsc,
            ),
          ),
          Positioned(
            top: 80,
            left: 100,
            child:Transform.rotate( 
              angle :- pi / 4,
              child:Icon(MdiIcons.bat, color: Pallete.lilas, size: 50),
            ),
          ),
          Positioned(
            bottom: 30, 
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: const Icon(
              Icons.directions_walk,
              color: Pallete.branco,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}