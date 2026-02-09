import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para LogicalKeyboardKey
import 'dart:math';
import '../../tower_game.dart'; // Import para acessar as cores e classes do jogo
import '../enemies/enemy.dart'; 
import '../projectiles/projectile.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import 'wall.dart';
import '../effects/dust.dart';

class Player extends PositionComponent 
    with HasGameRef<TowerGame>, KeyboardHandler, CollisionCallbacks {
  
  int maxHealth = 3;
  late final ValueNotifier<int> healthNotifier;
  ValueNotifier<int> shieldNotifier = ValueNotifier<int>(0);

  int maxDash = 2;
  late final ValueNotifier<int> dashNotifier;
  
  bool _isInvincible = false;
  double _invincibilityTimer = 0;
  double invincibilityDuration = 0.5; 
  // -----------------------
  double speed = 150;
  double attackRange = 200; 
  late CircleComponent _rangeIndicator;
  double _attackTimer = 0;
  double damage = 10.0;
  double fireRate = 0.4; 
  double moveSpeed = 150.0;

  Vector2 velocity = Vector2.zero();
  Vector2 velocityDash = Vector2(1, 0);
  
  Vector2 _keyboardInput = Vector2.zero(); 

  bool isDashing = false;
  double _dashTimer = 0;
  double dashDuration = 0.2; 
  double dashSpeed = 450;    
  
  double _dashCooldownTimer = 0;
  double dashCooldown = 1.0; 
  Vector2 _dashDirection = Vector2.zero();

  bool isBerserk = false;
  bool isAudaz = false;
  bool isFreeze = false;

  // Variáveis de Animação
  double _walkTimer = 0;
  final double _bounceSpeed = 15.0;     // Quão rápido ele quica
  final double _bounceAmplitude = 0.15; // Quão forte ele estica/esmaga (15%)

  double _dustSpawnTimer = 0;

  Player({required Vector2 position}) : super(size: Vector2.all(32), anchor: Anchor.center) {
    healthNotifier = ValueNotifier<int>(maxHealth);
    dashNotifier = ValueNotifier<int>(maxDash);
  }

  @override
  Future<void> onLoad() async {
    // Visual do Player
    add(GameIcon(
      icon: Icons.directions_walk, 
      color: Pallete.branco, 
      size: size,
      anchor: Anchor.center, 
      position: size / 2,    
    ));

    // Debug visual do alcance
    _rangeIndicator=CircleComponent(
      radius: attackRange,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 1,
    );
    add(_rangeIndicator);
    // Hitbox
    add(RectangleHitbox(
      size: Vector2(16,32),
      anchor: Anchor.center, 
      position: size / 2,    
      isSolid: true,
    ));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _keyboardInput = Vector2.zero();
    
    // Checa teclas pressionadas para movimento (WASD ou Setas)
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
      }else{
      _dashCooldownTimer = dashCooldown;
      dashNotifier.value++;
      }
    }
    

    if (isDashing) {
      _handleDashMovement(dt); 
    } else {
      _handleMovement(dt);    
    }

    // Lógica Visual (Virar sprite)
    if (velocity.x.abs() > 0.1) {
      final visual = children.whereType<GameIcon>().first;
      visual.scale = Vector2(velocity.x < 0 ? -1 : 1, 1);
    }

    _animateMovement(dt);

    _handleAutoAttack(dt);
    _handleInvincibility(dt);
    _keepInBounds(); 
  }

  void _animateMovement(double dt) {
    // Pega o componente visual (GameIcon)
    final visual = children.whereType<GameIcon>().firstOrNull;
    if (visual == null) return;

    // Lógica de Direção (Esquerda/Direita)
    // Mantém a direção atual se estiver parado horizontalmente
    double facingDirection = visual.scale.x.sign; 
    if (velocity.x < -0.1) facingDirection = -1.0;
    if (velocity.x > 0.1) facingDirection = 1.0;

    // Se estiver se movendo (velocidade > 0)
    if (!velocity.isZero()) {
      _walkTimer += dt * _bounceSpeed;

      // Cálculo da Onda Senoidal (vai de -1 a 1)
      double wave = sin(_walkTimer);

      // Efeito Squash & Stretch:
      // Quando Y estica (+), X deve esmagar (-) para manter o volume visual
      double scaleY = 1.0 + (wave * _bounceAmplitude); 
      double scaleX = 1.0 - (wave * _bounceAmplitude * 0.5); // X varia menos que Y

      // Aplica a escala combinando com a direção
      visual.scale = Vector2(facingDirection * scaleX, scaleY);
      
      // Opcional: Rotacionar levemente para dar gingado
      visual.angle = cos(_walkTimer) * 0.1; // Balança 0.1 radianos
      
    } else {
      // PARADO: Reseta a animação suavemente ou instantaneamente
      _walkTimer = 0;
      visual.scale = Vector2(facingDirection, 1.0); // Volta ao tamanho normal (1,1)
      visual.angle = 0; // Zera rotação
    }
  }

  // --- CORREÇÃO PRINCIPAL AQUI ---
  void _handleMovement(double dt) {
    velocity = Vector2.zero();

    // 1. Tenta Joystick Manual (Nova Lógica)
    // gameRef.joystickDelta é a variável Vector2 que criamos no TowerGame
    if (gameRef.joystickDelta != Vector2.zero()) {
       velocity = gameRef.joystickDelta * speed;
    } 
    // 2. Se não tem input do joystick, usa Teclado
    else if (_keyboardInput != Vector2.zero()) {
       velocity = _keyboardInput.normalized() * speed;
    }

    // Salva a direção para o dash
    if(velocity != Vector2.zero()) velocityDash = velocity;
    
    position += velocity * dt;
  }
  // --------------------------------

  void startDash() {
    if (dashNotifier.value <= 0 || isDashing) return;
    dashNotifier.value--;
    isDashing = true;

    _dashTimer = dashDuration;
    _dashCooldownTimer = dashCooldown;

    _dashDirection = velocityDash.normalized();
    
    // Efeito Visual: Usa children query para achar qualquer retângulo (hitbox ou visual debug)
    // Se não tiver RectangleComponent visual, pode dar erro aqui. 
    // Sugestão: Alterar a cor do GameIcon se possível, ou ignorar se não tiver rect visual.
    // children.whereType<GameIcon>().first.setColor(Colors.white); // Exemplo seguro
    
    _isInvincible = true; 
    print("DASH!");
  }

  void _handleDashMovement(double dt) {
    _dashTimer -= dt;
    position += _dashDirection * dashSpeed * dt;

    _dustSpawnTimer -= dt;
    if (_dustSpawnTimer <= 0) {
      // Reinicia o timer (0.05 significa uma nuvem a cada 0.05 segundos)
      _dustSpawnTimer = 0.025; 
      
      // Cria um deslocamento aleatório para a poeira não sair em linha reta perfeita
      final rng = Random();
      final offset = Vector2(
        (rng.nextDouble() - 0.5) * 10, // -5 a +5 no X
        (rng.nextDouble() - 0.5) * 10 + 10 // +5 a +15 no Y (Perto do pé)
      );

      // Adiciona a partícula no MUNDO (não dentro do player, senão ela se move junto com ele)
      gameRef.world.add(Dust(
        position: position + offset,
      ));
    }

    if (_dashTimer <= 0) {
      isDashing = false;
      _isInvincible = false; 
    }
  }

  void _keepInBounds() {
    double limitX = 180- 16;
    double limitY = 320 - 16;

    if (position.x < -limitX) position.x = -limitX;
    if (position.x > limitX) position.x = limitX;
    
    if (position.y < -limitY) position.y = -limitY;
    if (position.y > limitY) position.y = limitY;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Enemy && !_isInvincible) {
      takeDamage(1);
    }
  }

  void takeDamage(int amount) {
    if (healthNotifier.value <= 0) return;
    if (shieldNotifier.value > 0){
      shieldNotifier.value-- ;
      _isInvincible = true;
      _invincibilityTimer = invincibilityDuration;
      return;
    }

    healthNotifier.value -= amount;
    _isInvincible = true;
    _invincibilityTimer = invincibilityDuration;
    
    print("Dano recebido! Vida restante: ${healthNotifier.value}");

    if (healthNotifier.value <= 0) {
      _die();
    }
  }

  void _handleInvincibility(double dt) {
    if (_isInvincible) {
      _invincibilityTimer -= dt;
      
      final icon = children.whereType<GameIcon>().firstOrNull;
      if (icon != null) {
        if (_invincibilityTimer % 0.2 < 0.1) {
           icon.setColor(Pallete.vermelho.withOpacity(0.5));
        } else {
           icon.setColor(Pallete.branco);
        }
      }

      if (_invincibilityTimer <= 0) {
        _isInvincible = false;
        icon?.setColor(Pallete.branco);
      }
    }
  }

  void _die() {
    print("GAME OVER");
    gameRef.onGameOver();
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
    final direction = (target.position - position).normalized();
    double dmg = damage;

    if(isBerserk && healthNotifier.value == 1) dmg = dmg * 1.4;
    if(isAudaz && shieldNotifier.value == 0) dmg = dmg * 1.33;
    
    gameRef.world.add(Projectile(position: position.clone(), direction: direction, damage: dmg));
  }

  void reset() {
    maxHealth = 3;
    healthNotifier.value = 3;
    _isInvincible = false;
    _invincibilityTimer = 0;
    velocity = Vector2.zero();

    speed = 150;
    attackRange = 200; 
    _attackTimer = 0;
    damage = 10.0;
    fireRate = 0.4; 
    moveSpeed = 150.0;
    dashDuration = 0.2; 
    dashSpeed = 450;    
    dashCooldown = 1.0; 
    invincibilityDuration = 0.5;
    isBerserk = false;

    children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (other is Wall) {
      _handleWallCollision(intersectionPoints, other);
    }
  }

  void _handleWallCollision(Set<Vector2> points, PositionComponent wall) {
    final separationVector = (position - wall.position).normalized();
    position += separationVector * 2.0; 
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_dashCooldownTimer > 0) {
      const double barHeight = 4.0;
      final double barWidth = size.x; 
      final double yOffset = size.y + 5; 

      double percent = _dashCooldownTimer / dashCooldown;

      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth, barHeight),
        Paint()..color = Pallete.preto.withOpacity(0.5),
      );

      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth * percent, barHeight),
        Paint()..color = Pallete.verdeCla,
      );
    }
  }

  // UPGRADES
  void increaseDamage() { 
    damage *= 1.25; 
  }

  void increaseFireRate() { 
    fireRate *= 0.85; 
    if (fireRate < 0.1) fireRate = 0.1; 
  }

  void increaseMovementSpeed(){
    moveSpeed *= 1.2; 
    speed = moveSpeed; 
  }
  
  void increaseRange(){ 
    attackRange *= 1.2; 
    _rangeIndicator.radius = attackRange;
  }

  void increaseHp(){ 
    maxHealth++; 
    healthNotifier.value++; 
  }

  void increaseShield(){ 
    shieldNotifier.value++; 
  }
}