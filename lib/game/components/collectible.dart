import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../tower_game.dart';
import './game_icon.dart';
import 'pallete.dart';
import 'floating_text.dart';

// Novos tipos adicionados
enum CollectibleType { 
  coin,
  potion,
  key,
  chest, 
  damage,
  fireRate,
  moveSpeed,
  range,
}

class Collectible extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final CollectibleType type;

  Collectible({required Vector2 position, required this.type}) 
      : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual diferente para cada tipo
    IconData iconData;
    Color iconColor;

    switch (type) {
      case CollectibleType.coin:
        iconData = Icons.monetization_on; // Cifrão ou Moeda
        iconColor = Pallete.amarelo; // Dourado
        break;
      case CollectibleType.potion:
        iconData = Icons.favorite; // Coração ou Icons.local_drink
        iconColor = Pallete.vermelho; // Rosa
        break;
      case CollectibleType.key:
        iconData = Icons.vpn_key; // Chave
        iconColor = Pallete.laranja; // Ciano
        break;
      case CollectibleType.chest:
        iconData = Icons.vpn_key; // Chave
        iconColor = Pallete.laranja; // Ciano
        break;
      case CollectibleType.damage:
        iconData = Icons.gavel; // Setas pra cima
        iconColor = Pallete.azulCla; // Verde
        break;
      case CollectibleType.fireRate:
        iconData = Icons.gavel; // Setas pra cima
        iconColor = Pallete.azulCla; // Verde
        break;
      case CollectibleType.moveSpeed:
        iconData = Icons.gavel; // Setas pra cima
        iconColor = Pallete.azulCla; // Verde
        break;
      case CollectibleType.range:
        iconData = Icons.gavel; // Setas pra cima
        iconColor = Pallete.azulCla; // Verde
        break;
    }

    add(GameIcon(
      icon: iconData,
      color: iconColor,
      size: size * 1.5, // Ícones um pouco maiores que o hitbox ficam bonitos
    ));

    add(CircleHitbox());
  }

 @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other == gameRef.player) {
      String feedbackText = "";
      Color feedbackColor = Colors.white;

      switch (type) {
        case CollectibleType.coin:
          gameRef.coinsNotifier.value += 10;
          feedbackText = "+ 10\$ ";
          feedbackColor = const Color(0xFFFFD700); // Dourado
          break;
          
        case CollectibleType.potion:
          if (gameRef.player.healthNotifier.value < gameRef.player.maxHealth) {
            gameRef.player.healthNotifier.value++;
            feedbackText = "Curado!";
            feedbackColor = const Color(0xFFFF0055); // Rosa
          } else {
            feedbackText = "Cheio!"; // Se já estiver com vida cheia
          }
          break;
          
        case CollectibleType.key:
          gameRef.keysNotifier.value++;
          feedbackText = "Chave!";
          feedbackColor = const Color(0xFF00FFFF); // Ciano
          break;
          
        case CollectibleType.damage:
          gameRef.player.increaseDamage();
          feedbackText = "+ Dano!";
          feedbackColor = const Color(0xFFFF4500); // Laranja
          break;
          
        case CollectibleType.fireRate:
          gameRef.player.increaseFireRate();
          feedbackText = "+ Rapido!";
          feedbackColor = const Color(0xFFFFFF00); // Amarelo
          break;
          
        // Outros upgrades...
        case CollectibleType.moveSpeed:
           gameRef.player.increaseMovementSpeed();
           feedbackText = "+ Velocidade!";
           break;
        
        case CollectibleType.range:
           gameRef.player.increaseRange();
           feedbackText = "+ Velocidade!";
           break;
           
        default:
          break;
      }

      // Só mostra o texto se tiver algo para dizer
      if (feedbackText.isNotEmpty) {
        gameRef.world.add(FloatingText(
          text: feedbackText,
          position: position.clone(), // Aparece onde o item estava
          color: feedbackColor,
          fontSize: 12,
        ));
      }
      
      removeFromParent();
    }
  }


}