import 'dart:math';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';

class PoisonPuddle extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  final double damage;
  final bool isPlayer;
  Color cor = Pallete.verdeCla;
  double _lifeTimer = 0;      
  double _damageTickTimer = 0; 
  bool _playerIsInside = false;
  bool isFire;
  bool isPoison;
  bool isFreeze;
  bool isAquarius;
  bool isBleed;
  double _animTmr = 0;
  final double _bounceSpeed = 15.0;     
  final double _bounceAmplitude = 0.15; 
  final Set<Enemy> _enemiesInside = {};
  final bool alastra;

  GameSprite? visual;

  PoisonPuddle({
    required Vector2 position, 
    this.duration = 3.0,
    this.damage = 1.0, 
    this.isPlayer = false,
    this.isFire = false,
    this.isPoison = true,
    this.isFreeze = false,
    this.isBleed = false,
    this.isAquarius = false,
    this.alastra = false,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if(isPlayer) cor = Pallete.verdeEsc;
    String icon = 'sprites/projeteis/poca.png';
    if(isFire) {
      icon = 'sprites/projeteis/fogo.png';
      cor = Pallete.laranja;
    }
    if(isFreeze) {
      cor = Pallete.azulCla;
    }
    if(isAquarius) {
      cor = Pallete.lilas;
    }

    visual = GameSprite(
      imagePath: icon, 
      color: cor,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(visual!);

    // Hitbox (Sensor)
    add(CircleHitbox(
      radius: size.x / 2,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: false,
    ));

    add(TimerComponent(
      period: 0.5, 
      repeat: true,
      onTick: () {
        Color particleColor = cor;
        final rng = Random();

        final double posX = rng.nextDouble() * size.x - size.x/2 ;
        final double accX = rng.nextDouble() * size.x - size.x/2 ;

        final particleSystem = ParticleSystemComponent(
          particle: Particle.generate(
            count: 5, 
            lifespan: 0.5, 
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(accX, -150), 
              speed: Vector2((rng.nextDouble() - 0.5) * 60, -20), 
              position: Vector2((size.x / 2) + posX, size.x / 8),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = particleColor.withOpacity(1.0 - particle.progress)
                    ..isAntiAlias = false;
                  canvas.drawCircle(Offset.zero, size.y/10, paint); 
                }
              ),
            ),
          ),
        );
        add(particleSystem);
      },
    ));
    
    priority = -500;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;
    _damageTickTimer += dt;

    // --- 1. LÓGICA DE DANO/STATUS CONTÍNUO ---
    // Roda a cada 0.5 segundos (meio segundo)
    if (_damageTickTimer >= 0.5) {
      
      // A. Poça INIMIGA machuca o Player
      if (!isPlayer && _playerIsInside) {
        gameRef.player.takeDamage(1);
      }
      
      // B. Poça do PLAYER machuca os Inimigos
      if (isPlayer && _enemiesInside.isNotEmpty) {
        // Segurança: Remove inimigos que já morreram da lista
        _enemiesInside.removeWhere((e) => !e.isMounted || e.hp <= 0);

        for (var enemy in _enemiesInside) {
          if (isFire) {
            enemy.setBurn();
          } 
          if (isPoison)  {
            enemy.setPoison(alastra: alastra);
          }
          if (isBleed)  {
            enemy.setBleed();
          }
          if(isAquarius){
            enemy.takeDamage(damage);
          }
        }
      }

      _damageTickTimer = 0; 
    }

    //if (_lifeTimer > duration - 1.0) {
      // double currentOpacity = (duration - _lifeTimer).clamp(0.0, 1.0);
       //if (visual != null) {
       //  visual?.color = cor.withValues(alpha: 0.6 * currentOpacity);
       //}
    //}

    if (_lifeTimer >= duration) {
      removeFromParent();
    }

    if(isFire)_animateMovement(dt);
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player && !isPlayer && !other.voo) {
      _playerIsInside = true;
    }
    
    if (other is Enemy && isPlayer) {
      _enemiesInside.add(other);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (!isMounted) return;
    super.onCollisionEnd(other);
    
    if (other == gameRef.player && !isPlayer)  {
      _playerIsInside = false;
      _damageTickTimer = 0; 
    }
    
    if (other is Enemy && isPlayer) {
      _enemiesInside.remove(other);
    }
  }

  void _animateMovement(double dt) {
    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

    _animTmr += dt * _bounceSpeed;

    double wave = sin(_animTmr);
    currentScaleY = 1.0 + (wave * _bounceAmplitude); 
    currentScaleX = 1.0 - (wave * _bounceAmplitude * 0.5); 
    currentAngle = cos(_animTmr) * 0.1; 
    
    visual!.scale.setValues(currentScaleX, currentScaleY);
    visual!.angle = currentAngle; 

  }
}