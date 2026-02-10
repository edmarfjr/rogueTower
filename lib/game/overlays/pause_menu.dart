import 'package:flutter/material.dart';
import '../tower_game.dart';
import '../components/core/pallete.dart';

class PauseMenu extends StatelessWidget {
  final TowerGame game;

  const PauseMenu({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Fundo semi-transparente
      body: Center(
        child: Container(
          width: 300,
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
              const SizedBox(height: 40),
              
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
              const SizedBox(height: 20),

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
              const SizedBox(height: 20),
              Positioned(
              bottom: 40,
              left: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    // Ativa/Desativa o modo de debug do Flame
                    game.debugMode = !game.debugMode;
                    game.atualizaDebugMode();
                  },
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    width: 50, // Um pouco menor que o Dash
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.bug_report, // Ícone de Inseto (Bug)
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}