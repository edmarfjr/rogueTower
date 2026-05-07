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
    required this.killCounts, 
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
        const SizedBox(height: 16),
        // ==========================================
        // PAINEL DE DETALHES (TOPO)
        // ==========================================
        Expanded(
          flex: 2,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.935,
            decoration: BoxDecoration(
                    color: Pallete.preto,
                    border: Border.all(
                      color:Pallete.cinzaCla,
                      width: 2,
                    ),
                  ),
            padding: const EdgeInsets.all(16),
            child: _selectedEnemy == null
                ?  Center(
                    child: Text(
                      "selec_criat".tr(),
                      style:const TextStyle(fontFamily: 'pixelFont', color: Colors.white, fontSize: 18),
                    ),
                  )
                : _buildEnemyDetails(),
          ),
        ),
        
        // ==========================================
        // GRADE DE MONSTROS (BASE)
        // ==========================================
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
                    color: Pallete.preto,
                    border: Border.all(
                      color: _selectedEnemy == enemy ? Pallete.amarelo : Pallete.cinzaCla,
                      width: 2,
                    ),
                  ),
                  // MUDANÇA: Stack com a Aura e o Inimigo!
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // --- AURA NO GRID ---
                      if (enemy.isChamp && isUnlocked)
                        Container(
                          width: 24, 
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _selectedEnemy!.cor.withOpacity(0.4),
                                blurRadius: 15,  
                                spreadRadius: 5, 
                              ),
                            ],
                          ),
                        ),
                        
                      // --- FOTO NO GRID ---
                      Image.asset(
                        enemy.imagePath,
                        scale: 0.5,
                        color: isUnlocked ? enemy.cor : Pallete.cinzaEsc, 
                        colorBlendMode: isUnlocked ? BlendMode.modulate : BlendMode.srcIn,
                        filterQuality: FilterQuality.none, 
                      ),
                    ],
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
           Text(
            "criat_desco".tr(),
            style: const TextStyle(fontFamily: 'pixelFont', color: Pallete.vermelho, fontSize: 18),
          ),
          const SizedBox(height: 24),
          Text(
            "${'mortes'.tr()}: $mortesAtuais / $meta",
            style: const TextStyle(
              fontFamily: 'pixelFont', 
              color: Pallete.amarelo, 
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 150,
            height: 10, 
            child: LinearProgressIndicator(
              value: mortesAtuais / meta, 
              backgroundColor: Pallete.cinzaEsc,
              color: Pallete.verdeCla,
            ),
          ),
        ],
      );
    }

    // Se estiver desbloqueado, mostra os dados reais COM A COR E AURA!
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          // MUDANÇA: Stack com a Aura Gigante
          child: Stack(
            alignment: Alignment.center,
            children: [
              // --- AURA NOS DETALHES ---
              if (_selectedEnemy!.isChamp)
                Container(
                  width: 80, // Aumentado para acompanhar o scale: 0.25 da imagem
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _selectedEnemy!.cor.withOpacity(0.3), 
                        blurRadius: 16,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
                
              // --- FOTO EM DESTAQUE ---
              Image.asset(
                _selectedEnemy!.imagePath, 
                scale: 0.25, 
                color: _selectedEnemy!.cor, 
                colorBlendMode: isUnlocked ? BlendMode.modulate : BlendMode.srcIn,
                filterQuality: FilterQuality.none, 
              ),
            ],
          ), 
        ),
       // const SizedBox(height: 24),
        Text(
          // Adiciona a estrela no título se for um campeão
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