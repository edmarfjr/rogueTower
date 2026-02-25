import 'dart:math';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/core/interact_button.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
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
  //tipos de porta 
  coin, potion, key, shield, shop, boss, nextlevel, chest, bank, rareChest, bomba, alquimista, desafio, darkShop, 
  //itens comuns
  damage, fireRate, moveSpeed, range, healthContainer, keys, dash, sanduiche, critChance, critDamage, bombas, piercing, dot,
  fogo,veneno, sangramento, druidScroll, dotBook, chaveNegra, gravitacao, mine, bloodstone, bounce, spectral, cupon, bumerangue,
  pocaVeneno,
  //itens raros
  berserk, audacious, steroids, cafe, freeze, magicShield, alcool, orbitalShield, foice, revive, antimateria, homing,
  concentration, soda, defBurst, kinetic, heavyShot, conqCrown, flail 
}

class Collectible extends PositionComponent with HasGameRef<TowerGame> {
  final CollectibleType type;
  int custo;
  int souls;
  int custoKeys;
  int custoBombs;
  bool custoVida;
  bool naoEsgota;

  Vector2 _velocity = Vector2.zero();
  final double _gravity = 900.0; 
  bool isBouncing = false;
  double _groundY = 0.0;

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
    this.custoVida = false,
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

    if (custoKeys > 0){
      add(GameIcon(
        icon: MdiIcons.key,
        color: Pallete.laranja,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 -15, size.y + 13),
      ));
      add(TextComponent(
        text: ": $custoKeys",
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 14, color: Pallete.laranja, fontWeight: FontWeight.bold),
        ),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, size.y + 5),
      ));
    }

    if (custoBombs > 0){
      add(GameIcon(
        icon: MdiIcons.bomb,
        color: Pallete.cinzaEsc,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 -15, size.y + 13),
      ));
      add(TextComponent(
        text: ": $custoBombs",
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 14, color: Pallete.cinzaEsc, fontWeight: FontWeight.bold),
        ),
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2, size.y + 5),
      ));
    }
    if(custoVida){
      add(GameIcon(
        icon: MdiIcons.heart,
        color: Pallete.vermelho,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 + size.x/2 + 2, size.y + 13),
      ));
      add(GameIcon(
        icon: MdiIcons.heart,
        color: Pallete.vermelho,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y + 13),
      ));
      add(GameIcon(
        icon: MdiIcons.heart,
        color: Pallete.vermelho,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 - size.x/2 - 2, size.y + 13),
      ));
    }
    add(ShadowComponent(parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Calcula distância para o Player
    if (isBouncing) {
      // 1. A gravidade empurra a velocidade para baixo
      _velocity.y += _gravity * dt;
      
      // 2. Aplica a velocidade na posição do item
      position.x += _velocity.x * dt;
      position.y += _velocity.y * dt;

      // 3. Verifica se bateu no chão (e se está caindo, velocidade Y positiva)
      if (position.y >= _groundY && _velocity.y > 0) {
        position.y = _groundY; // Trava no chão
        isBouncing = false;    // Desliga a física
      }
    }
    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _pickupRange) {
      if (!_isInfoVisible) _showInfo();
    } else {
      if (_isInfoVisible) _hideInfo();
    }
  }

  void pop(Vector2 offsetDestino, {double altura = -200.0}) {
    _groundY = position.y + offsetDestino.y;
    
    // Joga a moeda para cima (y negativo) e para o lado (x)
    _velocity = Vector2(offsetDestino.x * 2.5, altura); 
    isBouncing = true;
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
    if (_currentButton != null) return;
    final screenSize = gameRef.camera.viewport.size;
    final hudPosition = Vector2(screenSize.x - 150, screenSize.y - 170);

    _currentButton= InteractButton(
      position: hudPosition,
      onTrigger: (){_collectItem(); _hideInfo();},
    );
    gameRef.camera.viewport.add(_currentButton!);
    _infoGroup.add(textName);
    _infoGroup.add(textDesc);
    

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
    if (_currentButton != null) {
      // Remove diretamente da lista de filhos do Viewport, que é 100% seguro!
      gameRef.camera.viewport.remove(_currentButton!); 
      _currentButton = null;
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
        gameRef.keysNotifier.value -= custoKeys;
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
        gameRef.player.bombNotifier.value -= custoBombs;
      }
    }

    if (custoVida){
      if (gameRef.player.maxHealth < 6) {
        gameRef.world.add(FloatingText(
          text: "Sem Containers de vida o suficiente!",
          position: position + Vector2(0, -20),
          color: Pallete.vermelho,
          fontSize: 10,
        ));
        return;
      } else {
        gameRef.player.maxHealth -= 6;
        gameRef.player.healthNotifier.value = min(gameRef.player.healthNotifier.value,gameRef.player.maxHealth);
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
    // --- NOVA LÓGICA DE INVENTÁRIO ---
    // 3. Define quais itens são consumíveis ou mapa (NÃO vão pro inventário)
    final List<CollectibleType> consumiveis = [
      CollectibleType.coin, CollectibleType.potion, CollectibleType.sanduiche,
      CollectibleType.key, CollectibleType.keys, CollectibleType.bomba, 
      CollectibleType.bombas, CollectibleType.chest, CollectibleType.rareChest, 
      CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextlevel, 
      CollectibleType.shop, CollectibleType.boss, CollectibleType.shield,
      CollectibleType.healthContainer
    ];

    // Se o item NÃO FOR consumível, adiciona na lista de adquiridos do Player
    if (!consumiveis.contains(type)) {
      final attrs = _getAttributes(type);
      
      gameRef.player.setAcquiredItemsList(
        attrs['name'] as String,
        attrs['desc'] as String,
        attrs['icon'] as IconData,
        attrs['color'] as Color,
      );
    }
    
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
      case CollectibleType.chaveNegra:
        return {'name': 'chaveNegra'.tr(), 'desc': 'chaveNegraDesc'.tr(), 'icon': MdiIcons.keyWireless, 'color': Pallete.cinzaEsc};
      case CollectibleType.keys:
        return {'name': 'keys'.tr(), 'desc': 'keysDesc'.tr(), 'icon': MdiIcons.keyChain, 'color': Pallete.laranja};
      case CollectibleType.bomba:
        return {'name': 'bomb'.tr(), 'desc': 'bombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.lilas};
      case CollectibleType.bombas:
        return {'name': 'bombs'.tr(), 'desc': 'bombsDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.lilas};
      case CollectibleType.chest:
        return {'name': 'Baú', 'desc': 'Contém tesouros', 'icon': Icons.inventory_2, 'color': Pallete.laranja};
      case CollectibleType.damage:
        return {'name': 'potDmg'.tr(), 'desc': 'potDmgDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.vermelho};
      case CollectibleType.dot:
        return {'name': 'potDot'.tr(), 'desc': 'potDotDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.verdeEsc};
      case CollectibleType.critChance:
        return {'name': 'potChCrit'.tr(), 'desc': 'potChCritDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.cinzaCla};
      case CollectibleType.critDamage:
        return {'name': 'potDmgCrit'.tr(), 'desc': 'potDmgCritDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.lilas};
      case CollectibleType.fireRate:
        return {'name': 'potFireRate'.tr(), 'desc': 'potFireRateDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.laranja};
      case CollectibleType.moveSpeed:
        return {'name': 'boots'.tr(), 'desc': 'bootsDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.verdeCla};
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
        return {'name': 'audaz'.tr(), 'desc': 'audazDesc'.tr(), 'icon': MdiIcons.shieldOff, 'color': Pallete.vermelho};
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
      case CollectibleType.piercing:
        return {'name': 'piercing'.tr(), 'desc': 'piercingDesc'.tr(), 'icon': MdiIcons.middlewareOutline, 'color': Pallete.vermelho};
      case CollectibleType.homing:
        return {'name': 'homing'.tr(), 'desc': 'homingDesc'.tr(), 'icon': MdiIcons.targetAccount, 'color': Pallete.vermelho};
      case CollectibleType.fogo:
        return {'name': 'fogo'.tr(), 'desc': 'fogoDesc'.tr(), 'icon': MdiIcons.fire, 'color': Pallete.laranja};
      case CollectibleType.veneno:
        return {'name': 'veneno'.tr(), 'desc': 'venenoDesc'.tr(), 'icon': MdiIcons.water, 'color': Pallete.verdeEsc};
      case CollectibleType.sangramento:
        return {'name': 'sang'.tr(), 'desc': 'sangDesc'.tr(), 'icon': MdiIcons.water, 'color': Pallete.vermelho};
     case CollectibleType.druidScroll:
        return {'name': 'druidScroll'.tr(), 'desc': 'druidScrollDesc'.tr(), 'icon': MdiIcons.scriptText, 'color': Pallete.verdeEsc};
      case CollectibleType.dotBook:
        return {'name': 'dotBook'.tr(), 'desc': 'dotBookDesc'.tr(), 'icon': MdiIcons.bookOpenPageVariant, 'color': Pallete.amarelo};
      case CollectibleType.concentration:
        return {'name': 'concentration'.tr(), 'desc': 'concentrationDesc'.tr(), 'icon': MdiIcons.meditation, 'color': Pallete.azulCla};
      case CollectibleType.gravitacao:
        return {'name': 'gravitacao'.tr(), 'desc': 'gravitacaoDesc'.tr(), 'icon': MdiIcons.autorenew, 'color': Pallete.branco};
      case CollectibleType.mine:
        return {'name': 'mine'.tr(), 'desc': 'mineDesc'.tr(), 'icon': MdiIcons.mine, 'color': Pallete.lilas};
      case CollectibleType.soda:
         return {'name': 'soda'.tr(), 'desc': 'sodaDesc'.tr(), 'icon': MdiIcons.bottleSodaClassic, 'color': Pallete.cinzaEsc}; 
      case CollectibleType.bloodstone:
         return {'name': 'bloodstone'.tr(), 'desc': 'bloodstoneDesc'.tr(), 'icon': MdiIcons.necklace, 'color': Pallete.vermelho}; 
      case CollectibleType.spectral:
         return {'name': 'spectral'.tr(), 'desc': 'spectralDesc'.tr(), 'icon': MdiIcons.circleOpacity, 'color': Pallete.lilas}; 
      case CollectibleType.bounce:
         return {'name': 'bounce'.tr(), 'desc': 'bounceDesc'.tr(), 'icon': MdiIcons.arrowCollapseUp, 'color': Pallete.vermelho}; 
      case CollectibleType.defBurst:
         return {'name': 'defBurst'.tr(), 'desc': 'defBurstDesc'.tr(), 'icon': MdiIcons.shieldStarOutline, 'color': Pallete.vermelho}; 
      case CollectibleType.kinetic:
         return {'name': 'kinetic'.tr(), 'desc': 'kineticDesc'.tr(), 'icon': MdiIcons.runFast, 'color': Pallete.vermelho}; 
      case CollectibleType.heavyShot:
         return {'name': 'heavy'.tr(), 'desc': 'heavyDesc'.tr(), 'icon': MdiIcons.dumbbell, 'color': Pallete.cinzaEsc}; 
      case CollectibleType.cupon:
         return {'name': 'cupon'.tr(), 'desc': 'cuponDesc'.tr(), 'icon': MdiIcons.ticketPercent, 'color': Pallete.bege};
      case CollectibleType.conqCrown:
         return {'name': 'conqCrown'.tr(), 'desc': 'conqCrownDesc'.tr(), 'icon': MdiIcons.crown, 'color': Pallete.amarelo};
      case CollectibleType.flail:
         return {'name': 'flail'.tr(), 'desc': 'flailDesc'.tr(), 'icon': MdiIcons.mace, 'color': Pallete.vermelho};
      case CollectibleType.bumerangue:
         return {'name': 'bumerangue'.tr(), 'desc': 'bumerangueDesc'.tr(), 'icon': MdiIcons.boomerang, 'color': Pallete.marrom};
      case CollectibleType.pocaVeneno:
         return {'name': 'pocaVeneno'.tr(), 'desc': 'pocaVenenoDesc'.tr(), 'icon': MdiIcons.cloudOffOutline, 'color': Pallete.verdeEsc};
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
      CollectibleType.dot,
      CollectibleType.dotBook,
      CollectibleType.druidScroll,
      CollectibleType.soda,
      CollectibleType.bloodstone,
      CollectibleType.conqCrown,
    ];
    if (!player.isBerserk) itens.add(CollectibleType.berserk);
    if (!player.isAudaz) itens.add(CollectibleType.audacious);
    if (!player.isFreeze) itens.add(CollectibleType.freeze);
    if (!player.magicShield) itens.add(CollectibleType.magicShield);
    if (!player.hasOrbShield) itens.add(CollectibleType.orbitalShield);
    if (!player.hasFoice) itens.add(CollectibleType.foice);
    if (!player.pegouRevive) itens.add(CollectibleType.revive);
    if (!player.hasAntimateria) itens.add(CollectibleType.antimateria);
    if (!player.isPiercing) itens.add(CollectibleType.piercing);
    if (!player.isHoming) itens.add(CollectibleType.homing);
    if (!player.isBurn) itens.add(CollectibleType.fogo);
    if (!player.isPoison) itens.add(CollectibleType.veneno);
    if (!player.isBleed) itens.add(CollectibleType.sangramento);
    if (!player.hasChaveNegra) itens.add(CollectibleType.chaveNegra);
    if (!player.isConcentration) itens.add(CollectibleType.concentration);
    if (!player.isOrbitalShot) itens.add(CollectibleType.gravitacao);
    if (!player.isMineShot) itens.add(CollectibleType.mine);
    if (!player.isSpectral) itens.add(CollectibleType.spectral);
    if (!player.canBounce) itens.add(CollectibleType.bounce);
    if (!player.defensiveBurst) itens.add(CollectibleType.defBurst);
    if (!player.isKinetic) itens.add(CollectibleType.kinetic);
    if (!player.isHeavyShot) itens.add(CollectibleType.heavyShot);
    if (!player.hasCupon) itens.add(CollectibleType.cupon);
    if (!player.criaPocaVenenoTmr) itens.add(CollectibleType.pocaVeneno);
    
      

    return itens;
  }


List<CollectibleType> retornaItensComuns(){
    List<CollectibleType> itens = [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.keys,
      CollectibleType.dash,
      CollectibleType.sanduiche,
      CollectibleType.critChance,
      CollectibleType.critDamage,
      CollectibleType.bombas,
      CollectibleType.dot,
      CollectibleType.dotBook,
      CollectibleType.druidScroll,
      CollectibleType.bloodstone,
      CollectibleType.pocaVeneno,
    ];
    itens.add(CollectibleType.piercing);
    itens.add(CollectibleType.fogo);
    itens.add(CollectibleType.veneno);
    itens.add(CollectibleType.sangramento);
    itens.add(CollectibleType.chaveNegra);
    itens.add(CollectibleType.gravitacao);
    itens.add(CollectibleType.mine);
    itens.add(CollectibleType.spectral);
    itens.add(CollectibleType.bounce);
    itens.add(CollectibleType.cupon);
    return itens;
  }

List<CollectibleType> retornaPocoes(){
    return [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.critChance,
      CollectibleType.critDamage,
      CollectibleType.dot,
    ];
  }

  List<CollectibleType> retornaItensRaros(){
    List<CollectibleType> itRaros =[
      CollectibleType.steroids,
      CollectibleType.cafe,  
      CollectibleType.alcool,
      CollectibleType.soda,
      CollectibleType.conqCrown,
    ];
    itRaros.add(CollectibleType.berserk);
    itRaros.add(CollectibleType.audacious);
    itRaros.add(CollectibleType.freeze);
    itRaros.add(CollectibleType.magicShield);
    itRaros.add(CollectibleType.orbitalShield);
    itRaros.add(CollectibleType.foice);
    itRaros.add(CollectibleType.revive);
    itRaros.add(CollectibleType.antimateria);
    itRaros.add(CollectibleType.homing);
    itRaros.add(CollectibleType.concentration);
    itRaros.add(CollectibleType.defBurst);
    itRaros.add(CollectibleType.kinetic);
    itRaros.add(CollectibleType.heavyShot);
    return itRaros ;
  }

class CollectibleLogic {
   static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {
      // Lógica placeholder: VOCÊ DEVE MANTER A SUA LÓGICA ORIGINAL AQUI
      // Copiei apenas um exemplo para funcionar
       String text = "";
       //Color color = Pallete.branco;
       final player = game.player;
      AudioManager.playSfx('collect.mp3');
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
          player.increaseDamage(1.2);
          text = "+ Damage!";
          //color = Pallete.branco; // Laranja
          break;

        case CollectibleType.dot:
          player.dot += 0.2;
          text = "+ Dot!";
          //color = Pallete.branco; // Laranja
          break;
          
        case CollectibleType.fireRate:
          player.increaseFireRate(0.85);
          text = "+ Fire Rate!";
          //color = Pallete.azulCla; // Amarelo
          break;
          
        case CollectibleType.moveSpeed:
          player.increaseMovementSpeed(1.2);
          text = "+ Speed!";
         // color = Pallete.azulCla;
          break;
        
        case CollectibleType.range:
          player.increaseRange(1.15);
          text = "+ Range!";
          //color = Pallete.azulCla;
          break;
        
        case CollectibleType.shield:
          player.increaseShield();
          text = "+ Shield!";
          //color = Pallete.azulCla;
          break;

        case CollectibleType.healthContainer:
          player.increaseHp(2);
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
          player.healthNotifier.value = min(player.healthNotifier.value,player.maxHealth) ;
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

        case CollectibleType.flail:
          game.world.add(OrbitalShield(angleOffset: 0, owner: player, isFlail: true, radius: 10, speed:10));
          text = "Flail Orbitais!";
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

        case CollectibleType.piercing:
          player.isPiercing = true;
          text = "Piercing Shot!";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.homing:
          player.isHoming = true;
          text = "Homing Shot!";
          //color = Pallete.vermelho;
          break;  
        
        case CollectibleType.fogo:
          player.isBurn = true;
          text = "Fire Shot!";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.veneno:
          player.isPoison = true;
          text = "Poison Shot!";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.sangramento:
          player.isBleed = true;
          text = "Bleed Shot!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.druidScroll:
          player.dot *= 2;
          player.damage *= 0.6;
          text = "Druid's Scroll: Dot Doubled!";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.dotBook:
          player.dot *= 1.5;
          player.attackRange *= 0.8;
          text = "Dot Book";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.chaveNegra:
          player.hasChaveNegra = true;
          text = "Chave Negra!";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.concentration:
          player.isConcentration = true;
          text = "Concentration!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.gravitacao:
          player.isOrbitalShot = true;
          player.fireRate *= 0.5;
          text = "Gravitation!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.soda:
          player.increaseMovementSpeed(2);
          text = "Gravitation!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.mine:
          player.isMineShot = true;
          text = "Mine Shot!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bloodstone:
          player.stackBonus += 5;
          text = "Bloodstone Bonus!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bounce:
          player.canBounce = true;
          text = "Bounce Shot!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.spectral:
          player.isSpectral = true;
          text = "Spectral Shot!";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.defBurst:
          player.defensiveBurst = true;
          text = "Defensive Burst!";
          //color = Pallete.vermelho;
          break;
  
        case CollectibleType.kinetic:
          player.isKinetic = true;
          text = "Kinetico!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.heavyShot:
          player.isHeavyShot = true;
          text = "Heavy Shot!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.cupon:
          player.hasCupon = true;
          text = "Cupom de Desconto!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.conqCrown:
          player.invincibilityDuration += 0.5;
          player.dashCooldown *= 0.75;
          text = "Coroa de Conquista!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bumerangue:
          player.isBoomerang = true;
          text = "Bumerangue!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.pocaVeneno:
          player.criaPocaVeneno = true;
          text = "poça veneno!";
          //color = Pallete.vermelho;
          break;

        default:
          text = "";
          break;
       }
       return {'text': text, 'color': Pallete.branco};
   }
}