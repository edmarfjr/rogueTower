import 'package:towerrogue/game/components/core/character_class.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
// import '../components/core/pallete.dart'; // Se for necessário no futuro

class CharacterSelectionMenu extends StatefulWidget {
  final TowerGame game;
  
  const CharacterSelectionMenu({super.key, required this.game});

  @override
  State<CharacterSelectionMenu> createState() => _CharacterSelectionMenuState();
}

class _CharacterSelectionMenuState extends State<CharacterSelectionMenu> {
  int _selectedIndex = 0;
  bool _isCurrentClassUnlocked = true;
  
  // --- VARIÁVEL DA DIFICULDADE ---
  double _selectedDifficulty = 1.0; // Começa no "Normal"

  @override
  void initState() {
    super.initState();
    _checkUnlockStatus();
  }

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
      color: Colors.black87,
      child: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.8, // Aumentei um pouquinho para caber a dificuldade
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: charClass.color, width: 3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "ESCOLHA SUA CLASSE",
                style: TextStyle(color: Pallete.branco, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    charClass.icon, 
                    size: 100, 
                    color: _isCurrentClassUnlocked ? charClass.color : Pallete.cinzaEsc
                  ),
                  if (!_isCurrentClassUnlocked)
                    const Icon(Icons.lock, size: 60, color: Pallete.branco),
                ],
              ),
              
              const SizedBox(height: 10),
              Text(
                _isCurrentClassUnlocked ? charClass.name : "???",
                style: TextStyle(
                  color: _isCurrentClassUnlocked ? charClass.color : Pallete.cinzaCla, 
                  fontSize: 32, 
                  letterSpacing: 2
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  _isCurrentClassUnlocked ? charClass.description : charClass.unlockConditionText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isCurrentClassUnlocked ? Pallete.cinzaCla : Pallete.vermelho, 
                    fontSize: 16,
                    fontWeight: _isCurrentClassUnlocked ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),
              const Spacer(),

              // --- SELETOR DE DIFICULDADE AQUI ---
              const Text("DIFICULDADE", style: TextStyle(color: Pallete.branco, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              // Envolvi num Wrap (ou SingleChildScrollView) caso a tela do telemóvel seja muito pequena
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildDifficultyButton("facil".tr(), 1.0, Pallete.verdeCla),
                  _buildDifficultyButton("normal".tr(), 1.5, Pallete.azulCla),
                  _buildDifficultyButton("dificil".tr(), 2.0, Pallete.laranja),
                  _buildDifficultyButton("pesadelo".tr(), 3.0, Pallete.vermelho),
                ],
              ),
              
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Pallete.branco, size: 30),
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
                  
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCurrentClassUnlocked ? charClass.color : Pallete.cinzaCla,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: _isCurrentClassUnlocked ? () {
                      
                      // 1. INJETA A DIFICULDADE NO JOGO
                      widget.game.difficultyMultiplier = _selectedDifficulty;
                      
                      // 2. INICIA O JOGO NORMALMENTE
                      widget.game.selectedClass = charClass;
                      widget.game.startGame(charClass);
                      widget.game.overlays.remove('CharacterSelectionMenu');
                      
                    } : null,
                    child: Text( _isCurrentClassUnlocked ? "INICIAR" : "BLOQUEADO", style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, color: Pallete.branco, size: 30),
                    onPressed: () {
                      setState(() {
                        if (_selectedIndex < CharacterRoster.classes.length - 1){
                          _selectedIndex++;
                        } else {
                          _selectedIndex = 0;
                        }
                        _checkUnlockStatus();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              TextButton(
                onPressed: () => widget.game.overlays.remove('CharacterSelectionMenu'),
                child: const Text("VOLTAR", style: TextStyle(color: Pallete.cinzaCla)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNÇÃO AUXILIAR PARA CRIAR OS BOTÕES DE DIFICULDADE ---
  Widget _buildDifficultyButton(String label, double multiplier, Color color) {
    bool isSelected = _selectedDifficulty == multiplier;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedDifficulty = multiplier;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFF2C2C2C), // Fundo mais escuro se não selecionado
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Pallete.branco : Colors.transparent, 
            width: 2
          ),
        ),
        child: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Pallete.branco : Pallete.cinzaCla,
            fontWeight: FontWeight.bold,
            fontSize: 12
          )
        ),
      ),
    );
  }
}