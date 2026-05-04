import 'dart:async';
import 'dart:math';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/gameObj/familiar.dart';
import 'package:towerrogue/game/components/projectiles/black_hole.dart';
import 'package:towerrogue/game/components/projectiles/eletric_spark.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:towerrogue/game/components/projectiles/laser_beam.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
//import '../core/game_icon.dart';
import '../enemies/enemy.dart'; 
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../../tower_game.dart';
import '../gameObj/player.dart';
import '../effects/explosion_effect.dart';

class Projectile extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  // --- PROPRIEDADES ORIGINAIS ---
  Vector2 direction; 
  double speed; 
  double damage;
  bool isEnemyProjectile;
  final bool apagaTiros;
  final PositionComponent? owner;

  late final Vector2 iniPosition;
  
  double _timer = 0.0;
  final double dieTimer;

  // --- COMPORTAMENTOS OPCIONAIS ---
  final bool canBounce;
  final int maxBounces;
  int _bounceCount = 0;

  final bool explodes;
  final double explosionRadius;

  final bool splits;
  final int splitCount;

  final bool isOrbital;
  double _currentAngle = 0; 
  final double orbitalRadius;

  final bool isHoming;
  final double homingTurnSpeed; 
  PositionComponent? _homingTarget; 
  final Vector2 _desiredDirection = Vector2.zero(); 

  final bool isPiercing;
  final Set<PositionComponent> _hitTargets = {};

  final bool isSpectral;

  final bool isBoomerang;
  bool _isReturning = false; 

  final bool isWave;
  final double growthRate; 
  final double maxRadius; 
  final double sweepAngle; 
  double _currentRadius; 
  late final Paint _wavePaint;
  late final Paint _wavePaintMeio;
  CircleHitbox? _waveCircleHitbox;
  
  final bool isSaw;
  final double acceleration;
  final double maxSpeed;

  GameSprite? visual;
  String image;
  double visualAngle = 0;

  bool _isDead = false;

  bool critico = true;

  bool goldShot = false;

  double knockbackForce;

  Color cor;
  Color corAtual = Pallete.branco;

  bool isStun;
  bool isMachadoArremeco;
  bool buracoNegro;
  bool isParalised;
  bool isFreeze;
  bool isBurn;
  bool isPoison;
  bool isBleed;
  bool isFear;
  bool isCharm;

  double criaHazardTmr = 0;
  bool fireHazzard;
  bool isSpark;

  bool refratado;

  Vector2 hbSize;

  bool rotaciona = false;

  Projectile({
    required Vector2 position, 
    required this.direction,
    this.damage = 10,
    this.speed = 300,
    this.owner,
    this.isEnemyProjectile = false,
    this.apagaTiros = false,
    this.dieTimer = 3.0,
    this.image = 'sprites/projeteis/blt.png',
    Vector2? hbSize,
    Vector2? size,
    this.canBounce = false,
    this.maxBounces = 2,
    this.explodes = false,
    this.explosionRadius = 60.0,
    this.splits = false,
    this.splitCount = 3,
    this.isOrbital = false,
    this.orbitalRadius = 50.0,
    this.isHoming = false,
    this.homingTurnSpeed = 4.0, 
    this.isPiercing = false,
    this.isSpectral = false,
    this.isBoomerang = false,
    this.isWave = false,
    this.growthRate = 60.0,
    this.maxRadius = 250.0,
    this.sweepAngle = pi / 2,
    this.isSaw = false,
    this.goldShot = false,
    this.acceleration = 200.0,
    this.maxSpeed = 1000.0,
    this.knockbackForce = 0,
    this.isStun = false,
    this.isMachadoArremeco = false,
    this.cor = Pallete.preto,
    this.fireHazzard = false,
    this.buracoNegro = false,
    this.isSpark = false,
    this.isParalised = false,
    this.isFreeze = false,
    this.isBurn = false,
    this.isPoison = false,
    this.isBleed = false,
    this.isFear = false,
    this.isCharm = false,
    this.refratado = false,
    Vector2? iniPosition,
  }): hbSize = hbSize ?? Vector2.all(16.0),
      _currentRadius = (hbSize?.x ?? 16) / 2, // Raio inicial baseado no tamanho
      super(position: position, size: size ?? Vector2.all(16), anchor: Anchor.center) {
    this.iniPosition = iniPosition?.clone() ?? position.clone();
  }

  @override
  Future<void> onLoad() async {
    corAtual = cor == Pallete.preto ? (isEnemyProjectile ? Pallete.vermelho : goldShot ? Pallete.amarelo : Pallete.azulCla) : cor;

    if (isWave) {
      corAtual = isEnemyProjectile ? Pallete.vermelho : Pallete.azulCla;
      _wavePaint = Paint()
        ..color = corAtual
        ..style = PaintingStyle.stroke 
        ..isAntiAlias = false
        ..strokeWidth = 1.0;

      _wavePaintMeio= Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke 
        ..isAntiAlias = false
        ..strokeWidth = 1.0;

      _waveCircleHitbox = CircleHitbox(
        radius: _currentRadius,
        anchor: Anchor.center,
        position: size / 2, // Centrado perfeitamente no projétil
      );
      add(_waveCircleHitbox!);
    } 
    else {
      // Lógica de visual padrão para tiros normais
      //IconData icon = Icons.circle;
      Vector2 tamanho = size;

      if(cor != Pallete.preto){
        corAtual = cor;
      }
      
      if (explodes) {
      } else if (isBoomerang) {
        image = 'sprites/projeteis/bumerangue.png';
        corAtual = Pallete.marrom;
        tamanho = tamanho * 2;
        rotaciona = true;
      } else if (isHoming) {
        visualAngle = -pi / 4; 
        tamanho = tamanho * 2;
      } else if (isSaw) {
        image = 'sprites/projeteis/saw.png';
        visualAngle = -pi / 4; 
        tamanho = tamanho * 2;
        corAtual = Pallete.lilas;
        rotaciona = true;
      } else if (gameRef.selectedClass.name == 'PIROMANTE'){
        corAtual = Pallete.laranja;
        tamanho = tamanho * 2;
      }else if(isMachadoArremeco){
        tamanho = tamanho * 2;
        corAtual = Pallete.lilas;
        rotaciona = true;
      }

      visual = GameSprite(
      imagePath: image,
      size: size,
      color: corAtual,
      anchor: Anchor.center,
      position: size / 2
    );
      add(visual!);
      
      add(RectangleHitbox(
      size: hbSize,
      anchor: Anchor.center, 
      position: size / 2,    
      isSolid: true,
    ));
    }

    _updateRotation();

    if (owner is Enemy) critico = false;
  }

  /* --- GERAÇÃO DOS PONTOS DA ONDA ---
  List<Vector2> _generateWavePoints({double radius = 1.0}) {
   final List<Vector2> points = [];
    const int segments = 10;
    
    // O seu updateRotation adiciona 1.54. Precisamos subtrair aqui para o arco nascer virado para a frente.
    double offsetCorrecao = -1.54 - visualAngle;
    double start = offsetCorrecao - (sweepAngle / 2);

    for (int i = 0; i <= segments; i++) {
      final double segAngle = start + (sweepAngle * (i / segments));
      points.add(Vector2(
        radius * cos(segAngle),
        radius * sin(segAngle),
      ));
    }
    return points;
  }
*/
  @override
  void update(double dt) {
    super.update(dt);
    if (_isDead) return;

    _timer += dt;

    if (_timer % 0.2 < 0.1) {
         visual?.changeColor(Pallete.branco);
      } else {
         visual?.changeColor(corAtual);
      }

    if(rotaciona) {
      visualAngle += 15 * dt; 
      _updateRotation();
    }

    if(fireHazzard) _createHazard(dt, isFire: true, tmp: 1/speed);

    if (owner != null && !owner!.isMounted) {
      if (!isBoomerang) {
        removeFromParent(); 
        return;
      }
    }

    // --- LÓGICA DO BUMERANGUE ---
    if (isBoomerang) {
      if (!isHoming || _isReturning) _updateRotation();

      if (!_isReturning && _timer >= dieTimer / 2) {
        _isReturning = true;
        _hitTargets.clear(); 
        _homingTarget = null; 
      }

      if (_isReturning) {
        Vector2 targetPos = (owner != null && owner!.isMounted) 
            ? owner!.position 
            : iniPosition;
            
        _desiredDirection.setFrom(targetPos);
        _desiredDirection.sub(position);

        if (_desiredDirection.length2 < 400) { 
          removeFromParent();
          return;
        }

        _desiredDirection.normalize();
        direction.setFrom(_desiredDirection);
      }
    }
    
    // --- LÓGICA HOMING ---
    if (isHoming && !isOrbital && !_isReturning) {
      _updateHomingTarget();
      
      if (_homingTarget != null && _homingTarget!.isMounted) {
        _desiredDirection.setFrom(_homingTarget!.position);
        _desiredDirection.sub(position);
        _desiredDirection.normalize();

        direction.x += (_desiredDirection.x - direction.x) * (dt * homingTurnSpeed);
        direction.y += (_desiredDirection.y - direction.y) * (dt * homingTurnSpeed);
        direction.normalize();

        if (!isBoomerang) _updateRotation();
      }
    }

    // --- LÓGICA DE CRESCIMENTO DA ONDA ---
    if (isWave) {
      if (_currentRadius < maxRadius) {
        _currentRadius += growthRate * dt;
        // Atualiza a hitbox poligonal com o novo tamanho
        _waveCircleHitbox?.radius = _currentRadius;
      }
    }

    if (isSaw) {
      if (speed < maxSpeed) {
        speed += acceleration * dt;
      }
      
    }

    // --- MOVIMENTO ---
    if (isOrbital) {
      double velocidade = speed;
      if(!isEnemyProjectile) velocidade = speed * game.player.masterOrb;

      _currentAngle += velocidade * dt;
      final double centerX = owner!.position.x ;
      final double centerY = owner!.position.y ;

      final newX = centerX + cos(_currentAngle) * orbitalRadius;
      final newY = centerY + sin(_currentAngle) * orbitalRadius;
    
      position.setValues(newX, newY);
    } else {
      position.addScaled(direction, speed * dt);
    }

    if (_timer >= dieTimer){
      kill(triggerEffects: true); 
    }
    
    if (position.length > 3000) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Renderiza os ícones normais, se existirem
    
    // --- DESENHO EXCLUSIVO DA ONDA ---
    if (isWave) {
      double start = -sweepAngle / 2;
      final center = size / 2;

      for(int i = 0; i < 3; i++){
        double radiusOffset = i * 1.5;
        canvas.drawArc(
          Rect.fromCircle(center: Offset(center.x, center.y), radius: _currentRadius - radiusOffset),
          start, 
          sweepAngle, 
          false, 
          i == 1 ? _wavePaintMeio : _wavePaint,
        );
      }
    }
  }

  void refletir(){
    isEnemyProjectile = false;
    damage = game.player.damageIni;
    direction *= -1;
    visual!.changeColor(isStun?Pallete.marrom:Pallete.branco);
    _timer = 0;
  }

  
  void refrata() {
    if(refratado) return;
    refratado = true;
    List<double> angs =[-0.2,-0.1,0.2,0.1];
    for(int i = 0; i < angs.length; i++)
    {
      double angleOffset = angs[i];
      Color cor = Pallete.branco;
      switch(i){
        case 0:
          cor = Pallete.azulCla;
          break;
        case 1:
          cor = Pallete.verdeCla;
          break;
        case 2:
          cor = Pallete.amarelo;
          break;
        case 3:
          cor = Pallete.vermelho;
          break;
      }

      double x = direction.x * cos(angleOffset) - direction.y * sin(angleOffset);
      double y = direction.x * sin(angleOffset) + direction.y * cos(angleOffset);
      direction.setValues(x, y);

      criaProjetil(position.clone() + direction.clone()*32,direction.clone(),damage,speed,size,dieTimer,apagaTiros,isHoming,position.clone(),
      canBounce,isSpectral,isPiercing,isOrbital,isBoomerang,splits,splitCount,goldShot,isWave,isSaw,cor,false);

      
    }
    removeFromParent();
  }

  void _createHazard(double dt,{bool isFire = false, bool isVeneno = true,bool isGelo = false,bool isBlood = false,double tmp = 0.1}) {
    criaHazardTmr += dt;
  
    if (criaHazardTmr >= tmp) {
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
      
      criaHazardTmr = 0;
    }
  }

  void criaProjetil(Vector2 pos, Vector2 dir, double dmg, double spd, Vector2 sz, double die, bool apaga, bool homing, Vector2 iniPos, bool bounce, bool spectral, bool piercing, bool orbital, bool boomer, bool split, int splitC, bool gold, bool wave, bool saw, Color cor, bool refratado){
    gameRef.world.add(Projectile(
        owner: owner,
        position: pos, 
        direction: dir, 
        damage:dmg, 
        speed: spd,
        hbSize: sz,
        dieTimer: die,
        apagaTiros: apaga,
        isHoming: homing ,
        iniPosition: iniPos,
        canBounce: bounce,
        isSpectral: spectral,
        isPiercing: piercing,
        isOrbital: orbital,
        isBoomerang: boomer,
        splits: split,
        splitCount: splitC,
        goldShot: gold,
        isWave: wave,         // <-- Transforma em onda!
        maxRadius: 150,       // <-- Tamanho máximo
        growthRate: 100,      // <-- Velocidade de expansão
        sweepAngle: pi / 1.5, // <-- Quase um semicírculo de largura!
        isSaw: saw,
        cor: cor,
        refratado: refratado
      ));
  }

  double get danoAtual {
    if (!isWave) return damage; 

    double progresso = (_currentRadius / maxRadius).clamp(0.0, 1.0);
    double multiplicador = 1.0 - (0.75 * progresso);

    return (damage * multiplicador) + 1;
  }

  void _updateHomingTarget() {
    if (_homingTarget != null && _homingTarget!.isMounted) return;

    if (isEnemyProjectile) {
      _homingTarget = gameRef.player;
    } else {
      final enemies = gameRef.world.children.query<Enemy>();
      double closestDist = double.infinity;
      Enemy? bestTarget;

      for (final enemy in enemies) {
        if(enemy.isCharmed) continue;
        if (_hitTargets.contains(enemy)) continue;

        final dist = position.distanceToSquared(enemy.position);
        if (dist < closestDist) {
          closestDist = dist;
          bestTarget = enemy;
        }
      }
      _homingTarget = bestTarget;
    }
  }

  void _gerarFaiscasEletricas(Vector2 pontoDeImpacto, double danoOriginal) {
    int quantidadeFaiscas = Random().nextInt(2) + 2; 
    double alcanceDaFaisca = 62.0; // Distância máxima que a faísca solta consegue pular

    // 1. Escaneia quem está perto o suficiente para tomar um choque
    List<Enemy> inimigosProximos = [];
    for (var inimigo in gameRef.world.children.query<Enemy>()) {
      if (inimigo.isInvencivel || inimigo.isIntangivel) continue;
      
      if (pontoDeImpacto.distanceTo(inimigo.position) <= alcanceDaFaisca) {
        inimigosProximos.add(inimigo);
      }
    }

    // 2. Dispara as faíscas uma por uma
    for (int i = 0; i < quantidadeFaiscas; i++) {
      Vector2 alvoDaFaisca;

      // Se ainda tiver inimigos perto, a faísca PULA para ele!
      if (inimigosProximos.isNotEmpty) {
        // Pega um inimigo aleatório da lista e já remove para a próxima faísca não ir no mesmo
        Enemy vitima = inimigosProximos.removeAt(Random().nextInt(inimigosProximos.length));
        
        // A ponta da faísca trava no inimigo
        alvoDaFaisca = vitima.position.clone();
        
        // CAUSA O DANO (Porque a faísca literalmente tocou nele)
        vitima.takeDamage(danoOriginal * 0.5, critico: false);
        
      } else {
        // Se não tem inimigo perto, a faísca espirra para o ar (só enfeite)
        double anguloAleatorio = Random().nextDouble() * 2 * pi;
        double tamanhoAleatorio = 20.0 + Random().nextDouble() * 40.0;
        alvoDaFaisca = pontoDeImpacto + Vector2(cos(anguloAleatorio) * tamanhoAleatorio, sin(anguloAleatorio) * tamanhoAleatorio);
      }

      // 3. Desenha a Faísca Tremida ligando o impacto até o alvo (ou o ar)
      gameRef.world.add(ElectricSpark(
        startPoint: pontoDeImpacto.clone(),
        endPoint: alvoDaFaisca,
      ));
    }

    // 4. DISPARA O CHAIN LIGHTNING! (O raio principal que pula mais longe)
    _dispararRaioEmCadeia(pontoDeImpacto.clone(), 4, [], danoOriginal);
  }

  /// Função Recursiva que faz o raio pular de inimigo em inimigo
  Future<void> _dispararRaioEmCadeia(
    Vector2 posicaoAtual, 
    int saltosRestantes, 
    List<Component> inimigosAtingidos, 
    double danoDoRaio,
  ) async {
    if (saltosRestantes <= 0 || !isMounted) return;

    Component? alvoProximo;
    double menorDistancia = 120.0; 

    for (var inimigo in gameRef.world.children.query<Enemy>()) {
      if (inimigo.isInvencivel || inimigo.isIntangivel || inimigo.isCharmed) continue;
      if (inimigosAtingidos.contains(inimigo)) continue;

      double dist = posicaoAtual.distanceTo(inimigo.position);
      if (dist < menorDistancia) {
        menorDistancia = dist;
        alvoProximo = inimigo;
      }
    }

    if (alvoProximo != null && alvoProximo is Enemy) {
      
      // DESENHA O RAIO EM CADEIA COM O EFEITO TREMIDO AQUI!
      gameRef.world.add(ElectricSpark(
        startPoint: posicaoAtual.clone(),
        endPoint: alvoProximo.position.clone(),
      ));

      alvoProximo.takeDamage(danoDoRaio, critico: false);
      inimigosAtingidos.add(alvoProximo);

      await Future.delayed(const Duration(milliseconds: 80));

      if (gameRef.isAttached) { 
         _dispararRaioEmCadeia(alvoProximo.position.clone(), saltosRestantes - 1, inimigosAtingidos, danoDoRaio);
      }
    }
  }

  void kill({bool triggerEffects = true}) {
    if (_isDead) return;
    _isDead = true;

    if (triggerEffects) {
      if (explodes) gameRef.world.add(Explosion(position: position, damagesPlayer:isEnemyProjectile, damage:damage));
      if(buracoNegro){
        game.world.add(BuracoNegro(position: position.clone(),size: Vector2.all(24), damage: damage/2, duration: 2));
      }
    }
    
    removeFromParent();
  }

  void _doSplit(bool rndDir,double dmg,double spd,Vector2 sz,double die,bool canBounce,bool isSpectral,bool isPiercing,bool isOrbital,bool isBoomerang,bool splits,int splitCount,bool goldShot,bool isWave,bool isSaw,Color cor) {
    for (int i = 0; i < splitCount; i++) {
      double angle = rndDir? Random().nextDouble() * 2*pi : i*(2*pi/splitCount); 
      Vector2 newDir = Vector2(cos(angle), sin(angle));

      criaProjetil(position.clone() - direction * 10,newDir,dmg,spd,sz,die,false,false,position.clone(),
      canBounce,isSpectral,isPiercing,isOrbital,isBoomerang,splits,splitCount,goldShot,isWave,isSaw,cor,false);
      /*
      gameRef.world.add(Projectile(
        position: position.clone() - direction * 10, 
        direction: newDir,
        speed: speed * 0.6, 
        damage: damage / 2, 
        isEnemyProjectile: isEnemyProjectile,
        owner: owner,
        dieTimer: 1.0, 
        size: size / 1.5, 
        canBounce: false,
        explodes: false, 
        splits: false, 
      ));
      */
    }
  }

  void explode(){
    _doSplit(false,damage,300,size,3.0,canBounce,isSpectral,isPiercing,isOrbital,isBoomerang,false,6,goldShot,isWave,isSaw,cor);
    removeFromParent();
  }

  // --- COLISÃO ---
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollisionStart(intersectionPoints, other);
    if (_isDead || _hitTargets.contains(other)) return;

  // FILTRO PARA VER SE O ALVO ESTÁ NA FRENTE OU ATRAS DA ONDA
    if (isWave && (other is Enemy || other is Player)) {
      Vector2 diff = other.absoluteCenter - absoluteCenter;
      
      if (diff.length2 > 0) { 
        Vector2 dirToTarget = diff.normalized();
        Vector2 forwardDir = Vector2(cos(absoluteAngle), sin(absoluteAngle));

        double dotProduct = forwardDir.dot(dirToTarget);
        double angleDiff = acos(dotProduct.clamp(-1.0, 1.0)); 

        if (angleDiff > sweepAngle / 2) {
          return; 
        }
      }
    }

    final hitPos = intersectionPoints.firstOrNull ?? position;

    // 1. COLISÃO COM PAREDES
    if (!isSpectral && (other is Wall || other is ScreenHitbox)) {
      createExplosionEffect(gameRef.world, hitPos, Pallete.cinzaCla, count: 5);
      if (canBounce /*&& _bounceCount < maxBounces*/) {
        _handleBounce(other, hitPos);
        if (other is Wall) other.takeDamage(); 
        return; 
      } 
      
      if (other is Wall) {
        other.takeDamage();
        if (other.vida <= 0) other.removeFromParent();
      }
      if (splits) _doSplit(true,damage/2,speed * 0.6,size / 1.5,1,false,false,false,false,false,false,splitCount,false,false,false,cor);
      if(isSpark)_gerarFaiscasEletricas(hitPos, damage/2);
      kill(); 
      return;
    }

    // 2. COLISÃO COM INIMIGOS / PLAYER
    if (isEnemyProjectile) {
      if (other is Player) {
        createExplosionEffect(gameRef.world, hitPos, Pallete.vermelho, count: 10);
        _hitTargets.add(other);
        final rnd = Random();
        if(rnd.nextInt(100)<50 && other.refletirChance){
          isStun = true;
          refletir();
          return; 
        }else{
          other.takeDamage(damage.toInt());
        } 
        
        // Bumerangue e Ondas normalmente perfuram alvos vivos!
        if (!isPiercing && !isBoomerang && !isWave) kill(); 
      } else if (other is Familiar && other.type == FamiliarType.block ){
        createExplosionEffect(gameRef.world, hitPos, Pallete.cinzaCla, count: 10);
        kill();
      }
    } else {
      if (other is Enemy && !other.isInvencivel && !other.isIntangivel && !other.isCharmed) {
        createExplosionEffect(gameRef.world, hitPos, other.originalColor, count: 10);
        _hitTargets.add(other); 
        other.setKnockBack(other,force:knockbackForce);
        other.takeDamage(danoAtual, critico: critico);
        if(isStun)other.setConfuse();
        if(isParalised)other.setParalise();
        if(isBurn)other.setBurn();
        if(isFreeze)other.setFreeze();
        if(isPoison)other.setPoison(alastra: gameRef.player.isPoisonAlastra || gameRef.player.tempPoisonAlastra);
        if(isBleed)other.setBleed();
        if(isFear)other.setFear();
        if(isCharm)other.setCharm();
        if(isSpark)_gerarFaiscasEletricas(hitPos, damage/2);
        
        if ((isPiercing || isBoomerang || isWave) && _homingTarget == other) {
          _homingTarget = null;
        }

        if(goldShot){
          int rnd = Random().nextInt(100);
          if(rnd <= 5){
            final item = Collectible(position: position, type: CollectibleType.coinUm);
            gameRef.world.add(item);
            double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
            double altura = Random().nextDouble() * 100 + 150 * -1;
            item.pop(Vector2(direcaoX, 0), altura:altura);
          }
        }
        if (splits) _doSplit(true,damage/2,speed * 0.6,size / 1.5,1,false,false,false,false,false,false,splitCount,false,false,false,cor);
        if(canBounce) _handleBounce(other, hitPos);
        if (!isPiercing && !isBoomerang && !isWave && !canBounce) kill();
      }
      
      if (apagaTiros && other is Projectile && other.isEnemyProjectile) {
        _hitTargets.add(other);
        other.removeFromParent();
        if (!isPiercing && !isBoomerang && !isWave) kill();
      }
    }
  }

  void _handleBounce(PositionComponent obstacle, Vector2 hitPos) {
    _bounceCount++;

    Vector2 relativePos = position - obstacle.position;
    
    if (relativePos.x.abs() > relativePos.y.abs()) {
      direction.x = -direction.x;
    } else {
      direction.y = -direction.y;
    }

    if(obstacle is Enemy){
      direction.x = Random().nextDouble()*2 -1;
      direction.y = Random().nextDouble()*2 -1;
    }

    direction.normalize();

    position += direction * obstacle.size.y;
    
    _homingTarget = null; 

    _updateRotation();
  }

  void _updateRotation() {
    if (isWave) {
      angle = atan2(direction.y, direction.x);
    } else {
      angle = atan2(direction.y, direction.x) + 1.54 + visualAngle; 
    }
  }

}