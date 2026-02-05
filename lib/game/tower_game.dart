import 'dart:async';
import 'dart:io';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flame/experimental.dart'; // Garante que Rectangle venha daqui

import 'package:tower/game/components/player.dart';
import 'package:tower/game/components/enemies/enemy.dart';
import 'package:tower/game/components/door.dart';
import 'package:tower/game/components/room_manager.dart';
import 'package:tower/game/components/projectile.dart';
import 'components/collectible.dart';
import 'components/pallete.dart';
import 'components/wall.dart';
import 'components/arena_border.dart';

class TowerGame extends FlameGame with HasCollisionDetection, HasKeyboardHandlerComponents {
  
  late final Player player;
  late final JoystickComponent joystick;
  late final RoomManager roomManager;
  
  int currentRoom = 1;
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  CollectibleType nextRoomReward = CollectibleType.coin;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {
    // 1. CONFIGURA O VIEWPORT (Tamanho da "Janela")
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    // --- CONFIGURAÇÃO DA ARENA ---
    const double gameWidth = 400;
    const double gameHeight = 700;

    // Adiciona as Paredes Visuais
    await world.add(ArenaBorder(
      size: Vector2(gameWidth, gameHeight),
      wallThickness: 64, 
      radius: 20,       
    ));
    // ----------------------------

    // 2. CONFIGURA OS LIMITES DA CÂMERA (CORRIGIDO)
    // O limite deve ser do tamanho da ARENA (400x700), não do viewport.
    camera.setBounds(
      Rectangle.fromCenter(
        center: Vector2.zero(),
        size: Vector2(gameWidth, gameHeight), // <--- USE AS VARIÁVEIS DA ARENA AQUI
      ),
      considerViewport: true, // A câmera vai parar exatamente quando a borda da tela tocar a borda da arena
    );

    roomManager = RoomManager();
    world.add(roomManager);

    player = Player();
    world.add(ScreenHitbox()); // Nota: O ScreenHitbox pega o tamanho do Viewport, não da Arena. 
                               // Se quiser colisão na arena toda, talvez precise ajustar isso depois.
    world.add(player);
    
    camera.follow(player);

    // Joystick (Mobile)
    bool isMobile = false;
    try {
      if (Platform.isAndroid || Platform.isIOS) isMobile = true;
    } catch (e) {}

    if (isMobile) {
      joystick = JoystickComponent(
        knob: CircleComponent(radius: 10, paint: Paint()..color = Pallete.colorDarkest),
        background: CircleComponent(radius: 30, paint: Paint()..color = Pallete.colorLight.withOpacity(0.5)),
        margin: const EdgeInsets.only(left: 40, bottom: 40),
      );
      camera.viewport.add(joystick);

      final dashButton = HudButtonComponent(
        button: CircleComponent(radius: 25, paint: Paint()..color = Pallete.colorLight.withOpacity(0.5)),
        buttonDown: CircleComponent(radius: 25, paint: Paint()..color = Pallete.colorDarkest),
        margin: const EdgeInsets.only(right: 40, bottom: 40),
        onPressed: () {
          player.startDash();
        },
      );
      camera.viewport.add(dashButton);
    }
  }

  @override
  void onMount() {
    super.onMount();
    overlays.add('MainMenu');
    //startLevel(); 
    //overlays.add('HUD'); 
  }
  void startGame() {
    // 1. Limpa overlays
    overlays.remove('MainMenu');
    overlays.add('HUD');

    // 2. Garante que o jogo está rodando
    resumeEngine();

    // 3. Reinicia variáveis e cria o player
    resetGame();
  }

  void pauseGame() {
    pauseEngine(); // Congela o Flame
    overlays.remove('HUD'); // Opcional: esconde o HUD para limpar a tela
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    overlays.add('HUD');
    resumeEngine(); // Descongela
  }

  void returnToMenu() {
    // Limpa tudo para não ficar lixo na memória
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('HUD');
    
    // Volta para o menu
    overlays.add('MainMenu');
    
    // Limpa o mundo visualmente (opcional, mas bom pra não ver o jogo congelado no fundo do menu)
    // world.removeAll(world.children); 
    // Mas cuidado para não remover o RoomManager se ele for fixo. 
    // O ideal é chamar um método de limpeza.
    
    // Pausa engine para economizar bateria no menu
    // (Opcional, se o menu for totalmente opaco)
    // pauseEngine(); 
  }

  void startLevel() {
    print("Iniciando Sala $currentRoom");
    player.position = Vector2(0, 250); 
    roomManager.startRoom(currentRoom);
  }

  void nextLevel(CollectibleType chosenReward) {
    currentRoom++;
    nextRoomReward = chosenReward;

    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    
    startLevel();
  }

  void onGameOver() {
    pauseEngine(); 
    overlays.add('GameOver'); 
  }

  void resetGame() {
    overlays.remove('GameOver');
    resumeEngine();

    currentRoom = 4;
    coinsNotifier.value = 0;
    keysNotifier.value = 0;

    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());

    player.reset();
    
    // IMPORTANTE: Recalibrar a câmera para seguir o player
    camera.follow(player);

    startLevel();
  }
}