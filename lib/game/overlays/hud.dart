import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; 
import '../tower_game.dart';
import '../components/core/pallete.dart'; 
import '../components/core/i18n.dart';

class Hud extends StatelessWidget {
  final TowerGame game;

  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Stack(
          children: [
            // ---------------------------------------------
            // 1. CANTO SUPERIOR ESQUERDO: STATUS
            // ---------------------------------------------
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- VIDA (COM MEIO CORAÇÃO) ---
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.healthNotifier,
                    builder: (context, currentHealth, child) {
                      
                      // Calcula quantos corações desenhar no total (Ex: 6 HP = 3 Corações)
                      final int totalHearts = (game.player.maxHealth / 2).ceil();

                      return Row(
                        children: List.generate(totalHearts, (index) {
                          // Lógica para saber se o coração é Cheio, Meio ou Vazio
                          // index 0 -> representa HP 1 e 2
                          // index 1 -> representa HP 3 e 4
                          int heartValueTimesTwo = (index + 1) * 2;

                          IconData icon;
                          if (currentHealth >= heartValueTimesTwo) {
                             // [CHEIO]
                             icon = MdiIcons.heart; 
                          } else if (currentHealth >= heartValueTimesTwo - 1) {
                             // [METADE]
                             icon = MdiIcons.heartHalfFull; 
                          } else {
                             // [VAZIO]
                             icon = MdiIcons.heartOutline; 
                          }

                          return Icon(
                            icon,
                            color: Pallete.vermelho,
                            size: 30, // MDI Icons costumam ficar bem nesse tamanho
                          );
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ESCUDO
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.shieldNotifier,
                    builder: (context, currentShield, child) {
                      if (currentShield == 0) return const SizedBox.shrink();
                      return Row(
                        children: List.generate(currentShield, (index) {
                          return  Icon(
                            MdiIcons.shield,
                            color: Pallete.cinzaCla,
                            size: 30,
                          );
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // DASH
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.dashNotifier,
                    builder: (context, currentDash, child) {
                      if (currentDash == 0) return const SizedBox.shrink();
                      return Row(
                        children: List.generate(currentDash, (index) {
                          return const Icon(
                            Icons.double_arrow,
                            color: Pallete.verdeCla,
                            size: 30,
                          );
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // MOEDAS
                  ValueListenableBuilder<int>(
                    valueListenable: game.coinsNotifier,
                    builder: (context, coins, child) {
                      return Text(
                        "\$ : $coins",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Pallete.amarelo,
                          shadows: [
                            Shadow(blurRadius: 2, color: Pallete.laranja, offset: Offset(2, 2))
                          ],
                          decoration: TextDecoration.none,
                        ),
                      );
                    },
                  ),

                  // CHAVES
                  ValueListenableBuilder<int>(
                    valueListenable: game.keysNotifier,
                    builder: (context, keys, child) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.key, // Ou MdiIcons.fire
                            color: Pallete.laranja,
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ": $keys", 
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Pallete.laranja,
                              shadows: [
                                Shadow(blurRadius: 2, color: Pallete.marrom, offset: Offset(2, 2))
                              ],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // BOMBAS
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.bombNotifier,
                    builder: (context, bombs, child) {
                      return Row(
                        children: [
                           Icon(
                            MdiIcons.bomb, // Ou MdiIcons.fire
                            color: Pallete.lilas,
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ": $bombs", 
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Pallete.lilas,
                              shadows: [
                                Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))
                              ],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // SOULS
                  ValueListenableBuilder<int>(
                    valueListenable: game.progress.soulsNotifier,
                    builder: (context, souls, child) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.whatshot, // Ou MdiIcons.fire
                            color: Pallete.lilas,
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ": $souls", 
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Pallete.lilas,
                              shadows: [
                                Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))
                              ],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
        
            // ---------------------------------------------
            // 2. CANTO SUPERIOR DIREITO: PAUSE
            // ---------------------------------------------
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 40),
                onPressed: () {
                  game.pauseGame();
                },
              ),
            ),

            // ---------------------------------------------
            // 3. CANTO INFERIOR DIREITO: BOTÃO DE DASH
            // ---------------------------------------------
            Positioned(
              bottom: 40,
              right: 90,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    game.player.startDash();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Pallete.branco.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.double_arrow,
                        color: Pallete.verdeCla,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),  
            // ---------------------------------------------
            // 4. CANTO INFERIOR DIREITO: BOTÃO DE BOMBA
            // ---------------------------------------------
            Positioned(
              bottom: 130,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    game.player.criaBomba();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Pallete.branco.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child:  Center(
                      child: Icon(
                        MdiIcons.bomb,
                        color: Pallete.cinzaEsc,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),  
            // ---------------------------------------------
            // 5. TOPO CENTRO: NÍVEL ATUAL
            // ---------------------------------------------
            Positioned(
              top: 15, // Um pouco mais para baixo
              left: 0,
              right: 0,
              child: Center(
                // Listenable.merge escuta uma lista de notifiers.
                // Se o Nível OU a Sala mudar, ele reconstrói o texto.
                child: ListenableBuilder(
                  listenable: Listenable.merge([
                    game.currentLevelNotifier, 
                    game.currentRoomNotifier
                  ]),
                  builder: (context, child) {
                    final int level = game.currentLevelNotifier.value;
                    final int room = game.currentRoomNotifier.value;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "$level - $room", 
                          style: const TextStyle(
                            fontSize: 24,
                            fontFamily: 'Pixel', 
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3.0,
                            shadows: [
                              Shadow(blurRadius: 4, color: Colors.black, offset: Offset(3, 3)),
                              Shadow(blurRadius: 10, color: Colors.black), // Borda suave
                            ],
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),        
          ],
        ),
      )
    );
  }
}