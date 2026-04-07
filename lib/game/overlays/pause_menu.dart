import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:towerrogue/game/overlays/hud.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';
import '../components/core/i18n.dart';

class PauseMenu extends StatelessWidget {
  final TowerGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final int hp = game.player.healthNotifier.value;
    final int maxHp = game.player.maxHealth;
    final int dmg = (game.player.returnDamage() / game.player.damageIni * 100).round();
    final int dot = (game.player.dot / game.player.dotIni * 100).round();
    final int fireRate = (game.player.fireRateIni / game.player.fireRate  * 100).round();
    final int range = (game.player.attackRange / game.player.attackRangeIni * 100).round();
    final int critChance = (game.player.returnCritChance()).round();
    final int critDmg = (game.player.critDamage / game.player.critDamageIni * 100).round();
    final int speed = (game.player.moveSpeed / game.player.moveSpeedIni * 100).round();
    final int sorte = game.player.sorte.toInt();
    final int level = game.currentLevel;
    final int room = game.currentRoom;

    // Busca a lista de itens adquiridos do jogador
    final itemsList = game.player.getAcquiredItemsList();

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5),
      body: Center(
        child: Container(
          width: 320, 
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallete.azulEsc,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pallete.branco, width: 2),
          ),
          // SingleChildScrollView evita o erro de Pixel Overflow se a tela for pequena!
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'paused'.tr(),
                  style: const TextStyle(
                    fontSize: 30,
                    color: Pallete.branco,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // -----------------------------------------
                // CAIXA DE STATUS DO JOGADOR
                // -----------------------------------------
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      _buildStatRow(Icons.favorite, 'health'.tr(), '$hp / $maxHp', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(MdiIcons.sword, 'dmg'.tr(), '$dmg%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(MdiIcons.fire, 'dot'.tr(), '$dot%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(MdiIcons.sword, 'fire_rate'.tr(), '$fireRate%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.whatshot, 'range'.tr(), '$range%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.whatshot, 'critChance'.tr(), '$critChance%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.whatshot, 'sorte'.tr(), '$sorte', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.whatshot, 'critDmg'.tr(), '$critDmg%', Pallete.branco),
                      const SizedBox(height: 8),
                      _buildStatRow(Icons.whatshot, 'moveSpeed'.tr(), '$speed%', Pallete.branco),
                      
                      const Divider(color: Colors.white30, height: 20, thickness: 1),
                      
                      _buildStatRow(Icons.map, 'location'.tr(), '${'lvl'.tr()} $level - ${'room'.tr()} $room', Pallete.branco),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // -----------------------------------------
                // CARROSSEL DE ITENS ADQUIRIDOS
                // -----------------------------------------
                AcquiredItemsCarousel(items: itemsList),

                const SizedBox(height: 30),
                
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.lilas,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    game.resumeGame();
                  },
                  child: Text('continue'.tr(), style: const TextStyle(fontSize: 18, color: Pallete.branco)),
                ),
                
                const SizedBox(height: 15),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.lilas,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    game.overlays.add('SettingsMenu');
                  },
                  child: Text('settings'.tr(), style: const TextStyle(fontSize: 18, color: Pallete.branco)),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Pallete.lilas,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    game.returnToMenu();
                  },
                  child: Text('main_menu'.tr(), style: const TextStyle(fontSize: 18, color: Pallete.branco)),
                ),
                
                const SizedBox(height: 20),

                IconButton(
                  icon: const Icon(Icons.bug_report, color: Pallete.laranja, size: 30),
                  tooltip: "Menu de Debug",
                  onPressed: () {
                    game.overlays.remove('PauseMenu');
                    game.overlays.add('DebugMenu');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Pallete.branco, fontSize: 16)),
          ],
        ),
        Text(value, style: const TextStyle(color: Pallete.branco, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ============================================================================
// WIDGET DO CARROSSEL DE ITENS (Pode ficar neste mesmo arquivo)
// ============================================================================
class AcquiredItemsCarousel extends StatefulWidget {
  final List<AcquiredItemData> items;

  const AcquiredItemsCarousel({super.key, required this.items});

  @override
  State<AcquiredItemsCarousel> createState() => _AcquiredItemsCarouselState();
}

class _AcquiredItemsCarouselState extends State<AcquiredItemsCarousel> {
  int currentIndex = 0;

  void _nextItem() {
    if (currentIndex < widget.items.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _prevItem() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Nenhum item especial adquirido.",
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final item = widget.items[currentIndex];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Inventário",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                onPressed: currentIndex > 0 ? _prevItem : null,
                disabledColor: Colors.white24,
              ),
              
              // Ícone do Item
              //Icon(item.icon, size: 40, color: item.color),
              PixelSprite(
                  imagePath: 'sprites/itens/${item.icon}.png',
                  color: item.color,
                  size: 32,
                ),

              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                onPressed: currentIndex < widget.items.length - 1 ? _nextItem : null,
                disabledColor: Colors.white24,
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          Text(
            item.name,
            style: TextStyle(color: item.color, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          Text(
            item.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8),
          Text(
            "${currentIndex + 1} / ${widget.items.length}",
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}