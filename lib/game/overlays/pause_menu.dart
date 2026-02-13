import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class PauseMenu extends StatelessWidget {
  final TowerGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Busca os valores atuais do jogo/jogador
    final int hp = game.player.healthNotifier.value;
    final int maxHp = game.player.maxHealth;
    final double dmg = game.player.damage / 10 * 100;
    final double fireRate = 0.4 / game.player.fireRate  * 100;
    final double range = game.player.attackRange / 200 * 100;
    final double critChance = game.player.critChance / 5 * 100;
    final double critDmg = game.player.critDamage / 2 * 100;
    final double speed = game.player.moveSpeed / 150 * 100;
    final int level = game.currentLevel;
    final int room = game.currentRoom;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Fundo semi-transparente
      body: Center(
        child: Container(
          width: 320, // Aumentei um pouquinho a largura para acomodar bem os textos
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallete.azulEsc,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pallete.branco, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSADO',
                style: TextStyle(
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
                  color: Colors.black.withOpacity(0.3), // Fundo mais escuro para destacar
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildStatRow(Icons.favorite, 'Vida: ', '$hp / $maxHp', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(MdiIcons.sword, 'Dano: ', '$dmg%', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(MdiIcons.sword, 'Taxa de tiro: ', '$fireRate%', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.whatshot, 'Alcance: ', '$range%', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.whatshot, 'Chance Crit.: ', '$critChance%', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.whatshot, 'Dano Crit.: ', '$critDmg%', Pallete.branco),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.whatshot, 'Velocidade: ', '$speed%', Pallete.branco),
                    
                    const Divider(color: Colors.white30, height: 20, thickness: 1),
                    
                    _buildStatRow(Icons.map, 'Local', 'Nvl $level - Sala $room', Pallete.branco),
                  ],
                ),
              ),
              // -----------------------------------------
              
              const SizedBox(height: 30),
              
              // Botão Continuar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.verdeCla,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  game.resumeGame();
                },
                child: const Text('Continuar', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
              const SizedBox(height: 15),

              // Botão Sair
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.vermelho,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  game.returnToMenu();
                },
                child: const Text('Menu Principal', style: TextStyle(fontSize: 18, color: Pallete.branco)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Método auxiliar para criar as linhas de status uniformemente
  Widget _buildStatRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            //Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label, 
              style: const TextStyle(color: Pallete.branco, fontSize: 16)
            ),
          ],
        ),
        Text(
          value, 
          style: const TextStyle(color: Pallete.branco, fontSize: 16, fontWeight: FontWeight.bold)
        ),
      ],
    );
  }
}