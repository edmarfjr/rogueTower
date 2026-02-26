import 'package:TowerRogue/game/components/gameObj/arena_border.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    // Inicia os sliders com a posição atual do jogador
    // Substitua 'currentLevel' pela variável real do seu jogo, se for diferente
    _selectedRoom = widget.game.currentRoomNotifier.value;
    _selectedLevel = 1; // Se você tiver um levelNotifier, puxe o valor dele aqui
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
            color: Pallete.cinzaEsc,
            border: Border.all(color: Colors.redAccent, width: 3), // Borda vermelha pra lembrar que é debug
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "DEBUG: SELETOR DE FASE",
                style: TextStyle(color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // --- SLIDER DE NÍVEL (ANDAR) ---
              Text("Nível Selecionado: $_selectedLevel", style: const TextStyle(color: Colors.white, fontSize: 16)),
              Slider(
                value: _selectedLevel.toDouble(),
                min: 1,
                max: widget.game.numLevels.toDouble(), // Máximo de níveis do seu jogo
                divisions: 9,
                activeColor: Pallete.azulCla,
                onChanged: (val) {
                  setState(() { _selectedLevel = val.toInt(); });
                },
              ),

              const Divider(color: Colors.white30),

              // --- SLIDER DE SALA ---
              Text("Sala Selecionada: $_selectedRoom", style: const TextStyle(color: Colors.white, fontSize: 16)),
              Slider(
                value: _selectedRoom.toDouble(),
                min: 0,
                max: widget.game.bossRoom.toDouble(), // Vai até a sala do boss
                divisions: widget.game.bossRoom - 1,
                activeColor: Pallete.verdeCla,
                onChanged: (val) {
                  setState(() { _selectedRoom = val.toInt(); });
                },
              ),

              const SizedBox(height: 30),

              // --- BOTÃO DE TELEPORTE ---
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.flash_on, color: Colors.white),
                label: const Text("TELEPORTAR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: () {
                  _teleportPlayer();
                },
              ),

              const SizedBox(height: 10),

              // Botão Fechar
              TextButton(
                onPressed: () {
                  widget.game.overlays.remove('DebugMenu');
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
      widget.game.currentRoomNotifier.value = _selectedRoom;
      widget.game.currentLevelNotifier.value = _selectedLevel; 
      
      final coisasParaApagar = widget.game.world.children.where((component) {
        return component.runtimeType.toString() == 'Enemy' ||
                component.runtimeType.toString() == 'Door' ||
                component.runtimeType.toString() == 'Collectible' ||
                component.runtimeType.toString() == 'Projectile' ||
                component.runtimeType.toString() == 'UnlockableItem' ||
                component.runtimeType.toString() == 'LaserBeam';
                
      });
      
      widget.game.world.removeAll(coisasParaApagar);

     /* await widget.game.world.add(ArenaBorder(
        size: Vector2(TowerGame.gameWidth, TowerGame.gameHeight),
        wallThickness: 54, 
        radius: 40,       
      ));
      */widget.game.overlays.add('HUD');

      widget.game.roomManager.startRoom(_selectedRoom);

      widget.game.player.position = Vector2(0, 250); 
    });
  }
}