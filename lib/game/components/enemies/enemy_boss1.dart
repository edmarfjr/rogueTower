import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../tower_game.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';
import '../effects/floating_text.dart';
import '../effects/explosion.dart';
import '../projectiles/projectile.dart';
import '../projectiles/laser_beam.dart';

// Imports da nova arquitetura
import 'enemy.dart';
import 'enemy_behaviors.dart'; 

// --- COMPORTAMENTO DE ATAQUE DO BOSS ---
// Encapsulamos toda a lógica de ataque complexa aqui
class BossAttackBehavior extends AttackBehavior {
  
  // Timers
  double _attackTimer = 0;
  final double attackInterval = 3.0; 
  
  double _specialAttackTimer = 0;
  final double _specialAttackCooldown = 6.0; 
  
  bool _isPerformingSpecial = false;

  @override
  void update(double dt) {
    
    // --- LÓGICA DO ESPECIAL (Omni Laser) ---
    if (_isPerformingSpecial) {
      _specialAttackTimer += dt;
      
      // Trava o Boss por 2s enquanto atira os lasers
      if (_specialAttackTimer > 2.0) {
        _isPerformingSpecial = false;
        _specialAttackTimer = 0;
        enemy.canMove = true; // Destrava movimento
        
        // Retorna a cor original
        final visual = enemy.children.whereType<GameIcon>().firstOrNull;
        visual?.setColor(enemy.originalColor);
      }
      return; 
    }

    _specialAttackTimer += dt;

    if (_specialAttackTimer >= _specialAttackCooldown) {
      _startOmniLaserAttack();
    } else {
      // --- LÓGICA DO ATAQUE NORMAL (Shotgun) ---
      _attackTimer -= dt;
      if (_attackTimer <= 0) {
        _shootShotgun();
        _attackTimer = attackInterval;
      }
    }
  }

  void _startOmniLaserAttack() {
    _isPerformingSpecial = true;
    _specialAttackTimer = 0;
    
    // 1. TRAVA E TELEPORTA
    enemy.canMove = false; // Impede o FollowPlayerBehavior de mexer nele
    enemy.position = Vector2(0, 0); // Centro da arena
    
    // Feedback Visual
    final visual = enemy.children.whereType<GameIcon>().firstOrNull;
    visual?.setColor(Colors.purpleAccent);

    // 2. DISPARA LASERS EM 360 GRAUS
    int numberOfLasers = 12;
    double step = (2 * pi) / numberOfLasers;

    for (int i = 0; i < numberOfLasers; i++) {
      double angle = step * i;

      enemy.gameRef.world.add(LaserBeam(
        position: enemy.position, 
        angleRad: angle,    
        owner: enemy,      
        damage: 1,          
        length: 500,        
      ));
    }
  }

  void _shootShotgun() {
    if (enemy.gameRef.isRemoved) return;

    final player = enemy.gameRef.player;
    final direction = (player.position - enemy.position).normalized();
    
    // Dispara 3 projéteis (Spread)
    _fireBullet(direction, -0.3); // Esquerda
    _fireBullet(direction, 0);    // Centro
    _fireBullet(direction, 0.3);  // Direita
  }

  void _fireBullet(Vector2 baseDir, double angleOffset) {
    double x = baseDir.x * cos(angleOffset) - baseDir.y * sin(angleOffset);
    double y = baseDir.x * sin(angleOffset) + baseDir.y * cos(angleOffset);
    final newDir = Vector2(x, y);

    enemy.gameRef.world.add(Projectile(
      position: enemy.position + newDir * 40,
      direction: newDir,
      damage: 1, 
      speed: 200,
      owner: enemy,
      isEnemyProjectile: true,
    ));
  }
}

// --- CLASSE DO BOSS ---
class BossEnemy extends Enemy {
  final double maxHp; 
  late BossHealthBar _healthBar;

  BossEnemy({required Vector2 position, int level = 1}) 
    : maxHp = 200,
      super(
        position: position,
        hp: 200,
        speed: 40,
        soul: 150,
        rotates: true,
        weight: 100,
        iconData: Icons.bug_report,
        originalColor: Pallete.rosa,
        // Usamos comportamentos: Seguir Player + Ataque do Boss
        movementBehavior: FollowPlayerBehavior(), 
        attackBehavior: BossAttackBehavior(),
      );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // O Boss é maior que os inimigos normais
    size = Vector2.all(64); 
    
    // Atualiza Hitbox e Ícone para o tamanho novo
    children.whereType<GameIcon>().forEach((c) {
      c.size = size;
      c.position = size / 2;
    });
    
    // Remove hitbox padrão (32x32) e cria uma grande (64x64)
    children.whereType<ShapeHitbox>().toList().forEach((h) => h.removeFromParent());
    add(RectangleHitbox(
      size: size, 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));
  }

  @override
  void onMount() {
    super.onMount();
    // Cria a barra de vida no Viewport
    _healthBar = BossHealthBar(this, maxHp)
      ..size = Vector2(260, 16) 
      ..anchor = Anchor.topCenter
      ..position = Vector2(TowerGame.arenaWidth / 2, 40); // Ajustado para centralizar na largura do jogo? 
      // Se TowerGame.arenaWidth for a largura do MUNDO, cuidado. 
      // Geralmente Viewport usa coordenadas de tela fixas. 
      // Se sua câmera tem viewport fixo de 360 de largura, use 180.
      // Vou manter o padrão seguro:
      // ..position = Vector2(180, 40);

    gameRef.camera.viewport.add(_healthBar);
  }

  @override
  void onRemove() {
    _healthBar.removeFromParent();
    super.onRemove();
  }

  // Sobrescrevemos takeDamage para manter a morte dramática do Boss
  @override
  void takeDamage(double damage) {
    if (hp <= 0) return;

    // Chama a lógica padrão (Flash branco, texto de dano, redução de HP)
    // Mas ATENÇÃO: Se o HP zerar na super.takeDamage, ela chama removeFromParent().
    // O Boss quer explodir antes de sumir.
    
    // Vamos fazer o cálculo manual aqui para interceptar a morte
    hp -= damage;
    
    // Efeitos visuais manuais (reutilizando lógica do pai se possível, 
    // mas como queremos controlar a morte, melhor duplicar o flash ou chamar super com cuidado)
    
    // Vamos chamar o super apenas para os efeitos visuais de dano, 
    // mas vamos "curar" o hp virtualmente para o super não matar o boss? 
    // Não, é melhor reimplementar o básico aqui para ter controle total.
    
    // 1. Texto e Flash (Cópia da lógica do Enemy para consistência)
    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position + Vector2(0, -30),
      fontSize: 16,
    ));
    
    // Pinta de branco
    final visual = children.whereType<GameIcon>().firstOrNull;
    visual?.setColor(Pallete.branco);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted) visual?.setColor(originalColor);
    });

    // 2. Morte Personalizada
    if (hp <= 0) {
      _die();
    }
  }

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

// --- BARRA DE VIDA (Mantida igual) ---
class BossHealthBar extends PositionComponent with HasGameRef<TowerGame> {
  final BossEnemy boss;
  final double maxHp;
  late final TextPaint _textPainter;

  BossHealthBar(this.boss, this.maxHp) {
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

    // Viewport fixo geralmente precisa de coordenadas relativas ao componente
    // Se o componente está em 180,40, o canvas aqui desenha a partir de 0,0 local.

    final bgRect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(bgRect, Paint()..color = Colors.black87);

    double hpPercent = boss.hp / maxHp;
    if (hpPercent < 0) hpPercent = 0;
    
    final hpRect = Rect.fromLTWH(0, 0, size.x * hpPercent, size.y);
    canvas.drawRect(hpRect, Paint()..color = Pallete.vermelho);

    canvas.drawRect(bgRect, Paint()..color = Colors.white ..style = PaintingStyle.stroke ..strokeWidth = 2);

    _textPainter.render(
      canvas, 
      "BOSS", 
      Vector2(size.x / 2, -20),
      anchor: Anchor.topCenter,
    );
  }
}