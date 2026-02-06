import 'dart:async';
import 'dart:io';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/input.dart';
import 'package:flame/experimental.dart'; // Garante que Rectangle venha daqui
import 'package:tower/game/components/chest.dart';

import 'package:tower/game/components/player.dart';
import 'package:tower/game/components/enemies/enemy.dart';
import 'package:tower/game/components/door.dart';
import 'package:tower/game/components/room_manager.dart';
import 'package:tower/game/components/projectile.dart';
import 'components/collectible.dart';
import 'components/pallete.dart';
import 'components/wall.dart';
import 'components/arena_border.dart';

class TowerGame extends FlameGame with PanDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  
  late final Player player;
  late JoystickComponent joystick;
  final double _joystickRadius = 60.0;
  late final RoomManager roomManager;
  
  int currentRoom = 1;
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  CollectibleType nextRoomReward = CollectibleType.coin;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {
    //debugMode = true;
    // 1. CONFIGURA O VIEWPORT (Tamanho da "Janela")
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    final knobPaint = Paint()..color = Colors.white.withOpacity(0.8);
    final backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.3);

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: knobPaint),
      background: CircleComponent(radius: _joystickRadius, paint: backgroundPaint),
      // Definimos prioridade alta para ficar em cima de tudo
      priority: 100, 
    );

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

    player = Player(position: Vector2(0, 0));
    world.add(ScreenHitbox()); // Nota: O ScreenHitbox pega o tamanho do Viewport, não da Arena. 
                               // Se quiser colisão na arena toda, talvez precise ajustar isso depois.
    world.add(player);
    
    camera.follow(player);


  }

  @override
  void onPanStart(DragStartInfo info) {
    // Quando o dedo toca na tela:
    
    // 1. Move a base do joystick para onde o dedo tocou (Coordenada da Tela/Widget)
    joystick.position = info.eventPosition.widget;
    
    // 2. Adiciona o joystick ao jogo (se ele não estiver lá)
    if (!joystick.isMounted) {
      camera.viewport.add(joystick); 
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // A matemática continua a mesma, pois widget position é relativo a tela
    final localDelta = info.eventPosition.widget - joystick.position;
    
    if (localDelta.length > _joystickRadius) {
      joystick.knob!.position = localDelta.normalized() * _joystickRadius;
    } else {
      joystick.knob!.position = localDelta;
    }
  }

  @override
  void onPanEnd(DragEndInfo info) {
    // Quando solta o dedo:
    _resetJoystick();
  }

  @override
  void onPanCancel() {
    // Se o toque for cancelado (saiu da tela, entrou ligação, etc)
    _resetJoystick();
  }

  void _resetJoystick() {
    // CORREÇÃO: Remove do pai atual (que agora é o viewport)
    if (joystick.isMounted) {
      joystick.removeFromParent();
    }
    joystick.knob!.position = Vector2.zero();
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
    world.children.query<Chest>().forEach((w) => w.removeFromParent());
    
    startLevel();
  }

  void onGameOver() {
    pauseEngine(); 
    overlays.add('GameOver'); 
  }

  void resetGame() {
    overlays.remove('GameOver');
    resumeEngine();

    currentRoom = 1;
    coinsNotifier.value = 0;
    keysNotifier.value = 0;

    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((w) => w.removeFromParent());

    player.reset();
    
    // IMPORTANTE: Recalibrar a câmera para seguir o player
    camera.follow(player);

    startLevel();
  }
}