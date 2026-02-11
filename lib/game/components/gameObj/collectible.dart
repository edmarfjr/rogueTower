import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart'; // Necessário para o TapCallbacks
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../effects/floating_text.dart';

enum CollectibleType { 
  coin, potion, key, shield, shop, boss, nextlevel, chest,bank, 
  damage, fireRate, moveSpeed, range, healthContainer,keys,dash, 
  berserk, audacious, steroids, cafe, freeze,magicShield
}

class Collectible extends PositionComponent with HasGameRef<TowerGame> {
  final CollectibleType type;
  int custo;
  int souls;
  bool naoEsgota;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 60.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão

  Collectible({
    required Vector2 position, 
    required this.type, 
    this.custo = 0, 
    this.souls = 0, 
    this.naoEsgota=false
    }): super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Configura Visual (Ícone e Cor)
    final attrs = _getAttributes(type);
    IconData iconData = attrs['icon'] as IconData;
    Color iconColor = attrs['color'] as Color;

    add(GameIcon(
      icon: iconData,
      color: iconColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    ));

    // Texto de preço (se houver)
    if (custo > 0){
      add(TextComponent(
        text: "\$ $custo",
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 14, color: Pallete.amarelo, fontWeight: FontWeight.bold),
        ),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, size.y + 5),
      ));
    }

  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Calcula distância para o Player
    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _pickupRange) {
      if (!_isInfoVisible) _showInfo();
    } else {
      if (_isInfoVisible) _hideInfo();
    }
  }

  void _showInfo() {
    _isInfoVisible = true;
    
    final attrs = _getAttributes(type);
    String name = attrs['name'] as String;
    String desc = attrs['desc'] as String;

    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);

    // 1. Nome do Item
    final textName = TextComponent(
      text: name,
      textRenderer: TextPaint(style: const TextStyle(color: Pallete.amarelo, fontSize: 12, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
      anchor: Anchor.bottomCenter,
      position: Vector2(0, -15),
    );

    // 2. Descrição do Efeito
    final textDesc = TextComponent(
      text: desc,
      textRenderer: TextPaint(style: const TextStyle(color: Pallete.branco, fontSize: 10, backgroundColor: Colors.black54)),
      anchor: Anchor.bottomCenter,
      position: Vector2(0, 0),
    );

    // 3. Botão de Pegar
    final btn = PickupButton(
      onPressed: _collectItem,
      size: Vector2(80, 24),
    )..position = Vector2(0, -50); 

    _infoGroup.add(textName);
    _infoGroup.add(textDesc);
    _infoGroup.add(btn);

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
  }

  void _collectItem() {
    // Lógica original de coleta movida para cá
    
    // 1. Verificação de Custo
    if (custo > 0) {
      if (gameRef.coinsNotifier.value < custo) {
        gameRef.world.add(FloatingText(
          text: "Sem dinheiro!",
          position: position + Vector2(0, -20),
          color: Pallete.vermelho,
          fontSize: 10,
        ));
        return;
      } else {
        gameRef.coinsNotifier.value -= custo;
      }
    }

    // 2. Aplica Efeito
    final feedback = Collectible.applyEffect(type: type, game: gameRef);
    String feedbackText = feedback['text'] as String;
    Color feedbackColor = feedback['color'] as Color;

    // 3. Feedback Visual Final
    if (feedbackText.isNotEmpty) {
      gameRef.world.add(FloatingText(
        text: feedbackText,
        position: position.clone(), 
        color: feedbackColor,
        fontSize: 12,
      ));
    }
    if (!naoEsgota) removeFromParent();
    
  }

  // Helper para pegar dados visuais e textos (Nome, Descrição, Ícone, Cor)
  Map<String, dynamic> _getAttributes(CollectibleType t) {
    switch (t) {
      case CollectibleType.coin:
        return {'name': 'Moeda', 'desc': '+10 Ouro', 'icon': Icons.monetization_on, 'color': Pallete.amarelo};
      case CollectibleType.potion:
        return {'name': 'Coração', 'desc': 'Recupera Vida', 'icon': Icons.favorite, 'color': Pallete.vermelho};
      case CollectibleType.key:
        return {'name': 'Chave', 'desc': 'Abre portas', 'icon': Icons.vpn_key, 'color': Pallete.laranja};
      case CollectibleType.keys:
        return {'name': 'Chave', 'desc': 'Um molho de Chaves', 'icon': MdiIcons.keyChain, 'color': Pallete.laranja};
      case CollectibleType.chest:
        return {'name': 'Baú', 'desc': 'Contém tesouros', 'icon': Icons.inventory_2, 'color': Pallete.laranja};
      case CollectibleType.damage:
        return {'name': 'Força', 'desc': 'Aumenta Dano', 'icon': MdiIcons.sword, 'color': Pallete.vermelho};
      case CollectibleType.fireRate:
        return {'name': 'Gatilho Rápido', 'desc': 'Atira mais rápido', 'icon': Icons.double_arrow, 'color': Pallete.vermelho};
      case CollectibleType.moveSpeed:
        return {'name': 'Botas', 'desc': 'Corre mais rápido', 'icon': MdiIcons.shoeSneaker, 'color': Pallete.azulCla};
      case CollectibleType.range:
        return {'name': 'Mira', 'desc': 'Aumenta Alcance', 'icon': Icons.gps_fixed, 'color': Pallete.azulCla};
      case CollectibleType.shield:
        return {'name': 'Escudo', 'desc': 'Protege 1 hit', 'icon': MdiIcons.shield, 'color': Pallete.cinzaCla};
      case CollectibleType.dash:
        return {'name': 'Dash', 'desc': '+ Dash', 'icon': MdiIcons.runFast, 'color': Pallete.verdeCla};
      case CollectibleType.healthContainer:
        return {'name': 'Coração', 'desc': '+ Vida Máxima', 'icon': Icons.favorite_outline, 'color': Pallete.vermelho};
      case CollectibleType.berserk:
        return {'name': 'Berserk', 'desc': '+Dano com pouca vida', 'icon': MdiIcons.emoticonAngry, 'color': Pallete.vermelho};
      case CollectibleType.audacious:
        return {'name': 'Audácia', 'desc': '+Dano sem escudo', 'icon': MdiIcons.shieldOff, 'color': Pallete.vermelho};
      case CollectibleType.steroids:
        return {'name': 'Esteroides', 'desc': '+Dano, -Vida Max', 'icon': MdiIcons.pill, 'color': Pallete.verdeEsc};
      case CollectibleType.cafe:
        return {'name': 'Café', 'desc': 'Muuuito tiro, pouco dano', 'icon': Icons.coffee, 'color': Pallete.marrom};
      case CollectibleType.freeze:
        return {'name': 'Gelo', 'desc': 'Congela inimigos', 'icon': Icons.ac_unit, 'color': Pallete.azulCla};
      case CollectibleType.magicShield:
        return {'name': 'Escudo Magico', 'desc': 'Protege contra um ataque, regenera quando entra em uma nova sala', 'icon': MdiIcons.shieldCrown, 'color': Pallete.amarelo};
      case CollectibleType.nextlevel:
        return {'name': 'Saída', 'desc': 'Próximo Nível', 'icon': Icons.stairs, 'color': Pallete.lilas};
      case CollectibleType.shop:
        return {'name': 'Loja', 'desc': 'Comprar itens', 'icon': Icons.store, 'color': Pallete.amarelo};
      case CollectibleType.boss:
        return {'name': 'Chefe', 'desc': 'Cuidado!', 'icon': Icons.dangerous, 'color': Pallete.vermelho};
      default:
        return {'name': 'Item', 'desc': '???', 'icon': Icons.help_outline, 'color': Pallete.cinzaCla};
    }
  }

  // Mantive seu método estático applyEffect igual (não alterado no exemplo para economizar espaço)
  static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {
      // ... (Sua lógica existente do applyEffect permanece aqui intacta)
      // Apenas para compilar o exemplo, vou colocar um retorno simples, 
      // mas você deve manter o seu código original gigante aqui.
      // Cole o conteúdo original do seu método applyEffect aqui.
      return CollectibleOriginalLogic.applyEffect(type: type, game: game);
  }
}

// =============================================================================
// COMPONENTE DO BOTÃO
// =============================================================================
class PickupButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;

  PickupButton({required this.onPressed, required Vector2 size}) 
    : super(size: size, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    // Desenha o fundo do botão
    final paintBg = Paint()..color = Pallete.verdeCla;
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintBg);

    // Desenha borda
    final paintBorder = Paint()..color = Pallete.branco..style = PaintingStyle.stroke..strokeWidth = 2;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(8)), paintBorder);

    // Texto "PEGAR" ou Ícone de Mão
    const textStyle = TextStyle(color: Pallete.branco, fontSize: 12, fontWeight: FontWeight.bold);
    const textSpan = TextSpan(text: "PEGAR", style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    textPainter.paint(canvas, Offset((size.x - textPainter.width) / 2, (size.y - textPainter.height) / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
  }
}

// Classe auxiliar apenas para simular a lógica antiga que você já tem
class CollectibleOriginalLogic {
   static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {
      // Lógica placeholder: VOCÊ DEVE MANTER A SUA LÓGICA ORIGINAL AQUI
      // Copiei apenas um exemplo para funcionar
       String text = "";
       Color color = Pallete.branco;
       final player = game.player;

       switch (type) {
         case CollectibleType.coin:
          game.coinsNotifier.value += 10;
          text = "+ 10\$ ";
          color = Pallete.amarelo;
          break;
          
        case CollectibleType.potion:
          if (player.healthNotifier.value < player.maxHealth) {
            player.curaHp(2); // Ou player.heal() se tiver criado
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

        case CollectibleType.keys:
          game.keysNotifier.value+=10;
          text = "Keys!";
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

        case CollectibleType.dash:
          player.increaseDash();
          text = "+ Dash!";
          color = Pallete.vermelho;
          break; 
        
        case CollectibleType.berserk:
          player.isBerserk = true;
          text = "+ 40% Damage when low HP!";
          color = Pallete.vermelho;
          break;

        case CollectibleType.audacious:
          player.isAudaz = true;
          text = "+ 33% Damage when no shield!";
          color = Pallete.vermelho;
          break;

        case CollectibleType.steroids:
          player.damage *= 1.4;
          player.maxHealth -=1;
          player.healthNotifier.value -=1;
          text = "+ 40% Damage, but 1 less Health!";
          color = Pallete.vermelho;
          break;
        
        case CollectibleType.cafe:
          player.damage *= 0.3;
          player.fireRate /= 3;
          text = "+ 200% Fire rate, but 70% less damage!";
          color = Pallete.vermelho;
          break;

        case CollectibleType.freeze:
          player.isFreeze = true;
          text = "Can freeze enemy on strike";
          color = Pallete.vermelho;
          break;

        case CollectibleType.magicShield:
          player.magicShield = true;
          text = "Magic Shield";
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