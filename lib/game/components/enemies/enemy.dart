import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart'; 
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../effects/floating_text.dart';
import 'enemy_behaviors.dart'; 

class Enemy extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  double _initTimer = 0.5;
  // Status
  double hp;
  double speed;
  int soul;
  bool rotates;
  double rotateOff;
  double weight;
  bool voa;
  // Controle
  bool canMove = true; // Behaviors podem travar isso (ex: Laser)
  late Color originalColor;
  
  // Efeitos de Status
  bool _isHit = false;
  double _hitTimer = 0;
  bool isFreeze = false;
  double get speedInicial => _baseSpeed;
  late double _baseSpeed;
  double freezeTimer = 0.0;

  // --- VARIÁVEIS DE ANIMAÇÃO (RESTAURADAS) ---
  Vector2 _lastPosition = Vector2.zero();
  double _animAmplitude = 0.1;
  double _animTimer = 0;
  final double _animSpeed = 15.0;
  bool animado;
  bool flipOposto;
  
  // COMPONENTES DE LÓGICA (Strategy Pattern)
  late MovementBehavior movementBehavior;
  late AttackBehavior attackBehavior;
  AttackBehavior? attack2Behavior;
  late DeathBehavior deathBehavior;
  final IconData iconData;

  Enemy({
    required Vector2 position,
    required this.movementBehavior,
    required this.attackBehavior,
    DeathBehavior? deathBehavior,
    this.attack2Behavior,
    this.hp = 30,
    this.speed = 80,
    this.soul = 1,
    this.weight = 1.0,
    this.rotates = false,
    this.rotateOff = pi/2,
    this.voa = false,
    this.animado = true,
    this.flipOposto = false,
    this.iconData = Icons.pest_control_rodent,
    this.originalColor = Pallete.vermelho,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2.all(32), anchor: Anchor.center) {
    this.deathBehavior = deathBehavior ?? NoDeathEffect();
    _baseSpeed = speed;
    // Vincula os behaviors a este inimigo
    movementBehavior.enemy = this;
    attackBehavior.enemy = this;
    this.deathBehavior.enemy = this;
    if (attack2Behavior != null) {
      attack2Behavior!.enemy = this;
    }
  }

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: iconData,
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    ));

    add(RectangleHitbox(
      size: size, 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));
  }

  @override
  void update(double dt) {
    if(_initTimer > 0){
      _initTimer -= dt;
      return;
    }

    super.update(dt);
    
    // 1. Executa Comportamentos
    movementBehavior.update(dt);
    attackBehavior.update(dt);
    attack2Behavior?.update(dt);
    

    // 2. Mantém na Arena (Lógica Global)
    _keepInsideArena();

    // 3. Status Effects (Freeze, Hit Flash)
    _updateStatus(dt);

    if ( animado )_animateEnemy(dt);
  }
  
  // Substitua o método antigo por este:
  void _animateEnemy(double dt) {
    final visual = children.whereType<GameIcon>().firstOrNull;
    if (visual == null) return;

    // 1. FLIP (Olhar para o Player)
    // Define a direção base: 1.0 (Direita) ou -1.0 (Esquerda)
    double facingDirection = 1.0;
    if(flipOposto)facingDirection = -1.0;
    
    if (!rotates) {
      final player = gameRef.player;
      if (player.position.x < position.x) {
        facingDirection = -1.0;
        if(flipOposto)facingDirection = 1.0; 
      }
    } else {
      // Se o inimigo rotaciona (ex: Boss/Spinner), ignoramos o flip X
      // Mas precisamos manter a escala X consistente com a animação abaixo
      facingDirection = visual.scale.x.sign; 
      if (facingDirection == 0) facingDirection = 1.0;
    }

    // 2. DETECTAR SE ESTÁ SE MOVENDO
    double displacement = position.distanceTo(_lastPosition);
    bool isMoving = displacement > 0.5; // Limiar de movimento

    // 3. ANIMAÇÃO DE CAMINHADA (SQUASH & STRETCH)
    if (isMoving) {
      _animTimer += dt * _animSpeed; // Velocidade da animação (12.0)

      // Senoide que vai de -1 a 1 suavemente
      double wave = sin(_animTimer);

      // Efeito de "Respirar/Correr":
      // Quando Y estica, X encolhe (preservação de volume visual)
      double stretchY = 1.0 + (wave * _animAmplitude); // Ex: vai de 0.9 a 1.1
      double squashX = 1.0 - (wave * _animAmplitude); 

      // Aplica as transformações
      visual.scale.y = stretchY;
      visual.scale.x = facingDirection * squashX; // Multiplica pela direção do Flip
      
      // (Opcional) Rotação leve: gingado para os lados (Waddle)
      if (!rotates) {
         visual.angle = wave * 0.1; // Gira levemente (-0.1 a 0.1 radianos)
      }

    } else {
      // RESET (IDLE)
      // Se parou, volta ao normal
      _animTimer = 0;
      visual.scale.y = 1.0;
      visual.scale.x = facingDirection; // Mantém o lado que estava olhando
      if (!rotates) visual.angle = 0;
    }

    // Atualiza a posição anterior para o próximo frame
    _lastPosition.setFrom(position);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Repassa colisão para o movimento (Ex: Bouncer precisa saber se bateu)
    movementBehavior.onCollision(intersectionPoints, other);

    if (other is Wall) {
      final separation = (position - other.position).normalized();
      position += separation * 1.0; 
    } 
    // COLISÃO COM INIMIGOS (Lógica de Peso)
    else if (other is Enemy && !voa) {
      _handleEnemyCollision(other);
    }
  }

  void _handleEnemyCollision(Enemy other) {
    // 1. Se eu sou MAIS PESADO que o outro, eu NÃO me movo (sou uma rocha)
    if (this.weight > other.weight) {
       return; 
    }

    // 2. Se temos o MESMO PESO, nos empurramos igualmente
    if (this.weight == other.weight) {
      final separation = (position - other.position).normalized();
      position += separation * 1.0; 
    }

    // 3. Se sou MAIS LEVE, sou empurrado com força
    if (this.weight < other.weight) {
      final separation = (position - other.position).normalized();
      position += separation * 3.0; // Empurrão forte
    }
  }

  void takeDamage(double damage) {
    if (hp <= 0) return;
    hp -= damage;
    
    // Lógica de Freeze
    if(gameRef.player.isFreeze){
      final rng = Random();
      if (rng.nextDouble() <= 0.8){
        isFreeze = true;
        speed = speed/4;
      }
    }

    // Flash Branco
    if (!_isHit) { 
        _isHit = true; 
        _hitTimer = 0.1; 
        children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
    }

    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position + Vector2(0, -10), 
      color: Colors.white, 
      fontSize: 14,
    ));

    if (hp <= 0) {
      deathBehavior.onDeath();
      gameRef.progress.addSouls(soul);
      removeFromParent();
    }
  }

  void _keepInsideArena() {
    double halfWidth = TowerGame.arenaWidth / 2;
    double halfHeight = TowerGame.arenaHeight / 2;
    double padding = size.x / 2; 

    position.x = position.x.clamp(-halfWidth + padding, halfWidth - padding);
    position.y = position.y.clamp(-halfHeight + padding, halfHeight - padding);
  }

  void _updateStatus(double dt) {
    // Freeze
    if (isFreeze){
      freezeTimer += dt;
      if (freezeTimer >= 5.0){
        isFreeze = false;
        freezeTimer = 0.0;
        speed = _baseSpeed;
        children.whereType<GameIcon>().firstOrNull?.setColor(originalColor);
      }
    }
    // Hit Flash
    if (_isHit) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        _isHit = false;
        Color cor = originalColor;
        if (isFreeze) cor = Pallete.azulCla;
        children.whereType<GameIcon>().firstOrNull?.setColor(cor);
      }
    }
  }
}