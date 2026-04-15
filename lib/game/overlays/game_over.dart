import 'package:towerrogue/game/components/core/ad_manager.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class GameOver extends StatelessWidget {
  final TowerGame game;

  const GameOver({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.85), // Fundo escuro semi-transparente
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TÍTULO
            const Text(
              'GAME OVER',
              style: TextStyle(
                fontSize: 50,
                fontFamily: 'pixelFont', // Se tiver fonte customizada, coloque aqui
                fontWeight: FontWeight.w900,
                color: Pallete.vermelho, // Vermelho sangue
              ),
            ),
            
            const SizedBox(height: 20),

            // INFORMAÇÃO DA SALA
            Text(
              'Você sobreviveu até a Sala ${game.currentRoom} do andar ${game.currentLevel}',
              style: const TextStyle(
                fontSize: 20,
                color: Pallete.branco,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // INFORMAÇÃO DE MOEDAS (Opcional)
            Text(
              'Almas coletadas: ${game.progress.souls}',
              style: const TextStyle(
                fontSize: 16,
                color: Pallete.amarelo,
              ),
            ),

            const SizedBox(height: 50),

            // BOTÃO TENTAR NOVAMENTE
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.preto,
                  minimumSize: const Size(200, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, 
                    ),
                    side: const BorderSide(
                      width: 2.0,
                      color: Pallete.branco,
                    ),
                ),
                onPressed: () {
                  game.resetGame(game.selectedClass); 
                },
                child: const Text('TENTAR NOVAMENTE', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
            
            const SizedBox(height: 20),

            // BOTÃO VOLTAR AO MENU
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.preto,
                  minimumSize: const Size(200, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, 
                    ),
                    side: const BorderSide(
                      width: 2.0,
                      color: Pallete.branco,
                    ),
                ),
                onPressed: () {                 
                  game.returnToMenu(); 
                },
                child: const Text('VOLTAR AO MENU', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.preto,
                  minimumSize: const Size(200, 50),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero, 
                    ),
                    //side: const BorderSide(
                    //  width: 2.0,
                    //  color: Pallete.branco,
                    //),
                ),
                child: const Text('REVIVER', style: TextStyle(fontSize: 18, color: Pallete.branco)),
                onPressed: () {
                  AdManager.showRewardedAd(
                    onRewardEarned: () {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        game.player.healthNotifier.value = (game.player.maxHealth/2).toInt(); 
                        game.player.setInvencibility(4);
                        game.overlays.remove('GameOver'); 
                        game.resumeEngine(); 
                      });
                    }
                  );
                }
              )
          ],
        ),
      ),
    );
  }
}