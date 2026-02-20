import 'dart:math';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../components/core/i18n.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';
// IMPORTANTE: Certifique-se de que seu pacote de ícones (ex: Material Design Icons) está importado
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MainMenu extends StatelessWidget {
  final TowerGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Obtém a largura da tela para ajudar a centralizar se necessário
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView( // Garante que não quebre em telas muito pequenas na horizontal
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Título do Jogo
              const Padding(
                padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
                child: Text(
                  'ROGUE TOWER',
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

              // --- NOVA ÁREA DE ARTE FLEXÍVEL ---
              _buildFlexibleBackgroundArt(context),

              const SizedBox(height: 40),

              // Botão Jogar
              _buildMenuButton(
                context,
                text: 'play'.tr(),
                onPressed: () => game.startGame(),
              ),

              const SizedBox(height: 15),

              // Botão Configurações
              _buildMenuButton(
                context,
                text: 'settings'.tr(),
                onPressed: () => game.overlays.add('SettingsMenu'),
              ),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNÇÃO AUXILIAR PARA OS BOTÕES (Para não repetir código) ---
  Widget _buildMenuButton(BuildContext context, {required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Pallete.branco,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 5, // Um pouco de sombra
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- ARTE DA TORRE USANDO STACK PARA CONTROLE TOTAL ---
  Widget _buildFlexibleBackgroundArt(BuildContext context) {
    // Definimos uma altura fixa para a área da "cena"
    const double sceneHeight = 350;

    return SizedBox(
      height: sceneHeight,
      width: double.infinity, // Ocupa toda a largura disponível
      // Usamos um Container transparente para poder ver a área de debug se precisar
      // color: Colors.red.withOpacity(0.1), 
      child: Stack(
        // Alinhamento padrão para elementos não posicionados (opcional)
        alignment: Alignment.bottomCenter, 
        clipBehavior: Clip.none, // Permite que elementos saiam um pouco da área se necessário
        children: [
          // ========================================================
          // CAMADA 1: FUNDO (Céu, Lua, Chão)
          // ========================================================
          
          Positioned(
            top: -20,
            right: MediaQuery.of(context).size.width / 2 - 80,
            child: Icon(MdiIcons.moonWaxingCrescent, color: Pallete.amarelo.withOpacity(0.3), size: 100),
          ),

        
          // Linha do Chão (opcional, para dar base)
         /* Positioned(
             bottom: 30,
             left: 20, right: 20, // Estica quase de ponta a ponta
             child: Container(height: 2, color: Colors.white10),
          ),
          */
          // ========================================================
          // CAMADA 2: ELEMENTOS PRINCIPAIS (Torre e Player)
          // ========================================================
          
          // --- A TORRE ---
          // Use 'right' e 'bottom' para mover ela.
          Positioned(
            bottom: 20, // Sentada na linha do chão
            // Dica: Para centralizar, você pode usar um cálculo ou ajustar 'right' visualmente.
            // Se quiser ela mais para a direita, aumente este valor.
            right: MediaQuery.of(context).size.width / 2 - 150, 
            child:  Icon(
              MdiIcons.chessRook,
              size: 300,
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
          // --- O PLAYER ---
          // Use 'left' e 'bottom' para mover ele.
          Positioned(
            bottom: 30, // Na mesma linha base da torre
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: const Icon(
              Icons.directions_walk,
              color: Pallete.branco,
              size: 50,
            ),
          ),

          // --- O PONTO/PEDRINHA ---
          // Posicionado relativo ao player
          /*
          Positioned(
            bottom: 35,
            left: MediaQuery.of(context).size.width / 2 - 135, // Um pouco atrás do player
            child: Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: Colors.white70,
                shape: BoxShape.circle, // Ponto redondo fica mais bonito
              ),
            ),
          ),
          */
        ],
      ),
    );
  }
}