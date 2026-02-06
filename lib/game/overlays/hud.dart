import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart'; 

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
            // 1. CANTO SUPERIOR ESQUERDO: STATUS (Vida, Moedas, Chaves, SOULS)
            // ---------------------------------------------
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // VIDA
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.healthNotifier,
                    builder: (context, currentHealth, child) {
                      return Row(
                        children: List.generate(game.player.maxHealth, (index) {
                          return Icon(
                            index < currentHealth ? Icons.favorite : Icons.favorite_border,
                            color: Pallete.vermelho,
                            size: 30,
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
                      if (currentShield == 0) return const SizedBox.shrink(); // Só mostra se tiver escudo
                      return Row(
                        children: List.generate(currentShield, (index) {
                          return const Icon(
                            Icons.gpp_bad,
                            color: Pallete.cinzaCla, // Ou AzulCiano
                            size: 30,
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  // dash
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.dashNotifier,
                    builder: (context, currentDash, child) {
                      if (currentDash == 0) return const SizedBox.shrink(); // Só mostra se tiver escudo
                      return Row(
                        children: List.generate(currentDash, (index) {
                          return const Icon(
                            Icons.double_arrow,
                            color: Pallete.verdeCla, // Ou AzulCiano
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
                        "\$ $coins",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Pallete.amarelo,
                          shadows: [
                            Shadow(blurRadius: 2, color: Pallete.colorDarkest, offset: Offset(2, 2))
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
                      return Text(
                        "Keys $keys",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Pallete.laranja,
                          shadows: [
                            Shadow(blurRadius: 2, color: Pallete.colorDarkest, offset: Offset(2, 2))
                          ],
                          decoration: TextDecoration.none,
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // --- CONTADOR DE SOULS ---
                  ValueListenableBuilder<int>(
                    valueListenable: game.progress.soulsNotifier, // Acessa o game.progress
                    builder: (context, souls, child) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.whatshot, // Ícone de Fogo/Alma
                            color: Pallete.lilas, // Roxo Mágico
                            size: 28,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$souls", 
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Pallete.lilas, // Roxo Mágico
                              shadows: [
                                Shadow(blurRadius: 2, color: Pallete.colorDarkest, offset: Offset(2, 2))
                              ],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // -------------------------------
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
              right: 20,
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
          ],
        ),
      )
    );
  }
}