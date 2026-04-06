import 'dart:math';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/gameObj/familiar.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; 
import '../effects/explosion_effect.dart';
import '../enemies/enemy.dart';
import '../gameObj/player.dart';
import '../gameObj/wall.dart';
//import '../../audio_manager.dart'; 

class LaserBeam extends PositionComponent with HasGameRef<TowerGame>,CollisionCallbacks {
  final double damage;
  final double maxLength;
  double currentLength;
  double larguraLaser;
  double angleRad; 
  bool isEnemyProjectile;
  bool isMoving;
  double speed;
  
  double dmgTmr = 0;
  double dmgTime;
  // Configuração de Tempo
  double _timer = 0;
  double chargeTime; // Tempo "mirando" (aviso)
  double fireTime;   // Tempo causando dano
  bool _hasFired = false;

  final PositionComponent? owner;
  final PositionComponent? target;

  RectangleHitbox? _hitbox;

  bool critico = true;

  Color cor;
  bool refratado;

  bool followsOwnerMov;

  bool invisivel = false;
  bool _canDamageThisFrame = false;

  bool atravessa;
  bool chains;
  int chainCount;
  int maxChains;

  LaserBeam({
    required Vector2 position,
    required this.angleRad,
    this.target,
    this.damage = 1,
    double length = 400,
    this.larguraLaser = 20,
    this.chargeTime = 1,
    this.fireTime = 1,
    this.dmgTime = 0.3,
    this.owner,
    this.isEnemyProjectile = false,
    this.isMoving = false,
    this.followsOwnerMov = false,
    this.speed = 0.01,
    this.cor = Pallete.vermelho,
    this.refratado = false,
    this.invisivel = false,
    this.atravessa = false,
    this.chains = false,
    this.chainCount = 0,
    this.maxChains = 4,
  }): maxLength = length, 
      currentLength = length, 
      
      super(position: position, anchor: Anchor.centerLeft);

  @override
  Future<void> onLoad() async {
    angle = angleRad;
    
    priority = 500; 

    if (owner is Enemy) critico = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
   // if(invisivel) return;

    if (owner != null && !owner!.isMounted) {
      removeFromParent(); 
      return;
    }

    _timer += dt;
    
    // FASE 1: DISPARAR (Acabou o tempo de carga)
    if (_timer >= chargeTime && !_hasFired) {
      _fire();
      AudioManager.playSfx('laser.mp3');
      
      // --- A MÁGICA ESTÁ AQUI ---
      // Forçamos o timer a já começar cheio. 
      // Assim, no exato frame em que o laser aparece, ele causa dano!
      dmgTmr = dmgTime; 
    }

    // --- SEGUNDA PARTE DA MÁGICA ---
    // Só calculamos o tempo de recarga do dano SE o laser já estiver atirando
    if (_hasFired) {
      if(dmgTmr > 0){
        dmgTmr -= dt;
        //_canDamageThisFrame = false; // Carregando o próximo ciclo de dano...
      } else {
        _canDamageThisFrame = true; // SINAL VERDE! Queima tudo!
        dmgTmr = dmgTime; // Reseta a contagem para esperar mais 0.3s
      }
    }
    // FASE 1: DISPARAR (Acabou o tempo de carga)
    if (_timer >= chargeTime && !_hasFired) {
      _fire();
      AudioManager.playSfx('laser.mp3');
    }

    if (owner is Player) {
      // 1. A origem do feixe fica colada no jogador
      Player p = owner as Player; // Converte para acessar a velocidade do Player
      
      // 1. A origem do feixe fica colada no jogador
      position = p.position.clone();
      
      // 2. A ponta aponta para o alvo (se ele ainda existir no mundo)
      if (followsOwnerMov) {
        
        // Se o player estiver se movendo (ignoramos tremores menores que 1.0)
        if (p.velocity.length > 1.0) {
          // Calcula o ângulo baseado na direção em que ele está andando!
          angle = atan2(p.velocity.y, p.velocity.x);
        }
        // Nota: Se ele ficar parado, o laser simplesmente mantém a última direção que estava apontando!
        
      } else if (target != null && target!.isMounted) {
        final directionVector = target!.position - position;
        angle = atan2(directionVector.y, directionVector.x);
      }
    }else if (owner is Familiar) {
      // 1. A origem do feixe fica colada no jogador
      Familiar p = owner as Familiar; // Converte para acessar a velocidade do Familiar
      
      // 1. A origem do feixe fica colada no jogador
      position = p.position.clone();
      
      // 2. A ponta aponta para o alvo (se ele ainda existir no mundo)
      if (followsOwnerMov) {
        
        // Se o player estiver se movendo (ignoramos tremores menores que 1.0)
        if (p.velocity.length > 1.0) {
          // Calcula o ângulo baseado na direção em que ele está andando!
          angle = atan2(p.velocity.y, p.velocity.x);
        }
        // Nota: Se ele ficar parado, o laser simplesmente mantém a última direção que estava apontando!
        
      } else if (target != null && target!.isMounted) {
        final directionVector = target!.position - position;
        angle = atan2(directionVector.y, directionVector.x);
      }
    } else if (isMoving && _hasFired) {
      // Mantém a sua lógica original para os lasers inimigos que giram
      angle += speed;
    }

    if(!atravessa)_updateLaserLength(); 

    // FASE 2: DESTRUIR (Acabou o tempo de fogo)
    if (_timer >= chargeTime + fireTime) {
      removeFromParent();
    }
  }

  Enemy? _findNextTarget(Enemy currentEnemy) {
    double jumpRange = 150.0; // Distância máxima do pulo elétrico
    Enemy? closest;
    double minDistance = jumpRange;

    for (final enemy in gameRef.world.children.whereType<Enemy>()) {
      // Ignora o inimigo que acabou de levar o choque e inimigos mortos
      if (enemy == currentEnemy || !enemy.isMounted) continue;

      double dist = currentEnemy.absoluteCenter.distanceTo(enemy.absoluteCenter);
      if (dist < minDistance) {
        minDistance = dist;
        closest = enemy;
      }
    }
    return closest;
  }

  void _updateLaserLength() {
    // Cria um raio matemático a partir do laser na direção atual
    final directionVector = Vector2(cos(absoluteAngle), sin(absoluteAngle));
    final ray = Ray2(origin: absolutePosition, direction: directionVector);

    // Faz a varredura
    final result = gameRef.collisionDetection.raycast(
      ray,
      maxDistance: maxLength,
      ignoreHitboxes: [
        if (_hitbox != null) _hitbox!, // O raio ignora a própria hitbox do laser
        if (owner != null) ...owner!.children.whereType<ShapeHitbox>(), // Ignora o dono
      ],
    );

    // Se o raio bateu em algo...
    if (result != null && result.hitbox != null) {
      final hitParent = result.hitbox!.parent;
      
      // Se for parede ou o limite da tela, corta o laser ali
      if (hitParent is Wall || result.hitbox is ScreenHitbox || hitParent is Enemy || hitParent is Player
      || hitParent is Familiar && hitParent.type == FamiliarType.prisma) {
        currentLength = result.distance!;
      } else {
        // Se bateu em outra coisa (Player/Enemy), ignora e atravessa
        currentLength = maxLength;
      }
    } else {
      currentLength = maxLength; // Nada no caminho
    }

    // Se a hitbox já foi criada (já disparou), ajustamos o tamanho dela
    // Isso garante que você não tome dano se estiver atrás de uma parede!
    if (_hitbox != null) {
      _hitbox!.size.x = currentLength;
    }
  }

  void _fire() {
    _hasFired = true;
    _hitbox = RectangleHitbox(
      position: Vector2(0, -larguraLaser/2), 
      size: Vector2(currentLength, larguraLaser), 
      isSolid: true,
      collisionType: CollisionType.active, 
    );
    add(_hitbox!);
    
    gameRef.camera.viewfinder.position += Vector2(Random().nextDouble() * 2, Random().nextDouble() * 2);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if(invisivel) return;
    if (!_hasFired) {
      // --- VISUAL DE CARGA (Aviso) ---
      // Linha fina que pisca
      double opacity = (_timer * 10).toInt() % 2 == 0 ? 0.3 : 0.6;
      
      final paintWarning = Paint()
        ..color = Pallete.vermelho.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = false;

      // Desenha linha da origem (0,0) até o alcance (length, 0)
      canvas.drawLine(Offset.zero, Offset(currentLength, 0), paintWarning);

    } else {
      // --- VISUAL DE DISPARO (Laser Real) ---
      
      // 1. Brilho Externo (Glow)
      final paintGlow = Paint()
        ..color = cor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = larguraLaser * 0.8
        //..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..isAntiAlias = false; 

      // 2. Núcleo Branco
      final paintCore = Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke
        ..strokeWidth = larguraLaser / 5
        ..isAntiAlias = false;

      canvas.drawLine(Offset.zero, Offset(currentLength, 0), paintGlow);
      canvas.drawLine(Offset.zero, Offset(currentLength, 0), paintCore);
    }
  }

  void refrata(Vector2 hitPos) {
    if (refratado) return; 
    refratado = true;

    List<double> angs = [-0.2, -0.1, 0.2, 0.1];
    for (int i = 0; i < angs.length; i++) {
      double angleOffset = angs[i];
      Color novaCor = Pallete.branco;
      switch (i) {
        case 0: novaCor = Pallete.azulCla; break;
        case 1: novaCor = Pallete.verdeCla; break;
        case 2: novaCor = Pallete.amarelo; break;
        case 3: novaCor = Pallete.vermelho; break;
      }

      double newAngle = angleRad + angleOffset;

      double tempoRestante = (chargeTime + fireTime) - _timer;
      if (tempoRestante <= 0) tempoRestante = 0.1;

      gameRef.world.add(LaserBeam(
        position: hitPos.clone(), 
        angleRad: newAngle,
        damage: damage,
        length: maxLength,
        chargeTime: 0, 
        fireTime: tempoRestante, 
        owner: owner,
        isEnemyProjectile: isEnemyProjectile,
        cor: novaCor,
        refratado: true
      ));
    }
    
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollision(intersectionPoints, other);
    final hitPos = intersectionPoints.firstOrNull ?? position;
    
    if(_canDamageThisFrame){
      if (isEnemyProjectile) {
        if (other is Player) {
          createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
          other.takeDamage(1); 
        }
      } 
      else {
        if (other is Enemy) {
          createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
          other.takeDamage(damage,critico:critico);
          if (chainCount < maxChains) {
            final nextEnemy = _findNextTarget(other);
            print('raio');
            if (nextEnemy != null) {
              // Calcula o ângulo para o próximo inimigo
              final direction = nextEnemy.absoluteCenter - other.absoluteCenter;
              final angleToNext = atan2(direction.y, direction.x);
              print('vai pula raio');
              // Cria o próximo elo da corrente
              gameRef.world.add(LaserBeam(
                position: other.absoluteCenter.clone(),
                angleRad: angleToNext,
                damage: damage * 0.8, // O dano pode diminuir a cada pulo (opcional)
                chains: true,
                chainCount: chainCount + 1, // Incrementa o contador
                maxChains: maxChains,
                fireTime: 0.15, // Faíscas de corrente são bem rápidas
                chargeTime: 0,
                cor: Pallete.azulCla,
                larguraLaser: larguraLaser * 0.9, // Vai ficando mais fino
                owner: null, // Importante ser null para não teletransportar pro player
                refratado:true,
              ));
            }
          }
        
        // Desativa o dano neste frame para este laser específico não "chainar" infinitamente no mesmo inimigo
        _canDamageThisFrame = false;
        }
      } 
      
      if (other is ScreenHitbox) {
        createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
      }
      if (other is Wall) {
        other.vida--;
        if (other.vida <=0) other.removeFromParent();
        createExplosionEffect(gameRef.world, hitPos, Pallete.laranja, count: 5);
        //removeFromParent(); 
      }
      dmgTmr = 0;
    }
    
    
  }
}