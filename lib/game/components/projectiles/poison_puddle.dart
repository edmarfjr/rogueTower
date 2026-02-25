import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class PoisonPuddle extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  final double damage;
  final bool isPlayer;
  Color cor = Pallete.verdeCla;
  double _lifeTimer = 0;      // Conta quanto tempo a poça existe
  double _damageTickTimer = 0; // Conta o intervalo entre danos
  bool _playerIsInside = false;

  CircleComponent? circle;

  PoisonPuddle({
    required Vector2 position, 
    this.duration = 3.0,
    this.damage = 1.0, 
    this.isPlayer = false,
    Vector2? size,
  }) : super(position: position, size: size ?? Vector2.all(20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if(isPlayer) cor = Pallete.verdeEsc;
    circle = CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = cor.withValues(alpha: 0.6), // Transparente
      anchor: Anchor.center,
      position: size / 2,
    );
    add(circle!);

    // Hitbox (Sensor)
    add(CircleHitbox(
      radius: size.x / 2,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: false,
    ));
    
    // Fica no chão
    priority = -2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _lifeTimer += dt;

    // 1. Lógica de Dano Contínuo
    
      _damageTickTimer += dt;
      if (_damageTickTimer >= 0.5) {
        if (_playerIsInside) {
          gameRef.player.takeDamage(1);
          _damageTickTimer = 0; 
        } 
      }
    

    // 2. Lógica de Desaparecer (Fade Out)
    // Começa a sumir quando faltar 1 segundo
    if (_lifeTimer > duration - 1.0) {
       // Calcula opacidade: Vai de 1.0 até 0.0 no último segundo
       double currentOpacity = (duration - _lifeTimer).clamp(0.0, 1.0);
       
       // Aplica no CÍRCULO (mantendo o tom base 0.6)
      // final circle = children.whereType<CircleComponent>().firstOrNull;
       if (circle != null) {
         circle?.paint.color = cor.withValues(alpha: 0.6 * currentOpacity);
       }
    }

    if (_lifeTimer >= duration) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == gameRef.player && !isPlayer) {
      _playerIsInside = true;
      // Opcional: Dano imediato ao pisar
      // gameRef.player.takeDamage(damage); 
    }
    if(other is Enemy && isPlayer && _damageTickTimer >= 1){
        other.setPoison();
        _damageTickTimer = 0; 
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other == gameRef.player && !isPlayer)  {
      _playerIsInside = false;
      _damageTickTimer = 0; // Reseta timer para não tomar dano instantâneo se voltar logo
    }
  }
}