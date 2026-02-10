import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';

class PoisonPuddle extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  final double damage;
  
  double _lifeTimer = 0;      // Conta quanto tempo a poça existe
  double _damageTickTimer = 0; // Conta o intervalo entre danos
  bool _playerIsInside = false;

  PoisonPuddle({
    required Vector2 position, 
    this.duration = 5.0,
    this.damage = 1.0, // Dano por tick
  }) : super(position: position, size: Vector2.all(20), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual: Círculo Verde
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = Pallete.verdeCla.withValues(alpha: 0.6), // Transparente
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Ícone de Bolhas (Opcional, para estilo)
    add(GameIcon(
      icon: MdiIcons.water, // Ou Icons.bubble_chart
      color: Pallete.verdeEsc.withValues(alpha: 0.5),
      size: size * 0.6,
      anchor: Anchor.center,
      position: size / 2,
    ));

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
    if (_playerIsInside) {
      //_damageTickTimer += dt;
      //if (_damageTickTimer >= 0.5) {
        gameRef.player.takeDamage(1);
      //  _damageTickTimer = 0; 
      //}
    }

    // 2. Lógica de Desaparecer (Fade Out)
    // Começa a sumir quando faltar 1 segundo
    if (_lifeTimer > duration - 1.0) {
       // Calcula opacidade: Vai de 1.0 até 0.0 no último segundo
       double currentOpacity = (duration - _lifeTimer).clamp(0.0, 1.0);
       
       // Aplica no CÍRCULO (mantendo o tom base 0.6)
       final circle = children.whereType<CircleComponent>().firstOrNull;
       if (circle != null) {
         circle.paint.color = Colors.greenAccent.withValues(alpha: 0.6 * currentOpacity);
       }

       // Aplica no ÍCONE (usando o método setColor do GameIcon)
       final icon = children.whereType<GameIcon>().firstOrNull;
       if (icon != null) {
         // Cor original era Colors.green[900] com alpha 0.5
         icon.setColor(Colors.green[900]!.withValues(alpha: 0.5 * currentOpacity));
       }
    }

    if (_lifeTimer >= duration) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == gameRef.player) {
      _playerIsInside = true;
      // Opcional: Dano imediato ao pisar
      // gameRef.player.takeDamage(damage); 
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other == gameRef.player) {
      _playerIsInside = false;
      _damageTickTimer = 0; // Reseta timer para não tomar dano instantâneo se voltar logo
    }
  }
}