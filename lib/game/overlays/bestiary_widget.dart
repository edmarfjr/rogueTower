import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/enemies/bestiary_data.dart';
import 'package:towerrogue/game/overlays/hud.dart';

class BestiaryWidget extends StatefulWidget {
  final List<String> unlockedEnemyIds; 
  final Map<String, int> killCounts;

  const BestiaryWidget({
    super.key, 
    required this.unlockedEnemyIds,
    required this.killCounts, // 2. REQUER NO CONSTRUTOR
  });

  @override
  State<BestiaryWidget> createState() => _BestiaryWidgetState();
}

class _BestiaryWidgetState extends State<BestiaryWidget> {
  BestiaryEntry? _selectedEnemy;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
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
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, 
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
                  // MUDANÇA AQUI: Usa a propriedade 'color' nativa da imagem!
                  child: Image.asset(
                    enemy.imagePath,
                    // Se estiver desbloqueado pinta com a cor do inimigo, senão pinta de preto puro!
                    // (Ajuste "enemy.color" para "enemy.cor" se você usou esse nome no seu arquivo)
                    scale: 0.5,
                    color: isUnlocked ? enemy.cor : Colors.black, 
                    colorBlendMode: isUnlocked ? BlendMode.modulate : BlendMode.srcIn,
                    filterQuality: FilterQuality.none, 
                  ),
                ),
              );
            },
          ),
        ),

        
      ],
    );
  }

  Widget _buildEnemyDetails() {
    final bool isUnlocked = widget.unlockedEnemyIds.contains(_selectedEnemy!.id);

    if (!isUnlocked) {
      int mortesAtuais = widget.killCounts[_selectedEnemy!.id] ?? 0;
      
      // O Truque: Se tiver 1000 ou mais de HP Base, a meta é 1 (Boss), senão é 10!
      int meta = _selectedEnemy!.baseHealth >= 1000 ? 1 : _selectedEnemy!.isChamp? 5 : 10;
      return  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PixelSprite(
                    imagePath: 'sprites/gameObjs/lock.png',
                    color: Pallete.branco,
                     size: 64
                  ),
          const SizedBox(height: 16),
          const Text(
            "CRIATURA DESCONHECIDA",
            style: TextStyle(fontFamily: 'pixelFont', color: Pallete.vermelho, fontSize: 18),
          ),
          const SizedBox(height: 16),
          const Text(
            "Derrote este monstro na masmorra para registrar suas informações.",
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'pixelFont', color: Pallete.cinzaCla),
          ),
          const SizedBox(height: 24),
          Text(
            "MORTES: $mortesAtuais / $meta",
            style: const TextStyle(
              fontFamily: 'pixelFont', 
              color: Pallete.amarelo, 
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Uma barrinha visual de carregamento!
          SizedBox(
            width: 150,
            height: 10, // Grossura da barra
            child: LinearProgressIndicator(
              value: mortesAtuais / meta, // Porcentagem de preenchimento
              backgroundColor: Pallete.cinzaEsc,
              color: Pallete.verdeCla,
            ),
          ),
        ],
      );
    }

    // Se estiver desbloqueado, mostra os dados reais COM A COR!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(
            _selectedEnemy!.imagePath, 
            scale: 0.25, 
            color: _selectedEnemy!.cor, // MUDANÇA AQUI: Pinta a foto grande também!
            colorBlendMode: isUnlocked ? BlendMode.modulate : BlendMode.srcIn,
            filterQuality: FilterQuality.none, 
                  ), 
        ),
        const SizedBox(height: 24),
        Text(
          _selectedEnemy!.name.toUpperCase(),
          style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.amarelo, fontSize: 24),
        ),
        const Divider(color: Pallete.cinzaCla),
        Text(
          _selectedEnemy!.isChamp ? '${"health".tr()}: ${_selectedEnemy!.baseHealth}x' : '${"health".tr()}: ${_selectedEnemy!.baseHealth}',
          style: const TextStyle(fontFamily: 'pixelFont', color: Colors.green),
        ),
        Text(
           _selectedEnemy!.isChamp ? '${"moveSpeed".tr()}: ${_selectedEnemy!.speed}x' : '${"moveSpeed".tr()}: ${_selectedEnemy!.speed}',
          style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.vermelho),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedEnemy!.description,
          style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.branco, fontSize: 14),
        ),
      ],
    );
  }
}