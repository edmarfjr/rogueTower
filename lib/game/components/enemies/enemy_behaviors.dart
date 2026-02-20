import 'dart:math';
import 'dart:ui';
//import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';

import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:TowerRogue/game/components/projectiles/explosion.dart';
import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';
import 'package:flutter/material.dart';

import '../gameObj/wall.dart';
import 'package:flame/components.dart';
import '../../tower_game.dart';
import 'enemy.dart';
import '../projectiles/projectile.dart';
import '../projectiles/laser_beam.dart';
import '../projectiles/mortar_shell.dart';
import '../projectiles/web.dart';
import '../effects/target_reticle.dart';
import '../effects/path_effect.dart';
import '../effects/explosion_effect.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';
//import 'enemy_factory.dart';

typedef EnemyBuilder = Enemy Function(Vector2);
typedef HazardBuilder = PositionComponent Function(Vector2 position);

// --- INTERFACES ---

abstract class MovementBehavior {
  late Enemy enemy;
  void update(double dt);
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

abstract class AttackBehavior {
  late Enemy enemy;
  void update(double dt);
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

abstract class DeathBehavior {
  late Enemy enemy;
  void onDeath();
}

// --- MOVIMENTOS (MOVEMENT BEHAVIORS) ---

class FollowPlayerBehavior extends MovementBehavior {
  final Vector2 _direction = Vector2.zero();

  @override
  void update(double dt) {
    // Só anda se o ataque permitir
    if (!enemy.canMove) return;

    final player = enemy.gameRef.player;
    _direction
      ..setFrom(player.position) // Copia posição do player
      ..sub(enemy.position)      // Subtrai posição do inimigo
      ..normalize();             // Normaliza
    
    // Rotação visual
    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) visual.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
    }
    
    enemy.position.addScaled(_direction, enemy.speed * dt);
  }
}

class KeepDistanceBehavior extends MovementBehavior {
  final double minDistance;
  final double maxDistance;

  final Vector2 _direction = Vector2.zero();

  KeepDistanceBehavior({this.minDistance = 150, this.maxDistance = 250});

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    final player = enemy.gameRef.player;
    final distance = enemy.position.distanceTo(player.position);
    _direction
      ..setFrom(player.position) // Copia posição do player
      ..sub(enemy.position)      // Subtrai posição do inimigo
      ..normalize();             // Normaliza

    // Rotação visual
    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) visual.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
    }

    if (distance > maxDistance) {
      // Aproxima
      enemy.position.addScaled(_direction, enemy.speed * dt);
    } else if (distance < minDistance) {
      // Foge
      enemy.position.addScaled(-_direction, (enemy.speed * 0.8) * dt);
    }
  }
}

class RandomWanderBehavior extends MovementBehavior {
  Vector2 _target = Vector2.zero();
  
  // Vetores reutilizáveis para evitar Garbage Collection (Travamentos)
  final Vector2 _direction = Vector2.zero();
  final Vector2 _tempCalc = Vector2.zero(); 

  final Random _rng = Random(); // Cache do Random

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    // Se não tem alvo ou chegou perto, escolhe um aleatório total
    if (_target == Vector2.zero() || enemy.position.distanceTo(_target) < 10) {
      _pickNewTarget();
    }

    // Lógica de Movimento Otimizada (Zero Alocação)
    _direction
      ..setFrom(_target)       
      ..sub(enemy.position)    
      ..normalize();           

    // Rotação visual
    if (enemy.rotates) {
      // Otimização: Se você implementou a variável '_visual' no Enemy sugerida antes, use-a aqui.
      // Se não, mantenha o children.firstOrNull
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) {
        visual.angle = atan2(_direction.y, _direction.x) + enemy.rotateOff;
      }
    }

    enemy.position.addScaled(_direction, enemy.speed * dt);
  }

  // Agora aceita uma direção opcional de viés (Bias)
  void _pickNewTarget({Vector2? pushAwayFrom}) {
    double w = TowerGame.arenaWidth / 2 - 40; // Margem de segurança maior (40)
    double h = TowerGame.arenaHeight / 2 - 40;

    if (pushAwayFrom != null) {
      // --- LÓGICA DE COLISÃO INTELIGENTE ---
      // 1. Pega o ângulo da direção oposta ao objeto
      double baseAngle = atan2(pushAwayFrom.y, pushAwayFrom.x);
      
      // 2. Adiciona uma variação aleatória de +/- 60 graus (pi/3)
      // Isso faz ele não voltar exatamente pra trás, mas sair na diagonal
      double noise = (_rng.nextDouble() - 0.5) * (pi / 1.5); 
      double finalAngle = baseAngle + noise;

      // 3. Projeta um ponto longe (ex: 200 pixels) nessa direção segura
      double dist = 100 + _rng.nextDouble() * 100;
      
      _target.setValues(
        enemy.position.x + cos(finalAngle) * dist,
        enemy.position.y + sin(finalAngle) * dist,
      );

    } else {
      // --- LÓGICA ALEATÓRIA PURA ---
      _target.setValues(
        (_rng.nextDouble() * 2 * w) - w, 
        (_rng.nextDouble() * 2 * h) - h
      );
    }

    // IMPORTANTE: Garante que o ponto calculado (seja por colisão ou random)
    // não caia fora da arena, senão ele tenta atravessar a parede do mundo.
    _target.x = _target.x.clamp(-w, w);
    _target.y = _target.y.clamp(-h, h);
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
     // Ignora coisas que não são barreiras físicas
     if (other is Web || other is PoisonPuddle) return;
     
     // Ignora se o alvo atual JÁ ESTÁ longe do objeto (evita jitter)
     if (other.position.distanceTo(_target) > other.position.distanceTo(enemy.position)) {
       return;
     }

     // 1. Calcula vetor que aponta PARA LONGE do objeto (Inimigo - Objeto)
     _tempCalc.setFrom(enemy.position);
     _tempCalc.sub(other.position);
     
     // 2. Escolhe novo alvo usando esse vetor como guia
     _pickNewTarget(pushAwayFrom: _tempCalc);
  }
}

class BouncerBehavior extends MovementBehavior {
  Vector2 _velocity = Vector2.zero();

  @override
  void update(double dt) {
    // Inicializa velocidade se estiver parada
    if (_velocity == Vector2.zero()) {
       final rng = Random();
       double angle = rng.nextDouble() * 2 * pi;
       _velocity = Vector2(cos(angle), sin(angle)) * enemy.speed;
    }
    
    enemy.position += _velocity * dt;
    _checkBounds();
  }

  void _checkBounds() {
   // Pegamos o tamanho REAL do inimigo (seja 32, 96 ou 200)
    double halfWidth = enemy.size.x / 2;
    double halfHeight = enemy.size.y / 2;

    // Limites da Arena (considerando o tamanho do inimigo)
    double rightLimit = (TowerGame.arenaWidth / 2) - halfWidth;
    double leftLimit = -(TowerGame.arenaWidth / 2) + halfWidth;
    double topLimit = -(TowerGame.arenaHeight / 2) + halfHeight;
    double bottomLimit = (TowerGame.arenaHeight / 2) - halfHeight;

    bool bounced = false;

    // --- EIXO X ---
    if (enemy.position.x >= rightLimit) {
      _velocity.x = -_velocity.x.abs(); // Força ir para Esquerda
      enemy.position.x = rightLimit;      // Desgruda da parede
      bounced = true;
    } 
    else if (enemy.position.x <= leftLimit) {
      _velocity.x = _velocity.x.abs();  // Força ir para Direita
      enemy.position.x = leftLimit;       // Desgruda da parede
      bounced = true;
    }

    // --- EIXO Y ---
    if (enemy.position.y >= bottomLimit) {
      _velocity.y = -_velocity.y.abs(); // Força ir para Cima
      enemy.position.y = bottomLimit;     // Desgruda
      bounced = true;
    } 
    else if (enemy.position.y <= topLimit) {
      _velocity.y = _velocity.y.abs();  // Força ir para Baixo
      enemy.position.y = topLimit;        // Desgruda
      bounced = true;
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Wall) {
      // 1. Descobrir se bateu no lado ou em cima/baixo
      // Pegamos o retângulo de colisão (interseção)
      final myRect = enemy.toAbsoluteRect();
      final otherRect = other.toAbsoluteRect();
      final intersection = myRect.intersect(otherRect);

      // 2. Lógica de Quique
      // Se a interseção é mais alta que larga -> Colisão Horizontal (Lados)
      if (intersection.width < intersection.height) {
         // Verifica direção para evitar "quiques duplos" ou prender
         // Se estou indo para a Direita (Vel > 0) e a parede está na minha Direita...
         if (_velocity.x > 0 && enemy.position.x < other.position.x) {
            _velocity.x = -_velocity.x; // Inverte X
         }
         // Se estou indo para a Esquerda e a parede está na Esquerda...
         else if (_velocity.x < 0 && enemy.position.x > other.position.x) {
            _velocity.x = -_velocity.x; // Inverte X
         }
      } 
      // Se a interseção é mais larga que alta -> Colisão Vertical (Topo/Baixo)
      else {
         // Indo para Baixo, parede embaixo
         if (_velocity.y > 0 && enemy.position.y < other.position.y) {
            _velocity.y = -_velocity.y; // Inverte Y
         }
         // Indo para Cima, parede em cima
         else if (_velocity.y < 0 && enemy.position.y > other.position.y) {
            _velocity.y = -_velocity.y; // Inverte Y
         }
      }
      
      // Opcional: Empurrão extra para desgrudar
      // (O Enemy.dart já faz um empurrão básico, mas se ainda prender, descomente abaixo)
      // final separation = (enemy.position - other.position).normalized();
      // enemy.position += separation * 2.0;
    }
  }
}

// --- ATAQUES (ATTACK BEHAVIORS) ---

class NoAttackBehavior extends AttackBehavior {
  @override
  void update(double dt) {}
}

class ProjectileAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  double speed;
  late Vector2 size;
  
  // Tipos de tiro
  final bool isShotgun;
  final bool is2shot;
  final bool isOrbital;
  final double orbitalRadius;
  final bool isStraight;
  final bool isHoming;
  final bool isBoomerang;

  // --- NOVAS CONFIGURAÇÕES DE RAJADA (BURST) ---
  final bool isBurst;
  final int burstCount;       // Quantos tiros por rajada
  final double burstDelay;    // Tempo entre os tiros da rajada (ex: 0.1s)

  // Variáveis de controle interno da rajada
  bool _isBurstActive = false;
  int _burstShotsFired = 0;
  double _burstTimer = 0;

  ProjectileAttackBehavior({
    this.interval = 2.0,
    this.speed = 200,
    this.isShotgun = false,
    this.is2shot = false,
    this.isOrbital = false,
    this.isStraight = true,
    this.isBurst = false,
    this.isHoming = false,
    this.isBoomerang = false,
    this.burstCount = 3,
    this.burstDelay = 0.2,
    this.orbitalRadius = 50.0,
    Vector2? size,
  }) {
    this.size = size ?? Vector2.all(10);
  }

  @override
  void update(double dt) {
    if (!enemy.isMounted) return;

    // --- LÓGICA DA RAJADA ATIVA ---
    if (_isBurstActive) {
      _burstTimer += dt;
      
      if (_burstTimer >= burstDelay) {
        _triggerShotPattern(); // Atira
        _burstShotsFired++;
        _burstTimer = 0; // Reseta timer do tiro rápido

        // Verifica se acabou a rajada
        if (_burstShotsFired >= burstCount) {
          _isBurstActive = false;
          _burstShotsFired = 0;
          _timer = 0; // Só agora reseta o Cooldown principal
        }
      }
      return; // Se está em rajada, não executa o timer principal
    }

    // --- LÓGICA DO INTERVALO PRINCIPAL (COOLDOWN) ---
    _timer += dt;
    if (_timer >= interval) {
      if (isBurst) {
        // INICIA A RAJADA
        _isBurstActive = true;
        _burstShotsFired = 0;
        _burstTimer = burstDelay; // Força o primeiro tiro a sair imediatamente no próximo frame
      } else {
        // TIRO NORMAL (Único)
        _triggerShotPattern();
        _timer = 0;
      }
    }
  }

  // Separei a lógica de QUAL tiro sai (Shotgun/Normal/2Shot) para poder reutilizar na rajada
  void _triggerShotPattern() {
    // Recalcula direção a cada tiro (para a rajada acompanhar o player se ele se mover)
    final player = enemy.gameRef.player;
    final direction = (player.position - enemy.position).normalized();

    if (is2shot) {
      _fireBullet(direction, 0.2);
      _fireBullet(direction, -0.2);
    } else {
      _fireBullet(direction, 0); // Tiro central
      
      if (isShotgun) {
        _fireBullet(direction, 0.3);
        _fireBullet(direction, -0.3);
      }
    }
  }

  void _fireBullet(Vector2 baseDir, double angleOffset) {
    AudioManager.playSfx('enemyShot.mp3');
    
    double x = baseDir.x * cos(angleOffset) - baseDir.y * sin(angleOffset);
    double y = baseDir.x * sin(angleOffset) + baseDir.y * cos(angleOffset);
    final newDir = Vector2(x, y);
    if(!isStraight){
      double angleOffset = Random().nextDouble() * 0.2;
      double x = newDir.x * cos(angleOffset) - newDir.y * sin(angleOffset);
      double y = newDir.x * sin(angleOffset) + newDir.y * cos(angleOffset);
      newDir.setValues(x, y);
    }

    enemy.gameRef.world.add(Projectile(
      position: enemy.position + newDir * 20,
      direction: newDir,
      damage: 1,
      speed: speed,
      size: size,
      owner: enemy,
      isOrbital: isOrbital,
      orbitalRadius: orbitalRadius,
      isHoming: isHoming,
      isBoomerang: isBoomerang,
      dieTimer: isBoomerang ? 1.0 : 3.0,
      isEnemyProjectile: true,
    ));
  }
}

class MortarAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  final double minRange = 600;
  final bool isPoison;
  final double explosionRadius;

  MortarAttackBehavior({this.interval = 4.0, this.isPoison = false, this.explosionRadius = 60.0});

  @override
  void update(double dt) {
    _timer += dt;
    final dist = enemy.position.distanceTo(enemy.gameRef.player.position);

    if (_timer >= interval && dist < minRange) {
      final target = enemy.gameRef.player.position.clone();
      double flightTime = 1.5;

      enemy.gameRef.world.add(TargetReticle(
        position: target,
        duration: flightTime,
        owner: enemy,
        radius: explosionRadius,
      ));
      AudioManager.playSfx('enemyShot.mp3');
      enemy.gameRef.world.add(MortarShell(
        startPos: enemy.position.clone(),
        targetPos: target,
        owner: enemy,
        flightDuration: flightTime,
        isPoison: isPoison,
        explosionRadius: explosionRadius,
      ));
      
      _timer = 0;
    }
  }
}

class LaserAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  bool _isShooting = false;
  bool isMoving;
  final bool isShotgun;
  
  LaserAttackBehavior({this.interval = 3.0, this.isMoving = false, this.isShotgun = false});

  @override
  void update(double dt) {
    _timer += dt;

    if (_isShooting) {
      enemy.canMove = false; // TRAVA O MOVIMENTO
      if (_timer > 1.2) {
        _isShooting = false;
        enemy.canMove = true; // DESTRAVA
        _timer = 0;
      }
      return;
    }

    final dist = enemy.position.distanceTo(enemy.gameRef.player.position);
    if (_timer >= interval && dist < 350) {
      _isShooting = true;
      _timer = 0;
      
      final dir = (enemy.gameRef.player.position - enemy.position).normalized();
      final angle = atan2(dir.y, dir.x);

      enemy.gameRef.world.add(LaserBeam(
        position: enemy.position + (dir * 10),
        angleRad: angle,
        owner: enemy,
        isMoving: isMoving,
        isEnemyProjectile: true,
      ));
      if (isShotgun) {
        // Tiros adicionais com ângulo levemente diferente
        enemy.gameRef.world.add(LaserBeam(
          position: enemy.position + (dir * 10),
          angleRad: angle + 0.2,
          owner: enemy,
          isMoving: isMoving,
          isEnemyProjectile: true,
        ));
        enemy.gameRef.world.add(LaserBeam(
          position: enemy.position + (dir * 10),
          angleRad: angle - 0.2,
          owner: enemy,
          isMoving: isMoving,
          isEnemyProjectile: true,
        ));
      }
    }
  }
}

class SpinnerAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  final bool isDiagonal;
  final bool isChangeDir;
  final bool isBoomerang;
  int changeDirAux = 0;

  SpinnerAttackBehavior({
    this.interval = 1.5, 
    this.isDiagonal = false, 
    this.isChangeDir = false,
    this.isBoomerang = false,
  });

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= interval) {
      // Atira em cruz
      List<Vector2> directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)];

      if (isDiagonal || isChangeDir && changeDirAux>=4){
        directions = [Vector2(-1, -1), Vector2(1, 1), Vector2(-1, 1), Vector2(1, -1)];
        changeDirAux = 0;
      }

      for (var dir in directions) {
        enemy.gameRef.world.add(Projectile(
          position: enemy.position + dir * 20,
          direction: dir,
          damage: 1,
          speed: 200,
          owner: enemy,
          isBoomerang: isBoomerang,
          dieTimer: isBoomerang ? 1.0 : 3.0,
          isEnemyProjectile: true,
        ));

        if (isChangeDir) changeDirAux++;
        AudioManager.playSfx('enemyShot.mp3');
      }     
      // Gira visualmente
      //final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      //visual?.angle += pi / 4;
      
      _timer = 0;
    }
  }
}

class DashAttackBehavior extends AttackBehavior {
  int _state = 0; // 0: Aim, 1: Dash, 2: Recover
  double _timer = 0;
  Vector2 _dashDir = Vector2.zero();
  
  // Flag para evitar múltiplas colisões no mesmo frame
  bool _hitProcessed = false; 

  @override
  void update(double dt) {
    _hitProcessed = false; 
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;

    if (_state == 0) { // --- MIRA (AIMING) ---
      enemy.canMove = false; 
      
      if (_timer < 0.5) { 
         final player = enemy.gameRef.player;
         _dashDir = (player.position - enemy.position).normalized();
         if(visual != null) visual.angle = atan2(_dashDir.y, _dashDir.x) + enemy.rotateOff;
      } else { 
         if (_timer < 0.6) { 
            enemy.gameRef.world.add(PathEffect(
              position: enemy.position.clone(),
              angleRad: atan2(_dashDir.y, _dashDir.x),
              owner: enemy,
            ));
         }
      }
      
      _timer += dt;
      if (_timer >= 1.0) {
        _state = 1; // VAI PARA O DASH
        _timer = 0;
        if(visual != null) visual.setColor(Pallete.vermelho);
      }
      
    } else if (_state == 1) { // --- INVESTIDA (DASHING) ---
       
       // Move
       enemy.position += _dashDir * 350 * dt; 
       
       // VERIFICAÇÃO MANUAL DE BORDA (A correção está aqui!)
       // Se bater na borda da arena, para imediatamente.
       if(_checkArenaImpact()) {
          _triggerBonk();
       }
       
    } else if (_state == 2) { // --- RECUPERAÇÃO (RECOVERING) ---
       _timer += dt;
       if (_timer >= 1.0) {
         _state = 0; // Volta a mirar
         _timer = 0;
         enemy.canMove = true;
         if(visual != null) visual.setColor(Pallete.amarelo);
       }
    }
  }

  // Escuta colisões com Paredes Internas (Walls)
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_state == 1 && other is Wall && !_hitProcessed) {
       _triggerBonk();
       _hitProcessed = true;
    }
  }

  // --- FUNÇÃO QUE PARA O DASH ---
  void _triggerBonk() {
    _state = 2; // Muda estado para Recuperando
    _timer = 0;
    
    // Empurrão para trás (Recuo) para desgrudar da parede
    enemy.position -= _dashDir * 20; 
    
    // Feedback visual (opcional)
    enemy.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
  }

  // --- VERIFICA SE BATEU NA BORDA DA ARENA ---
  bool _checkArenaImpact() {
    bool hit = false;
    double halfW = TowerGame.arenaWidth / 2;
    double halfH = TowerGame.arenaHeight / 2;
    
    // Raio do inimigo (aprox metade do tamanho)
    double r = enemy.size.x / 2;

    // Borda Esquerda ou Direita
    if (enemy.position.x <= -halfW + r || enemy.position.x >= halfW - r) {
      hit = true;
    }

    // Borda Cima ou Baixo
    if (enemy.position.y <= -halfH + r || enemy.position.y >= halfH - r) {
      hit = true;
    }

    return hit;
  }
}

class ChargeAttackBehavior extends AttackBehavior {
  // Configurações
  final double detectRange; // Distância para ativar
  final double chargeSpeed; // Velocidade da investida
  final double prepTime;    // Tempo parado avisando que vai atacar
  
  // Variáveis de Estado
  int _state = 0; // 0: Idle, 1: Prep, 2: Charge, 3: Cooldown
  double _timer = 0;
  Vector2 _chargeDir = Vector2.zero();

  ChargeAttackBehavior({
    this.detectRange = 200,
    this.chargeSpeed = 350,
    this.prepTime = 0.5,
  });

  @override
  void update(double dt) {
    final player = enemy.gameRef.player;
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;

    // --- ESTADO 0: VIGILÂNCIA ---
    // O inimigo está andando aleatoriamente (controlado pelo MovementBehavior)
    if (_state == 0) {
      double dist = enemy.position.distanceTo(player.position);
      
      if (dist <= detectRange) {
        // PLAYER ENTROU NO ALCANCE!
        _state = 1;
        _timer = 0;
        enemy.canMove = false; // Trava o movimento aleatório
        
        // Feedback Visual: Fica Vermelho (Perigo!)
        visual?.setColor(Pallete.vermelho);
      }
    }

    // --- ESTADO 1: PREPARAÇÃO ---
    // Fica parado "carregando" o ataque
    else if (_state == 1) {
      _timer += dt;
      
      // Mira no jogador enquanto prepara (opcional, deixa mais difícil)
      _chargeDir = (player.position - enemy.position).normalized();
      
      // Se tiver visual, rotaciona para olhar pro player
      if (visual != null && !enemy.rotates) {
         if (player.position.x < enemy.position.x) visual.scale.x = -1;
         else visual.scale.x = 1;
      }

      if (_timer >= prepTime) {
        _state = 2; // INICIA A CARGA
        _timer = 0;
      }
    }

    // --- ESTADO 2: INVESTIDA (CHARGE) ---
    // Corre na direção travada
    else if (_state == 2) {
      _timer += dt;
      
      // Move manualmente (ignorando speed base)
      enemy.position += _chargeDir * chargeSpeed * dt;

      // Duração máxima da investida (ex: 1 segundo ou até bater)
      if (_timer >= 1.0) {
        _stopCharge();
      }
    }

    // --- ESTADO 3: COOLDOWN ---
    // Descansa um pouco antes de voltar a andar
    else if (_state == 3) {
      _timer += dt;
      if (_timer >= 1.5) { // 1.5s de descanso
        _state = 0; // Volta a andar aleatoriamente
        _timer = 0;
        enemy.canMove = true; // Libera movimento
        visual?.setColor(enemy.originalColor); // Cor volta ao normal
      }
    }
  }

  // Se bater na parede ou no player durante a carga, para.
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_state == 2) { // Só importa se estiver correndo
      if (other is Wall) {
        // Empurra um pouco pra trás pra não grudar
        enemy.position -= _chargeDir * 10;
        _stopCharge();
      }
      // Se bater no player, o player toma dano (lógica já existente no Player/Enemy),
      // mas podemos parar o dash também:
      if (other == enemy.gameRef.player) {
         _stopCharge();
      }
    }
  }

  void _stopCharge() {
    _state = 3; // Vai para Cooldown
    _timer = 0;
    // Opcional: Feedback visual de "tonto" ou "cansado"
    enemy.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.cinzaEsc);
  }
}

class JumpAttackBehavior extends AttackBehavior {
  final double jumpRange;
  final double minRange;
  final double jumpDuration;
  final double cooldown;
  final double impactRadius;
  final double maxJumpHeight; 

  final bool isRandomJump; 
  final double randomJumpRadius; 

  final bool isExplosionOnLand;
  final bool is4ShotOnLand;

  late Player _cachedPlayer;

  bool _isJumping = false;
  double _timer = 0;
  Vector2 _startPos = Vector2.zero();
  Vector2 _targetPos = Vector2.zero();

  // Referências para os efeitos visuais
  CircleComponent? _shadow;

  JumpAttackBehavior({
    this.jumpRange = 250,
    this.minRange = 50,
    this.jumpDuration = 0.8,
    this.cooldown = 2.5,
    this.impactRadius = 60,
    this.maxJumpHeight = 120.0, // Altura que ele sobe na tela
    this.isRandomJump = false, // Padrão: Comportamento antigo
    this.randomJumpRadius = 100.0,
    this.isExplosionOnLand = true, // Se true, cria efeito de explosão ao aterrissar
    this.is4ShotOnLand = false, // Se true, atira 4 projéteis ao aterrissar
  });

  @override
  void update(double dt) {
    if (!enemy.isMounted) return;
    _cachedPlayer = enemy.gameRef.player;

    if (_isJumping) {
      _timer += dt;
      double progress = (_timer / jumpDuration).clamp(0.0, 1.0);

      // 1. Posição Lógica (Move a "sombra" no chão em linha reta)
      enemy.position.x = lerpDouble(_startPos.x, _targetPos.x, progress)!;
      enemy.position.y = lerpDouble(_startPos.y, _targetPos.y, progress)!;

      // 2. Cálculo da Parábola (Senoide vai de 0 -> 1 -> 0)
      double arc = sin(progress * pi);
      double heightFactor = sin(progress * pi);
      
      // 3. Move o VISUAL para cima (Simulando o eixo Z)
      //final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (enemy.visual != null) {
        // A posição padrão do ícone é size / 2. Nós subtraímos a altura.
        enemy.visual!.position.y = (enemy.size.y / 2) - (arc * maxJumpHeight);
        enemy.scale = Vector2.all(1.0 + (heightFactor * 0.5));
      }

      // 4. Efeito na Sombra (Fica menor e mais clara quanto mais alto o inimigo vai)
      if (_shadow != null) {
        _shadow!.scale = Vector2.all(1.0 - (arc * 0.6)); // Encolhe até 40%
        _shadow!.paint.color = Pallete.cinzaEsc;
      }

      if (progress >= 1.0) {
        _land();
      }
    } else {
      _timer += dt;

      if (_timer >= cooldown) {
        if (isRandomJump) {
          // MODO ALEATÓRIO: Pula para um lugar qualquer por perto
          _startJump(_getRandomTarget());
        } else {
          // MODO PADRÃO: Pula no jogador se estiver no alcance
          final player = enemy.gameRef.player;
          double dist = enemy.position.distanceTo(player.position);

          if (dist <= jumpRange && dist >= minRange) {
            _startJump(player.position);
          }
        }
      }
    }
  }

  Vector2 _getRandomTarget() {
    final rng = Random();
    
    // Gera ângulo e distância aleatórios
    double angle = rng.nextDouble() * 2 * pi;
    double dist = (rng.nextDouble() * randomJumpRadius) + 30; // +30 para evitar pulos muito curtos
    
    // Calcula o deslocamento
    Vector2 offset = Vector2(cos(angle), sin(angle)) * dist;
    Vector2 target = enemy.position + offset;

    // (Opcional) Clampar para dentro da arena para ele não pular no vazio
    double halfW = TowerGame.arenaWidth / 2 - 20;
    double halfH = TowerGame.arenaHeight / 2 - 20;
    
    target.x = target.x.clamp(-halfW, halfW);
    target.y = target.y.clamp(-halfH, halfH);

    return target;
  }

  void _startJump(Vector2 target) {
    _isJumping = true;
    enemy.isIntangivel = true;
    _timer = 0;
    enemy.canMove = false;
    
    _startPos = enemy.position.clone();
    _targetPos = target.clone();

    // 1. Cria a Mira no chão do Mundo
    if (!isRandomJump){
      enemy.gameRef.world.add(TargetReticle(
        position: target,
        duration: jumpDuration,
        radius: impactRadius,
      ));

    }
    
    // 2. Cria a Sombra no Inimigo (Fica no 'chão' relativo a ele)
    _shadow = CircleComponent(
      radius: enemy.size.x / 2.5,
      position: enemy.size / 2, // Fica no centro lógico
      anchor: Anchor.center,
      paint: Paint()..color = Colors.black.withOpacity(0.5),
      priority: -1, // Garante que a sombra fique ATRÁS do corpo do inimigo
    );
    // Para criar um oval (sombra realista), achatamos o eixo Y
    _shadow!.scale.y = 0.5; 
    enemy.add(_shadow!);
  }

  void _land() {
    _isJumping = false;
    enemy.isIntangivel = false;
    _timer = 0;
    enemy.canMove = true;

    // 1. Limpeza Visual (Remove mira, remove sombra, reseta altura do sprite)
    _shadow?.removeFromParent();
    _shadow = null;
    
    if (enemy.visual != null) {
      enemy.visual!.position.y = enemy.size.y / 2; // Volta pro chão
    }
    enemy.scale = Vector2.all(1.0);

    // 2. Impacto e Dano
    if (isExplosionOnLand){
      createExplosionEffect(enemy.gameRef.world, enemy.position, Colors.orange, count: 15);
      
      if (enemy.position.distanceTo(_cachedPlayer.position) <= impactRadius) {
        _cachedPlayer.takeDamage(1);
        Vector2 pushDir = (_cachedPlayer.position - enemy.position).normalized();
        _cachedPlayer.position += pushDir * 30;
      }
    }else if (is4ShotOnLand){
      List<Vector2> directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)];
      for (var dir in directions) {
        enemy.gameRef.world.add(Projectile(
          position: enemy.position + dir * 20,
          direction: dir,
          damage: 1,
          speed: 200,
          owner: enemy,
          isEnemyProjectile: true,
        ));
      } 
    }
    
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (_isJumping) return; // Ignora colisões enquanto voa
    super.onCollision(intersectionPoints, other);
  }
}

class SummonAttackBehavior extends AttackBehavior {
  final double interval;
  final int maxMinions;
  final EnemyBuilder minionBuilder; // <--- A VARIÁVEL MÁGICA
  
  double _timer = 0;
  final List<Enemy> _minions = []; 

  SummonAttackBehavior({
    required this.minionBuilder, // Agora é obrigatório dizer O QUE ele invoca
    this.interval = 4.0, 
    this.maxMinions = 3
  });

  @override
  void update(double dt) {
    _timer += dt;
    _minions.removeWhere((e) => !e.isMounted);

    if (_timer >= interval) {
      if (_minions.length < maxMinions) {
        _summonMinion();
        _timer = 0;
      }
    }
  }

  void _summonMinion() {
    // Efeito visual no Invocador (Pisca)
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;
    visual?.setColor(Pallete.rosa);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (enemy.isMounted) visual?.setColor(enemy.originalColor);
    });

    // Posição aleatória
    final rng = Random();
    double offsetX = (rng.nextDouble() * 60) - 30; 
    double offsetY = (rng.nextDouble() * 60) - 30;
    Vector2 spawnPos = enemy.position + Vector2(offsetX, offsetY);

    // --- AQUI A MÁGICA ACONTECE ---
    // Usamos a função variável para criar o inimigo específico
    final minion = minionBuilder(spawnPos);
    
    // Configurações extras opcionais (se quiser forçar que minions sejam menores)
    // minion.scale = Vector2.all(0.8); 
    
    enemy.gameRef.world.add(minion);
    _minions.add(minion);

    createExplosionEffect(enemy.gameRef.world, spawnPos, Pallete.cinzaCla, count: 5);
  }
}

class DropHazardBehavior extends AttackBehavior {
  final double interval;
  final HazardBuilder hazardBuilder; // A função que cria o objeto
  double _timer = 0;

  DropHazardBehavior({
    required this.hazardBuilder, // Obrigatório: O que soltar?
    this.interval = 3.0,
  });

  @override
  void update(double dt) {
    _timer += dt;
    
    if (_timer >= interval) {
      // Verifica se o inimigo ainda existe antes de tentar soltar algo
      if (enemy.isMounted) {
        _dropHazard();
        _timer = 0;
      }
    }
  }

  void _dropHazard() {
    // 1. Usa a função builder para criar o objeto na posição atual
    final hazard = hazardBuilder(enemy.position.clone());
    
    // 2. Adiciona ao mundo
    enemy.gameRef.world.add(hazard);
  }
}

// --- MORTES (DEATH BEHAVIORS) ---

// 1. Padrão: Apenas morre (dá almas e somem)
class NoDeathEffect extends DeathBehavior {
  @override
  void onDeath() {
    // Nada acontece (além da lógica padrão do Enemy)
  }
}

// 2. Explosão: Cria dano em área ao morrer (Kamikaze)
class ExplosionDeathBehavior extends DeathBehavior {
  final int damage;
  final double radius;

  ExplosionDeathBehavior({this.damage = 10, this.radius = 60});

  @override
  void onDeath() {
    // Efeito Visual
    createExplosionEffect(enemy.gameRef.world, enemy.position, Pallete.vermelho, count: 20);

    // Lógica de Dano em Área (AOE)
    // Verifica se o player está perto
    final player = enemy.gameRef.player;
    if (player.position.distanceTo(enemy.position) <= radius) {
       player.takeDamage(damage);
    }
    
    // Opcional: Dano em outros inimigos (Fogo Amigo)
    // ...
  }
}

// 3. Projéteis: Solta tiros em todas as direções (Bullet Hell)
class ProjectileBurstDeathBehavior extends DeathBehavior {
  final int projectileCount;
  
  ProjectileBurstDeathBehavior({this.projectileCount = 8});

  @override
  void onDeath() {
    double step = (2 * pi) / projectileCount;

    for (int i = 0; i < projectileCount; i++) {
      double angle = step * i;
      Vector2 dir = Vector2(cos(angle), sin(angle));
      
      enemy.gameRef.world.add(Projectile(
        position: enemy.position,
        direction: dir,
        damage: 1,
        speed: 150,
        owner: enemy,
        isEnemyProjectile: true,
      ));
    }
  }
}

// 4. Invocação: O inimigo se divide em outros (Slime Split)
class SpawnOnDeathBehavior extends DeathBehavior {
  final int count;
  final EnemyBuilder minionBuilder;

  SpawnOnDeathBehavior({required this.minionBuilder, this.count = 2});

  @override
  void onDeath() {
    for (int i = 0; i < count; i++) {
      // Pequena variação na posição para não nascerem empilhados
      Vector2 offset = Vector2(
        (Random().nextDouble() - 0.5) * 50,
        (Random().nextDouble() - 0.5) * 50,
      );
      
      final minion = minionBuilder(enemy.position + offset);
      
      // Opcional: Minions nascem menores/mais fracos
      //minion.scale = Vector2.all(0.7);
      //minion.hp = minion.hp / 2;
      
      enemy.gameRef.world.add(minion);
    }
  }
}