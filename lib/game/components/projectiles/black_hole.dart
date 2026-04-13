//import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import '../enemies/enemy.dart';
import '../enemies/enemy_boss.dart';
import '../projectiles/projectile.dart'; 
import '../effects/explosion_effect.dart';

class BuracoNegro extends PositionComponent with HasGameRef<TowerGame> {
  double duration;
  double _timer = 0;
  double _damageTimer = 0;
  final double _damageTime = 0.2;
  double damage;

  final double pullRadius; // O alcance da gravidade
  final double basePullForce = 30.0; // A força do puxão

  BuracoNegro({
        required Vector2 position,
        Vector2? size,
        this.damage = 5,
        this.duration = 6,
        this.pullRadius = 200.0,
      })
      : super(position: position, size: size ?? Vector2.all(24), anchor: Anchor.center);

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Efeito visual de rotação do buraco negro
    angle += 5 * dt;

    if (_timer >= duration) {
      // Explosão final antes de sumir
      createExplosionEffect(gameRef.world, absoluteCenter, Pallete.lilas, count: 20);
      removeFromParent();
      return;
    }

    _damageTimer += dt;
    bool dealDamage = _damageTimer >= _damageTime; // Causa dano a cada meio segundo (Tick)

    // --- A MÁGICA DA GRAVIDADE ---
    // Varremos todos os componentes vivos na sala
    for (var child in gameRef.world.children) {
      
      // 1. ATRAI INIMIGOS
      if (child is Enemy) {
        double dist = absoluteCenter.distanceTo(child.absoluteCenter);

        if (dist < pullRadius) {
          Vector2 dir = (absoluteCenter - child.absoluteCenter).normalized();

          // Bosses são mais pesados, resistem 70% da atração
          double force = child is EnemyBoss ? basePullForce * 0.3 : basePullForce;

          // Efeito "Singularidade": Quanto mais perto, mais forte o puxão!
          double intensity = 1.0 + (1.0 - (dist / pullRadius));
          child.position.addScaled(dir, force * intensity * dt);

          // Horizonte de Eventos (Se encostar no centro, toma dano)
          if (dealDamage && dist < size.x * 0.8) {
            child.takeDamage(damage); // Quantidade de dano por tick
            createExplosionEffect(gameRef.world, child.absoluteCenter, Pallete.lilas, count: 3);
          }
        }
      }
      
      // 2. ATRAI PROJÉTEIS INIMIGOS
      else if (child is Projectile && child.isEnemyProjectile) {
        double dist = absoluteCenter.distanceTo(child.absoluteCenter);

        if (dist < pullRadius) {
          Vector2 dir = (absoluteCenter - child.absoluteCenter).normalized();

          // Puxa projéteis com o dobro da velocidade para curvar os tiros
          child.position.addScaled(dir, basePullForce * 2 * dt);

          // Se o projétil chegar no centro absoluto, é engolido e apagado!
          if (dist < 15) {
            child.removeFromParent();
          }
        }
      }
    }

    // Reseta o cronômetro de dano após aplicar
    if (dealDamage) _damageTimer = 0;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // 1. Aura Roxa
    final paintAura = Paint()
      ..color = Pallete.lilas.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // 2. Núcleo Negro Absoluto
    final paintCore = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    // 3. Disco de Acreção (Branco piscante para dar sensação de poder)
    double ringOpacity = (_timer * 10).toInt() % 2 == 0 ? 0.9 : 0.4;
    final paintRing = Paint()
      ..color = Colors.white.withOpacity(ringOpacity)
      ..style = PaintingStyle.stroke
      ..isAntiAlias = false
      ..strokeWidth = 1;

    final centerOffset = Offset(size.x / 2, size.y / 2);

    canvas.drawCircle(centerOffset, size.x / 1.5, paintAura);
    canvas.drawCircle(centerOffset, size.x / 2.5, paintCore);
    canvas.drawCircle(centerOffset, size.x / 2.5, paintRing);
  }
}