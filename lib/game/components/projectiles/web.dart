import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import '../core/game_icon.dart';

class Web extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double duration;
  double _timer = 0;
  bool _affectingPlayer = false; // Controle para saber se estamos lentificando o player

  Web({required Vector2 position, this.duration = 8.0})
      : super(position: position, size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual da Teia
    add(GameIcon(
      icon: MdiIcons.spiderWeb, // Se não tiver MDI, use Icons.grid_4x4
      color: Colors.white.withValues(alpha: 0.7),
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    ));

    // Hitbox (um pouco menor que o desenho para não ser injusto)
    add(CircleHitbox(
      radius: size.x / 2.5,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: false, // Player pode andar "dentro", é um sensor
    ));
    
    // Fica no chão (abaixo dos inimigos e player)
    priority = -1;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Efeito de piscar antes de sumir
    if (_timer > duration - 2.0) {
       final opacity = (_timer * 10).toInt() % 2 == 0 ? 0.3 : 0.7;
       children.whereType<GameIcon>().firstOrNull?.setColor(Colors.white.withValues(alpha: opacity));
    }

    if (_timer >= duration) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other == gameRef.player && !_affectingPlayer) {
      _applySlow();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other == gameRef.player && _affectingPlayer) {
      _removeSlow();
    }
  }

  // Segurança: Se a teia sumir ENQUANTO o player está em cima, precisamos devolver a velocidade
  @override
  void onRemove() {
    if (_affectingPlayer) {
      _removeSlow();
    }
    super.onRemove();
  }

  void _applySlow() {
    _affectingPlayer = true;
    gameRef.player.moveSpeed *= 0.4; // Reduz para 40% da velocidade
    // Muda cor do player para indicar status (opcional)
    gameRef.player.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.cinzaCla);
  }

  void _removeSlow() {
    _affectingPlayer = false;
    // Restaura dividindo pelo mesmo fator (matemática inversa)
    // Ex: 100 * 0.4 = 40. -> 40 / 0.4 = 100.
    gameRef.player.moveSpeed /= 0.4; 
    
    // Restaura cor original (assumindo que seja Ciano/Azul do player)
    gameRef.player.children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
  }
}