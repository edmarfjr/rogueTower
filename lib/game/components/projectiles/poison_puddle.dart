import 'dart:math';
import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class PoisonPuddle extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  final double damage;
  final bool isPlayer;
  Color cor = Pallete.verdeCla;
  double _lifeTimer = 0;      
  double _damageTickTimer = 0; 
  bool _playerIsInside = false;
  bool isFire;

  // --- NOVA VARIÁVEL: Rastreia todos os inimigos pisando na poça ---
  final Set<Enemy> _enemiesInside = {};

  GameIcon? visual;

  PoisonPuddle({
    required Vector2 position, 
    this.duration = 3.0,
    this.damage = 1.0, 
    this.isPlayer = false,
    this.isFire = false,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2.all(20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if(isPlayer) cor = Pallete.verdeEsc;
    IconData icon = Icons.circle;
    if(isFire) {
      icon = MdiIcons.fire;
      cor = Pallete.laranja;
    }

    visual = GameIcon(
      icon: icon, 
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
        Color particleColor = isFire ? Pallete.vermelho : Pallete.verdeCla;
        final rng = Random();

        final particleSystem = ParticleSystemComponent(
          particle: Particle.generate(
            count: 3, 
            lifespan: 0.5, 
            generator: (i) => AcceleratedParticle(
              acceleration: Vector2(0, -150), 
              speed: Vector2((rng.nextDouble() - 0.5) * 60, -20), 
              position: Vector2(size.x / 2, size.y / 2),
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = particleColor.withOpacity(1.0 - particle.progress);
                  canvas.drawCircle(Offset.zero, 3.0, paint); 
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
          } else {
            enemy.setPoison();
          }
        }
      }

      // Zera o cronômetro para o próximo "Tick"
      _damageTickTimer = 0; 
    }

    // --- 2. LÓGICA DE FADE OUT ---
    if (_lifeTimer > duration - 1.0) {
       double currentOpacity = (duration - _lifeTimer).clamp(0.0, 1.0);
       if (visual != null) {
         visual?.color = cor.withValues(alpha: 0.6 * currentOpacity);
       }
    }

    if (_lifeTimer >= duration) {
      removeFromParent();
    }
  }

  // --- CONTROLE DE QUEM ENTRA E SAI DA POÇA ---

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other == gameRef.player && !isPlayer) {
      _playerIsInside = true;
    }
    
    // Anota o inimigo na lista quando ele pisa
    if (other is Enemy && isPlayer) {
      _enemiesInside.add(other);
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    if (other == gameRef.player && !isPlayer)  {
      _playerIsInside = false;
      _damageTickTimer = 0; 
    }
    
    // Tira o inimigo da lista quando ele sai
    if (other is Enemy && isPlayer) {
      _enemiesInside.remove(other);
    }
  }
}