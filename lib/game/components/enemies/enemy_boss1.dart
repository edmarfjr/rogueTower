import 'dart:math';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/tower_game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import '../projectiles/projectile.dart';
import '../projectiles/laser_beam.dart';
import '../core/game_icon.dart';
import '../effects/floating_text.dart';
import '../effects/explosion.dart'; 

class BossEnemy extends Enemy {
  double _attackTimer = 0;
  final double attackInterval = 3; 
  double _specialAttackCooldown = 6.0; 
  double _specialAttackTimer = 0;
  bool _isPerformingSpecial = false;
  final double maxHp; 
  late BossHealthBar _healthBar;

  BossEnemy({required Vector2 position, int level = 1}) 
    : maxHp = 200,
    super(position: position) {
    hp = maxHp;
    speed = 40;
    soul = 150; 
    rotaciona = true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(64); 
    
    children.whereType<ShapeHitbox>().toList().forEach((h) => h.removeFromParent());
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());

    add(GameIcon(
      icon: Icons.bug_report, 
      color: Pallete.rosa,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    add(RectangleHitbox(
      size: size , 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));
  }

   @override
  void onMount() {
    super.onMount();
    
    // 1. Cria a barra
    _healthBar = BossHealthBar(this, maxHp)
      ..size = Vector2(260, 16) // Largura e Altura da barra
      ..anchor = Anchor.topCenter
      // O Viewport tem 360 de largura (definido no TowerGame). 
      // 360 / 2 = 180 (Meio exato da tela). O Y é 40 para dar um espaço do topo.
      ..position = Vector2(180, 40); 

    // 2. ADICIONA AO VIEWPORT (Isso prende ela na tela, ignorando a câmera!)
    gameRef.camera.viewport.add(_healthBar);
  }

  @override
  void onRemove() {
    // Quando o Boss morrer (ou a sala resetar), a barra some junto!
    _healthBar.removeFromParent();
    super.onRemove();
  }

  @override
  void update(double dt) {
    // Nota: Não chamamos super.update(dt) aqui para ter controle total,
    // mas chamamos os comportamentos manualmente.
    if (_isPerformingSpecial) {
      _specialAttackTimer += dt;
      
      // O Laser demora 0.9s (0.6 carrega + 0.3 atira).
      // Vamos travar o boss por 1.5s para ele "descansar" após o ataque.
      if (_specialAttackTimer > 2) {
        _isPerformingSpecial = false;
        _specialAttackTimer = 0; // Reseta o timer para contar o próximo cooldown
      }
      return; 
    }

    _specialAttackTimer += dt;

    // Se o timer bateu o cooldown -> INICIA O ATAQUE
    if (_specialAttackTimer >= _specialAttackCooldown) {
      _startOmniLaserAttack();
    } else {
      // Se não está atacando, segue o comportamento padrão (andar/atirar normal)
      behaviorFollowPlayer(dt);
      _attackBehavior(dt);
      handleHitEffect(dt);
      super.update(dt); 
    }

  }

  void _startOmniLaserAttack() {
    //print("BOSS: OMNI LASER!");
    _isPerformingSpecial = true;
    _specialAttackTimer = 0;

    // 1. TELEPORTAR PARA O CENTRO
    // Efeito visual simples: Teletransporte instantâneo
    //position = Vector2(0, 0);
    
    // (Opcional) Flash de cor para indicar teleporte
    //children.whereType<GameIcon>().firstOrNull?.setColor(Colors.purpleAccent);
    
    // 2. DISPARAR EM TODAS AS DIREÇÕES
    // Vamos criar 12 lasers formando um círculo completo (360 graus / 12 = 30 graus cada)
    int numberOfLasers = 12;
    double step = (2 * pi) / numberOfLasers; // Passo em radianos

    for (int i = 0; i < numberOfLasers; i++) {
      double angle = step * i;

      // Adiciona o Laser
      gameRef.world.add(LaserBeam(
        position: position, // Sai do centro do Boss
        angleRad: angle,    // Ângulo calculado
        owner: this,      // O Boss é o dono (se morrer, laser some)
        damage: 1,          // Dano
        length: 500,        // Comprimento longo para cobrir a arena
      ));
    }
    
    // 3. RESTAURA A COR (após um tempinho)
    Future.delayed(const Duration(seconds: 1), () {
      if (isMounted) {
         children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.rosa); // Ou sua cor original
      }
    });
  }

  // Sobrescrevemos takeDamage para garantir que use a lógica do Boss (barra de vida e morte especial)
  @override
  void takeDamage(double damage) {
    if (hp <= 0) return;

    hp -= damage;
    
    // Efeito visual (Piscar Branco)
    // Tenta achar o ícone e pintar de branco
    final visual = children.whereType<GameIcon>().firstOrNull;
    if (visual != null) {
        // AGORA FUNCIONA: Chamamos o método que acabamos de criar
        visual.setColor(Pallete.branco); 
        
        Future.delayed(const Duration(milliseconds: 100), () {
            if (isMounted) { 
                 visual.setColor(Pallete.rosa); // Volta para a cor original
            }
        });
    }

    // Texto de dano
    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position + Vector2(0, -30),
      fontSize: 16,
    ));

    if (hp <= 0) {
      _die();
    }
  }

  void _attackBehavior(double dt) {
    _attackTimer -= dt;
    if (_attackTimer <= 0) {
      _shootShotgun();
      _attackTimer = attackInterval;
    }
  }

  void _shootShotgun() {
    // Verifica se o jogo ainda está ativo
    if (gameRef.isRemoved) return;

    final player = gameRef.player;
    final direction = (player.position - position).normalized();
    
    // Spread Shot
    _fireBullet(direction, -0.3); // Esquerda
    _fireBullet(direction, 0);    // Centro
    _fireBullet(direction, 0.3);  // Direita
  }

  void _fireBullet(Vector2 baseDir, double angleOffset) {
    double x = baseDir.x * cos(angleOffset) - baseDir.y * sin(angleOffset);
    double y = baseDir.x * sin(angleOffset) + baseDir.y * cos(angleOffset);
    final newDir = Vector2(x, y);

    gameRef.world.add(Projectile(
      position: position + newDir * 40,
      direction: newDir,
      damage: 1, 
      speed: 200,
      owner: this,
      isEnemyProjectile: true,
    ));
  }
  
  // Morte Especial
  void _die() {
    createExplosion(gameRef.world, position, Colors.purple, count: 50);
    
    gameRef.world.add(FloatingText(
        text: "BOSS DERROTADO!", 
        position: position, 
        color: Colors.yellow, 
        fontSize: 20
    ));
    gameRef.progress.addSouls(soul);
    removeFromParent();
  }
}


class BossHealthBar extends PositionComponent with HasGameRef<TowerGame> {
  final BossEnemy boss;
  final double maxHp;
  late final TextPaint _textPainter;

  BossHealthBar(this.boss, this.maxHp) {
    // Configura a fonte do texto "BOSS"
    _textPainter = TextPaint(
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Fundo da Barra (Cinza escuro/Preto)
    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(bgRect, Paint()..color = Colors.black87);

    // 2. Preenchimento da Vida (Vermelho)
    double hpPercent = boss.hp / maxHp;
    if (hpPercent < 0) hpPercent = 0; // Evita bugar se a vida ficar negativa
    
    final hpRect = Rect.fromLTWH(0, 0, size.x * hpPercent, size.y);
    canvas.drawRect(hpRect, Paint()..color = Pallete.vermelho); // Use sua cor

    // 3. Borda da Barra (Branca)
    canvas.drawRect(bgRect, Paint()..color = Colors.white ..style = PaintingStyle.stroke ..strokeWidth = 2);

    // 4. Texto com o Nome do Boss (Fica centralizado acima da barra)
    _textPainter.render(
      canvas, 
      "BOSS", 
      Vector2(size.x / 2, -20), // -20 coloca o texto em cima da barra
      anchor: Anchor.topCenter,
    );
  }
}