import 'package:towerrogue/game/overlays/bank_menu.dart';
import 'package:towerrogue/game/overlays/diary_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:towerrogue/game/overlays/character_selection_menu.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game/tower_game.dart';
import 'game/overlays/hud.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/pause_menu.dart';
import 'game/overlays/game_over.dart';
import 'game/overlays/victory_menu.dart';
import 'game/overlays/settings_menu.dart';
import 'game/overlays/debug_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  
 // await AudioManager.init();

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
      body: GameWidget<TowerGame>(
          game: TowerGame(),
          overlayBuilderMap: {
            'MainMenu': (context, game) => MainMenu(game: game),
            'PauseMenu': (context, game) => PauseMenu(game: game),
            'HUD': (context, game) => Hud(game: game),
            'GameOver': (context, game) => GameOver(game: game), 
            'VictoryMenu': (context, game) => VictoryMenu(game: game),
            'SettingsMenu': (context, game) => SettingsMenu(game: game), 
            'DebugMenu': (context, game) => DebugMenu(game: game), 
            'CharacterSelectionMenu': (context, game) => CharacterSelectionMenu(game: game), 
            'DiaryScreen': (context, game) => DiaryScreen(game: game), 
            'bank_menu': (context, game) => BankMenu(game: game), 
          },
      )
    );
  }
}