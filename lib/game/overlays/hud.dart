import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; 
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
            // 1. CANTO SUPERIOR ESQUERDO: STATUS E INVENTÁRIO ATIVO
            // ---------------------------------------------
            Positioned(
              top: 10,
              left: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // --- INVENTÁRIO DE ITENS ATIVOS (NOVO!) ---
                  ValueListenableBuilder<List<ActiveItemData?>>(
                    // Escuta a lista de itens ativos que criamos no Player
                    valueListenable: game.player.activeItems, 
                    builder: (context, activeItems, child) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0), // Espaço antes da vida
                        child: Row(
                          children: [
                            _buildItemSlot(0, activeItems[0]),
                            const SizedBox(width: 8),
                            _buildItemSlot(1, activeItems[1]),
                          ],
                        ),
                      );
                    },
                  ),

                  // --- VIDA---
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.healthNotifier,
                    builder: (context, currentHealth, child) {
                      final int totalHearts = (game.player.maxHealth / 2).ceil();
                      return Row(
                        children: List.generate(totalHearts, (index) {
                          int heartValueTimesTwo = (index + 1) * 2;
                          IconData icon;
                          if (currentHealth >= heartValueTimesTwo) {
                             icon = MdiIcons.heart; 
                          } else if (currentHealth >= heartValueTimesTwo - 1) {
                             icon = MdiIcons.heartHalfFull; 
                          } else {
                             icon = MdiIcons.heartOutline; 
                          }
                          return Icon(icon, color: Pallete.vermelho, size: 30);
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),

                  // --- VIDA ARTIFICIAL ---
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.artificialHealthNotifier,
                    builder: (context, currentHealth, child) {
                      final int totalHearts = (game.player.maxArtificialHealth / 2).ceil();
                      return Row(
                        children: List.generate(totalHearts, (index) {
                          int heartValueTimesTwo = (index + 1) * 2;
                          IconData icon;
                          if (currentHealth >= heartValueTimesTwo) {
                             icon = MdiIcons.heart; 
                          } else if (currentHealth >= heartValueTimesTwo - 1) {
                             icon = MdiIcons.heartHalfFull; 
                          } else {
                             icon = MdiIcons.heartOutline; 
                          }
                          return Icon(icon, color: Pallete.azulCla, size: 30);
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // ESCUDO
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.shieldNotifier,
                    builder: (context, currentShield, child) {
                      if (currentShield == 0) return const SizedBox.shrink();
                      return Row(
                        children: List.generate(currentShield, (index) {
                          return  Icon(MdiIcons.shield, color: Pallete.cinzaCla, size: 30);
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 2),
                  
                  // DASH
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.dashNotifier,
                    builder: (context, currentDash, child) {
                      if (currentDash == 0) return const SizedBox.shrink();
                      return Row(
                        children: List.generate(currentDash, (index) {
                          return const Icon(Icons.double_arrow, color: Pallete.verdeCla, size: 30);
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
                        "\$ : $coins",
                        style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold, color: Pallete.amarelo,
                          shadows: [Shadow(blurRadius: 2, color: Pallete.laranja, offset: Offset(2, 2))],
                          decoration: TextDecoration.none,
                        ),
                      );
                    },
                  ),

                  // CHAVES
                  ValueListenableBuilder<int>(
                    valueListenable: game.keysNotifier,
                    builder: (context, keys, child) {
                      return Row(
                        children: [
                          const Icon(Icons.key, color: Pallete.laranja, size: 28),
                          const SizedBox(width: 4),
                          Text(
                            ": $keys", 
                            style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Pallete.laranja,
                              shadows: [Shadow(blurRadius: 2, color: Pallete.marrom, offset: Offset(2, 2))],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // BOMBAS
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.bombNotifier,
                    builder: (context, bombs, child) {
                      return Row(
                        children: [
                           Icon(MdiIcons.bomb, color: Pallete.lilas, size: 28),
                          const SizedBox(width: 4),
                          Text(
                            ": $bombs", 
                            style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Pallete.lilas,
                              shadows: [Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // SOULS
                  ValueListenableBuilder<int>(
                    valueListenable: game.progress.soulsNotifier,
                    builder: (context, souls, child) {
                      return Row(
                        children: [
                          const Icon(Icons.whatshot, color: Pallete.lilas, size: 28),
                          const SizedBox(width: 4),
                          Text(
                            ": $souls", 
                            style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold, color: Pallete.lilas,
                              shadows: [Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
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
              right: 90,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    game.player.startDash();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Pallete.branco.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Pallete.branco.withOpacity(0.5), width: 2),
                    ),
                    child: const Center(
                      child: Icon(Icons.double_arrow, color: Pallete.verdeCla, size: 40),
                    ),
                  ),
                ),
              ),
            ),  
            
            // ---------------------------------------------
            // 4. CANTO INFERIOR DIREITO: BOTÃO DE BOMBA
            // ---------------------------------------------
            Positioned(
              bottom: 130,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    game.player.criaBomba();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: Pallete.branco.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Pallete.branco.withOpacity(0.5), width: 2),
                    ),
                    child: Center(
                      child: Icon(MdiIcons.bomb, color: Pallete.cinzaEsc, size: 40),
                    ),
                  ),
                ),
              ),
            ),  

            // ---------------------------------------------
            // 5. TOPO CENTRO: DESAFIO
            // ---------------------------------------------
            Positioned(
              top: 50, 
              left: 0,
              right: 0,
              child: ValueListenableBuilder<int>(
                valueListenable: game.challengeHitsNotifier,
                builder: (context, hitsTaken, child) {
                  if (hitsTaken < 0) return const SizedBox.shrink();

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "DESAFIO: ",
                        style: TextStyle(
                          color: Pallete.amarelo, fontWeight: FontWeight.bold, fontSize: 20,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)], decoration: TextDecoration.none,
                        ),
                      ),
                      ...List.generate(3, (index) {
                        bool lost = index < hitsTaken;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Icon(
                            lost ? MdiIcons.heartBroken : MdiIcons.heartOutline,
                            color: lost ? Colors.red : Colors.white54,
                            size: 30,
                            shadows: const [Shadow(blurRadius: 4, color: Colors.black)],
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  // ==========================================================
  // HELPER WIDGET: Desenha um único slot de item ativo
  // ==========================================================
  Widget _buildItemSlot(int index, ActiveItemData? itemData) {
    bool isEmpty = itemData == null;
    bool isReady = isEmpty || itemData.isReady;

    IconData? slotIcon;
    Color? slotColor;
    if (!isEmpty) {
      final attrs = Collectible.getAttributes(itemData.type);
      slotIcon = attrs['icon'];
      slotColor = attrs['color'];
    }

    return GestureDetector(
      onTap: () {
        if (!isEmpty && isReady) {
          game.player.useActiveSlot(index);
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Pallete.cinzaEsc.withOpacity(0.8),
          border: Border.all(
            color: !isEmpty && isReady ? Pallete.amarelo : Pallete.cinzaCla, 
            width: 2
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: isEmpty 
          ? const SizedBox.shrink() 
          : Stack(
              alignment: Alignment.center,
              children: [
                // 1. O Ícone Oficial puxado do jogo!
                Icon(
                  slotIcon,
                  color: slotColor,
                  size: 32,
                ),
                
                // 2. A PELÍCULA DE COOLDOWN E A CARGA (Apenas se não estiver pronto)
                if (!isReady) ...[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65), 
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Text(
                    "${itemData.currentCharge}/${itemData.maxCharge}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ],
            ),
      ),
    );
  }

  // ==========================================================
  // HELPER PARA CORES E ÍCONES (Já que o método do Collectible é privado)
  // ==========================================================
  /*
  IconData _getIconForType(CollectibleType type) {
    switch (type) {
      case CollectibleType.pocaVeneno: return MdiIcons.cloudOffOutline;
      case CollectibleType.tornado: return MdiIcons.weatherTornado;
      // Adicione seus novos itens ativos aqui:
      // case CollectibleType.suaPocaoDeCura: return MdiIcons.bottleTonicPlus;
      default: return Icons.star;
    }
  }

  Color _getColorForType(CollectibleType type) {
    switch (type) {
      case CollectibleType.pocaVeneno: return Pallete.verdeEsc;
      case CollectibleType.tornado: return Pallete.branco;
      default: return Pallete.amarelo;
    }
  }
  */
}