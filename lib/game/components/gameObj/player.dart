import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/core/character_class.dart';
import 'package:TowerRogue/game/components/effects/floating_text.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/effects/magic_shield_effect.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:TowerRogue/game/components/gameObj/door.dart';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:TowerRogue/game/components/projectiles/bomb.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
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
  double attackRange = 200; 
  late CircleComponent _rangeIndicator;
  double _attackTimer = 0;
  double damage = 10.0;
  double dot = 1.0;
  double critChance = 5;
  double critDamage = 2.0;
  double fireRate = 0.4; 
  double fireRateInicial = 0.4; 
  double moveSpeed = 150.0;

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
  double dashDuration = 0.2; 
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

  int stackBonus = 0;

  // Variáveis de Animação
  double _walkTimer = 0;
  final double _bounceSpeed = 15.0;     
  final double _bounceAmplitude = 0.15; 

  double _dustSpawnTimer = 0;
  double _ghostTimer = 0;

  // --- CACHES DE RENDERIZAÇÃO E COMPONENTES ---
  late GameIcon _visual;
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

    // Debug visual do alcance
    _rangeIndicator=CircleComponent(
      radius: attackRange,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 2,
    );
    add(_rangeIndicator);
    
    // Hitbox
    add(RectangleHitbox(
      size: Vector2(12,24),
      anchor: Anchor.center, 
      position: size / 2 + Vector2(0,4),    
      isSolid: true,
    ));

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

    // Lógica Visual (Virar sprite) - Acesso direto ao _visual cacheado
    if (velocity.x.abs() > 0.1) {
      _visual.scale.x = velocity.x < 0 ? -1 : 1;
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
      dashCooldown = charClass.dashCooldown;

      // 3. Aplica Passivas
      isPiercing = charClass.isPiercing;

      // 4. (Opcional) Muda a cor do personagem para bater com a classe!
      //originalColor = charClass.color;
      final visualIcon = children.whereType<GameIcon>().firstOrNull;
      if (visualIcon != null) {
        visualIcon.setColor(charClass.color);
        // Se a sua classe GameIcon permitir, você pode até trocar o ícone dele aqui:
        // visualIcon.icon = charClass.icon; 
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

    if (!velocity.isZero()) {
      _walkTimer += dt * _bounceSpeed;

      double wave = sin(_walkTimer);
      double scaleY = 1.0 + (wave * _bounceAmplitude); 
      double scaleX = 1.0 - (wave * _bounceAmplitude * 0.5); 

      _visual.scale.setValues(facingDirection * scaleX, scaleY);
      _visual.angle = cos(_walkTimer) * 0.1; 
      
    } else {
      _walkTimer = 0;
      _visual.scale.setValues(facingDirection, 1.0); 
      _visual.angle = 0; 
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
          color: Pallete.branco.withOpacity(0.3),
          position: position.clone(), 
          size: size,
          anchor: anchor,
          scale: _visual.scale.clone(), // Clonado para não linkar referências
        ),
      );
      _ghostTimer = 0;
    }
  }

  void _handleDashMovement(double dt) {
    _dashTimer -= dt;
    _createGhostEffect(dt);
    position.addScaled(_dashDirection, dashSpeed * dt);

    if (_dashTimer <= 0) {
      isDashing = false;
      _isInvincible = false; 
    }
  }

  void _keepInBounds() {
    double limitX = game.gameWidth/2 - size.x;
    double limitY = game.gameHeight/2 - size.y;

    position.x = position.x.clamp(-limitX, limitX);
    position.y = position.y.clamp(-limitY, limitY);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy && !other.isIntangivel) {
      takeDamage(1);
    }
  }

  void takeDamage(int amount) {
    if(_isInvincible) return;
   // if (healthNotifier.value <= 0) return;
    gameRef.shakeCamera(intensity: 4.0, duration: 0.15);
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
         _visual.setColor(Pallete.branco);
      }

      if (_invincibilityTimer <= 0) {
        _isInvincible = false;
        _visual.setColor(Pallete.branco);
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
    double closestDist = attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (dist <= attackRange && dist < closestDist) {
        closestDist = dist;
        target = enemy;
      }
    }

    if (target != null) {
      _attackTimer = 0;
      _shootAt(target);
    }
  }

  void _shootAt(Enemy target) {
    // Calculo da direção livre de lixo de memória
    _tempDirection.setFrom(target.position);
    _tempDirection.sub(position);
    _tempDirection.normalize();

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
      double angleOffset = Random().nextDouble() * 0.2;
      double x = _tempDirection.x * cos(angleOffset) - _tempDirection.y * sin(angleOffset);
      double y = _tempDirection.x * sin(angleOffset) + _tempDirection.y * cos(angleOffset);
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
      speed: isOrbitalShot ? 4.0 : isHeavyShot ? 150 : 300,
      size: isHeavyShot ? Vector2.all(30) : Vector2.all(10),
      dieTimer: isBoomerang ? 1.0 : 3.0,
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
    attackRange = 200; 
    _attackTimer = 0;
    damage = 10.0;
    critChance = 5;
    critDamage = 2.0;
    fireRate = 0.4; 
    fireRateInicial = 0.4;
    moveSpeed = 150.0;
    dashDuration = 0.2; 
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
    _rangeIndicator.radius = attackRange;
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

  void increaseShield(){ 
    shieldNotifier.value++; 
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