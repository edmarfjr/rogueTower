import 'dart:math';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
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
  bool isBoss;
  // Controle
  bool canMove = true; 
  late Color originalColor;
  
  // Efeitos de Status
  bool _isHit = false;
  double _hitTimer = 0;
  bool isFreeze = false;
  late double _baseSpeed;
  double speedInicial = 0;
  double freezeTimer = 0.0;
  double freezeDuration = 3.0;
  bool isBurned = false;
  double burnTimer = 0.0;
  double burnTime = 1.0;
  ValueNotifier<int> burnStacks = ValueNotifier<int>(0);
  bool isPoisoned = false;
  double poisonTimer = 0.0;
  double poisonTime = 1.0;
  ValueNotifier<int> poisonStacks = ValueNotifier<int>(0);
  bool isBleed = false;
  double bleedTimer = 0.0;
  double bleedTime = 1.0;
  ValueNotifier<int> bleedStacks = ValueNotifier<int>(0);
  bool isConfuse = false;
  double confuseTimer = 0.0;
  double confuseTime = 3.0;
  int numCondicoes = 0;
  MovementBehavior confuseBehavior = RandomWanderBehavior();
  PositionComponent? lureTarget;
  bool isCharmed = false;

  // --- VARIÁVEIS DA AURA VISUAL ---
  //double _auraTimer = 0; // Timer para a aura "pulsar"
  
  // CACHE DE TINTAS PARA A AURA (Evita lags por Garbage Collection)
 // final Paint _burnAuraPaint = Paint()..color = Pallete.laranja.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
 // final Paint _poisonAuraPaint = Paint()..color = Pallete.verdeCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
 // final Paint _bleedAuraPaint = Paint()..color = Pallete.vermelho.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
 // final Paint _freezeAuraPaint = Paint()..color = Pallete.azulCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  GameIcon? visual;
  GameIcon? burnIcon;
  GameIcon? freezeIcon;
  GameIcon? poisonIcon;
  GameIcon? bleedIcon;
  GameIcon? confuseIcon;
  GameIcon? charmIcon;
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
  
  // COMPONENTES DE LÓGICA
  late MovementBehavior movementBehavior;
  late AttackBehavior attackBehavior;
  AttackBehavior? attack2Behavior;
  late DeathBehavior deathBehavior;
  final IconData iconData;

  final bool hasShield;
  final Vector2 _collisionBuffer = Vector2.zero();
  final bool isDummy;

  late final Vector2 hbSize;
  late final Vector2 hbOffset;

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
    Vector2? hbSize,
    Vector2? hbOffset,
    this.hasShield = false,
    this.isBoss = false,
  }) : super(position: position, size: size ?? Vector2.all(32), anchor: Anchor.center) {
    this.deathBehavior = deathBehavior ?? NoDeathEffect();
    _baseSpeed = speed;
    movementBehavior.enemy = this;
    attackBehavior.enemy = this;
    confuseBehavior.enemy = this;
    this.deathBehavior.enemy = this;
    if (attack2Behavior != null) {
      attack2Behavior!.enemy = this;
    }
    this.hbSize = hbSize ?? this.size;
    this.hbOffset = hbOffset ?? Vector2.zero();
    
  }

  @override
  Future<void> onLoad() async {
    speedInicial = speed;
    
    final gameIcon = GameIcon(
      icon: iconData,
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    );
    add(gameIcon);
    visual = gameIcon;

    add(RectangleHitbox(
      size: hbSize , 
      anchor: Anchor.center,
      position: size / 2 + hbOffset, 
      isSolid: true,
    ));

    if (hasShield) {
      List<double> angles = [0, pi/2, pi, 3*pi/2];
      for (var ang in angles) {
        add(OrbitalShield(
          owner: this,
          speed: 4.0,
          isEnemy: true,
          angleOffset: ang,
        ));
      }
    }

    add(ShadowComponent(parentSize: size));

    add(TimerComponent(
      period: 0.2, // A cada 0.2 segundos cospe uma fumaça
      repeat: true,
      onTick: () {
        // Se não tiver nenhum efeito ativo, não faz nada
        if (!isBurned && !isPoisoned && !isFreeze && !isBleed) return;

        Color particleColor = Colors.white;
        if (isBurned) particleColor = Pallete.laranja;
        if (isPoisoned) particleColor = Pallete.verdeCla;
        if (isFreeze) particleColor = Pallete.azulCla;
        if (isBleed) particleColor = Pallete.vermelho;

        final rng = Random();

        // Cria a fumaça subindo
        final particleSystem = ParticleSystemComponent(
          particle: Particle.generate(
            count: 3, // 3 bolinhas por vez
            lifespan: 0.6, // Duram meio segundo
            generator: (i) => AcceleratedParticle(
              // Gravidade invertida (sobem)
              acceleration: Vector2(0, -150), 
              // Espalha um pouco para os lados
              speed: Vector2((rng.nextDouble() - 0.5) * 60, -20), 
              position: Vector2(size.x / 2, size.y / 2),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  // Faz a partícula sumir suavemente (fade out) conforme o tempo passa
                  final paint = Paint()
                    ..color = particleColor.withOpacity(1.0 - particle.progress);
                  canvas.drawCircle(Offset.zero, 3.0, paint); // Tamanho da bolinha
                }
              ),
            ),
          ),
        );

        add(particleSystem);
      },
    ));

    
  }

  @override
  void update(double dt) {
    if(_initTimer > 0){
      _initTimer -= dt;
      return;
    }

    super.update(dt);
    
    // Atualiza o timer da aura visual
   // _auraTimer += dt * 5; 

    if(isConfuse){
      confuseBehavior.update(dt);
    }else{
      if (lureTarget != null) {
        if (!lureTarget!.isMounted) {
          lureTarget = null; 
        } else if (canMove) {
          final dir = (lureTarget!.position - position).normalized();
          position += dir * speed * dt;

          if (rotates && visual != null) {
            visual!.angle = atan2(dir.y, dir.x) + rotateOff;
          }
        }
      } 
      if (lureTarget == null) {
        movementBehavior.update(dt);
      }
      attackBehavior.update(dt);
      attack2Behavior?.update(dt);
    }
    _keepInsideArena();
    _updateStatus(dt);

    if (animado) _animateEnemy(dt);

    priority = position.y.toInt();
  }
/*
  // --- LÓGICA DE RENDERIZAÇÃO DA AURA ---
  @override
  void render(Canvas canvas) {
    // 1. Desenha as auras PRIMEIRO para ficarem atrás do inimigo
    if (isBurned || isPoisoned || isBleed || isFreeze) {
      // Cria uma pulsação matemática suave que vai de 0.9 a 1.1x do tamanho
      double pulse = sin(_auraTimer) * 0.1 + 1.0; 
      double baseRadius = size.x / 2;
      final center = Offset(size.x / 2, size.y / 2);

      // Usamos multiplicadores levemente diferentes (1.0, 0.9, 1.1) 
      // para que, se o inimigo tomar todas as condições juntas, as auras
      // não sobreponham perfeitamente umas as outras, mesclando as cores.
      //if (isBurned) canvas.drawCircle(center, baseRadius * pulse, _burnAuraPaint);
      if (isBleed) canvas.drawCircle(center, (baseRadius * 1.1) * pulse, _bleedAuraPaint);
      if (isPoisoned) canvas.drawCircle(center, (baseRadius * 0.9) * pulse, _poisonAuraPaint);
      if (isFreeze) canvas.drawCircle(center, (baseRadius * 0.8) * pulse, _freezeAuraPaint);
    }

    // 2. Chama o método original para desenhar o Ícone e as TextComponents do Flame por cima
    super.render(canvas); 
  }
  */
  
 void _createGhostEffect(double dt) {
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
    if (visual == null) return;

    double facingDirection = 1.0;
    if(flipOposto) facingDirection = -1.0;
    
    if (!rotates) {
      final player = gameRef.player;
      if (player.position.x < position.x) {
        facingDirection = -1.0;
        if(flipOposto)facingDirection = 1.0; 
      }
    } else {
      facingDirection = visual!.scale.x.sign; 
      if (facingDirection == 0) facingDirection = 1.0;
    }

    double displacement = position.distanceTo(_lastPosition);
    bool isMoving = displacement > 0.5;

    if (isMoving) {
      _animTimer += dt * _animSpeed;
      double wave = sin(_animTimer);
      double stretchY = 1.0 + (wave * _animAmplitude);
      double squashX = 1.0 - (wave * _animAmplitude); 

      visual?.scale.y = stretchY;
      visual?.scale.x = facingDirection * squashX; 
      
      if (!rotates) {
         visual?.angle = wave * 0.1; 
      }
    } else {
      _animTimer = 0;
      visual?.scale.y = 1.0;
      visual?.scale.x = facingDirection; 
      if (!rotates) visual?.angle = 0;
    }

    _lastPosition.setFrom(position);
    if(hasGhostEffect) _createGhostEffect(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    movementBehavior.onCollision(intersectionPoints, other);

    if (other is Wall && !voa) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 1.0);
    } 
    else if(other is Enemy){
      if(other.isCharmed){
        takeDamage(gameRef.player.damage / 2,critico:false);
      }else if (!voa && !other.voa|| (voa && !other.voa)) {
        _handleEnemyCollision(other);
      }
    }
  }

  void _handleEnemyCollision(Enemy other) {
    if (this.weight > other.weight) return; 

    if (this.weight == other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 1.0); 
    }

    if (this.weight < other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 3.0);
    }
  }

  void takeDamage(double damage, {bool isDot = false, critico = true}) { // <-- ADICIONADO AQUI
    if (hp <= 0) return;
    bool isCrit = false;
    double dmg = damage;
    double critChance = Random().nextDouble() * 100;

    if (critChance <= gameRef.player.critChance && critico) {
      dmg *= gameRef.player.critDamage;
      isCrit = true;
    }
    hp -= dmg;
    
    if (!isDot) {
      if(gameRef.player.isFreeze){
        final rng = Random();
        if (rng.nextDouble() <= 0.2){
          setFreeze();
        }
      }

      if(gameRef.player.isBurn){
        setBurn();
      }

      if(gameRef.player.isPoison){
        setPoison();
      }

      if(gameRef.player.isBleed){
        setBleed();
      }
    }

    if (!_isHit) { 
        _isHit = true; 
        _hitTimer = 0.1; 
        visual!.setColor(Pallete.branco);
    }

    Color cor = Pallete.branco;
    double fontSize = 14;

    if(isCrit){
      gameRef.shakeCamera(intensity: 2.0, duration: 0.1);
      gameRef.triggerHitStop(0.1);
      cor = Pallete.amarelo;
      fontSize = 18;
      if(gameRef.player.confuseOnCrit){
        setConfuse();
      }
      if(gameRef.player.charmOnCrit){
        setCharm();
      }
      
    } 

    if (dmg > 0){
      gameRef.world.add(FloatingText(
        text: dmg.toInt().toString(),
        position: position + Vector2(0, -10), 
        color: cor, 
        fontSize: fontSize,
      ));
    }
    

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    AudioManager.playSfx('enemy_die.mp3');
    deathBehavior.onDeath();
    gameRef.progress.addSouls(soul);
    removeFromParent();
  }

  void _keepInsideArena() {
    double halfWidth = TowerGame.gameWidth / 2;
    double halfHeight = TowerGame.gameHeight / 2;
    double padding = size.x / 2 + 10; 

    position.x = position.x.clamp(-halfWidth + padding, halfWidth - padding);
    position.y = position.y.clamp(-halfHeight + padding, halfHeight - padding);
  }

  void setCharm() {
    if (!isCharmed && !isBoss) {
      isCharmed = true;
      numCondicoes ++;
      charmIcon = GameIcon(
        icon: MdiIcons.heart,
        color: Pallete.rosa,
        size: size/4,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
      );
      
      add(charmIcon!);
    }
  }

  void setFreeze(){
    if (isFreeze) return;
    numCondicoes ++;
    isFreeze = true;
    if (isBoss){
        speed = speed/2;
    }else{
      speed = speed/4;
    }

    freezeIcon = GameIcon(
      icon: Icons.ac_unit,
      color: Pallete.azulCla,
      size: size/4,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
    );
    
    add(freezeIcon!);

  }

  void setConfuse(){
    if (isConfuse || isBoss) return;
    numCondicoes ++;
    isConfuse = true;

    confuseIcon = GameIcon(
      icon: MdiIcons.help,
      color: Pallete.amarelo,
      size: size/4,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
    );
    
    add(confuseIcon!);

  }

  void setBurn(){
    if (burnStacks.value >= 5 + gameRef.player.stackBonus) return;
    if(!isBurned) numCondicoes ++;
    isBurned = true;
    burnStacks.value += 1;

    if (burnIcon == null){
      burnIcon = GameIcon(
      icon: MdiIcons.fire,
      color: Pallete.laranja,
      size: size/2,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, - size.y / 4 - 10*numCondicoes), 
    );
      add(burnIcon!);
    }

    if (burnText == null){
      burnText = TextComponent(
        text: burnStacks.value.toString(),
        position: Vector2((size.x/2) - 12, - size.y / 4 - 10*numCondicoes),
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
    burnText?.text = burnStacks.value.toString();
  }
  
  void setBleed(){
    if (bleedStacks.value >= 15 + gameRef.player.stackBonus) return;
    if(!isBleed) numCondicoes ++;
    isBleed = true;
    bleedStacks.value += 1;

    // Garante recriação se já tivesse sido apagado (Correção similar ao burnIcon)
    if (bleedIcon == null) {
      bleedIcon = GameIcon(
        icon: MdiIcons.water,
        color: Pallete.vermelho,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, - size.y / 4 - 10*numCondicoes), 
      );
      add(bleedIcon!);
    }

    if (bleedText == null){
      bleedText = TextComponent(
        text: bleedStacks.value.toString(),
        position: Vector2((size.x/2) - 12, - size.y / 4 - 10*numCondicoes),
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
    bleedText?.text = bleedStacks.value.toString();
  }

  void setPoison(){
    if (poisonStacks.value >= 10 + gameRef.player.stackBonus) return;
    if(!isPoisoned) numCondicoes ++;
    isPoisoned = true;
    poisonStacks.value += 1;

    if (poisonIcon == null) {
      poisonIcon = GameIcon(
        icon: MdiIcons.water,
        color: Pallete.verdeCla,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, - size.y / 4 - 10*numCondicoes), 
      );
      add(poisonIcon!);
    }

    if (poisonText == null){
      poisonText = TextComponent(
        text: poisonStacks.value.toString(),
        position: Vector2((size.x/2) - 12, - size.y / 4 - 10*numCondicoes),
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
    poisonText?.text = poisonStacks.value.toString();
  }

  void _updateStatus(double dt) {
    // Freeze
    if (isFreeze){
      freezeTimer += dt;
      double freezeDurationEffective = isBoss ? freezeDuration / 2 : freezeDuration;
      if (freezeTimer >= freezeDurationEffective){
        isFreeze = false;
        numCondicoes --;
        freezeTimer = 0.0;
        speed = _baseSpeed;
        if (visual == null) return;
        visual?.setColor(originalColor);
        if (freezeIcon != null) {
         freezeIcon!.removeFromParent();
         freezeIcon = null; // IMPORTANTE
        }
      }
    }
    
    // Burn
    if (isBurned){
      burnTimer += dt;
      if (burnTimer >= burnTime){
        burnTimer = 0.0;
        burnStacks.value -= 1;
        takeDamage(5 *gameRef.player.dot, isDot: true);
        burnText?.text = burnStacks.value.toString();
        
        if (burnStacks.value <= 0) {
          isBurned = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (burnIcon != null) {
            burnIcon!.removeFromParent();
            burnIcon = null; // IMPORTANTE
          }
          if (burnText != null) {
            burnText!.removeFromParent();
            burnText = null; // IMPORTANTE
          }
        }
      }
    }
    
    // Poison
    if (isPoisoned){
      poisonTimer += dt;
      if (poisonTimer >= poisonTime){
        poisonStacks.value -= 1;
        takeDamage(3 *gameRef.player.dot, isDot: true);
        poisonText?.text = poisonStacks.value.toString();
        poisonTimer = 0.0;
        if (poisonStacks.value <= 0) {
          isPoisoned = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (poisonIcon != null) {
            poisonIcon!.removeFromParent();
            poisonIcon = null; // IMPORTANTE
          }
          if (poisonText != null) {
            poisonText!.removeFromParent();
            poisonText = null; // IMPORTANTE
          }
        }
      }
    }
    
    // Bleed
    if (isBleed){
      bleedTimer += dt;
      if (bleedTimer >= bleedTime){
        bleedStacks.value -= 1;
        takeDamage(2 *gameRef.player.dot, isDot: true);
        bleedText?.text = bleedStacks.value.toString();
        bleedTimer = 0.0;
        if (bleedStacks.value <= 0) {
          isBleed = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (bleedIcon != null) {
            bleedIcon!.removeFromParent();
            bleedIcon = null; // IMPORTANTE
          }
          if (bleedText != null) {
            bleedText!.removeFromParent();
            bleedText = null; // IMPORTANTE
          }
        }
      }
    }

    //confuse
    if (isConfuse){
      confuseTimer += dt;
      if (confuseTimer >= confuseTime){
        isConfuse = false;
        if (confuseIcon != null) {
          confuseIcon!.removeFromParent();
          confuseIcon = null; // IMPORTANTE
        }
      }
    }
    
    // Hit Flash
    if (_isHit) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        _isHit = false;
        Color cor = originalColor;
        if (visual == null) return;
        visual?.setColor(cor);
      }
    }
  }
}