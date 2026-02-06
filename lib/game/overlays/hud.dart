import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/pallete.dart'; // Certifique-se que o caminho está certo

class Hud extends StatelessWidget {
  final TowerGame game;

  const Hud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, // <--- Adicione isso se tiver dúvidas
      child:SafeArea(
        child: Stack(
          children: [
            // ---------------------------------------------
            // 1. CANTO SUPERIOR ESQUERDO: STATUS (Vida, Moedas, Chaves)
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
                    // Chama a função de dash do player
                    game.player.startDash();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Fundo semi-transparente
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.flash_on, // Ícone de raio
                        color: Colors.greenAccent,
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