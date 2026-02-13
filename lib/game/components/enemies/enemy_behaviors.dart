import 'dart:math';
import 'dart:ui';
//import 'package:TowerRogue/game/components/projectiles/poison_puddle.dart';

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
import '../effects/explosion.dart';
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
  @override
  void update(double dt) {
    // Só anda se o ataque permitir
    if (!enemy.canMove) return;

    final player = enemy.gameRef.player;
    final direction = (player.position - enemy.position).normalized();
    
    // Rotação visual
    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) visual.angle = atan2(direction.y, direction.x) + enemy.rotateOff;
    }
    
    enemy.position += direction * enemy.speed * dt;
  }
}

class KeepDistanceBehavior extends MovementBehavior {
  final double minDistance;
  final double maxDistance;

  KeepDistanceBehavior({this.minDistance = 150, this.maxDistance = 250});

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    final player = enemy.gameRef.player;
    final distance = enemy.position.distanceTo(player.position);
    final direction = (player.position - enemy.position).normalized();

    // Rotação visual
    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) visual.angle = atan2(direction.y, direction.x) + enemy.rotateOff;
    }

    if (distance > maxDistance) {
      // Aproxima
      enemy.position += direction * enemy.speed * dt;
    } else if (distance < minDistance) {
      // Foge
      enemy.position -= direction * (enemy.speed * 0.8) * dt;
    }
  }
}

class RandomWanderBehavior extends MovementBehavior {
  Vector2 _target = Vector2.zero();

  @override
  void update(double dt) {
    if (!enemy.canMove) return;

    if (_target == Vector2.zero() || enemy.position.distanceTo(_target) < 10) {
      _pickNewTarget();
    }

    final direction = (_target - enemy.position).normalized();

    // Rotação visual
    if (enemy.rotates) {
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) visual.angle = atan2(direction.y, direction.x) + enemy.rotateOff;
    }

    enemy.position += direction * enemy.speed * dt;
  }

  void _pickNewTarget() {
    final rng = Random();
    // Gera alvo aleatório dentro da arena
    double w = TowerGame.arenaWidth / 2 - 20;
    double h = TowerGame.arenaHeight / 2 - 20;
    _target = Vector2((rng.nextDouble() * 2 * w) - w, (rng.nextDouble() * 2 * h) - h);
  }
  
  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
     if (other is Web || other is PoisonPuddle) return;
     _pickNewTarget();
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
  bool isShotgun ;
  bool is2shot ;

  ProjectileAttackBehavior({
    this.interval = 2.0, 
    this.speed = 200,
    this.isShotgun = false,
    this.is2shot = false,
    Vector2? size,
  }) {
    this.size = size ?? Vector2.all(10);
  }

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= interval) {
      final player = enemy.gameRef.player;
      final direction = (player.position - enemy.position).normalized();
      
      if(is2shot){
        _fireBullet(direction, 0.2);
        _fireBullet(direction, -0.2);
      }else{
        _fireBullet(direction, 0);
      if (isShotgun){
        _fireBullet(direction, 0.3);
        _fireBullet(direction, -0.3);
      }
      }
      
      _timer = 0;
    }
  }

  void _fireBullet(Vector2 baseDir, double angleOffset) {
    double x = baseDir.x * cos(angleOffset) - baseDir.y * sin(angleOffset);
    double y = baseDir.x * sin(angleOffset) + baseDir.y * cos(angleOffset);
    final newDir = Vector2(x, y);

    enemy.gameRef.world.add(Projectile(
      position: enemy.position + newDir * 20,
      direction: newDir,
      damage: 1, 
      speed: speed,
      size: size,
      owner: enemy,
      isEnemyProjectile: true,
    ));
  }

}

class MortarAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  final double minRange = 600;

  MortarAttackBehavior({this.interval = 4.0});

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
        radius: 60,
      ));
      
      enemy.gameRef.world.add(MortarShell(
        startPos: enemy.position.clone(),
        targetPos: target,
        flightDuration: flightTime,
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
  
  LaserAttackBehavior({this.interval = 3.0, this.isMoving = false});

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
    }
  }
}

class SpinnerAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;
  final bool isDiagonal;
  final bool isChangeDir;
  int changeDirAux = 0;

  SpinnerAttackBehavior({
    this.interval = 1.5, 
    this.isDiagonal = false, 
    this.isChangeDir = false
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
          isEnemyProjectile: true,
        ));

        if (isChangeDir) changeDirAux++;
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
  final double maxJumpHeight; // <--- NOVA CONFIGURAÇÃO: Altura máxima do pulo

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
  });

  @override
  void update(double dt) {
    if (!enemy.isMounted) return;

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
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      if (visual != null) {
        // A posição padrão do ícone é size / 2. Nós subtraímos a altura.
        visual.position.y = (enemy.size.y / 2) - (arc * maxJumpHeight);
        enemy.scale = Vector2.all(1.0 + (heightFactor * 0.5));
      }

      // 4. Efeito na Sombra (Fica menor e mais clara quanto mais alto o inimigo vai)
      if (_shadow != null) {
        _shadow!.scale = Vector2.all(1.0 - (arc * 0.6)); // Encolhe até 40%
        _shadow!.paint.color = Pallete.azulEsc;
      }

      if (progress >= 1.0) {
        _land();
      }
    } else {
      _timer += dt;

      if (_timer >= cooldown) {
        final player = enemy.gameRef.player;
        double dist = enemy.position.distanceTo(player.position);

        if (dist <= jumpRange && dist >= minRange) {
          _startJump(player.position);
        }
      }
    }
  }

  void _startJump(Vector2 target) {
    _isJumping = true;
    enemy.isIntangivel = true;
    _timer = 0;
    enemy.canMove = false;
    
    _startPos = enemy.position.clone();
    _targetPos = target.clone();

    // 1. Cria a Mira no chão do Mundo
    enemy.gameRef.world.add(TargetReticle(
        position: target,
        duration: jumpDuration,
        radius: 60,
      ));

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
    
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;
    if (visual != null) {
      visual.position.y = enemy.size.y / 2; // Volta pro chão
    }

    // 2. Impacto e Dano
    createExplosion(enemy.gameRef.world, enemy.position, Colors.orange, count: 15);
    
    final player = enemy.gameRef.player;
    if (enemy.position.distanceTo(player.position) <= impactRadius) {
      player.takeDamage(1);
      Vector2 pushDir = (player.position - enemy.position).normalized();
      player.position += pushDir * 30;
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

    createExplosion(enemy.gameRef.world, spawnPos, Pallete.cinzaCla, count: 5);
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
    createExplosion(enemy.gameRef.world, enemy.position, Pallete.vermelho, count: 20);

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
        (Random().nextDouble() - 0.5) * 30,
        (Random().nextDouble() - 0.5) * 30,
      );
      
      final minion = minionBuilder(enemy.position + offset);
      
      // Opcional: Minions nascem menores/mais fracos
      //minion.scale = Vector2.all(0.7);
      //minion.hp = minion.hp / 2;
      
      enemy.gameRef.world.add(minion);
    }
  }
}