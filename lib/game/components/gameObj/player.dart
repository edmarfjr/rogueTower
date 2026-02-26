import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:TowerRogue/game/components/core/game_progress.dart';
import 'package:TowerRogue/game/components/effects/floating_text.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/effects/magic_shield_effect.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:TowerRogue/game/components/effects/unlock_notification.dart';
import 'package:TowerRogue/game/components/gameObj/collectible.dart';
import 'package:TowerRogue/game/components/gameObj/door.dart';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:TowerRogue/game/components/projectiles/bomb.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
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

  int maxDash = 2;
  late final ValueNotifier<int> dashNotifier;
  
  bool _isInvincible = false;
  double _invincibilityTimer = 0;
  double invincibilityDuration = 0.5; 
  // -----------------------
  double attackRange = 1.0; // tempo que o tiro demora pra sumir
 // late CircleComponent _rangeIndicator;
  double _attackTimer = 0;
  double damage = 10.0;
  double dot = 1.0;
  double critChance = 5;
  double critDamage = 2.0;
  double fireRate = 0.4; 
  double fireRateInicial = 0.4; 
  double moveSpeed = 150.0;
   int stackBonus = 0;

  ValueNotifier<int> bombNotifier = ValueNotifier<int>(0);

  // VETORES OTIMIZADOS (Previnem Garbage Collection)
  final Vector2 velocity = Vector2.zero();
  final Vector2 velocityDash = Vector2(1, 0);
  final Vector2 _keyboardInput = Vector2.zero(); 
  final Vector2 _dashDirection = Vector2.zero();
  final Vector2 _collisionBuffer = Vector2.zero();
  final Vector2 _tempDirection = Vector2.zero(); // Usado na mira

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
  bool isBleed = false;
  bool isBebado = false;
  bool hasOrbShield = false;
  bool hasFoice = false;
  bool magicShield = false;
  bool hasShield = false;
  bool revive = false;
  bool pegouRevive = false;
  bool hasAntimateria = false;
  bool isHoming = false;
  bool canBounce = false;
  bool isPiercing = false;
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

  // Variáveis de Animação
  double _walkTimer = 0;
  final double _bounceSpeed = 15.0;     
  final double _bounceAmplitude = 0.15; 

  double _dustSpawnTimer = 0;
  double _ghostTimer = 0;

  // --- CACHES DE RENDERIZAÇÃO E COMPONENTES ---
  late GameIcon _visual;
  Color currentColor = Pallete.branco;
  GameIcon? _currentAccessory;
  double _baseAccessoryOffsetX = 0.0;
  double _baseAccessoryScaleX = 1.0;

  CircleComponent? _dodgeAura;
  double _auraPulseTimer = 0.0;

  MagicShieldEffect? _shieldVisual;
  final Paint _dashBgPaint = Paint()..color = Pallete.preto.withOpacity(0.5);
  final Paint _dashFgPaint = Paint()..color = Pallete.verdeCla;

  //lista de itens
  List<AcquiredItemData> items = [];

  Player({required Vector2 position}) : super(size: Vector2.all(32), anchor: Anchor.center) {
    healthNotifier = ValueNotifier<int>(maxHealth);
    dashNotifier = ValueNotifier<int>(maxDash);
  }
  
  @override
  Future<void> onLoad() async {
    // Cache do visual para acesso instantâneo
    _visual = GameIcon(
      icon: Icons.directions_walk, 
      color: Pallete.branco, 
      size: size,
      anchor: Anchor.center, 
      position: size / 2,    
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
    add(RectangleHitbox(
      size: Vector2(12,24),
      anchor: Anchor.center, 
      position: size / 2 + Vector2(0,4),    
      isSolid: true,
    ));

    _dodgeAura = CircleComponent(
      radius: size.x * 0.7, // Um pouco maior que o corpo do player
      anchor: Anchor.center,
      position: size / 2, // Fica centralizada no jogador
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

    add(ShadowComponent(parentSize: size));
    
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
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dashNotifier.value < maxDash){
      if (_dashCooldownTimer > 0) {
        _dashCooldownTimer -= dt;
      } else {
        _dashCooldownTimer = dashCooldown;
        dashNotifier.value++;
      }
    }

    if(isKinetic){
      if(kineticTimer >=0){
        kineticTimer -= dt;
      }else{
        kineticStacks = 0;
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
    _handleAutoAttack(dt);
    _handleInvincibility(dt);
    _keepInBounds(); 

    if (healthNotifier.value <= 0 && shieldNotifier.value <= 0) {
      _die();
    }
  }

  void applyClass(CharacterClass charClass) {
      // 1. Aplica Vida e Escudo
      maxHealth = charClass.maxHp;
      maxDash = charClass.maxDash;
      healthNotifier.value = maxHealth;
      shieldNotifier.value = charClass.startingShield;
      bombNotifier.value = charClass.startingBombs;
      
      // 2. Aplica Atributos Numéricos
      moveSpeed = charClass.speed;
      damage = charClass.damage;
      fireRate = charClass.fireRate;
      fireRateInicial = charClass.fireRate;
      critChance = charClass.critChance;
      critDamage = charClass.critDamage;
      attackRange = charClass.attackRange;
     // _rangeIndicator.radius = attackRange;
      dashCooldown = charClass.dashCooldown;
      dot = charClass.dot;
      stackBonus = charClass.stackBonus;

      // 3. Aplica Passivas
      isPiercing = charClass.isPiercing;
      isBurn = charClass.isBurn;
      isShotgun = charClass.isShotgun;

      if(charClass.hasOrbShield){
        game.world.add(OrbitalShield(angleOffset: 0, owner: this));
        game.world.add(OrbitalShield(angleOffset: pi, owner: this));
        game.itensRarosPoolCurrent.remove(CollectibleType.orbitalShield);
      }

      //remove itens cujo efeito ja existe
      if(isPiercing)game.itensComunsPoolCurrent.remove(CollectibleType.piercing);
      if(isBurn)game.itensComunsPoolCurrent.remove(CollectibleType.fogo);
      if(isShotgun)game.itensRarosPoolCurrent.remove(CollectibleType.tripleShot);
   

      if (_currentAccessory != null) {
      _currentAccessory!.removeFromParent();
      _currentAccessory = null;
    }

     /* // 4. (Opcional) Muda a cor do personagem para bater com a classe!
      currentColor = charClass.color;
      if (_visual != null) {
        _visual.setColor(charClass.color);
        // Se a sua classe GameIcon permitir, você pode até trocar o ícone dele aqui:
        // visualIcon.icon = charClass.icon; 
      }
      */

      _currentAccessory = GameIcon(
        icon: charClass.icon,     // Usa o ícone da classe (Escudo, Varinha, etc)
        color: charClass.color,   // Usa a cor da classe
        size: Vector2(charClass.accessorySize,charClass.accessorySize),
      );

      _baseAccessoryOffsetX = charClass.accessoryOffsetX;
     _baseAccessoryScaleX = charClass.flipAccessoryBase ? -1.0 : 1.0;

      _currentAccessory!.position = Vector2(_baseAccessoryOffsetX, charClass.accessoryOffsetY);
      _currentAccessory!.scale.x = _baseAccessoryScaleX;
      _currentAccessory!.angle = charClass.acessoryAngle;
      _currentAccessory!.priority = 1;
      add(_currentAccessory!);
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

    // Variáveis base de animação
    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

    if (!velocity.isZero()) {
      _walkTimer += dt * _bounceSpeed;

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
        _currentAccessory!.position.x = -_baseAccessoryOffsetX + 32.0; // O nosso ajuste fino!
        _currentAccessory!.scale.x = -_baseAccessoryScaleX * currentScaleX;
      } else {
        // Virado para a Direita
        _currentAccessory!.position.x = _baseAccessoryOffsetX;
        _currentAccessory!.scale.x = _baseAccessoryScaleX * currentScaleX;
      }
    }
  }

  void _handleMovement(double dt) {
    velocity.setZero();

    if (gameRef.joystickDelta != Vector2.zero()) {
       velocity.setFrom(gameRef.joystickDelta);
       velocity.scale(moveSpeed);
    } else if (_keyboardInput != Vector2.zero()) {
       velocity.setFrom(_keyboardInput);
       velocity.normalize();
       velocity.scale(moveSpeed);
    }

    if (!velocity.isZero()) {
      velocityDash.setFrom(velocity); // Copia segura
      _handleDustEffect(dt);
      if(criaPocaVeneno) _createHazard(dt); 
      if(isConcentration) fireRate = fireRateInicial * 1.15;
    }else{
      if(isConcentration) fireRate = fireRateInicial * 0.5;
    } 
    
    position.addScaled(velocity, dt); // Otimizado
  }

  void startDash() {
    if (dashNotifier.value <= 0 || isDashing) return;
    dashNotifier.value--;
    isDashing = true;

    if(isKinetic){
      kineticStacks++;
      kineticTimer = 3.0;
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
      
      final offset = Vector2(0, size.y / 2);
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

  void _createHazard(double dt,{bool isFire = false, double tmp = 0.1}) {
    criaHazardTmr += dt;
    if (criaHazardTmr >= tmp) {
      gameRef.world.add(
        PoisonPuddle(
          position: position.clone(), 
          isPlayer: true,
          isFire: isFire,
        ),
      );
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

    position.x = position.x.clamp(-limitX, limitX);
    position.y = position.y.clamp(-limitY, limitY);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy && !other.isIntangivel) {
      if( isDashing && isDashDamages){
        other.takeDamage(100);
      }else{
        takeDamage(1);
      }
      
    }
  }

  void takeDamage(int amount) {
    if(_isInvincible || isDashing) return;
   // if (healthNotifier.value <= 0) return;
    gameRef.shakeCamera(intensity: 4.0, duration: 0.15);
    gameRef.triggerHitStop(0.05);
    if (hasShield) {
      _breakShield(); 
      return; 
    }

    if (gameRef.challengeHitsNotifier.value >= 0) {
      // Se ainda não tomou 3 hits, adiciona +1
      if (gameRef.challengeHitsNotifier.value < 3) {
        gameRef.challengeHitsNotifier.value++;
      }
    }

    if (shieldNotifier.value > 0){
      shieldNotifier.value-- ;
      _isInvincible = true;
      _invincibilityTimer = invincibilityDuration;
      if(defensiveBurst){
        gameRef.world.add(Explosion(position: position.clone(), damage: 0, radius: 500, damagesPlayer: false));
      }
      return;
    }

    healthNotifier.value -= amount;
    _isInvincible = true;
    _invincibilityTimer = invincibilityDuration;
    
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

  void _die() {
    if(revive){
      revive = false;
      curaHp((maxHealth/2).ceil());
    }else{
      AudioManager.playSfx('game_over.mp3');
      gameRef.onGameOver();
    }
  }

  void _handleAutoAttack(double dt) {
    _attackTimer += dt;
    if (_attackTimer < fireRate) return;

    final enemies = gameRef.world.children.query<Enemy>();
    Enemy? target;
    double closestDist = double.infinity;//attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (/* dist <= attackRange && */ dist < closestDist) {
        closestDist = dist;
        target = enemy;
      }
    }

    if (target != null) {
      _attackTimer = 0;
      if(isShotgun){
        _shootAt(target,angleOffset: 0.075);
        _shootAt(target,angleOffset: -0.075);
        _shootAt(target,angleOffset: 0.2);
        _shootAt(target,angleOffset: -0.2);
      }else{
        _shootAt(target);
        if(tripleShot){
          _shootAt(target,angleOffset: 0.2);
          _shootAt(target,angleOffset: -0.2);
        }
      }
      
    }
  }

  void _shootAt(Enemy target, {double angleOffset = 0}) {
    // Calculo da direção livre de lixo de memória
    _tempDirection.setFrom(target.position);
    _tempDirection.sub(position);
    _tempDirection.normalize();

    double x = _tempDirection.x * cos(angleOffset) - _tempDirection.y * sin(angleOffset);
    double y = _tempDirection.x * sin(angleOffset) + _tempDirection.y * cos(angleOffset);
    _tempDirection.setValues(x, y);

    double dmg = damage;

    if(isBerserk && healthNotifier.value <= 2) dmg = dmg * 1.4;
    if(isAudaz && shieldNotifier.value == 0) dmg = dmg * 1.3;
    if(kineticTimer > 0){
      dmg = dmg * (1 + (kineticStacks * 0.15));
    }
    if(isHeavyShot){
       dmg = dmg * 1.3;
    }
    if(isBebado){
      double angOffset = Random().nextDouble() * 0.2;
      double x = _tempDirection.x * cos(angOffset) - _tempDirection.y * sin(angOffset);
      double y = _tempDirection.x * sin(angOffset) + _tempDirection.y * cos(angOffset);
      _tempDirection.setValues(x, y);
      dmg = dmg * 1.3;
    }
    
    AudioManager.playSfx('shoot.mp3');
    if(isMineShot){
      gameRef.world.add(Bomb(position: position.clone(), damage: dmg*1.5, isMine: true, direction: _tempDirection.clone()));
      return;
    }
    gameRef.world.add(Projectile(
      owner: this,
      position: position.clone(), 
      direction: _tempDirection.clone(), 
      damage: dmg, 
      speed: isOrbitalShot ? 4.0 : isHeavyShot ? 250 : 500,
      size: isHeavyShot ? Vector2.all(30) : Vector2.all(10),
      dieTimer: isBoomerang ? 1.0 : attackRange,
      apagaTiros: hasAntimateria,
      isHoming: isHoming,
      iniPosition: position.clone(),
      canBounce: canBounce,
      isSpectral: isSpectral,
      isPiercing: isPiercing,
      isOrbital: isOrbitalShot,
      isBoomerang: isBoomerang,
    ));
  }

  void criaBomba(){
    if (bombNotifier.value > 0){
      bombNotifier.value--;
      gameRef.world.add(Bomb(position: position.clone(), damage:30));
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
    maxHealth = 8;
    healthNotifier.value = 4;
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
    critChance = 5;
    critDamage = 2.0;
    fireRate = 0.4; 
    fireRateInicial = 0.4;
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
    revive = false;
    pegouRevive = false;
    hasAntimateria = false;
    isHoming = false;
    canBounce = false;
    isPiercing = false;
    isSpectral = false;
    stackBonus = 0;
    isBurn = false;
    isPoison = false;
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

    _visual.setColor(Pallete.branco);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall || other is Door || other is UnlockableItem) {
      _handleWallCollision(intersectionPoints, other);
    }
  }

  void _handleWallCollision(Set<Vector2> points, PositionComponent wall) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(wall.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 2.0);
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

  // UPGRADES
  void increaseDamage(double multiplier) { 
    damage *= multiplier; 
  }

  void increaseFireRate(double multiplier) { 
    fireRate *= multiplier; 
    if (fireRate < 0.1) fireRate = 0.1; 
    fireRateInicial = fireRate;
  }

  void increaseMovementSpeed(double multiplier){
    moveSpeed *= multiplier; 
  }
  
  void increaseRange(double multiplier){ 
    attackRange *= multiplier; 
    //_rangeIndicator.radius = attackRange;
  }

  void increaseHp(int val){ 
    maxHealth+=val; 
    healthNotifier.value+=val; 
  }

  void curaHp([int val = 1]){ 
    healthNotifier.value+=val;
    healthNotifier.value = min(healthNotifier.value,maxHealth);
  }

  void increaseDash([int val = 1]){ 
    maxDash+=val; 
    dashNotifier.value+=val; 
  }

  void increaseShield() async { 
    shieldNotifier.value++; 
    if (shieldNotifier.value == 5) { 
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

  void setAcquiredItemsList(String name, String description, IconData icon, Color color) {
    items.add(AcquiredItemData(
      name: name,
      description: description,
      icon: icon,
      color: color,
    ));
  }
}

class AcquiredItemData {
  final IconData icon;
  final String name;
  final String description;
  final Color color;

  AcquiredItemData({
    required this.icon, 
    required this.name, 
    required this.description, 
    required this.color
  });
}