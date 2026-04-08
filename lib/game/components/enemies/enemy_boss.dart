import 'dart:math';

import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import '../effects/explosion_effect.dart';
import '../effects/unlock_notification.dart';
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

  bool _isEpicDying = false;
  

  EnemyBoss({
    required this.bossName,
    required super.hp,
    required super.position,
    required this.behaviorChangeInterval,
    required this.phase1Movements,
    required this.phase1Attacks,
    this.hasSecondForm = false,
    this.phase2Movements = const [],
    this.phase2Attacks = const [],
    super.dropList = const [],
    super.deathBehavior,
    super.speed = 100,
    super.soul = 50,
    super.weight = 10.0,
    super.rotates = false,
    super.hasGhostEffect = false,
    super.hasFlail = false,
    super.image,
    super.originalColor,
    super.size,
    super.hbSize,
    super.hbOffset,
    super.noChamp = true,
  })  : maxHp = hp,
        // Passa o primeiro comportamento da Fase 1 para o super inicializar o Enemy corretamente
        super(
          isBoss: true,
          movementBehavior: phase1Movements.isNotEmpty ? phase1Movements.first : IdleBehavior() as MovementBehavior,
          attackBehavior: phase1Attacks.isNotEmpty ? phase1Attacks.first : IdleBehavior() as AttackBehavior,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    dmg = 1;

    movementBehavior.enemy = this;
    attackBehavior.enemy = this;

    healthBar = BossHealthBar(this);
    gameRef.camera.viewport.add(healthBar);
  }

  @override
  void update(double dt) {
    if (_isEpicDying) return;

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
  void die() async {
    if (hasSecondForm && !isSecondForm) {
      _startTransformation();
    } else {
      String clasId = '';
      String clasNome = '';
      switch (gameRef.currentLevel) {
        case 3:
          clasId = 'arqueiro';
          clasNome = 'arqueiro'.tr();
          break;
        case 5:
          clasId = 'exterminador';
          clasNome = 'exterminador'.tr();
          if(!gameRef.usouBomba){
            clasId = 'bomberman';
            clasNome = 'bomberman'.tr();
          }
          break;
        default:
      }
      if(clasId != ''){
        bool isNewUnlock = await GameProgress.unlockClass(clasId); 
    
        if (isNewUnlock) {
          gameRef.world.add(
            UnlockNotification(
              message: "NOVA CLASSE: $clasNome!",
              position: position.clone(), // Nasce no cadáver do Boss
            )
          );
        }
      } 
      
      if (!_isEpicDying) {
        _startEpicDeathSequence();
      }
    }
  }

  void _startEpicDeathSequence() {
    _isEpicDying = true;
    isInvencivel = true;
    canMove = false;

    // Remove a barra de vida gigante do topo da tela na mesma hora
    if (healthBar.isMounted) {
      healthBar.removeFromParent();
    }

    int explosionCount = 0;
    
    // Um timer que roda a cada 0.3 segundos criando explosões aleatórias
    add(TimerComponent(
      period: 0.3,
      repeat: true,
      onTick: () {
        explosionCount++;
        
        if (explosionCount < 7) {
          final rng = Random();
          double offsetX = (rng.nextDouble() - 0.5) * size.x;
          double offsetY = (rng.nextDouble() - 0.5) * size.y;
          
          createExplosionEffect(gameRef.world, position + Vector2(offsetX, offsetY), Pallete.laranja, count: 12);
          AudioManager.playSfx('explosion.mp3');
          gameRef.shakeCamera(intensity: 3.0, duration: 0.2); // Tremor leve e contínuo

        
        /*  if (explosionCount % 2 == 0){

            bool isCoin = Random().nextBool();
            final item = Collectible(position: position, type: isCoin? CollectibleType.coin : CollectibleType.potion);
            gameRef.world.add(item);
            double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
            double altura = Random().nextDouble() * 100 + 150 * -1;
            item.pop(Vector2(direcaoX, 0), altura:altura);
          }
         */ 
        } else {
          // --- A EXPLOSÃO FINAL MASSIVA ---
          createExplosionEffect(gameRef.world, position, Pallete.vermelho, count: 60);
          AudioManager.playSfx('enemy_die.mp3');
          gameRef.shakeCamera(intensity: 12.0, duration: 1.5);

          bool isUm = Random().nextBool();
          final item = Collectible(position: position, type: isUm? CollectibleType.potionUm : CollectibleType.potion);
          gameRef.world.add(item);
          double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
          double altura = Random().nextDouble() * 100 + 150 * -1;
          item.pop(Vector2(direcaoX, 0), altura:altura);

          AudioManager.playBgm('8_bit_adventure.mp3');
          super.die(); 
        }
      },
    ));
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
    hp = (maxHp * gameRef.difficultyMultiplier).ceil().toDouble();

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
    anchor = Anchor.topCenter;
    
    const double larguraVirtual = 16*16; 
    
    size = Vector2(larguraVirtual * 0.7, 12);
    
    double xPerfeito = (larguraVirtual / 2);
    
    position = Vector2(xPerfeito, 20); 

    textPaint = Pallete.textoDanoCritico;
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
    double hpPercent = (boss.hp / (boss.maxHp * gameRef.difficultyMultiplier).ceil().toDouble()).clamp(0.0, 1.0);
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
        ..strokeWidth = 1,
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