import 'dart:async';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import '../tower_game.dart';

class DialogOverlay extends StatefulWidget {
  final TowerGame game;
  const DialogOverlay({super.key, required this.game});

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  int _currentIndex = 0;
  String _currentText = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTypewriter(); // Começa a digitar a primeira frase
  }

  void _startTypewriter() {
    _timer?.cancel(); // Cancela o timer anterior se houver
    _currentText = "";
    
    // Pega a frase inteira atual
    String fullText = widget.game.activeDialogs[_currentIndex];
    int charIndex = 0;

    // Adiciona uma letra a cada 30 milissegundos
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _currentText += fullText[charIndex];
        });
        charIndex++;
      } else {
        timer.cancel(); // Terminou de escrever
      }
    });
  }

  // Função para avançar o papo
  void _nextDialog() {
    String fullText = widget.game.activeDialogs[_currentIndex];
    
    // Se o texto ainda está digitando, clicar pula a animação e mostra tudo
    if (_currentText.length < fullText.length) {
      _timer?.cancel();
      setState(() {
        _currentText = fullText;
      });
      return;
    }

    // Se já terminou de digitar, vai para a próxima frase
    if (_currentIndex < widget.game.activeDialogs.length - 1) {
      _currentIndex++;
      _startTypewriter();
    } else {
      // Se era a última frase, fecha tudo!
      _closeDialog();
    }
  }

  void _closeDialog() {
    widget.game.overlays.remove('DialogOverlay');
    widget.game.activeDialogs.clear();
    
    // Quando fechar o diálogo, força o botão de interação a voltar,
    // pois o jogador ainda está parado na frente do NPC!
    widget.game.canInteractNotifier.value = true;
    
    widget.game.resumeEngine(); // Despausa o jogo
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GestureDetector captura cliques na tela inteira
    return GestureDetector(
      onTap: _nextDialog, 
      child: Container(
        color: Colors.transparent, // Impede clicar nas coisas do jogo atrás
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
            child: Container(
              height: 120, // Altura fixa da caixa
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pallete.preto.withOpacity(0.85), // Fundo escuro
                border: Border.all(color: Pallete.branco, width: 2), // Borda pixel
                borderRadius: BorderRadius.zero,
              ),
              child: Stack(
                children: [
                  // O TEXTO DIGITADO
                  Text(
                    _currentText,
                    style: const TextStyle(
                      fontFamily: 'pixelFont',
                      fontSize: 18,
                      color: Colors.white,
                      height: 1.5, // Espaçamento entre linhas
                      decoration: TextDecoration.none,
                    ),
                  ),
                  
                  // A SETINHA PISCANDO NO CANTO (Indica para clicar)
                  if (_currentText.length == widget.game.activeDialogs[_currentIndex].length)
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "▼", 
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}