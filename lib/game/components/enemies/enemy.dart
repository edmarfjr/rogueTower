import 'dart:math';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/effects/ghost_particle.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import 'package:towerrogue/game/components/gameObj/chest.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/projectiles/bomb.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:towerrogue/game/components/projectiles/orbital_shield.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
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

  bool _isDead = false;
  
  // Status
  double hp;
  double hpMax = 0;
  bool isInvencivel = false;
  bool isIntangivel = false;
  double speed;
  int soul;
  bool rotates;
  double rotateOff;
  double weight;
  bool voa;
  bool isBoss;
  bool isMinion;
  // Controle
  bool canMove = true; 
  bool canAttack = true;
  late Color originalColor;
  late Color auxColor;
  double _meleeCooldown = 0.0;

  double facingDirection = 1;

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
  bool isParalised = false;
  double paraliseTimer = 0.0;
  double paraliseTime = 3.0;
  
  // --- VARIÁVEIS DA AURA VISUAL ---
  double _auraTimer = 0;
  
  // CACHE DE TINTAS PARA A AURA (Evita lags por Garbage Collection)
  Paint championAuraPaint = Paint()..color = Pallete.laranja.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _poisonAuraPaint = Paint()..color = Pallete.verdeCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _bleedAuraPaint = Paint()..color = Pallete.vermelho.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
  //final Paint _freezeAuraPaint = Paint()..color = Pallete.azulCla.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

  GameSprite? visual;
  GameIcon? targetIcon;
  bool isTarget = false;
  late ShadowComponent _shadow;
  late RectangleHitbox _hitbox;
  GameIcon? burnIcon;
  GameIcon? freezeIcon;
  GameIcon? poisonIcon;
  GameIcon? bleedIcon;
  GameIcon? confuseIcon;
  GameIcon? charmIcon;
  GameIcon? fearIcon;
  GameIcon? paraliseIcon;
  TextComponent? burnText;
  TextComponent? poisonText;
  TextComponent? bleedText;
  final Vector2 _lastPosition = Vector2.zero();
  final double _animAmplitude = 0.1;
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
  final String image;

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
    this.image = "sprites/inimigos/rat.png",
    this.originalColor = Pallete.vermelho,
    this.isDummy = false,
    Vector2? size,
    Vector2? hbSize,
    Vector2? hbOffset,
    this.hasShield = false,
    this.hasFlail = false,
    this.isBoss = false,
    this.isMinion = false,
    this.dropList = const [],
    this.championType = 0,
    this.noChamp = false,
  }) : super(position: position, size: size ?? Vector2.all(16), anchor: Anchor.center) {
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

    hpMax = hp;

    auxColor = originalColor;

    if(!noChamp && championType == 0)criaChampion();
    if(championType > 0) setChampion();

    speedInicial = speed;

    hp = (hp * gameRef.difficultyMultiplier).ceil().toDouble();
    
    visual = GameSprite(
          imagePath: image,
          size: size,
          color: originalColor, 
          anchor: Anchor.center,
          position: size / 2
        );
    add(visual!);

    _hitbox=RectangleHitbox(
      size: hbSize/2 , 
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
    if(rng <= 10 + gameRef.chanceChampBonus && rng > 5 + gameRef.chanceChampBonus){
      championType = Random().nextInt(5) + 1;
    }else if(rng <= 5 + gameRef.chanceChampBonus){
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
        originalColor = Pallete.branco.withOpacity(0.2);
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
        var pocoes = retornaPocoes();
        itens.addAll(pocoes);
        itens.shuffle();
        dropList = [itens[0]];
        break;
        
    }

    dmg = 2;
    hp *= hpBonus;
    championAuraPaint = Paint()..color = originalColor.withOpacity(0.8)..maskFilter = MaskFilter.blur(BlurStyle.normal, size.x/3);
    if(championType == 7) championAuraPaint = Paint()..color = originalColor.withOpacity(0.5)..maskFilter = MaskFilter.blur(BlurStyle.normal, size.x/3);
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
    }else if(isParalised){
      // nao faz nada
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
      if(canAttack){
        attackBehavior.update(dt);
        attack2Behavior?.update(dt);
      }

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
    if(isTarget){
      final paint = Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
        
      final paintFundo = Paint()
        ..color = Pallete.preto
        ..style = PaintingStyle.fill;

      // 1. O centro perfeito do seu inimigo no Canvas local
      final center = Offset(size.x / 2, size.y);

      // 2. Linhas da mira calculadas a partir do centro
      final start1 = Offset(center.dx - size.x * 0.5, center.dy - size.y * 0.5);
      final end1 = Offset(center.dx + size.x * 0.5, center.dy + size.y * 0.5);

      final start2 = Offset(center.dx - size.x * 0.5, center.dy + size.y * 0.5);
      final end2 = Offset(center.dx + size.x * 0.5, center.dy - size.y * 0.5);

      // 3. A MÁGICA: Criar os retângulos a partir do centro para eles expandirem por igual!
      final rectFundo = Rect.fromCenter(
        center: center, 
        width: size.x, 
        height: size.y * .8
      );
      
      final rectMaior = Rect.fromCenter(
        center: center, 
        width: size.x * 1.2, 
        height: size.y * 1.0
      );
      
      // 4. Desenha tudo
      
      canvas.drawLine(start1, end1, paint);
      canvas.drawLine(start2, end2, paint);
      canvas.drawOval(rectFundo, paintFundo); 
      canvas.drawOval(rectMaior, paint); 
    }

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
   /*   gameRef.world.add(
        GhostParticle(
          icon: visual!.icon,
          color: originalColor.withOpacity(0.3),
          position: position.clone() - Vector2(0, size.y/5), 
          size: size,
          anchor: anchor,
          scale: visual!.scale
        ),
      );
      */
      _ghostTimer = 0;
    }
  }
  
  void _animateEnemy(double dt) {
    if (visual == null) return;

    // Descobre o vetor de direção calculando a diferença da posição
    Vector2 delta = position - _lastPosition;
    double displacement = delta.length;
    bool isMoving = displacement > 0.5;

    // ==========================================
    // 1. LÓGICA DE DIREÇÃO E ROTAÇÃO
    // ==========================================
    if (rotates) {
      // Inimigos que rotacionam (ex: morcegos apontam o bico pra onde voam)
      if (isMoving) {
        // atan2 descobre o ângulo do movimento. Somamos rotateOff caso o sprite original esteja "deitado"
        visual!.angle = atan2(delta.y, delta.x) + rotateOff;
      }
      facingDirection = 1.0; // Mantém a escala sempre positiva para não amassar a rotação
      
    } else {
      // Inimigos normais "flipam" (espelham horizontalmente) para olhar pro player
      final player = gameRef.player;
      facingDirection = (player.position.x < position.x) ? -1.0 : 1.0;
      if (flipOposto) facingDirection *= -1.0;
    }

    // ==========================================
    // 2. LÓGICA DE SQUASH & STRETCH (Pular/Andar)
    // ==========================================
    if (isMoving) {
      _animTimer += dt * _animSpeed;
      double wave = sin(_animTimer);
      double stretchY = 1.0 + (wave * _animAmplitude);
      double squashX = 1.0 - (wave * _animAmplitude); 

      visual!.scale.y = stretchY;
      visual!.scale.x = facingDirection * squashX; 
      
      // APENAS inimigos que NÃO rotacionam recebem o "gingado" de andar
      if (!rotates) {
         visual!.angle = wave * 0.1; 
      }
    } else {
      // Parado
      _animTimer = 0;
      visual!.scale.y = 1.0;
      visual!.scale.x = facingDirection; 
      
      if (!rotates) {
        visual!.angle = 0;
      }
    }

    _lastPosition.setFrom(position);
    if (hasGhostEffect) _createGhostEffect(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    movementBehavior.onCollision(intersectionPoints, other);

    if (other is Wall && !voa && !isSpectral) {
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
    if (weight > other.weight) return; 

    if (weight == other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 1.0); 
    }

    if (weight < other.weight) {
      _collisionBuffer.setFrom(position);
      _collisionBuffer.sub(other.position);
      _collisionBuffer.normalize();
      position.addScaled(_collisionBuffer, 3.0);
    }
  }

  void takeDamage(double damage, {bool isDot = false, critico = true}) 
  { 
    final rnd = Random();
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
    double critChance = rnd.nextDouble() * 100;

    if (critChance <= gameRef.player.returnCritChance() && critico) {
      dmg *= gameRef.player.critDamage;
      isCrit = true;
    }

    if(gameRef.player.eutanasia){
      double chance = min (1/(gameRef.player.sorte*2)*100,25);
      if(rnd.nextInt(100) <= chance){
        if(isBoss){
          dmg *= 3;
        }else{
          dmg = hp;
        }

      }
    }

    
    if(gameRef.player.charmOnCrit){
      double chance = 1/(gameRef.player.sorte/3)*100;
      if(rnd.nextInt(100) <= chance){
        setCharm();
      }
    }

    hp -= dmg;
    /*
    if (!isDot) {
      if(gameRef.player.isFreeze){
        if (rnd.nextDouble() <= 0.2){
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
    */
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
      if(gameRef.player.encolheOnCrit){
        setEncolhido();
      }
      
      if(gameRef.player.isCritHeal){
        if(rnd.nextDouble() < 0.5){
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
    final rng = Random();
    if (_isDead) return;
    _isDead = true;

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

      if(rng.nextInt(100)<= 90){
        gameRef.world.add(Bomb(
          position: position.clone(), 
          damage:1, 
          //owner: this, 
          isEnemy: true,
        ));
      }
    }else if(championType == 4){
        for (int i = 0; i < 8; i++) {
        double angle =(i * (2 * pi / 8));
        Vector2 direction = Vector2(cos(angle), sin(angle));
        gameRef.world.add(Projectile(
          position: position + direction * 20,
          direction: direction,
          damage: 1,
          speed: 200,
          hbSize: Vector2.all(15),
          dieTimer: 3.0,
          isEnemyProjectile: true,
        ));
      }
    }else if(championType == 5){
      splitIntoTwoNormalEnemies();
    } 

    AudioManager.playSfx('enemy_die.mp3');
    deathBehavior.onDeath();
    gameRef.progress.addSouls(soul);
    gameRef.soulsTotal += soul;

    if (dropList.isNotEmpty || dropChest){
      bool shouldDrop = true;
      
      if(championType > 0 && gameRef.difficultyMultiplier >= 2.0){
        if(rng.nextInt(100) > 33) shouldDrop = false; 
      }

      CollectibleType itemEquilibrio = CollectibleType.potion;
      bool itemEq = false;

      if(gameRef.player.glifoEquilibrio){
        itemEq = true;
        // quero fazer essa logica de sair do if aqui
        if(gameRef.player.healthNotifier.value == 1){
          itemEquilibrio = CollectibleType.potion;
        }
        else if(gameRef.keysNotifier.value == 0){
          itemEquilibrio = CollectibleType.key;
        }
        else if(gameRef.player.bombNotifier.value == 0){
          itemEquilibrio = CollectibleType.bomba;
        }else if(gameRef.player.healthNotifier.value % 2 != 0){
          itemEquilibrio = CollectibleType.potion;
        }else if(gameRef.coinsNotifier.value < 50){
          itemEquilibrio = CollectibleType.coin;
        }else if(gameRef.keysNotifier.value < 5){
          itemEquilibrio = CollectibleType.key;
        }else if(gameRef.player.bombNotifier.value < 5){
          itemEquilibrio = CollectibleType.bomba;
        }else if(gameRef.player.healthNotifier.value + gameRef.player.artificialHealthNotifier.value < 12){
          itemEquilibrio = CollectibleType.artificialHp;
        }else{
          itemEq = false;
        }

      }

      if(shouldDrop){
        if(dropChest && !itemEq && rng.nextBool()){
          gameRef.world.add(Chest(position: position.clone(),isLock: true));
        } else if (dropList.isNotEmpty || itemEq) {
          dropList.shuffle();
          final item = Collectible(position: position.clone(), type:itemEq?itemEquilibrio: dropList[0]);
          gameRef.world.add(item);
          double direcaoX = (Random().nextBool() ? 1 : -1) * 30.0;
          double altura = Random().nextDouble() * 100 + 150 * -1;
          item.pop(Vector2(direcaoX, altura/2), altura:altura);
        }
      }
    }

    if(gameRef.player.isPac) gameRef.player.curaHp(1);

    if (gameRef.player.activeItems.value.isNotEmpty && 
        gameRef.player.activeItems.value[0] != null &&
        gameRef.player.activeItems.value[0]!.type == CollectibleType.activeJarroFadas && 
        gameRef.player.fadasNoJarro < 20){
      gameRef.player.fadasNoJarro++; // Guarda a vida no jarro

      game.world.add(FloatingText(
        text: "${gameRef.player.fadasNoJarro}/20",
        position: gameRef.player.absoluteCenter.clone() + Vector2(0, -30),
        color: Pallete.azulCla,
      ));

    }

    removeFromParent();
  }

  Enemy criaCopiaNormal(Vector2 novaPos,{isMenor = false}){
    double hpAux = 1;
    double sizeAux = 1.3;

    if(isMenor){
      hpAux = 0.4;
      //sizeAux = 2;
    }

    return Enemy(
      position : novaPos ,
      movementBehavior: movementBehavior,
      attackBehavior:attackBehavior,
      deathBehavior: deathBehavior,
      attack2Behavior:attack2Behavior,
      hp : hpMax * hpAux,
      speed : speed,
      soul : soul,
      weight : weight,
      rotates : rotates,
      rotateOff : rotateOff,
      voa : voa,
      animado : animado,
      flipOposto : flipOposto,
      hasGhostEffect : hasGhostEffect,
      image : image,
      originalColor : auxColor,
      isDummy : isDummy,
      size : size / sizeAux,
      hbSize : hbSize / sizeAux,
      hbOffset : hbOffset / sizeAux,
      hasShield : hasShield,
      hasFlail : hasFlail,
      isBoss : false,
      dropList : [],
      noChamp : true,
    );
  }
  

  void splitIntoTwoNormalEnemies({isMenor = false}) {
    final clone1 = criaCopiaNormal(position.clone() + Vector2(-20, 0),isMenor: isMenor);
    final clone2 = criaCopiaNormal(position.clone() + Vector2(20, 0),isMenor: isMenor);

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
    visual = GameSprite(
      imagePath: image, 
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

  void setParalise() {
    if (!isParalised && !isBoss) {
      isParalised = true;
      numCondicoes ++;
      paraliseIcon = GameIcon(
        icon: MdiIcons.linkVariant,
        color: Pallete.cinzaCla,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y / 2 - size.y / 4 - 10*numCondicoes), 
      );
      
      add(paraliseIcon!);
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

  void criaTargetIcon(){
    /*
    if (targetIcon == null){
      targetIcon = GameIcon(
      icon: MdiIcons.target,
      color: Pallete.branco,
      size: size*1.5,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y), 
    );
      targetIcon!.priority = priority - 50;
      add(targetIcon!);
    }
    */
    isTarget = true;
  }

  void removeTargetIcon(){
    /*
    if (targetIcon != null) {
      targetIcon!.removeFromParent();
      targetIcon = null; 
    }
    */
    isTarget = false;
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

     //paralise
    if (isParalised){
      paraliseTimer += dt;
      if (paraliseTimer >= paraliseTime){
        isParalised = false;
        if (paraliseIcon != null) {
          paraliseIcon!.removeFromParent();
          paraliseIcon = null; 
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