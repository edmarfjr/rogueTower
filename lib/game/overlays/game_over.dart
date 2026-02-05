import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/pallete.dart';

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
                color: Colors.white,
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
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black, // Cor do texto
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: const BorderSide(color: Pallete.colorDarkest, width: 3),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  game.resetGame();
                },
                child: const Text(
                  'TENTAR NOVAMENTE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // BOTÃO VOLTAR AO MENU
            TextButton(
              onPressed: () {
                game.returnToMenu();
              },
              child: const Text(
                'Voltar ao Menu',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}