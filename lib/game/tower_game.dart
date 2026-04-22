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
import 'package:towerrogue/game/components/gameObj/chest.dart'; 
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/core/room_manager.dart';
import 'package:towerrogue/game/components/gameObj/secret_door.dart';
import 'components/gameObj/collectible.dart';
import 'components/core/pallete.dart';
import 'components/gameObj/arena_border.dart';
import 'components/core/game_progress.dart';
import 'package:flutter/services.dart';

class TowerGame extends FlameGame with MultiTouchDragDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double gameWidth = 16*16; 
  static const double gameHeight = 16*32.0; 
  late final Player player;
  late final ArenaBorder arenaBorder;
  late final RoomManager roomManager;
  late CharacterClass selectedClass;

  //late final FragmentProgram _crtProgram;
  //double _shaderTime = 0.0;

  bool useCRTEffect = false;
  
  late CircleComponent joystickBase;
  late CircleComponent joystickKnob;
  
  final double _maxRadius = 40.0; 
  
  Vector2 joystickDelta = Vector2.zero();

  final ValueNotifier<int> currentRoomNotifier = ValueNotifier<int>(0);
  int get currentRoom => currentRoomNotifier.value;
  final ValueNotifier<int> currentLevelNotifier = ValueNotifier<int>(1);
  int get currentLevel => currentLevelNotifier.value;
  final int bossRoom = 10;
  int numLevels = 6;

  final ValueNotifier<int> coinsNotifier = ValueNotifier<int>(0);
  int coinsTotal = 0;
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> challengeHitsNotifier = ValueNotifier<int>(-1);
  int soulsTotal = 0;

  Set<int> salasLimpas = {};

  List<Component> backupSalaNormal = [];
  List<Component> backupSalaSecreta = [];
  bool salaSecretaGeradaNestaSala = false;
  
  CollectibleType nextRoomReward = CollectibleType.nextLevel;

  final GameProgress progress = GameProgress();
  

  late ScreenTransition transitionEffect;

  int? _joystickPointerId;

  //final List<CollectibleType> itensComunsPool = retornaItensComuns();
  //final List<CollectibleType> itensRarosPool = retornaItensRaros();
  List<CollectibleType> itensComunsPoolCurrent = [];
  List<CollectibleType> itensRarosPoolCurrent = [];

  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;
  final Vector2 _baseViewportPosition = Vector2.zero();
  bool _isShaking = false;

  //final double gameWidth = 500;
  //final double gameHeight = 900;

  double _hitStopTimer = 0.0;

  bool usouBomba = false;

  double chanceChampBonus = 0;

  bool primeiroInimigoPocaVeneno = false;

  int salaAnteriorId = 0; 

  Vector2 posicaoRetorno = Vector2.zero();

  final ValueNotifier<int> dividaNotifier = ValueNotifier<int>(0);
  bool isCurrentRoomBank = false;

  double difficultyMultiplier = 1.0;

  bool killDummy = false;

  final ValueNotifier<bool> canInteractNotifier = ValueNotifier(false);
  final ValueNotifier<bool> interactIsItem = ValueNotifier(false);
  
  VoidCallback? onInteractAction;

  bool isGodMode = false;

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {

   // _crtProgram = await FragmentProgram.fromAsset('shaders/crt.frag');

    try {
      await AudioManager.init();
    } catch (e) {
      //print("Erro ao carregar áudio: $e");
    }
    
    await progress.load();
    debugMode = false;
    camera.viewport = FixedResolutionViewport(resolution: Vector2(gameWidth, gameHeight));
    //camera.viewport = MaxViewport();

    joystickBase = CircleComponent(
      radius: _maxRadius,
      paint: Paint()..color = Pallete.cinzaCla//.withOpacity(0.3)
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 1.0
                    ..isAntiAlias = false,
      anchor: Anchor.center,
      priority: 900,        
    );

    joystickKnob = CircleComponent(
      radius: 16,
      paint: Paint()..color = Pallete.branco//.withOpacity(0.8)
                    ..isAntiAlias = false,
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
      Rectangle.fromCenter(center: Vector2.zero(), size: Vector2(120, 100)),
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
      
      // A MÁGICA: No exato milissegundo antes de começar a tremer,
      // nós salvamos a coordenada perfeita da tela!
      if (!_isShaking) {
        _isShaking = true;
        _baseViewportPosition.setFrom(camera.viewport.position);
      }

      _shakeTimer -= dt;
      
      final rng = Random();
      double offsetX = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      double offsetY = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      
      // Trememos a tela somando o caos na posição original segura
      camera.viewport.position.setValues(
        _baseViewportPosition.x + offsetX,
        _baseViewportPosition.y + offsetY,
      );
      
    } else if (_isShaking) {
      // 3. O tremor acabou! Devolvemos a moldura pro lugar original
      // As bordas pretas e o alinhamento voltam ao normal na hora.
      _isShaking = false;
      camera.viewport.position.setFrom(_baseViewportPosition);
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
    //print('returnToMenu');
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

    if (!mesmaSala) {
      currentRoomNotifier.value++;
      if (currentRoomNotifier.value > bossRoom) {
        currentRoomNotifier.value = 0;
        currentLevelNotifier.value++;
        salasLimpas.clear();
        if(currentLevelNotifier.value > numLevels)
        {
          winGame();
        }
      }

      salaSecretaGeradaNestaSala = false;
      backupSalaNormal.clear();
      backupSalaSecreta.clear();
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
    dividaNotifier.value = 0;
    salasLimpas.clear();
    backupSalaNormal.clear();
    backupSalaSecreta.clear();
    salaSecretaGeradaNestaSala = false;
    coinsNotifier.value = 0;
    keysNotifier.value = 0;
    challengeHitsNotifier.value = -1;
    nextRoomReward = CollectibleType.nextLevel;

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

  void entrarNaSalaSecreta() {
    final rng = Random();
    roomManager.pauseManager = true;
    posicaoRetorno = player.position.clone();

    // 1. SALVA A SALA NORMAL: Pega tudo do mapa (menos player, borda e o manager)
    backupSalaNormal = world.children.where((c) => 
      c != player && c != arenaBorder && c != roomManager
    ).toList();

    // 2. Remove do mundo (Eles ficam "congelados" no tempo dentro da lista)
    world.removeAll(backupSalaNormal);

    // 3. CARREGA A SALA SECRETA
    if (!salaSecretaGeradaNestaSala) {
      // Primeira vez entrando: Gera a sala do zero
      salaSecretaGeradaNestaSala = true;
      
      player.position = Vector2(0, 170);
      if(rng.nextBool()){
        roomManager.geraItemAleatorio(Vector2(0, 80), 0);
      }else{
        world.add(Chest(position: Vector2(0, 80), isLock: rng.nextBool()));
      }
      world.add(SecretDoor(position: Vector2(0, 200), isExit: true));
      
    } else {
      // Já tínhamos entrado antes: Descongela a sala secreta salva!
      player.position = Vector2(0, 200); 
      world.addAll(backupSalaSecreta);
      backupSalaSecreta.clear(); // Limpa a caixa, pois os itens voltaram pro mundo
    }
  }

  void sairDaSalaSecreta() {
    // 1. SALVA A SALA SECRETA (Baús abertos, itens deixados pra trás, etc)
    backupSalaSecreta = world.children.where((c) => 
      c != player && c != arenaBorder && c != roomManager
    ).toList();

    // 2. Remove a sala secreta da tela
    world.removeAll(backupSalaSecreta);

    // 3. RESTAURA A SALA NORMAL (Tudo volta exatamente como estava, portas inclusas!)
    world.addAll(backupSalaNormal);
    backupSalaNormal.clear(); 

    roomManager.pauseManager = false;
    
    // 4. Devolve o jogador
    double offX = 16;
    if(posicaoRetorno.x > 0)offX = -16;
    player.position = posicaoRetorno + Vector2(0, offX); 
  }

  @override
  void onRemove() {
    // Garante que o motor de áudio desliga a música quando o jogo é destruído/recarregado
    AudioManager.stopBgm(); 
    
    super.onRemove();
  }
}