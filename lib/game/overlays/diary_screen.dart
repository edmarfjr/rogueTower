import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/overlays/bestiary_widget.dart';
import 'package:towerrogue/game/overlays/hud.dart';
import '../components/core/pallete.dart';
import '../tower_game.dart';
// IMPORTANTE: Importe o arquivo onde você salvou o BestiaryWidget que criamos antes!
// import 'bestiary_widget.dart'; 

class DiaryScreen extends StatelessWidget {
  final TowerGame game;

  const DiaryScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Puxa a lista direto da memória do jogo
    final discoveredItems = game.progress.discoveredItems;
    
    // ATENÇÃO: Puxa a lista de inimigos mortos (ajuste para o local exato onde você salvou no seu jogo)
    final unlockedEnemies = game.bestiaryKills; // ou game.progress.bestiaryKills

    // Filtra itens que não devem aparecer no diário
    final ignoreList = [
      CollectibleType.potion, CollectibleType.potionUm, CollectibleType.coinUm, CollectibleType.shield,
      CollectibleType.coin, CollectibleType.key, CollectibleType.keys, CollectibleType.souls,
      CollectibleType.bomba, CollectibleType.bombas, CollectibleType.healthContainer,
      CollectibleType.chest, CollectibleType.rareChest, CollectibleType.bank,
      CollectibleType.nextLevel, CollectibleType.shop, CollectibleType.boss, CollectibleType.slotMachine,
      CollectibleType.alquimista, CollectibleType.desafio, CollectibleType.darkShop, CollectibleType.doacaoSangue,
      CollectibleType.slotMachine, CollectibleType.artificialHp, CollectibleType.cajadoQuebrado
    ];

    // 1. Pega em todos os itens válidos
    final validItems = CollectibleType.values.where((t) => !ignoreList.contains(t)).toList();

    return Material(
      color: Pallete.preto,
      // DefaultTabController gere a lógica dos separadores automaticamente
      child: DefaultTabController(
        length: 2, 
        child: SafeArea(
          child: Column(
            children: [
              // --- CABEÇALHO ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const PixelSprite(
                      imagePath: 'sprites/hud/setaEsq.png',
                      color: Pallete.branco,
                      size: 32,
                    ),
                      onPressed: (){
                        game.overlays.remove('DiaryScreen'); 
                        game.overlays.add('MainMenu'); 
                      } ,
                    ),
                    const Text(
                      "COMPÊNDIO",
                      style: TextStyle(
                        color: Pallete.amarelo,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 40), 
                  ],
                ),
              ),
              
              // --- OS SEPARADORES (TABS) ---
              const TabBar(
                indicatorColor: Pallete.amarelo,
                labelColor: Pallete.amarelo,
                unselectedLabelColor: Colors.white54,
                tabs: [
                  Tab(text: "ITENS"),
                  Tab(text: "BESTIÁRIO"), // Nova aba!
                ],
              ),
              
              // --- O CONTEÚDO DAS ABAS (TabBarView) ---
              Expanded(
                child: TabBarView(
                  children: [
                    // --- ABA 1: ITENS ---
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          "ITENS DESCOBERTOS: ${discoveredItems.length} / ${validItems.length}",
                          style: const TextStyle(color: Pallete.cinzaCla, fontSize: 16),
                        ),
                        Expanded(
                          child: _buildGrid(validItems, discoveredItems),
                        ),
                      ],
                    ),

                    // --- ABA 2: BESTIÁRIO ---
                    // Chama o widget do bestiário passando a lista de monstros mortos
                    BestiaryWidget(unlockedEnemyIds: unlockedEnemies),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(List<CollectibleType> items, List<String> discoveredList) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5, 
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final type = items[index];
        // Checa se já pegou o item
        final isDiscovered = discoveredList.contains(type.toString());
        final attrs = Collectible.getAttributes(type);

        String desc = attrs['desc'].toString().toLowerCase();

        if (isItemAtivo(type)) {
          if (isItemRecarregavel(type)) {
            desc += "\n[recarregável]";
          } else if (isItemUsoUnico(type)) {
            desc += "\n[uso único]";
          }
        }

        return Tooltip(
          message: isDiscovered ? "${attrs['name'].toUpperCase()}\n$desc" : "Item Desconhecido",
          textStyle: const TextStyle(fontSize: 14, color: Pallete.branco),
          decoration: BoxDecoration(color: Pallete.preto, border: Border.all(color: Pallete.amarelo)),
          child: Container(
            decoration: BoxDecoration(
              color: Pallete.preto,
              borderRadius: BorderRadius.zero,
              border: Border.all(
                color: isDiscovered ? Pallete.branco: Pallete.cinzaEsc,
                width: 1,
              ),
            ),
            child: Center(
              child: PixelSprite(
                imagePath: isDiscovered ? 'sprites/itens/${attrs['icon']}.png' : 'sprites/itens/noItem.png', 
                color: isDiscovered ? attrs['color'] : Pallete.cinzaEsc, 
                size: 48
              )
            ),
          ),
        );
      },
    );
  }
}