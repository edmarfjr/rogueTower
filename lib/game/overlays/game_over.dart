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
                fontFamily: 'Pixel', // Se tiver fonte customizada, coloque aqui
                fontWeight: FontWeight.w900,
                color: Pallete.vermelho, // Vermelho sangue
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black, offset: Offset(4, 4))
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // INFORMAÇÃO DA SALA
            Text(
              'Você sobreviveu até a Sala ${game.currentRoom}',
              style: const TextStyle(
                fontSize: 20,
                color: Pallete.branco,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // INFORMAÇÃO DE MOEDAS (Opcional)
            Text(
              'Ouro coletado: ${game.coinsNotifier.value}',
              style: const TextStyle(
                fontSize: 16,
                color: Pallete.amarelo,
              ),
            ),

            const SizedBox(height: 50),

            // BOTÃO TENTAR NOVAMENTE
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.verdeCla,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  game.resetGame();
                },
                child: const Text('TENTAR NOVAMENTE', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
            
            const SizedBox(height: 20),

            // BOTÃO VOLTAR AO MENU
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.vermelho,
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  game.returnToMenu();
                },
                child: const Text('VOLTAR AO MENU', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
          ],
        ),
      ),
    );
  }
}