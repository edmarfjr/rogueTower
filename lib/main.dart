import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/tower_game.dart';

import 'game/overlays/hud.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/pause_menu.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/victory_menu.dart';

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
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenu(game: game),
            'PauseMenu': (context, game) => PauseMenu(game: game),
            'HUD': (context, game) => Hud(game: game),
            'GameOver': (context, game) => GameOver(game: game), 
            'VictoryMenu': (context, game) => VictoryMenu(game: game), 
          },
        ),
      )
    );
  }
}