import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/enemies/bestiary_data.dart';

class BestiaryWidget extends StatefulWidget {
  // Lista de IDs de monstros que o jogador já derrotou (vem do seu save game)
  final List<String> unlockedEnemyIds; 

  const BestiaryWidget({super.key, required this.unlockedEnemyIds});

  @override
  State<BestiaryWidget> createState() => _BestiaryWidgetState();
}

class _BestiaryWidgetState extends State<BestiaryWidget> {
  BestiaryEntry? _selectedEnemy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LADO ESQUERDO: A Grade de Monstros
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 ícones por linha
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: fullBestiary.length,
            itemBuilder: (context, index) {
              final enemy = fullBestiary[index];
              final isUnlocked = widget.unlockedEnemyIds.contains(enemy.id);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedEnemy = enemy;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Pallete.cinzaEsc,
                    border: Border.all(
                      color: _selectedEnemy == enemy ? Pallete.amarelo : Pallete.cinzaCla,
                      width: 2,
                    ),
                  ),
                  child: isUnlocked 
                      // Desenha o monstro normal
                      ? Image.asset(enemy.imagePath) 
                      // O SEGREDO DA SILHUETA: Pinta o monstro de preto!
                      : ColorFiltered(
                          colorFilter: const ColorFilter.mode(
                            Colors.black, 
                            BlendMode.srcIn,
                          ),
                          child: Image.asset(enemy.imagePath),
                        ),
                ),
              );
            },
          ),
        ),

        // LADO DIREITO: Detalhes do Monstro Selecionado
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(16),
            child: _selectedEnemy == null
                ? const Center(
                    child: Text(
                      "Selecione uma criatura",
                      style: TextStyle(fontFamily: 'pixelFont', color: Colors.white),
                    ),
                  )
                : _buildEnemyDetails(),
          ),
        ),
      ],
    );
  }

  Widget _buildEnemyDetails() {
    final bool isUnlocked = widget.unlockedEnemyIds.contains(_selectedEnemy!.id);

    if (!isUnlocked) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Pallete.cinzaCla),
          const SizedBox(height: 16),
          const Text(
            "CRIATURA DESCONHECIDA",
            style: TextStyle(fontFamily: 'pixelFont', color: Pallete.vermelho, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            "Derrote este monstro na masmorra para registrar suas informações.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'pixelFont', color: Colors.white70),
          ),
        ],
      );
    }

    // Se estiver desbloqueado, mostra os dados reais!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(_selectedEnemy!.imagePath, scale: 0.5), // Foto Maior
        ),
        const SizedBox(height: 24),
        Text(
          _selectedEnemy!.name.toUpperCase(),
          style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.amarelo, fontSize: 24),
        ),
        const Divider(color: Pallete.cinzaCla),
        Text(
          "HP Base: ${_selectedEnemy!.baseHealth}",
          style: const TextStyle(fontFamily: 'pixelFont', color: Colors.green),
        ),
        Text(
          "Dano: ${_selectedEnemy!.baseDamage}",
          style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.vermelho),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedEnemy!.description,
          style: const TextStyle(fontFamily: 'pixelFont', color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}