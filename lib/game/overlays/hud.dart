import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/pallete.dart'; // Certifique-se que o caminho está certo

class Hud extends StatelessWidget {
  final TowerGame game;

  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- LADO ESQUERDO: STATUS (Vida, Moedas, Chaves) ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. VIDA (Corações Reativos)
                ValueListenableBuilder<int>(
                  valueListenable: game.player.healthNotifier,
                  builder: (context, currentHealth, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Icon(
                          index < currentHealth ? Icons.favorite : Icons.favorite_border,
                          color: Pallete.vermelho,
                          size: 30,
                        );
                      }),
                    );
                  },
                ),
                
                const SizedBox(height: 8), // Espaçamento

                // 2. MOEDAS
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

                // 3. CHAVES
                ValueListenableBuilder<int>(
                  valueListenable: game.keysNotifier,
                  builder: (context, keys, child) {
                    return Text(
                      "Keys $keys",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Pallete.laranja, // Certifique-se que essa cor existe no Pallete
                        shadows: [
                          Shadow(blurRadius: 2, color: Pallete.colorDarkest, offset: Offset(2, 2))
                        ],
                        decoration: TextDecoration.none,
                      ),
                    );
                  },
                ),
              ],
            ),

            // --- LADO DIREITO: BOTÃO DE PAUSE ---
            IconButton(
              icon: const Icon(Icons.pause_circle_filled, color: Colors.white, size: 40),
              onPressed: () {
                game.pauseGame(); // Chama a função que criamos no TowerGame
              },
            ),
          ],
        ),
      ),
    );
  }
}