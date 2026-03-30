import 'dart:math';
import 'dart:async';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/character_class.dart';
import 'package:towerrogue/game/components/core/save_manager.dart';
import 'package:towerrogue/game/components/core/screen_transition.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:flame/camera.dart'; 
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/core/room_manager.dart';
import 'components/gameObj/collectible.dart';
import 'components/core/pallete.dart';
import 'components/gameObj/arena_border.dart';
import 'components/core/game_progress.dart';
import 'package:flutter/services.dart';

class TowerGame extends FlameGame with MultiTouchDragDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double gameWidth = 500.0;  // Largura total (Esquerda <-> Direita)
  static const double gameHeight = 900.0; // Altura total (Cima <-> Baixo)
  late final Player player;
  late final ArenaBorder arenaBorder;
  late final RoomManager roomManager;
  late CharacterClass selectedClass;

  //late final FragmentProgram _crtProgram;
  //double _shaderTime = 0.0;

  bool useCRTEffect = false;
  
  // --- SISTEMA DE JOYSTICK MANUAL ---
  // Em vez de usar JoystickComponent, usamos 2 círculos simples
  late CircleComponent joystickBase;
  late CircleComponent joystickKnob;
  
  final double _maxRadius = 40.0; 
  
  // Variável pública para o Player ler
  Vector2 joystickDelta = Vector2.zero();

  final ValueNotifier<int> currentRoomNotifier = ValueNotifier<int>(0);
  int get currentRoom => currentRoomNotifier.value;
  final ValueNotifier<int> currentLevelNotifier = ValueNotifier<int>(1);
  int get currentLevel => currentLevelNotifier.value;
  final int bossRoom = 10;
  int numLevels = 5;

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  int coinsTotal = 0;
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> challengeHitsNotifier = ValueNotifier<int>(-1);
  int soulsTotal = 0;
  
  CollectibleType nextRoomReward = CollectibleType.nextlevel;

  final GameProgress progress = GameProgress();
  

  late ScreenTransition transitionEffect;

  int? _joystickPointerId;

  //final List<CollectibleType> itensComunsPool = retornaItensComuns();
  //final List<CollectibleType> itensRarosPool = retornaItensRaros();
  List<CollectibleType> itensComunsPoolCurrent = [];
  List<CollectibleType> itensRarosPoolCurrent = [];

  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  //final double gameWidth = 500;
  //final double gameHeight = 900;

  double _hitStopTimer = 0.0;

  bool usouBomba = false;

  double chanceChampBonus = 0;

  bool primeiroInimigoPocaVeneno = false;

  // --- SISTEMA DE EMPRÉSTIMO ---
  final ValueNotifier<int> dividaNotifier = ValueNotifier<int>(0);
  bool isCurrentRoomBank = false;

  double difficultyMultiplier = 1.0;

  bool killDummy = false;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {

   // _crtProgram = await FragmentProgram.fromAsset('shaders/crt.frag');

    try {
      await AudioManager.init();
    } catch (e) {
      print("Erro ao carregar áudio: $e");
    }
    
    await progress.load();
    debugMode = false;
    //camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));
    camera.viewport = MaxViewport();

    joystickBase = CircleComponent(
      radius: _maxRadius,
      paint: Paint()..color = Colors.grey.withOpacity(0.3),
      anchor: Anchor.center,
      priority: 900,        
    );

    joystickKnob = CircleComponent(
      radius: 20,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
      anchor: Anchor.center,
      priority: 901,         
    );

    joystickBase.position = Vector2(-1000, -1000);
    joystickKnob.position = Vector2(-1000, -1000);

    camera.viewport.add(joystickBase);
    camera.viewport.add(joystickKnob);

    arenaBorder = ArenaBorder(
      size: Vector2(gameWidth, gameHeight),
      wallThickness: 54, 
      radius: 40,       
    );
    await world.add(arenaBorder);

    camera.setBounds(
      Rectangle.fromLTWH(-60, -60, 120, 130),
      considerViewport: false, 
    );

    roomManager = RoomManager();
    add(roomManager);

    player = Player(position: Vector2(0, 0));
    world.add(player);
    
    camera.follow(player);

    transitionEffect = ScreenTransition();
    camera.viewport.add(transitionEffect);
    camera.viewfinder.anchor = Anchor.center;
    
    await progress.loadSettings(this);
   // useCRTEffect = false;
    if (AudioManager.isMutedMusic) {
      AudioManager.stopBgm(); 
    } else {
      AudioManager.stopBgm(); 
      AudioManager.playBgm('retro_forest.mp3');
    }
    
  }

 @override
  void update(double dt) {
    if (_hitStopTimer > 0) {
      _hitStopTimer -= dt;
      return; 
    }

    super.update(dt); 

    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      
      final rng = Random();
      double offsetX = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      double offsetY = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      
      camera.viewport.position = Vector2(offsetX, offsetY);

      if (_shakeTimer <= 0) {
        camera.viewport.position = Vector2.zero();
      }
    }
  }

  void triggerHitStop(double duration) {
    if (duration > _hitStopTimer) {
      _hitStopTimer = duration;
    }
  }

/*
@override
  void render(Canvas canvas) {
    if (!useCRTEffect) {
      super.render(canvas);
      return;
    }

    try {
      final shader = _crtProgram.fragmentShader();

      final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

      shader.setFloat(0, _shaderTime);
      
      shader.setFloat(1, size.x * pixelRatio); 
      shader.setFloat(2, size.y * pixelRatio);

      final paint = Paint()..imageFilter = ImageFilter.shader(shader);

      canvas.saveLayer(size.toRect(), paint);
      super.render(canvas);
      canvas.restore();

    } catch (e) {
      useCRTEffect = false;
      super.render(canvas);
    }
  }
  */
  void shakeCamera({double intensity = 5.0, double duration = 0.3}) {
    _shakeIntensity = intensity;
    _shakeTimer = duration;

    if (intensity >= 6.0) {
      HapticFeedback.heavyImpact();
    } 
    else {
      HapticFeedback.vibrate(); 
    }
  }

  void depositCoins(int amount) {
    if (coinsNotifier.value >= amount) {
      coinsNotifier.value -= amount; 
      progress.depositToBank(amount); 
    }
  }

  void withdrawCoins(int amount) async {
    bool success = await progress.withdrawFromBank(amount);
    
    if (success) {
      coinsNotifier.value += amount; 
    }
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    if (_joystickPointerId != null) return;
    
    _joystickPointerId = pointerId;

    final screenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);

    joystickBase.position = screenPosition;
    joystickKnob.position = screenPosition;
    
    joystickDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    if (pointerId != _joystickPointerId) return;

    final currentScreenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);
    
    final dragVector = currentScreenPosition - joystickBase.position;
    
    if (dragVector.length > _maxRadius) {
      joystickKnob.position = joystickBase.position + (dragVector.normalized() * _maxRadius);
    } else {
      joystickKnob.position = currentScreenPosition;
    }

    final rawDelta = joystickKnob.position - joystickBase.position;
    joystickDelta = rawDelta / _maxRadius;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    if (pointerId == _joystickPointerId) {
      _resetJoystick();
    }
  }

  @override
  void onDragCancel(int pointerId) {
    if (pointerId == _joystickPointerId) {
      _resetJoystick();
    }
  }

  void _resetJoystick() {
    _joystickPointerId = null; 
    
    joystickBase.position = Vector2(-1000, -1000);
    joystickKnob.position = Vector2(-1000, -1000);
    
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

  void startGame(CharacterClass selectedClass) {
    overlays.remove('MainMenu');
    overlays.add('HUD');
    resumeEngine();
    resetGame(selectedClass);
  }

  void pauseGame() {
    AudioManager.pauseBgm();
    pauseEngine();
    overlays.remove('HUD');
    overlays.add('PauseMenu');
  }

  void resumeGame() {
    AudioManager.resumeBgm();
    overlays.remove('PauseMenu');
    overlays.add('HUD');
    resumeEngine();
  }

  void returnToMenu() {
    overlays.remove('PauseMenu');
    overlays.remove('GameOver');
    overlays.remove('HUD');
    overlays.add('MainMenu');
    AudioManager.playBgm('retro_forest.mp3');
    print('returnToMenu');
  }

  void startLevel({salaAtual = true,sala = 0}) {
    player.position = Vector2(0, 250); 
    roomManager.startRoom(salaAtual?currentRoom:sala);
    player.applyZodiac();
  }

  void continueGame() async {
    // 1. Limpa o mundo ANTES de carregar para evitar fantasmas da sessão anterior!
    world.removeAll(world.children.where((c) => c != player && c != arenaBorder && c != roomManager));

    // 2. Carrega o Save
    String? savedClassId = await SaveManager.loadRun(this);

    selectedClass = CharacterRoster.getClassById(savedClassId);

    // 3. RECONSTRÓI AS POOLS! (É isto que impedia o jogador de atirar!)
    itensComunsPoolCurrent = retornaItensComuns(player);
    itensRarosPoolCurrent = retornaItensRaros(player);

    // 4. Muda a UI e retoma o motor
    overlays.remove('MainMenu');
    overlays.add('HUD');
    resumeEngine();

    startLevel();
  }

  void nextLevel(CollectibleType chosenReward,{bool mesmaSala = false}) {
    primeiroInimigoPocaVeneno = false;
    player.rechargeActiveItem();
    //reseta upgrades temporarios
    if(player.isHomingTemp) player.isHomingTemp = false;
    if(player.takeOneDmg) player.takeOneDmg = false;
    if(player.zodiacTaurusTransf) player.zodiacTaurusTransf = false;

    if(!mesmaSala)currentRoomNotifier.value++;
    if (currentRoom > bossRoom){
      currentRoomNotifier.value = 0;
      currentLevelNotifier.value++;
      if (currentLevel > numLevels) winGame(); 
    }
    nextRoomReward = chosenReward;

    /* Limpeza de componentes
    world.children.query<Door>().forEach((d) => d.removeFromParent());
    world.children.query<Projectile>().forEach((p) => p.removeFromParent());
    world.children.query<Enemy>().forEach((e) => e.removeFromParent());
    world.children.query<Collectible>().forEach((c) => c.removeFromParent());
    world.children.query<Wall>().forEach((w) => w.removeFromParent());
    world.children.query<Chest>().forEach((c) => c.removeFromParent());
    world.children.query<UnlockableItem>().forEach((c) => c.removeFromParent());
    world.children.query<BankAtm>().forEach((c) => c.removeFromParent());
    */

    world.removeAll(world.children.where((c) => c != player && c != arenaBorder));
    //collisionDetection.items.clear();
    saveGame();
    startLevel();
  }

  void saveGame(){
    SaveManager.saveRun(this);
  }

  void onGameOver() {
    SaveManager.clearSavedRun();
    AudioManager.stopBgm();
    pauseEngine(); 
    overlays.add('GameOver'); 
  }

   void winGame() {
    pauseEngine(); 
    overlays.add('VictoryMenu'); 
  }

  void resetGame(CharacterClass selectedClass) {
     // Recarrega os áudios para evitar problemas de cache
    overlays.remove('GameOver');
    overlays.remove('VictoryMenu'); 
    resumeEngine();

    usouBomba = false;

    currentRoomNotifier.value = 0;
    currentLevelNotifier.value = 1;
    coinsNotifier.value = 0;
    keysNotifier.value = 0;
    challengeHitsNotifier.value = -1;
    nextRoomReward = CollectibleType.nextlevel;

    // Limpa tudo
    world.removeAll(world.children.where((c) => c != player && c != arenaBorder));

    player.reset();
    player.applyClass(selectedClass);
    camera.follow(player);

    itensComunsPoolCurrent = retornaItensComuns(player);
    itensRarosPoolCurrent = retornaItensRaros(player);
    itensComunsPoolCurrent.shuffle();
    itensRarosPoolCurrent.shuffle();
    
    AudioManager.playBgm('8_bit_adventure.mp3');
    startLevel();
  }

  @override
  void onRemove() {
    // Garante que o motor de áudio desliga a música quando o jogo é destruído/recarregado
    AudioManager.stopBgm(); 
    
    super.onRemove();
  }
}