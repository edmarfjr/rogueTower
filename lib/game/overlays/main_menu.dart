import '../components/core/i18n.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class MainMenu extends StatelessWidget {
  final TowerGame game;

  const MainMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Título do Jogo
            const Text(
              'ROGUE TOWER',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Pallete.branco,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 50),

            // Botão Jogar
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.branco,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  //game.transitionEffect.startTransition(() {
                    game.startGame();
                  //});  
                },
                child: Text(
                  'play'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botão configuracoes
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.branco,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onPressed: () {
                  //game.transitionEffect.startTransition(() {
                    game.overlays.add('SettingsMenu');
                  //});  
                },
                child: Text(
                  'settings'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}