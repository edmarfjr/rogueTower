import 'dart:math';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';
import 'package:towerrogue/game/components/core/interact_button.dart';
import 'package:towerrogue/game/components/effects/explosion_effect.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import 'package:towerrogue/game/components/effects/unlock_notification.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/enemies/enemy_boss.dart';
import 'package:towerrogue/game/components/gameObj/familiar.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/projectiles/black_hole.dart';
import 'package:towerrogue/game/components/projectiles/bombardmentEffect.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:towerrogue/game/components/projectiles/orbital_shield.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
//import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
//import 'package:flame/events.dart'; 
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../effects/floating_text.dart';
import '../core/i18n.dart';

class ActiveItemData {
  final CollectibleType type;
  int currentCharge;
  int maxCharge;

  ActiveItemData({
    required this.type,
    required this.currentCharge,
    required this.maxCharge,
  });

  bool get isReady => currentCharge >= maxCharge;
}

enum CollectibleType {
  //tipos de porta 
  coin, coinUm, souls, potion, potionUm, artificialHp,key, shield, shop, boss, nextlevel, chest, bank, rareChest, bomba, alquimista, desafio, darkShop,
  doacaoSangue, slotMachine,
  //itens comuns
  damage, fireRate, moveSpeed, range, sorte, healthContainer, keys, dash, sanduiche, critChance, critDamage, bombas, piercing, dot,
  fogo,veneno, sangramento, druidScroll, dotBook, chaveNegra, gravitacao, mine, bloodstone, bounce, spectral, cupon, bumerangue,
  pocaVeneno, rastroFogo, activeHeal, activePoisonBomb, activeBattery, battery, activeArtHp, activeMagicKey, activeHoming,
  activeGift, activeRerollItem, activeBandage, activeMidas, goldDmg, activeUnicornUnico, activeBombardeioUnico, activeTurretUnico,
  saw, boloDinheiro, restock, goldShot, primeiroInimigoPocaVeneno, familiarFinger, familiarBouncer, familiarPrisma,familiarRefletor,
  jumpersCable, activeCircularShots, keysToBombs, activeRandPillUnico, activeFear, activeDiarreiaExplosiva,familiarDummy, voo,
  cardinalShot, activeBloodBag, activeDullRazor, activeBoxSpider, activeD10, defensiveFairys, familiarDmgBns, itemExtraBoss, activeSlot,
  activeFreezeBomb, activeBltDetonator, activeGoldenrazor, activeSacrifFamiliar, activeTurretRotate, activeGlassStaff, activeBuracoNegro,
  activeLoja, activeRestart, activeCleaver, bombaBuracoNegro, activeKamikaze, retribuicao, adagaArremeco, bloquel, glifoEquilibrio, 
  bltFireHazard, trofelCampeao, familiarLanca, activeWoodenCoin, 
  //itens raros
  berserk, audacious, steroids, cafe, freeze, magicShield, alcool, orbitalShield, foice, revive, antimateria, homing,
  concentration, soda, defBurst, kinetic, heavyShot, conqCrown, flail, tornado, tripleShot, activeLicantropia, regenShield,
  decoy, magicMush, activeMagicKeyChain, activeD6, splitShot, familiarBlock, familiarAtira, confuseCrit, pregos, bombDecoy,
  activeHeartConverter, activeDivineShield, activeRitualDagger, activeConvBruta, activeMagicMirror, charmOnCrit, freezeDash,
  activeStunBomb, activeFairy, activeUnicorn, activeBombardeio, curaCrit, molotov, laser, activeTurret, wave, activeSuborno,
  pilNanicolina, retaliar, familiarFreeze, encolheOnCrit, familiarGlitch, familiarDmgBuff, familiarCircProt,glitterBomb,
  clusterShot, evasao, familiarEye, adrenalina, eutanasia, goldHeart, activeRandPill, portalBoss, noveVidas, activePacmen,
  hurtPac, zodiacAquarius, zodiacAries, zodiacCancer, zodiacCapricorn, zodiacGemini, zodiacLeo, zodiacLibra, zodiacPisces,
  zodiacSargittarius, zodiacScorpio, zodiacTaurus, zodiacVirgo, zodiac, activeScroll, familiarMastery, activeGoldenBox,
  activeJarroDeVida, activePa, activeBoxOfFriends, activeDupliItem, activeJarroFadas, activeSuperLaser, activeNuke, bltBuracoNegro,
  bltSparks, paralisia, devilInside, rainbowShot,
}


bool isItemRecarregavel(CollectibleType type) {
  const recarregaveis = [
    CollectibleType.activePoisonBomb, 
    CollectibleType.activeLicantropia, 
    CollectibleType.activeHeal, 
    CollectibleType.activeMagicKeyChain,
    CollectibleType.activeGift,
    CollectibleType.activeHeartConverter,
    CollectibleType.activeRitualDagger,
    CollectibleType.activeConvBruta,
    CollectibleType.activeMagicMirror,
    CollectibleType.activeMidas,
    CollectibleType.activeStunBomb,
    CollectibleType.activeFairy,
    CollectibleType.activeUnicorn,
    CollectibleType.activeBombardeio,
    CollectibleType.activeTurret,
    CollectibleType.activeCircularShots,
    CollectibleType.activeRandPill,
    CollectibleType.activeDiarreiaExplosiva,
    CollectibleType.activeBloodBag,
    CollectibleType.activeDullRazor,
    CollectibleType.activeBoxSpider,
    CollectibleType.activeD10,
    CollectibleType.activeScroll,
    CollectibleType.activeGoldenBox,
    CollectibleType.activeSlot,
    CollectibleType.activeJarroDeVida,
    CollectibleType.activeBoxOfFriends,
    CollectibleType.activeJarroFadas,
    CollectibleType.activeFreezeBomb,
    CollectibleType.activeSuperLaser,
    CollectibleType.activeBltDetonator,
    CollectibleType.activeGoldenrazor,
    CollectibleType.activeTurretRotate,
    CollectibleType.activeGlassStaff,
    CollectibleType.activeBuracoNegro,
    CollectibleType.activeLoja,
    CollectibleType.activeCleaver,
    CollectibleType.activeKamikaze,
    CollectibleType.activeWoodenCoin,
  ];
  return recarregaveis.contains(type);
}

bool isItemUsoUnico(CollectibleType type) {
  const usoUnico = [
    CollectibleType.sanduiche,
    CollectibleType.cupon,  
    CollectibleType.activeBattery,
    CollectibleType.activeArtHp,
    CollectibleType.activeMagicKey,
    CollectibleType.activeHoming,
    CollectibleType.activeD6,
    CollectibleType.activeDivineShield,
    CollectibleType.activeRerollItem,
    CollectibleType.activeBandage,
    CollectibleType.activeUnicornUnico,
    CollectibleType.activeBombardeioUnico,
    CollectibleType.activeTurretUnico,
    CollectibleType.activeSuborno,
    CollectibleType.keysToBombs,
    CollectibleType.activeRandPillUnico,
    CollectibleType.portalBoss,
    CollectibleType.activeFear,
    CollectibleType.activePacmen,
    CollectibleType.activePa,
    CollectibleType.activeDupliItem,
    CollectibleType.activeSacrifFamiliar,
    CollectibleType.activeRestart,
    CollectibleType.activeNuke,
  ];
  return usoUnico.contains(type);
}

bool isItemAtivo(CollectibleType type) {
  return isItemRecarregavel(type) || isItemUsoUnico(type);
}

class Collectible extends PositionComponent with HasGameRef<TowerGame> {
  final CollectibleType type;
  int custo;
  int souls;
  int custoKeys;
  int custoBombs;
  bool custoVida;
  bool naoEsgota;
  int? activeCharge;
  bool _isCollected = false;

  Vector2 _velocity = Vector2.zero();
  final double _gravity = 900.0; 
  bool isBouncing = false;
  double _groundY = 0.0;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 30.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão
  InteractButton? _currentButton;
  GameIcon? visual;

  Collectible({
    required Vector2 position, 
    required this.type, 
    this.custo = 0, 
    this.souls = 0, 
    this.custoKeys = 0, 
    this.custoBombs = 0, 
    this.custoVida = false,
    this.naoEsgota=false,
    this.activeCharge,
    }): super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Configura Visual (Ícone e Cor)
    final attrs = Collectible.getAttributes(type);
    IconData iconData = attrs['icon'] as IconData;
    Color iconColor = attrs['color'] as Color;

    double ang = 0;

    if(type == CollectibleType.activeFairy) ang = pi/4;

    visual = GameIcon(
      icon: iconData,
      color: iconColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    );

    visual!.angle = ang;
    add(visual!);

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
    priority = position.y.toInt();
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
    
    final attrs = Collectible.getAttributes(type);
    String name = attrs['name'] as String;
    String desc = attrs['desc'] as String;

    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);
    
    _infoGroup.priority = 1500;

    // 1. Descrição do Efeito
    final textDesc = TextBoxComponent(
      text: desc.toLowerCase(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Pallete.branco, 
          fontSize: 12, 
          backgroundColor: Colors.black54
        )
      ),
      anchor: Anchor.bottomCenter,
      align: Anchor.center,
      position: Vector2(0, 10),
      boxConfig: const TextBoxConfig(
        maxWidth: 250.0,
        // Se colocar 0.0, o texto aparece todo de uma vez instantaneamente.
        // Se colocar, por exemplo, 0.05, ele faz um efeito de "digitando" muito legal!
        timePerChar: 0.0, 
      ),
    );

    double espacoEntreTextos = 2.0;
    double posicaoYDoTitulo = textDesc.position.y - textDesc.size.y - espacoEntreTextos;

    // 2. Nome do Item
    final textName = TextComponent(
      text: name.toUpperCase(),
      textRenderer: TextPaint(style: const TextStyle(color: Pallete.amarelo, fontSize: 12, fontWeight: FontWeight.bold, backgroundColor: Colors.black54)),
      anchor: Anchor.bottomCenter,
      position: Vector2(0, posicaoYDoTitulo),
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

  void _collectItem() async {
    // 1. SALVA A REFERÊNCIA (Se o item sumir no meio do código, o 'game' continua existindo na memória!)
    final game = gameRef;
    final player = game.player;

    // Se já foi coletado e está no processo de sumir, ignora novas colisões!
    if (_isCollected) return;

    // 2. VERIFICAÇÃO DE CUSTO (Usa a variável 'game' em vez de 'gameRef')
    if (custo > 0) {
      if (game.coinsNotifier.value < custo) {
        game.world.add(FloatingText(text: "noCoins".tr(), position: position + Vector2(0, -20), color: Pallete.vermelho, fontSize: 10));
        return; // Retorna sem travar o item, o jogador pode tentar comprar depois!
      }
    }
    if (custoKeys > 0) {
      if (game.keysNotifier.value < custoKeys) {
        game.world.add(FloatingText(text: "noKeys".tr(), position: position + Vector2(0, -20), color: Pallete.vermelho, fontSize: 10));
        return;
      }
    }
    if (custoBombs > 0) {
      if (player.bombNotifier.value < custoBombs) {
        game.world.add(FloatingText(text: "noBombs".tr(), position: position + Vector2(0, -20), color: Pallete.vermelho, fontSize: 10));
        return;
      }
    }
    if (custoVida) {
      if (player.maxHealth < 6) {
        game.world.add(FloatingText(text: "noHp".tr(), position: position + Vector2(0, -20), color: Pallete.vermelho, fontSize: 10));
        return;
      }
    }

    // --- PASSOU NOS TESTES DE CUSTO! ---
    // Trancamos o item agora. Nenhuma outra colisão vai passar daqui.
    _isCollected = true;

    // 3. COBRANÇA (Agora é seguro deduzir os valores)
    if (custo > 0) game.coinsNotifier.value -= custo;
    if (custoKeys > 0) game.keysNotifier.value -= custoKeys;
    if (custoBombs > 0) player.bombNotifier.value -= custoBombs;
    if (custoVida) {
      player.maxHealth -= 6;
      player.healthNotifier.value = min(player.healthNotifier.value, player.maxHealth);
    }

    // 4. RESTOCK DE ITENS
    if ((custo > 0 || custoKeys > 0 || custoBombs > 0 || custoVida) && player.restock) {
      final rng = Random();
      final rngPool = rng.nextDouble();
      List<CollectibleType> pool = [];

      if(custo > 0){
        if (rngPool <= 0.2) pool = retornaItensRaros(player);
        else if(rngPool <= 0.6) pool = retornaItensComuns(player);
        else pool = retornaPocoes();
      } else if(custoKeys > 0 || custoBombs > 0){
        pool = retornaPocoes();
      } else if(custoVida){
        pool = retornaItensRaros(player);
      }
      
      if (pool.isNotEmpty) {
        pool.shuffle();
        final novoItem = Collectible(
          position: position.clone(), type: pool.first,
          custo: custo, custoKeys: custoKeys, custoBombs: custoBombs, custoVida: custoVida,
        );
        game.world.add(novoItem);
        createExplosionEffect(game.world, position.clone(), Pallete.branco, count: 10);
      }
    }

    // 5. APLICAÇÃO DE EFEITOS E ITENS ATIVOS
    if (isItemAtivo(type)) {
      ActiveItemData? droppedData = player.equipActiveItem(type, activeCharge);

      if (droppedData != null) {
        final droppedItem = Collectible(
          position: player.position.clone(), type: droppedData.type, activeCharge: droppedData.currentCharge,
        );
        game.world.add(droppedItem);
        droppedItem.pop(Vector2((Random().nextDouble() - 0.5) * 60, 10));
      }

      game.progress.discoverItem(type.toString());
      if (!naoEsgota) removeFromParent(); 
      AudioManager.playSfx('collect.mp3'); 
      
      // Como tem return aqui, chamamos o unlock antes de sair
      _tentaDesbloquearClasse(game);
      return; 
    }
    
    // Efeitos passivos
    final feedback = Collectible.applyEffect(type: type, game: game);
    String feedbackText = feedback['text'] as String;
    Color feedbackColor = feedback['color'] as Color;

    /*
    if (feedbackText.isNotEmpty) {
      game.world.add(FloatingText(text: feedbackText, position: position.clone(), color: feedbackColor, fontSize: 12));
    }
    */

    // 6. INVENTÁRIO
    final List<CollectibleType> consumiveis = [
      CollectibleType.coin, CollectibleType.coinUm ,CollectibleType.potion, CollectibleType.sanduiche,
      CollectibleType.potionUm,CollectibleType.key, CollectibleType.keys, CollectibleType.bomba, 
      CollectibleType.souls,CollectibleType.bombas, CollectibleType.chest, CollectibleType.rareChest, 
      CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextlevel, 
      CollectibleType.shop, CollectibleType.boss, CollectibleType.shield, CollectibleType.doacaoSangue,
      CollectibleType.healthContainer,CollectibleType.slotMachine
    ];

    if (!consumiveis.contains(type)) {
      final attrs = Collectible.getAttributes(type);
      player.setAcquiredItemsList(
        type, attrs['name'] as String, attrs['desc'] as String, attrs['icon'] as IconData, attrs['color'] as Color,
      );
      game.progress.discoverItem(type.toString());
    }
    
    // 7. REMOVE DO JOGO IMEDIATAMENTE!
    if (!naoEsgota) removeFromParent();
    
    // 8. O AWAIT FICA NO FINAL (Ele roda em segundo plano sem quebrar nada)
    _tentaDesbloquearClasse(game);
  }

  // --- FUNÇÃO AUXILIAR PARA O AWAIT NÃO ATRAPALHAR O FLUXO ---
  Future<void> _tentaDesbloquearClasse(TowerGame game) async {
    String clasId = '';
    String clasNome = '';

    switch (type){
      case CollectibleType.activeLicantropia:
        clasId = 'licantropo'; clasNome = 'licantropo'.tr(); break;
      case CollectibleType.molotov:
        clasId = 'multidao'; clasNome = 'multidao'.tr(); break;
      default: return; // Não é item de classe
    }

    bool isNewUnlock = await GameProgress.unlockClass(clasId); 
        
    if (isNewUnlock) {
      // Como usamos a variável 'game' salva, adicionar o texto funciona mesmo com o item já removido!
      game.world.add(UnlockNotification(
        message: "NOVA CLASSE: $clasNome!",
        position: position.clone(),
      ));
    }
  }

  // Helper para pegar dados visuais e textos (Nome, Descrição, Ícone, Cor)
  static Map<String, dynamic> getAttributes(CollectibleType t) {
    switch (t) {
      case CollectibleType.coin:
        return {'name': 'gold'.tr(), 'desc': 'goldDesc'.tr(), 'icon': Icons.monetization_on, 'color': Pallete.amarelo};
      case CollectibleType.coinUm:
        return {'name': 'goldUm'.tr(), 'desc': 'goldUmDesc'.tr(), 'icon': Icons.monetization_on, 'color': Pallete.amarelo};
      case CollectibleType.souls:
        return {'name': 'soul'.tr(), 'desc': 'alma', 'icon': MdiIcons.fire, 'color': Pallete.lilas};
      case CollectibleType.potion:
        return {'name': 'heart'.tr(), 'desc': 'heartDesc'.tr(), 'icon': Icons.favorite, 'color': Pallete.vermelho};
      case CollectibleType.potionUm:
        return {'name': 'heartUm'.tr(), 'desc': 'heartUmDesc'.tr(), 'icon': Icons.favorite, 'color': Pallete.vermelho};
      case CollectibleType.artificialHp:
        return {'name': 'artificialHp'.tr(), 'desc': 'artificialHpDesc'.tr(), 'icon': Icons.favorite, 'color': Pallete.azulCla};
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
      case CollectibleType.sorte:
        return {'name': 'sortePot'.tr(), 'desc': 'sortePotDesc'.tr(), 'icon': MdiIcons.flaskRoundBottom, 'color': Pallete.amarelo};
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
        return {'name': 'steroids'.tr(), 'desc': 'steroidsDesc'.tr(), 'icon': MdiIcons.needle, 'color': Pallete.vermelho};
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
        return {'name': 'revive'.tr(), 'desc': 'reviveDesc'.tr(), 'icon': MdiIcons.oneUp, 'color': Pallete.verdeCla};
      case CollectibleType.antimateria:
        return {'name': 'antimat'.tr(), 'desc': 'antimatDesc'.tr(), 'icon': MdiIcons.radioboxMarked, 'color': Pallete.lilas};
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
      case CollectibleType.rastroFogo:
         return {'name': 'rastroFogo'.tr(), 'desc': 'rastroFogoDesc'.tr(), 'icon': MdiIcons.fireCircle, 'color': Pallete.vermelho};
      case CollectibleType.tornado:
         return {'name': 'tornado'.tr(), 'desc': 'tornadoDesc'.tr(), 'icon': MdiIcons.weatherTornado, 'color': Pallete.branco};
      case CollectibleType.tripleShot:
         return {'name': 'tripleShot'.tr(), 'desc': 'tripleShotDesc'.tr(), 'icon': MdiIcons.arrowDecision, 'color': Pallete.branco};
      case CollectibleType.activeHeal:
         return {'name': 'activeHeal'.tr(), 'desc': 'activeHealDesc'.tr(), 'icon': MdiIcons.bottleTonicPlusOutline, 'color': Pallete.vermelho};
      case CollectibleType.activePoisonBomb:
         return {'name': 'activePoisonBomb'.tr(), 'desc': 'activePoisonBombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.verdeEsc};
      case CollectibleType.activeLicantropia:
         return {'name': 'activeLicantropia'.tr(), 'desc': 'activeLicantropiaDesc'.tr(), 'icon': MdiIcons.dogSide, 'color': Pallete.vermelho};
      case CollectibleType.activeBattery:
         return {'name': 'activeBattery'.tr(), 'desc': 'activeBatteryDesc'.tr(), 'icon': MdiIcons.battery, 'color': Pallete.azulCla};
      case CollectibleType.battery:
         return {'name': 'battery'.tr(), 'desc': 'batteryDesc'.tr(), 'icon': MdiIcons.carBattery, 'color': Pallete.azulCla};
      case CollectibleType.regenShield:
         return {'name': 'regenShield'.tr(), 'desc': 'regenShieldDesc'.tr(), 'icon': MdiIcons.shieldSync, 'color': Pallete.azulCla};
      case CollectibleType.activeArtHp:
         return {'name': 'activeArtHp'.tr(), 'desc': 'activeArtHpDesc'.tr(), 'icon': MdiIcons.heart, 'color': Pallete.azulCla};
      case CollectibleType.decoy:
        return {'name': 'decoy'.tr(), 'desc': 'decoyDesc'.tr(), 'icon': MdiIcons.accountMultiple, 'color': Pallete.cinzaCla};
      case CollectibleType.magicMush:
        return {'name': 'magicMush'.tr(), 'desc': 'magicMushDesc'.tr(), 'icon': MdiIcons.oneUp, 'color': Pallete.vermelho};
      case CollectibleType.activeMagicKey:
        return {'name': 'activeMagicKey'.tr(), 'desc': 'activeMagicKeyDesc'.tr(), 'icon': Icons.vpn_key, 'color': Pallete.azulCla};
      case CollectibleType.activeMagicKeyChain:
        return {'name': 'activeMagicKeyChain'.tr(), 'desc': 'activeMagicKeyChainDesc'.tr(), 'icon': MdiIcons.keyChain, 'color': Pallete.azulCla};
      case CollectibleType.activeHoming:
        return {'name': 'activeHoming'.tr(), 'desc': 'activeHomingDesc'.tr(), 'icon': MdiIcons.targetAccount, 'color': Pallete.laranja};
      case CollectibleType.activeGift:
        return {'name': 'activeGift'.tr(), 'desc': 'activeGiftDesc'.tr(), 'icon': MdiIcons.gift, 'color': Pallete.rosa};
      case CollectibleType.activeD6:
        return {'name': 'activeD6'.tr(), 'desc': 'activeD6Desc'.tr(), 'icon': MdiIcons.dice6, 'color': Pallete.verdeCla};
      case CollectibleType.splitShot:
        return {'name': 'splitShot'.tr(), 'desc': 'splitShotDesc'.tr(), 'icon': MdiIcons.axisArrow, 'color': Pallete.vermelho};
      case CollectibleType.familiarBlock:
        return {'name': 'familiarBlock'.tr(), 'desc': 'familiarBlockDesc'.tr(), 'icon': MdiIcons.fire, 'color': Pallete.azulCla};
      case CollectibleType.familiarAtira:
        return {'name': 'familiarAtira'.tr(), 'desc': 'familiarAtiraDesc'.tr(), 'icon': MdiIcons.fire, 'color': Pallete.vermelho};
      case CollectibleType.confuseCrit:
        return {'name': 'confuseCrit'.tr(), 'desc': 'confuseCritDesc'.tr(), 'icon': MdiIcons.headQuestion, 'color': Pallete.amarelo};
      case CollectibleType.pregos:
        return {'name': 'pregos'.tr(), 'desc': 'pregosDesc'.tr(), 'icon': MdiIcons.nail, 'color': Pallete.cinzaCla};
      case CollectibleType.bombDecoy:
        return {'name': 'bombDecoy'.tr(), 'desc': 'bombDecoyDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.cinzaEsc};
      case CollectibleType.activeHeartConverter:
        return {'name': 'activeHeartConverter'.tr(), 'desc': 'activeHeartConverterDesc'.tr(), 'icon': MdiIcons.heartOutline, 'color': Pallete.azulCla};
      case CollectibleType.activeDivineShield:
        return {'name': 'activeDivineShield'.tr(), 'desc': 'activeDivineShieldDesc'.tr(), 'icon': MdiIcons.shieldStar, 'color': Pallete.azulCla};
      case CollectibleType.activeRerollItem:
        return {'name': 'activeRerollItem'.tr(), 'desc': 'activeRerollItemDesc'.tr(), 'icon': MdiIcons.diceD20, 'color': Pallete.laranja};
      case CollectibleType.activeRitualDagger:
        return {'name': 'activeRitualDagger'.tr(), 'desc': 'activeRitualDaggerDesc'.tr(), 'icon': MdiIcons.knifeMilitary, 'color': Pallete.vermelho};
      case CollectibleType.activeBandage:
        return {'name': 'activeBandage'.tr(), 'desc': 'activeBandageDesc'.tr(), 'icon': MdiIcons.bandage, 'color': Pallete.bege};
      case CollectibleType.activeMagicMirror:
        return {'name': 'activeMagicMirror'.tr(), 'desc': 'activeMagicMirrorDesc'.tr(), 'icon': MdiIcons.mirrorVariant, 'color': Pallete.laranja};
      case CollectibleType.activeConvBruta:
        return {'name': 'activeConvBruta'.tr(), 'desc': 'activeConvBrutaDesc'.tr(), 'icon': MdiIcons.flaskPlus, 'color': Pallete.vermelho};
      case CollectibleType.activeMidas:
        return {'name': 'activeMidas'.tr(), 'desc': 'activeMidasDesc'.tr(), 'icon': MdiIcons.handFrontRight, 'color': Pallete.laranja};
      case CollectibleType.charmOnCrit:
        return {'name': 'charmOnCrit'.tr(), 'desc': 'charmOnCritDesc'.tr(), 'icon': MdiIcons.charity, 'color': Pallete.rosa};
      case CollectibleType.freezeDash:
        return {'name': 'freezeDash'.tr(), 'desc': 'freezeDashDesc'.tr(), 'icon': MdiIcons.skate, 'color': Pallete.azulCla};
      case CollectibleType.goldDmg:
        return {'name': 'goldDmg'.tr(), 'desc': 'goldDmgDesc'.tr(), 'icon': MdiIcons.magicStaff, 'color': Pallete.laranja};
      case CollectibleType.activeStunBomb:
        return {'name': 'activeStunBomb'.tr(), 'desc': 'activeStunBombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.amarelo};
      case CollectibleType.activeFairy:
        return {'name': 'activeFairy'.tr(), 'desc': 'activeFairyDesc'.tr(), 'icon': MdiIcons.candy, 'color': Pallete.amarelo};
      case CollectibleType.activeUnicorn:
        return {'name': 'activeUnicorn'.tr(), 'desc': 'activeUnicornDesc'.tr(), 'icon': MdiIcons.unicornVariant, 'color': Pallete.laranja};
      case CollectibleType.activeUnicornUnico:
        return {'name': 'activeUnicorn'.tr(), 'desc': 'activeUnicornDesc'.tr(), 'icon': MdiIcons.unicornVariant, 'color': Pallete.amarelo};
      case CollectibleType.activeBombardeio:
        return {'name': 'activeBombardeio'.tr(), 'desc': 'activeBombardeioDesc'.tr(), 'icon': MdiIcons.airplaneRemove, 'color': Pallete.vermelho};
      case CollectibleType.activeBombardeioUnico:
        return {'name': 'activeBombardeio'.tr(), 'desc': 'activeBombardeioDesc'.tr(), 'icon': MdiIcons.airplaneRemove, 'color': Pallete.laranja};
      case CollectibleType.curaCrit:
        return {'name': 'curaCrit'.tr(), 'desc': 'curaCritDesc'.tr(), 'icon': MdiIcons.bloodBag, 'color': Pallete.vermelho};
      case CollectibleType.molotov:
        return {'name': 'molotov'.tr(), 'desc': 'molotovDesc'.tr(), 'icon': MdiIcons.bottleWine, 'color': Pallete.laranja};
      case CollectibleType.laser:
        return {'name': 'laser'.tr(), 'desc': 'laserDesc'.tr(), 'icon': MdiIcons.laserPointer, 'color': Pallete.vermelho};
      case CollectibleType.activeTurret:
        return {'name': 'activeTurret'.tr(), 'desc': 'activeTurretDesc'.tr(), 'icon': MdiIcons.floorLampTorchiereVariant, 'color': Pallete.vermelho};
      case CollectibleType.activeTurretUnico:
        return {'name': 'activeTurret'.tr(), 'desc': 'activeTurretDesc'.tr(), 'icon': MdiIcons.floorLampTorchiereVariant, 'color': Pallete.laranja};
      case CollectibleType.wave:
        return {'name': 'wave'.tr(), 'desc': 'waveDesc'.tr(), 'icon': MdiIcons.waves, 'color': Pallete.azulCla};
      case CollectibleType.activeSuborno:
        return {'name': 'activeSuborno'.tr(), 'desc': 'activeSubornoDesc'.tr(), 'icon': MdiIcons.accountCash, 'color': Pallete.verdeEsc};
      case CollectibleType.pilNanicolina:
        return {'name': 'pilNanicolina'.tr(), 'desc': 'pilNanicolinaDesc'.tr(), 'icon': MdiIcons.pill, 'color': Pallete.azulCla};
      case CollectibleType.saw:
        return {'name': 'saw'.tr(), 'desc': 'sawDesc'.tr(), 'icon': MdiIcons.sawBlade, 'color': Pallete.cinzaCla};
      case CollectibleType.boloDinheiro:
        return {'name': 'boloDinheiro'.tr(), 'desc': 'boloDinheiroDesc'.tr(), 'icon': MdiIcons.cashMultiple, 'color': Pallete.verdeEsc};
      case CollectibleType.retaliar:
        return {'name': 'retaliar'.tr(), 'desc': 'retaliarDesc'.tr(), 'icon': MdiIcons.shieldSwordOutline, 'color': Pallete.vermelho};
      case CollectibleType.restock:
        return {'name': 'restock'.tr(), 'desc': 'restockDesc'.tr(), 'icon': MdiIcons.cart, 'color': Pallete.vermelho};
      case CollectibleType.familiarFreeze:
        return {'name': 'familiarFreeze'.tr(), 'desc': 'familiarFreezeDesc'.tr(), 'icon': MdiIcons.snowflake, 'color': Pallete.azulCla};
      case CollectibleType.encolheOnCrit:
        return {'name': 'encolheOnCrit'.tr(), 'desc': 'encolheOnCritDesc'.tr(), 'icon': MdiIcons.accountArrowDown, 'color': Pallete.marrom};
      case CollectibleType.familiarGlitch:
        return {'name': 'familiarGlitch'.tr(), 'desc': 'familiarGlitchDesc'.tr(), 'icon': MdiIcons.circleOpacity, 'color': Pallete.rosa};
      case CollectibleType.familiarDmgBuff:
        return {'name': 'familiarDmgBuff'.tr(), 'desc': 'familiarDmgBuffDesc'.tr(), 'icon': MdiIcons.satelliteVariant, 'color': Pallete.vermelho};
      case CollectibleType.familiarCircProt:
        return {'name': 'familiarCircProt'.tr(), 'desc': 'familiarCircProtDesc'.tr(), 'icon': MdiIcons.circleDouble, 'color': Pallete.branco};
      case CollectibleType.glitterBomb:
        return {'name': 'glitterBomb'.tr(), 'desc': 'glitterBombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.rosa};
      case CollectibleType.goldShot:
        return {'name': 'goldShot'.tr(), 'desc': 'goldShotDesc'.tr(), 'icon': MdiIcons.gold, 'color': Pallete.laranja};
      case CollectibleType.clusterShot:
        return {'name': 'clusterShot'.tr(), 'desc': 'clusterShotDesc'.tr(), 'icon': MdiIcons.dotsHexagon, 'color': Pallete.vinho};
      case CollectibleType.evasao:
        return {'name': 'evasao'.tr(), 'desc': 'evasaoDesc'.tr(), 'icon': MdiIcons.runFast, 'color': Pallete.azulCla};
      case CollectibleType.primeiroInimigoPocaVeneno:
        return {'name': 'primeiroInimigoPocaVeneno'.tr(), 'desc': 'primeiroInimigoPocaVenenoDesc'.tr(), 'icon': MdiIcons.needle, 'color': Pallete.verdeCla};
      case CollectibleType.familiarFinger:
        return {'name': 'familiarFinger'.tr(), 'desc': 'familiarFingerDesc'.tr(), 'icon': MdiIcons.handPointingRight, 'color': Pallete.bege};
      case CollectibleType.familiarBouncer:
        return {'name': 'familiarBouncer'.tr(), 'desc': 'familiarBouncerDesc'.tr(), 'icon': MdiIcons.weatherTornado, 'color': Pallete.branco};
      case CollectibleType.familiarEye:
        return {'name': 'familiarEye'.tr(), 'desc': 'familiarEyeDesc'.tr(), 'icon': MdiIcons.eyeCircle, 'color': Pallete.rosa};
      case CollectibleType.adrenalina:
        return {'name': 'adrenalina'.tr(), 'desc': 'adrenalinaDesc'.tr(), 'icon': MdiIcons.needle, 'color': Pallete.rosa};
      case CollectibleType.eutanasia:
        return {'name': 'eutanasia'.tr(), 'desc': 'eutanasiaDesc'.tr(), 'icon': MdiIcons.needle, 'color': Pallete.cinzaEsc};
      case CollectibleType.goldHeart:
        return {'name': 'goldHeart'.tr(), 'desc': 'goldHeartDesc'.tr(), 'icon': MdiIcons.heart, 'color': Pallete.laranja};
      case CollectibleType.familiarPrisma:
        return {'name': 'familiarPrisma'.tr(), 'desc': 'familiarPrismaDesc'.tr(), 'icon': MdiIcons.triangle, 'color': Pallete.branco};
      case CollectibleType.familiarRefletor:
        return {'name': 'familiarRefletor'.tr(), 'desc': 'familiarRefletorDesc'.tr(), 'icon': MdiIcons.mirrorVariant, 'color': Pallete.cinzaCla};
      case CollectibleType.jumpersCable:
        return {'name': 'jumpersCable'.tr(), 'desc': 'jumpersCableDesc'.tr(), 'icon': MdiIcons.jumpRope, 'color': Pallete.cinzaEsc};
      case CollectibleType.activeCircularShots:
        return {'name': 'activeCircularShots'.tr(), 'desc': 'activeCircularShotsDesc'.tr(), 'icon': MdiIcons.dotsCircle, 'color': Pallete.branco};
      case CollectibleType.keysToBombs:
        return {'name': 'keysToBombs'.tr(), 'desc': 'keysToBombsDesc'.tr(), 'icon': MdiIcons.keyArrowRight, 'color': Pallete.lilas};
      case CollectibleType.activeRandPill:
        return {'name': 'activeRandPill'.tr(), 'desc': 'activeRandPillDesc'.tr(), 'icon': MdiIcons.medication, 'color': Pallete.laranja};
      case CollectibleType.activeRandPillUnico:
        return {'name': 'activeRandPill'.tr(), 'desc': 'activeRandPillDesc'.tr(), 'icon': MdiIcons.medication, 'color': Pallete.verdeEsc};
      case CollectibleType.portalBoss:
        return {'name': 'portalBoss'.tr(), 'desc': 'portalBossDesc'.tr(), 'icon': MdiIcons.tunnelOutline, 'color': Pallete.vermelho};
      case CollectibleType.activeFear:
        return {'name': 'activeFear'.tr(), 'desc': 'activeFearDesc'.tr(), 'icon': MdiIcons.emoticonAngryOutline, 'color': Pallete.vinho};
      case CollectibleType.activeDiarreiaExplosiva:
        return {'name': 'activeDiarreiaExplosiva'.tr(), 'desc': 'activeDiarreiaExplosivaDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.marrom};
      case CollectibleType.familiarDummy:
        return {'name': 'familiarDummy'.tr(), 'desc': 'familiarDummyDesc'.tr(), 'icon': MdiIcons.humanMale, 'color': Pallete.bege};
      case CollectibleType.voo:
        return {'name': 'voo'.tr(), 'desc': 'vooDesc'.tr(), 'icon': MdiIcons.humanHandsup, 'color': Pallete.azulCla};
      case CollectibleType.cardinalShot:
        return {'name': 'cardinalShot'.tr(), 'desc': 'cardinalShotDesc'.tr(), 'icon': MdiIcons.arrowExpandAll, 'color': Pallete.vermelho};
      case CollectibleType.noveVidas:
        return {'name': 'noveVidas'.tr(), 'desc': 'noveVidasDesc'.tr(), 'icon': MdiIcons.cat, 'color': Pallete.azulEsc};
      case CollectibleType.activePacmen:
        return {'name': 'activePacmen'.tr(), 'desc': 'activePacmenDesc'.tr(), 'icon': MdiIcons.nintendoGameBoy, 'color': Pallete.cinzaCla};
      case CollectibleType.hurtPac:
        return {'name': 'hurtPac'.tr(), 'desc': 'hurtPacDesc'.tr(), 'icon': MdiIcons.gamepadSquare, 'color': Pallete.cinzaCla};
      case CollectibleType.zodiacAquarius:
        return {'name': 'zodiacAquarius'.tr(), 'desc': 'zodiacAquariusDesc'.tr(), 'icon': MdiIcons.zodiacAquarius, 'color': Pallete.azulCla};
      case CollectibleType.zodiacAries:
        return {'name': 'zodiacAries'.tr(), 'desc': 'zodiacAriesDesc'.tr(), 'icon': MdiIcons.zodiacAries, 'color': Pallete.azulCla};
      case CollectibleType.zodiacCancer:
        return {'name': 'zodiacCancer'.tr(), 'desc': 'zodiacCancerDesc'.tr(), 'icon': MdiIcons.zodiacCancer, 'color': Pallete.azulCla};
      case CollectibleType.zodiacCapricorn:
        return {'name': 'zodiacCapricorn'.tr(), 'desc': 'zodiacCapricornDesc'.tr(), 'icon': MdiIcons.zodiacCapricorn, 'color': Pallete.azulCla};
      case CollectibleType.zodiacGemini:
        return {'name': 'zodiacGemini'.tr(), 'desc': 'zodiacGeminiDesc'.tr(), 'icon': MdiIcons.zodiacGemini, 'color': Pallete.azulCla};
      case CollectibleType.zodiacLeo:
        return {'name': 'zodiacLeo'.tr(), 'desc': 'zodiacLeoDesc'.tr(), 'icon': MdiIcons.zodiacLeo, 'color': Pallete.azulCla};
      case CollectibleType.zodiacLibra:
        return {'name': 'zodiacLibra'.tr(), 'desc': 'zodiacLibraDesc'.tr(), 'icon': MdiIcons.zodiacLibra, 'color': Pallete.azulCla};
      case CollectibleType.zodiacPisces:
        return {'name': 'zodiacPisces'.tr(), 'desc': 'zodiacPiscesDesc'.tr(), 'icon': MdiIcons.zodiacPisces, 'color': Pallete.azulCla};
      case CollectibleType.zodiacSargittarius:
        return {'name': 'zodiacSargittarius'.tr(), 'desc': 'zodiacSargittariusDesc'.tr(), 'icon': MdiIcons.zodiacSagittarius, 'color': Pallete.azulCla};
      case CollectibleType.zodiacScorpio:
        return {'name': 'zodiacScorpio'.tr(), 'desc': 'zodiacScorpioDesc'.tr(), 'icon': MdiIcons.zodiacScorpio, 'color': Pallete.azulCla};
      case CollectibleType.zodiacTaurus:
        return {'name': 'zodiacTaurus'.tr(), 'desc': 'zodiacTaurusDesc'.tr(), 'icon': MdiIcons.zodiacTaurus, 'color': Pallete.azulCla};
      case CollectibleType.zodiacVirgo:
        return {'name': 'zodiacVirgo'.tr(), 'desc': 'zodiacVirgoDesc'.tr(), 'icon': MdiIcons.zodiacVirgo, 'color': Pallete.azulCla};
      case CollectibleType.zodiac:
        return {'name': 'zodiac'.tr(), 'desc': 'zodiacDesc'.tr(), 'icon': MdiIcons.starFourPoints, 'color': Pallete.azulCla};
      case CollectibleType.activeDullRazor:
        return {'name': 'activeDullRazor'.tr(), 'desc': 'activeDullRazorDesc'.tr(), 'icon': MdiIcons.razorDoubleEdge, 'color': Pallete.marrom};
      case CollectibleType.activeBoxSpider:
        return {'name': 'activeBoxSpider'.tr(), 'desc': 'activeBoxSpiderDesc'.tr(), 'icon': MdiIcons.package, 'color': Pallete.azulCla};
      case CollectibleType.activeD10:
        return {'name': 'activeD10'.tr(), 'desc': 'activeD10Desc'.tr(), 'icon': MdiIcons.diceD10, 'color': Pallete.laranja};
      case CollectibleType.activeScroll:
        return {'name': 'activeScroll'.tr(), 'desc': 'activeScrollDesc'.tr(), 'icon': MdiIcons.scriptText, 'color': Pallete.bege};
      case CollectibleType.defensiveFairys:
        return {'name': 'defensiveFairys'.tr(), 'desc': 'defensiveFairysDesc'.tr(), 'icon': MdiIcons.candy, 'color': Pallete.azulCla};
      case CollectibleType.familiarDmgBns:
        return {'name': 'familiarDmgBns'.tr(), 'desc': 'familiarDmgBnsDesc'.tr(), 'icon': MdiIcons.cardAccountDetails, 'color': Pallete.verdeEsc};
      case CollectibleType.familiarMastery:
        return {'name': 'familiarMastery'.tr(), 'desc': 'familiarMasteryDesc'.tr(), 'icon': MdiIcons.license, 'color': Pallete.verdeEsc};
      case CollectibleType.itemExtraBoss:
        return {'name': 'itemExtraBoss'.tr(), 'desc': 'itemExtraBossDesc'.tr(), 'icon': MdiIcons.sack, 'color': Pallete.laranja};
      case CollectibleType.activeGoldenBox:
        return {'name': 'activeGoldenBox'.tr(), 'desc': 'activeGoldenBoxDesc'.tr(), 'icon': MdiIcons.package, 'color': Pallete.laranja};
      case CollectibleType.activeSlot:
        return {'name': 'activeSlot'.tr(), 'desc': 'activeSlotDesc'.tr(), 'icon': MdiIcons.slotMachine, 'color': Pallete.laranja};
      case CollectibleType.activeJarroDeVida:
        return {'name': 'activeJarroDeVida'.tr(), 'desc': 'activeJarroDeVidaDesc'.tr(), 'icon': MdiIcons.flaskRoundBottomEmptyOutline, 'color': Pallete.vermelho};
      case CollectibleType.activePa:
        return {'name': 'activePa'.tr(), 'desc': 'activePaDesc'.tr(), 'icon': MdiIcons.ladder, 'color': Pallete.azulCla};
      case CollectibleType.activeBoxOfFriends:
        return {'name': 'activeBoxOfFriends'.tr(), 'desc': 'activeBoxOfFriendsDesc'.tr(), 'icon': MdiIcons.packageUp, 'color': Pallete.azulCla};
      case CollectibleType.activeDupliItem:
        return {'name': 'activeDupliItem'.tr(), 'desc': 'activeDupliItemDesc'.tr(), 'icon': MdiIcons.romanNumeral2, 'color': Pallete.vinho};
      case CollectibleType.activeJarroFadas:
        return {'name': 'activeJarroFadas'.tr(), 'desc': 'activeJarroFadasDesc'.tr(), 'icon': MdiIcons.flaskRoundBottomEmptyOutline, 'color': Pallete.azulCla};
      case CollectibleType.activeFreezeBomb:
        return {'name': 'activeFreezeBomb'.tr(), 'desc': 'activeFreezeBombDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.azulCla};
      case CollectibleType.activeSuperLaser:
        return {'name': 'activeSuperLaser'.tr(), 'desc': 'activeSuperLaserDesc'.tr(), 'icon': MdiIcons.laserPointer, 'color': Pallete.vinho};
      case CollectibleType.activeBltDetonator:
        return {'name': 'activeBltDetonator'.tr(), 'desc': 'activeBltDetonatorDesc'.tr(), 'icon': MdiIcons.arrowExpandAll, 'color': Pallete.vinho};
      case CollectibleType.activeGoldenrazor:
        return {'name': 'activeGoldenrazor'.tr(), 'desc': 'activeGoldenrazorDesc'.tr(), 'icon': MdiIcons.knifeMilitary, 'color': Pallete.laranja};
      case CollectibleType.activeSacrifFamiliar:
        return {'name': 'activeSacrifFamiliar'.tr(), 'desc': 'activeSacrifFamiliarDesc'.tr(), 'icon': MdiIcons.knifeMilitary, 'color': Pallete.verdeEsc};
      case CollectibleType.activeTurretRotate:
        return {'name': 'activeTurretRotate'.tr(), 'desc': 'activeTurretRotateDesc'.tr(), 'icon': MdiIcons.floorLampTorchiereVariant, 'color': Pallete.azulCla};
      case CollectibleType.activeGlassStaff:
        return {'name': 'activeGlassStaff'.tr(), 'desc': 'activeGlassStaffDesc'.tr(), 'icon': MdiIcons.magicStaff, 'color': Pallete.azulCla};
      case CollectibleType.activeBuracoNegro:
        return {'name': 'activeBuracoNegro'.tr(), 'desc': 'activeBuracoNegroDesc'.tr(), 'icon': MdiIcons.circleOutline, 'color': Pallete.branco};
      case CollectibleType.activeLoja:
        return {'name': 'activeLoja'.tr(), 'desc': 'activeLojaDesc'.tr(), 'icon': MdiIcons.store, 'color': Pallete.branco};
      case CollectibleType.activeRestart:
        return {'name': 'activeRestart'.tr(), 'desc': 'activeRestartDesc'.tr(), 'icon': MdiIcons.alphaRBox, 'color': Pallete.bege};
      case CollectibleType.activeNuke:
        return {'name': 'activeNuke'.tr(), 'desc': 'activeNukeDesc'.tr(), 'icon': MdiIcons.nuke, 'color': Pallete.cinzaCla};
      case CollectibleType.activeKamikaze:
        return {'name': 'activeKamikaze'.tr(), 'desc': 'activeKamikazeDesc'.tr(), 'icon': MdiIcons.nuke, 'color': Pallete.vermelho};
      case CollectibleType.retribuicao:
        return {'name': 'retribuicao'.tr(), 'desc': 'retribuicaoDesc'.tr(), 'icon': MdiIcons.decagram, 'color': Pallete.vermelho};
      case CollectibleType.adagaArremeco:
        return {'name': 'adagaArremeco'.tr(), 'desc': 'adagaArremecoDesc'.tr(), 'icon': MdiIcons.knifeMilitary, 'color': Pallete.cinzaCla};
      case CollectibleType.bloquel:
        return {'name': 'bloquel'.tr(), 'desc': 'bloquelDesc'.tr(), 'icon': MdiIcons.shieldHalfFull, 'color': Pallete.cinzaCla};
      case CollectibleType.glifoEquilibrio:
        return {'name': 'glifoEquilibrio'.tr(), 'desc': 'glifoEquilibrioDesc'.tr(), 'icon': MdiIcons.triangleDownOutline, 'color': Pallete.azulCla};
      case CollectibleType.activeCleaver:
        return {'name': 'activeCleaver'.tr(), 'desc': 'activeCleaverDesc'.tr(), 'icon': MdiIcons.axeBattle, 'color': Pallete.vermelho};
      case CollectibleType.bombaBuracoNegro:
        return {'name': 'bombaBuracoNegro'.tr(), 'desc': 'bombaBuracoNegroDesc'.tr(), 'icon': MdiIcons.bomb, 'color': Pallete.azulEsc};
      case CollectibleType.activeBloodBag:
        return {'name': 'activeBloodBag'.tr(), 'desc': 'activeBloodBagDesc'.tr(), 'icon': MdiIcons.bloodBag, 'color': Pallete.vermelho};
      case CollectibleType.bltFireHazard:
        return {'name': 'bltFireHazard'.tr(), 'desc': 'bltFireHazardDesc'.tr(), 'icon': MdiIcons.fireCircle, 'color': Pallete.vermelho};
      case CollectibleType.trofelCampeao:
        return {'name': 'trofelCampeao'.tr(), 'desc': 'trofelCampeaoDesc'.tr(), 'icon': MdiIcons.trophy, 'color': Pallete.laranja};
      case CollectibleType.bltBuracoNegro:
        return {'name': 'bltBuracoNegro'.tr(), 'desc': 'bltBuracoNegroDesc'.tr(), 'icon': MdiIcons.circleOutline, 'color': Pallete.branco};
      case CollectibleType.bltSparks:
        return {'name': 'bltSparks'.tr(), 'desc': 'bltSparksDesc'.tr(), 'icon': MdiIcons.lightningBolt, 'color': Pallete.azulCla};
      case CollectibleType.familiarLanca:
        return {'name': 'familiarLanca'.tr(), 'desc': 'familiarLancaDesc'.tr(), 'icon': MdiIcons.spear, 'color': Pallete.verdeEsc};
      case CollectibleType.activeWoodenCoin:
        return {'name': 'activeWoodenCoin'.tr(), 'desc': 'activeWoodenCoinDesc'.tr(), 'icon': Icons.monetization_on, 'color': Pallete.marrom};
      case CollectibleType.paralisia:
        return {'name': 'paralisia'.tr(), 'desc': 'paralisiaDesc'.tr(), 'icon': MdiIcons.linkVariant, 'color': Pallete.lilas};
      case CollectibleType.devilInside:
        return {'name': 'devilInside'.tr(), 'desc': 'devilInsideDesc'.tr(), 'icon': MdiIcons.emoticonDevil, 'color': Pallete.vermelho};
      case CollectibleType.rainbowShot:
        return {'name': 'rainbowShot'.tr(), 'desc': 'rainbowShotDesc'.tr(), 'icon': MdiIcons.magicStaff, 'color': Pallete.rosa};
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

  static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {
      return CollectibleLogic.applyEffect(type: type, game: game);
  }

}

List<CollectibleType> _filtrarPool(List<CollectibleType> poolOriginal, Player player) {

  const stackables = [
    CollectibleType.healthContainer, CollectibleType.potionUm, CollectibleType.coinUm,
    CollectibleType.coin, CollectibleType.potion, CollectibleType.key, CollectibleType.bomba
  ];

  poolOriginal.removeWhere((itemType) {

    if (player.itemsExcluidos.contains(itemType)) {
      return true; 
    }

    if (stackables.contains(itemType)) return false; 

    bool temPassiva = player.items.any((adquirido) => adquirido.type == itemType);

    final ativos = player.activeItems.value;
    bool temAtivo0 = ativos[0]?.type == itemType;
    bool temAtivo1 = ativos[1]?.type == itemType;

    return temPassiva || temAtivo0 || temAtivo1;
  });

  return poolOriginal;
}

List<CollectibleType> retornaItensSimples(){
    return [
      CollectibleType.potion,
      CollectibleType.shield,
      CollectibleType.key, 
      CollectibleType.bomba, 
    ];
  }

List<CollectibleType> retornaItensComuns(player){
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
      CollectibleType.rastroFogo,
      CollectibleType.piercing,
      CollectibleType.fogo,
      CollectibleType.veneno,
      CollectibleType.sangramento,
      CollectibleType.chaveNegra,
      CollectibleType.gravitacao,
      CollectibleType.mine,
      CollectibleType.spectral,
      CollectibleType.bounce,
      CollectibleType.cupon,
      CollectibleType.activePoisonBomb,
      CollectibleType.activeHeal,
      CollectibleType.activeBattery,
      CollectibleType.activeArtHp,
      CollectibleType.activeHoming,
      CollectibleType.activeMagicKey,
      CollectibleType.activeRerollItem,
      CollectibleType.activeBandage,
      CollectibleType.activeMidas,
      CollectibleType.goldDmg,
      CollectibleType.activeBombardeioUnico,
      CollectibleType.boloDinheiro,
      CollectibleType.restock,
      CollectibleType.goldShot,
      CollectibleType.primeiroInimigoPocaVeneno,
      CollectibleType.familiarFinger,
      CollectibleType.familiarBouncer,
      CollectibleType.familiarPrisma,
      CollectibleType.familiarRefletor,
      CollectibleType.jumpersCable,
      CollectibleType.activeCircularShots,
      CollectibleType.keysToBombs,
      CollectibleType.activeRandPillUnico,
      CollectibleType.voo,
      CollectibleType.cardinalShot,
      CollectibleType.activeBloodBag,
      CollectibleType.activeDullRazor,
      CollectibleType.activeD10,
      CollectibleType.familiarDmgBns,
      CollectibleType.itemExtraBoss,
      CollectibleType.activeSlot,
      CollectibleType.activeBltDetonator,
      CollectibleType.activeGoldenrazor,
      CollectibleType.activeSacrifFamiliar,
      CollectibleType.activeGlassStaff,
      CollectibleType.activeBuracoNegro,
      CollectibleType.activeLoja,
      CollectibleType.activeCleaver,
      CollectibleType.activeKamikaze,
      CollectibleType.retribuicao,
      CollectibleType.adagaArremeco,
      CollectibleType.bloquel,
      CollectibleType.glifoEquilibrio,
      CollectibleType.bltFireHazard,
      CollectibleType.trofelCampeao,
      CollectibleType.familiarLanca,
      CollectibleType.activeWoodenCoin,
    ];
    
    return _filtrarPool(itens, player);
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
      CollectibleType.sorte,
    ];
  }

  List<CollectibleType> retornaItensRaros(player){
    List<CollectibleType> itRaros =[
      CollectibleType.steroids,
      CollectibleType.cafe,  
      CollectibleType.alcool,
      CollectibleType.soda,
      CollectibleType.conqCrown,
      CollectibleType.berserk,
      CollectibleType.audacious,
      CollectibleType.freeze,
      CollectibleType.magicShield,
      CollectibleType.orbitalShield,
      CollectibleType.foice,
      CollectibleType.revive,
      CollectibleType.antimateria,
      CollectibleType.homing,
      CollectibleType.concentration,
      CollectibleType.defBurst,
      CollectibleType.kinetic,
      CollectibleType.heavyShot,
      CollectibleType.tornado,
      CollectibleType.tripleShot,     
      CollectibleType.activeLicantropia,
      CollectibleType.battery,
      CollectibleType.regenShield,
      CollectibleType.decoy,
      CollectibleType.magicMush,
      CollectibleType.activeMagicKeyChain,
      CollectibleType.splitShot,
      CollectibleType.familiarBlock,
      CollectibleType.familiarAtira,
      CollectibleType.confuseCrit,
      CollectibleType.pregos,
      CollectibleType.bombDecoy,
      CollectibleType.activeDivineShield,
      CollectibleType.activeHeartConverter,
      CollectibleType.activeRitualDagger,
      CollectibleType.activeConvBruta,
      CollectibleType.activeMagicMirror,
      CollectibleType.charmOnCrit,
      CollectibleType.activeUnicorn,
      CollectibleType.activeBombardeio,
      CollectibleType.molotov,
      CollectibleType.laser,
      CollectibleType.wave,
      CollectibleType.pilNanicolina,
      CollectibleType.encolheOnCrit,
      CollectibleType.retaliar , 
      CollectibleType.familiarFreeze , 
      CollectibleType.familiarGlitch,
      CollectibleType.familiarDmgBuff,
      CollectibleType.familiarCircProt,
      CollectibleType.glitterBomb,
      CollectibleType.clusterShot,
      CollectibleType.evasao,
      CollectibleType.familiarEye,
      CollectibleType.adrenalina,
      CollectibleType.eutanasia,
      CollectibleType.goldHeart,
      CollectibleType.activeRandPill,
      CollectibleType.portalBoss,
      CollectibleType.noveVidas,
      CollectibleType.activePacmen,
      CollectibleType.hurtPac,
      CollectibleType.zodiacAquarius,
      CollectibleType.zodiacAries,
      CollectibleType.zodiacCancer,
      CollectibleType.zodiacCapricorn,
      CollectibleType.zodiacGemini,
      CollectibleType.zodiacLeo,
      CollectibleType.zodiacLibra,
      CollectibleType.zodiacPisces,
      CollectibleType.zodiacSargittarius,
      CollectibleType.zodiacScorpio,
      CollectibleType.zodiacTaurus,
      CollectibleType.zodiacVirgo,
      CollectibleType.zodiac,
      CollectibleType.familiarMastery,
      CollectibleType.activeScroll,
      CollectibleType.activeGoldenBox,
      CollectibleType.activeJarroDeVida,
      CollectibleType.activePa,
      CollectibleType.activeBoxOfFriends,
      CollectibleType.activeDupliItem,
      CollectibleType.activeJarroFadas,
      CollectibleType.activeSuperLaser,
      CollectibleType.bombaBuracoNegro,
      CollectibleType.activeNuke,
      CollectibleType.bltBuracoNegro,
      CollectibleType.bltSparks,
      CollectibleType.paralisia,
      CollectibleType.devilInside,
      CollectibleType.rainbowShot,
    ];
    return _filtrarPool(itRaros, player);
  }

class CollectibleLogic {
   static Map<String, dynamic> applyEffect({required CollectibleType type, required TowerGame game}) {

       String text = "";
       final player = game.player;
      AudioManager.playSfx('collect.mp3');
       switch (type) {
         case CollectibleType.coin:
          int c = Random().nextInt(20)+5;
          player.collectCoin(c);
          text = "+ $c\$ ";
          //color = Pallete.amarelo;
          break;

         case CollectibleType.coinUm:
          player.collectCoin(1);
          text = "+ 1\$ ";
          //color = Pallete.amarelo;
          break;

         case CollectibleType.souls:
          game.progress.soulsNotifier.value += 1000;
          text = "alma";
          //color = Pallete.amarelo;
          break;
          
        case CollectibleType.potion:
          if (player.healthNotifier.value < player.maxHealth) {
            player.curaHp(2);
            text = "${"Curado".tr()}!";
            //color = Pallete.vermelho; 
          } else {
            if (player.activeItems.value[0]!.type == CollectibleType.activeJarroDeVida && player.vidasNoJarro < 4) {
              player.vidasNoJarro++; // Guarda a vida no jarro
      
              game.world.add(FloatingText(
                text: "${player.vidasNoJarro}/4",
                position: player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.vermelho,
              ));
        
            }
            text = "${"Cheio".tr()}!";
            //color = Pallete.cinzaCla;
          }
          break;

        case CollectibleType.sanduiche:
        if (player.healthNotifier.value >= player.maxHealth 
          && player.artificialHealthNotifier.value >= player.maxArtificialHealth) {
            return {
              'text': "Vida Cheia!", 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
            player.curaHp(6); 
            text = "${"Curado".tr()}!";
            //color = Pallete.vermelho; 
          
          break;  
          
        case CollectibleType.key:
          int k = Random().nextInt(2)+1;
          game.keysNotifier.value += k;
          text = "${"$k Key(s)"}!";
          //color = Pallete.branco; 
          break;

        case CollectibleType.keys:
          game.keysNotifier.value+=10;
          text = "${"10 Keys".tr()}!";
          //color = Pallete.branco; 
          break;
        
        case CollectibleType.bomba:
          int b = Random().nextInt(2)+1;
          player.bombNotifier.value += b;
          text = "${"$b Bombs(s)".tr()}!";
          //color = Pallete.branco; 
          break;

        case CollectibleType.bombas:
          player.bombNotifier.value+=10;
          text = "${"10 Bombs".tr()}!";
          //color = Pallete.branco; 
          break;

        case CollectibleType.damage:
          player.increaseDamage(1.2);
          text = "${"+ Damage".tr()}!";
          //color = Pallete.branco; 
          break;

        case CollectibleType.sorte:
          player.sorte ++;
          text = "${"sorte".tr()}!";
          //color = Pallete.branco; 
          break;

        case CollectibleType.dot:
          player.dot += 0.2;
          text = "${"+ Dot".tr()}!";
          //color = Pallete.branco;
          break;
          
        case CollectibleType.fireRate:
          player.increaseFireRate(0.85);
          text = "${"+ Fire Rate".tr()}!";
          //color = Pallete.azulCla; 
          break;
          
        case CollectibleType.moveSpeed:
          player.increaseMovementSpeed(1.2);
          text = "${"+ Speed".tr()}!";
         // color = Pallete.azulCla;
          break;
        
        case CollectibleType.range:
          player.increaseRange(1.15);
          text = "${"+ Range".tr()}!";
          //color = Pallete.azulCla;
          break;
        
        case CollectibleType.shield:
          player.increaseShield();
          text = "${"+ Shield".tr()}!";
          //color = Pallete.azulCla;
          break;

        case CollectibleType.healthContainer:
          player.increaseHp(2);
          text = "${"+ Max HP".tr()}!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.dash:
          player.increaseDash();
          text = "${"+ Dash".tr()}!";
          //color = Pallete.vermelho;
          break; 
        
        case CollectibleType.berserk:
          player.isBerserk = true;
          text = "+ 40% Damage when low HP";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.audacious:
          player.isAudaz = true;
          text = "+ 33% Damage when no shield";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.alcool:
          player.isBebado = true;
          text = "+ 33% Damage, shots don't go straight";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.steroids:
          player.damage *= 1.4;
          player.maxHealth -=2;
          player.healthNotifier.value = min(player.healthNotifier.value,player.maxHealth) ;
          text = "+ 40% Damage, but 1 less Health";
          //color = Pallete.vermelho;
          break;
        
        case CollectibleType.cafe:
          player.damage *= 0.3;
          player.fireRate /= 3;
          text = "+ 200% Fire rate, but 70% less damage";
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
          text = "Escudos Orbitais";
         // color = Pallete.azulCla;
          break;

        case CollectibleType.foice:
          game.world.add(OrbitalShield(angleOffset: 0, owner: player, isFoice: true, radius: player.size.y, speed:5));
          game.world.add(OrbitalShield(angleOffset: 2*pi/3, owner: player, isFoice: true, radius: player.size.y, speed:5));
          game.world.add(OrbitalShield(angleOffset: 4*pi/3, owner: player, isFoice: true, radius: player.size.y, speed:5));
          text = "Foices Orbitais";
         // color = Pallete.azulCla;
          break;  

        case CollectibleType.flail:
          game.world.add(OrbitalShield(angleOffset: 0, owner: player, isFlail: true, radius: player.size.y*3, speed:10));
          text = "Flail Orbitais";
         // color = Pallete.azulCla;
          break; 

        case CollectibleType.revive:
          player.revive += 1;
          if(player.reviveIcon == null){
            player.numIcons ++;
            player.reviveIcon = GameIcon(
              icon: MdiIcons.cross,
              color: Pallete.amarelo,
              size: player.size/2,
              anchor: Anchor.center,
              position: Vector2(player.size.x / 2, - player.size.y / 4 - 14*player.numIcons), 
            );
            player.add(player.reviveIcon!);
          }
          
          if (player.reviveText == null){
            player.reviveText = TextComponent(
              text: player.revive.toString(),
              position: Vector2((player.size.x/2) - 12, - player.size.y / 4 - 14*player.numIcons),
              anchor: Anchor.center,
              textRenderer: TextPaint(
                style: const TextStyle(
                  color: Pallete.amarelo,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            player.add(player.reviveText!);
          }
          player.reviveText?.text = player.revive.toString();
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
          text = "${"Piercing Shot".tr()}!";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.homing:
          player.isHoming = true;
          text = "${"Homing Shot".tr()}!";
          //color = Pallete.vermelho;
          break;  
        
        case CollectibleType.fogo:
          player.isBurn = true;
          text = "Fire Shot";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.veneno:
          player.isPoison = true;
          text = "Poison Shot";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.sangramento:
          player.isBleed = true;
          text = "Bleed Shot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.druidScroll:
          player.dot *= 2;
          player.damage *= 0.6;
          text = "Druid's Scroll: Dot Doubled";
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
          text = "Chave Negra";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.concentration:
          player.isConcentration = true;
          text = "Concentration";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.gravitacao:
          player.isOrbitalShot = true;
          player.fireRate *= 0.5;
          text = "Gravitation";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.soda:
          player.increaseMovementSpeed(2);
          text = "Gravitation";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.mine:
          player.isMineShot = true;
          text = "Mine Shot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bloodstone:
          player.stackBonus += 5;
          text = "Bloodstone Bonus";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bounce:
          player.canBounce = true;
          text = "Bounce Shot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.spectral:
          player.isSpectral = true;
          text = "Spectral Shot";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.defBurst:
          player.defensiveBurst = true;
          text = "Defensive Burst";
          //color = Pallete.vermelho;
          break;
  
        case CollectibleType.kinetic:
          player.isKinetic = true;
          text = "Kinetico";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.heavyShot:
          player.isHeavyShot = true;
          player.bltSize += 20;
          text = "Heavy Shot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.cupon:
          player.hasCupon = true;

          if(player.cuponIcon == null){
            player.numIcons ++;
            player.cuponIcon = GameIcon(
              icon: MdiIcons.ticketPercent,
              color: Pallete.bege,
              size: player.size/2,
              anchor: Anchor.center,
              position: Vector2(player.size.x / 2, - player.size.y / 4 - 10*player.numIcons), 
            );
            player.add(player.cuponIcon!);
          }

          text = "Cupom de Desconto";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.conqCrown:
          player.invincibilityDuration += 0.5;
          player.dashCooldown *= 0.75;
          text = "Coroa de Conquista";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bumerangue:
          player.isBoomerang = true;
          text = "Bumerangue";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.pocaVeneno:
          player.criaPocaVeneno = true;
          text = "poça veneno";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.rastroFogo:
          player.fireDash = true;
          text = "rastroFogo";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.tornado:
          player.isDashDamages = true;
          player.dashDuration *= 1.5;
          text = "tornado";
          //color = Pallete.vermelho;
          break;  
        
        case CollectibleType.tripleShot:
          player.tripleShot = true;
          player.increaseFireRate(1.4);
          text = "tripleShot";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeHeal:
          if (player.healthNotifier.value >= player.maxHealth 
          && player.artificialHealthNotifier.value >= player.maxArtificialHealth) {
            return {
              'text': "Vida Cheia!", 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.curaHp(2);
          text = "activeHeal";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activePoisonBomb:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            damage:player.damage * 3, 
            radius:100));
          game.world.add(PoisonPuddle(
            position: player.position.clone(),
            isPlayer: true,
            duration: 5.0,
            size: Vector2.all(100)
          ));
          text = "activePoisonBomb";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeLicantropia:
          player.ativaLicantropia();
          text = "activeLicantropia";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeBattery:
          player.rechargeActiveItem(full: true);
          text = "activeBattery";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.battery:
          player.hasBattery = true;
          final currentItems = List<ActiveItemData?>.from(player.activeItems.value);
          if (currentItems[0] != null){
            print('tem item');
            if(currentItems[0]!.maxCharge == 1){
              print('tem item custo 1');
              currentItems[0]!.currentCharge = 0;
              currentItems[0]!.maxCharge = 0;
              player.rechargeActiveItem(full: true);
            }
          }
          text = "battery";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.regenShield:
          player.hasShieldRegen = true;
          text = "regenShield";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeArtHp:
          player.increaseArtificialHp(6);
          text = "activeArtHp";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.decoy:
          //if (player.activeDecoy == null) {
            final decoy = Familiar(position: player.position.clone(),type: FamiliarType.decoy, followDistance: 120, player: player);
            player.familiars.add(decoy);
            game.world.add(decoy);
         // }
          text = "Decoy Ativado";
          break;

        case CollectibleType.magicMush:
          player.changeSize(2);
          player.increaseDamage(1.2);
          player.increaseHp(2);
          player.increaseRange(1.2);
          player.increaseMovementSpeed(1.2);
          player.increaseFireRate(0.8);
          text = "GROWS";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeMagicKey:
          game.roomManager.reloadDoors();
          text = "magickey";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeMagicKeyChain:
          game.roomManager.reloadDoors();
          text = "magickeychain";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeHoming:
          player.isHomingTemp = true;
          text = "activeHoming";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeGift:
          final int rng = Random().nextInt(6);
          String txt = '';
          switch(rng){
            case 0:
              player.curaHp(2);
              txt = 'Cura!';
              break;  
            case 1:
              player.increaseShield();
              txt = 'Escudo!';
              break;
            case 2:
              game.keysNotifier.value += 1;
              txt = 'Chave!';
              break;
            case 3:
              player.bombNotifier.value += 1;
              txt = 'Bomba!';
              break;
            case 4:
              final int c = Random().nextInt(20)+5;
              player.collectCoin(c);
              txt = 'Moedas!';
              break;
            case 5:
              game.progress.addSouls(50);
              game.soulsTotal += 50;
              txt = 'Almas!';
              break;
          }
          text = txt;
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeD6:
          game.nextLevel(game.nextRoomReward,mesmaSala:true);
          text = "activeHoming";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.splitShot:
          player.isShootSplits = true;
          text = "splitShot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarBlock:
          //if (player.activeDecoy == null) {
            final block = Familiar(position: player.position.clone(),
                                  type: FamiliarType.block, 
                                  player: player,
                                  followDistance: 25
                                  );
            player.familiars.add(block);
            game.world.add(block);
         // }
          text = "Decoy Ativado";
          break;

        case CollectibleType.familiarAtira:
          //if (player.activeDecoy == null) {
            final atira = Familiar(position: player.position.clone(),
                                  type: FamiliarType.atira, 
                                  player: player,
                                  followDistance: 5
                                  );
            player.familiars.add(atira);
            game.world.add(atira);
         // }
          text = "familiarAtira";
          break;

        case CollectibleType.confuseCrit:
          player.confuseOnCrit = true;
          text = "confuseOnCrit";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.pregos:
          player.isBombSplits = true;
          text = "pregos";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.bombDecoy:
          player.isBombDecoy = true;
          player.bombNotifier.value += 5;
          text = "bombDecoy";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeHeartConverter:
          if (player.maxHealth < 2) {
            return {
              'text': "noHp".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.increaseArtificialHp(6);
          player.increaseHp(-2);
          text = "activeHeartConverter";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeDivineShield:
          player.setInvencibility(10);
          text = "activeDivineShield";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeRerollItem:
          bool rolouAlgo = false;

          final itensNoChao = game.world.children.whereType<Collectible>().toList();

          final naoRolar = [
            CollectibleType.coin, CollectibleType.potion,
            CollectibleType.key, CollectibleType.keys, CollectibleType.bomba, 
            CollectibleType.bombas, CollectibleType.chest, CollectibleType.rareChest, 
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextlevel, 
            CollectibleType.shop, CollectibleType.boss, CollectibleType.healthContainer,
            CollectibleType.darkShop, CollectibleType.desafio
          ];

          final poolRaros = retornaItensRaros(player);

          final pool = retornaItensComuns(player);

          for (var item in itensNoChao) {
            if (!naoRolar.contains(item.type) && item.custo==0 && item.custoBombs==0 && item.custoKeys==0) {
              if (pool.isNotEmpty) {
                CollectibleType novoTipo;
                if (poolRaros.contains(item.type)) {
                  novoTipo = poolRaros[Random().nextInt(poolRaros.length)];
                  print('item raro');
                }else{
                  novoTipo = pool[Random().nextInt(pool.length)];
                  print('item comum');
                }
                Vector2 pos = item.position.clone();
                
                item.removeFromParent();
                
                game.world.add(Collectible(position: pos, type: novoTipo));
                
                
                createExplosionEffect(game.world, pos, Pallete.lilas, count: 15);
                
                rolouAlgo = true;
              }
            }
          }

          text = rolouAlgo ? "Destino Alterado!" : "Nada para mudar";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeRitualDagger:
          if (player.healthNotifier.value < 1) {
            return {
              'text': "noHp".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.takeDamage(1);
          player.tempDmgBonus ++ ;

          if(player.dmgBuffIcon == null){
            player.numIcons ++;
            player.dmgBuffIcon = GameIcon(
              icon: MdiIcons.knifeMilitary,
              color: Pallete.vermelho,
              size: player.size/2,
              anchor: Anchor.center,
              position: Vector2(player.size.x / 2, - player.size.y / 4 - 14*player.numIcons), 
            );
            player.add(player.dmgBuffIcon!);
          }
        
          text = "${"activeRitualDagger".tr()}!";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeBandage:
          player.regenCount = 4;
          text = "activeBandage";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeConvBruta:
          final itensNoChao = game.world.children.whereType<Collectible>().toList();

          final naoRolar = [
            CollectibleType.coin, CollectibleType.potion,
            CollectibleType.key, CollectibleType.keys, CollectibleType.bomba, 
            CollectibleType.bombas, CollectibleType.chest, CollectibleType.rareChest, 
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextlevel, 
            CollectibleType.shop, CollectibleType.boss, CollectibleType.healthContainer,
            CollectibleType.darkShop, CollectibleType.desafio
          ];

          for (var item in itensNoChao) {
              if (!naoRolar.contains(item.type) && item.custo==0 && item.custoBombs==0 && item.custoKeys==0) {
                Vector2 pos = item.position.clone();
                item.removeFromParent();
                game.world.add(Collectible(position: pos, type: CollectibleType.damage)); 
                createExplosionEffect(game.world, pos, Pallete.lilas, count: 15);
            }
          }
          text = "activeConvBruta";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeMagicMirror:
          final ativos = player.activeItems.value;
          
          final itemUsoUnico = ativos[1]; 

          if (itemUsoUnico != null) {
             final feedback = CollectibleLogic.applyEffect(type: itemUsoUnico.type, game: game);
             // SUCESSO! Dá um 'return' direto aqui para sair da função agora mesmo.
             return {'text': "Copiou: ${feedback['text'].tr()}", 'color': Pallete.branco, 'sucesso': true}; 
           } else {
             // FALHOU! Dá um 'return' direto dizendo que deu erro.
             return {'text': "Nada para copiar!", 'color': Pallete.branco, 'sucesso': false};
           }

        case CollectibleType.charmOnCrit:
          player.charmOnCrit = true;
          text = "charmOnCrit";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeMidas:
          if(game.progress.soulsNotifier.value >= 1000)
          {
            game.progress.spendSouls(1000);
            player.collectCoin(50);
            text = "activeMidas";
            return {'text': "activeMidas!", 'color': Pallete.branco, 'sucesso': true}; 
          }else{
            return {'text': "Almas Insuficiente!", 'color': Pallete.branco, 'sucesso': false};
          }

        case CollectibleType.freezeDash:
          player.increaseDash(-1);
          player.isFreezeDash = true;
          text = "freezeDash";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.goldDmg:
          player.goldDmg = true;
          text = "goldDmg";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeStunBomb:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            isStun: true, 
            radius:100,
            cor:Pallete.laranja.withAlpha(50),
            corBorda:Pallete.marrom.withAlpha(50)
          ));
          text = "activeStunBomb";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeFairy:
          for(var i = 0; i < 5; i++){
            final f = Familiar(position: player.position.clone(),
                                type: FamiliarType.fly, 
                                player: player,
                                angleOffset: i*(2*pi/5)
                              );
            player.familiars.add(f);
            game.world.add(f);
          }
          text = "activeFairy";
          break;

        case CollectibleType.activeUnicorn:
          player.ativaUnicorn() ;
          text = "activeUnicorn";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeUnicornUnico:
          player.ativaUnicorn() ;
          text = "activeUnicornUnico";
          //color = Pallete.vermelho;
          break; 
          
        case CollectibleType.activeBombardeio:
          game.world.add(BombardmentEffect(
            totalExplosions: 12,           
            interval: 0.2,                 
            damage: player.damage * 5,
          ));
          text = "activeBombardeio";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeBombardeioUnico:
          game.world.add(BombardmentEffect(
            totalExplosions: 12,           
            interval: 0.2,                 
            damage: player.damage * 5,
          ));
          text = "activeBombardeio";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.curaCrit:
          player.isCritHeal = true;
          text = "curaCrit";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.molotov:
          player.isMorteiro = true;
          player.increaseFireRate(2);
          text = "molotov";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.laser:
          player.isLaser = true;
          text = "laser";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.wave:
          player.isWave = true;
          text = "wave";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.activeSuborno:
         // if (game.coinsNotifier.value < 15) break;
         if (game.coinsNotifier.value < 15) {
            return {
              'text': "noCoins".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.collectCoin(-15);
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            isCharm: true, 
            radius:100,
            cor:Pallete.verdeCla.withAlpha(50),
            corBorda:Pallete.verdeEsc.withAlpha(50)
          ));
          text = "Suborno";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.activeTurret:
          final f = Familiar(position: player.position.clone(),
                                type: FamiliarType.turret, 
                                player: player,
                                retorna: false,
                                speed: 0,
                                fireRate: 0.5
                              );
          player.familiars.add(f);
          game.world.add(f);
          text = "Turret";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeTurretUnico:
          final f = Familiar(position: player.position.clone(),
                                type: FamiliarType.turret, 
                                player: player,
                                retorna: false,
                                speed: 0,
                                fireRate: 0.5
                              );
          player.familiars.add(f);
          game.world.add(f);
          text = "Turret";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.pilNanicolina:
          player.changeSize(0.75);
          player.increaseDamage(0.8);
          player.increaseRange(0.8);
          player.increaseMovementSpeed(1.2);
          text = "SHRINK";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.saw:
          player.isSaw = true;
          player.increaseDamage(1.2);
          text = "saw";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.boloDinheiro:
          player.collectCoin(50);
          text = "CASH";
          //color = Pallete.vermelho;
          break;   

        case CollectibleType.retaliar:
          player.explodeHit = true ;
          text = "retaliar";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.restock:
          player.restock = true ;
          text = "restock";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarFreeze:
          //if (player.activeDecoy == null) {
            final freeze = Familiar(position: player.position.clone(),
                                  type: FamiliarType.freeze, 
                                  player: player,
                                  radius: 100, 
                                  followDistance: 25

                                  );
            player.familiars.add(freeze);
            game.world.add(freeze);
         // }
          text = "familiarFreeze";
          break;

        case CollectibleType.encolheOnCrit:
          player.encolheOnCrit = true ;
          text = "encolheOnCrit";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarGlitch:
          //if (player.activeDecoy == null) {
            final glitch = Familiar(position: player.position.clone(),
                                  type: FamiliarType.glitch, 
                                  player: player,
                                  );
            player.familiars.add(glitch);
            game.world.add(glitch);
         // }
          text = "familiarGlitch";
          break;

        case CollectibleType.familiarDmgBuff:
          //if (player.activeDecoy == null) {
            final glitch = Familiar(position: player.position.clone(),
                                  type: FamiliarType.dmgBuff, 
                                  player: player,
                                  speed:0
                                  );
            player.familiars.add(glitch);
            game.world.add(glitch);
         // }
          text = "familiarDmgBuff";
          break;
        
        case CollectibleType.familiarCircProt:
          //if (player.activeDecoy == null) {
            final circProt = Familiar(position: player.position.clone(),
                                  type: FamiliarType.circProt, 
                                  player: player,
                                  );
            player.familiars.add(circProt);
            game.world.add(circProt);
         // }
          text = "familiarCircProt";
          break;

        case CollectibleType.glitterBomb:
          player.isGlitterBomb = true ;
          player.bombNotifier.value += 5;
          text = "glitterBomb";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.goldShot:
          player.goldShot = true ;
          text = "goldShot";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.clusterShot:
          player.clusterShot = 0 ;
          text = "clusterShot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.evasao:
          player.evasao = true ;
          text = "evasao";
          //color = Pallete.vermelho;
          break;
        
        case CollectibleType.primeiroInimigoPocaVeneno:
          player.primeiroInimigoPocaVeneno = true ;
          text = "primeiroInimigoPocaVeneno";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarFinger:
          //if (player.activeDecoy == null) {
            final finger = Familiar(position: player.position.clone(),
                                  type: FamiliarType.finger, 
                                  player: player,
                                  );
            player.familiars.add(finger);
            game.world.add(finger);
         // }
          text = "finger";
          break;

        case CollectibleType.familiarBouncer:
          //if (player.activeDecoy == null) {
            final bouncer = Familiar(position: player.position.clone(),
                                  type: FamiliarType.bouncer, 
                                  player: player,
                                  );
            player.familiars.add(bouncer);
            game.world.add(bouncer);
         // }
          text = "bouncer";
          break;

        case CollectibleType.familiarEye:
          //if (player.activeDecoy == null) {
            final eye = Familiar(position: player.position.clone(),
                                  type: FamiliarType.eye, 
                                  player: player,
                                  );
            player.familiars.add(eye);
            game.world.add(eye);
         // }
          text = "eye";
          break;

        case CollectibleType.adrenalina:
          player.adrenalina = true ;
          text = "adrenalina";
          //color = Pallete.vermelho;
          break;
        
        case CollectibleType.eutanasia:
          player.eutanasia = true ;
          text = "eutanasia";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.goldHeart:
          int v = (game.coinsNotifier.value / 25 ).floor()*2;
          player.increaseHp(v);
          text = "goldHeart";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarPrisma:
          //if (player.activeDecoy == null) {
            final prisma = Familiar(position: player.position.clone(),
                                  type: FamiliarType.prisma, 
                                  player: player,
                                  );
            player.familiars.add(prisma);
            game.world.add(prisma);
         // }
          text = "prisma";
          break;

        case CollectibleType.familiarRefletor:
          //if (player.activeDecoy == null) {
            final refletor = Familiar(position: player.position.clone(),
                                  type: FamiliarType.refletor, 
                                  player: player,
                                  );
            player.familiars.add(refletor);
            game.world.add(refletor);
         // }
          text = "refletor";
          break;  

        case CollectibleType.jumpersCable:
          player.killCharge = 0 ;
          text = "jumpersCable";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeCircularShots:
          for (int i = 0; i < 16; i++) {
            double angle = (i * (2 * pi / 16));
            Vector2 direction = Vector2(cos(angle), sin(angle));

            game.world.add(Projectile(
              owner: player,
              position: player.position.clone(), 
              direction: direction.clone(), 
              damage: player.noDamage? 0 : player.returnDamage(), 
              speed: player.isOrbitalShot ? 4.0 : player.isHeavyShot ? 250 : player.isWave ? 350 : player.isSaw ? 50 : 500,
              size: player.isHeavyShot ? Vector2.all(30) : Vector2.all(10),
              dieTimer: player.isBoomerang ? 1.0 : player.isOrbitalShot ? 2 : player.isSaw ? player.attackRange*1.5 : player.attackRange,
              apagaTiros: player.hasAntimateria,
              isHoming: player.isHoming || player.isHomingTemp,
              iniPosition: player.position.clone(),
              canBounce: player.canBounce,
              isSpectral: player.isSpectral,
              isPiercing: player.isPiercing,
              isBoomerang: player.isBoomerang,
              splits: player.isShootSplits,
              splitCount: Random().nextInt(3) + 1,
              goldShot:player. goldShot,
              isWave: player.isWave,         // <-- Transforma em onda!
              maxRadius: 150,       // <-- Tamanho máximo
              growthRate: 100,      // <-- Velocidade de expansão
              sweepAngle: pi / 1.5, // <-- Quase um semicírculo de largura!
              isSaw: player.isSaw,
            ));
          }

        case CollectibleType.keysToBombs:
          int bombs = (player.bombNotifier.value * 1.5).floor();
          int keys = (game.keysNotifier.value * 1.5).floor() ;

          player.bombNotifier.value = keys;
          game.keysNotifier.value = bombs;
          
          text = "keysToBombs".tr();
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.activeRandPill:
          String txt = '';
          int rnd = Random().nextInt(8);

          switch(rnd){
            case 0:
              player.increaseDamage(1.2);
              txt = 'dano';
              break;
            case 1:
              player.increaseFireRate(0.8);
              txt = 'taxa de tiro';
              break;
            case 2:
              player.increaseMovementSpeed(1.2);
              txt = 'velocidade';
              break;
            case 3:
              player.increaseRange(1.2);
              txt = 'alcançe';
              break;
            case 4:
              player.critChance += 5;
              txt = 'chance crítica';
              break;
            case 5:
              player.critDamage *= 1.15;
              txt = 'dano crítico';
              break;
            case 6:
              player.increaseHp(2);
              txt = 'HP';
              break;
            case 7:
              player.dot *= 1.5;
              txt = 'dano por tempo';
              break;
          }
          text = txt;
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeRandPillUnico:
          String txt = '';
          int rnd = Random().nextInt(8);

          switch(rnd){
            case 0:
              player.increaseDamage(1.2);
              txt = 'dano';
              break;
            case 1:
              player.increaseFireRate(0.8);
              txt = 'taxa de tiro';
              break;
            case 2:
              player.increaseMovementSpeed(1.2);
              txt = 'velocidade';
              break;
            case 3:
              player.increaseRange(1.2);
              txt = 'alcançe';
              break;
            case 4:
              player.critChance += 5;
              txt = 'chance crítica';
              break;
            case 5:
              player.critDamage *= 1.15;
              txt = 'dano crítico';
              break;
            case 6:
              player.increaseHp(2);
              txt = 'HP';
              break;
            case 7:
              player.dot *= 1.5;
              txt = 'dano por tempo';
              break;
          }

          text = txt;
          //color = Pallete.vermelho;
          break;

        case CollectibleType.portalBoss:
          game.transitionEffect.startTransition(() async {   
          game.currentRoomNotifier.value = 10;
          
          final coisasParaApagar = game.world.children.where((component) {
              return component.runtimeType.toString() == 'Enemy' ||
                      component.runtimeType.toString() == 'Door' ||
                      component.runtimeType.toString() == 'Collectible' ||
                      component.runtimeType.toString() == 'Projectile' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'Wall' ||
                      component.runtimeType.toString() == 'PoisonPuddle' ||
                      component.runtimeType.toString() == 'Chest' ||
                      component.runtimeType.toString() == 'BloodMachine' ||
                      component.runtimeType.toString() == 'SlotMachine' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'LaserBeam';
                      
            });
          
          game.world.removeAll(coisasParaApagar);
          game.overlays.add('HUD');

          game.nextRoomReward = CollectibleType.boss;
            game.startLevel(salaAtual:false ,sala: 10); 

          player.position = Vector2(0, 250); 
        });
          
          text = "TO BOSS".tr();
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeFear:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            isFear: true, 
            radius:150,
            cor:Pallete.vermelho.withAlpha(50),
            corBorda:Pallete.vinho.withAlpha(50)
          ));
          text = "FEAR";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeDiarreiaExplosiva:
          player.bombTimer = 5.0; 
          var tmrC=TimerComponent(
            period: 0.5,
            repeat: true,
            onTick: () {
              player.criaBomba(semCusto:true);
          });
          player.bombTmr = tmrC;
          game.world.add(tmrC);
          text = "activeDiarreiaExplosiva".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarDummy:
          //if (player.activeDecoy == null) {
            final refletor = Familiar(position: player.position.clone(),
                                  type: FamiliarType.dummy, 
                                  player: player,
                                  );
            player.familiars.add(refletor);
            game.world.add(refletor);
         // }
          text = "refletor";
          break; 

        case CollectibleType.voo:
          player.voo = true ;
          player.criaVisual(reset : true);
          text = "voo";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.cardinalShot:
          player.cardinalShot = true ;
          text = "cardinalShot";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.noveVidas:
          player.revive += 9;
          player.maxHealth = 2;
          player.healthNotifier.value = min(player.maxHealth,player.healthNotifier.value);

          if(player.reviveIcon == null){
            player.numIcons ++;
            player.reviveIcon = GameIcon(
              icon: MdiIcons.cross,
              color: Pallete.amarelo,
              size: player.size/2,
              anchor: Anchor.center,
              position: Vector2(player.size.x / 2, - player.size.y / 4 - 14*player.numIcons), 
            );
            player.add(player.reviveIcon!);
          }

          if (player.reviveText == null){
            player.reviveText = TextComponent(
              text: player.revive.toString(),
              position: Vector2((player.size.x/2) - 12, - player.size.y / 4 - 14*player.numIcons),
              anchor: Anchor.center,
              textRenderer: TextPaint(
                style: const TextStyle(
                  color: Pallete.amarelo,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
            player.add(player.reviveText!);
          }
          player.reviveText?.text = player.revive.toString();
          text = "noveVidas";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activePacmen:
          if (player.isPac) {
            return {
              'text': "PAC PAC PAC!", 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.ativaPacmen();
          text = "activePacmen";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.hurtPac:
          player.hurtPac = true;
          text = "hurtPac";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeBloodBag:
          player.takeDamage(1,pulaEscudo:true);
          int c = Random().nextInt(20)+5;
          player.collectCoin(c);
          text = "+ $c\$ ";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacAquarius:
          player.zodiacAquarius = true;
          text = "zodiacAquarius";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacAries:
          player.zodiacAries = true;
          text = "zodiacAries";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacCancer:
          player.zodiacCancer = true;
          player.increaseArtificialHp(6);
          text = "zodiacCancer";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacCapricorn:
          player.increaseHp(2);
          player.increaseDamage(1.2);
          player.increaseMovementSpeed(1.1);
          player.increaseFireRate(0.85);
          player.increaseRange(1.2);
          player.collectCoin(10);
          player.bombNotifier.value ++;
          game.keysNotifier.value ++;

          text = "zodiacCapricorn";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacGemini:
          //if (player.activeDecoy == null) {
            final gemini = Familiar(position: player.position.clone(),
                                  type: FamiliarType.gemini, 
                                  player: player,
                                  );
            player.familiars.add(gemini);
            game.world.add(gemini);
         // }
          text = "zodiacGemini";
          break; 

        case CollectibleType.zodiacLeo:
          player.zodiacLeo = true;
          text = "zodiacLeo";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacLibra:
          player.zodiacLibra = true;
          //player.applyLibraBalance();
          player.collectCoin(20);
          player.bombNotifier.value += 6;
          game.keysNotifier.value += 6;
          text = "zodiacLibra";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacPisces:
          player.zodiacPisces = true;
          player.bltSize *= 1.25;
          player.increaseFireRate(0.8);
          text = "zodiacPisces";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacSargittarius:
          player.isPiercing = true;
          player.increaseMovementSpeed(1.2);
          text = "zodiacSargittarius";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacScorpio:
          player.isPoison = true;
          player.isPoisonAlastra;
          text = "zodiacScorpio";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacTaurus:
          player.zodiacTaurus = true;
          player.increaseMovementSpeed(0.7);
          text = "zodiacTaurus";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiacVirgo:
          player.zodiacVirgo = true;
          text = "zodiacVirgo";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.zodiac:
          player.zodiac = true;
          text = "zodiac";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeDullRazor:
          player.takeDamage(0);
          text = "ai".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeBoxSpider:
          //if (player.activeDecoy == null) {
          int rnd = Random().nextInt(4) + 1;

          for(var i=0;i<rnd;i++){
            final aranha = Familiar(position: player.position.clone(),
                                type: FamiliarType.aranha, 
                                player: player,
                                retorna: false,
                                );
          player.familiars.add(aranha);
          game.world.add(aranha);
          }
          
         // }
          text = "boxOfSpiders";
          break; 

        case CollectibleType.activeD10:
          game.roomManager.rerollEnemies();
          text = "REROLL".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeScroll:
          player.useRandomActiveItem();
          text = "activeScroll".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.defensiveFairys:
          player.defensiveFairys = true;
          text = "defensiveFairys".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarDmgBns:
          player.familiarDmg += 0.2;
          text = "familiarDmgBns".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.familiarMastery:
          player.familiarDmg += 0.7;
          player.increaseDamage(0.7);
          text = "familiarMastery".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.itemExtraBoss:
          player.itemExtraBoss = true;
          text = "itemExtraBoss".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeGoldenBox:
          if(game.coinsNotifier.value < 10){
            return {
              'text': "noCoins".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            player.collectCoin(-10);
            game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            damage:player.damage * 2, 
            radius:400,
            cor: Pallete.amarelo.withAlpha(50),
            corBorda: Pallete.laranja.withAlpha(50)
            ));
          }
          text = "activeGoldenBox".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeSlot:
          if(game.coinsNotifier.value < 5){
            return {
              'text': "noCoins".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            player.collectCoin(-5);
            player.slotMachine();
          }
          text = "-1\$";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeJarroDeVida:
          if(player.vidasNoJarro <= 0){
            return {
              'text': "noHp".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            for (int i = 0; i < player.vidasNoJarro; i++) {
              final rng = Random();
              // Calcula uma posição aleatória próxima ao jogador para o item cair
              double offsetX = (rng.nextDouble() * 60) - 30;
              double offsetY = (rng.nextDouble() * 60) - 30;
              Vector2 spawnPos = player.absoluteCenter.clone() + Vector2(offsetX, offsetY);

              // Instancia o coração/vida
              final heart = Collectible(
                position: spawnPos,
                type: CollectibleType.potion,
              );

              game.world.add(heart);
              
              // Usa a física de "pop" para fazer o coração saltar do jarro para o chão
              heart.pop(Vector2(offsetX * 1.5, -50)); 
            }
            player.vidasNoJarro = 0;
          }
          text = "activeJarroDeVida".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activePa:
          game.transitionEffect.startTransition(() async {   
            game.currentLevelNotifier.value ++;
            game.currentRoomNotifier.value = 0;
            
            final coisasParaApagar = game.world.children.where((component) {
              return component.runtimeType.toString() == 'Enemy' ||
                      component.runtimeType.toString() == 'Door' ||
                      component.runtimeType.toString() == 'Collectible' ||
                      component.runtimeType.toString() == 'Projectile' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'Wall' ||
                      component.runtimeType.toString() == 'PoisonPuddle' ||
                      component.runtimeType.toString() == 'Chest' ||
                      component.runtimeType.toString() == 'BloodMachine' ||
                      component.runtimeType.toString() == 'SlotMachine' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'LaserBeam';
                      
            });
            
            game.world.removeAll(coisasParaApagar);
            game.overlays.add('HUD');

            game.nextRoomReward = CollectibleType.nextlevel;
            game.startLevel(salaAtual:false ,sala: 0); 

            player.position = Vector2(0, 250); 
          });
          
          text = "TO NEXT LEVEL".tr();
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeBoxOfFriends:
        //o to list cria uma copia, senão da erro de loop infinito
          final familiars = player.familiars.toList();

          if(familiars.isEmpty){
            final atira = Familiar(position: player.position.clone(),
                                    type: FamiliarType.atira, 
                                    player: player,
                                  );
            player.familiars.add(atira);
            game.world.add(atira);
          }else{
            for (var fam in familiars) {
              final f = Familiar(position: player.position.clone(),
                                    type: fam.type, 
                                    player: player,
                                    offX: -16, 
                                    retorna: false,
                                );
              player.familiars.add(f);
              game.world.add(f);
            }
          }
          text = "activeBoxOfFriends".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeDupliItem:
          final itensNoChao = game.world.children.whereType<Collectible>().toList();

          final naoRolar = [
            CollectibleType.chest, CollectibleType.rareChest, 
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextlevel, 
            CollectibleType.shop, CollectibleType.boss,
            CollectibleType.darkShop, CollectibleType.desafio
          ];

          if(itensNoChao.isEmpty){
            return {
                'text': "Nada para duplicar!".tr(), 
                'color': Pallete.branco, 
                'sucesso': false
              };
          }
          for (var item in itensNoChao) {
            if (!naoRolar.contains(item.type)){
              CollectibleType novoItem = item.type;
                
              Vector2 pos = item.position.clone() + Vector2(Random().nextDouble()*20-40,Random().nextDouble()*20-40);
              
              game.world.add(Collectible(position: pos, type: novoItem));
              
              createExplosionEffect(game.world, pos, Pallete.lilas, count: 15);
            }
          }

          text = "Duplicado";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeJarroFadas:
          if(player.fadasNoJarro <= 0){
            return {
              'text': "noHp".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            for (int i = 0; i < player.fadasNoJarro; i++) {
              final f = Familiar(position: player.position.clone(),
                                type: FamiliarType.fly, 
                                player: player,
                                angleOffset: i*(2*pi/player.fadasNoJarro)
                              );
            player.familiars.add(f);
            game.world.add(f);
            }
            player.fadasNoJarro = 0;
          }
          text = "activeJarroFadas".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeFreezeBomb:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            damage: player.damage * 2,
            isFreeze: true, 
            radius:400,
            cor:Pallete.lilas.withAlpha(50),
            corBorda:Pallete.azulCla.withAlpha(50)
          ));
          text = "activeFreezeBomb";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeSuperLaser:
          final dir = player.velocityDash;
          final angle = atan2(player.velocityDash.y, player.velocityDash.x); 
          player.criaLaserDirecional(dir,angle,player.damage*5,0.5,4,50);
          text = "activeSuperLaser";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeBltDetonator:
          final allBlts = game.world.children.query<Projectile>();
          final plrBlts = allBlts.where((blt) => !blt.isEnemyProjectile);

          if (plrBlts.isEmpty){
            return {
              'text': "noBlts".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            for(var b in plrBlts){
              b.explode();
            }
          }
          text = "activeSuperLaser";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeGoldenrazor:
          if (game.coinsNotifier.value < 20) {
            return {
              'text': "noCoins".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }
          player.collectCoin(-20);
          player.tempDmgGoldBonus ++ ;

          if(player.dmgGoldBuffIcon == null){
            player.numIcons ++;
            player.dmgGoldBuffIcon = GameIcon(
              icon: MdiIcons.knifeMilitary,
              color: Pallete.laranja,
              size: player.size/2,
              anchor: Anchor.center,
              position: Vector2(player.size.x / 2, - player.size.y / 4 - 14*player.numIcons), 
            );
            player.add(player.dmgGoldBuffIcon!);
          }
        
        case CollectibleType.activeSacrifFamiliar:
          final familiars = player.familiars.toList();
          final famFracos = familiars.where((fam) => fam.type == FamiliarType.fly || fam.type == FamiliarType.aranha);
          final famFortes = familiars.where((fam) => fam.type != FamiliarType.fly && fam.type != FamiliarType.aranha);
          int sacrificiosMaiores = 0;
          final rng = Random();

          final itensRaros = retornaItensRaros(player);
          final itensComuns = retornaItensComuns(player);
          final pocoes = retornaPocoes();

          List<CollectibleType> poolDeItens = [];

          poolDeItens.addAll(itensRaros);
          poolDeItens.addAll(itensComuns);
          poolDeItens.addAll(pocoes);

          if(familiars.isEmpty){
            return {
              'text': "noFamiliar".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            for(var fam in famFracos){
              Vector2 posMorte = fam.absoluteCenter.clone();
              if (fam.type == FamiliarType.fly || fam.type == FamiliarType.aranha) {
        
                final moeda = Collectible(position: posMorte, type: CollectibleType.coin);
                game.world.add(moeda);
                moeda.pop(Vector2((rng.nextDouble() - 0.5) * 50, -50));

                createExplosionEffect(game.world, posMorte, Pallete.amarelo, count: 5);
                
                fam.removeFromParent(); 
                player.familiars.remove(fam);

              } 
            }
            for(var fam in famFortes){
              Vector2 posMorte = fam.absoluteCenter.clone();
              if (sacrificiosMaiores < 2) {
                final tipoSorteado = poolDeItens[rng.nextInt(poolDeItens.length)];
                final item = Collectible(position: posMorte, type: tipoSorteado);
                
                game.world.add(item);
                item.pop(Vector2((rng.nextDouble() - 0.5) * 50, -50));

                // Sangue/Fumaça vermelha para o sacrifício maior
                createExplosionEffect(game.world, posMorte, Pallete.vermelho, count: 10);
                
                fam.removeFromParent(); 
                player.familiars.remove(fam);  
                
                sacrificiosMaiores++;
              }
            }
          }
          text = "activeSacrifFamiliar".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeTurretRotate:
          final f = Familiar(position: player.position.clone(),
                                type: FamiliarType.turretRotate, 
                                player: player,
                                retorna: false,
                                speed: 0,
                                fireRate: 0.5
                              );
          player.familiars.add(f);
          game.world.add(f);
          text = "activeTurretRotate";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeGlassStaff:
          player.superShot = true;
          player.healthNotifier.value = 1;
          text = "activeGlassStaff";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeBuracoNegro:
        // Cria o buraco negro na posição atual do jogador
        game.world.add(BuracoNegro(position: player.position.clone()));
        
        // Dica de Game Feel: Um recuo/knockback no jogador na hora do disparo fica muito bom
         player.velocity.addScaled(player.velocityDash, -300); 
        
        // AudioManager.playSfx('black_hole_spawn.wav'); // Som grave e distorcido
        text = "activeBuracoNegro";
        break;

        case CollectibleType.activeLoja:
          final rng = Random();
          List<CollectibleType> possibleRewards;
          bool itemSimples = rng.nextBool();

          if(itemSimples){
            possibleRewards = retornaItensSimples();
            final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];
            game.world.add(Collectible(position: player.position.clone() + Vector2(0,-40), type: lootType, custo: 15));
          }else{
            game.roomManager.geraItemAleatorio(player.position.clone() + Vector2(0,-40), 30);
          }

        case CollectibleType.activeRestart:
          game.transitionEffect.startTransition(() async {   
            game.currentLevelNotifier.value = 1;
            game.currentRoomNotifier.value = 0;
            
            final coisasParaApagar = game.world.children.where((component) {
              return component.runtimeType.toString() == 'Enemy' ||
                      component.runtimeType.toString() == 'Door' ||
                      component.runtimeType.toString() == 'Collectible' ||
                      component.runtimeType.toString() == 'Projectile' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'Wall' ||
                      component.runtimeType.toString() == 'PoisonPuddle' ||
                      component.runtimeType.toString() == 'Chest' ||
                      component.runtimeType.toString() == 'BloodMachine' ||
                      component.runtimeType.toString() == 'SlotMachine' ||
                      component.runtimeType.toString() == 'UnlockableItem' ||
                      component.runtimeType.toString() == 'LaserBeam';
                      
            });
            
            game.world.removeAll(coisasParaApagar);
            game.overlays.add('HUD');

            
            //game.roomManager.startRoom(0);
            game.nextRoomReward = CollectibleType.nextlevel;
            game.startLevel(salaAtual:false ,sala: 0); 
            //player.position = Vector2(0, 250); 
          });
          
          text = "activeRestart".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeCleaver:
          final currentEnemies = game.world.children
          .whereType<Enemy>()
          .where((e) => !e.isMinion)
          .toList();

          final int numEnemiesToSpawn = currentEnemies.length;

          if (numEnemiesToSpawn == 0) {
            return {
              'text': "noEnemys".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }

          for (var enemy in currentEnemies) {
            createExplosionEffect(game.world, enemy.absoluteCenter, Pallete.lilas, count: 6);
            enemy.splitIntoTwoNormalEnemies(isMenor:true);
            enemy.removeFromParent();
          }
          break;

        case CollectibleType.bombaBuracoNegro:
          player.bombaBuracoNegro = true;
          player.bombNotifier.value+=5;
          text = "bombaBuracoNegro";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.activeNuke:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            damage: 1000,
            radius:700,
            cor:Pallete.amarelo.withAlpha(50),
            corBorda:Pallete.vermelho.withAlpha(50)
          ));
          text = "activeNuke";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeKamikaze:
          game.world.add(Explosion(
            position: player.position.clone(),
            damagesPlayer:false, 
            damage: 500,
            radius:700,
            cor:Pallete.amarelo.withAlpha(50),
            corBorda:Pallete.vermelho.withAlpha(50)
          ));
          player.takeDamage(1);
          text = "activeKamikaze";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.retribuicao:
          player.retribuicao = true;
          text = "retribuicao";
          //color = Pallete.vermelho;
          break; 
        
        case CollectibleType.bloquel:
          player.refletirChance = true;
          player.increaseArtificialHp(2);
          text = "bloquel";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.adagaArremeco:
          player.adagaChance = true;
          player.increaseFireRate(0.8);
          text = "adagaArremeco";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.glifoEquilibrio:
          player.glifoEquilibrio = true;
          player.increaseArtificialHp(4);
          text = "bloquel";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.bltFireHazard:
          player.bltFireHazard = true;
          text = "bltFireHazard";
          //color = Pallete.vermelho;
          break; 
  
        case CollectibleType.trofelCampeao:
          player.increaseDamage(1.3) ;
          game.chanceChampBonus += 15;
          text = "trofelCampeao";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.familiarLanca:
          final lanca = Familiar(position: player.position.clone(),
                                  type: FamiliarType.lanca, 
                                  player: player,
                                  );
            player.familiars.add(lanca);
            game.world.add(lanca);
          text = "familiarLanca";
          break;

        case CollectibleType.bltBuracoNegro:
          player.bltBuracoNegro = true;
          text = "bltBuracoNegro";
          //color = Pallete.vermelho;
          break;  

        case CollectibleType.bltSparks:
          player.bltSparks = true;
          text = "bltSpark";
          //color = Pallete.vermelho;
          break;   

        case CollectibleType.artificialHp:
          player.increaseArtificialHp(2);
          text = "artificialHp";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.activeWoodenCoin:
          final int rng = Random().nextInt(100);
          final pos = player.position.clone() + Vector2(0, -50);
          var item;
          if (rng < 44) {
            game.world.add(FloatingText(text: "nada".tr(), position: pos, color: Pallete.vermelho, fontSize: 10));
            createExplosionEffect(game.world, pos, Pallete.lilas, count: 15);
          } else if (rng < 90) {
            item = Collectible(position: pos, type: CollectibleType.coinUm);
          } else if (rng < 95) {
            item = Collectible(position: pos, type: CollectibleType.coin);
          } else {
            item = Collectible(position: pos, type: CollectibleType.boloDinheiro);
          }
          if(item != null){
            createExplosionEffect(game.world, pos, Pallete.lilas, count: 15);
            game.world.add(item);
            item.pop(Vector2(0, 0));
          }
          text = "activeWoodenCoin";
          //color = Pallete.vermelho;
          break; 
          
        case CollectibleType.paralisia:
          player.isParalised = true;
          text = "paralisia";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.rainbowShot:
          player.rainbowShot = true;
          text = "rainbowShot";
          //color = Pallete.vermelho;
          break; 

        case CollectibleType.devilInside:
          player.isFear = true;
          player.increaseDamage(1.5);
          player.increaseMovementSpeed(1.2);
          player.increaseArtificialHp(player.maxHealth);
          player.increaseHp(-player.maxHealth );
          text = "devilInside";
          //color = Pallete.vermelho;
          break; 

        default:
          text = "";
          break;
       }
       return {'text': text, 'color': Pallete.branco, 'sucesso': true};
   }
}