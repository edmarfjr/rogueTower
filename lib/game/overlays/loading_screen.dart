import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/core/pallete.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Material(
      color: Pallete.preto, // Fundo escuro
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Se você tiver um logo do jogo, pode colocar um Image.asset aqui!
            
             const CircularProgressIndicator(
              color: Pallete.branco, // Cor da rodinha carregando
            ),
            const SizedBox(height: 24),
            Text(
              "loading".tr(),
              style: const TextStyle(
                fontFamily: 'pixelFont', // Use a sua fonte pixelada
                color: Pallete.branco,
                fontSize: 24,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}