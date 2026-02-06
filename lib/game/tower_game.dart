import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/camera.dart'; 
import 'package:flame/experimental.dart';
import 'package:TowerRogue/game/components/player.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/door.dart';
import 'package:TowerRogue/game/components/room_manager.dart';
import 'package:TowerRogue/game/components/projectile.dart';
import 'package:TowerRogue/game/components/chest.dart';
import 'components/collectible.dart';
import 'components/pallete.dart';
import 'components/wall.dart';
import 'components/arena_border.dart';

class TowerGame extends FlameGame with PanDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  
  late final Player player;
  late final RoomManager roomManager;
  
  // JOYSTICK
  late JoystickComponent joystick;
  final double _joystickRadius = 60.0; // Reduzi um pouco para ficar mais confortável
  Vector2 joystickDelta = Vector2.zero();

  // PAINTS (Controle de Transparência)
  // Começam visíveis (Alpha 255) para você debugar. 
  // Mude .withAlpha(0) quando quiser esconder.
  final _knobPaint = Paint()..color = Colors.white.withOpacity(0.8);
  final _backgroundPaint = Paint()..color = Colors.grey.withOpacity(0.3);

  int currentRoom = 1;
  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  CollectibleType nextRoomReward = CollectibleType.coin;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {
    // 1. VIEWPORT
    camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));

    // 2. CONFIGURAÇÃO DO JOYSTICK
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: _knobPaint),
      background: CircleComponent(radius: _joystickRadius, paint: _backgroundPaint),
      priority: 1000, // Prioridade máxima
      anchor: Anchor.center, // <--- CORREÇÃO 1: Centro no dedo
    );

    // Começa fora da tela para não aparecer no (0,0)
    joystick.position = Vector2(-1000, -1000);

    // Adiciona ao HUD (Viewport)
    camera.viewport.add(joystick);

    // 3. ARENA E BORDAS
    const double gameWidth = 400;
    const double gameHeight = 700;

    await world.add(ArenaBorder(
      size: Vector2(gameWidth, gameHeight),
      wallThickness: 64, 
      radius: 20,       
    ));

    camera.setBounds(
      Rectangle.fromCenter(
        center: Vector2.zero(),
        size: Vector2(gameWidth, gameHeight),
      ),
      considerViewport: true,
    );

    // 4. MUNDO E PLAYER
    roomManager = RoomManager();
    world.add(roomManager);

    player = Player(position: Vector2(0, 0));
    world.add(player);
    
    // Opcional: Se quiser colisão na tela toda. 
    // Mas ScreenHitbox no mundo pode bugar se a câmera andar. 
    // Prefira usar as paredes da ArenaBorder.
    // world.add(ScreenHitbox()); 

    camera.follow(player);
  }

  // --- LÓGICA DO JOYSTICK DINÂMICO ---

  @override
  void onPanStart(DragStartInfo info) {
    // CORREÇÃO 2: Conversão Robusta de Coordenadas
    // Pegamos o pixel exato da tela (.widget) e convertemos para o Viewport (360x640)
    final viewportPosition = camera.viewport.globalToLocal(info.eventPosition.widget);
    
    // Move o joystick para lá
    joystick.position = viewportPosition;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    // Mesma conversão para garantir consistência
    final viewportPosition = camera.viewport.globalToLocal(info.eventPosition.widget);
    final localDelta = viewportPosition - joystick.position;
    
    // Lógica de limitar o movimento da bolinha (Knob)
    if (localDelta.length > _joystickRadius) {
      joystick.knob!.position = localDelta.normalized() * _joystickRadius;
    } else {
      joystick.knob!.position = localDelta;
    }
    
    // Atualiza o Delta que o Player vai ler
    joystickDelta = joystick.relativeDelta;
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
    // Joga o joystick para longe novamente (ou use opacidade se preferir)
    joystick.position = Vector2(-1000, -1000); 
    
    // Reseta a bolinha e o movimento
    joystick.knob!.position = Vector2.zero();
    joystickDelta = Vector2.zero();
  }

  // --- MÉTODOS DE FLUXO (Mantidos) ---

  @override
  void onMount() {
    super.onMount();
    overlays.add('MainMenu');
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
    currentRoom++;
    nextRoomReward = chosenReward;

    // Limpeza segura usando query
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((c) => c.removeFromParent());// Adicione ShopItem se tiver criado
    
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

    // Limpa tudo
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((c) => c.removeFromParent());
    // Adicione ShopItem na limpeza se necessário

    player.reset();
    camera.follow(player);

    startLevel();
  }
}