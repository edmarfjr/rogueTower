import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:TowerRogue/game/components/core/game_progress.dart';
import 'package:TowerRogue/game/components/core/i18n.dart';
import 'package:TowerRogue/game/components/effects/floating_text.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/effects/magic_shield_effect.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:TowerRogue/game/components/effects/unlock_notification.dart';
import 'package:TowerRogue/game/components/gameObj/collectible.dart';
import 'package:TowerRogue/game/components/gameObj/familiar.dart';
import 'package:TowerRogue/game/components/gameObj/door.dart';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:TowerRogue/game/components/projectiles/bomb.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:TowerRogue/game/components/projectiles/laser_beam.dart';
import 'package:TowerRogue/game/components/projectiles/mortar_shell.dart';
//import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/math.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; 
import 'dart:math';
import '../../tower_game.dart'; 
import '../enemies/enemy.dart'; 
import '../projectiles/projectile.dart';
import '../core/game_icon.dart';
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
  double critChance = 5;
  double critChanceIni = 5;
  double critDamage = 2.0;
  double critDamageIni = 2.0;
  double fireRate = 0.4; 
  double fireRateIni = 0.4; 
  double moveSpeed = 150.0;
  double moveSpeedIni = 150.0;
  double moveSpeedTaurus = 150.0;
  final double acceleration = 250.0; 
  final double friction = 750.0;
  bool velMax = false;
  TextComponent? velMaxText;
  int stackBonus = 0;
  double knockbackForce = 0;

  double bltSize = 10;

  double _rawDamage = 0;
  double _rawSpeed = 0;
  double _rawFireRate = 0;
  double _rawRange = 0;

  ValueNotifier<int> bombNotifier = ValueNotifier<int>(0);
  double bombButtonTimer = 0;

  // VETORES OTIMIZADOS (Previnem Garbage Collection)
  final Vector2 velocity = Vector2.zero();
  final Vector2 velocityDash = Vector2(1, 0);
  final Vector2 _keyboardInput = Vector2.zero(); 
  final Vector2 _dashDirection = Vector2.zero();
  final Vector2 _collisionBuffer = Vector2.zero();
  final Vector2 _tempDirection = Vector2.zero(); 

  bool isDashing = false;
  double _dashTimer = 0;
  double dashDuration = 0.4; 
  double dashSpeed = 450;    
  
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
  bool tempDmgBonus = false;
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

  int numIcons = 0;

  GameIcon? reviveIcon;
  TextComponent? reviveText;
  GameIcon? cuponIcon;
  GameIcon? kineticIcon;
  TextComponent? kineticText;
  GameIcon? dmgBuffIcon;
  GameIcon? ariesIcon;

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
  late GameIcon _visual;
  late ShadowComponent _shadow;
  late RectangleHitbox _hitbox;
  Color currentColor = Pallete.branco;
  GameIcon? _currentAccessory;
  double _baseAccessoryOffsetX = 0.0;
  double _baseAccessoryOffsetY = 0.0;
  double _baseAccessoryScaleX = 1.0;
  double _acessorySize = 0;
  IconData icone = Icons.directions_walk;

  CircleComponent? _dodgeAura;
  double _auraPulseTimer = 0.0;

  MagicShieldEffect? _shieldVisual;
  final Paint _dashBgPaint = Paint()..color = Pallete.preto.withOpacity(0.5);
  final Paint _dashFgPaint = Paint()..color = Pallete.verdeCla;

  //lista de itens
  List<AcquiredItemData> items = [];
  List<CollectibleType> itemsExcluidos = [];

  bool noDamage = false;

  TimerComponent? bombTmr;

  final ValueNotifier<List<ActiveItemData?>> activeItems = ValueNotifier([null, null]);

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
    
    return 5; 
  }

  Player({required Vector2 position}) : super(size: Vector2.all(32), anchor: Anchor.center) {
    healthNotifier = ValueNotifier<int>(maxHealth);
    artificialHealthNotifier = ValueNotifier<int>(maxArtificialHealth);
    dashNotifier = ValueNotifier<int>(maxDash);
  }
  
  @override
  Future<void> onLoad() async {
    // Cache do visual para acesso instantâneo
    criaVisual();
    
  }

  void criaVisual({reset = false}){

    bool acessorio = false;
    IconData? acessIcon;
    Color? acessCor;
    double? acessAng;

    if (reset){
      _visual.removeFromParent();
      _hitbox.removeFromParent();
      _dodgeAura!.removeFromParent();
      _shadow.removeFromParent();
      if(_currentAccessory != null){
        _currentAccessory!.removeFromParent(); 
        acessIcon= _currentAccessory!.icon ;
        acessCor = _currentAccessory!.color ;
        acessAng = _currentAccessory!.angle;
        acessorio = true;
      }
      currentColor = Pallete.branco;
    }

    Vector2 vooOffset = Vector2(0, 0);
    if(voo){
      vooOffset = Vector2(0, -15);
      animContrario = true;
    }    
    _visual = GameIcon(
      icon: Icons.directions_walk, 
      color: Pallete.branco, 
      size: size,
      anchor: Anchor.center, 
      position: size / 2 + vooOffset,    
    );
    add(_visual);

    /* Debug visual do alcance
    _rangeIndicator=CircleComponent(
      radius: attackRange,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 2,
    );
    add(_rangeIndicator);
    */
    
    // Hitbox
    
    _hitbox=RectangleHitbox(
      size: Vector2(12,24),
      anchor: Anchor.center, 
      position: size / 2 + Vector2(0,4) + vooOffset,    
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
        ..strokeWidth = 4.0
        // O SEGREDO DO NEON: Um blur filter na pintura!
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
    );
    
    // Para deixar oval/achatado simulando perspectiva 3D isométrica (opcional)
    _dodgeAura!.scale.y = 0.6; 
    
    add(_dodgeAura!);

    if(acessorio){
      _currentAccessory = GameIcon(
          icon: acessIcon!,     
          color: acessCor!,   
          size: Vector2(_acessorySize,_acessorySize),
        );

        _currentAccessory!.position = Vector2(_baseAccessoryOffsetX, _baseAccessoryOffsetY) + vooOffset;
        _currentAccessory!.scale.x = _baseAccessoryScaleX;
        _currentAccessory!.angle = acessAng!;
        _currentAccessory!.priority = 1;
        add(_currentAccessory!);
    }

    _shadow =  ShadowComponent(parentSize: size); 
    add(_shadow);
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
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
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

    if (healthNotifier.value <= 0 && shieldNotifier.value <= 0) {
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

  }

  void ativaLicantropia(){
    if(isLicantropia) return;
    isLicantropia = true;
    animContrario = false;
    _visual.removeFromParent();
    _currentAccessory!.removeFromParent();

    _visual = GameIcon(
      icon: MdiIcons.dogSide,
      color: Pallete.marrom,
      size: size, 
      anchor: Anchor.center,
      position: size / 2,
    );
    currentColor = Pallete.marrom;
    add(_visual);
  }
  void _handleLicantropia(double dt){
    if (isLicantropia){
      licantropiaTmr += dt;
      if (licantropiaTmr >= 30){
        isLicantropia = false;
        criaVisual(reset:true);
      }
    }
  }

  void ativaPacmen(){
    if(isPac) return;
    isPac = true;
    animContrario = false;
    _isInvincible = true;
    _visual.removeFromParent();
    _currentAccessory!.removeFromParent();

    _visual = GameIcon(
      icon: MdiIcons.pacMan,
      color: Pallete.amarelo,
      size: size, 
      anchor: Anchor.center,
      position: size / 2,
    );
    currentColor = Pallete.amarelo;
    add(_visual);

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
        criaVisual(reset:true);
      }
    }
  }

  void ativaUnicorn(){
    if(isUnicorn) return;
    isUnicorn = true;
    animContrario = false;
    _isInvincible = true;
    _visual.removeFromParent();
    _currentAccessory!.removeFromParent();

    _visual = GameIcon(
      icon: MdiIcons.unicorn,
      color: Pallete.laranja,
      size: size, 
      anchor: Anchor.center,
      position: size / 2,
    );
    currentColor = Pallete.laranja;
    add(_visual);
  }
  void _handleUnicorn(double dt){
    if (isUnicorn){
      unicornTmr += dt;
      if (unicornTmr >= 10){
        isUnicorn = false;
        _isInvincible = false;
        criaVisual(reset:true);
      }
    }
  }

  ActiveItemData? equipActiveItem(CollectibleType newItem, int? incomingCharge) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    ActiveItemData? droppedData; // Guarda TUDO do item antigo (tipo e carga)

    if (isItemRecarregavel(newItem)) {
      if (currentItems[0] != null) droppedData = currentItems[0];
      
      int max = cargaItem(newItem);
      // Se veio do chão com carga, usa ela. Se é novo gerado pelo baú, vem cheio (max)!
      int chargeToSet = incomingCharge ?? max; 
      
      currentItems[0] = ActiveItemData(type: newItem, currentCharge: chargeToSet, maxCharge: max);
      
    } else if (isItemUsoUnico(newItem)) {
      if (currentItems[1] != null) droppedData = currentItems[1];
      
      currentItems[1] = ActiveItemData(type: newItem, currentCharge: 1, maxCharge: 1);
    }

    activeItems.value = currentItems;
    return droppedData;
  }

  void useActiveSlot(int slotIndex) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    final itemData = currentItems[slotIndex];

    // Só usa se existir e estiver com a carga completa!
    if (itemData != null && itemData.isReady) {
      
      final feedback = CollectibleLogic.applyEffect(type: itemData.type, game: gameRef);
      String feedbackText = feedback['text'] as String;
      Color feedbackColor = feedback['color'] as Color;
      bool foiSucesso = feedback['sucesso'] ?? true;

    /* 3. Feedback Visual Final*/
    if (feedbackText.isNotEmpty) {
      gameRef.world.add(FloatingText(
        text: feedbackText,
        position: position.clone(), 
        color: feedbackColor,
        fontSize: 12,
      ));
    }
    

      if (slotIndex == 0) {
        // Zera a carga do recarregável
        if (foiSucesso)itemData.currentCharge = 0; 
      } else if (slotIndex == 1) {
        // Destrói o de uso único
        if (foiSucesso) currentItems[1] = null;
      }
      activeItems.value = currentItems;
    }
  }

  void rechargeActiveItem({bool full = false}) {
    final currentItems = List<ActiveItemData?>.from(activeItems.value);
    int val = 1;
    if(hasBattery) val = 2;
    if(full) val = cargaItem(currentItems[0]!.type);
    // Se tem item no slot 0 e ele NÃO está pronto, carrega +1
    if (currentItems[0] != null && !currentItems[0]!.isReady) {
      currentItems[0]!.currentCharge+= val;
      activeItems.value = currentItems; // Dispara a atualização visual na HUD
    }
  }

  void applyClass(CharacterClass charClass) {

      maxHealth = charClass.maxHp;
      maxDash = charClass.maxDash;
      healthNotifier.value = maxHealth;
      shieldNotifier.value = charClass.startingShield;
      bombNotifier.value = charClass.startingBombs;
      
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
              attrs['icon'] as IconData,
              attrs['color'] as Color,
            );
          }
        }
      }

      if (_currentAccessory != null) {
      _currentAccessory!.removeFromParent();
      _currentAccessory = null;
    }

     /* 
      currentColor = charClass.color;
      if (_visual != null) {
        _visual.setColor(charClass.color);
        // Se a sua classe GameIcon permitir, você pode até trocar o ícone dele aqui:
        // visualIcon.icon = charClass.icon; 
      }
      */
      if (!charClass.semAcessorio)
      {
        _currentAccessory = GameIcon(
          icon: charClass.icon,     
          color: charClass.color,   
          size: Vector2(charClass.accessorySize,charClass.accessorySize),
        );

        _baseAccessoryOffsetX = charClass.accessoryOffsetX;
        _baseAccessoryOffsetY = charClass.accessoryOffsetY;
        _baseAccessoryScaleX = charClass.flipAccessoryBase ? -1.0 : 1.0;
        _acessorySize = charClass.accessorySize;

        _currentAccessory!.position = Vector2(_baseAccessoryOffsetX, charClass.accessoryOffsetY);
        _currentAccessory!.scale.x = _baseAccessoryScaleX;
        _currentAccessory!.angle = charClass.acessoryAngle;
        _currentAccessory!.priority = 1;
        add(_currentAccessory!);
      }
      if(charClass.mudaIcone){
         _visual.removeFromParent();

        _visual = GameIcon(
          icon: charClass.icon,
          color: Pallete.branco,
          size: size * 1.2, 
          anchor: Anchor.center,
          position: size / 2,
        );
        currentColor = Pallete.branco;
        add(_visual);

        icone = charClass.icon;
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
    double facingDirection = _visual.scale.x.sign; 
    if (velocity.x < -0.1) facingDirection = -1.0;
    if (velocity.x > 0.1) facingDirection = 1.0;

    double bSpeed = voo ? _bounceSpeed/2 : _bounceSpeed;

    // Variáveis base de animação
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
    }

    // 1. Aplica a animação no Corpo Principal (_visual)
    _visual.scale.setValues(facingDirection * currentScaleX, currentScaleY);
    _visual.angle = currentAngle; 

    // 2. Aplica a animação no Acessório (Sincronizado!)
    if (_currentAccessory != null) {
      // Sincroniza o "pulo" (escala Y) e a rotação (balanço)
      _currentAccessory!.scale.y = currentScaleY;
      _currentAccessory!.angle = currentAngle;

      // Trata a inversão de lado e o "amasso" (escala X)
      if (facingDirection < 0) {
        // Virado para a Esquerda
        _currentAccessory!.position.x = -_baseAccessoryOffsetX + size.x; // O nosso ajuste fino!
        _currentAccessory!.scale.x = -_baseAccessoryScaleX * currentScaleX;
      } else {
        // Virado para a Direita
        _currentAccessory!.position.x = _baseAccessoryOffsetX;
        _currentAccessory!.scale.x = _baseAccessoryScaleX * currentScaleX;
      }
    }
  }

  void _handleMovement(double dt) {
    // 1. Definição do Limite de Velocidade
    double movVel = moveSpeed;
    if (isLicantropia || isUnicorn) movVel = moveSpeed * 1.5;

    if((zodiacTaurus || tempZodiacTaurus) && !isUnicorn){
      movVel = moveSpeedIni * 2;
    }

    // 2. Captura o Input
    Vector2 input = Vector2.zero();
    if (gameRef.joystickDelta != Vector2.zero()) {
       input.setFrom(gameRef.joystickDelta);
    } else if (_keyboardInput != Vector2.zero()) {
       input.setFrom(_keyboardInput);
       input.normalize();
    }

    // --- O SEGREDO ANTES DE MOVER ---
    // Guardamos a velocidade e a direção do frame anterior
    double speedAntes = velocity.length;
    Vector2 direcaoAntes = speedAntes > 0 ? velocity.normalized() : Vector2.zero();

    // 3. Aplica a Força (Aceleração ou Atrito)
    Vector2 targetVelocity = input * movVel;
    double rate = input.isZero() ? friction : acceleration;

    Vector2 diferenca = targetVelocity - velocity;
    if (diferenca.length < rate * dt) {
      velocity.setFrom(targetVelocity);
    } else {
      velocity.addScaled(diferenca.normalized(), rate * dt);
    }

    // 4. --- MÁGICA DA PRESERVAÇÃO DE MOMENTUM ---
    if (!input.isZero() && speedAntes > 0) {
      // O dot product retorna: 1 (Mesma direção), 0 (90 graus), -1 (Direção Oposta)
      double dot = direcaoAntes.dot(input.normalized());
      
      // Se a curva for mais suave que um retorno brusco (> -0.5, permite curvas até 120º)
      if (dot > -0.5) {
        // Se o cálculo da curva roubou velocidade, nós a restauramos!
        if (velocity.length < speedAntes) {
          velocity.scaleTo(speedAntes);
        }
      }
    }
    
    // Segurança extra: Garante que o momentum restaurado não quebre o limite máximo
    if (velocity.length > movVel) {
      velocity.scaleTo(movVel);
    }

    // 5. --- Lógica de Efeitos ---
    bool isMoving = velocity.length > 10.0;

    if (isMoving) {
      if (!input.isZero()) {
         velocityDash.setFrom(input.normalized() * movVel); 
      } else {
         velocityDash.setFrom(velocity.normalized() * movVel);
      }
      
      _handleDustEffect(dt);
      if(isLicantropia || isUnicorn) _createGhostEffect(dt);
      if(criaPocaVeneno || zodiacAquarius) _createHazard(dt); 
      if(isConcentration) fireRate = fireRateIni * 1.15;
    } else {
      if(isConcentration) fireRate = fireRateIni * 0.5;
    } 
    
    // 6. Atualiza Posição e Status Max Speed
    position.addScaled(velocity, dt);

    if (velocity.length >= movVel - dt) {
      velMax = true;
      if(zodiacAries){
        if (ariesIcon == null) {
          numIcons ++;
          ariesIcon = GameIcon(
            icon: MdiIcons.zodiacAries,
            color: Pallete.azulCla,
            size: size/2,
            anchor: Anchor.center,
            position: Vector2(size.x / 2, - size.y / 4 - 10*numIcons), 
          );
          add(ariesIcon!);
        }
      }
      if(zodiacTaurus || tempZodiacTaurus){
          if(!zodiacTaurusTransf){
            zodiacTaurusTransf = true;
            gameRef.world.add(FloatingText(
              text: "TAURUS",
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
            ativaUnicorn();
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
        kineticIcon = GameIcon(
          icon: MdiIcons.sword,
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
          icon: _visual.icon,
          color: currentColor.withOpacity(0.3),
          position: position.clone(), 
          size: size,
          anchor: anchor,
          scale: _visual.scale.clone(), // Clonado para não linkar referências
        ),
      );
      _ghostTimer = 0;
    }
  }

  void _createHazard(double dt,{bool isFire = false, bool isVeneno = true,bool isGelo = false,bool isBlood = false,double tmp = 0.1}) {
    criaHazardTmr += dt;
  
    if (criaHazardTmr >= tmp) {
      if(zodiacAquarius){
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
    position.addScaled(_dashDirection, dashSpeed * dt);

    if (_dashTimer <= 0) {
      isDashing = false;
      _isInvincible = false; 
    }
  }

  void _keepInBounds() {
    double limitX = TowerGame.gameWidth/2 - size.x;
    double limitY = TowerGame.gameHeight/2 - size.y;
    double arenaBorder = 10;

    position.x = position.x.clamp(-limitX + arenaBorder, limitX - arenaBorder);
    position.y = position.y.clamp(-limitY + arenaBorder, limitY - arenaBorder);
  }

/*
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    
  }
*/
  void takeDamage(int amount,{bool roubaMoeda = false,bool pulaEscudo = false}) {
    if(_isInvincible || isDashing) return;

    if(evasao){
      if(Random().nextDouble() <= 0.2) return;
    }
    gameRef.shakeCamera(intensity: 4.0, duration: 0.15);
    gameRef.triggerHitStop(0.05);
    if(explodeHit){
      gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:false, damage:30, radius:60));
    }

    if(roubaMoeda && gameRef.coinsNotifier.value > 0) collectCoin(Random().nextInt(10) + 5);

    if(hurtPac){
      int rnd = Random().nextInt(100);
      if(rnd <= 5){ 
        ativaPacmen();
      }
    }

    if (hasShield && !pulaEscudo && amount>0) {
      _breakShield(); 
      return; 
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
        print(maxArtificialHealth);
      }
    }else{
      healthNotifier.value -= amount;
    }

    if(zodiacCancer){
      takeOneDmg = true;
    }

    double invTmr = invincibilityDuration;
    if(zodiacVirgo){
      int rnd = Random().nextInt(100);
      if(rnd <= 20) {
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
         _visual.setColor(Pallete.vermelho.withOpacity(0.5));
      } else {
         _visual.setColor(currentColor);
      }

      if (_invincibilityTimer <= 0) {
        _isInvincible = false;
        _visual.setColor(currentColor);
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
    Enemy? target;
    double closestDist = double.infinity;//attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (/* dist <= attackRange && */ dist < closestDist && !enemy.isCharmed) {
        closestDist = dist;
        target = enemy;
      }
    }

    if (target != null) {
      
      _attackTimer = 0;
      if(isMorteiro){
        gameRef.world.add(MortarShell(
          startPos: position.clone(),
          targetPos: target.position.clone(),
          owner: this,
          flightDuration: 1,
          damage: damage * 2,
          isFire: true,
          explosionRadius: 100,
          isPlayer: true,
          goldShot: goldShot,
        ));
      }else if(isLaser){
        final dir = (target.position - position.clone()).normalized();
        final angle = atan2(dir.y, dir.x);
        criaLaser(dir,angle,target);
      }else{
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
            size: Vector2.all(15),
            dieTimer: attackRange,
            cor : Pallete.vinho,
          ));
          }
        }
        if(isShotgun){
          _shootAt(target,angleOffset: 0.075);
          _shootAt(target,angleOffset: -0.075);
          _shootAt(target,angleOffset: 0.2);
          _shootAt(target,angleOffset: -0.2);
          if(cardinalShot){
            int rnd = Random().nextInt(100);
            if(rnd <= 25){
              _shootAt(target,angleOffset: pi/2);
              _shootAt(target,angleOffset: -pi/2);
              _shootAt(target,angleOffset: pi);
            }
          }
        }else{
          _shootAt(target);
          if(tripleShot){
            _shootAt(target,angleOffset: 0.2);
            _shootAt(target,angleOffset: -0.2);
          }
          if(cardinalShot){
            int rnd = Random().nextInt(100);
            if(rnd <= 25){
              _shootAt(target,angleOffset: pi/2);
              _shootAt(target,angleOffset: -pi/2);
              _shootAt(target,angleOffset: pi);
            }
          }
        }
      }
    }
  }

  void criaLaser(Vector2 dir,ang,target)
  {
    gameRef.world.add(LaserBeam(
      position: position + (dir * 10),
      angleRad: ang,
      chargeTime: 0,
      fireTime: fireRate,
      target: target,
      owner: this,
      damage: damage
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
    if(tempDmgBonus){
       dmg = dmg * 1.2;
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

    return dmg;
  }

  double returnCritChance(){
    double crit = critChance;

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
    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: _tempDirection.clone(), 
      damage: noDamage? 0 : dmg, 
      speed: isOrbitalShot ? 4.0 : isHeavyShot ? 250 : isWave ? 350 : isSaw ? 50 : 500,
      size: Vector2.all(bltSize),
      dieTimer: isBoomerang ? 1.0 : isOrbitalShot ? 2 : isSaw ? aRange*1.5 : aRange,
      apagaTiros: hasAntimateria,
      isHoming: isHoming || isHomingTemp,
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
      knockbackForce: knockbackForce
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
        damage:30, 
        owner: this, 
        splits: isBombSplits,
        isDecoy: isBombDecoy,
        isGlitterBomb: isGlitterBomb
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
    size = Vector2.all(32);
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
    critChance = 5;
    critDamage = 2.0;
    fireRate = 0.4; 
    fireRateIni = 0.4;
    moveSpeed = 150.0;
    dashDuration = 0.3; 
    dashSpeed = 450;    
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
    tempDmgBonus = false;
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

    criaVisual(reset:true);
    _visual.setColor(Pallete.branco);
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
    if (other is Enemy && !other.isIntangivel  && !other.isCharmed) {
      if( isUnicorn || isDashing && isDashDamages || other.encolhido || isPac || zodiacAries && velMax){
        double dmg = (isUnicorn || isPac)? damage*2 : damage;
        other.takeDamage(dmg);
      }else{
        takeDamage(other.dmg.toInt());
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
      const double barHeight = 4.0;
      final double barWidth = size.x; 
      final double yOffset = size.y + 5; 

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
          increaseHp(2);
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
/*
    print('--- DEBUG DA LIBRA ---');
    print('Dano  -> Raw: $damage | Base: $damageIni | Ratio: $ratioDmg');
    print('Speed -> Raw: $moveSpeed | Base: $moveSpeedIni | Ratio: $ratioSpd');
    print('Tiro  -> Raw: $fireRate | Base: $fireRateIni | Ratio: $ratioFR');
    print('Range  -> Raw: $attackRange | Base: $attackRangeIni | Ratio: $ratioRng');
    print('Média Global (Average Ratio): $averageRatio');
    print('Dano Final Aplicado: $damage');
    print('----------------------');
    */
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
    _visual.removeFromParent();
    size = size*sizeMod;
    _visual = GameIcon(
      icon: Icons.directions_walk, 
      color: Pallete.branco, 
      size: size,
      anchor: Anchor.center, 
      position: size / 2,    
    );
    add(_visual);

    _hitbox.removeFromParent();

    _hitbox=RectangleHitbox(
      size: Vector2(12,24)*sizeMod,
      anchor: Anchor.center, 
      position: size / 2 + Vector2(0,4),    
      isSolid: true,
    );
    add(_hitbox);

    _shadow.removeFromParent();
    _shadow =  ShadowComponent(parentSize: size); 
    add(_shadow);

    if (_currentAccessory != null) {
      // Guarda os valores atuais antes de destruir o acessório antigo
      double currentOffsetY = _currentAccessory!.position.y;
      double currentAngle = _currentAccessory!.angle;
      IconData currentIcon = _currentAccessory!.icon;
      Color currentAccessoryColor = _currentAccessory!.color;
      Vector2 newAccessorySize = _currentAccessory!.size * sizeMod;
      
      _currentAccessory!.removeFromParent();

      // Escala o deslocamento X (offset) para ele não afundar no corpo
      _baseAccessoryOffsetX *= sizeMod;
      double newOffsetY = currentOffsetY * sizeMod;

      // Recria o acessório com o novo tamanho
      _currentAccessory = GameIcon(
        icon: currentIcon,     
        color: currentAccessoryColor,   
        size: newAccessorySize,
      );

      _currentAccessory!.position = Vector2(_baseAccessoryOffsetX, newOffsetY);
      _currentAccessory!.scale.x = _baseAccessoryScaleX;
      _currentAccessory!.angle = currentAngle;
      _currentAccessory!.priority = 1;
      
      add(_currentAccessory!);
    }
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

  List<AcquiredItemData> getAcquiredItemsList() {
    return items;
  }

  void setAcquiredItemsList(CollectibleType type, String name, String desc, IconData icon, Color color) {
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
  final IconData icon;
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