import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class DebugMenu extends StatefulWidget {
  final TowerGame game;

  const DebugMenu({super.key, required this.game});

  @override
  State<DebugMenu> createState() => _DebugMenuState();
}

class _DebugMenuState extends State<DebugMenu> {
  // Variáveis temporárias do menu
  int _selectedLevel = 1;
  int _selectedRoom = 1;
  bool _isGodMode = false;

  @override
  void initState() {
    super.initState();
    // Inicia os sliders com a posição atual do jogador
    // Substitua 'currentLevel' pela variável real do seu jogo, se for diferente
    _selectedRoom = widget.game.currentRoomNotifier.value;
    _selectedLevel = 1; // Se você tiver um levelNotifier, puxe o valor dele aqui
    _isGodMode = widget.game.isGodMode; // Puxa o estado atual do God Mode
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pallete.preto,
            border: Border.all(color: Pallete.branco, width: 3), // Borda vermelha pra lembrar que é debug
            borderRadius: BorderRadius.zero,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "DEBUG: SELETOR DE FASE",
                style: TextStyle(color: Pallete.branco, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- SLIDER DE NÍVEL (ANDAR) ---
              Text("Nível Selecionado: $_selectedLevel", style: const TextStyle(color: Colors.white, fontSize: 16)),
              Slider(
                value: _selectedLevel.toDouble(),
                min: 1,
                max: widget.game.numLevels.toDouble(), // Máximo de níveis do seu jogo
                divisions: widget.game.numLevels,
                activeColor: Pallete.branco,
                onChanged: (val) {
                  setState(() { _selectedLevel = val.toInt(); });
                },
              ),

              const Divider(color: Colors.white),

              // --- SLIDER DE SALA ---
              Text("Sala Selecionada: $_selectedRoom", style: const TextStyle(color: Colors.white, fontSize: 16)),
              Slider(
                value: _selectedRoom.toDouble(),
                min: 0,
                max: widget.game.bossRoom.toDouble(), 
                divisions: widget.game.bossRoom,
                activeColor: Colors.white,
                onChanged: (val) {
                  setState(() { _selectedRoom = val.toInt(); });
                },
              ),

              const SizedBox(height: 30),

              // --- BOTÃO DE TELEPORTE ---
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Pallete.preto,
                  minimumSize: const Size(double.infinity, 50),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
                label: const Text("TELEPORTAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  _teleportPlayer();
                },
              ),

              const SizedBox(height: 10),

              CheckboxListTile(
                    title: const Text('God Mode', style: TextStyle(color: Colors.white, fontSize: 18)),
                    value: _isGodMode,
                    activeColor: Pallete.vermelho,
                    checkColor: Pallete.branco,
                    side: const BorderSide(color: Pallete.cinzaCla, width: 1),
                    onChanged: (bool? value) {
                      setState(() {
                        _isGodMode = value ?? false;
                        widget.game.isGodMode = _isGodMode;
                      });
                    },
                  ),

              // Botão Fechar
              TextButton(
                onPressed: () {
                  widget.game.overlays.remove('DebugMenu');
                  widget.game.resumeGame();
                },
                child: const Text("FECHAR DEBUG", style: TextStyle(color: Colors.white54)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _teleportPlayer() {
    widget.game.overlays.remove('DebugMenu');
    widget.game.resumeEngine(); 

    widget.game.transitionEffect.startTransition(() async {   
      
      // DEIXA O FLAME CUIDAR DO RESTO!
      widget.game.forceTeleportToRoom(_selectedRoom, _selectedLevel);
      
      widget.game.overlays.add('HUD');
    });
  }
}