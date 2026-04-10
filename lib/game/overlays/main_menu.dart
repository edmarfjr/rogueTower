import 'package:towerrogue/game/components/core/ad_manager.dart';
import 'package:towerrogue/game/components/core/save_manager.dart';
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
      backgroundColor: Colors.black, // Cor de fallback caso a imagem demore 1 milissegundo pra carregar
      
      // ==========================================
      // A MÁGICA DO FUNDO GIGANTE: Usando STACK!
      // ==========================================
      body: Stack(
        children: [
          // 1. CAMADA BASE: A Imagem de Fundo
          Positioned.fill(
            child: Image.asset(
              'assets/images/sprites/mainMenu.png',
              fit: BoxFit.cover, // Estica para cobrir toda a tela
              filterQuality: FilterQuality.none, // Mantém o pixel art nítido
            ),
          ),
          
          // 2. CAMADA DO MEIO: Filtro Escuro (Opcional)
          // É uma boa prática colocar uma leve película escura sobre a arte
          // para garantir que o texto branco dos botões fique legível.
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.3), // 30% de escuridão
            ),
          ),

          // 3. CAMADA DO TOPO: O seu Menu (Título e Botões)
          Positioned.fill(
            child: SafeArea( // Protege o título da câmera frontal/notch do celular
              child: Column(
                children: [
                  // --- TÍTULO (Empurrado para o topo) ---
                  const Padding(
                    padding: EdgeInsets.only(top: 40.0), // Ajuste este valor para descer/subir mais o título
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

                  // ========================================================
                  // A MÁGICA: O Spacer é a "mola" que separa o Topo do Fundo
                  // ========================================================
                  const Spacer(),

                  // --- BOTÕES (Empurrados para o fundo) ---
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

                          _buildMenuButton(
                            context,
                            text: 'play'.tr(), 
                            onPressed: () async {
                              AdManager.loadRewardedAd();
                              if (hasSave) {
                                await SaveManager.clearSavedRun(); 
                              }
                              game.overlays.add('CharacterSelectionMenu');
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
                  
                  // Margem inferior para os botões não colarem no rodapé da tela
                  const SizedBox(height: 50), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- FUNÇÃO AUXILIAR DOS BOTÕES CONTINUA IGUAL ---
  Widget _buildMenuButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    Color bgColor = Pallete.preto,
    Color textColor = Pallete.branco,
  }) {
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