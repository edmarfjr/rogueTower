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
  
  // Lógica de Segunda Fase
  final bool hasSecondForm;
  bool isSecondForm = false;
  bool _isTransforming = false;
  double _transformTimer = 0;

  // Comportamentos da Fase 2
  MovementBehavior? phase2Movement;
  AttackBehavior? phase2Attack;
  AttackBehavior? phase2Attack2;
  

  late BossHealthBar healthBar;

  EnemyBoss({
    required this.bossName,
    required double hp,
    required super.position,
    required super.movementBehavior,
    required super.attackBehavior,
    super.deathBehavior,
    super.attack2Behavior,
    super.speed = 100,
    super.soul = 50,
    super.weight = 10.0, // Bosses são pesados, não são empurrados!
    super.rotates = false,
    super.hasGhostEffect = false,
    super.iconData,
    super.originalColor,
    super.size,
    super.hbSize,
    super.hbOffset,
    this.hasSecondForm = false,
    this.phase2Movement,
    this.phase2Attack,
    this.phase2Attack2,
  })  : maxHp = hp,
        super(hp: hp, isBoss: true);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Cria a barra de vida e adiciona no Viewport da Câmera (Fica fixo na tela UI)
    healthBar = BossHealthBar(this);
    gameRef.camera.viewport.add(healthBar);
  }

  @override
  void update(double dt) {
    // --- LÓGICA DE TRANSIÇÃO DE FASE ---
    if (_isTransforming) {
      _transformTimer -= dt;
      
      // Efeito visual de transformação (tremendo/girando)
      visual?.angle += 20 * dt; 
      visual?.scale.x = 1.0 + (1.5 - _transformTimer).abs() * 0.2;
      visual?.scale.y = 1.0 + (1.5 - _transformTimer).abs() * 0.2;

      if (_transformTimer <= 0) {
        _finishTransformation();
      }
      return; // Impede que ele ande ou ataque enquanto se transforma
    }

    super.update(dt);
  }

  // --- O SEGREDO: SOBRESCREVER A MORTE ---
  @override
  void die() {
    if (hasSecondForm && !isSecondForm) {
      _startTransformation();
    } else {
      super.die(); // Morre de verdade na Fase 2 (ou se não tiver fase 2)
    }
  }

  void _startTransformation() {
    _isTransforming = true;
    isSecondForm = true;
    isInvencivel = true;
    canMove = false; // Trava o boss no lugar
    
    _transformTimer = 2.0; // 2 segundos de animação

    gameRef.shakeCamera(intensity: 8.0, duration: 1.5);
    
    // Explode a primeira forma
    createExplosionEffect(gameRef.world, position, Pallete.laranja, count: 20);
    // AudioManager.playSfx('boss_phase2.mp3'); // Opcional
  }

  void _finishTransformation() {
    _isTransforming = false;
    isInvencivel = false;
    canMove = true;
    
    // Reseta visual
    visual?.angle = 0;
    visual?.scale.setValues(1.0, 1.0);
    
    // Fica mais perigoso (Muda cor, enche HP)
    hp = maxHp; // Ou maxHp * 1.5 se quiser uma fase 2 com mais vida!
    //originalColor = Pallete.roxo; // Cor da segunda fase
    //visual?.setColor(originalColor);

    // Troca o cérebro (Behaviors) para os da Fase 2
    if (phase2Movement != null) {
      movementBehavior = phase2Movement!;
      movementBehavior.enemy = this; // Vincula ao boss atual
    }
    if (phase2Attack != null) {
      attackBehavior = phase2Attack!;
      attackBehavior.enemy = this;
    }
    if (phase2Attack2 != null) {
      attack2Behavior = phase2Attack2;
      attack2Behavior!.enemy = this;
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