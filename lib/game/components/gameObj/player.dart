import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/character_class.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/effects/explosion_effect.dart';
import 'package:towerrogue/game/components/effects/floating_text.dart';
import 'package:towerrogue/game/components/effects/ghost_particle.dart';
import 'package:towerrogue/game/components/effects/magic_shield_effect.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import 'package:towerrogue/game/components/effects/unlock_notification.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/gameObj/familiar.dart';
import 'package:towerrogue/game/components/gameObj/door.dart';
import 'package:towerrogue/game/components/gameObj/unlockable_item.dart';
import 'package:towerrogue/game/components/projectiles/bomb.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:towerrogue/game/components/projectiles/laser_beam.dart';
import 'package:towerrogue/game/components/projectiles/mortar_shell.dart';
//import 'package:towerrogue/game/components/projectiles/orbital_shield.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
//import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; 
import 'dart:math';
import '../../tower_game.dart'; 
import '../enemies/enemy.dart'; 
import '../projectiles/projectile.dart';
//import '../core/game_icon.dart';
import '../core/pallete.dart';
import 'wall.dart';
import '../effects/dust.dart';

class Player extends PositionComponent 
    with HasGameRef<TowerGame>, KeyboardHandler, CollisionCallbacks {
  
  int maxHealth = 4;
  late final ValueNotifier<int> healthNotifier;
  ValueNotifier<int> shieldNotifier = ValueNotifier<int>(0);

  int maxArtificialHealth = 0;
  late final ValueNotifier<int> artificialHealthNotifier;

  int maxDash = 2;
  late final ValueNotifier<int> dashNotifier;
  
  bool _isInvincible = false;
  double _invincibilityTimer = 0;
  double invincibilityDuration = 1.0; 

  double attackRange = 1.0; 
  double attackRangeIni = 1.0;
  double _attackTimer = 0;
  double damage = 10.0;
  double damageIni = 10.0;
  double dotIni = 1.0;
  double dot = 1.0;
  double familiarDmg = 1.0;
  double critChance = 5;
  double critChanceIni = 5;
  double critDamage = 2.0;
  double critDamageIni = 2.0;
  double fireRate = 0.4; 
  double fireRateIni = 0.4; 
  double moveSpeed = 75.0;
  double moveSpeedIni = 75.0;
  double moveSpeedTaurus = 75.0;
  final double acceleration = 125.0; 
  final double friction = 750.0;
  bool velMax = false;
  TextComponent? velMaxText;
  int stackBonus = 0;
  double knockbackForce = 0;
  double sorte = 0;
  double sorteIni = 0;

  double bltSize = 16;
  String bltImage = 'sprites/projeteis/blt.png';
  String bltImageIni = 'sprites/projeteis/blt.png';
  double bltSpeed = 500;

  ValueNotifier<int> bombNotifier = ValueNotifier<int>(0);
  double bombButtonTimer = 0;

  // VETORES OTIMIZADOS (Previnem Garbage Collection)
  Vector2 velocity = Vector2.zero();
  final Vector2 velocityDash = Vector2(1, 0);
  final Vector2 _keyboardInput = Vector2.zero(); 
  final Vector2 _dashDirection = Vector2.zero();
  final Vector2 _collisionBuffer = Vector2.zero();
  final Vector2 _tempDirection = Vector2.zero(); 
  final Vector2 lastAttackDirection = Vector2.zero(); 

  bool isDashing = false;
  double _dashTimer = 0;
  double dashDuration = 0.4; 
  double dashSpeed = 275;    
  
  double _dashCooldownTimer = 0;
  double dashCooldown = 2.5; 

  bool isBerserk = false;
  bool isAudaz = false;
  bool isFreeze = false;
  bool isBurn = false;
  bool isPoison = false;
  bool isPoisonAlastra = false;
  bool tempPoison = false;
  bool tempPoisonAlastra = false;
  bool isBleed = false;
  bool isBebado = false;
  bool hasOrbShield = false;
  bool hasFoice = false;
  bool magicShield = false;
  bool hasShield = false;
  int revive = 0;
  bool pegouRevive = false;
  bool hasAntimateria = false;
  bool isHoming = false;
  bool isHomingTemp = false;
  bool canBounce = false;
  bool isPiercing = false;
  bool tempPiercing = false;
  bool isSpectral = false;
  bool hasChaveNegra = false;
  bool isConcentration = false;
  bool isOrbitalShot = false;
  bool isMineShot = false;
  bool defensiveBurst = false;
  bool isKinetic = false;
  double kineticTimer = 0.0;
  int kineticStacks = 0;
  bool isHeavyShot = false;
  bool hasCupon = false;
  bool isBoomerang = false;
  bool criaPocaVeneno = false;
  double criaHazardTmr = 0;
  bool isShotgun = false;
  bool tripleShot = false;
  bool fireDash = false;
  bool isDashDamages = false;
  bool isLicantropia = false;
  double licantropiaTmr = 0;
  bool isMorteiro = false;
  bool hasBattery = false;
  bool hasShieldRegen = false;
  bool isShootSplits = false;
  bool confuseOnCrit = false;
  bool isBombSplits = false;
  bool isBombDecoy = false;
  bool bombaBuracoNegro = false;
  int tempDmgBonus = 0;
  int tempDmgGoldBonus = 0;
  int regenCount = 0;
  bool charmOnCrit = false;
  bool isFreezeDash = false;
  bool goldDmg = false;
  bool shieldCrit = false;
  bool isUnicorn = false;
  double unicornTmr = 0;
  bool isCritHeal = false;
  bool isLaser = false;
  bool isWave = false;
  bool isBomber = false;
  bool isSaw = false;
  bool explodeHit = false;
  bool restock = false;
  bool encolheOnCrit = false;
  bool dmgBuff = false;
  bool isGlitterBomb = false;
  bool goldShot = false;
  int clusterShot = -1;
  bool evasao = false;
  bool adrenalina = false;
  bool eutanasia = false;
  bool primeiroInimigoPocaVeneno = false;
  int killCharge = -1;
  double bombTimer = 0;
  bool voo = false;
  bool cardinalShot = false;
  bool isPac = false;
  double pacTmr = 0;
  bool hurtPac = false;
  bool zodiacAquarius = false;
  bool zodiacAries = false;
  bool zodiacCancer = false;
  bool takeOneDmg = false;
  bool zodiacLeo = false;
  bool zodiacVirgo = false;
  bool zodiacLibra = false;
  bool zodiacPisces = false;
  bool zodiacTaurus = false;
  bool zodiacTaurusTransf = false;
  bool zodiac = false;
  bool tempZodiacAquarius = false;
  bool tempZodiacAries = false;
  bool tempZodiacCancer = false;
  bool tempZodiacLeo = false;
  bool tempZodiacVirgo = false;
  bool tempZodiacLibra = false;
  bool tempZodiacPisces = false;
  bool tempZodiacTaurus = false;
  bool defensiveFairys = false;
  bool itemExtraBoss = false;
  bool retribuicao = false;
  bool refletirChance = false;
  bool adagaChance = false;
  bool glifoEquilibrio = false;
  bool bltFireHazard = false;
  bool bltBuracoNegro = false;
  bool bltSparks = false;
  bool isParalised = false;
  bool isFear = false;
  bool rainbowShot = false;
  double masterOrb = 1;

  int vidasNoJarro = 0;
  int fadasNoJarro = 0;

  int numIcons = 0;

  GameSprite? reviveIcon;
  TextComponent? reviveText;
  GameSprite? cuponIcon;
  GameSprite? kineticIcon;
  TextComponent? kineticText;
  GameSprite? dmgBuffIcon;
  GameSprite? dmgGoldBuffIcon;
  GameSprite? ariesIcon;

  // Variáveis de Animação
  double _walkTimer = 0;
  final double _bounceSpeed = 15.0;     
  final double _bounceAmplitude = 0.15; 
  bool animContrario = false;

  double _dustSpawnTimer = 0;
  double _ghostTimer = 0;

  //Familiar? activeDecoy;
  List<Familiar> familiars = [];

  // --- CACHES DE RENDERIZAÇÃO E COMPONENTES ---
  //late GameIcon visual;
  late GameSprite visual;
  late ShadowComponent _shadow;
  late RectangleHitbox _hitbox;
  Color currentColor = Pallete.branco;
  Color classColor = Pallete.branco;
  

  CircleComponent? _dodgeAura;
  double _auraPulseTimer = 0.0;

  MagicShieldEffect? _shieldVisual;
  final Paint _dashBgPaint = Paint()..color = Pallete.preto.withOpacity(0.5);
  final Paint _dashFgPaint = Paint()..color = Pallete.verdeCla;

  //lista de itens
  List<AcquiredItemData> items = [];
  List<CollectibleType> itemsExcluidos = [];
  GameSprite? itemUsadoIcon;
  double itemUsadoTmr = 0;

  bool noDamage = false;

  TimerComponent? bombTmr;

  final ValueNotifier<List<ActiveItemData?>> activeItems = ValueNotifier([null, null]);

  Enemy? target;

  bool superShot = false;
  
  PositionComponent? arma;
  GameSprite? armaVisual;
  double armaAngOffset = 0;
  double armaAng = 0;
  bool armaBalanca = false;

  String classImage = '';
  String armaImage = '';
  Color armaCor = Pallete.branco;

  double _colorTimer = 0;

  //int cargaItem = 5;
  int cargaItem(CollectibleType type) {
    if (type == CollectibleType.activePoisonBomb) return 2; 
    if (type == CollectibleType.activeLicantropia) return 6;    
    if (type == CollectibleType.activeHeal) return 5;   
    if (type == CollectibleType.activeMagicKeyChain) return 5;
    if (type == CollectibleType.activeGift) return 5;
    if (type == CollectibleType.activeHeartConverter) return 5;
    if (type == CollectibleType.activeRitualDagger) return 0;
    if (type == CollectibleType.activeStunBomb) return 3;
    if (type == CollectibleType.activeFairy) return 4;
    if (type == CollectibleType.activeUnicorn) return 6;
    if (type == CollectibleType.activeConvBruta) return 5;
    if (type == CollectibleType.activeBloodBag) return 0;
    if (type == CollectibleType.activeDullRazor) return 2;
    if (type == CollectibleType.activeCircularShots) return 2;
    if (type == CollectibleType.activeDiarreiaExplosiva) return 2;
    if (type == CollectibleType.activeBoxSpider) return 2;
    if (type == CollectibleType.activeD10) return 2;
    if (type == CollectibleType.activeScroll) return 2;
    if (type == CollectibleType.activeGoldenBox) return 0;
    if (type == CollectibleType.activeSlot) return 0;
    if (type == CollectibleType.activeJarroDeVida) return 0;
    if (type == CollectibleType.activeBoxOfFriends) return 3;
    if (type == CollectibleType.activeJarroFadas) return 0;
    if (type == CollectibleType.activeFreezeBomb) return 2;
    if (type == CollectibleType.activeSuperLaser) return 5;
    if (type == CollectibleType.activeBltDetonator) return 1;
    if (type == CollectibleType.activeGoldenrazor) return 0;
    if (type == CollectibleType.activeTurret) return 2;
    if (type == CollectibleType.activeTurretRotate) return 3;
    if (type == CollectibleType.activeGlassStaff) return 1;
    if (type == CollectibleType.activeBuracoNegro) return 4;
    if (type == CollectibleType.activeLoja) return 2;
    if (type == CollectibleType.activeCleaver) return 3;
    if (type == CollectibleType.activeKamikaze) return 0;
    if (type == CollectibleType.activeWoodenCoin) return 1;
    if (type == CollectibleType.cajadoQuebrado) return 5;
    
    return 5; 
  }

  double tempoItem(CollectibleType type) {
    // Retorna os segundos necessários para cada item de tempo
    // if (type == CollectibleType.activeLaserTempo) return 8.0; 
    
    return 5.0; // Padrão: 5 segundos
  }

  Player({required Vector2 position}) : super(size: Vector2.all(16), anchor: Anchor.center) {
    healthNotifier = ValueNotifier<int>(maxHealth);
    artificialHealthNotifier = ValueNotifier<int>(maxArtificialHealth);
    dashNotifier = ValueNotifier<int>(maxDash);
  }
  
  @override
  Future<void> onLoad() async {
    // Cache do visual para acesso instantâneo
    criaVisual();
    
  }


  void criaVisual({reset = false,image = 'sprites/chars/char.png',color = Pallete.branco}){
    if (reset){
      //if(visual != null){
        visual.removeFromParent();
      //}
      //if(_hitbox != null){
        _hitbox.removeFromParent();
      //}
      if(_dodgeAura != null){
        _dodgeAura!.removeFromParent();
      }
      if(_shadow != null){
        _shadow.removeFromParent();
      }
      if(armaVisual != null){
        armaVisual!.removeFromParent();
      }
     
      currentColor = color;
    }

    Vector2 vooOffset = Vector2(0, 0);
    if(voo){
      vooOffset = Vector2(0, -8);
      animContrario = true;
    }    

    visual = GameSprite(
      imagePath: image,
      size: size + Vector2(4,4),
      color: color, 
      anchor: Anchor.center,
      position: size / 2 + vooOffset
    );
    add(visual);
    
    _hitbox=RectangleHitbox(
      size: Vector2(size.x*0.3,size.y*0.7),
      anchor: Anchor.center, 
      position: size / 2 + vooOffset,    
      isSolid: true,
    );
    add(_hitbox);

    _dodgeAura = CircleComponent(
      radius: size.x * 0.7, // Um pouco maior que o corpo do player
      anchor: Anchor.center,
      position: size / 2 + vooOffset, // Fica centralizada no jogador
      priority: -1, // Prioridade negativa para ficar ATRÁS do corpo do player
      paint: Paint()
        ..color = Colors.transparent // Começa invisível
        ..style = PaintingStyle.stroke // Apenas a borda
        ..strokeWidth = 2.0
        // O SEGREDO DO NEON: Um blur filter na pintura!
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
    );
    
    // Para deixar oval/achatado simulando perspectiva 3D isométrica (opcional)
    _dodgeAura!.scale.y = 0.6; 
    
    add(_dodgeAura!);

    _shadow =  ShadowComponent(parentSize: size); 
    add(_shadow);

    if(arma != null && !isLicantropia && !isUnicorn && !isPac){
      armaVisual = GameSprite(
        imagePath: armaImage,
        size: Vector2(16, 16),
        color: armaCor , 
        anchor: Anchor.center,
        position: Vector2(16, 8), 
      );
      armaVisual!.angle = armaAng;

      arma!.add(armaVisual!);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardInput.setZero();
    
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _keyboardInput.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _keyboardInput.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _keyboardInput.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _keyboardInput.x = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      startDash();
    }
    
    if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
      criaBomba();
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyE) && gameRef.onInteractAction!=null) {
      gameRef.onInteractAction!();
    }
    if (keysPressed.contains(LogicalKeyboardKey.numpad1) || keysPressed.contains(LogicalKeyboardKey.digit1)) {
      useActiveSlot(0);
    }
    if (keysPressed.contains(LogicalKeyboardKey.numpad2) || keysPressed.contains(LogicalKeyboardKey.digit2)) {
      useActiveSlot(1);
    }
    if (keysPressed.contains(LogicalKeyboardKey.escape) || keysPressed.contains(LogicalKeyboardKey.keyP)) {
      game.pauseGame();
    }

    
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (gameRef.isGodMode && damage < 100){
      damageIni = damage;
      damage = 100;
    }else if (!gameRef.isGodMode && damage == 100){
      damage = damageIni;
    }

    if (visual != null && isUnicorn) {
        _colorTimer += dt;
        
        if (_colorTimer >= 0.3) {
          
          _colorTimer = 0;

          List<Color> cores=[
            Pallete.vermelho,
            Pallete.azulCla,
            Pallete.verdeCla,
            Pallete.rosa,
            Pallete.lilas,
            Pallete.amarelo,
            Pallete.laranja,
            Pallete.cinzaCla,
            Pallete.branco,
            Pallete.marrom,
            Pallete.bege,
            Pallete.vinho,
            Pallete.verdeEsc,
          ];
          
          final rng = Random();
          Color cor = cores[rng.nextInt(cores.length)];

          visual!.changeColor(cor);
        }
      }

    if(itemUsadoTmr>0){
      itemUsadoTmr -= dt;
    }else{
      if(itemUsadoIcon!=null){
        itemUsadoIcon!.removeFromParent();
        itemUsadoIcon = null;
      }
    }
    
    for (var familiar in familiars) {
      
      if (familiar.parent == null && familiar.retorna) {
        
        gameRef.world.add(familiar);
       
        familiar.position = position.clone() + Vector2(
          (Random().nextDouble() - 0.5) * 40, 
          (Random().nextDouble() - 0.5) * 40
        ); 
      }
    }
    
    if (dashNotifier.value < maxDash){
      if (_dashCooldownTimer > 0) {
        _dashCooldownTimer -= dt;
      } else {
        _dashCooldownTimer = dashCooldown;
        dashNotifier.value++;
      }
    }

    if(isKinetic && kineticStacks> 0){
      if(kineticTimer >=0){
        kineticTimer -= dt;
      }else{
        kineticStacks --;
        kineticTimer = 3.0;
        kineticText?.text = kineticStacks.toString();
      }
    }else{
        if (kineticText != null) {
          kineticText!.removeFromParent();
          kineticText = null;
        }
        if (kineticIcon != null) {
          numIcons --;
          kineticIcon!.removeFromParent();
          kineticIcon = null; 
        }  
    }

    if (isDashing) {
      _handleDashMovement(dt); 
    } else {
      _handleMovement(dt);    
    }
    if (_dodgeAura != null) {
      if (isDashing && isDashDamages) {
        _auraPulseTimer += dt * 30; // Velocidade do pulso
        
        // Faz a aura pulsar de tamanho usando uma onda Senoide (Sin)
        double pulse = 1.0 + (sin(_auraPulseTimer) * 0.2);
        _dodgeAura!.scale.x = pulse;
        _dodgeAura!.scale.y = pulse * 0.6; // Mantém o achatamento isométrico

        // Pinta a aura com a cor da classe atual (ou usa um Azul/Ciano genérico)
        Color auraColor =  Pallete.branco;
        _dodgeAura!.paint.color = auraColor.withOpacity(0.8);
        
      } else {
        // Se não está no dash, a aura fica invisível
        _dodgeAura!.paint.color = Colors.transparent;
        _auraPulseTimer = 0.0;
      }
    }
    _animateMovement(dt);
    if(!isUnicorn && !isBomber && !isPac)_handleAutoAttack(dt);
    _handleInvincibility(dt);
    _keepInBounds(); 
    _handleLicantropia(dt);
    _handleUnicorn(dt);
    _handlePacmen(dt);

    if (healthNotifier.value <= 0 && shieldNotifier.value <= 0 && gameRef.isGodMode == false) {
      _die();
    }

    if (bombButtonTimer > 0) bombButtonTimer -= dt;

    priority = position.y.toInt();

    if(bombTimer > 0){
      bombTimer -= dt;
    }else{
      if(bombTmr!=null){
        bombTmr!.removeFromParent();
      }
    }

    final currentActives = activeItems.value;
    if (currentActives[0] != null && currentActives[0]!.rechargeType == RechargeType.time) {
      // Se não está pronto, o tempo corre!
      if (currentActives[0]!.currentCharge < currentActives[0]!.maxCharge) {
        currentActives[0]!.currentCharge += dt;
        
        // Garante que não passe do limite
        if (currentActives[0]!.currentCharge >= currentActives[0]!.maxCharge) {
          currentActives[0]!.currentCharge = currentActives[0]!.maxCharge;
          // Opcional: Tocar um som de 'Item Pronto' aqui!
        }
        
        // Força a HUD a desenhar a bordinha crescendo copiando a lista
        activeItems.value = List.from(currentActives);
      }
    }

  }

  void ativaLicantropia(){
    if(isLicantropia) return;
    isLicantropia = true;
    animContrario = false;

    bltImage = 'sprites/projeteis/arranhao.png';

    criaVisual(reset:true,image: 'sprites/chars/licantropo.png',color : Pallete.marrom);
    
  }

  void _handleLicantropia(double dt){
    if (isLicantropia){
      licantropiaTmr += dt;
      if (licantropiaTmr >= 10){
        isLicantropia = false;
        criaVisual(reset:true,image: classImage,color : classColor);
        bltImage = bltImageIni;
      }
    }
  }

  void ativaPacmen(){
    if(isPac) return;
    pacTmr = 0;
    isPac = true;
    animContrario = false;
    _isInvincible = true;

    criaVisual(reset:true,image: 'sprites/chars/pac.png',color : Pallete.amarelo); 

    gameRef.world.add(FloatingText(
      text: "PAC PAC PAC!!",
      position: position.clone(), 
      color: Pallete.branco,
      fontSize: 12,
    ));
  }
  void _handlePacmen(double dt){
    if (isPac){
      pacTmr += dt;
      if (pacTmr >= 6){
        isPac = false;
        _isInvincible = false;
        criaVisual(reset:true,image: classImage,color : classColor);
      }
    }
  }

  void ativaUnicorn({bool taurus = false}){
    unicornTmr = 0;
    if(isUnicorn){
      return;
    } 
    isUnicorn = true;
    animContrario = false;
    _isInvincible = true;

    criaVisual(reset:true,image: taurus? 'sprites/chars/minotauro.png' : 'sprites/chars/unicorn.png',color : Pallete.laranja); 
  }
  void _handleUnicorn(double dt){
    if (isUnicorn){
      unicornTmr += dt;
      if (unicornTmr >= 10){
        isUnicorn = false;
        _isInvincible = false;
        criaVisual(reset:true,image: classImage,color : classColor);
      }
    }
  }

 ActiveItemData? equipActiveItem(CollectibleType newItem, double? incomingCharge) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    ActiveItemData? droppedData; 

    bool isRoom = isItemRecarregavel(newItem);
    bool isTime = isItemRecarregavelTempo(newItem);

    // Se for item de Slot 0 (Sala OU Tempo)
    if (isRoom || isTime) {
      if (currentItems[0] != null) droppedData = currentItems[0];
      
      // Puxa do dicionário certo dependendo do tipo
      double max = isTime ? tempoItem(newItem) : cargaItem(newItem).toDouble(); 
      double chargeToSet = incomingCharge ?? max; 

      // Se tem bateria, e é item de sala de carga 1
      if (hasBattery && max == 1 && isRoom) {
        chargeToSet = 0;
        max = 0;
      }
      
      currentItems[0] = ActiveItemData(
        type: newItem, 
        currentCharge: chargeToSet, 
        maxCharge: max,
        rechargeType: isTime ? RechargeType.time : RechargeType.room
      );
      
    } else if (isItemUsoUnico(newItem)) {
      if (currentItems[1] != null) droppedData = currentItems[1];
      currentItems[1] = ActiveItemData(
        type: newItem, 
        currentCharge: 1, 
        maxCharge: 1, 
        rechargeType: RechargeType.singleUse
      );
    }

    activeItems.value = currentItems;
    return droppedData;
  }

  void useActiveSlot(int slotIndex) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    final itemData = currentItems[slotIndex];

    // Só usa se existir e estiver com a carga completa!
    if (itemData != null && itemData.isReady) {
      final atributos = Collectible.getAttributes(itemData.type); 
      
      final String icone = atributos['icon'] as String;
      final Color cor = atributos['color'] as Color;
      if(itemUsadoIcon == null){
        itemUsadoIcon = GameSprite(
          imagePath: 'sprites/itens/$icone.png',
          color: cor,
          size: size,
          anchor: Anchor.center,
          position: Vector2(size.x / 2, - size.y / 4 - 8), 
        );
        add(itemUsadoIcon!);
        itemUsadoTmr = 1;
      }
      final feedback = CollectibleLogic.applyEffect(type: itemData.type, game: gameRef);
      bool foiSucesso = feedback['sucesso'] ?? true;
    /*  String feedbackText = feedback['text'] as String;
      Color feedbackColor = feedback['color'] as Color;

    // 3. Feedback Visual Final
    if (feedbackText.isNotEmpty) {
      gameRef.world.add(FloatingText(
        text: '${feedbackText.tr()}!',
        position: position.clone() + Vector2(0,-size.y/2), 
        color: feedbackColor,
        fontSize: 12,
      ));
    }
    */

      if (slotIndex == 0) {
        if (foiSucesso) {
          // --- LÓGICA DE CONSERTO CORRIGIDA ---
          if (itemData.type == CollectibleType.cajadoQuebrado) {
            
            // 1. Pegamos o valor de tempo do cajado original
            double tempoMax = tempoItem(CollectibleType.activeGlassStaff);

            // 2. Criamos o novo objeto com a flag de TEMPO
            currentItems[0] = ActiveItemData(
              type: CollectibleType.activeGlassStaff, 
              currentCharge: tempoMax, // Já nasce carregado
              maxCharge: tempoMax,
              rechargeType: RechargeType.time // OBRIGATÓRIO para ativar o motor de tempo
            );
            
            gameRef.world.add(FloatingText(
              text: "Consertado!",
              position: position.clone() + Vector2(0, -size.y/2), 
              color: Pallete.verdeCla,
              fontSize: 12,
            ));
            
          } else {
            // Comportamento para itens normais (Zera a carga de sala)
            itemData.currentCharge = 0.0; 
          }
        }
      } else if (slotIndex == 1) {
        // Destrói o de uso único
        if (foiSucesso) currentItems[1] = null;
      }
      activeItems.value = currentItems;
    }
  }

  void _quebrarItemDeVidro() {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    
    gameRef.world.add(FloatingText(
      text: "quebrado".tr(),
      position: position.clone() + Vector2(0, -size.y/2), 
      color: Pallete.verdeCla,
      fontSize: 12,
    ));
    
    currentItems[0] = ActiveItemData(
      type: CollectibleType.cajadoQuebrado,
      currentCharge: 0.0,
      maxCharge: cargaItem(CollectibleType.cajadoQuebrado).toDouble(),
      rechargeType: RechargeType.room,
    );
    
    activeItems.value = currentItems;
    
    gameRef.world.add(FloatingText(
      text: "quebrado".tr(),
      position: position.clone() + Vector2(0, -size.y/2), 
      color: Pallete.vermelho,
      fontSize: 12,
    ));
    
    superShot = false; 
  }

  void rechargeActiveItem({bool full = false}) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    if (currentItems[0] == null || currentItems[0]!.rechargeType == RechargeType.time) return;
    int val = 1;
    if(hasBattery) val = 2;
    if(full) val = cargaItem(currentItems[0]!.type);
    // Se tem item no slot 0 e ele NÃO está pronto, carrega +1
    if (currentItems[0] != null && !currentItems[0]!.isReady) {
      currentItems[0]!.currentCharge+= val;
      activeItems.value = currentItems; // Dispara a atualização visual na HUD
    }
  }

  void useRandomActiveItem() {
    final rng = Random();
    
    final List<CollectibleType> activeItemsPool = [
      //recarregaveis
      CollectibleType.activePoisonBomb, 
      CollectibleType.activeLicantropia, 
      CollectibleType.activeHeal, 
      CollectibleType.activeMagicKeyChain,
      CollectibleType.activeGift,
      CollectibleType.activeHeartConverter,
      CollectibleType.activeRitualDagger,
      CollectibleType.activeConvBruta,
      CollectibleType.activeMagicMirror,
      CollectibleType.activeMidas,
      CollectibleType.activeStunBomb,
      CollectibleType.activeFairy,
      CollectibleType.activeUnicorn,
      CollectibleType.activeBombardeio,
      CollectibleType.activeTurret,
      CollectibleType.activeCircularShots,
      CollectibleType.activeRandPill,
      CollectibleType.activeDiarreiaExplosiva,
      CollectibleType.activeBloodBag,
      CollectibleType.activeDullRazor,
      CollectibleType.activeBoxSpider,
      CollectibleType.activeD10,
      CollectibleType.activeScroll,
      CollectibleType.activeGoldenBox,
      CollectibleType.activeSlot,
      CollectibleType.activeJarroDeVida,
      CollectibleType.activeBoxOfFriends,
      CollectibleType.activeJarroFadas,
      CollectibleType.activeFreezeBomb,
      CollectibleType.activeSuperLaser,
      CollectibleType.activeBltDetonator,
      CollectibleType.activeGoldenrazor,
      CollectibleType.activeTurretRotate,
      CollectibleType.activeGlassStaff,
      CollectibleType.activeBuracoNegro,
      CollectibleType.activeLoja,
      CollectibleType.activeCleaver,
      CollectibleType.activeKamikaze,
      CollectibleType.activeWoodenCoin,
      //uso unico
      CollectibleType.sanduiche,
      CollectibleType.cupon,  
      CollectibleType.activeBattery,
      CollectibleType.activeArtHp,
      CollectibleType.activeMagicKey,
      CollectibleType.activeHoming,
      CollectibleType.activeD6,
      CollectibleType.activeDivineShield,
      CollectibleType.activeRerollItem,
      CollectibleType.activeBandage,
      CollectibleType.activeUnicornUnico,
      CollectibleType.activeBombardeioUnico,
      CollectibleType.activeTurretUnico,
      CollectibleType.activeSuborno,
      CollectibleType.keysToBombs,
      CollectibleType.activeRandPillUnico,
      CollectibleType.portalBoss,
      CollectibleType.activeFear,
      CollectibleType.activePacmen,
      CollectibleType.activePa,
      CollectibleType.activeDupliItem,
      CollectibleType.activeSacrifFamiliar,
      CollectibleType.activeRestart,
      CollectibleType.activeNuke,
    ];

    final effectDrawn = activeItemsPool[rng.nextInt(activeItemsPool.length)];

    final feedback = CollectibleLogic.applyEffect(type: effectDrawn, game: gameRef);
      String feedbackText = feedback['text'] as String;
      Color feedbackColor = feedback['color'] as Color;

    if (feedbackText.isNotEmpty) {
      gameRef.world.add(FloatingText(
        text: feedbackText.tr(),
        position: position.clone() - size/2, 
        color: feedbackColor,
        fontSize: 12,
      ));
    }
  }

  void applyClass(CharacterClass charClass) {

      maxHealth = charClass.maxHp;
      maxDash = charClass.maxDash;
      healthNotifier.value = maxHealth;
      shieldNotifier.value = charClass.startingShield;
      bombNotifier.value = charClass.startingBombs;
      game.keysNotifier.value = charClass.startingKeys;
      
      moveSpeed = charClass.speed;
      moveSpeedIni = charClass.speed;
      damage = charClass.damage;
      damageIni = charClass.damage;
      fireRate = charClass.fireRate;
      fireRateIni = charClass.fireRate;
      critChance = charClass.critChance;
      critChanceIni = charClass.critChance;
      critDamage = charClass.critDamage;
      critDamageIni = charClass.critDamage;
      attackRange = charClass.attackRange;
      attackRangeIni = charClass.attackRange;
     // _rangeIndicator.radius = attackRange;
      dashCooldown = charClass.dashCooldown;
      dot = charClass.dot;
      //dotIni = charClass.dot;
      stackBonus = charClass.stackBonus;

      isShotgun = charClass.isShotgun;
      isBomber = charClass.isBomber;

      noDamage = charClass.noDamage;

      itemsExcluidos = charClass.itemsExcluidos;
      bltImage = charClass.bltImage;
      bltImageIni = charClass.bltImage;
      bltSize = charClass.bltSize;
      bltSpeed = charClass.bltSpeed;

      armaBalanca = charClass.armaBalanca;


      for (var itemType in charClass.startingItems) {

        if (isItemAtivo(itemType)) {
          equipActiveItem(itemType, null); 
        } 
        else {
          
          CollectibleLogic.applyEffect(type: itemType, game: gameRef);

          final List<CollectibleType> consumiveis = [
            CollectibleType.coin, CollectibleType.potion, CollectibleType.sanduiche,
            CollectibleType.key, CollectibleType.keys, CollectibleType.bomba, 
            CollectibleType.bombas, CollectibleType.healthContainer
          ];

          if (!consumiveis.contains(itemType)) {
            final attrs = Collectible.getAttributes(itemType);
            
            setAcquiredItemsList(
              itemType,
              attrs['name'] as String,
              attrs['desc'] as String,
              attrs['icon'] as String,
              attrs['color'] as Color,
            );
          }
        }
      }

      classImage = 'sprites/chars/${charClass.id}.png';
      classColor = charClass.color;
      if(charClass.id == 'licantropo'){
        classImage = 'sprites/chars/char.png';
        classColor = Pallete.branco;
      }

      criaVisual(reset : true,image : classImage,color : classColor);

      if (armaVisual != null) {
          armaVisual!.removeFromParent();
          armaVisual = null;
      }

      armaAngOffset = 0;

      if (charClass.weaponImage != '') {
        armaImage = charClass.weaponImage;
        armaCor = charClass.armaCor;
        armaAng = charClass.armaAngOffset;
        if (arma != null && arma!.isMounted) {
          arma!.removeFromParent();
        }

        arma = PositionComponent(
          size: Vector2(16, 16),
          anchor: Anchor.center,
          priority: 100,
        );

        armaVisual = GameSprite(
          imagePath: armaImage,
          size: Vector2(16, 16),
          color: armaCor , 
          anchor: Anchor.center,
          position: Vector2(16, 8), 
        );
        armaVisual!.angle = armaAng;

        arma!.add(armaVisual!);

        gameRef.world.add(arma!);
      }
    }

  void activateShield() {
    if (hasShield) return; 

    hasShield = true;
    _shieldVisual = MagicShieldEffect(size: size);
    add(_shieldVisual!);
  }

  void _breakShield() {
    hasShield = false;
    _shieldVisual?.removeFromParent();
    _shieldVisual = null;
  }

  void _animateMovement(double dt) {
    double facingDirection = visual.scale.x.sign; 
    if (velocity.x < -0.1) facingDirection = -1.0;
    if (velocity.x > 0.1) facingDirection = 1.0;

    double bSpeed = voo ? _bounceSpeed/2 : _bounceSpeed;

    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

    bool anim = false;

    if(animContrario){
      if(velocity.isZero())anim = true;
    }else{
      if(!velocity.isZero())anim = true;
    }
    if (anim) {
      _walkTimer += dt * bSpeed;

      double wave = sin(_walkTimer);
      currentScaleY = 1.0 + (wave * _bounceAmplitude); 
      currentScaleX = 1.0 - (wave * _bounceAmplitude * 0.5); 
      currentAngle = cos(_walkTimer) * 0.1; 
      
    } else {
      _walkTimer = 0;
      if(voo){
        if(facingDirection > 0){
          currentAngle = pi/8;
        }else{
          currentAngle = -pi/8;
        }
        
      }
    }

    visual.scale.setValues(facingDirection * currentScaleX, currentScaleY);
    visual.angle = currentAngle; 

    if (arma != null) {
      if (!arma!.isMounted && isMounted) {
        gameRef.world.add(arma!);
      }
      
      arma!.scale.y = currentScaleY; 
      Vector2 vooOffsetAtual = voo ? Vector2(0, -8) : Vector2(0, 0);

      arma!.position = absoluteCenter + vooOffsetAtual;

      bool atacandoParaEsquerda = lastAttackDirection.x < 0;

      if (atacandoParaEsquerda) {
        arma!.scale.x = -currentScaleX.abs(); 
        arma!.angle = atan2(-lastAttackDirection.y, -lastAttackDirection.x) - armaAngOffset;
        if(atan2(lastAttackDirection.y, lastAttackDirection.x)<pi/2){
          arma!.priority = priority - 1;
        }else{
          arma!.priority = priority + 1;
        }
      } else {
        arma!.scale.x = currentScaleX.abs(); 
        arma!.angle = atan2(lastAttackDirection.y, lastAttackDirection.x) + armaAngOffset;
        if(atan2(lastAttackDirection.y, lastAttackDirection.x)>pi/2){
          arma!.priority = priority - 1;
        }else{
          arma!.priority = priority + 1;
        }
      }
      
    }
  }

  void _handleMovement(double dt) {
    double baseLimit = moveSpeed;
    if (isLicantropia || isUnicorn) baseLimit = moveSpeed * 1.5;

    bool hasTaurus = (zodiacTaurus || tempZodiacTaurus) && !isUnicorn;
    double taurusLimit = moveSpeedIni * 2.0;
    
    double absoluteMaxSpeed = hasTaurus ? taurusLimit : baseLimit;

    Vector2 input = Vector2.zero();
    if (gameRef.joystickDelta != Vector2.zero()) {
       input.setFrom(gameRef.joystickDelta);
    } else if (_keyboardInput != Vector2.zero()) {
       input.setFrom(_keyboardInput);
       input.normalize();
    }

    if (input.isZero()) {
      velocity.setZero(); 
    } else {
      double currentSpeed = velocity.length;
      
      double currentAcc = acceleration; 

      if (hasTaurus && currentSpeed >= baseLimit) {
        currentAcc = acceleration * 0.1; 
      }

      currentSpeed += currentAcc * dt;

      if (currentSpeed > absoluteMaxSpeed) {
        currentSpeed = absoluteMaxSpeed;
      }

      velocity = input.normalized() * currentSpeed;
    }

    bool isMoving = velocity.length > 10.0;

    if (isMoving) {
      velocityDash.setFrom(velocity.normalized() * absoluteMaxSpeed);
      
      _handleDustEffect(dt);
      if(isLicantropia || isUnicorn) _createGhostEffect(dt);
      if(criaPocaVeneno || zodiacAquarius || tempZodiacAquarius) _createHazard(dt); 
      if(isConcentration) fireRate = fireRateIni * 1.15;
    } else {
      if(isConcentration) fireRate = fireRateIni * 0.5;
    }

    double speedForTrigger = baseLimit;
    double speedForTriggerTaurus = taurusLimit;
    
    position.addScaled(velocity, dt);

    if(velocity.length >= speedForTriggerTaurus - dt && zodiacTaurus || tempZodiacTaurus){
      if(!zodiacTaurusTransf){
        zodiacTaurusTransf = true;
        gameRef.world.add(FloatingText(
          text: "TAURUS",
          position: position.clone(), 
          color: Pallete.branco,
          fontSize: 12,
        ));
        if(isUnicorn)isUnicorn = false;
        ativaUnicorn(taurus: true);
      }
    }

    if (velocity.length >= speedForTrigger - dt) {
      velMax = true;
      if(zodiacAries){
        if (ariesIcon == null) {
          numIcons ++;
          ariesIcon = GameSprite(
            imagePath: 'sprites/condicoes/aries.png',
            color: Pallete.azulCla,
            size: size/2,
            anchor: Anchor.center,
            position: Vector2(size.x / 2, - size.y / 4 - 10*numIcons), 
          );
          add(ariesIcon!);
        }
      }
      
    } else {
      velMax = false;
      if(zodiacAries){
        if (ariesIcon != null) {
         ariesIcon!.removeFromParent();
         ariesIcon = null;
         numIcons --; 
        }
      }
    }
  }

  void startDash() {
    if (dashNotifier.value <= 0 || isDashing) return;
    dashNotifier.value--;
    isDashing = true;

    if(isKinetic){
      kineticStacks++;
      kineticTimer = 3.0;

      if(kineticIcon == null){
        numIcons ++;
        kineticIcon = GameSprite(
          imagePath: 'sprites/condicoes/espada.png',
          color: Pallete.verdeCla,
          size: size/2,
          anchor: Anchor.center,
          position: Vector2(size.x / 2, - size.y / 4 - 14* numIcons), 
        );
        add(kineticIcon!);
      }
      if (kineticText == null){
        kineticText = TextComponent(
          text: kineticStacks.toString(),
          position: Vector2((size.x/2) - 12, - size.y / 4 - 10*numIcons),
          anchor: Anchor.center,
          textRenderer: TextPaint(
            style: const TextStyle(
              color: Pallete.verdeCla,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        add(kineticText!);
      }
      kineticText?.text = kineticStacks.toString();
    }

    if(isFreezeDash){
      gameRef.world.add(Explosion(
                          position: position, 
                          damagesPlayer:false, 
                          radius:150, 
                          owner: this,
                          isFreeze: true,
                          cor: Pallete.branco.withAlpha(50),
                          corBorda: Pallete.azulCla.withAlpha(50),
                        ));
    }

    AudioManager.playSfx('dash.mp3');

    _dashTimer = dashDuration;
    _dashCooldownTimer = dashCooldown;

    // Normalização sem gerar lixo
    _dashDirection.setFrom(velocityDash);
    _dashDirection.normalize();
  
    _isInvincible = true; 
  }

  void _handleDustEffect(double dt){
    _dustSpawnTimer -= dt;
    if (_dustSpawnTimer <= 0) {
      _dustSpawnTimer = 0.05; 
      
      var offset = Vector2(0, size.y / 2);
      gameRef.world.add(Dust(
        position: position + offset,
      ));
    }
  }

  void _createGhostEffect(double dt) {
    _ghostTimer += dt;
    if (_ghostTimer >= 0.025) {
      gameRef.world.add(
        GhostParticle(
          imagePath: visual.imagePath,
          color: currentColor.withOpacity(0.3),
          position: position.clone(), 
          size: size,
          anchor: anchor,
          scale: visual.scale.clone(), // Clonado para não linkar referências
        ),
      );
      _ghostTimer = 0;
    }
    
  }

  void _createHazard(double dt,{bool isFire = false, bool isVeneno = true,bool isGelo = false,bool isBlood = false,double tmp = 0.1}) {
    criaHazardTmr += dt;
  
    if (criaHazardTmr >= tmp) {
      if(zodiacAquarius || tempZodiacAquarius){
        gameRef.world.add(
          PoisonPuddle(
            position: position.clone() + Vector2(0, size.y/2), 
            isPlayer: true,
            isAquarius: true,
            isFire: isBurn,
            isPoison: isPoison,
            isFreeze: isFreeze,
            isBleed: isBleed,
            size: Vector2.all(10)
          ),
        );
      }else{
        gameRef.world.add(
        PoisonPuddle(
            position: position.clone() + Vector2(0, size.y/2), 
            isPlayer: true,
            isFire: isFire,
            isPoison: isVeneno,
            isFreeze: isGelo,
            isBleed: isBlood
          ),
        );
      }
      
      criaHazardTmr = 0;
    }
  }

  void _handleDashMovement(double dt) {
    _dashTimer -= dt;
    _createGhostEffect(dt);
    if(fireDash)_createHazard(dt, isFire: true, tmp: 0.025);
    if(zodiacAquarius || tempZodiacAquarius) _createHazard(dt); 
    position.addScaled(_dashDirection, dashSpeed * dt);

    if (_dashTimer <= 0) {
      isDashing = false;
      _isInvincible = false; 
    }
  }

  void _keepInBounds() {
    double limitX = TowerGame.gameWidth/2 - _hitbox.size.x;
    double limitY = TowerGame.gameHeight/2 - _hitbox.size.y;
    double arenaBorder = 4;

    position.x = position.x.clamp(-limitX + arenaBorder * 3, limitX + arenaBorder);
    position.y = position.y.clamp(-limitY + arenaBorder, limitY + arenaBorder);
  }

/*
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    
  }
*/
  void takeDamage(int amount,{bool roubaMoeda = false,bool pulaEscudo = false}) {
    final rng = Random();
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    if (currentItems[0] != null && currentItems[0]!.type == CollectibleType.activeGlassStaff){
      _quebrarItemDeVidro();
      if(healthNotifier.value == 1){ 
        _isInvincible = true;
        _invincibilityTimer = invincibilityDuration;
      }
      return;
    }

    if(_isInvincible || isDashing) return;

    if(evasao){
      if(rng.nextDouble() <= 0.2) return;
    }
    gameRef.shakeCamera(intensity: 4.0, duration: 0.15);
    gameRef.triggerHitStop(0.05);
    if(explodeHit){
      gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:false, damage:30, radius:60));
    }

    if(roubaMoeda && gameRef.coinsNotifier.value > 0) collectCoin(rng.nextInt(10) + 5);

    if(hurtPac && !isUnicorn){
      double chance = 5.0 + (2.5 * sorte);
      if(rng.nextInt(100) <= chance && !isPac){ 
        ativaPacmen();
      }
    }

    if(defensiveFairys){
      final f = Familiar(position: position.clone(),
                          type: FamiliarType.fly, 
                          player: this,
                          // angleOffset: i*(2*pi/5)
                        );
      familiars.add(f);
      game.world.add(f);
    }

    if (hasShield && !pulaEscudo && amount>0) {
      _breakShield(); 
      return; 
    }

    if(retribuicao){
      for (int i = 0; i < 10; i++) {
        double angle = i*(2*pi/10); 
        Vector2 newDir = Vector2(cos(angle), sin(angle));
        criaTiro(damage*1.5,newDir,2,retribuicao: true); 
      }
    }

    if(takeOneDmg) amount = 1;

    if (gameRef.challengeHitsNotifier.value >= 0) {
      
      if (gameRef.challengeHitsNotifier.value < 3) {
        gameRef.challengeHitsNotifier.value++;
      }
    }

    if (shieldNotifier.value > 0 && !pulaEscudo){
      int dano = amount>1? 1: amount;
      shieldNotifier.value-=dano ;
      _isInvincible = true;
      _invincibilityTimer = invincibilityDuration;
      if(defensiveBurst){
        gameRef.world.add(Explosion(position: position.clone(), damage: 0, radius: 500, damagesPlayer: false));
      }
      return;
    }
    if(artificialHealthNotifier.value > 0){
      artificialHealthNotifier.value -= amount;
      
      if (artificialHealthNotifier.value % 2 == 0 ){
        maxArtificialHealth -= 2;
      }
    }else{
      healthNotifier.value -= amount;
    }

    if(zodiacCancer){
      takeOneDmg = true;
    }

    double invTmr = invincibilityDuration;
    if(zodiacVirgo){
      double chance = (1/(10-sorte))*100;
      if(rng.nextInt(100) <= chance) {
        invTmr = 10;
        gameRef.world.add(FloatingText(
          text: "INVINCIBLE",
          position: position.clone(), 
          color: Pallete.branco,
          fontSize: 12,
        ));
      }
    }
    setInvencibility(invTmr);
    
  }

  void _handleInvincibility(double dt) {
    if (_isInvincible) {
      _invincibilityTimer -= dt;
      
      if (_invincibilityTimer % 0.2 < 0.1) {
         visual.changeColor(Pallete.vermelho.withOpacity(0.5));
      } else {
         visual.changeColor(currentColor);
      }

      if (_invincibilityTimer <= 0) {
        _isInvincible = false;
        visual.changeColor(currentColor);
      }
    }
  }

  void setInvencibility(double dur){
    _isInvincible = true;
    _invincibilityTimer = dur;
  }

  void _die() {
    if(revive > 0){
      revive --;
      reviveText?.text = revive.toString();

      if(maxHealth > 2){
        curaHp((maxHealth/2).ceil());
      }else{
        curaHp(maxHealth);
      }
      
    }else{
      if (reviveText != null) {
        reviveText!.removeFromParent();
        reviveText = null; 
      }
      if (reviveIcon != null) {
        reviveIcon!.removeFromParent();
        reviveIcon = null;
        numIcons --;
      }
      AudioManager.playSfx('game_over.mp3');
      gameRef.onGameOver();
    }
  }

  void resetAttackTimer() {
    _attackTimer = 0;
  }

  void _handleAutoAttack(double dt) {
    _attackTimer += dt;
    double fRate = fireRate;
    if (isLicantropia) fRate = fireRate*0.5;
    if (_attackTimer < fRate) return;

    final enemies = gameRef.world.children.query<Enemy>();
    
    double closestDist = double.infinity;//attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (dist < closestDist && !enemy.isCharmed && (!enemy.isIntangivel && !enemy.isInvencivel)) {
        if(target != null) target!.removeTargetIcon();
        closestDist = dist;
        target = enemy;
        enemy.criaTargetIcon();
      }
    }

    if (target != null && !target!.isMounted) {
      target = null;
    }

    if (target != null) {
      _attackTimer = 0;
      if(isMorteiro){
        _tempDirection.setFrom(target!.position);
        lastAttackDirection.setFrom(_tempDirection);
        gameRef.world.add(MortarShell(
          startPos: position.clone(),
          targetPos: target!.position.clone(),
          owner: this,
          flightDuration: 1,
          damage: damage * 2,
          isFire: true,
          explosionRadius: 50,
          isPlayer: true,
          goldShot: goldShot,
        ));
      }else if(isLaser){
        final dir = (target!.position - position.clone()).normalized();
        final angle = atan2(dir.y, dir.x);
        final dist = position.distanceTo(target!.position);
        criaLaser(dir,angle,target,dist);
        _tempDirection.setFrom(target!.position);
        lastAttackDirection.setFrom(_tempDirection);
      }else{
        lastAttackDirection.setFrom(_tempDirection);
        if(clusterShot > -1){
          clusterShot ++;
        }
        if(clusterShot >= 20){
          clusterShot = 0;
          for(var i=0;i<10;i++){
            Vector2 offset = Vector2(-30 + Random().nextInt(60).toDouble(),
                                     -30 + Random().nextInt(60).toDouble());
            gameRef.world.add(Projectile(
            owner: this,
            position: position.clone() + offset, 
            direction: _tempDirection.clone(), 
            damage: damage, 
            speed: 300,
            hbSize: Vector2.all(15),
            dieTimer: attackRange,
            cor : Pallete.vinho,
          ));
          }
        }
        if(isShotgun){
          _shootAt(target!,angleOffset: 0.075);
          _shootAt(target!,angleOffset: -0.075);
          _shootAt(target!,angleOffset: 0.2);
          _shootAt(target!,angleOffset: -0.2);
          if(cardinalShot){
            int rnd = Random().nextInt(100);
            if(rnd <= 25){
              _shootAt(target!,angleOffset: pi/2);
              _shootAt(target!,angleOffset: -pi/2);
              _shootAt(target!,angleOffset: pi);
            }
          }
        }else{
          _shootAt(target!);
          if(superShot)
          {
            superShot = false;
          }
          if(tripleShot){
            _shootAt(target!,angleOffset: 0.2);
            _shootAt(target!,angleOffset: -0.2);
          }
          if(cardinalShot){
            final rnd = Random();
            double chance = (1/(8-sorte))*100;
            if(rnd.nextInt(100) <= chance){
              _shootAt(target!,angleOffset: pi/2);
              _shootAt(target!,angleOffset: -pi/2);
              _shootAt(target!,angleOffset: pi);
            }
          }
        }
      }
      
      if(armaBalanca){
        if(armaAngOffset==-pi/4){
          armaAngOffset = pi/2;
        }else{
          armaAngOffset = -pi/4;
        }
      }
    }else{
      lastAttackDirection.setFrom(velocityDash);
      armaAngOffset = 0;
    }
    
  }


  void criaLaser(Vector2 dir,ang,target,tamanho)
  {
    gameRef.world.add(LaserBeam(
      position: position + (dir * 10),
      angleRad: ang,
      length: tamanho,
      chargeTime: 0,
      fireTime: fireRate,
      target: target,
      owner: this,
      damage: damage
    ));
  }

  void criaLaserDirecional(Vector2 dir,ang,dmg,chargeTime,durTime,largura)
  {
    gameRef.world.add(LaserBeam(
      position: position + (dir * 10),
      angleRad: ang,
      larguraLaser: largura,
      chargeTime: chargeTime,
      fireTime: durTime,
      followsOwnerMov: true,
      owner: this,
      damage: dmg,
      length: 600,
    ));
  }


  double returnDamage(){
    double dmg = damage;

    if(isBerserk && healthNotifier.value <= 2) dmg = dmg * 1.4;
    if(isAudaz && shieldNotifier.value == 0) dmg = dmg * 1.3;
    if(kineticTimer > 0){
      dmg = dmg * (1 + (kineticStacks * 0.15));
    }
    if(isHeavyShot){
       dmg = dmg * 1.3;
    }
    if(tempDmgBonus > 0){
       dmg = dmg * (1+(0.2*tempDmgBonus));
    }
    if(tempDmgGoldBonus > 0){
       dmg = dmg * (1+(0.2*tempDmgGoldBonus));
    }
    if(goldDmg){
      dmg += dmg*0.01*gameRef.coinsNotifier.value;
    }
    if(isBebado){
       dmg = dmg * 1.3;
    }
    if(isLicantropia){
       dmg = dmg * 1.5;
    }
    if(dmgBuff){
      dmg = dmg * 1.5;
    }
    if(adrenalina){
      int hpVazio = ((maxHealth - healthNotifier.value)/2).floor();
      dmg = dmg * (1 + (hpVazio * 0.2));
    }
    if(superShot)
    {
      dmg *= 10;
    }

    return dmg;
  }

  double returnCritChance(){
    double crit = critChance + sorte;

    if(shieldCrit){
      crit += shieldNotifier.value * 5;
    }

    return crit;
  }

  void _shootAt(Enemy target, {double angleOffset = 0}) {
    // Calculo da direção livre de lixo de memória
    _tempDirection.setFrom(target.position);
    _tempDirection.sub(position);
    _tempDirection.normalize();

    double x = _tempDirection.x * cos(angleOffset) - _tempDirection.y * sin(angleOffset);
    double y = _tempDirection.x * sin(angleOffset) + _tempDirection.y * cos(angleOffset);
    _tempDirection.setValues(x, y);

    double dmg = returnDamage();
    double aRange = attackRange;

    if(isBebado){
      double angOffset = Random().nextDouble() * 0.2;
      double x = _tempDirection.x * cos(angOffset) - _tempDirection.y * sin(angOffset);
      double y = _tempDirection.x * sin(angOffset) + _tempDirection.y * cos(angOffset);
      _tempDirection.setValues(x, y);
    }
    if(isLicantropia){
      aRange = aRange * 0.5;
    }
    AudioManager.playSfx('shoot.mp3');
    if(isMineShot){
      gameRef.world.add(Bomb(
        position: position.clone(), 
        damage: dmg*1.5, 
        isMine: true, 
        direction: _tempDirection.clone()));
      return;
    }
    criaTiro(dmg,_tempDirection.clone(),aRange,speed: bltSpeed,img:bltImage);
  }
  void criaTiro(double dmg, Vector2 dir, double aRange, {double speed = 300, String img = 'sprites/projeteis/blt.png', bool retribuicao = false}){
    final rnd = Random();
    bool isAdaga = false;
    bool isFireHazard = false;
    bool isBuracoNegro = false;

    double adagaCha = (1/(15-sorte))*100;
    double fireHazChance = min((1/(12-sorte))*100,50);
    double buracoNegroChance = min((1/(20-sorte))*100,20);

    if(rnd.nextInt(100) <= adagaCha && adagaChance){
      isAdaga = true;
      dmg *= 4;
    }

    if(rnd.nextInt(100) <= fireHazChance && bltFireHazard){
      isFireHazard = true;
    }


    if(rnd.nextInt(100) <= buracoNegroChance && bltBuracoNegro){
      isBuracoNegro = true;
    }

    bool tempBurn = false;
    bool tempPoison = false;
    bool tempCharm = false;
    bool tempHoming = false;
    bool tempFreeze = false;
    bool tempParalise = false;
    bool tempFear = false;

    Color cor = Pallete.preto;
    if(rainbowShot){
      int effectRoll = rnd.nextInt(8);
      switch(effectRoll){
        case 0:
          tempBurn = true;
          cor = Pallete.laranja;
          break;
        case 1:
          tempPoison = true;
          cor = Pallete.verdeCla;
          break;
        case 2:
          tempCharm = true;
          cor = Pallete.rosa;
          break;
        case 3:
          tempHoming = true;
          cor = Pallete.lilas;
          break;
        case 4:
          tempFreeze = true;
          cor = Pallete.azulCla;
          break;
        case 5:
          tempParalise = true;
          cor = Pallete.marrom;
          break;
        case 6:
          tempFear = true;
          cor = Pallete.cinzaEsc;
          break;
        case 7:
          break;
      }

    }
    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: dir, 
      damage: retribuicao? dmg : noDamage? 0.0 : dmg, 
      speed: isOrbitalShot ? 4.0 : isHeavyShot ? speed/2 : isWave ? speed * 0.75 : isSaw ? speed/10 : speed,
      hbSize: superShot? Vector2.all(bltSize* 5) : Vector2.all(bltSize),
      size: superShot? Vector2.all(16 * 5) : Vector2.all(16),
      image:isAdaga? 'sprites/projeteis/faca.png' : img ,
      dieTimer: isBoomerang ? 1.0 : isOrbitalShot ? 2 : isSaw ? aRange*1.5 : aRange,
      apagaTiros: hasAntimateria,
      isHoming: tempHoming ||isHoming || isHomingTemp,
      iniPosition: position.clone(),
      canBounce: canBounce,
      isSpectral: isSpectral,
      isPiercing: isPiercing || tempPiercing,
      isOrbital: isOrbitalShot,
      isBoomerang: isBoomerang,
      splits: isShootSplits,
      splitCount: Random().nextInt(3) + 1,
      goldShot: goldShot,
      isWave: isWave,         // <-- Transforma em onda!
      maxRadius: 150,       // <-- Tamanho máximo
      growthRate: 100,      // <-- Velocidade de expansão
      sweepAngle: pi / 1.5, // <-- Quase um semicírculo de largura!
      isSaw: isSaw,
      knockbackForce: knockbackForce,
      isAdaga: isAdaga,
      fireHazzard: isFireHazard,
      buracoNegro: isBuracoNegro,
      isSpark: bltSparks,
      isParalised:tempParalise || isParalised? Random().nextInt(100) <= min((1/(5-(sorte * 0.15)))*100, 50)? true:false : false,
      isFreeze:tempFreeze || isFreeze? Random().nextInt(100) <= (1/(4 - (sorte / 5)))*100? true:false : false,
      isFear: tempFear || isFear? Random().nextInt(100) <= (15/(100 - sorte ))*100? true:false : false,
      isBleed: isBleed,
      isPoison:tempPoison || isPoison,
      isBurn: tempBurn || isBurn,
      isCharm: tempCharm,
      cor:cor,
    ));
  }

  void criaBomba({bool semCusto = false}){
    if(!gameRef.usouBomba)gameRef.usouBomba = true;
    if(bombButtonTimer>0 && !semCusto) return;
    bombButtonTimer = 0.5;
    if (bombNotifier.value > 0 || isBomber || semCusto){
      if(!isBomber)bombNotifier.value--;
      gameRef.world.add(Bomb(
        position: position.clone(), 
        damage:damage*5, 
        owner: this, 
        splits: isBombSplits,
        isDecoy: isBombDecoy,
        isGlitterBomb: isGlitterBomb,
        isBuracoNegro: bombaBuracoNegro,
      ));
    } else {
      gameRef.world.add(FloatingText(
        text: "Sem Bombas",
        position: position.clone(), 
        color: Pallete.branco,
        fontSize: 12,
      ));
    }
  }

  void reset() {
    size = Vector2.all(16);
    maxHealth = 4;
    healthNotifier.value = 4;
    maxArtificialHealth = 0;
    artificialHealthNotifier.value = 0;
    shieldNotifier.value = 0;
    maxDash = 2;
    dashNotifier.value = 2;
    _dashCooldownTimer = 0;
    _isInvincible = false;
    _invincibilityTimer = 0;
    velocity.setZero();
    bombNotifier.value = 0;
    attackRange = 1.0; 
    _attackTimer = 0;
    damage = 10.0;
    knockbackForce = 0;
    sorte = 0;
    critChance = 5;
    critDamage = 2.0;
    fireRate = 0.4; 
    fireRateIni = 0.4;
    moveSpeed = 75.0;
    dashDuration = 0.3; 
    dashSpeed = 275;    
    dashCooldown = 2.5; 
    invincibilityDuration = 0.5;
    isBerserk = false;
    isAudaz = false;
    isFreeze = false;
    isBebado = false;
    hasOrbShield = false;
    hasFoice = false;
    magicShield = false;
    hasShield = false;
    revive = 0;
    pegouRevive = false;
    hasAntimateria = false;
    isHoming = false;
    canBounce = false;
    isPiercing = false;
    isSpectral = false;
    stackBonus = 0;
    isBurn = false;
    isPoison = false;
    isPoisonAlastra = false;
    hasChaveNegra = false;
    isConcentration = false;
    isOrbitalShot = false;
    isMineShot = false;
    defensiveBurst = false;
    isKinetic = false;
    isHeavyShot = false;
    hasCupon = false;
    isBoomerang = false;
    isBleed = false;
    criaPocaVeneno = false;
    isShotgun = false;
    fireDash = false;
    isDashDamages = false;
    isMorteiro = false;
    hasBattery = false;
    hasShieldRegen = false;
    items = [];
    familiars = [];
    isShootSplits = false;
    confuseOnCrit = false;
    isBombSplits = false;
    isBombDecoy = false;
    tempDmgBonus = 0;
    tempDmgGoldBonus = 0;
    regenCount = 0;
    activeItems.value = [null, null];
    charmOnCrit = false;
    isFreezeDash = false;
    goldDmg = false;
    shieldCrit = false;
    isCritHeal = false;
    isLaser = false;
    isWave = false;
    isSaw = false;
    noDamage = false;
    explodeHit = false;
    restock = false;
    encolheOnCrit = false;
    isGlitterBomb = false;
    bombaBuracoNegro = false;
    goldShot = false;
    clusterShot = -1;
    evasao = false;
    primeiroInimigoPocaVeneno = false;
    adrenalina = false;
    eutanasia = false;
    killCharge = -1;
    voo = false;
    cardinalShot = false;
    animContrario = false;
    hurtPac = false;
    zodiacAquarius = false;
    zodiacAries = false;
    zodiacCancer = false;
    zodiacLeo = false;
    zodiacVirgo = false;
    zodiacLibra = false;
    zodiacPisces = false;
    zodiacTaurus = false;
    zodiac = false;
    defensiveFairys = false;
    itemExtraBoss = false;
    retribuicao = false;
    refletirChance = false;
    adagaChance = false;
    glifoEquilibrio = false;
    bltFireHazard = false;
    bltBuracoNegro = false;
    bltSparks = false;
    isParalised = false;
    isFear = false;
    rainbowShot = false;
    masterOrb = 1;
    armaImage = '';
    armaAng = 0;
    armaCor = Pallete.branco;
    classColor = Pallete.branco;
    classImage = '';

    criaVisual(reset:true);
    visual.changeColor(Pallete.branco);
  }

   @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Enemy && !other.isIntangivel  && !other.isCharmed) {
      if( isUnicorn || isDashing && isDashDamages || other.encolhido || isPac || zodiacAries && velMax){
        double dmg = (isUnicorn || isPac)? damage*2 : damage;
        other.takeDamage(dmg);
        other.setKnockBack(this);
      }
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall || other is Door || other is UnlockableItem) {
      _handleWallCollision(intersectionPoints, other);
      if(other is Wall && zodiacLeo){
        other.die();
      }
    }
    if (other is Enemy && !other.isIntangivel  && !other.isCharmed && other.hp>0 &&
     !(isUnicorn || isDashing && isDashDamages || other.encolhido || isPac || zodiacAries && velMax)) {
      int danoIni = 1;
      if(other.isBoss || other.championType>0) danoIni = 2;
      takeDamage(danoIni);
      if(other.championType == 6){
        if (gameRef.coinsNotifier.value > 0)
        {
          collectCoin(-5);
          gameRef.world.add(FloatingText(
          text: "-5\$",
          position: position.clone(), 
          color: Pallete.branco,
          fontSize: 12,
        ));
          if (gameRef.coinsNotifier.value < 0){
            gameRef.coinsNotifier.value = 0;
          }
        }
        
      }
    }
  }

  void _handleWallCollision(Set<Vector2> points, PositionComponent wall) {
    if(!voo){
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(wall.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 2.0);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // OTIMIZAÇÃO: Usa as tintas cacheadas em vez de instanciar Paint() a 60FPS
    if (_dashCooldownTimer > 0 && dashNotifier.value < maxDash) {
      const double barHeight = 2.0;
      final double barWidth = size.x; 
      final double yOffset = size.y + 3; 

      double percent = _dashCooldownTimer / dashCooldown;

      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth, barHeight),
        _dashBgPaint,
      );

      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth * percent, barHeight),
        _dashFgPaint,
      );
    }
  }
  
  void applyZodiac(){
    if(zodiac){
      if(tempZodiacTaurus)moveSpeed = moveSpeedTaurus;
      tempZodiacAquarius = false;
      tempZodiacAries = false;
      tempZodiacCancer = false;
      tempZodiacLeo = false;
      tempZodiacLibra = false;
      tempZodiacPisces = false;
      tempZodiacTaurus = false;
      tempZodiacVirgo = false;

      int rng = Random().nextInt(12);
      String text = '';

      //bool tst = Random().nextBool();
      //rng = tst?4:10;
      switch (rng){
        case 0:
          tempZodiacAquarius = true;
          text = "zodiacAquarius";
          break;
        case 1:
          tempZodiacAries = true;
          text = "zodiacAries";
          break;
        case 2:
          tempZodiacCancer = true;
          increaseArtificialHp(6);
          text = "zodiacCancer";
          break;
        case 3:
          increaseDamage(1.2);
          increaseMovementSpeed(1.1);
          increaseFireRate(0.85);
          increaseRange(1.2);
          text = "zodiacCapricorn";
          break;
        case 4:
          final gemini = Familiar(position: position.clone(),
                                    type: FamiliarType.gemini, 
                                    player: this,
                                    retorna: false,
                                    );
              familiars.add(gemini);
              gameRef.world.add(gemini);
          // }
            text = "zodiacGemini";
          break;
        case 5:
          tempZodiacLeo = true;
          text = "zodiacLeo";
          break;
        case 6:
          tempZodiacLibra = true;
          applyLibraBalance();
          text = "zodiacLibra";
          break;
        case 7:
          tempZodiacPisces = true;
          bltSize *= 1.25;
          increaseFireRate(0.8);
          text = "zodiacPisces";
          break;
        case 8:
          tempPiercing = true;
          increaseMovementSpeed(1.2);
          text = "zodiacSargittarius";
          break;
        case 9:
          tempPoison = true;
          tempPoisonAlastra;
          text = "zodiacScorpio";
          break;
        case 10:
          tempZodiacTaurus = true;
          moveSpeedTaurus = moveSpeed;
          increaseMovementSpeed(0.7);
          text = "zodiacTaurus";
          break;
        case 11:
          tempZodiacVirgo = true;
          text = "zodiacVirgo";
          break;
      }
      gameRef.world.add(FloatingText(
        text: text.tr(),
        position: position.clone(), 
        color: Pallete.branco,
        fontSize: 12,
      ));

    }
  }

  void applyLibraBalance() {
    if (!zodiacLibra) return;
    double safeRawFR = fireRate <= 0.01 ? 0.01 : fireRate;
    double safeBaseFR = fireRateIni <= 0.01 ? 0.01 : fireRateIni;

    // 2. CALCULA A PROPORÇÃO (RATIO) DE CADA STATUS (1.0 = Normal, 2.0 = O dobro)
    double ratioDmg = damage / damageIni;
    double ratioSpd = moveSpeed / moveSpeedIni;
    double ratioRng = attackRange / attackRangeIni;
    
    // ATENÇÃO: O Fire Rate é Invertido! (Delay menor = Ratio maior)
    // Se o delay base é 0.5 e agora é 0.25, a força (ratio) é 2.0!
    double ratioFR = safeBaseFR / safeRawFR; 

    // 3. CALCULA A MÉDIA DE FORÇA GLOBAL DO PERSONAGEM
    // Se usar Range, some ratioRng e divida por 4.0
    double averageRatio = (ratioDmg + ratioSpd + ratioFR + ratioRng) / 4.0; 

    // 4. APLICA A FORÇA GLOBAL DE VOLTA AOS STATUS
    damage = damageIni * averageRatio;
    moveSpeed = moveSpeedIni * averageRatio;
    attackRange = attackRangeIni * averageRatio;
    fireRate = safeBaseFR / averageRatio;

    // 5. TRAVA DE SEGURANÇA (Para o menu de pause e metralhadora infinita)
    if (fireRate < 0.05) {
      fireRate = 0.05;
    }

  }
/*
  void recalculateStats() {
    // 1. Reseta para os status base do personagem
    _rawDamage = damage;
    _rawSpeed = moveSpeed;
    _rawFireRate = fireRate;
    _rawRange = attackRange;

    // 2. Soma todos os bónus dos itens normais que ele tem no inventário
    for (var item in items) {
       _rawDamage += item.bonusDamage;
       _rawSpeed += item.bonusSpeed;
       // ...
    }

    // 3. Aplica aos status reais (caso ele não tenha a Libra)
    damage = _rawDamage;
    moveSpeed = _rawSpeed;
    fireRate = _rawFireRate;
    // ...

    // 4. A MÁGICA: Se tiver a Libra, ela esmaga os status reais e os substitui pela média!
    if (zodiacLibra) {
      applyLibraBalance();
    }
  }
*/
  // UPGRADES
  void changeSize(double sizeMod){
    visual.removeFromParent();
    size = size*sizeMod;

    criaVisual(reset:true,image: classImage,color : classColor);
  }


  void increaseDamage(double multiplier) { 
    damage *= multiplier; 
    applyLibraBalance();
  }

  void increaseFireRate(double multiplier) { 
    fireRate *= multiplier; 
    if (fireRate < 0.1) fireRate = 0.1; 
    fireRateIni = fireRate;
    applyLibraBalance();
  }

  void increaseMovementSpeed(double multiplier){
    moveSpeed *= multiplier; 
    applyLibraBalance();
  }
  
  void increaseRange(double multiplier){ 
    attackRange *= multiplier; 
    applyLibraBalance();
    //_rangeIndicator.radius = attackRange;
  }

  void increaseHp(int val){ 
    maxHealth+=val; 
    healthNotifier.value+=val; 
  }

  void increaseArtificialHp(int val){ 
    maxArtificialHealth+=val; 
    artificialHealthNotifier.value+=val; 
  }

  void curaHp([int val = 1]){ 
    if(maxArtificialHealth > 0 && artificialHealthNotifier.value < maxArtificialHealth){
      artificialHealthNotifier.value ++;
      val --;
    }
    healthNotifier.value+=val;
    healthNotifier.value = min(healthNotifier.value,maxHealth);
  }

  void increaseDash([int val = 1]){ 
    maxDash+=val; 
    dashNotifier.value+=val; 
  }

  void increaseShield() async { 
    shieldNotifier.value++; 
    if (shieldNotifier.value == 6) { 
      bool isNewUnlock = await GameProgress.unlockClass('defensor');
      
      if (isNewUnlock) {
        // Cria o texto nascendo em cima do próprio jogador!
        gameRef.world.add(
          UnlockNotification(
            message: "NOVA CLASSE: DEFENSOR!",
            position: position.clone() - Vector2(0, 40), // Um pouco acima da cabeça
          )
        );
      }
    }
  }

  void collectCoin(int value) async {
    gameRef.coinsNotifier.value+=value;
    gameRef.coinsTotal += value;

    if(gameRef.coinsNotifier.value < 0) gameRef.coinsNotifier.value = 0;
    
    if (gameRef.coinsNotifier.value == 100) { 
      bool isNewUnlock = await GameProgress.unlockClass('ladino');
      
      if (isNewUnlock) {
        // Cria o texto nascendo em cima do próprio jogador!
        gameRef.world.add(
          UnlockNotification(
            message: "NOVA CLASSE: LADINO!",
            position: position.clone() - Vector2(0, 40), // Um pouco acima da cabeça
          )
        );
      }
    }
  }

  void slotMachine(int custo,{bool isPortatil = false}){
    gameRef.world.add(FloatingText(
      text: "-${custo}\$",
      position: position.clone() + Vector2(0, -30),
      paint:Pallete.textoPadrao
    ));

    // 4. Efeito Visual de Sangue jorrando da máquina
    createExplosionEffect(gameRef.world, position.clone(), Pallete.branco, count: 15);
    AudioManager.playSfx('hit.mp3'); 

    int rng = Random().nextInt(100);

    CollectibleType item = CollectibleType.coinUm;
    bool temItem = true;

    if (rng > 40){
      if(rng < 50){
        item = CollectibleType.coinUm;
      }else if(rng >= 50 && rng < 60){
        item = CollectibleType.coin;
      }else if(rng >= 60 && rng < 70){
        item = CollectibleType.bomba;
      }else if(rng >= 70 && rng < 80){
        item = CollectibleType.key;
      }else if(rng >= 80 && rng < 90){
        item = CollectibleType.potion;
      }else if(rng >= 90 && rng < 95){
        var pool = retornaItensComuns(this);
        item = pool.first;
      }else if(rng >= 95 && rng < 98){
        item = CollectibleType.boloDinheiro;
      }else if(rng >= 98){
        gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:true, damage:1, radius:60));
        temItem = false;
      }
    }else{
      return;
    }

    String ResultTxt = 'nada';
    if (temItem){
      final newItem = Collectible(
        position:isPortatil ? position.clone() + Vector2(0, 10) : Vector2(0, 10), 
        type: item,
      );
    
      gameRef.world.add(newItem);

      final attrs = Collectible.getAttributes(item);
      
      setAcquiredItemsList(
        item,
        attrs['name'] as String,
        attrs['desc'] as String,
        attrs['icon'] as String,
        attrs['color'] as Color,
      );

      ResultTxt = "${attrs['name']}" ;
          
      newItem.pop(Vector2(0, 20));
    }

    gameRef.world.add(FloatingText(
        text: ResultTxt.tr(),
        position: position.clone() + Vector2(0, -30),
        color: Pallete.laranja,
      ));
  }

  List<AcquiredItemData> getAcquiredItemsList() {
    return items;
  }

  void setAcquiredItemsList(CollectibleType type, String name, String desc, String icon, Color color) {
    items.add(AcquiredItemData(
      type: type, 
      name: name, 
      description: desc, 
      icon: icon, 
      color: color
    ));
  }
}

class AcquiredItemData {
  final CollectibleType type;
  final String icon;
  final String name;
  final String description;
  final Color color;

  AcquiredItemData({
    required this.type,
    required this.icon, 
    required this.name, 
    required this.description, 
    required this.color
  });
}