import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/tower_game.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart'; // Para acessar os tipos de itens

class ServiceMenu extends StatelessWidget {
  final TowerGame game;

  const ServiceMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Pallete.preto,
          border: Border.all(color: Pallete.branco, width: 4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              "dama".tr(),
              style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.branco, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              "servicoMassage".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.branco, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // BOTAO NAO
                ElevatedButton(
                 // style: ElevatedButton.styleFrom(backgroundColor: Pallete.branco),
                  onPressed: () {
                    // Apenas fecha o menu e volta para o jogo
                    game.overlays.remove('ServiceMenu');
                    game.resumeEngine(); // Despausa o jogo se você pausou
                  },
                  child: const Text("NÃO", style: TextStyle(fontFamily: 'pixelFont', color: Pallete.preto)),
                ),
                
                // BOTAO SIM
                ElevatedButton(
                  //style: ElevatedButton.styleFrom(backgroundColor: Pallete.branco),
                  onPressed: () {
                    _comprarServico();
                  },
                  child: const Text("SIM (20\$)", style: TextStyle(fontFamily: 'pixelFont', color: Pallete.preto)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _comprarServico() {
    final player = game.player;

    if (game.coinsNotifier.value >= 20) {
      // 1. Cobra o valor
      player.collectCoin(-20);
      
      // 2. Aplica o Serviço (Aqui usamos a mecânica de bebida que criamos!)
      player.receberMassagem(6);

      // 3. Fecha o menu e retoma o jogo
      game.overlays.remove('ServiceMenu');
      game.resumeEngine();
    } else {
      // Opcional: Feedback se não tiver dinheiro
      // (O menu não fecha, o jogador precisa clicar no NÃO)
    }
  }
}