import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/tower_game.dart';

// Importe todas as suas Overlays aqui
import 'game/overlays/hud.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/pause_menu.dart';
import 'game/overlays/game_over.dart'; // <--- Import novo

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GameEntry(),
  ));
}

class GameEntry extends StatelessWidget {
  const GameEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( 
        child:GameWidget<TowerGame>(
          game: TowerGame(),
          // Mapa de Overlays limpo e profissional
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenu(game: game),
            'PauseMenu': (context, game) => PauseMenu(game: game),
            'HUD': (context, game) => Hud(game: game),
            'GameOver': (context, game) => GameOver(game: game), // <--- Uso da nova classe
          },
        ),
      )
    );
  }
}