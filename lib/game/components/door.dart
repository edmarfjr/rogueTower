import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import './player.dart';
import 'collectible.dart';
import 'game_icon.dart';
import 'pallete.dart';

class Door extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool isOpen = false;
  final CollectibleType rewardType;

  // CORREÇÃO 1: Mudamos de 'late GameIcon' para 'GameIcon?' (pode ser nulo)
  GameIcon? _doorIcon;

  Door({required Vector2 position, required this.rewardType}) 
      : super(position: position, size: Vector2(60, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. ÍCONE DA PORTA (Estado Inicial: FECHADA)
    _updateDoorIcon(Icons.door_front_door, Pallete.cinzaEsc);

    // 2. HITBOX (Física)
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

    // 3. ÍCONE DA RECOMPENSA
    _addRewardIcon();
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
    Color iconColor;
    
    switch (rewardType) {
      case CollectibleType.potion:
        iconData = Icons.favorite;
        iconColor = Pallete.vermelho;
        break;
      case CollectibleType.coin:
        iconData = Icons.attach_money;
        iconColor = Pallete.amarelo;
        break;
      case CollectibleType.key:
        iconData = Icons.vpn_key;
        iconColor = Pallete.laranja;
        break;
      case CollectibleType.chest:
        iconData = Icons.lock;
        iconColor = Pallete.azulCla;
        break;
      default:
        iconData = Icons.help_outline;
        iconColor = Colors.white;
    }
    
    add(GameIcon(
      icon: iconData,
      color: iconColor,
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