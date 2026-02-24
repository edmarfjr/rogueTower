import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/character_class.dart';
import '../components/core/pallete.dart';

class CharacterSelectionMenu extends StatefulWidget {
  final TowerGame game;
  const CharacterSelectionMenu({super.key, required this.game});

  @override
  State<CharacterSelectionMenu> createState() => _CharacterSelectionMenuState();
}

class _CharacterSelectionMenuState extends State<CharacterSelectionMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final charClass = CharacterRoster.classes[_selectedIndex];

    return Material(
      color: Colors.black87, // Fundo semi-transparente
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Fundo da caixa
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: charClass.color, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ESCOLHA SUA CLASSE",
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              
              // O Ícone Gigante da Classe
              Icon(charClass.icon, size: 100, color: charClass.color),
              const SizedBox(height: 10),
              
              // Nome da Classe
              Text(
                charClass.name,
                style: TextStyle(color: charClass.color, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
              
              // Descrição
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  charClass.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),

              // Status Rápidos
              Text("HP: ${charClass.maxHp} | Dano: ${charClass.damage} | Crítico: ${charClass.critChance}%",
                  style: const TextStyle(color: Colors.white, fontSize: 18)),

              const Spacer(),

              // Botões de Navegação e Confirmar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Seta para a Esquerda
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                    onPressed: () {
                      setState(() {
                        if (_selectedIndex > 0) _selectedIndex--;
                      });
                    },
                  ),
                  
                  // Botão de COMEÇAR JOGO
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: charClass.color,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () {
                      // CHAMA A FUNÇÃO QUE ALTERAMOS NO PASSO 3!
                      widget.game.selectedClass = charClass;
                      widget.game.startGame(charClass);
                      widget.game.overlays.remove('CharacterSelectionMenu');
                    },
                    child: const Text("INICIAR", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),

                  // Seta para a Direita
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                    onPressed: () {
                      setState(() {
                        if (_selectedIndex < CharacterRoster.classes.length - 1) _selectedIndex++;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),
              
              // Botão Fechar
              TextButton(
                onPressed: () => widget.game.overlays.remove('CharacterSelectionMenu'),
                child: const Text("VOLTAR", style: TextStyle(color: Colors.grey)),
              )
            ],
          ),
        ),
      ),
    );
  }
}