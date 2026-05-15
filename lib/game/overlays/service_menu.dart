import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/tower_game.dart';
//import 'package:towerrogue/game/components/gameObj/collectible.dart'; 

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
                    game.overlays.remove('ServiceMenu');
                    game.resumeEngine();
                  },
                  child:  Text("no".tr(), style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.preto)),
                ),
                
                // BOTAO SIM
                ElevatedButton(
                  //style: ElevatedButton.styleFrom(backgroundColor: Pallete.branco),
                  onPressed: () {
                    _comprarServico();
                  },
                  child:  Text("${"yes".tr()} (20\$)", style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.preto)),
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
      player.collectCoin(-20);
      
      player.receberMassagem(6);

      game.overlays.remove('ServiceMenu');
      game.resumeEngine();
    } 
  }
}