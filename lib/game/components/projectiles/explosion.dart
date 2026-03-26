import 'dart:math';

import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/gameObj/door.dart';
import 'package:towerrogue/game/components/gameObj/slot_machine.dart';
import 'package:towerrogue/game/components/gameObj/wall.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/pallete.dart'; // Ajuste imports
import '../effects/explosion_effect.dart';
import '../enemies/enemy.dart';

class Explosion extends PositionComponent with HasGameRef<TowerGame> {
  final double radius;
  final double damage;
  final bool apagaTiros;
  final bool damagesPlayer; 
  final Color cor;
  final Color corBorda; 
  final PositionComponent? owner;
  final bool isFreeze;
  final bool isStun;
  final bool isCharm;
  final bool isGlitter;
  final bool isFear;

  double _timer = 0;
  final double _duration = 0.4;

  Explosion({
    required Vector2 position,
    this.radius = 60,
    this.damage = 1,
    this.damagesPlayer = true,
    this.apagaTiros = false,
    this.owner,
    this.isFreeze = false,
    this.isStun = false,
    this.isCharm = false,
    this.isGlitter = false,
    this.isFear = false,
    Color? cor,
    Color? corBorda,
  }) : cor = cor ?? Pallete.laranja.withValues(alpha: 0.6),
       corBorda = corBorda ?? Pallete.vermelho.withValues(alpha: 0.6),
       super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    priority = 500;
    AudioManager.playSfx('explosion.mp3');

    createExplosionEffect(gameRef.world, position, Pallete.laranja, count: 30, lifespan: _duration*2, velocity: 300);
    createExplosionEffect(gameRef.world, position, Pallete.vermelho, count: 30, lifespan: _duration*2, velocity: 300);

    // VERIFICA DANO INSTANTÂNEO AO NASCER
    if (damagesPlayer) {
      final player = gameRef.player;
      if (player.position.distanceTo(position) <= radius) {
        player.takeDamage(damage.toInt());
      }
    } else {
      // inimigos
      final enemies = gameRef.world.children.query<Enemy>();
      for(final e in enemies){
         if (e.position.distanceTo(position) <= radius && !e.isInvencivel && !e.isIntangivel && !e.isCharmed) {
            if(isFreeze){
              e.setFreeze();
            }if(isStun){
              e.setConfuse();
            }if(isCharm){
              e.setCharm();
            }
            if(isFear){
              e.setFear();
            }else{
              if(isGlitter){
                int rnd = Random().nextInt(6);
                Collectible? item;
                switch (rnd){
                  case 0:
                    item = Collectible(position: position, type: CollectibleType.coin);
                    break;
                  case 1:
                    item = Collectible(position: position, type: CollectibleType.potion);
                    break;
                  case 2:
                    item = Collectible(position: position, type: CollectibleType.shield);
                    break;
                  case 3:
                    item = Collectible(position: position, type: CollectibleType.key);
                    break;
                  case 4:
                    item = Collectible(position: position, type: CollectibleType.bomba);
                    break;
                  case 5:
                    e.setCharm();
                    break;
                }
                if(item != null){
                  gameRef.world.add(item);
                    double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
                    double altura = Random().nextDouble() * 100 + 150 * -1;
                    item.pop(Vector2(direcaoX, 0), altura:altura);
                }
              }
              e.takeDamage(damage,critico: false); 
            }
         }
      }
      // Apaga projéteis inimigos
      final projeteis = gameRef.world.children.query<Projectile>();
      for(final p in projeteis){
         if (p.position.distanceTo(position) <= radius && p.isEnemyProjectile && apagaTiros) {
            p.removeFromParent(); 
         }
      }
      // Desbloqueia portas
      final doors = gameRef.world.children.query<Door>();
      for(final d in doors){
         if (d.position.distanceTo(position) <= radius && d.bloqueada ) {
            d.desbloqueia(); 
         }
      }
      // Apaga projéteis inimigos
      final walls = gameRef.world.children.query<Wall>();
      for(final w in walls){
         if (w.position.distanceTo(position) <= radius) {
            w.die(); 
         }
      }
      //quebra maquinas
      final slotMac = gameRef.world.children.query<SlotMachine>();
      for(final s in slotMac){
         if (s.position.distanceTo(position) <= radius) {
            s.explode(); 
         }
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;
    if (_timer >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Progresso de 0.0 a 1.0
    double progress = _timer / _duration; 
    
    // Círculo expandindo
    double currentRadius = radius * (0.2 + (0.8 * progress));
    
    // Opacidade diminuindo (fading out)
    double opacity = 1.0 - progress;
    if (opacity < 0) opacity = 0;

    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.fill;
      
    final paintBorder = Paint()
      ..color = corBorda
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius / 4;

    canvas.drawCircle(Offset.zero, currentRadius, paint);
    canvas.drawCircle(Offset.zero, currentRadius, paintBorder);
  }
}