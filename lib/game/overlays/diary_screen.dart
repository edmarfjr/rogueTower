import 'package:TowerRogue/game/components/gameObj/collectible.dart';
import 'package:flutter/material.dart';
import '../components/core/pallete.dart';
import '../tower_game.dart';

class DiaryScreen extends StatelessWidget {
  final TowerGame game;

  const DiaryScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Puxa a lista direto da memória do jogo
    final discoveredItems = game.progress.discoveredItems;

    // Filtra itens que não devem aparecer no diário
    final ignoreList = [
      CollectibleType.coin, CollectibleType.key, CollectibleType.keys,
      CollectibleType.bomba, CollectibleType.bombas, CollectibleType.healthContainer,
      CollectibleType.chest, CollectibleType.rareChest, CollectibleType.bank,
      CollectibleType.nextlevel, CollectibleType.shop, CollectibleType.boss,
      CollectibleType.alquimista, CollectibleType.desafio, CollectibleType.darkShop
    ];

    // 1. Pega em todos os itens válidos
    final validItems = CollectibleType.values.where((t) => !ignoreList.contains(t)).toList();
    
    // 2. Separa em duas listas usando a função que criámos anteriormente!
    final activeItemsList = validItems.where((t) => isItemAtivo(t)).toList();
    final passiveItemsList = validItems.where((t) => !isItemAtivo(t)).toList();

    return Material(
      color: Colors.black87,
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
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
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
              
              // --- PROGRESSO GERAL ---
              Text(
                "ITENS DESCOBERTOS: ${discoveredItems.length} / ${validItems.length}",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 10),

              // --- OS SEPARADORES (TABS) ---
              const TabBar(
                indicatorColor: Pallete.amarelo,
                labelColor: Pallete.amarelo,
                unselectedLabelColor: Colors.white54,
                tabs: [
                  Tab(text: "ITENS PASSIVOS"),
                  Tab(text: "ITENS ATIVOS"),
                ],
              ),

              // --- O CONTEÚDO DE CADA SEPARADOR ---
              Expanded(
                child: TabBarView(
                  children: [
                    // Separador 1: Grelha de Itens Passivos
                    _buildGrid(passiveItemsList, discoveredItems),
                    
                    // Separador 2: Grelha de Itens Ativos
                    _buildGrid(activeItemsList, discoveredItems),
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

        return Tooltip(
          message: isDiscovered ? "${attrs['name']}\n${attrs['desc']}" : "Item Desconhecido",
          textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          decoration: BoxDecoration(color: Colors.black87, border: Border.all(color: Pallete.amarelo)),
          child: Container(
            decoration: BoxDecoration(
              color: Pallete.cinzaEsc,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDiscovered ? (attrs['color'] as Color) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                isDiscovered ? attrs['icon'] : Icons.question_mark,
                color: isDiscovered ? attrs['color'] : Colors.white24,
                size: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}