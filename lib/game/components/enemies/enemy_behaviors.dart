import 'dart:math';
import '../gameObj/wall.dart';
import 'package:flame/components.dart';
import '../../tower_game.dart';
import 'enemy.dart';
import '../projectiles/projectile.dart';
import '../projectiles/laser_beam.dart';
import '../projectiles/mortar_shell.dart';
import '../effects/target_reticle.dart';
import '../effects/path_effect.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';

// --- INTERFACES ---

abstract class MovementBehavior {
  late Enemy enemy;
  void update(double dt);
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {}
}

abstract class AttackBehavior {
  late Enemy enemy;
  void update(double dt);
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
      if (visual != null) visual.angle = atan2(direction.y, direction.x) + (pi / 2);
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
     // Se bateu na parede, muda o alvo
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
    // ... (Seu código de limites da tela continua igual aqui) ...
    // Apenas certifique-se que o padding/raio está correto
    double limitX = TowerGame.arenaWidth / 2 - 16; // -16 (metade do inimigo 32px)
    double limitY = TowerGame.arenaHeight / 2 - 16;

    if (enemy.position.x <= -limitX) {
      enemy.position.x = -limitX + 1; // Tira da parede
      if (_velocity.x < 0) _velocity.x = -_velocity.x; // Só inverte se estiver indo contra
    } 
    else if (enemy.position.x >= limitX) {
      enemy.position.x = limitX - 1;
      if (_velocity.x > 0) _velocity.x = -_velocity.x;
    }

    if (enemy.position.y <= -limitY) {
      enemy.position.y = -limitY + 1;
      if (_velocity.y < 0) _velocity.y = -_velocity.y;
    } 
    else if (enemy.position.y >= limitY) {
      enemy.position.y = limitY - 1;
      if (_velocity.y > 0) _velocity.y = -_velocity.y;
    }
  }

  // --- ADICIONE ESTE MÉTODO ---
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

  ProjectileAttackBehavior({this.interval = 2.0});

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= interval) {
      final player = enemy.gameRef.player;
      final direction = (player.position - enemy.position).normalized();
      
      enemy.gameRef.world.add(Projectile(
        position: enemy.position + direction * 20,
        direction: direction,
        damage: 1,
        speed: 200,
        owner: enemy,
        isEnemyProjectile: true,
      ));
      _timer = 0;
    }
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
  
  LaserAttackBehavior({this.interval = 3.0});

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
        isEnemyProjectile: true,
      ));
    }
  }
}

class SpinnerAttackBehavior extends AttackBehavior {
  final double interval;
  double _timer = 0;

  SpinnerAttackBehavior({this.interval = 1.5});

  @override
  void update(double dt) {
    _timer += dt;
    if (_timer >= interval) {
      // Atira em cruz
      final directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)];
      
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
      
      // Gira visualmente
      final visual = enemy.children.whereType<GameIcon>().firstOrNull;
      visual?.angle += pi / 4;
      
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
         if(visual != null) visual.angle = atan2(_dashDir.y, _dashDir.x) + (pi/2);
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