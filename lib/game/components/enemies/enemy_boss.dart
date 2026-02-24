import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import '../effects/explosion_effect.dart';
import 'enemy.dart';
import 'enemy_behaviors.dart';

class EnemyBoss extends Enemy {
  final String bossName;
  final double maxHp;
  
  // --- LÓGICA DE ROTAÇÃO DE COMPORTAMENTOS ---
  final double behaviorChangeInterval; // De quantos em quantos segundos ele muda de ataque?
  double _behaviorTimer = 0;
  int _currentBehaviorIndex = 0;

  // Listas de comportamentos da FASE 1
  final List<MovementBehavior> phase1Movements;
  final List<AttackBehavior> phase1Attacks;

  // Listas de comportamentos da FASE 2
  final bool hasSecondForm;
  bool isSecondForm = false;
  final List<MovementBehavior> phase2Movements;
  final List<AttackBehavior> phase2Attacks;

  bool _isTransforming = false;
  double _transformTimer = 0;

  late BossHealthBar healthBar;

  EnemyBoss({
    required this.bossName,
    required double hp,
    required super.position,
    required this.behaviorChangeInterval,
    required this.phase1Movements,
    required this.phase1Attacks,
    this.hasSecondForm = false,
    this.phase2Movements = const [],
    this.phase2Attacks = const [],
    super.deathBehavior,
    super.speed = 100,
    super.soul = 50,
    super.weight = 10.0,
    super.rotates = false,
    super.hasGhostEffect = false,
    super.iconData,
    super.originalColor,
    super.size,
    super.hbSize,
    super.hbOffset,
  })  : maxHp = hp,
        // Passa o primeiro comportamento da Fase 1 para o super inicializar o Enemy corretamente
        super(
          hp: hp, 
          isBoss: true,
          movementBehavior: phase1Movements.isNotEmpty ? phase1Movements.first : IdleBehavior() as MovementBehavior,
          attackBehavior: phase1Attacks.isNotEmpty ? phase1Attacks.first : IdleBehavior() as AttackBehavior,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Garante que os comportamentos iniciais conheçam o chefe
    movementBehavior.enemy = this;
    attackBehavior.enemy = this;

    healthBar = BossHealthBar(this);
    gameRef.camera.viewport.add(healthBar);
  }

  @override
  void update(double dt) {
    if (_isTransforming) {
      _transformTimer -= dt;
      visual?.angle += 20 * dt; 
      visual?.scale.x = 1.0 + (1.5 - _transformTimer).abs() * 0.2;
      visual?.scale.y = 1.0 + (1.5 - _transformTimer).abs() * 0.2;

      if (_transformTimer <= 0) {
        _finishTransformation();
      }
      return; 
    }

    // --- O SEGREDO DA TROCA DE ATAQUES ---
    _behaviorTimer += dt;
    if (_behaviorTimer >= behaviorChangeInterval) {
      _behaviorTimer = 0;
      _switchToNextBehavior();
    }

    super.update(dt);
  }

  void _switchToNextBehavior() {
    // Escolhe qual lista usar dependendo da fase atual
    List<MovementBehavior> currentMovements = isSecondForm ? phase2Movements : phase1Movements;
    List<AttackBehavior> currentAttacks = isSecondForm ? phase2Attacks : phase1Attacks;

    if (currentAttacks.isEmpty || currentMovements.isEmpty) return;

    // Avança o índice e volta para o 0 se chegar no final da lista
    _currentBehaviorIndex = (_currentBehaviorIndex + 1) % currentAttacks.length;

    // Atualiza os comportamentos e avisa a eles quem é o "enemy" (este boss)
    movementBehavior = currentMovements[_currentBehaviorIndex % currentMovements.length];
    movementBehavior.enemy = this;

    attackBehavior = currentAttacks[_currentBehaviorIndex];
    attackBehavior.enemy = this;
  }

  @override
  void die() {
    if (hasSecondForm && !isSecondForm) {
      _startTransformation();
    } else {
      super.die(); 
    }
  }

  void _startTransformation() {
    _isTransforming = true;
    isSecondForm = true;
    isInvencivel = true;
    canMove = false; 
    
    _transformTimer = 2.0; 
    gameRef.shakeCamera(intensity: 8.0, duration: 1.5);
    createExplosionEffect(gameRef.world, position, Pallete.laranja, count: 20);
  }

  void _finishTransformation() {
    _isTransforming = false;
    isInvencivel = false;
    canMove = true;
    
    visual?.angle = 0;
    visual?.scale.setValues(1.0, 1.0);
    hp = maxHp; 

    // Reseta o timer e o índice para a Fase 2 começar limpa
    _behaviorTimer = 0;
    _currentBehaviorIndex = 0;
    
    // Força a troca imediata para o primeiro ataque da Fase 2
    if (phase2Movements.isNotEmpty) {
      movementBehavior = phase2Movements.first;
      movementBehavior.enemy = this;
    }
    if (phase2Attacks.isNotEmpty) {
      attackBehavior = phase2Attacks.first;
      attackBehavior.enemy = this;
    }
  }
}

// ============================================================================
// WIDGET DO FLAME PARA A BARRA DE VIDA (HUD)
// ============================================================================
class BossHealthBar extends PositionComponent with HasGameRef<TowerGame> {
  final EnemyBoss boss;
  late TextPaint textPaint;

  BossHealthBar(this.boss);

  @override
  Future<void> onLoad() async {
    // 1. Muda a âncora para o topo-centro, facilitando o alinhamento
    anchor = Anchor.topCenter;

    // 2. Reduz a largura da barra (subtrai 160 pixels para fugir do HUD esquerdo e do Pause)
    double barWidth = gameRef.camera.viewport.size.x/2;
    size = Vector2(barWidth, 20);

    // 3. Posiciona no meio da tela no eixo X. 
    // Como você tem o HUD na esquerda, adicionei "+ 20" para empurrar o centro visual mais pra direita
    position = Vector2((gameRef.camera.viewport.size.x / 3) + 16, 20); 

    textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white, 
        fontSize: 12, 
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!boss.isMounted) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Fundo Preto
    canvas.drawRect(size.toRect(), Paint()..color = Colors.black87);

    // Barra Cheia (Calcula Porcentagem)
    double hpPercent = (boss.hp / boss.maxHp).clamp(0.0, 1.0);
    Color barColor = Pallete.vermelho;
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x * hpPercent, size.y), 
      Paint()..color = barColor,
    );

    // Borda Branca
    canvas.drawRect(
      size.toRect(), 
      Paint()
        ..color = Pallete.branco
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Texto Centralizado
    String phaseText = boss.isSecondForm ? " (Fase 2)" : "";
    textPaint.render(
      canvas, 
      "${boss.bossName.toUpperCase()}$phaseText", 
      Vector2(size.x / 2, size.y / 2), 
      anchor: Anchor.center,
    );
  }
}