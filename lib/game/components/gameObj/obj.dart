import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import '../../tower_game.dart';

class Obj extends PositionComponent with HasGameRef<TowerGame> {
  final String imagePath;
  late GameSprite visual;
  Color cor;

  Obj({
    required Vector2 position,
    required this.imagePath,
    Vector2? size,
    this.cor = Pallete.branco,
  }) : super(position: position, size: size ?? Vector2.all(64), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    visual = GameSprite(
      imagePath: imagePath,
      size: Vector2.all(64),
      color: cor,
      anchor: Anchor.center,
      position: size / 2
    );
    add(visual);

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

    priority = position.y.toInt();
  }

}
