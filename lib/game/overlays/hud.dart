import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flutter/material.dart';
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
                  
                  // --- INVENTÁRIO DE ITENS ATIVOS ---
                  ValueListenableBuilder<List<ActiveItemData?>>(
                    valueListenable: game.player.activeItems, 
                    builder: (context, activeItems, child) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
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

                  // --- VIDA ---
                  ValueListenableBuilder<int>(
                    valueListenable: game.player.healthNotifier,
                    builder: (context, currentHealth, child) {
                      final int totalHearts = (game.player.maxHealth / 2).ceil();
                      return Row(
                        children: List.generate(totalHearts, (index) {
                          int heartValueTimesTwo = (index + 1) * 2;
                          String spriteName;
                          
                          if (currentHealth >= heartValueTimesTwo) {
                             spriteName = 'sprites/hud/hpCheio.png'; 
                          } else if (currentHealth >= heartValueTimesTwo - 1) {
                             spriteName = 'sprites/hud/hpMeio.png'; 
                          } else {
                             spriteName = 'sprites/hud/hpVazio.png'; 
                          }
                          return PixelSprite(imagePath: spriteName, color: Pallete.vermelho, size: 32);
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
                          String spriteName;
                          if (currentHealth >= heartValueTimesTwo) {
                             spriteName = 'sprites/hud/hpCheio.png'; 
                          } else if (currentHealth >= heartValueTimesTwo - 1) {
                             spriteName = 'sprites/hud/hpMeio.png'; 
                          } else {
                             spriteName = 'sprites/hud/hpVazio.png'; 
                          }
                          return PixelSprite(imagePath: spriteName, color: Pallete.azulCla, size: 32);
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
                          return const PixelSprite(imagePath: 'sprites/hud/escudo.png', color: Pallete.cinzaCla, size: 32);
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
                          return const PixelSprite(imagePath: 'sprites/hud/dash.png', color: Pallete.verdeCla, size: 32);
                        }),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // MOEDAS
                  ValueListenableBuilder<int>(
                    valueListenable: game.coinsNotifier,
                    builder: (context, coins, child) {
                      return Row(
                        children: [
                          const PixelSprite(imagePath: 'sprites/hud/coin.png', color: Pallete.amarelo, size: 32),
                          const SizedBox(width: 4),
                          Text(
                            ": $coins",
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Pallete.amarelo,
                              //shadows: [Shadow(blurRadius: 2, color: Pallete.laranja, offset: Offset(2, 2))],
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // CHAVES
                  ValueListenableBuilder<int>(
                    valueListenable: game.keysNotifier,
                    builder: (context, keys, child) {
                      return Row(
                        children: [
                          const PixelSprite(imagePath: 'sprites/hud/key.png', color: Pallete.laranja, size: 32),
                          const SizedBox(width: 4),
                          Text(
                            ": $keys", 
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Pallete.laranja,
                              //shadows: [Shadow(blurRadius: 2, color: Pallete.marrom, offset: Offset(2, 2))],
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
                          const PixelSprite(imagePath: 'sprites/hud/bomb.png', color: Pallete.lilas, size: 32),
                          const SizedBox(width: 4),
                          Text(
                            ": $bombs", 
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Pallete.lilas,
                             // shadows: [Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))],
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
                          const PixelSprite(imagePath: 'sprites/hud/soul.png', color: Pallete.azulCla, size: 32),
                          const SizedBox(width: 4),
                          Text(
                            ": $souls", 
                            style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold, color: Pallete.azulCla,
                              //shadows: [Shadow(blurRadius: 2, color: Pallete.azulEsc, offset: Offset(2, 2))],
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
                icon: const PixelSprite(imagePath: 'sprites/hud/pause.png', color: Pallete.branco, size: 40),
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
                      child: PixelSprite(imagePath: 'sprites/hud/dash.png', color: Pallete.verdeCla, size: 40),
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
                    child: const Center(
                      child: PixelSprite(imagePath: 'sprites/hud/bomb.png', color: Pallete.cinzaEsc, size: 40),
                    ),
                  ),
                ),
              ),
            ),  

            // ---------------------------------------------
            // BOTÃO DE INTERAÇÃO (Dinâmico)
            // ---------------------------------------------
            Positioned(
              bottom: 130,
              right: 110, // Fica ao lado esquerdo da bomba e acima do dash
              child: ValueListenableBuilder<bool>(
                valueListenable: game.canInteractNotifier,
                builder: (context, canInteract, child) {
                  // Se não tiver nada perto, o botão SOME da tela!
                  if (!canInteract) return const SizedBox.shrink();

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Chama a função da porta ou do baú
                        game.onInteractAction?.call();
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
                          // Um ícone de mãozinha ou de exclamação usando sua fonte de pixel
                          child: Text(
                            "!", 
                            style: TextStyle(
                              fontFamily: 'pixelFont', // Ajuste para sua fonte
                              color: Pallete.branco,
                              fontSize: 40,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
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
                          child: PixelSprite(
                            imagePath: lost ? 'sprites/hud/hpMeio.png' : 'sprites/hud/hpVazio.png',
                            color: lost ? Pallete.vermelho : Colors.white54,
                            size: 32,
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

    String? slotIcon;
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
                PixelSprite(
                  imagePath: 'sprites/itens/$slotIcon.png',
                  color: slotColor ?? Pallete.branco,
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
  //_buildItemSlot com sprites
  // ==========================================================
  /*
  Widget _buildItemSlot(int index, ActiveItemData? itemData) {
    bool isEmpty = itemData == null;
    bool isReady = isEmpty || itemData.isReady;

    String? slotSpritePath;
    Color? slotColor;
    if (!isEmpty) {
      final attrs = Collectible.getAttributes(itemData.type);
      
      // IMPORTANTE: Assumindo que você mudou o seu getAttributes
      // para retornar um 'sprite' (String) no lugar de um 'icon' (IconData)
      slotSpritePath = attrs['sprite']; 
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
                // 1. O Ícone Pixel Art Oficial puxado do jogo!
                if (slotSpritePath != null)
                  PixelSprite(
                    imagePath: slotSpritePath,
                    color: slotColor ?? Pallete.branco,
                    size: 32,
                  ),
                
                // 2. A PELÍCULA DE COOLDOWN E A CARGA
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
  */
  
}
class PixelSprite extends StatelessWidget {
  final String imagePath;
  final Color color;
  final double size;

  const PixelSprite({
    super.key,
    required this.imagePath,
    required this.color,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/$imagePath', // Caminho padrão do Flame para o Flutter
      width: size,
      height: size,
      color: color,
      colorBlendMode: BlendMode.modulate, 
      filterQuality: FilterQuality.none, 
      fit: BoxFit.contain,
      isAntiAlias: false,
    );
  }
}