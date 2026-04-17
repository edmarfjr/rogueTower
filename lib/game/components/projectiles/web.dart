import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
//import '../core/game_icon.dart';

class Web extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  double _timer = 0;
  bool _affectingPlayer = false; // Controle para saber se estamos lentificando o player

  Web({required Vector2 position, this.duration = 8.0})
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual da Teia
    add(GameSprite(
      imagePath: 'sprites/projeteis/web.png',
      size: size,
      color: Pallete.branco, 
      anchor: Anchor.center,
      position: size / 2
    ));

    add(CircleHitbox(
      radius: size.x / 2.5,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: false, 
    ));
    
    priority = -500;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= size.x/2) {
       _applySlow();
       
    } else {
       _removeSlow();
    }

    // Efeito de piscar antes de sumir
    if (_timer > duration - 2.0) {
       final opacity = (_timer * 10).toInt() % 2 == 0 ? 0.3 : 0.7;
       children.whereType<GameSprite>().firstOrNull?.changeColor(Colors.white.withValues(alpha: opacity));
    }

    if (_timer >= duration) {
      removeFromParent();
    }
  }
  /*

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollision(intersectionPoints, other);
    if (other is Player && !other.voo && !_affectingPlayer ) {
      _applySlow();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (!isMounted) return;
    super.onCollisionEnd(other);
    if (other is Player && _affectingPlayer) {
      _removeSlow();
    }
  }
  */

  @override
  void onRemove() {
    if (_affectingPlayer) {
      _removeSlow();
    }
    super.onRemove();
  }

  void _applySlow() {
    if(_affectingPlayer) return; 
    _affectingPlayer = true;
    gameRef.player.moveSpeed *= 0.4;
    gameRef.player.visual.changeColor(Pallete.cinzaCla);
  }

  void _removeSlow() {
    if(_affectingPlayer){
      _affectingPlayer = false;
      gameRef.player.moveSpeed /= 0.4; 
      gameRef.player.visual.changeColor(gameRef.player.classColor);
    }
  }
}