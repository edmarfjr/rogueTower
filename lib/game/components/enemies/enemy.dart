import 'dart:math';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  bool isInvencivel = false;
  bool isIntangivel = false;
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
  late double _baseSpeed;
  double speedInicial = 0;
  double freezeTimer = 0.0;
  bool isBurned = false;
  double burnTimer = 0.0;
  double burnTime = 2.0;
  ValueNotifier<int> burnStacks = ValueNotifier<int>(0);
  bool isPoisoned = false;
  double poisonTimer = 0.0;
  double poisonTime = 1.0;
  ValueNotifier<int> poisonStacks = ValueNotifier<int>(0);
  bool isBleed = false;
  double bleedTimer = 0.0;
  double bleedTime = 1.0;
  ValueNotifier<int> bleedStacks = ValueNotifier<int>(0);

  GameIcon? visual;
  GameIcon? burnIcon;
  GameIcon? freezeIcon;
  GameIcon? poisonIcon;
  GameIcon? bleedIcon;
  TextComponent? burnText;
  TextComponent? poisonText;
  TextComponent? bleedText;
  Vector2 _lastPosition = Vector2.zero();
  double _animAmplitude = 0.1;
  double _animTimer = 0;
  final double _animSpeed = 15.0;
  bool animado;
  bool flipOposto;
  double _ghostTimer = 0;
  bool hasGhostEffect;
  
  // COMPONENTES DE LÓGICA (Strategy Pattern)
  late MovementBehavior movementBehavior;
  late AttackBehavior attackBehavior;
  AttackBehavior? attack2Behavior;
  late DeathBehavior deathBehavior;
  final IconData iconData;

  final bool hasShield;

  final Vector2 _collisionBuffer = Vector2.zero();

  final bool isDummy;

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
    this.hasGhostEffect = false,
    this.iconData = Icons.pest_control_rodent,
    this.originalColor = Pallete.vermelho,
    this.isDummy = false,
    Vector2? size,
    this.hasShield = false,
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
    speedInicial = speed;
    // Cria o componente visual
    final gameIcon = GameIcon(
      icon: iconData,
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    );
    
    add(gameIcon);
    
    // 2. GUARDA A REFERÊNCIA AQUI!
    visual = gameIcon;

    add(RectangleHitbox(
      size: size, 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));

    if (hasShield) {
      List<double> angles = [0, pi/2, pi, 3*pi/2];
      for (var ang in angles) {
        add(OrbitalShield(
          owner: this,
        //radius: size.x, 
          speed: 4.0,
          isEnemy: true,
          angleOffset: ang,
        ));
      }
    }
  }

  @override
  void update(double dt) {
    if(_initTimer > 0){
      _initTimer -= dt;
      return;
    }

    super.update(dt);
    movementBehavior.update(dt);
    attackBehavior.update(dt);
    attack2Behavior?.update(dt);
    
    _keepInsideArena();

    _updateStatus(dt);

    if ( animado )_animateEnemy(dt);
  }
  
 void _createGhostEffect(double dt) {
   // final visual = children.whereType<GameIcon>().first;
    if (visual == null) return;
    _ghostTimer += dt;
    if (_ghostTimer >= 0.1) {
      gameRef.world.add(
        GhostParticle(
          icon: visual!.icon,
          color: originalColor.withOpacity(0.3),
          position: position.clone(), 
          size: size,
          anchor: anchor,
          scale: visual!.scale
        ),
      );
      _ghostTimer = 0;
    }
  }
  
  void _animateEnemy(double dt) {
    //final visual = children.whereType<GameIcon>().firstOrNull;
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
      facingDirection = visual!.scale.x.sign; 
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
      visual?.scale.y = stretchY;
      visual?.scale.x = facingDirection * squashX; // Multiplica pela direção do Flip
      
      // (Opcional) Rotação leve: gingado para os lados (Waddle)
      if (!rotates) {
         visual?.angle = wave * 0.1; // Gira levemente (-0.1 a 0.1 radianos)
      }

    } else {
      // RESET (IDLE)
      // Se parou, volta ao normal
      _animTimer = 0;
      visual?.scale.y = 1.0;
      visual?.scale.x = facingDirection; // Mantém o lado que estava olhando
      if (!rotates) visual?.angle = 0;
    }

    // Atualiza a posição anterior para o próximo frame
    _lastPosition.setFrom(position);

      if(hasGhostEffect) _createGhostEffect(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Repassa colisão para o movimento (Ex: Bouncer precisa saber se bateu)
    movementBehavior.onCollision(intersectionPoints, other);

    if (other is Wall && !voa) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 1.0);
    } 
    // COLISÃO COM INIMIGOS (Lógica de Peso)
    else if (other is Enemy && !voa) {
      _handleEnemyCollision(other);
    }
  }

  void _handleEnemyCollision(Enemy other) {
    // 1. Se eu sou MAIS PESADO que o outro, eu NÃO me movo
    if (this.weight > other.weight) {
       return; 
    }

    // 2. Se temos o MESMO PESO, nos empurramos igualmente
    if (this.weight == other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 1.0); 
    }

    // 3. Se sou MAIS LEVE, sou empurrado com força
    if (this.weight < other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 3.0);
    }
  }

  void takeDamage(double damage) {
    if (hp <= 0) return;
    bool isCrit = false;
    double dmg = damage;
    double critChance = Random().nextDouble() * 100;

    if (critChance <= gameRef.player.critChance) {
      dmg *= gameRef.player.critDamage;
      isCrit = true;
    }
    hp -= dmg;
    
    // Lógica de Freeze
    if(gameRef.player.isFreeze){
      final rng = Random();
      if (rng.nextDouble() <= 0.8){
        setFreeze();
      }
    }

    // Lógica de burn
    if(gameRef.player.isBurn){
      if (burnStacks.value < 5 + gameRef.player.stackBonus){
        setBurn();     
      }
    }

    // Lógica de poison
    if(gameRef.player.isPoison){
      if (poisonStacks.value < 10 + gameRef.player.stackBonus){
        setPoison();
      }
    }

    // Lógica de bleed
    if(gameRef.player.isBleed){
      if (bleedStacks.value < 15 + gameRef.player.stackBonus){
        setBleed();
      }
    }

    // Flash Branco
    if (!_isHit) { 
        _isHit = true; 
        _hitTimer = 0.1; 
        visual!.setColor(Pallete.branco);
    }

    Color cor = Pallete.branco;
    double fontSize = 14;

    if(isCrit){
      cor = Pallete.amarelo;
      fontSize = 18;
    } 

    gameRef.world.add(FloatingText(
      text: dmg.toInt().toString(),
      position: position + Vector2(0, -10), 
      color: cor, 
      fontSize: fontSize,
    ));

    if (hp <= 0) {
      AudioManager.playSfx('enemy_die.mp3');
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

  void setFreeze(){
    isFreeze = true;
    speed = speed/4;

    freezeIcon = GameIcon(
      icon: Icons.ac_unit,
      color: Pallete.azulCla,
      size: size/4,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - size.y / 4), 
    );
    
    add(freezeIcon!);
  }

  void setBurn(){
    isBurned = true;
    burnStacks.value += 1;

    if (burnIcon == null){
      burnIcon = GameIcon(
      icon: MdiIcons.fire,
      color: Pallete.laranja,
      size: size/2,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, - size.y / 4), 
    );
    
      add(burnIcon!);
    }

    if (burnText == null){
      burnText = TextComponent(
        text: burnStacks.value.toString(),
        position: Vector2((size.x/2) - 5, - size.y / 4),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Pallete.laranja,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      add(burnText!);
    }
  }
  

  void setBleed(){
    isBleed = true;
    bleedStacks.value += 1;

    bleedIcon = GameIcon(
      icon: MdiIcons.heart,
      color: Pallete.vermelho,
      size: size/2,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, - size.y / 4), 
    );
    
    add(bleedIcon!);

    if (bleedText == null){
      bleedText = TextComponent(
        text: bleedStacks.value.toString(),
        position: Vector2((size.x/2) - 5, - size.y / 4),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Pallete.vermelho,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      add(bleedText!);
    }
  }

  void setPoison(){
    isPoisoned = true;
    poisonStacks.value += 1;

    poisonIcon = GameIcon(
      icon: MdiIcons.water,
      color: Pallete.verdeCla,
      size: size/2,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, - size.y / 4), 
    );
    
    add(poisonIcon!);

    if (poisonText == null){
      poisonText = TextComponent(
        text: poisonStacks.value.toString(),
        position: Vector2((size.x/2) - 5, - size.y / 4),
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Pallete.verdeCla,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      add(poisonText!);
    }
  }

  void _updateStatus(double dt) {
    // Freeze
    if (isFreeze){
      freezeTimer += dt;
      if (freezeTimer >= 5.0){
        isFreeze = false;
        freezeTimer = 0.0;
        speed = _baseSpeed;
        if (visual == null) return;
        visual?.setColor(originalColor);
        if (freezeIcon != null) {
         freezeIcon!.removeFromParent();
        }
      }
    }
    // Burn
    if (isBurned){
      burnTimer += dt;
      if (burnTimer >= burnTime){
        burnStacks.value -= 1;
        
        burnTimer = 0.0;
        if (burnStacks.value <= 0) {
          isBurned = false;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (burnIcon != null) {
            burnIcon!.removeFromParent();
          }
          if (burnText != null) {
            burnText!.removeFromParent();
          }
        }else{
          takeDamage(5 *gameRef.player.dot);
        }
        
      }
    }
     // Poison
    if (isPoisoned){
      poisonTimer += dt;
      if (poisonTimer >= poisonTime){
        poisonStacks.value -= 1;
        
        poisonTimer = 0.0;
        if (poisonStacks.value <= 0) {
          isPoisoned = false;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (poisonIcon != null) {
            poisonIcon!.removeFromParent();
          }
        }else{
          takeDamage(3 *gameRef.player.dot);
        }
        
      }
    }
     // Bleed
    if (isBleed){
      bleedTimer += dt;
      if (bleedTimer >= bleedTime){
        bleedStacks.value -= 1;
        
        bleedTimer = 0.0;
        if (bleedStacks.value <= 0) {
          isBleed = false;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (bleedIcon != null) {
            bleedIcon!.removeFromParent();
          }
        }else{
          takeDamage(2 *gameRef.player.dot);
        }
        
      }
    }
    // Hit Flash
    if (_isHit) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        _isHit = false;
        Color cor = originalColor;
        if (isFreeze) cor = Pallete.azulCla;
        if (visual == null) return;
        visual?.setColor(cor);
      }
    }

  }
}