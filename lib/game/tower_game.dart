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
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/gameObj/chest.dart';
import 'package:towerrogue/game/components/gameObj/door.dart';
import 'package:towerrogue/game/components/gameObj/npc.dart'; 
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/core/room_manager.dart';
import 'package:towerrogue/game/components/gameObj/secret_door.dart';
import 'package:towerrogue/game/components/gameObj/unlockable_item.dart';
import 'package:towerrogue/game/components/gameObj/wall.dart';
import 'package:towerrogue/game/components/projectiles/laser_beam.dart';
import 'package:towerrogue/game/components/projectiles/orbital_shield.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
import 'package:towerrogue/game/overlays/crt_overlay_widget.dart';
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
  int numLevels = 7;

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
  List<CollectibleType> itensEpicosPoolCurrent = [];

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

  // Guarda o NPC que está perto o suficiente para interagir
  Npc? npcNear; 
  
  // Guarda a lista de textos do diálogo atual
  List<String> activeDialogs = [];

  @override
  Color backgroundColor() => Pallete.preto;

  @override
  Future<void> onLoad() async {
    try {
      await AudioManager.init();
    } catch (e) {
      //print("Erro ao carregar áudio: $e");
    }

    //carregar imagens
    await images.loadAll([
      'sprites/chars/arqueiro.png',
      'sprites/mainMenu.png',
      'sprites/chars/bomberman.png',
      'sprites/chars/char.png',
      'sprites/chars/cowboy.png',
      'sprites/chars/debug.png',
      'sprites/chars/defensor.png',
      'sprites/chars/exterminador.png',
      'sprites/chars/guerreiro.png',
      'sprites/chars/ladino.png',
      'sprites/chars/licantropo.png',
      'sprites/chars/multidao.png',
      'sprites/chars/pac.png',
      'sprites/chars/piromante.png',
      'sprites/chars/samuela.png',
      'sprites/chars/unicorn.png',
      'sprites/condicoes/aries.png',
      'sprites/condicoes/caveira.png',
      'sprites/condicoes/charm.png',
      'sprites/condicoes/confuso.png',
      'sprites/condicoes/coracao.png',
      'sprites/condicoes/corrente.png',
      'sprites/condicoes/cruz.png',
      'sprites/condicoes/cupom.png',
      'sprites/condicoes/espada.png',
      'sprites/condicoes/fogo.png',
      'sprites/condicoes/gelo.png',
      'sprites/condicoes/gota.png',
      'sprites/doorIcons/alquimista.png',
      'sprites/doorIcons/bank.png',
      'sprites/doorIcons/bau.png',
      'sprites/doorIcons/bauTrancado.png',
      'sprites/doorIcons/blood.png',
      'sprites/doorIcons/bomb.png',
      'sprites/doorIcons/boss.png',
      'sprites/doorIcons/coins.png',
      'sprites/doorIcons/desafio.png',
      'sprites/doorIcons/escudo.png',
      'sprites/doorIcons/hpCheio.png',
      'sprites/doorIcons/hpVazio.png',
      'sprites/doorIcons/key.png',
      'sprites/doorIcons/loja.png',
      'sprites/doorIcons/lojaEvil.png',
      'sprites/doorIcons/nextLevel.png',
      'sprites/doorIcons/slot.png',
      'sprites/familiares/aranha.png',
      'sprites/familiares/circuloProt.png',
      'sprites/familiares/decoy.png',
      'sprites/familiares/dedo.png',
      'sprites/familiares/dummy.png',
      'sprites/familiares/espelho.png',
      'sprites/familiares/espirito.png',
      'sprites/familiares/fada.png',
      'sprites/familiares/fantasma.png',
      'sprites/familiares/lanca.png',
      'sprites/familiares/lanca2.png',
      'sprites/familiares/olho.png',
      'sprites/familiares/prisma.png',
      'sprites/familiares/satelite.png',
      'sprites/familiares/soul.png',
      'sprites/familiares/tornado.png',
      'sprites/familiares/turret.png',
      'sprites/familiares/turret2.png',
      'sprites/familiares/virus.png',
      'sprites/familiares/wisp.png',
      'sprites/gameObjs/banco.png',
      'sprites/gameObjs/bank.png',
      'sprites/gameObjs/bau.png',
      'sprites/gameObjs/bauAberto.png',
      'sprites/gameObjs/bauTrancado.png',
      'sprites/gameObjs/blood.png',
      'sprites/gameObjs/doacaoSangue.png',
      'sprites/gameObjs/lock.png',
      'sprites/gameObjs/pedestal.png',
      'sprites/gameObjs/slot.png',
      'sprites/gameObjs/slot2.png',
      'sprites/hud/bomb.png',
      'sprites/hud/coins.png',
      'sprites/hud/dash.png',
      'sprites/hud/dash1.png',
      'sprites/hud/dashCheio.png',
      'sprites/hud/dashVazio.png',
      'sprites/hud/escudo.png',
      'sprites/hud/hpCheio.png',
      'sprites/hud/hpMeio.png',
      'sprites/hud/hpVazio.png',
      'sprites/hud/key.png',
      'sprites/hud/pause.png',
      'sprites/hud/setaDir.png',
      'sprites/hud/setaEsq.png',
      'sprites/hud/soul.png',
      'sprites/inimigos/agiota.png',
      'sprites/inimigos/anemona.png',
      'sprites/inimigos/bat.png',
      'sprites/inimigos/bee.png',
      'sprites/inimigos/beehive.png',
      'sprites/inimigos/besta.png',
      'sprites/inimigos/bird.png',
      'sprites/inimigos/bishop.png',
      'sprites/inimigos/bug.png',
      'sprites/inimigos/coffin.png',
      'sprites/inimigos/cyborg.png',
      'sprites/inimigos/dolphin.png',
      'sprites/inimigos/drone.png',
      'sprites/inimigos/dullahan.png',
      'sprites/inimigos/dummy.png',
      'sprites/inimigos/elephant.png',
      'sprites/inimigos/fish.png',
      'sprites/inimigos/ghost.png',
      'sprites/inimigos/goblin.png',
      'sprites/inimigos/headless.png',
      'sprites/inimigos/jellyfish.png',
      'sprites/inimigos/king.png',
      'sprites/inimigos/knight.png',
      'sprites/inimigos/mare.png',
      'sprites/inimigos/mecha.png',
      'sprites/inimigos/megalodon.png',
      'sprites/inimigos/mushroom.png',
      'sprites/inimigos/orc.png',
      'sprites/inimigos/orcBerserk.png',
      'sprites/inimigos/orcChief.png',
      'sprites/inimigos/orcDefensor.png',
      'sprites/inimigos/orcShaman.png',
      'sprites/inimigos/pawn.png',
      'sprites/inimigos/queen.png',
      'sprites/inimigos/rabbit.png',
      'sprites/inimigos/rat.png',
      'sprites/inimigos/ratKing.png',
      'sprites/inimigos/rook.png',
      'sprites/inimigos/shark.png',
      'sprites/inimigos/slime.png',
      'sprites/inimigos/slimeP.png',
      'sprites/inimigos/snail.png',
      'sprites/inimigos/snake.png',
      'sprites/inimigos/spider.png',
      'sprites/inimigos/tank.png',
      'sprites/inimigos/tank2.png',
      'sprites/inimigos/tortoise.png',
      'sprites/inimigos/trueQueen.png',
      'sprites/inimigos/turret1.png',
      'sprites/inimigos/turret2.png',
      'sprites/inimigos/turtle.png',
      'sprites/inimigos/unicorn.png',
      'sprites/inimigos/warg.png',
      'sprites/inimigos/worm.png',
      'sprites/itens/adagaRitual.png',
      'sprites/itens/alqBrutal.png',
      'sprites/itens/antimateria.png',
      'sprites/itens/aquarius.png',
      'sprites/itens/aries.png',
      'sprites/itens/asa.png',
      'sprites/itens/bandage.png',
      'sprites/itens/bateria.png',
      'sprites/itens/bloodBag.png',
      'sprites/itens/bloquel.png',
      'sprites/itens/bltBuracoNegro.png',
      'sprites/itens/bltRastroFogo.png',
      'sprites/itens/bolaCorrente.png',
      'sprites/itens/bomba.png',
      'sprites/itens/bombaBuracoNegro.png',
      'sprites/itens/bombaConfusao.png',
      'sprites/itens/bombaDecoy.png',
      'sprites/itens/bombaDiarreia.png',
      'sprites/itens/bombaGlitter.png',
      'sprites/itens/bombardeio.png',
      'sprites/itens/bombaVeneno.png',
      'sprites/itens/bombsAreKeys.png',
      'sprites/itens/book.png',
      'sprites/itens/boss.png',
      'sprites/itens/bota.png',
      'sprites/itens/bounceShot.png',
      'sprites/itens/bumerangue.png',
      'sprites/itens/buracoNegro.png',
      'sprites/itens/cabecaUnicornio.png',
      'sprites/itens/cafe.png',
      'sprites/itens/caixa.png',
      'sprites/itens/cajado.png',
      'sprites/itens/cajadoQuebrado.png',
      'sprites/itens/cancer.png',
      'sprites/itens/capa.png',
      'sprites/itens/capricorn.png',
      'sprites/itens/cardinal.png',
      'sprites/itens/cash.png',
      'sprites/itens/cat.png',
      'sprites/itens/caveira.png',
      'sprites/itens/certificado.png',
      'sprites/itens/charm.png',
      'sprites/itens/cinturao.png',
      'sprites/itens/circuloProt.png',
      'sprites/itens/cogumelo.png',
      'sprites/itens/coin.png',
      'sprites/itens/coins.png',
      'sprites/itens/colar.png',
      'sprites/itens/confuseShot.png',
      'sprites/itens/console.png',
      'sprites/itens/coroa.png',
      'sprites/itens/cupon.png',
      'sprites/itens/d10.png',
      'sprites/itens/d20.png',
      'sprites/itens/d6.png',
      'sprites/itens/dash.png',
      'sprites/itens/decoy.png',
      'sprites/itens/dedo.png',
      'sprites/itens/detonador.png',
      'sprites/itens/devil.png',
      'sprites/itens/dummy.png',
      'sprites/itens/duplicado.png',
      'sprites/itens/encolhe.png',
      'sprites/itens/escada.png',
      'sprites/itens/escudo.png',
      'sprites/itens/escudoDivino.png',
      'sprites/itens/escudoExplode.png',
      'sprites/itens/escudoOrbital.png',
      'sprites/itens/escudoRegen.png',
      'sprites/itens/espelho.png',
      'sprites/itens/espelho2.png',
      'sprites/itens/espirito.png',
      'sprites/itens/faca.png',
      'sprites/itens/fada.png',
      'sprites/itens/fantasma.png',
      'sprites/itens/flail.png',
      'sprites/itens/fogo.png',
      'sprites/itens/fogoRastro.png',
      'sprites/itens/foice.png',
      'sprites/itens/fragmento.png',
      'sprites/itens/furia.png',
      'sprites/itens/gameboy.png',
      'sprites/itens/gemini.png',
      'sprites/itens/glifo.png',
      'sprites/itens/hpCheio.png',
      'sprites/itens/hpMeio.png',
      'sprites/itens/hpVazio.png',
      'sprites/itens/jarroCoracao.png',
      'sprites/itens/jarroFada.png',
      'sprites/itens/jumperCable.png',
      'sprites/itens/key.png',
      'sprites/itens/lamina.png',
      'sprites/itens/lanca.png',
      'sprites/itens/laser.png',
      'sprites/itens/leo.png',
      'sprites/itens/libra.png',
      'sprites/itens/licantropo.png',
      'sprites/itens/loja.png',
      'sprites/itens/machado.png',
      'sprites/itens/mao.png',
      'sprites/itens/masterOrb.png',
      'sprites/itens/mina.png',
      'sprites/itens/molhoChaves.png',
      'sprites/itens/molotov.png',
      'sprites/itens/neve.png',
      'sprites/itens/noItem.png',
      'sprites/itens/nuke.png',
      'sprites/itens/nuke2.png',
      'sprites/itens/olho.png',
      'sprites/itens/onda.png',
      'sprites/itens/patins.png',
      'sprites/itens/pet.png',
      'sprites/itens/piercing.png',
      'sprites/itens/pilha.png',
      'sprites/itens/pill.png',
      'sprites/itens/pisces.png',
      'sprites/itens/pocaVeneno.png',
      'sprites/itens/portal.png',
      'sprites/itens/potCura.png',
      'sprites/itens/potion.png',
      'sprites/itens/prego.png',
      'sprites/itens/presente.png',
      'sprites/itens/prisma.png',
      'sprites/itens/r.png',
      'sprites/itens/raio.png',
      'sprites/itens/raiva.png',
      'sprites/itens/restock.png',
      'sprites/itens/retribuicao.png',
      'sprites/itens/sacoBomba.png',
      'sprites/itens/sacoMoedas.png',
      'sprites/itens/sagittarius.png',
      'sprites/itens/sanduiche.png',
      'sprites/itens/sangue.png',
      'sprites/itens/satelite.png',
      'sprites/itens/saw.png',
      'sprites/itens/scorpio.png',
      'sprites/itens/scroll.png',
      'sprites/itens/seringa.png',
      'sprites/itens/slot.png',
      'sprites/itens/sonicBoom.png',
      'sprites/itens/soul.png',
      'sprites/itens/spectralShot.png',
      'sprites/itens/taurus.png',
      'sprites/itens/telecinese.png',
      'sprites/itens/tiroOrbital.png',
      'sprites/itens/tornado.png',
      'sprites/itens/tripleShot.png',
      'sprites/itens/turret.png',
      'sprites/itens/turret2.png',
      'sprites/itens/vampirismo.png',
      'sprites/itens/veneno.png',
      'sprites/itens/vinho.png',
      'sprites/itens/virgo.png',
      'sprites/itens/wisp.png',
      'sprites/itens/zodiac.png',
      'sprites/mainMenu.png',
      'sprites/npcs/alquimista.png',
      'sprites/npcs/diabo.png',
      'sprites/npcs/placa.png',
      'sprites/npcs/vendedor.png',
      'sprites/projeteis/adaga.png',
      'sprites/projeteis/arco.png',
      'sprites/projeteis/arranhao.png',
      'sprites/projeteis/blt.png',
      'sprites/projeteis/bomba.png',
      'sprites/projeteis/bumerangue.png',
      'sprites/projeteis/corte.png',
      'sprites/projeteis/corteP.png',
      'sprites/projeteis/escopeta.png',
      'sprites/projeteis/escudo.png',
      'sprites/projeteis/espada.png',
      'sprites/projeteis/faca.png',
      'sprites/projeteis/flail.png',
      'sprites/projeteis/flecha.png',
      'sprites/projeteis/fogo.png',
      'sprites/projeteis/foice.png',
      'sprites/projeteis/handCanon.png',
      'sprites/projeteis/mina.png',
      'sprites/projeteis/molotov.png',
      'sprites/projeteis/poca.png',
      'sprites/projeteis/revolver.png',
      'sprites/projeteis/soco.png',
      'sprites/projeteis/socoArma.png',
      'sprites/projeteis/varinha.png',
      'sprites/projeteis/web.png',
      'sprites/projeteis/webP.png',
      'sprites/tileset/1parede.png',
      'sprites/tileset/1paredeQuina.png',
      'sprites/tileset/1paredeQuina2.png',
      'sprites/tileset/1paredeQuina3.png',
      'sprites/tileset/1paredeQuina4.png',
      'sprites/tileset/2parede.png',
      'sprites/tileset/2paredeQuina.png',
      'sprites/tileset/3parede.png',
      'sprites/tileset/3paredeQuina.png',
      'sprites/tileset/4parede.png',
      'sprites/tileset/4parede2.png',
      'sprites/tileset/4paredeQuina.png',
      'sprites/tileset/4paredeQuina2.png',
      'sprites/tileset/5parede.png',
      'sprites/tileset/5parede2.png',
      'sprites/tileset/5paredeQuina.png',
      'sprites/tileset/5paredeQuina2.png',
      'sprites/tileset/anemona.png',
      'sprites/tileset/barril.png',
      'sprites/tileset/bloqueio.png',
      'sprites/tileset/crate.png',
      'sprites/tileset/crate3.png',
      'sprites/tileset/dama.png',
      'sprites/tileset/detalhe.png',
      'sprites/tileset/flor.png',
      'sprites/tileset/mushroom.png',
      'sprites/tileset/ossos.png',
      'sprites/tileset/pinheiro.png',
      'sprites/tileset/portaAberta.png',
      'sprites/tileset/portaBites.png',
      'sprites/tileset/portaFechada.png',
      'sprites/tileset/portaTrancada.png',
      'sprites/tileset/salaSecretaBomba.png',
      'sprites/tileset/salaSecretaChave.png',
      'sprites/tileset/salaSecretaEntrada.png',
      'sprites/tileset/salaSecretaEntradaChave.png',
      'sprites/tileset/salaSecretaSaida.png',
      'sprites/tileset/tabuleiro.png',
      'sprites/tileset/tumulo.png',
      'sprites/tileset/weaponRack.png',
    ]);
    
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
    player.position = Vector2(0, 224); 
    roomManager.startRoom(salaAtual?currentRoom:sala);
    player.applyZodiac();
  }

  void continueGame() async {
    // 1. Limpa o mundo ANTES de carregar para evitar fantasmas da sessão anterior!
    world.removeAll(
      world.children.where((c) {
        // 1. Se for o player, NÃO remove (retorna falso)
        if (c == player){
          return false;
        } 
        
        // 2. Se for a borda da arena, NÃO remove
        if (c == arenaBorder) return false;
        
        // 3. Se for um escudo orbital E o dono dele for o player, NÃO remove
        if (c is OrbitalShield && c.owner == player){
          return false;
        } 

        // 4. Qualquer outra coisa (inimigos, escudos de inimigos, tiros, itens), REMOVE! (retorna true)
        return true;
      })
    );

    // 2. Carrega o Save
    String? savedClassId = await SaveManager.loadRun(this);

    selectedClass = CharacterRoster.getClassById(savedClassId);

    player.criaVisual(reset : true);

    // 3. RECONSTRÓI AS POOLS! (É isto que impedia o jogador de atirar!)
    itensComunsPoolCurrent = retornaItensComuns(player);
    itensRarosPoolCurrent = retornaItensRaros(player);
    itensEpicosPoolCurrent = retornaItensEpicos(player);


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

    world.removeAll(
      world.children.where((c) {
        // 1. Se for o player, NÃO remove (retorna falso)
        if (c == player){
          return false;
        } 
        
        // 2. Se for a borda da arena, NÃO remove
        if (c == arenaBorder) return false;
        
        // 3. Se for um escudo orbital E o dono dele for o player, NÃO remove
        if (c is OrbitalShield && c.owner == player){
          return false;
        } 

        // 4. Qualquer outra coisa (inimigos, escudos de inimigos, tiros, itens), REMOVE! (retorna true)
        return true;
      })
    );
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
    itensEpicosPoolCurrent = retornaItensEpicos(player);
    itensComunsPoolCurrent.shuffle();
    itensRarosPoolCurrent.shuffle();
    itensEpicosPoolCurrent.shuffle();

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

  void forceTeleportToRoom(int targetRoom, int targetLevel) {
    // 1. Reseta os notifiers
    currentRoomNotifier.value = targetRoom;
    currentLevelNotifier.value = targetLevel;
    
    // 2. Limpeza profunda do mundo
    final coisasParaApagar = world.children.where((component) {
        return component is Enemy ||
               component is Door ||
               component is Collectible ||
               component is Projectile ||
               component is UnlockableItem ||
               component is LaserBeam ||
               component is Npc ||
               component is Wall ||
               component is Wall ||
               component is PoisonPuddle;
      }).toList(); // O .toList() é obrigatório aqui para evitar erros de remoção!
      
      world.removeAll(coisasParaApagar);

    // 3. Pool de recompensas (Igual ao seu código)
    Set<CollectibleType> possibleRewards = {
      CollectibleType.coin,
      CollectibleType.potion,
      CollectibleType.shield,
      CollectibleType.key,
      CollectibleType.bomba,
      CollectibleType.healthContainer,
      CollectibleType.chest,
      CollectibleType.rareChest,
      CollectibleType.doacaoSangue,
      CollectibleType.slotMachine,
    };
    List<CollectibleType> finalPool = possibleRewards.toList();
    finalPool.shuffle();

    nextRoomReward = finalPool[0];
    if(targetRoom == 10){
      nextRoomReward = CollectibleType.boss;
    }else if(targetRoom == 0){
      nextRoomReward = CollectibleType.nextLevel;
    }

    // 4. Posiciona o player antes de iniciar a sala
    player.position = Vector2(0, 250); 

    // 5. O CÓDIGO CHAVE: Reinicia completamente o RoomManager
    // Forçamos ele a "esquecer" que já tinha uma sala ativa
    roomManager.resetStateForTeleport(); 
    roomManager.startRoom(targetRoom);
  }

  @override
  void onRemove() {
    // Garante que o motor de áudio desliga a música quando o jogo é destruído/recarregado
    AudioManager.stopBgm(); 
    
    super.onRemove();
  }
}