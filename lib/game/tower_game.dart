import 'dart:math';
import 'dart:ui';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:TowerRogue/game/components/core/save_manager.dart';
import 'package:TowerRogue/game/components/core/screen_transition.dart';
import 'package:TowerRogue/game/components/gameObj/bank_atm.dart';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/experimental.dart';
import 'package:flame_audio/flame_audio.dart'; 
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
import 'components/gameObj/arena_border.dart';
import 'components/core/game_progress.dart';
import 'overlays/bank_menu.dart';
import 'package:flutter/services.dart';

class TowerGame extends FlameGame with MultiTouchDragDetector, HasCollisionDetection, HasKeyboardHandlerComponents {
  static const double arenaWidth = 360.0;  // Largura total (Esquerda <-> Direita)
  static const double arenaHeight = 660.0; // Altura total (Cima <-> Baixo)
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
  final ValueNotifier<int> keysNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> challengeHitsNotifier = ValueNotifier<int>(-1);
  
  CollectibleType nextRoomReward = CollectibleType.nextlevel;

  final GameProgress progress = GameProgress();
  

  late ScreenTransition transitionEffect;

  int? _joystickPointerId;

  final List<CollectibleType> itensComunsPool = retornaItensComuns();
  final List<CollectibleType> itensRarosPool = retornaItensRaros();
  List<CollectibleType> itensComunsPoolCurrent = [];
  List<CollectibleType> itensRarosPoolCurrent = [];

  double _shakeTimer = 0.0;
  double _shakeIntensity = 0.0;

  
  final double gameWidth = 500;
  final double gameHeight = 900;

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
    // 1. VIEWPORT (Janela do Jogo)
    //camera.viewport = FixedResolutionViewport(resolution: Vector2(360, 640));
    camera.viewport = MaxViewport();

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

    arenaBorder = ArenaBorder(
      size: Vector2(gameWidth, gameHeight),
      wallThickness: 54, 
      radius: 40,       
    );
    await world.add(arenaBorder);

    camera.setBounds(
      Rectangle.fromLTWH(-60, -60, 120, 130),
      considerViewport: false, // Force a parada independente do tamanho da tela
    );

    // 4. MUNDO E ENTIDADES
    roomManager = RoomManager();
    add(roomManager);

    player = Player(position: Vector2(0, 0));
    world.add(player);
    
    camera.follow(player);

    transitionEffect = ScreenTransition();
    camera.viewport.add(transitionEffect);
    camera.viewfinder.anchor = Anchor.center;

    overlays.addEntry('bank_menu', (context, game) => BankMenu(game: this));

    FlameAudio.bgm.initialize();

    await progress.loadSettings(this);
    useCRTEffect = false;
  }

 @override
  void update(double dt) {
    super.update(dt); 

    // --- NOVA LÓGICA DO TREMOR (À PROVA DE FALHAS) ---
    if (_shakeTimer > 0) {
      _shakeTimer -= dt;
      
      final rng = Random();
      double offsetX = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      double offsetY = (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;
      
      // O PULO DO GATO: Nós trememos a tela do celular (viewport), 
      // e não o mundo virtual do jogo. Assim não briga com o camera.follow()!
      camera.viewport.position = Vector2(offsetX, offsetY);

      // Quando o tempo acabar, temos que garantir que a tela volta para o centro
      if (_shakeTimer <= 0) {
        camera.viewport.position = Vector2.zero();
      }
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

      // Pega a densidade real da tela
      final pixelRatio = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;

      shader.setFloat(0, _shaderTime);
      
      // Resolução perfeita usando apenas o tamanho do Flame multiplicado pela densidade
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

    // --- LÓGICA DE VIBRAÇÃO FÍSICA NO CELULAR ---
    // Se o tremor for forte (como o do Boss), dá um "Tranco" pesado
    if (intensity >= 6.0) {
      HapticFeedback.heavyImpact();
    } 
    // Se for um tremor mais fraco (dano comum), vibra mais suave
    else {
      HapticFeedback.vibrate(); 
    }
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
  void onDragStart(int pointerId, DragStartInfo info) {
    // 2. A MÁGICA: Se já temos um dedo controlando o joystick, ignora esse novo toque!
    if (_joystickPointerId != null) return;
    
    // Grava o ID do dedo que acabou de tocar para ser o "Dono" do joystick
    _joystickPointerId = pointerId;

    // Converte o toque da tela para coordenadas do Viewport (360x640)
    final screenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);

    // Posiciona a BASE e o KNOB exatamente onde tocou
    joystickBase.position = screenPosition;
    joystickKnob.position = screenPosition;
    
    // Zera o movimento inicial
    joystickDelta = Vector2.zero();
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    // 3. SEGREGAÇÃO: Se o dedo que está movendo não for o Dono, ignora!
    if (pointerId != _joystickPointerId) return;

    // Onde o dedo está AGORA (no viewport)
    final currentScreenPosition = camera.viewport.globalToLocal(info.eventPosition.widget);
    
    // Calcula a distância entre o dedo e o centro da base
    final dragVector = currentScreenPosition - joystickBase.position;
    
    // Limita o movimento ao raio máximo
    if (dragVector.length > _maxRadius) {
      joystickKnob.position = joystickBase.position + (dragVector.normalized() * _maxRadius);
    } else {
      joystickKnob.position = currentScreenPosition;
    }

    // CALCULA O DELTA (Isso é o que o Player usa para andar)
    final rawDelta = joystickKnob.position - joystickBase.position;
    joystickDelta = rawDelta / _maxRadius;
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    // Só reseta o joystick se o dedo que levantou for o Dono
    if (pointerId == _joystickPointerId) {
      _resetJoystick();
    }
  }

  @override
  void onDragCancel(int pointerId) {
    // Só cancela se for o Dono
    if (pointerId == _joystickPointerId) {
      _resetJoystick();
    }
  }

  void _resetJoystick() {
    // Libera o joystick para um novo dedo no futuro
    _joystickPointerId = null; 
    
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

  void startGame(CharacterClass selectedClass) {
    overlays.remove('MainMenu');
    overlays.add('HUD');
    resumeEngine();
    resetGame(selectedClass);
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
    AudioManager.playBgm('8bit_menu.mp3');
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
    SaveManager.saveRun(this);
    startLevel();
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
    itensComunsPoolCurrent = List.from(itensComunsPool);
    itensRarosPoolCurrent = List.from(itensRarosPool);
    itensComunsPoolCurrent.shuffle();
    itensRarosPoolCurrent.shuffle();

     // Recarrega os áudios para evitar problemas de cache
    overlays.remove('GameOver');
    overlays.remove('VictoryMenu'); 
    resumeEngine();

    currentRoomNotifier.value = 0;
    currentLevelNotifier.value = 1;
    coinsNotifier.value = 0;
    keysNotifier.value = 0;
    nextRoomReward = CollectibleType.nextlevel;

    // Limpa tudo
    world.removeAll(world.children.where((c) => c != player && c != arenaBorder));

    player.reset();
    player.applyClass(selectedClass);
    camera.follow(player);
    
    AudioManager.playBgm('funny_bit.mp3');
    startLevel();
  }
}