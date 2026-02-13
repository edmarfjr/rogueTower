import 'dart:math';
import 'package:TowerRogue/game/components/core/interact_button.dart';
import 'package:TowerRogue/game/components/projectiles/orbital_shield.dart';
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
import '../core/i18n.dart';

enum CollectibleType { 
  coin, potion, key, shield, shop, boss, nextlevel, chest, bank, rareChest, bomba, alquimista,
  damage, fireRate, moveSpeed, range, healthContainer, keys, dash, sanduiche, critChance, critDamage, bombas,
  berserk, audacious, steroids, cafe, freeze, magicShield, alcool, orbitalShield, foice, revive, antimateria,
}

class Collectible extends PositionComponent with HasGameRef<TowerGame> {
  final CollectibleType type;
  int custo;
  int souls;
  int custoKeys;
  int custoBombs;
  bool naoEsgota;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 60.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão
  InteractButton? _currentButton;

  Collectible({
    required Vector2 position, 
    required this.type, 
    this.custo = 0, 
    this.souls = 0, 
    this.custoKeys = 0, 
    this.custoBombs = 0, 
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
      text: name.toUpperCase(),
      textRenderer: TextPaint(style: const TextStyle(color: Pallete.amarelo, fontSize: 12, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
      anchor: Anchor.bottomCenter,
      position: Vector2(0, -15),
    );

    // 2. Descrição do Efeito
    final textDesc = TextComponent(
      text: desc.toLowerCase(),
      textRenderer: TextPaint(style: const TextStyle(color: Pallete.branco, fontSize: 10, backgroundColor: Colors.black54)),
      anchor: Anchor.bottomCenter,
      position: Vector2(0, 0),
    );

    // 3. Botão de Pegar
    final btn = InteractButton(
      onTrigger: _collectItem,
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
    if (custo > 0 ) {
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

    if (custoKeys > 0 ) {
      if (gameRef.keysNotifier.value < custoKeys) {
        gameRef.world.add(FloatingText(
          text: "Sem Chaves!",
          position: position + Vector2(0, -20),
          color: Pallete.vermelho,
          fontSize: 10,
        ));
        return;
      } else {
        gameRef.coinsNotifier.value -= custoKeys;
      }
    }

    if (custoBombs > 0 ) {
      if (gameRef.player.bombNotifier.value < custoBombs) {
        gameRef.world.add(FloatingText(
          text: "Sem Bombas!",
          position: position + Vector2(0, -20),
          color: Pallete.vermelho,
          fontSize: 10,
        ));
        return;
      } else {
        gameRef.coinsNotifier.value -= custoBombs;
      }
    }

    // 2. Aplica Efeito
    final feedback = Collectible.applyEffect(type: type, game: gameRef);
    String feedbackText = feedback['text'] as String;
    Color feedbackColor = feedback['color'] as Color;

    /* 3. Feedback Visual Final
    if (feedbackText.isNotEmpty) {
      gameRef.world.add(FloatingText(
        text: feedbackText,
        position: position.clone(), 
        color: feedbackColor,
        fontSize: 12,
      ));
    }
    */
    if (!naoEsgota) removeFromParent();
    
  }

  // Helper para pegar dados visuais e textos (Nome, Descrição, Ícone, Cor)
  Map<String, dynamic> _getAttributes(CollectibleType t) {
    switch (t) {
      case CollectibleType.coin:
        return {'name': 'gold'.tr(), 'desc': '+10 Ouro', 'icon': Icons.monetization_on, 'color': Pallete.amarelo};
      case CollectibleType.potion:
        return {'name': 'heart'.tr(), 'desc': 'heartDesc'.tr(), 'icon': Icons.favorite, 'color': Pallete.vermelho};
      case CollectibleType.sanduiche:
        return {'name': 'sanduiche'.tr(), 'desc': 'sanduiche'.tr(), 'icon': MdiIcons.hamburger, 'color': Pallete.marrom};
      case CollectibleType.key:
        return {'name': 'key'.tr(), 'desc': 'keyDesc'.tr(), 'icon': Icons.vpn_key, 'color': Pallete.laranja};
      case CollectibleType.keys:
        return {'name': 'keys'.tr(), 'desc': 'keysDesc'.tr(), 'icon': MdiIcons.keyChain, 'color': Pallete.laranja};
      case CollectibleType.bomba:
        return {'name': 'bomb'.tr(), 'desc': 'bombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.cinzaEsc};
      case CollectibleType.bombas:
        return {'name': 'bombs'.tr(), 'desc': 'bombsDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.cinzaEsc};
      case CollectibleType.chest:
        return {'name': 'Baú', 'desc': 'Contém tesouros', 'icon': Icons.inventory_2, 'color': Pallete.laranja};
      case CollectibleType.damage:
        return {'name': 'potDmg'.tr(), 'desc': 'potDmgDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.vermelho};
      case CollectibleType.critChance:
        return {'name': 'potChCrit'.tr(), 'desc': 'potChCritDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.cinzaCla};
      case CollectibleType.critDamage:
        return {'name': 'potDmgCrit'.tr(), 'desc': 'porDmgCritDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.lilas};
      case CollectibleType.fireRate:
        return {'name': 'potFireRate'.tr(), 'desc': 'potFireRateDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.laranja};
      case CollectibleType.moveSpeed:
        return {'name': 'boots'.tr(), 'desc': 'bootsDesc'.tr(), 'icon': MdiIcons.shoeSneaker, 'color': Pallete.azulCla};
      case CollectibleType.range:
        return {'name': 'aim'.tr(), 'desc': 'aimDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.rosa};
      case CollectibleType.shield:
        return {'name': 'shield'.tr(), 'desc': 'shieldDesc'.tr(), 'icon': MdiIcons.shield, 'color': Pallete.cinzaCla};
      case CollectibleType.dash:
        return {'name': 'dash'.tr(), 'desc': 'dashDesc'.tr(), 'icon': MdiIcons.runFast, 'color': Pallete.verdeCla};
      case CollectibleType.healthContainer:
        return {'name': 'hpContainer'.tr(), 'desc': 'hpContainerDesc'.tr(), 'icon': Icons.favorite_outline, 'color': Pallete.vermelho};
      case CollectibleType.berserk:
        return {'name': 'berserk'.tr(), 'desc': 'berserkDesc'.tr(), 'icon': MdiIcons.emoticonAngry, 'color': Pallete.vermelho};
      case CollectibleType.audacious:
        return {'name': 'audaz'.tr(), 'desc': 'audazDescr'.tr(), 'icon': MdiIcons.shieldOff, 'color': Pallete.vermelho};
      case CollectibleType.steroids:
        return {'name': 'steroids'.tr(), 'desc': 'steroidsDesc'.tr(), 'icon': MdiIcons.pill, 'color': Pallete.verdeEsc};
      case CollectibleType.cafe:
        return {'name': 'cafe'.tr(), 'desc': 'cafeDesc'.tr(), 'icon': Icons.coffee, 'color': Pallete.marrom};
      case CollectibleType.alcool:
        return {'name': 'alcool'.tr(), 'desc': 'alcoolDesc'.tr(), 'icon': MdiIcons.bottleWine, 'color': Pallete.lilas};
      case CollectibleType.freeze:
        return {'name': 'freeze'.tr(), 'desc': 'freezeDesc'.tr(), 'icon': Icons.ac_unit, 'color': Pallete.azulCla};
      case CollectibleType.magicShield:
        return {'name': 'magicShield'.tr(), 'desc': 'magicShieldDesc'.tr(), 'icon': MdiIcons.shieldSun, 'color': Pallete.amarelo};
      case CollectibleType.orbitalShield:
        return {'name': 'orbShield'.tr(), 'desc': 'orbShieldDesc'.tr(), 'icon': MdiIcons.shieldRefresh, 'color': Pallete.lilas};
      case CollectibleType.foice:
        return {'name': 'foice'.tr(), 'desc': 'foiceDesc'.tr(), 'icon': MdiIcons.sickle, 'color': Pallete.lilas};
      case CollectibleType.revive:
        return {'name': 'revive'.tr(), 'desc': 'reviveDesc'.tr(), 'icon': MdiIcons.cross, 'color': Pallete.amarelo};
      case CollectibleType.antimateria:
        return {'name': 'antimat'.tr(), 'desc': 'antimatDesc'.tr(), 'icon': MdiIcons.radioboxMarked, 'color': Pallete.azulEsc};
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
      return CollectibleLogic.applyEffect(type: type, game: game);
  }

}

List<CollectibleType> retornaItens(player){
     List<CollectibleType> itens = [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.healthContainer,
      CollectibleType.keys,
      CollectibleType.dash,
      CollectibleType.sanduiche,
      CollectibleType.critChance,
      CollectibleType.critDamage,
      CollectibleType.steroids,
      CollectibleType.cafe,  
      CollectibleType.alcool,
      CollectibleType.bombas,
    ];
    if (!player.isBerserk) itens.add(CollectibleType.berserk);
    if (!player.isAudaz) itens.add(CollectibleType.audacious);
    if (!player.isFreeze) itens.add(CollectibleType.freeze);
    if (!player.magicShield) itens.add(CollectibleType.magicShield);
    if (!player.hasOrbShield) itens.add(CollectibleType.orbitalShield);
    if (!player.hasFoice) itens.add(CollectibleType.foice);
    if (!player.pegouRevive) itens.add(CollectibleType.revive);
    if (!player.hasAntimateria) itens.add(CollectibleType.antimateria);

    return itens;
  }


List<CollectibleType> retornaItensComuns(){
    return [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.healthContainer,
      CollectibleType.keys,
      CollectibleType.dash,
      CollectibleType.sanduiche,
      CollectibleType.critChance,
      CollectibleType.critDamage,
      CollectibleType.bombas,
    ];
  }

List<CollectibleType> retornaPocoes(){
    return [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.critChance,
      CollectibleType.critDamage,
    ];
  }

  List<CollectibleType> retornaItensRaros(player){
    List<CollectibleType> itRaros =[
      CollectibleType.steroids,
      CollectibleType.cafe,  
      CollectibleType.alcool,
    ];
    if (!player.isBerserk) itRaros.add(CollectibleType.berserk);
    if (!player.isAudaz) itRaros.add(CollectibleType.audacious);
    if (!player.isFreeze) itRaros.add(CollectibleType.freeze);
    if (!player.magicShield) itRaros.add(CollectibleType.magicShield);
    if (!player.hasOrbShield) itRaros.add(CollectibleType.orbitalShield);
    if (!player.hasFoice) itRaros.add(CollectibleType.foice);
    if (!player.pegouRevive) itRaros.add(CollectibleType.revive);
    if (!player.hasAntimateria) itRaros.add(CollectibleType.antimateria);
    return itRaros ;
  }

class CollectibleLogic {
   static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {
      // Lógica placeholder: VOCÊ DEVE MANTER A SUA LÓGICA ORIGINAL AQUI
      // Copiei apenas um exemplo para funcionar
       String text = "";
       //Color color = Pallete.branco;
       final player = game.player;

       switch (type) {
         case CollectibleType.coin:
          int c = Random().nextInt(20)+5;
          game.coinsNotifier.value += c;
          text = "+ $c\$ ";
          //color = Pallete.amarelo;
          break;
          
        case CollectibleType.potion:
          if (player.healthNotifier.value < player.maxHealth) {
            player.curaHp(2); // Ou player.heal() se tiver criado
            text = "Curado!";
            //color = Pallete.vermelho; // Rosa/Vermelho
          } else {
            text = "Cheio!";
            //color = Pallete.cinzaCla;
          }
          break;

        case CollectibleType.sanduiche:
          if (player.healthNotifier.value < player.maxHealth) {
            player.curaHp(6); // Ou player.heal() se tiver criado
            text = "Curado!";
            //color = Pallete.vermelho; // Rosa/Vermelho
          } else {
            text = "Cheio!";
           // color = Pallete.cinzaCla;
          }
          break;  
          
        case CollectibleType.key:
          int k = Random().nextInt(2)+1;
          game.keysNotifier.value += k;
          text = "$k Key(s)!";
          //color = Pallete.branco; // Ciano/Laranja
          break;

        case CollectibleType.keys:
          game.keysNotifier.value+=10;
          text = "10 Keys!";
          //color = Pallete.branco; // Ciano/Laranja
          break;
        
        case CollectibleType.bomba:
          int b = Random().nextInt(2)+1;
          game.player.bombNotifier.value += b;
          text = "$b Bombs(s)!";
          //color = Pallete.branco; // Ciano/Laranja
          break;

        case CollectibleType.bombas:
          game.player.bombNotifier.value+=10;
          text = "10 Bombs!";
          //color = Pallete.branco; // Ciano/Laranja
          break;

        case CollectibleType.damage:
          player.increaseDamage();
          text = "+ Damage!";
          //color = Pallete.branco; // Laranja
          break;
          
        case CollectibleType.fireRate:
          player.increaseFireRate();
          text = "+ Fire Rate!";
          //color = Pallete.azulCla; // Amarelo
          break;
          
        case CollectibleType.moveSpeed:
          player.increaseMovementSpeed();
          text = "+ Speed!";
         // color = Pallete.azulCla;
          break;
        
        case CollectibleType.range:
          player.increaseRange();
          text = "+ Range!";
          //color = Pallete.azulCla;
          break;
        
        case CollectibleType.shield:
          player.increaseShield();
          text = "+ Shield!";
          //color = Pallete.azulCla;
          break;

        case CollectibleType.healthContainer:
          player.increaseHp();
          text = "+ Max HP!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.dash:
          player.increaseDash();
          text = "+ Dash!";
          //color = Pallete.vermelho;
          break; 
        
        case CollectibleType.berserk:
          player.isBerserk = true;
          text = "+ 40% Damage when low HP!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.audacious:
          player.isAudaz = true;
          text = "+ 33% Damage when no shield!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.alcool:
          player.isBebado = true;
          text = "+ 33% Damage, shots don't go straight!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.steroids:
          player.damage *= 1.4;
          player.maxHealth -=2;
          player.healthNotifier.value -=2;
          text = "+ 40% Damage, but 1 less Health!";
          //color = Pallete.vermelho;
          break;
        
        case CollectibleType.cafe:
          player.damage *= 0.3;
          player.fireRate /= 3;
          text = "+ 200% Fire rate, but 70% less damage!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.freeze:
          player.isFreeze = true;
          text = "Can freeze enemy on strike";
         // color = Pallete.vermelho;
          break;

        case CollectibleType.magicShield:
          player.magicShield = true;
          text = "Magic Shield";
        //  color = Pallete.vermelho;
          break;

        case CollectibleType.critChance:
          player.critChance += 5;
          text = "+ 5% Crit. Chance";
        //  color = Pallete.amarelo;
          break;

        case CollectibleType.critDamage:
          player.critDamage *= 1.15;
          text = "+ 15% Crit. Damage";
         // color = Pallete.amarelo;
          break;

        case CollectibleType.orbitalShield:
          game.world.add(OrbitalShield(angleOffset: 0, owner: player));
          game.world.add(OrbitalShield(angleOffset: pi, owner: player));
          text = "Escudos Orbitais!";
         // color = Pallete.azulCla;
          break;

        case CollectibleType.foice:
          game.world.add(OrbitalShield(angleOffset: 0, owner: player, isFoice: true, radius: 20, speed:5));
          game.world.add(OrbitalShield(angleOffset: 2*pi/3, owner: player, isFoice: true, radius: 20, speed:5));
          game.world.add(OrbitalShield(angleOffset: 4*pi/3, owner: player, isFoice: true, radius: 20, speed:5));
          text = "Foices Orbitais!";
         // color = Pallete.azulCla;
          break;  

        case CollectibleType.revive:
          player.revive = true;
          text = "Ressurreição";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.antimateria:
          player.hasAntimateria = true;
          text = "antimateria";
          //color = Pallete.vermelho;
          break;  

        default:
          text = "";
          break;
       }
       return {'text': text, 'color': Pallete.branco};
   }
}