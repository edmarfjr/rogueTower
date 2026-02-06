import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../effects/floating_text.dart';

// Novos tipos adicionados
enum CollectibleType { 
  coin,
  potion,
  key,
  shield,
  shop,
  boss,
  nextlevel,
  chest, 
  damage,
  fireRate,
  moveSpeed,
  range,
  healthContainer,
  berserk,
}

class Collectible extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final CollectibleType type;

  int custo;
  int souls;

  Collectible({required Vector2 position, required this.type, this.custo = 0, this.souls = 0}) 
      : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual diferente para cada tipo
    IconData iconData;
    Color iconColor;

    switch (type) {
      case CollectibleType.coin:
        iconData = Icons.monetization_on; 
        iconColor = Pallete.amarelo; 
        break;
      case CollectibleType.potion:
        iconData = Icons.favorite; 
        iconColor = Pallete.vermelho; 
        break;
      case CollectibleType.key:
        iconData = Icons.vpn_key; 
        iconColor = Pallete.laranja; 
        break;
      case CollectibleType.chest:
        iconData = Icons.inventory_2; // Alterei para caixa para diferenciar da chave
        iconColor = Pallete.laranja;
        break;
      case CollectibleType.damage:
        iconData = Icons.gavel; 
        iconColor = Pallete.azulCla; 
        break;
      case CollectibleType.fireRate:
        iconData = Icons.double_arrow; 
        iconColor = Pallete.azulCla; 
        break;
      case CollectibleType.moveSpeed:
        iconData = Icons.roller_skating; 
        iconColor = Pallete.azulCla; 
        break;
      case CollectibleType.range:
        iconData = Icons.gps_fixed; 
        iconColor = Pallete.azulCla; 
        break;
      case CollectibleType.shield:
        iconData = Icons.gpp_bad; 
        iconColor = Pallete.lilas; 
        break;
      case CollectibleType.healthContainer:
        iconData = Icons.favorite_outline; 
        iconColor = Pallete.vermelho; 
        break;
      case CollectibleType.nextlevel:
        iconData = Icons.stairs; 
        iconColor = Pallete.lilas; 
        break;
      case CollectibleType.berserk:
        iconData = Icons.sentiment_very_satisfied; 
        iconColor = Pallete.vermelho; 
        break;
      default:
        iconData = Icons.help_outline; 
        iconColor = Pallete.azulCla; 
        break;
    }

    add(GameIcon(
      icon: iconData,
      color: iconColor,
      size: size * 1.5, 
    ));

    if (custo > 0){
      add(TextComponent(
        text: "\$ $custo",
        textRenderer: TextPaint(
          style: const TextStyle(
            fontSize: 14,
            color: Pallete.amarelo,
            fontWeight: FontWeight.bold,
          ),
        ),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, size.y + 5),
      ));
    }

    add(CircleHitbox());
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    if (other == gameRef.player) {

      // 1. VERIFICAÇÃO DE CUSTO
      if (custo > 0){
        if (gameRef.coinsNotifier.value < custo){
          // Feedback Visual de "Sem dinheiro" (Opcional)
           gameRef.world.add(FloatingText(
             text: "No Funds!",
             position: position + Vector2(0, -20),
             color: Pallete.vermelho,
             fontSize: 10,
           ));
          return;
        } else {
          gameRef.coinsNotifier.value -= custo;
        }
      }

      // 2. APLICA O EFEITO (USANDO O MÉTODO ESTÁTICO)
      // Recebemos um mapa com o texto e a cor para o feedback
      final feedback = Collectible.applyEffect(
        type: type, 
        game: gameRef
      );

      String feedbackText = feedback['text'] as String;
      Color feedbackColor = feedback['color'] as Color;

      // 3. MOSTRA FEEDBACK VISUAL
      if (feedbackText.isNotEmpty) {
        gameRef.world.add(FloatingText(
          text: feedbackText,
          position: position.clone(), 
          color: feedbackColor,
          fontSize: 12,
        ));
      }
      
      removeFromParent();
    }
  }

  // ===========================================================================
  // MÉTODO ESTÁTICO HELPER (REUTILIZÁVEL)
  // ===========================================================================
  // Retorna um Map com 'text' (String) e 'color' (Color) para feedback visual
  static Map<String, dynamic> applyEffect({
    required CollectibleType type,
    required TowerGame game,
  }) {
    String text = "";
    Color color = Pallete.branco;
    final player = game.player; // Atalho

    switch (type) {
      case CollectibleType.coin:
        game.coinsNotifier.value += 10;
        text = "+ 10\$ ";
        color = Pallete.amarelo;
        break;
        
      case CollectibleType.potion:
        if (player.healthNotifier.value < player.maxHealth) {
          player.healthNotifier.value++; // Ou player.heal() se tiver criado
          text = "Curado!";
          color = Pallete.vermelho; // Rosa/Vermelho
        } else {
          text = "Cheio!";
          color = Pallete.cinzaCla;
        }
        break;
        
      case CollectibleType.key:
        game.keysNotifier.value++;
        text = "Key!";
        color = Pallete.laranja; // Ciano/Laranja
        break;
        
      case CollectibleType.damage:
        player.increaseDamage();
        text = "+ Damage!";
        color = Pallete.azulCla; // Laranja
        break;
        
      case CollectibleType.fireRate:
        player.increaseFireRate();
        text = "+ Fire Rate!";
        color = Pallete.azulCla; // Amarelo
        break;
        
      case CollectibleType.moveSpeed:
         player.increaseMovementSpeed();
         text = "+ Speed!";
         color = Pallete.azulCla;
         break;
      
      case CollectibleType.range:
         player.increaseRange();
         text = "+ Range!";
         color = Pallete.azulCla;
         break;
      
      case CollectibleType.shield:
         player.increaseShield();
         text = "+ Shield!";
         color = Pallete.azulCla;
         break;

      case CollectibleType.healthContainer:
         player.increaseHp();
         text = "+ Max HP!";
         color = Pallete.vermelho;
         break;
      
      case CollectibleType.berserk:
         player.isBerserk = true;
         text = "Double Damage when low HP!";
         color = Pallete.vermelho;
         break;

      case CollectibleType.chest:
         // Exemplo: Baú dá muito ouro
         game.coinsNotifier.value += 50;
         text = "+ 50\$ (Chest)";
         color = Pallete.amarelo;
         break;

      default:
         text = "";
         break;
    }

    return {'text': text, 'color': color};
  }
}