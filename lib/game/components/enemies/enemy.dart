import 'dart:math';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/effects/ghost_particle.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:TowerRogue/game/components/gameObj/chest.dart';
import 'package:TowerRogue/game/components/gameObj/collectible.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:TowerRogue/game/components/projectiles/projectile.dart';
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
  late Color auxColor;
  double _meleeCooldown = 0.0;

  // --- VARIÁVEIS DE KNOCKBACK ---
  final Vector2 knockbackVelocity = Vector2.zero();
  final double _knockbackFriction = 1500.0;
  
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
  MovementBehavior encolhidoBehavior = FollowPlayerBehavior(speedMod:-1);
  PositionComponent? lureTarget;
  bool isCharmed = false;
  bool encolhido = false;
  double encolhidoTimer = 0.0;
  double encolhidoTime = 3.0;
  bool isFear = false;
  double fearTimer = 0.0;
  double fearTime = 5.0;
  double fearTimeBase = 5.0;
  
  // --- VARIÁVEIS DA AURA VISUAL ---
  double _auraTimer = 0; // Timer para a aura "pulsar"
  
  // CACHE DE TINTAS PARA A AURA (Evita lags por Garbage Collection)
  Paint championAuraPaint = Paint()..color = Pallete.laranja.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _poisonAuraPaint = Paint()..color = Pallete.verdeCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _bleedAuraPaint = Paint()..color = Pallete.vermelho.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _freezeAuraPaint = Paint()..color = Pallete.azulCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  GameIcon? visual;
  late ShadowComponent _shadow;
  late RectangleHitbox _hitbox;
  GameIcon? burnIcon;
  GameIcon? freezeIcon;
  GameIcon? poisonIcon;
  GameIcon? bleedIcon;
  GameIcon? confuseIcon;
  GameIcon? charmIcon;
  GameIcon? fearIcon;
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
  final bool hasFlail;
  final Vector2 _collisionBuffer = Vector2.zero();
  final bool isDummy;

  late final Vector2 hbSize;
  late final Vector2 hbOffset;

  bool pocaVenenoQuandoMorre = false;

  List<CollectibleType> dropList;

  int championType;
  bool noChamp;
  bool dropChest = false;
  bool isSpectral = false;

  double dmg = 1;

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
    this.hasFlail = false,
    this.isBoss = false,
    this.dropList = const [],
    this.championType = 0,
    this.noChamp = false,
  }) : super(position: position, size: size ?? Vector2.all(32), anchor: Anchor.center) {
    this.deathBehavior = deathBehavior ?? NoDeathEffect();
    _baseSpeed = speed;
    movementBehavior.enemy = this;
    attackBehavior.enemy = this;
    confuseBehavior.enemy = this;
    encolhidoBehavior.enemy = this;
    this.deathBehavior.enemy = this;
    if (attack2Behavior != null) {
      attack2Behavior!.enemy = this;
    }
    this.hbSize = hbSize ?? this.size;
    this.hbOffset = hbOffset ?? Vector2.zero();
    
  }

  @override
  Future<void> onLoad() async {

    auxColor = originalColor;

    if(!noChamp && championType == 0)criaChampion();
    if(championType > 0) setChampion();

    speedInicial = speed;

    hp = (hp * gameRef.difficultyMultiplier).ceil().toDouble();
    
    visual = GameIcon(
      icon: iconData,
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    );
    add(visual!);

    _hitbox=RectangleHitbox(
      size: hbSize , 
      anchor: Anchor.center,
      position: size / 2 + hbOffset, 
      isSolid: true,
    );

    add(_hitbox);

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

    if (hasFlail) {
      add(OrbitalShield(
        owner: this,
        speed: 8.0,
        isEnemy: true,
        angleOffset: 0,
        radius: size.y * 2,
        isFlail: true
      ));
    }

    
    _shadow=ShadowComponent(parentSize: size);
    add(_shadow);

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

  void criaChampion(){
    int rng = Random().nextInt(100);
    if(rng <= 10 && rng > 5){
      championType = Random().nextInt(5) + 1;
    }else if(rng <5){
      championType = Random().nextInt(4) + 6;
    }
  }

  void setChampion(){
    size *= 1.3;
    hbSize * 1.3;
    hbOffset * 1.3;
    double hpBonus = 2;

    switch(championType){
      case 0:
        break;
      case 1:
        originalColor = Pallete.vermelho;
        hpBonus = 2.5;
        dropList = [CollectibleType.potion];
        break;
      case 2:
        originalColor = Pallete.lilas;
        dropList = [CollectibleType.bomba];
        break;
      case 3:
        originalColor = Pallete.amarelo;
        dropList = [CollectibleType.key];
        speed *= 1.5;
        break;
      case 4:
        originalColor = Pallete.azulCla;
        dropList = [CollectibleType.shield];
        break;
      case 5:
        originalColor = Pallete.verdeEsc;
        break;
      case 6:
        originalColor = Pallete.laranja;
        dropList = [CollectibleType.coin];
        break;
      case 7:
        originalColor = Pallete.branco.withOpacity(0.1);
        isSpectral = true;
        dropChest = true;
        voa = true;
        break; 
      case 8:
        originalColor = Pallete.branco;
        dropList = [CollectibleType.healthContainer];
        break;
      case 9:
        originalColor = Pallete.rosa;
        var itens = retornaItensComuns(gameRef.player);
        dropList = [itens[0]];
        break;
        
    }

    dmg = 2;
    hp *= hpBonus;
    championAuraPaint = Paint()..color = originalColor.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
  }

  @override
  void update(double dt) {
    if(_initTimer > 0){
      _initTimer -= dt;
      return;
    }

    super.update(dt);
    
    if(gameRef.player.isPac && !isFear){
      setFear();
      fearTime = 6.0;
    }
    
    // Atualiza o timer da aura visual
    if(championType>0) _auraTimer += dt * 5; 

    if (_meleeCooldown > 0) {
      _meleeCooldown -= dt;
    }

    _handleKnockBack(dt);

    if(encolhido || isFear){
      encolhidoBehavior.update(dt);
    }
    else if(isConfuse){
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
      //comportamento normal
      attackBehavior.update(dt);
      attack2Behavior?.update(dt);

      if (championType == 9) {
      const double pullRadius = 600.0; // O tamanho do campo gravitacional
      const double playerPullForce = 50.0; // Quão forte puxa o player (pixels por segundo)
      const double projGravity = 4.0; // Quão rápido curva os tiros do player

      // 1. ATRAIR O PLAYER
      final player = gameRef.player;
      double distToPlayer = absoluteCenter.distanceTo(player.absoluteCenter);
      
      if (distToPlayer < pullRadius) {
        // Cria um vetor que aponta do player PARA o inimigo
        Vector2 pullDir = (absoluteCenter - player.absoluteCenter).normalized();
        
        // Arrasta o jogador contra a vontade dele!
        player.position += pullDir * playerPullForce * dt;
      }

      // 2. ATRAIR OS TIROS (Projéteis)
      // Pega em todos os projéteis que estão no mundo
      final projectiles = gameRef.world.children.whereType<Projectile>();
      
      for (var proj in projectiles) {
        // Se o tiro NÃO for do inimigo (ou seja, é um tiro do player tentando acertá-lo)
        if (!proj.isEnemyProjectile) {
          double distToProj = absoluteCenter.distanceTo(proj.absoluteCenter);
          
          if (distToProj < pullRadius) {
            // Vetor que aponta do tiro PARA o inimigo
            Vector2 pullDir = (absoluteCenter - proj.absoluteCenter).normalized();
            
            // EFEITO GRAVIDADE: Entorta a direção do tiro em direção ao buraco negro
            proj.direction = (proj.direction + (pullDir * projGravity * dt)).normalized();
            
            // Atualiza a rotação do sprite para o tiro virar de lado visualmente!
            proj.angle = atan2(proj.direction.y, proj.direction.x);
          }
        }
      }
    }

    }



    _keepInsideArena();
    _updateStatus(dt);

    if (animado) _animateEnemy(dt);

    priority = position.y.toInt();
  }

  // --- LÓGICA DE RENDERIZAÇÃO DA AURA ---
  @override
  void render(Canvas canvas) {
    // 1. Desenha as auras PRIMEIRO para ficarem atrás do inimigo
    if (championType > 0) {
      // Cria uma pulsação matemática suave que vai de 0.9 a 1.1x do tamanho
      double pulse = sin(_auraTimer) * 0.1 + 1.0; 
      double baseRadius = size.x / 2;
      final center = Offset(size.x / 2, size.y / 2);

      canvas.drawCircle(center, baseRadius * pulse, championAuraPaint);

      // Usamos multiplicadores levemente diferentes (1.0, 0.9, 1.1) 
      // para que, se o inimigo tomar todas as condições juntas, as auras
      // não sobreponham perfeitamente umas as outras, mesclando as cores.
      //if (isBurned) canvas.drawCircle(center, baseRadius * pulse, _burnAuraPaint);
      //if (isBleed) canvas.drawCircle(center, (baseRadius * 1.1) * pulse, _bleedAuraPaint);
      //if (isPoisoned) canvas.drawCircle(center, (baseRadius * 0.9) * pulse, _poisonAuraPaint);
      //if (isFreeze) canvas.drawCircle(center, (baseRadius * 0.8) * pulse, _freezeAuraPaint);
      if (championType == 9) {
        final center = Offset(size.x / 2, size.y / 2);
        
        /*final pullPaint = Paint()
          ..color = Pallete.lilas.withOpacity(0.15)
          ..style = PaintingStyle.fill;
        */  
        final borderPaint = Paint()
          ..color = Pallete.rosa.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        //canvas.drawCircle(center, 150.0, pullPaint);
        canvas.drawCircle(center, 80.0, borderPaint);
        canvas.drawCircle(center, 40.0, borderPaint);
      }
    }

    // 2. Chama o método original para desenhar o Ícone e as TextComponents do Flame por cima
    super.render(canvas); 
  }
  
  
 void _createGhostEffect(double dt) {
    if (visual == null) return;
    _ghostTimer += dt;
    if (_ghostTimer >= 0.1) {
      gameRef.world.add(
        GhostParticle(
          icon: visual!.icon,
          color: originalColor.withOpacity(0.3),
          position: position.clone() - Vector2(0, size.y/5), 
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
        if (_meleeCooldown <= 0) {
          takeDamage(gameRef.player.damage / 2,critico:false);
          _meleeCooldown = 0.5; 
          other._meleeCooldown = 0.5;
          setKnockBack(other);
        }
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

  void takeDamage(double damage, {bool isDot = false, critico = true}) 
  { 
    if (hp <= 0) return;
    if(championType == 8){
      final allEnemies = gameRef.world.children.query<Enemy>();
      
      final realEnemies = allEnemies.where((enemy) => !enemy.isDummy && !enemy.isCharmed && enemy.championType != 8);

      print('inimigos: ${realEnemies.length}');
      if (realEnemies.isNotEmpty){
        return;
      }
    }
    bool isCrit = false;
    double dmg = damage;
    double critChance = Random().nextDouble() * 100;

    if (critChance <= gameRef.player.returnCritChance() && critico) {
      dmg *= gameRef.player.critDamage;
      isCrit = true;
    }

    if(gameRef.player.eutanasia){
      if(Random().nextInt(100) <= 3){
        if(isBoss){
          dmg *= 3;
        }else{
          dmg = hp;
        }

      }
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

      if(gameRef.player.isPoison || gameRef.player.tempPoison){
        setPoison(alastra: gameRef.player.isPoisonAlastra || gameRef.player.tempPoisonAlastra);
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
      gameRef.shakeCamera(intensity: 1.0, duration: 0.1);
      //gameRef.triggerHitStop(0.1);
      cor = Pallete.amarelo;
      fontSize = 18;
      if(gameRef.player.confuseOnCrit){
        setConfuse();
      }
      if(gameRef.player.charmOnCrit){
        setCharm();
      }
      if(gameRef.player.encolheOnCrit){
        setEncolhido();
      }
      
      if(gameRef.player.isCritHeal){
        double rng = Random().nextDouble();
        if(rng < 0.5){
          gameRef.world.add(FloatingText(
            text: 'Cura!',
            position: gameRef.player.position.clone() + Vector2(0, -10), 
            //color: Pallete.branco, 
            fontSize: 14,
          ));
          gameRef.player.curaHp(1);
        } 
      }
    } 

    if (dmg > 0){
      gameRef.world.add(FloatingText(
        text: dmg.toInt().toString(),
        position: position.clone() + Vector2(0, -10), 
        color: cor, 
        fontSize: fontSize,
      ));
    }
    

    if (hp <= 0) {
      die();
    }
  }

  void die() {
    if (gameRef.player.primeiroInimigoPocaVeneno && !gameRef.primeiroInimigoPocaVeneno){
      gameRef.primeiroInimigoPocaVeneno = true;
      pocaVenenoQuandoMorre = true;
    }

    if(gameRef.player.killCharge > -1){
      gameRef.player.killCharge ++;
      if(gameRef.player.killCharge == 10){
        gameRef.player.rechargeActiveItem();
        gameRef.player.killCharge = 0;
      }
    }

    if(pocaVenenoQuandoMorre){
      gameRef.world.add(
        PoisonPuddle(
          position: position.clone() + Vector2(0, size.y/2), 
          isPlayer: true,
          alastra: true,
          size: Vector2.all(80)
        ));
    }

    if(isDummy && !gameRef.killDummy) gameRef.killDummy = true;

    if(championType == 2){
      gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:true, damage:2, radius:80));
    }else if(championType == 4){
        for (int i = 0; i < 8; i++) {
        double angle =(i * (2 * pi / 8));
        Vector2 direction = Vector2(cos(angle), sin(angle));
        gameRef.world.add(Projectile(
          position: position + direction * 20,
          direction: direction,
          damage: 1,
          speed: 200,
          size: Vector2.all(15),
          dieTimer: 3.0,
          isEnemyProjectile: true,
        ));
      }
    }else if(championType == 5){
      _splitIntoTwoNormalEnemies();
    } 

    AudioManager.playSfx('enemy_die.mp3');
    deathBehavior.onDeath();
    gameRef.progress.addSouls(soul);
    gameRef.soulsTotal += soul;

    if (dropList.isNotEmpty || dropChest){
      //difuldades maiores, os campeoes tem chance de 33% de drop
      if(championType > 0 && gameRef.difficultyMultiplier >= 2.0){
        int rnd = Random().nextInt(100);
        if(rnd > 33) removeFromParent();
      }

      if(dropChest){
        gameRef.world.add(Chest(position: position.clone(),isLock: true));
      }else{
        dropList.shuffle();
        final item = Collectible(position: position.clone(), type: dropList[0]);
          gameRef.world.add(item);
          double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
          double altura = Random().nextDouble() * 100 + 150 * -1;
          item.pop(Vector2(direcaoX, 0), altura:altura);
      }
    }

    if(gameRef.player.isPac) gameRef.player.curaHp(1);

    removeFromParent();
  }

  Enemy criaCopiaNormal(Vector2 novaPos){
    return Enemy(
		position : novaPos ,
		movementBehavior: movementBehavior,
		attackBehavior:attackBehavior,
		deathBehavior: deathBehavior,
		attack2Behavior:attack2Behavior,
		hp : hp,
		speed : speed,
		soul : soul,
		weight : weight,
		rotates : rotates,
		rotateOff : rotateOff,
		voa : voa,
		animado : animado,
		flipOposto : flipOposto,
		hasGhostEffect : hasGhostEffect,
		iconData : iconData,
		originalColor : auxColor,
		isDummy : isDummy,
		size : size * 0.7,
		hbSize : hbSize * 0.7,
		hbOffset : hbOffset * 0.7,
		hasShield : hasShield,
		hasFlail : hasFlail,
		isBoss : isBoss,
		dropList : [],
		noChamp : true,
    );
  }

  void _splitIntoTwoNormalEnemies() {
    final clone1 = criaCopiaNormal(position.clone() + Vector2(-20, 0));
    final clone2 = criaCopiaNormal(position.clone() + Vector2(20, 0));

    gameRef.world.add(clone1);
    gameRef.world.add(clone2);
  }
  

  void _keepInsideArena() {
    double limitX = TowerGame.gameWidth/2 - size.x;
    double limitY = TowerGame.gameHeight/2 - size.y;
    double arenaBorder = 10;

    position.x = position.x.clamp(-limitX + arenaBorder, limitX - arenaBorder);
    position.y = position.y.clamp(-limitY + arenaBorder, limitY - arenaBorder);
  }

  void changeSize(sizeMod){
    visual!.removeFromParent();
    size = size*sizeMod;
    visual = GameIcon(
      icon: iconData, 
      color: originalColor, 
      size: size,
      anchor: Anchor.center, 
      position: size / 2,    
    );
    add(visual!);

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
  }

  void setEncolhido(){
    if (encolhido) return;
    encolhido = true;
    changeSize(0.5);
    hp *= 0.5;
    
  }

  void setCharm() {
    if (!isCharmed && !isBoss) {
      isCharmed = true;
      numCondicoes ++;
      charmIcon = GameIcon(
        icon: MdiIcons.heart,
        color: Pallete.rosa,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
      );
      
      add(charmIcon!);
    }
  }

  void setFear() {
    if (!isFear && !isBoss) {
      isFear = true;
      numCondicoes ++;
      fearIcon = GameIcon(
        icon: MdiIcons.skull,
        color: Pallete.branco,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
      );
      
      add(fearIcon!);
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
      size: size/2,
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
      size: size/2,
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

  void setPoison({bool alastra = false}){
    if(alastra) pocaVenenoQuandoMorre = true;
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
         freezeIcon = null; 
        }
      }
    }
    
    // Burn
    if (isBurned){
      burnTimer += dt;
      if (burnTimer >= burnTime){
        burnTimer = 0.0;
        burnStacks.value -= 1;

        double dmg = 5 ;
        double dot = gameRef.player.dot;
        if (gameRef.player.goldDmg){
          dot += gameRef.coinsNotifier.value * 0.01;
        }
        dmg *= dot ;
        takeDamage(dmg, isDot: true);

        burnText?.text = burnStacks.value.toString();
        
        if (burnStacks.value <= 0) {
          isBurned = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (burnIcon != null) {
            burnIcon!.removeFromParent();
            burnIcon = null; 
          }
          if (burnText != null) {
            burnText!.removeFromParent();
            burnText = null; 
          }
        }
      }
    }
    
    // Poison
    if (isPoisoned){
      poisonTimer += dt;
      if (poisonTimer >= poisonTime){
        poisonStacks.value -= 1;
        
        double dmg = 3 ;
        double dot = gameRef.player.dot;
        if (gameRef.player.goldDmg){
          dot += gameRef.coinsNotifier.value * 0.01;
        }
        dmg *= dot ;
        takeDamage(dmg, isDot: true);
        
        poisonText?.text = poisonStacks.value.toString();
        poisonTimer = 0.0;
        if (poisonStacks.value <= 0) {
          isPoisoned = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (poisonIcon != null) {
            poisonIcon!.removeFromParent();
            poisonIcon = null; 
          }
          if (poisonText != null) {
            poisonText!.removeFromParent();
            poisonText = null; 
          }
        }
      }
    }
    
    // Bleed
    if (isBleed){
      bleedTimer += dt;
      if (bleedTimer >= bleedTime){
        bleedStacks.value -= 1;
        
        double dmg = 2 ;
        double dot = gameRef.player.dot;
        if (gameRef.player.goldDmg){
          dot += gameRef.coinsNotifier.value * 0.01;
        }
        dmg *= dot ;
        takeDamage(dmg, isDot: true);
        
        bleedText?.text = bleedStacks.value.toString();
        bleedTimer = 0.0;
        if (bleedStacks.value <= 0) {
          isBleed = false;
          numCondicoes --;
          if (visual == null) return;
          visual?.setColor(originalColor);
          if (bleedIcon != null) {
            bleedIcon!.removeFromParent();
            bleedIcon = null; 
          }
          if (bleedText != null) {
            bleedText!.removeFromParent();
            bleedText = null; 
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
          confuseIcon = null; 
        }
      }
    }

    //fear
    if (isFear){
      fearTimer += dt;
      if (fearTimer >= fearTime){
        isFear = false;
        if (fearIcon != null) {
          fearIcon!.removeFromParent();
          fearIcon = null; 
        }
        fearTime = fearTimeBase;
      }
    }

    if (encolhido){
      encolhidoTimer += dt;
      if (encolhidoTimer >= encolhidoTime){
        encolhido = false;
        changeSize(2);
        hp *= 2;
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
  
  void _handleKnockBack(double dt) {
    if (!knockbackVelocity.isZero()) {
      // 1. Move o personagem na direção do empurrão
      position.addScaled(knockbackVelocity, dt);
      
      // 2. Aplica o atrito (freio)
      double drop = _knockbackFriction * dt;
      if (knockbackVelocity.length > drop) {
        // Reduz a velocidade mantendo a mesma direção
        knockbackVelocity.setFrom(knockbackVelocity - knockbackVelocity.normalized() * drop);
      } else {
        // Parou completamente
        knockbackVelocity.setZero();
      }
    }
  }
  
  void setKnockBack(other,{double force = 150}) {
    Vector2 knockbackDir = (position - other.position).normalized();
          
    double forcaDoEmpurrao = force; 

    knockbackVelocity.setFrom(knockbackDir * forcaDoEmpurrao);
  
    if(other is Enemy)other.knockbackVelocity.setFrom(-knockbackDir * forcaDoEmpurrao);
  }
}