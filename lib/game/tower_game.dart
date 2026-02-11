import 'dart:async';

import 'package:TowerRogue/game/components/core/screen_transition.dart';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart'; // Para Rectangle
import 'package:flutter/material.dart';
import 'package:flame/camera.dart'; 

import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/door.dart';
import 'package:TowerRogue/game/components/core/room_manager.dart';
import 'package:TowerRogue/game/components/projectiles/projectile.dart';
import 'package:TowerRogue/game/components/gameObj/chest.dart';
import 'components/gameObj/collectible.dart';
import 'components/core/pallete.dart';
import 'components/gameObj/wall.dart';
import 'components/core/arena_border.dart';
import 'components/core/game_progress.dart';
import 'overlays/bank_menu.dart';

class TowerGame extends FlameGame with PanDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double arenaWidth = 360.0;  // Largura total (Esquerda <-> Direita)
  static const double arenaHeight = 660.0; // Altura total (Cima <-> Baixo)
  late final Player player;
  late final RoomManager roomManager;
  
  // --- SISTEMA DE JOYSTICK MANUAL ---
  // Em vez de usar JoystickComponent, usamos 2 círculos simples
  late CircleComponent joystickBase;
  late CircleComponent joystickKnob;
  
  final double _maxRadius = 60.0; 
  bool _isDragging = false;
  
  // Variável pública para o Player ler
  Vector2 joystickDelta = Vector2.zero();

  final ValueNotifier<int> currentRoomNotifier = ValueNotifier<int>(0);
  int get currentRoom => currentRoomNotifier.value;
  final ValueNotifier<int> currentLevelNotifier = ValueNotifier<int>(1);
  int get currentLevel => currentLevelNotifier.value;
  final int bossRoom = 10;
  int maxLevel = 2;

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  
  CollectibleType nextRoomReward = CollectibleType.nextlevel;

  final GameProgress progress = GameProgress();

  late ScreenTransition transitionEffect;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {
    await progress.load();
    debugMode = false;
    // 1. VIEWPORT (Janela do Jogo)
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    // 2. CONSTRUÇÃO MANUAL DO JOYSTICK
    // Base (O círculo cinza no fundo)
    joystickBase = CircleComponent(
      radius: _maxRadius,
      paint: Paint()..color = Colors.grey.withOpacity(0.3),
      anchor: Anchor.center, // Importante: Centro no pivô
      priority: 900,         // Alto, mas abaixo do knob
    );

    // Knob (A bolinha branca que mexe)
    joystickKnob = CircleComponent(
      radius: 20,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
      anchor: Anchor.center,
      priority: 901,         // Mais alto para ficar em cima da base
    );

    // Esconde eles inicialmente (jogando pra longe)
    joystickBase.position = Vector2(-1000, -1000);
    joystickKnob.position = Vector2(-1000, -1000);

    // ADICIONA AO VIEWPORT (Para ficarem fixos na tela, tipo HUD)
    camera.viewport.add(joystickBase);
    camera.viewport.add(joystickKnob);


    // 3. CONFIGURAÇÃO DA ARENA
    const double gameWidth = 400;
    const double gameHeight = 700;

    await world.add(ArenaBorder(
      size: Vector2(gameWidth, gameHeight),
      wallThickness: 54, 
      radius: 40,       
    ));

    camera.setBounds(
      Rectangle.fromCenter(
        center: Vector2.zero(),
        size: Vector2(gameWidth, gameHeight),
      ),
      considerViewport: true,
    );

    // 4. MUNDO E ENTIDADES
    roomManager = RoomManager();
    world.add(roomManager);

    player = Player(position: Vector2(0, 0));
    world.add(player);
    
    camera.follow(player);

    transitionEffect = ScreenTransition();
    camera.viewport.add(transitionEffect);

    overlays.addEntry('bank_menu', (context, game) => BankMenu(game: this));
  }

  // Tira da Carteira (Atual) -> Põe no Banco (Persistente)
  void depositCoins(int amount) {
    if (coinsNotifier.value >= amount) {
      coinsNotifier.value -= amount; // Tira da mão
      progress.depositToBank(amount); // Salva no banco
    }
  }

  // Tira do Banco (Persistente) -> Põe na Carteira (Atual)
  void withdrawCoins(int amount) async {
    // Tenta sacar do banco
    bool success = await progress.withdrawFromBank(amount);
    
    if (success) {
      coinsNotifier.value += amount; // Põe na mão
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    // 1. Converte o toque da tela para coordenadas do Viewport (360x640)
    final screenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);

    // 2. Posiciona a BASE e o KNOB exatamente onde tocou
    joystickBase.position = screenPosition;
    joystickKnob.position = screenPosition;
    
    // 3. Marca como arrastando
    _isDragging = true;
    
    // Zera o movimento inicial
    joystickDelta = Vector2.zero();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    if (!_isDragging) return;

    // 1. Onde o dedo está AGORA (no viewport)
    final currentScreenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);
    
    // 2. Calcula a distância entre o dedo e o centro da base
    final dragVector = currentScreenPosition - joystickBase.position;
    
    // 3. Limita o movimento ao raio máximo (Matemática de vetores)
    if (dragVector.length > _maxRadius) {
      // Se esticou demais, prende na borda do círculo
      joystickKnob.position = joystickBase.position + (dragVector.normalized() * _maxRadius);
    } else {
      // Se está dentro, segue o dedo
      joystickKnob.position = currentScreenPosition;
    }

    // 4. CALCULA O DELTA (Isso é o que o Player usa para andar)
    // O valor deve ser entre -1 e 1
    // (Posição do Knob - Posição da Base) / Raio
    final rawDelta = joystickKnob.position - joystickBase.position;
    joystickDelta = rawDelta / _maxRadius;
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _resetJoystick();
  }

  @override
  void onPanCancel() {
    _resetJoystick();
  }

  void _resetJoystick() {
    _isDragging = false;
    
    // Some com o joystick visualmente
    joystickBase.position = Vector2(-1000, -1000);
    joystickKnob.position = Vector2(-1000, -1000);
    
    // Para o player
    joystickDelta = Vector2.zero();
  }

  @override
  void onMount() {
    super.onMount();
    overlays.add('MainMenu');
  }
  
  void toggleDebugMode(){
    debugMode = !debugMode;
  }

  void atualizaDebugMode(){
    for (var component in world.children) {
        if (component is PositionComponent) {
          component.debugMode = debugMode;
        }
    }
  }

  void startGame() {
    overlays.remove('MainMenu');
    overlays.add('HUD');
    resumeEngine();
    resetGame();
  }

  void pauseGame() {
    pauseEngine();
    overlays.remove('HUD');
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    overlays.remove('PauseMenu');
    overlays.add('HUD');
    resumeEngine();
  }

  void returnToMenu() {
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('HUD');
    overlays.add('MainMenu');
  }

  void startLevel() {
    player.position = Vector2(0, 250); 
    roomManager.startRoom(currentRoom);
  }

  void nextLevel(CollectibleType chosenReward) {
    currentRoomNotifier.value++;
    if (currentRoom > bossRoom){
      currentRoomNotifier.value = 0;
      currentLevelNotifier.value++;
      if (currentLevel > maxLevel) winGame(); 
    }
    nextRoomReward = chosenReward;

    // Limpeza de componentes
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((c) => c.removeFromParent());
    world.children.query<UnlockableItem>().forEach((c) => c.removeFromParent());
    
    startLevel();
  }

  void onGameOver() {
    pauseEngine(); 
    overlays.add('GameOver'); 
  }

   void winGame() {
    pauseEngine(); 
    overlays.add('VictoryMenu'); 
  }

  void resetGame() {
    overlays.remove('GameOver');
    overlays.remove('VictoryMenu'); 
    resumeEngine();

    currentRoomNotifier.value = 0;
    currentLevelNotifier.value = 1;
    coinsNotifier.value = 10;
    keysNotifier.value = 0;
    nextRoomReward = CollectibleType.nextlevel;

    // Limpa tudo
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((c) => c.removeFromParent());
    world.children.query<UnlockableItem>().forEach((c) => c.removeFromParent());

    player.reset();
    camera.follow(player);

    startLevel();
  }
}