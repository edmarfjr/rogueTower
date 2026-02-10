import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import 'player.dart';
import 'collectible.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';

class Door extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool isOpen = false;
  final CollectibleType rewardType;

  // CORREÇÃO 1: Mudamos de 'late GameIcon' para 'GameIcon?' (pode ser nulo)
  GameIcon? _doorIcon;

  Door({required Vector2 position, required this.rewardType}) 
      : super(position: position, size: Vector2(60, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _updateDoorIcon(Icons.door_front_door, Pallete.cinzaEsc);

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

  }

  void _updateDoorIcon(IconData icon, Color color) {
    // CORREÇÃO 2: Verificamos se não é nulo antes de remover
    if (_doorIcon != null) {
      _doorIcon!.removeFromParent();
    }

    // Cria o novo ícone
    _doorIcon = GameIcon(
      icon: icon,
      color: color,
      size: size, 
      anchor: Anchor.center,
      position: size / 2,
    );
    
    // Adiciona ao jogo com a garantia (!) de que não é nulo agora
    add(_doorIcon!);
  }

  void _addRewardIcon() {
    IconData iconData;
    
    switch (rewardType) {
      case CollectibleType.potion:
        iconData = Icons.favorite;
        break;
      case CollectibleType.coin:
        iconData = Icons.attach_money;
        break;
      case CollectibleType.key:
        iconData = Icons.vpn_key;
        break;
      case CollectibleType.chest:
        iconData = Icons.lock;
        break;
      case CollectibleType.shop:
        iconData = Icons.store_mall_directory;
        break;
      case CollectibleType.shield:
        iconData = Icons.gpp_bad;
        break;
      case CollectibleType.boss:
        iconData = MdiIcons.skull;
        break;
      case CollectibleType.healthContainer:
        iconData = Icons.favorite_outline;
        break;
      case CollectibleType.nextlevel:
        iconData = MdiIcons.stairsUp;
        break;
      default:
        iconData = Icons.help_outline;
    }
    
    add(GameIcon(
      icon: iconData,
      color: Pallete.branco,
      size: Vector2(20, 20),
      position: Vector2(size.x / 2, -20), 
      anchor: Anchor.center,
    ));
  }

  void open() {
    if (isOpen) return;
    isOpen = true;
    
    // Troca para porta aberta
    _updateDoorIcon(Icons.meeting_room, Pallete.lilas);
    
    _addRewardIcon();
    
    print("Porta destrancada!");
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if (other is Player) {
      if (isOpen) {
        gameRef.nextLevel(rewardType);
      }
    }
  }
}