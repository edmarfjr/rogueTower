import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'enemy.dart';
import '../gameObj/projectile.dart';
import '../game_icon.dart';
import '../gameObj/collectible.dart';
import '../floating_text.dart';
import '../effects/explosion.dart'; 

class BossEnemy extends Enemy {
  double _attackTimer = 0;
  final double attackInterval = 2.5; 
  final double maxHp; 

  BossEnemy({required Vector2 position, int level = 1}) 
      : maxHp = 100.0 + (level * 20),
        super(position: position) {
    
    // Configura a vida inicial igual ao máximo calculado
    hp = maxHp;
    speed = 40; 
  }

  @override
  Future<void> onLoad() async {
    // 1. Carrega a lógica do pai (Hitbox, etc)
    await super.onLoad();

    // 2. AUMENTA O TAMANHO
    size = Vector2.all(64); 
    
    // 3. REMOÇÃO SEGURA DOS VISUAIS ANTIGOS
    // Correção: Usamos .toList() para evitar erro ao remover enquanto percorre a lista
    children.whereType<GameIcon>().toList().forEach((c) => c.removeFromParent());
    
    // ERRO ANTERIOR: removeAll(children); 
    // Removi essa linha pois ela apagava a Hitbox de colisão!

    // 4. VISUAL DO CHEFE
    add(GameIcon(
      icon: Icons.bug_report, 
      color: Colors.purpleAccent,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // BARRA DE VIDA
    final double barWidth = size.x;
    final double barHeight = 6;
    final double yOffset = -15;

    // Fundo Preto
    canvas.drawRect(
      Rect.fromLTWH(0, yOffset, barWidth, barHeight),
      Paint()..color = Colors.black,
    );

    // Vida Vermelha
    double percent = hp / maxHp;
    if (percent < 0) percent = 0;
    
    canvas.drawRect(
      Rect.fromLTWH(0, yOffset, barWidth * percent, barHeight),
      Paint()..color = const Color(0xFFFF0000),
    );
  }

  @override
  void update(double dt) {
    // Nota: Não chamamos super.update(dt) aqui para ter controle total,
    // mas chamamos os comportamentos manualmente.
    
    behaviorFollowPlayer(dt);
    _attackBehavior(dt);
    handleHitEffect(dt);
    
    // Chama o update dos filhos (ícones, timers, etc)
    super.update(dt); 
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
        visual.setColor(Colors.white); 
        
        Future.delayed(const Duration(milliseconds: 100), () {
            if (isMounted) { 
                 visual.setColor(Colors.purpleAccent); // Volta para a cor original
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
      isEnemyProjectile: true,
    ));
  }
  
  // Morte Especial
  void _die() {
    createExplosion(gameRef.world, position, Colors.purple, count: 50);
    
    // Dropa Loot do Boss
    gameRef.world.add(Collectible(position: position, type: CollectibleType.key));
    gameRef.world.add(Collectible(position: position + Vector2(20,0), type: CollectibleType.coin));
    gameRef.world.add(Collectible(position: position + Vector2(-20,0), type: CollectibleType.coin));

    gameRef.world.add(FloatingText(
        text: "BOSS DERROTADO!", 
        position: position, 
        color: Colors.yellow, 
        fontSize: 20
    ));

    removeFromParent();
  }
}