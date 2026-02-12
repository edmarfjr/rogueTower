import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class VictoryMenu extends StatelessWidget {
  final TowerGame game;

  const VictoryMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Calcula uma pontuação simples baseada em Almas + Vida + Ouro
    final int score = (game.progress.souls * 100) + 
                      (game.coinsNotifier.value * 10) + 
                      (game.player.healthNotifier.value * 50);

    return Material(
      color: Colors.black.withOpacity(0.85), // Fundo escuro transparente
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallete.cinzaEsc, // Fundo do cartão
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pallete.amarelo, width: 4), // Borda Dourada
            boxShadow: [
              BoxShadow(color: Pallete.amarelo.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              const Icon(Icons.emoji_events, color: Pallete.amarelo, size: 80),
              const SizedBox(height: 10),
              const Text(
                "VITÓRIA!",
                style: TextStyle(
                  fontFamily: 'Pixel', // Se tiver fonte pixelada
                  fontSize: 40,
                  color: Pallete.amarelo,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))],
                ),
              ),
              const SizedBox(height: 20),
              
              // Estatísticas
              _buildStatRow("Almas Coletadas", "${game.progress.souls}", Icons.whatshot),
              _buildStatRow("Ouro Acumulado", "${game.coinsNotifier.value}", Icons.monetization_on),
              _buildStatRow("Vida Restante", "${game.player.healthNotifier.value}", Icons.favorite),
              
              const Divider(color: Pallete.cinzaCla, thickness: 2, height: 30),
              
              Text(
                "PONTUAÇÃO TOTAL: $score",
                style: const TextStyle(
                  fontSize: 24, 
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                ),
              ),

              const SizedBox(height: 30),

              // Botão de Reiniciar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.verdeEsc,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: const BorderSide(color: Pallete.verdeCla, width: 3),
                  ),
                  onPressed: () {
                    // Reinicia o jogo
                    game.transitionEffect.startTransition(() {
                      game.overlays.remove('victory');
                      game.resetGame(); 
                    }); 
                    
                  },
                  child: const Text(
                    "JOGAR NOVAMENTE",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Pallete.cinzaCla, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Pallete.cinzaCla, fontSize: 18)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}