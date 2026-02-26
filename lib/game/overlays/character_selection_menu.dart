import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:TowerRogue/game/components/core/game_progress.dart';
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
  bool _isCurrentClassUnlocked = true;

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus(); // Checa o primeiro personagem ao abrir a tela
  }

  // Função que lê o save
  void _checkUnlockStatus() async {
    final charClass = CharacterRoster.classes[_selectedIndex];
    bool unlocked = await GameProgress.isClassUnlocked(charClass);
    setState(() {
      _isCurrentClassUnlocked = unlocked;
    });
  }

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
              Stack(
                alignment: Alignment.center,
                children: [
                  // O ícone da classe (Fica cinza se estiver bloqueado!)
                  Icon(
                    charClass.icon, 
                    size: 100, 
                    color: _isCurrentClassUnlocked ? charClass.color : Colors.white24
                  ),
                  
                  // O Cadeado gigante em cima
                  if (!_isCurrentClassUnlocked)
                    const Icon(Icons.lock, size: 60, color: Colors.white),
                ],
              ),
              
              const SizedBox(height: 10),
              Text(
                _isCurrentClassUnlocked ? charClass.name : "???",
                style: TextStyle(
                  color: _isCurrentClassUnlocked ? charClass.color : Colors.grey, 
                  fontSize: 32, 
                  letterSpacing: 2
                ),
              ),
              
              // Mostra a descrição normal se liberado, ou a Dica se bloqueado
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  _isCurrentClassUnlocked ? charClass.description : charClass.unlockConditionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCurrentClassUnlocked ? Colors.white70 : Colors.redAccent, 
                    fontSize: 16,
                    fontWeight: _isCurrentClassUnlocked ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),

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
                        if (_selectedIndex > 0){
                          _selectedIndex--;
                        } else {
                          _selectedIndex = CharacterRoster.classes.length - 1;
                        }
                        _checkUnlockStatus();
                      });
                    },
                  ),
                  
                  // Botão de COMEÇAR JOGO
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCurrentClassUnlocked ? charClass.color : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isCurrentClassUnlocked ? () {
                      // CHAMA A FUNÇÃO QUE ALTERAMOS NO PASSO 3!
                      widget.game.selectedClass = charClass;
                      widget.game.startGame(charClass);
                      widget.game.overlays.remove('CharacterSelectionMenu');
                    } : null,
                    child: Text( _isCurrentClassUnlocked ? "INICIAR" : "BLOQUEADO", style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),

                  // Seta para a Direita
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                    onPressed: () {
                      setState(() {
                        if (_selectedIndex < CharacterRoster.classes.length - 1){
                          _selectedIndex++;
                        } else {
                          _selectedIndex = 0;
                        }_checkUnlockStatus();
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