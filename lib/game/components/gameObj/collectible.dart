import 'dart:math';
import 'package:towerrogue/game/components/core/audio_manager.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/interact_button.dart';
import 'package:towerrogue/game/components/effects/explosion_effect.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import 'package:towerrogue/game/components/effects/unlock_notification.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
//import 'package:towerrogue/game/components/enemies/enemy_boss.dart';
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

enum RechargeType { room, time, singleUse }

class ActiveItemData {
  final CollectibleType type;
  double currentCharge; // Mudou para double
  double maxCharge;     // Mudou para double
  final RechargeType rechargeType; // NOVO: Guarda a regra de recarga
  ActiveItemData({
    required this.type,
    required this.currentCharge,
    required this.maxCharge,
    this.rechargeType = RechargeType.room,
  });

  bool get isReady => currentCharge >= maxCharge;
}



// 3. ATUALIZE O isItemAtivo para enxergar os novos itens de tempo!
bool isItemAtivo(CollectibleType type) {
  return isItemRecarregavel(type) || isItemRecarregavelTempo(type) || isItemUsoUnico(type);
}

enum CollectibleType {
  //tipos de porta e itens simples
  coin, coinUm, souls, potion, potionUm, artificialHp,key, shield, shop, boss, nextLevel, chest, bank, rareChest, bomba, alquimista, desafio, 
  darkShop, doacaoSangue, slotMachine,cajadoQuebrado,
  //pocoes
  damage, fireRate, moveSpeed, range, sorte, critChance, critDamage, dot, healthContainer,
  //itens comuns
  keys, dash, sanduiche, bombas, piercing, fogo,veneno, sangramento, druidScroll, dotBook, chaveNegra, mine, bloodstone, bounce, spectral, cupon, 
  pocaVeneno, rastroFogo, activeHeal, activePoisonBomb, activeBattery, battery, activeArtHp, activeMagicKey, activeHoming, activeGift, activeBandage,
  activeMidas, boloDinheiro, restock, primeiroInimigoPocaVeneno, activeCircularShots, keysToBombs, activeRandPillUnico, familiarDummy, activeBloodBag, 
  activeDullRazor, activeBoxSpider, machadoArremeco, bloquel, activeWoodenCoin, activeTurretRotate, activeDiarreiaExplosiva, jumpersCable, gravitacao, 
  bumerangue, saw, familiarBouncer, familiarPrisma, activeBombardeioUnico, defensiveFairys, foice, familiarAtira,
  //itens raros
  activeRerollItem, goldDmg, activeUnicornUnico, activeTurretUnico, activeD10, orbitalShield, itemExtraBoss, activeSlot, activeFreezeBomb, 
  activeBltDetonator, activeGoldenrazor, activeGlassStaff, activeBuracoNegro, cardinalShot, activeLoja, activeFear, goldShot, familiarFinger, 
  familiarRefletor, berserk, audacious, steroids, cafe, freeze, magicShield, alcool, concentration, soda, defBurst, kinetic, heavyShot, decoy, 
  magicMush, activeMagicKeyChain, molotov, activeTurret, flail, glifoEquilibrio, bltFireHazard, trofelCampeao, familiarLanca, familiarDmgBns, 
  activeRestart, activeCleaver, bombaBuracoNegro, activeKamikaze, retribuicao, activeSacrifFamiliar, masterOrb, voo, activeJarroFadas, retaliar, 
  familiarFreeze, activeJarroDeVida, evasao, activeConvBruta, familiarBlock, revive,
  //itens epicos
  antimateria, homing, conqCrown, tornado, tripleShot, activeLicantropia, regenShield, activeD6, splitShot,
  confuseCrit, pregos, bombDecoy,activeHeartConverter, activeDivineShield, activeRitualDagger, activeMagicMirror, charmOnCrit, 
  freezeDash, activeStunBomb, activeFairy, activeUnicorn, activeBombardeio, curaCrit, laser, wave, activeSuborno, pilNanicolina, encolheOnCrit, 
  familiarGlitch, familiarDmgBuff, familiarCircProt, glitterBomb, clusterShot, familiarEye, adrenalina, eutanasia, goldHeart, activeRandPill,
  portalBoss, noveVidas, activePacmen, hurtPac, zodiacAquarius, zodiacAries, zodiacCancer, zodiacCapricorn, zodiacGemini, zodiacLeo, zodiacLibra,
  zodiacPisces, zodiacSargittarius, zodiacScorpio, zodiacTaurus, zodiacVirgo, zodiac, activeScroll, familiarMastery, activeGoldenBox,
  activePa, activeBoxOfFriends, activeDupliItem, activeSuperLaser, activeNuke, bltBuracoNegro,
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
    CollectibleType.activeGoldenrazor,
    CollectibleType.activeTurretRotate,
    CollectibleType.activeBuracoNegro,
    CollectibleType.activeLoja,
    CollectibleType.activeCleaver,
    CollectibleType.activeKamikaze,
    CollectibleType.activeWoodenCoin,
  ];
  return recarregaveis.contains(type);
}

// 2. NOVA FUNÇÃO: Coloque aqui os ENUMs dos itens que carregam por tempo
bool isItemRecarregavelTempo(CollectibleType type) {
  const recarregaveisTempo = [
    CollectibleType.activeGlassStaff,
    CollectibleType.activeBltDetonator,
    CollectibleType.activeCircularShots,
  ];
  return recarregaveisTempo.contains(type);
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

class Collectible extends PositionComponent with HasGameRef<TowerGame> {
  final CollectibleType type;
  int custo;
  int souls;
  int custoKeys;
  int custoBombs;
  bool custoVida;
  bool naoEsgota;
  double? activeCharge;
  bool _isCollected = false;

  Vector2 _velocity = Vector2.zero();
  final double _gravity = 900.0; 
  bool isBouncing = false;
  double _groundY = 0.0;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 16.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão
  InteractButton? _currentButton;
  GameSprite? visual;

  Collectible({
  required Vector2 position, 
  required this.type, 
  this.custo = 0, 
  this.souls = 0, 
  this.custoKeys = 0, 
  this.custoBombs = 0, 
  this.custoVida = false,
  this.naoEsgota=false,
  double? activeCharge,
  }): super(position: position, size: Vector2.all(16), anchor: Anchor.center) {
    this.activeCharge = activeCharge;
  }

  @override
  Future<void> onLoad() async {
    // 1. Configura Visual (Ícone e Cor)
    final attrs = Collectible.getAttributes(type);
    String iconData = attrs['icon'] as String;
    Color iconColor = attrs['color'] as Color;

    double ang = 0;

    if(type == CollectibleType.activeFairy) ang = pi/4;

    visual = GameSprite(
      imagePath: 'sprites/itens/$iconData.png',
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
        textRenderer: Pallete.textoAmarelo,
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2 + 4, size.y + 5),
      ));
    }

    if (custoKeys > 0){
      add(GameSprite(
        imagePath: 'sprites/hud/key.png',
        color: Pallete.laranja,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 -4, size.y + 10),
      ));
      add(TextComponent(
        text: ": $custoKeys",
        textRenderer: Pallete.textoLaranja,
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2 + 4, size.y + 5),
      ));
    }

    if (custoBombs > 0){
      add(GameSprite(
        imagePath: 'sprites/hud/bomb.png',
        color: Pallete.lilas,
        size: size/2,
        anchor: Anchor.center,
        position: Vector2(size.x / 2 -4, size.y + 10),
      ));
      add(TextComponent(
        text: ": $custoBombs",
        textRenderer: Pallete.textoLilas,
        anchor: Anchor.topCenter,
        position: Vector2(size.x / 2 + 4, size.y + 5),
      ));
    }
    if(custoVida){
      add(GameSprite(
        imagePath: 'sprites/condicoes/coracao.png',
        color: Pallete.vermelho,
        size: Vector2.all(8),
        anchor: Anchor.center,
        position: Vector2(size.x / 2 + size.x/2 + 2, size.y + 10),
      ));
      add(GameSprite(
        imagePath: 'sprites/condicoes/coracao.png',
        color: Pallete.vermelho,
        size: Vector2.all(8),
        anchor: Anchor.center,
        position: Vector2(size.x / 2, size.y + 10),
      ));
      add(GameSprite(
        imagePath: 'sprites/condicoes/coracao.png',
        color: Pallete.vermelho,
        size: Vector2.all(8),
        anchor: Anchor.center,
        position: Vector2(size.x / 2 - size.x/2 - 2, size.y + 10),
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
      if (!_isInfoVisible){
        _showInfo();
      }
       
    } else {
      if (_isInfoVisible) _hideInfo();
    }
  }

  void pop(Vector2 offsetDestino, {double altura = -150.0}) {
    _groundY = position.y + offsetDestino.y;
    
    // Joga a moeda para cima (y negativo) e para o lado (x)
    _velocity = Vector2(offsetDestino.x * 1.0, altura); 
    isBouncing = true;
  }

  void _showInfo() {
    if(gameRef.canInteractNotifier.value && gameRef.interactIsItem.value) return;
    gameRef.interactIsItem.value = true;
    _isInfoVisible = true;
    
    final attrs = Collectible.getAttributes(type);
    String name = attrs['name'] as String;
    String desc = attrs['desc'] as String;

    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);
    
    _infoGroup.priority = 1500;

    // 1. Descrição do Efeito
    //final textDesc = TextBoxComponent(
    //  text: desc.toLowerCase(),
    //  textRenderer: Pallete.textoDescricaoGigante, // 1. Usa a fonte gigante
     // anchor: Anchor.bottomCenter,
    //  align: Anchor.center,
    //  position: Vector2(0, 10),
    //  scale: Vector2.all(0.25), // 2. Encolhe TUDO para o tamanho normal
      
    //  boxConfig: const TextBoxConfig(
    //    maxWidth: 600.0, // 3. A caixa agora precisa ser 4x maior (250 * 4 = 1000)
    //    timePerChar: 0.0, 
    //  ),
    //);

    final textDesc = TextBoxComponent(
      text: desc.toLowerCase(),
      textRenderer: Pallete.textoDescricaoGigante, // Usa nosso super estilo
      
      anchor: Anchor.bottomCenter,
      align: Anchor.center,
      position: Vector2(0, 10),
      scale: Vector2.all(0.25), 
      
      boxConfig: const TextBoxConfig(
        maxWidth: 600.0, 
        timePerChar: 0.00, 
      ),
    );

    double espacoEntreTextos = 1.0;
    double posicaoYDoTitulo = (textDesc.position.y - textDesc.size.y - espacoEntreTextos)/4;

    // 2. Nome do Item
    final textName = TextComponent(
      text: name.toUpperCase(),
      textRenderer: Pallete.textoDanoCritico,
      anchor: Anchor.bottomCenter,
      position: Vector2(0, posicaoYDoTitulo + 8),
    );

    // 3. Botão de Pegar

    gameRef.onInteractAction = () {
      _collectItem(); _hideInfo();
    };

    gameRef.canInteractNotifier.value = true;
    _infoGroup.add(textName);
    _infoGroup.add(textDesc);
    

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
    gameRef.canInteractNotifier.value = false;
    gameRef.interactIsItem.value = false;
    gameRef.onInteractAction = null;
  }

  void _collectItem() async {
    // 1. SALVA A REFERÊNCIA (Se o item sumir no meio do código, o 'game' continua existindo na memória!)
    final game = gameRef;
    final player = game.player;

    // Se já foi coletado e está no processo de sumir, ignora novas colisões!
    if (_isCollected && !naoEsgota) return;

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
      CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextLevel, 
      CollectibleType.shop, CollectibleType.boss, CollectibleType.shield, CollectibleType.doacaoSangue,
      CollectibleType.healthContainer,CollectibleType.slotMachine
    ];

    if (!consumiveis.contains(type)) {
      final attrs = Collectible.getAttributes(type);
      player.setAcquiredItemsList(
        type, attrs['name'] as String, attrs['desc'] as String, attrs['icon'] as String, attrs['color'] as Color,
      );
      game.progress.discoverItem(type.toString());
    }
    
    // 7. REMOVE DO JOGO IMEDIATAMENTE!
    if (!naoEsgota) removeFromParent();
    
    // 8. O AWAIT FICA NO FINAL (Ele roda em segundo plano sem quebrar nada)
    _tentaDesbloquearClasse(game);
  }

  // --- DESBLOQUEAR CLASSES ---
  Future<void> _tentaDesbloquearClasse(TowerGame game) async {
    String clasId = '';
    String clasNome = '';

    switch (type){
      case CollectibleType.activeLicantropia:
        clasId = 'licantropo'; clasNome = 'licantropo'.tr(); break;
      case CollectibleType.molotov:
        clasId = 'multidao'; clasNome = 'multidao'.tr(); break;
      // --- DESBLOQUEIOS COMPLEXOS (Múltiplos Itens) ---
      // Exemplo: O "Piromante" precisa do Molotov E do Anel de Fogo.
      // Colocamos os cases juntos (fallthrough) para que pegar QUALQUER UM dos dois dispare a checagem.
      case CollectibleType.laser:
      case CollectibleType.activeSuperLaser:
        
        // 1. Verificamos no GameProgress se o jogador JÁ TEM os itens salvos.
        // (Ajuste a forma como você converte o enum para String, ex: .name ou .toString())
        bool temLaser1 = game.progress.discoveredItems.contains(CollectibleType.laser.toString());
        bool temLaser2 = game.progress.discoveredItems.contains(CollectibleType.activeSuperLaser.toString());

        // 2. Como o jogador está pegando um dos itens EXATAMENTE AGORA, 
        // ele pode ainda não ter sido salvo no disco. Então garantimos que o atual conta como 'true'.
        if (type == CollectibleType.laser) temLaser1 = true;
        if (type == CollectibleType.activeSuperLaser) temLaser2 = true;

        // 3. Só preenche o ID e Nome se tiver TODAS as partes
        if (temLaser1 && temLaser2) {
          clasId = 'samuela'; 
          clasNome = 'samuela'.tr();
        } else {
          return; // Falta peça, cancela a função e não tenta desbloquear nada.
        }
        break;

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
        return {'name': 'gold'.tr(), 'desc': 'goldDesc'.tr(), 'icon': 'coins', 'color': Pallete.amarelo};
      case CollectibleType.coinUm:
        return {'name': 'goldUm'.tr(), 'desc': 'goldUmDesc'.tr(), 'icon': 'coin', 'color': Pallete.amarelo};
      case CollectibleType.souls:
        return {'name': 'soul'.tr(), 'desc': 'alma', 'icon': 'soul', 'color': Pallete.lilas};
      case CollectibleType.potion:
        return {'name': 'heart'.tr(), 'desc': 'heartDesc'.tr(), 'icon': 'hpCheio', 'color': Pallete.vermelho};
      case CollectibleType.potionUm:
        return {'name': 'heartUm'.tr(), 'desc': 'heartUmDesc'.tr(), 'icon': 'hpMeio', 'color': Pallete.vermelho};
      case CollectibleType.artificialHp:
        return {'name': 'artificialHp'.tr(), 'desc': 'artificialHpDesc'.tr(), 'icon': 'hpCheio', 'color': Pallete.azulCla};
      case CollectibleType.sanduiche:
        return {'name': 'sanduiche'.tr(), 'desc': 'sanduiche'.tr(), 'icon': 'sanduiche', 'color': Pallete.marrom};
      case CollectibleType.key:
        return {'name': 'key'.tr(), 'desc': 'keyDesc'.tr(), 'icon': 'key', 'color': Pallete.laranja};
      case CollectibleType.chaveNegra:
        return {'name': 'chaveNegra'.tr(), 'desc': 'chaveNegraDesc'.tr(), 'icon': 'key', 'color': Pallete.cinzaEsc};
      case CollectibleType.keys:
        return {'name': 'keys'.tr(), 'desc': 'keysDesc'.tr(), 'icon': 'molhoChaves', 'color': Pallete.laranja};
      case CollectibleType.bomba:
        return {'name': 'bomb'.tr(), 'desc': 'bombDesc'.tr(), 'icon': 'bomba', 'color': Pallete.lilas};
      case CollectibleType.bombas:
        return {'name': 'bombs'.tr(), 'desc': 'bombsDesc'.tr(), 'icon': 'sacoBomba', 'color': Pallete.lilas};
      case CollectibleType.damage:
        return {'name': 'potDmg'.tr(), 'desc': 'potDmgDesc'.tr(), 'icon': 'potion', 'color': Pallete.vermelho};
      case CollectibleType.dot:
        return {'name': 'potDot'.tr(), 'desc': 'potDotDesc'.tr(), 'icon': 'potion', 'color': Pallete.verdeEsc};
      case CollectibleType.critChance:
        return {'name': 'potChCrit'.tr(), 'desc': 'potChCritDesc'.tr(), 'icon': 'potion', 'color': Pallete.cinzaCla};
      case CollectibleType.critDamage:
        return {'name': 'potDmgCrit'.tr(), 'desc': 'potDmgCritDesc'.tr(), 'icon': 'potion', 'color': Pallete.lilas};
      case CollectibleType.fireRate:
        return {'name': 'potFireRate'.tr(), 'desc': 'potFireRateDesc'.tr(), 'icon': 'potion', 'color': Pallete.laranja};
      case CollectibleType.moveSpeed:
        return {'name': 'boots'.tr(), 'desc': 'bootsDesc'.tr(), 'icon': 'potion', 'color': Pallete.verdeCla};
      case CollectibleType.range:
        return {'name': 'aim'.tr(), 'desc': 'aimDesc'.tr(), 'icon': 'potion', 'color': Pallete.rosa};
      case CollectibleType.sorte:
        return {'name': 'sortePot'.tr(), 'desc': 'sortePotDesc'.tr(), 'icon': 'potion', 'color': Pallete.amarelo};
      case CollectibleType.shield:
        return {'name': 'shield'.tr(), 'desc': 'shieldDesc'.tr(), 'icon': 'escudo', 'color': Pallete.cinzaCla};
      case CollectibleType.dash:
        return {'name': 'dash'.tr(), 'desc': 'dashDesc'.tr(), 'icon': 'dash', 'color': Pallete.verdeCla};
      case CollectibleType.healthContainer:
        return {'name': 'hpContainer'.tr(), 'desc': 'hpContainerDesc'.tr(), 'icon': 'hpVazio', 'color': Pallete.vermelho};
      case CollectibleType.berserk:
        return {'name': 'berserk'.tr(), 'desc': 'berserkDesc'.tr(), 'icon': 'furia', 'color': Pallete.vermelho};
      case CollectibleType.audacious:
        return {'name': 'audaz'.tr(), 'desc': 'audazDesc'.tr(), 'icon': 'raiva', 'color': Pallete.vermelho};
      case CollectibleType.steroids:
        return {'name': 'steroids'.tr(), 'desc': 'steroidsDesc'.tr(), 'icon': 'seringa', 'color': Pallete.vermelho};
      case CollectibleType.cafe:
        return {'name': 'cafe'.tr(), 'desc': 'cafeDesc'.tr(), 'icon': 'cafe', 'color': Pallete.marrom};
      case CollectibleType.alcool:
        return {'name': 'alcool'.tr(), 'desc': 'alcoolDesc'.tr(), 'icon': 'vinho', 'color': Pallete.lilas};
      case CollectibleType.freeze:
        return {'name': 'freeze'.tr(), 'desc': 'freezeDesc'.tr(), 'icon': 'neve', 'color': Pallete.azulCla};
      case CollectibleType.magicShield:
        return {'name': 'magicShield'.tr(), 'desc': 'magicShieldDesc'.tr(), 'icon': 'escudoDivino', 'color': Pallete.amarelo};
      case CollectibleType.orbitalShield:
        return {'name': 'orbShield'.tr(), 'desc': 'orbShieldDesc'.tr(), 'icon': 'escudoOrbital', 'color': Pallete.lilas};
      case CollectibleType.foice:
        return {'name': 'foice'.tr(), 'desc': 'foiceDesc'.tr(), 'icon': 'foice', 'color': Pallete.lilas};
      case CollectibleType.revive:
        return {'name': 'revive'.tr(), 'desc': 'reviveDesc'.tr(), 'icon': 'cogumelo', 'color': Pallete.verdeCla};
      case CollectibleType.antimateria:
        return {'name': 'antimat'.tr(), 'desc': 'antimatDesc'.tr(), 'icon': 'antimateria', 'color': Pallete.lilas};
      case CollectibleType.piercing:
        return {'name': 'piercing'.tr(), 'desc': 'piercingDesc'.tr(), 'icon': 'piercing', 'color': Pallete.vermelho};
      case CollectibleType.homing:
        return {'name': 'homing'.tr(), 'desc': 'homingDesc'.tr(), 'icon': 'telecinese', 'color': Pallete.vermelho};
      case CollectibleType.fogo:
        return {'name': 'fogo'.tr(), 'desc': 'fogoDesc'.tr(), 'icon': 'fogo', 'color': Pallete.laranja};
      case CollectibleType.veneno:
        return {'name': 'veneno'.tr(), 'desc': 'venenoDesc'.tr(), 'icon': 'sangue', 'color': Pallete.verdeCla};
      case CollectibleType.sangramento:
        return {'name': 'sang'.tr(), 'desc': 'sangDesc'.tr(), 'icon': 'sangue', 'color': Pallete.vermelho};
     case CollectibleType.druidScroll:
        return {'name': 'druidScroll'.tr(), 'desc': 'druidScrollDesc'.tr(), 'icon': 'scroll', 'color': Pallete.verdeEsc};
      case CollectibleType.dotBook:
        return {'name': 'dotBook'.tr(), 'desc': 'dotBookDesc'.tr(), 'icon': 'book', 'color': Pallete.amarelo};
      case CollectibleType.concentration:
        return {'name': 'concentration'.tr(), 'desc': 'concentrationDesc'.tr(), 'icon': 'retribuicao', 'color': Pallete.azulCla};
      case CollectibleType.gravitacao:
        return {'name': 'gravitacao'.tr(), 'desc': 'gravitacaoDesc'.tr(), 'icon': 'tiroOrbital', 'color': Pallete.branco};
      case CollectibleType.mine:
        return {'name': 'mine'.tr(), 'desc': 'mineDesc'.tr(), 'icon': 'mina', 'color': Pallete.verdeEsc};
      case CollectibleType.soda:
         return {'name': 'soda'.tr(), 'desc': 'sodaDesc'.tr(), 'icon': 'vinho', 'color': Pallete.cinzaEsc}; 
      case CollectibleType.bloodstone:
         return {'name': 'bloodstone'.tr(), 'desc': 'bloodstoneDesc'.tr(), 'icon': 'colar', 'color': Pallete.vermelho}; 
      case CollectibleType.spectral:
         return {'name': 'spectral'.tr(), 'desc': 'spectralDesc'.tr(), 'icon': 'spectralShot', 'color': Pallete.lilas}; 
      case CollectibleType.bounce:
         return {'name': 'bounce'.tr(), 'desc': 'bounceDesc'.tr(), 'icon': 'bounceShot', 'color': Pallete.vermelho}; 
      case CollectibleType.defBurst:
         return {'name': 'defBurst'.tr(), 'desc': 'defBurstDesc'.tr(), 'icon': 'escudoExplode', 'color': Pallete.vermelho}; 
      case CollectibleType.kinetic:
         return {'name': 'kinetic'.tr(), 'desc': 'kineticDesc'.tr(), 'icon': 'dash', 'color': Pallete.vermelho}; 
      case CollectibleType.heavyShot:
         return {'name': 'heavy'.tr(), 'desc': 'heavyDesc'.tr(), 'icon': 'bolaCorrente', 'color': Pallete.cinzaEsc}; 
      case CollectibleType.cupon:
         return {'name': 'cupon'.tr(), 'desc': 'cuponDesc'.tr(), 'icon': 'cupon', 'color': Pallete.bege};
      case CollectibleType.conqCrown:
         return {'name': 'conqCrown'.tr(), 'desc': 'conqCrownDesc'.tr(), 'icon': 'coroa', 'color': Pallete.amarelo};
      case CollectibleType.flail:
         return {'name': 'flail'.tr(), 'desc': 'flailDesc'.tr(), 'icon': 'flail', 'color': Pallete.vermelho};
      case CollectibleType.bumerangue:
         return {'name': 'bumerangue'.tr(), 'desc': 'bumerangueDesc'.tr(), 'icon': 'bumerangue', 'color': Pallete.marrom};
      case CollectibleType.pocaVeneno:
         return {'name': 'pocaVeneno'.tr(), 'desc': 'pocaVenenoDesc'.tr(), 'icon': 'pocaVeneno', 'color': Pallete.verdeCla};
      case CollectibleType.rastroFogo:
         return {'name': 'rastroFogo'.tr(), 'desc': 'rastroFogoDesc'.tr(), 'icon': 'fogoRastro', 'color': Pallete.laranja};
      case CollectibleType.tornado:
         return {'name': 'tornado'.tr(), 'desc': 'tornadoDesc'.tr(), 'icon': 'sonicBoom', 'color': Pallete.branco};
      case CollectibleType.tripleShot:
         return {'name': 'tripleShot'.tr(), 'desc': 'tripleShotDesc'.tr(), 'icon': 'tripleShot', 'color': Pallete.branco};
      case CollectibleType.activeHeal:
         return {'name': 'activeHeal'.tr(), 'desc': 'activeHealDesc'.tr(), 'icon': 'potCura', 'color': Pallete.vermelho};
      case CollectibleType.activePoisonBomb:
         return {'name': 'activePoisonBomb'.tr(), 'desc': 'activePoisonBombDesc'.tr(), 'icon': 'bombaVeneno', 'color': Pallete.verdeCla};
      case CollectibleType.activeLicantropia:
         return {'name': 'activeLicantropia'.tr(), 'desc': 'activeLicantropiaDesc'.tr(), 'icon': 'licantropo', 'color': Pallete.vermelho};
      case CollectibleType.activeBattery:
         return {'name': 'activeBattery'.tr(), 'desc': 'activeBatteryDesc'.tr(), 'icon': 'pilha', 'color': Pallete.azulCla};
      case CollectibleType.battery:
         return {'name': 'battery'.tr(), 'desc': 'batteryDesc'.tr(), 'icon': 'bateria', 'color': Pallete.azulCla};
      case CollectibleType.regenShield:
         return {'name': 'regenShield'.tr(), 'desc': 'regenShieldDesc'.tr(), 'icon': 'escudoRegen', 'color': Pallete.azulCla};
      case CollectibleType.activeArtHp:
         return {'name': 'activeArtHp'.tr(), 'desc': 'activeArtHpDesc'.tr(), 'icon': 'hpCheio', 'color': Pallete.azulCla};
      case CollectibleType.decoy:
        return {'name': 'decoy'.tr(), 'desc': 'decoyDesc'.tr(), 'icon': 'decoy', 'color': Pallete.cinzaCla};
      case CollectibleType.magicMush:
        return {'name': 'magicMush'.tr(), 'desc': 'magicMushDesc'.tr(), 'icon': 'cogumelo', 'color': Pallete.vermelho};
      case CollectibleType.activeMagicKey:
        return {'name': 'activeMagicKey'.tr(), 'desc': 'activeMagicKeyDesc'.tr(), 'icon': 'key', 'color': Pallete.azulCla};
      case CollectibleType.activeMagicKeyChain:
        return {'name': 'activeMagicKeyChain'.tr(), 'desc': 'activeMagicKeyChainDesc'.tr(), 'icon': 'molhoChaves', 'color': Pallete.azulCla};
      case CollectibleType.activeHoming:
        return {'name': 'activeHoming'.tr(), 'desc': 'activeHomingDesc'.tr(), 'icon': 'telecinese', 'color': Pallete.laranja};
      case CollectibleType.activeGift:
        return {'name': 'activeGift'.tr(), 'desc': 'activeGiftDesc'.tr(), 'icon': 'presente', 'color': Pallete.rosa};
      case CollectibleType.activeD6:
        return {'name': 'activeD6'.tr(), 'desc': 'activeD6Desc'.tr(), 'icon': 'd6', 'color': Pallete.verdeCla};
      case CollectibleType.splitShot:
        return {'name': 'splitShot'.tr(), 'desc': 'splitShotDesc'.tr(), 'icon': 'fragmento', 'color': Pallete.vermelho};
      case CollectibleType.familiarBlock:
        return {'name': 'familiarBlock'.tr(), 'desc': 'familiarBlockDesc'.tr(), 'icon': 'wisp', 'color': Pallete.azulCla};
      case CollectibleType.familiarAtira:
        return {'name': 'familiarAtira'.tr(), 'desc': 'familiarAtiraDesc'.tr(), 'icon': 'fantasma', 'color': Pallete.vermelho};
      case CollectibleType.confuseCrit:
        return {'name': 'confuseCrit'.tr(), 'desc': 'confuseCritDesc'.tr(), 'icon': 'portal', 'color': Pallete.amarelo};
      case CollectibleType.pregos:
        return {'name': 'pregos'.tr(), 'desc': 'pregosDesc'.tr(), 'icon': 'prego', 'color': Pallete.cinzaCla};
      case CollectibleType.bombDecoy:
        return {'name': 'bombDecoy'.tr(), 'desc': 'bombDecoyDesc'.tr(), 'icon': 'bombaDecoy', 'color': Pallete.cinzaEsc};
      case CollectibleType.activeHeartConverter:
        return {'name': 'activeHeartConverter'.tr(), 'desc': 'activeHeartConverterDesc'.tr(), 'icon': 'hpVazio', 'color': Pallete.azulCla};
      case CollectibleType.activeDivineShield:
        return {'name': 'activeDivineShield'.tr(), 'desc': 'activeDivineShieldDesc'.tr(), 'icon': 'escudoDivino', 'color': Pallete.azulCla};
      case CollectibleType.activeRerollItem:
        return {'name': 'activeRerollItem'.tr(), 'desc': 'activeRerollItemDesc'.tr(), 'icon': 'd20', 'color': Pallete.laranja};
      case CollectibleType.activeRitualDagger:
        return {'name': 'activeRitualDagger'.tr(), 'desc': 'activeRitualDaggerDesc'.tr(), 'icon': 'adagaRitual', 'color': Pallete.vermelho};
      case CollectibleType.activeBandage:
        return {'name': 'activeBandage'.tr(), 'desc': 'activeBandageDesc'.tr(), 'icon': 'bandage', 'color': Pallete.bege};
      case CollectibleType.activeMagicMirror:
        return {'name': 'activeMagicMirror'.tr(), 'desc': 'activeMagicMirrorDesc'.tr(), 'icon': 'espelho', 'color': Pallete.laranja};
      case CollectibleType.activeConvBruta:
        return {'name': 'activeConvBruta'.tr(), 'desc': 'activeConvBrutaDesc'.tr(), 'icon': 'alqBrutal', 'color': Pallete.vermelho};
      case CollectibleType.activeMidas:
        return {'name': 'activeMidas'.tr(), 'desc': 'activeMidasDesc'.tr(), 'icon': 'mao', 'color': Pallete.laranja};
      case CollectibleType.charmOnCrit:
        return {'name': 'charmOnCrit'.tr(), 'desc': 'charmOnCritDesc'.tr(), 'icon': 'charm', 'color': Pallete.rosa};
      case CollectibleType.freezeDash:
        return {'name': 'freezeDash'.tr(), 'desc': 'freezeDashDesc'.tr(), 'icon': 'patins', 'color': Pallete.azulCla};
      case CollectibleType.goldDmg:
        return {'name': 'goldDmg'.tr(), 'desc': 'goldDmgDesc'.tr(), 'icon': 'cajado', 'color': Pallete.laranja};
      case CollectibleType.activeStunBomb:
        return {'name': 'activeStunBomb'.tr(), 'desc': 'activeStunBombDesc'.tr(), 'icon': 'bombaConfusao', 'color': Pallete.amarelo};
      case CollectibleType.activeFairy:
        return {'name': 'activeFairy'.tr(), 'desc': 'activeFairyDesc'.tr(), 'icon': 'fada', 'color': Pallete.amarelo};
      case CollectibleType.activeUnicorn:
        return {'name': 'activeUnicorn'.tr(), 'desc': 'activeUnicornDesc'.tr(), 'icon': 'cabecaUnicornio', 'color': Pallete.laranja};
      case CollectibleType.activeUnicornUnico:
        return {'name': 'activeUnicorn'.tr(), 'desc': 'activeUnicornDesc'.tr(), 'icon': 'cabecaUnicornio', 'color': Pallete.amarelo};
      case CollectibleType.activeBombardeio:
        return {'name': 'activeBombardeio'.tr(), 'desc': 'activeBombardeioDesc'.tr(), 'icon': 'bombardeio', 'color': Pallete.vermelho};
      case CollectibleType.activeBombardeioUnico:
        return {'name': 'activeBombardeio'.tr(), 'desc': 'activeBombardeioDesc'.tr(), 'icon': 'bombardeio', 'color': Pallete.laranja};
      case CollectibleType.curaCrit:
        return {'name': 'curaCrit'.tr(), 'desc': 'curaCritDesc'.tr(), 'icon': 'bloodBag', 'color': Pallete.vermelho};
      case CollectibleType.molotov:
        return {'name': 'molotov'.tr(), 'desc': 'molotovDesc'.tr(), 'icon': 'molotov', 'color': Pallete.laranja};
      case CollectibleType.laser:
        return {'name': 'laser'.tr(), 'desc': 'laserDesc'.tr(), 'icon': 'laser', 'color': Pallete.vermelho};
      case CollectibleType.activeTurret:
        return {'name': 'activeTurret'.tr(), 'desc': 'activeTurretDesc'.tr(), 'icon': 'turret', 'color': Pallete.vermelho};
      case CollectibleType.activeTurretUnico:
        return {'name': 'activeTurret'.tr(), 'desc': 'activeTurretDesc'.tr(), 'icon': 'turret', 'color': Pallete.laranja};
      case CollectibleType.wave:
        return {'name': 'wave'.tr(), 'desc': 'waveDesc'.tr(), 'icon': 'onda', 'color': Pallete.azulCla};
      case CollectibleType.activeSuborno:
        return {'name': 'activeSuborno'.tr(), 'desc': 'activeSubornoDesc'.tr(), 'icon': 'sacoMoedas', 'color': Pallete.verdeEsc};
      case CollectibleType.pilNanicolina:
        return {'name': 'pilNanicolina'.tr(), 'desc': 'pilNanicolinaDesc'.tr(), 'icon': 'pill', 'color': Pallete.vermelho};
      case CollectibleType.saw:
        return {'name': 'saw'.tr(), 'desc': 'sawDesc'.tr(), 'icon': 'saw', 'color': Pallete.cinzaCla};
      case CollectibleType.boloDinheiro:
        return {'name': 'boloDinheiro'.tr(), 'desc': 'boloDinheiroDesc'.tr(), 'icon': 'cash', 'color': Pallete.verdeEsc};
      case CollectibleType.retaliar:
        return {'name': 'retaliar'.tr(), 'desc': 'retaliarDesc'.tr(), 'icon': 'escudoExplode', 'color': Pallete.vermelho};
      case CollectibleType.restock:
        return {'name': 'restock'.tr(), 'desc': 'restockDesc'.tr(), 'icon': 'restock', 'color': Pallete.vermelho};
      case CollectibleType.familiarFreeze:
        return {'name': 'familiarFreeze'.tr(), 'desc': 'familiarFreezeDesc'.tr(), 'icon': 'espirito', 'color': Pallete.azulCla};
      case CollectibleType.encolheOnCrit:
        return {'name': 'encolheOnCrit'.tr(), 'desc': 'encolheOnCritDesc'.tr(), 'icon': 'encolhe', 'color': Pallete.marrom};
      case CollectibleType.familiarGlitch:
        return {'name': 'familiarGlitch'.tr(), 'desc': 'familiarGlitchDesc'.tr(), 'icon': 'caveira', 'color': Pallete.rosa};
      case CollectibleType.familiarDmgBuff:
        return {'name': 'familiarDmgBuff'.tr(), 'desc': 'familiarDmgBuffDesc'.tr(), 'icon': 'satelite', 'color': Pallete.vermelho};
      case CollectibleType.familiarCircProt:
        return {'name': 'familiarCircProt'.tr(), 'desc': 'familiarCircProtDesc'.tr(), 'icon': 'circuloProt', 'color': Pallete.branco};
      case CollectibleType.glitterBomb:
        return {'name': 'glitterBomb'.tr(), 'desc': 'glitterBombDesc'.tr(), 'icon': 'bombaGlitter', 'color': Pallete.rosa};
      case CollectibleType.goldShot:
        return {'name': 'goldShot'.tr(), 'desc': 'goldShotDesc'.tr(), 'icon': 'cajado', 'color': Pallete.laranja};
      case CollectibleType.clusterShot:
        return {'name': 'clusterShot'.tr(), 'desc': 'clusterShotDesc'.tr(), 'icon': 'fragmento', 'color': Pallete.vinho};
      case CollectibleType.evasao:
        return {'name': 'evasao'.tr(), 'desc': 'evasaoDesc'.tr(), 'icon': 'capa', 'color': Pallete.azulCla};
      case CollectibleType.primeiroInimigoPocaVeneno:
        return {'name': 'primeiroInimigoPocaVeneno'.tr(), 'desc': 'primeiroInimigoPocaVenenoDesc'.tr(), 'icon': 'seringa', 'color': Pallete.verdeCla};
      case CollectibleType.familiarFinger:
        return {'name': 'familiarFinger'.tr(), 'desc': 'familiarFingerDesc'.tr(), 'icon': 'dedo', 'color': Pallete.bege};
      case CollectibleType.familiarBouncer:
        return {'name': 'familiarBouncer'.tr(), 'desc': 'familiarBouncerDesc'.tr(), 'icon': 'tornado', 'color': Pallete.branco};
      case CollectibleType.familiarEye:
        return {'name': 'familiarEye'.tr(), 'desc': 'familiarEyeDesc'.tr(), 'icon': 'olho', 'color': Pallete.rosa};
      case CollectibleType.adrenalina:
        return {'name': 'adrenalina'.tr(), 'desc': 'adrenalinaDesc'.tr(), 'icon': 'seringa', 'color': Pallete.rosa};
      case CollectibleType.eutanasia:
        return {'name': 'eutanasia'.tr(), 'desc': 'eutanasiaDesc'.tr(), 'icon': 'seringa', 'color': Pallete.lilas};
      case CollectibleType.goldHeart:
        return {'name': 'goldHeart'.tr(), 'desc': 'goldHeartDesc'.tr(), 'icon': 'hpCheio', 'color': Pallete.laranja};
      case CollectibleType.familiarPrisma:
        return {'name': 'familiarPrisma'.tr(), 'desc': 'familiarPrismaDesc'.tr(), 'icon': 'prisma', 'color': Pallete.branco};
      case CollectibleType.familiarRefletor:
        return {'name': 'familiarRefletor'.tr(), 'desc': 'familiarRefletorDesc'.tr(), 'icon': 'espelho2', 'color': Pallete.cinzaCla};
      case CollectibleType.jumpersCable:
        return {'name': 'jumpersCable'.tr(), 'desc': 'jumpersCableDesc'.tr(), 'icon': 'jumperCable', 'color': Pallete.lilas};
      case CollectibleType.activeCircularShots:
        return {'name': 'activeCircularShots'.tr(), 'desc': 'activeCircularShotsDesc'.tr(), 'icon': 'fragmento', 'color': Pallete.branco};
      case CollectibleType.keysToBombs:
        return {'name': 'keysToBombs'.tr(), 'desc': 'keysToBombsDesc'.tr(), 'icon': 'bombsAreKeys', 'color': Pallete.lilas};
      case CollectibleType.activeRandPill:
        return {'name': 'activeRandPill'.tr(), 'desc': 'activeRandPillDesc'.tr(), 'icon': 'pill', 'color': Pallete.laranja};
      case CollectibleType.activeRandPillUnico:
        return {'name': 'activeRandPill'.tr(), 'desc': 'activeRandPillDesc'.tr(), 'icon': 'pill', 'color': Pallete.verdeEsc};
      case CollectibleType.portalBoss:
        return {'name': 'portalBoss'.tr(), 'desc': 'portalBossDesc'.tr(), 'icon': 'portal', 'color': Pallete.vermelho};
      case CollectibleType.activeFear:
        return {'name': 'activeFear'.tr(), 'desc': 'activeFearDesc'.tr(), 'icon': 'raiva', 'color': Pallete.vinho};
      case CollectibleType.activeDiarreiaExplosiva:
        return {'name': 'activeDiarreiaExplosiva'.tr(), 'desc': 'activeDiarreiaExplosivaDesc'.tr(), 'icon': 'bombaDiarreia', 'color': Pallete.marrom};
      case CollectibleType.familiarDummy:
        return {'name': 'familiarDummy'.tr(), 'desc': 'familiarDummyDesc'.tr(), 'icon': 'dummy', 'color': Pallete.bege};
      case CollectibleType.voo:
        return {'name': 'voo'.tr(), 'desc': 'vooDesc'.tr(), 'icon': 'asa', 'color': Pallete.azulCla};
      case CollectibleType.cardinalShot:
        return {'name': 'cardinalShot'.tr(), 'desc': 'cardinalShotDesc'.tr(), 'icon': 'cardinal', 'color': Pallete.vermelho};
      case CollectibleType.noveVidas:
        return {'name': 'noveVidas'.tr(), 'desc': 'noveVidasDesc'.tr(), 'icon': 'cat', 'color': Pallete.cinzaEsc};
      case CollectibleType.activePacmen:
        return {'name': 'activePacmen'.tr(), 'desc': 'activePacmenDesc'.tr(), 'icon': 'gameboy', 'color': Pallete.cinzaCla};
      case CollectibleType.hurtPac:
        return {'name': 'hurtPac'.tr(), 'desc': 'hurtPacDesc'.tr(), 'icon': 'console', 'color': Pallete.cinzaCla};
      case CollectibleType.zodiacAquarius:
        return {'name': 'zodiacAquarius'.tr(), 'desc': 'zodiacAquariusDesc'.tr(), 'icon': 'aquarius', 'color': Pallete.azulCla};
      case CollectibleType.zodiacAries:
        return {'name': 'zodiacAries'.tr(), 'desc': 'zodiacAriesDesc'.tr(), 'icon': 'aries', 'color': Pallete.azulCla};
      case CollectibleType.zodiacCancer:
        return {'name': 'zodiacCancer'.tr(), 'desc': 'zodiacCancerDesc'.tr(), 'icon': 'cancer', 'color': Pallete.azulCla};
      case CollectibleType.zodiacCapricorn:
        return {'name': 'zodiacCapricorn'.tr(), 'desc': 'zodiacCapricornDesc'.tr(), 'icon': 'capricorn', 'color': Pallete.azulCla};
      case CollectibleType.zodiacGemini:
        return {'name': 'zodiacGemini'.tr(), 'desc': 'zodiacGeminiDesc'.tr(), 'icon': 'gemini', 'color': Pallete.azulCla};
      case CollectibleType.zodiacLeo:
        return {'name': 'zodiacLeo'.tr(), 'desc': 'zodiacLeoDesc'.tr(), 'icon': 'leo', 'color': Pallete.azulCla};
      case CollectibleType.zodiacLibra:
        return {'name': 'zodiacLibra'.tr(), 'desc': 'zodiacLibraDesc'.tr(), 'icon': 'libra', 'color': Pallete.azulCla};
      case CollectibleType.zodiacPisces:
        return {'name': 'zodiacPisces'.tr(), 'desc': 'zodiacPiscesDesc'.tr(), 'icon': 'pisces', 'color': Pallete.azulCla};
      case CollectibleType.zodiacSargittarius:
        return {'name': 'zodiacSargittarius'.tr(), 'desc': 'zodiacSargittariusDesc'.tr(), 'icon': 'sagittarius', 'color': Pallete.azulCla};
      case CollectibleType.zodiacScorpio:
        return {'name': 'zodiacScorpio'.tr(), 'desc': 'zodiacScorpioDesc'.tr(), 'icon': 'scorpio', 'color': Pallete.azulCla};
      case CollectibleType.zodiacTaurus:
        return {'name': 'zodiacTaurus'.tr(), 'desc': 'zodiacTaurusDesc'.tr(), 'icon': 'taurus', 'color': Pallete.azulCla};
      case CollectibleType.zodiacVirgo:
        return {'name': 'zodiacVirgo'.tr(), 'desc': 'zodiacVirgoDesc'.tr(), 'icon': 'virgo', 'color': Pallete.azulCla};
      case CollectibleType.zodiac:
        return {'name': 'zodiac'.tr(), 'desc': 'zodiacDesc'.tr(), 'icon': 'zodiac', 'color': Pallete.azulCla};
      case CollectibleType.activeDullRazor:
        return {'name': 'activeDullRazor'.tr(), 'desc': 'activeDullRazorDesc'.tr(), 'icon': 'lamina', 'color': Pallete.marrom};
      case CollectibleType.activeBoxSpider:
        return {'name': 'activeBoxSpider'.tr(), 'desc': 'activeBoxSpiderDesc'.tr(), 'icon': 'caixa', 'color': Pallete.azulCla};
      case CollectibleType.activeD10:
        return {'name': 'activeD10'.tr(), 'desc': 'activeD10Desc'.tr(), 'icon': 'd10', 'color': Pallete.laranja};
      case CollectibleType.activeScroll:
        return {'name': 'activeScroll'.tr(), 'desc': 'activeScrollDesc'.tr(), 'icon': 'scroll', 'color': Pallete.bege};
      case CollectibleType.defensiveFairys:
        return {'name': 'defensiveFairys'.tr(), 'desc': 'defensiveFairysDesc'.tr(), 'icon': 'fada', 'color': Pallete.azulCla};
      case CollectibleType.familiarDmgBns:
        return {'name': 'familiarDmgBns'.tr(), 'desc': 'familiarDmgBnsDesc'.tr(), 'icon': 'certificado', 'color': Pallete.verdeEsc};
      case CollectibleType.familiarMastery:
        return {'name': 'familiarMastery'.tr(), 'desc': 'familiarMasteryDesc'.tr(), 'icon': 'pet', 'color': Pallete.verdeEsc};
      case CollectibleType.itemExtraBoss:
        return {'name': 'itemExtraBoss'.tr(), 'desc': 'itemExtraBossDesc'.tr(), 'icon': 'sacoMoedas', 'color': Pallete.verdeEsc};
      case CollectibleType.activeGoldenBox:
        return {'name': 'activeGoldenBox'.tr(), 'desc': 'activeGoldenBoxDesc'.tr(), 'icon': 'caixa', 'color': Pallete.laranja};
      case CollectibleType.activeSlot:
        return {'name': 'activeSlot'.tr(), 'desc': 'activeSlotDesc'.tr(), 'icon': 'slot', 'color': Pallete.laranja};
      case CollectibleType.activeJarroDeVida:
        return {'name': 'activeJarroDeVida'.tr(), 'desc': 'activeJarroDeVidaDesc'.tr(), 'icon': 'jarroCoracao', 'color': Pallete.vermelho};
      case CollectibleType.activePa:
        return {'name': 'activePa'.tr(), 'desc': 'activePaDesc'.tr(), 'icon': 'escada', 'color': Pallete.azulCla};
      case CollectibleType.activeBoxOfFriends:
        return {'name': 'activeBoxOfFriends'.tr(), 'desc': 'activeBoxOfFriendsDesc'.tr(), 'icon': 'caixa', 'color': Pallete.verdeEsc};
      case CollectibleType.activeDupliItem:
        return {'name': 'activeDupliItem'.tr(), 'desc': 'activeDupliItemDesc'.tr(), 'icon': 'duplicado', 'color': Pallete.vinho};
      case CollectibleType.activeJarroFadas:
        return {'name': 'activeJarroFadas'.tr(), 'desc': 'activeJarroFadasDesc'.tr(), 'icon': 'jarroFada', 'color': Pallete.azulCla};
      case CollectibleType.activeFreezeBomb:
        return {'name': 'activeFreezeBomb'.tr(), 'desc': 'activeFreezeBombDesc'.tr(), 'icon': 'bomba', 'color': Pallete.azulCla};
      case CollectibleType.activeSuperLaser:
        return {'name': 'activeSuperLaser'.tr(), 'desc': 'activeSuperLaserDesc'.tr(), 'icon': 'laser', 'color': Pallete.vinho};
      case CollectibleType.activeBltDetonator:
        return {'name': 'activeBltDetonator'.tr(), 'desc': 'activeBltDetonatorDesc'.tr(), 'icon': 'detonador', 'color': Pallete.vinho};
      case CollectibleType.activeGoldenrazor:
        return {'name': 'activeGoldenrazor'.tr(), 'desc': 'activeGoldenrazorDesc'.tr(), 'icon': 'lamina', 'color': Pallete.laranja};
      case CollectibleType.activeSacrifFamiliar:
        return {'name': 'activeSacrifFamiliar'.tr(), 'desc': 'activeSacrifFamiliarDesc'.tr(), 'icon': 'adagaRitual', 'color': Pallete.verdeEsc};
      case CollectibleType.activeTurretRotate:
        return {'name': 'activeTurretRotate'.tr(), 'desc': 'activeTurretRotateDesc'.tr(), 'icon': 'turret2', 'color': Pallete.azulCla};
      case CollectibleType.activeGlassStaff:
        return {'name': 'activeGlassStaff'.tr(), 'desc': 'activeGlassStaffDesc'.tr(), 'icon': 'cajado', 'color': Pallete.azulCla};
      case CollectibleType.cajadoQuebrado:
        return {'name': 'cajadoQuebrado'.tr(), 'desc': 'cajadoQuebradoDesc'.tr(), 'icon': 'cajadoQuebrado', 'color': Pallete.azulCla};
      case CollectibleType.activeBuracoNegro:
        return {'name': 'activeBuracoNegro'.tr(), 'desc': 'activeBuracoNegroDesc'.tr(), 'icon': 'buracoNegro', 'color': Pallete.branco};
      case CollectibleType.activeLoja:
        return {'name': 'activeLoja'.tr(), 'desc': 'activeLojaDesc'.tr(), 'icon': 'loja', 'color': Pallete.branco};
      case CollectibleType.activeRestart:
        return {'name': 'activeRestart'.tr(), 'desc': 'activeRestartDesc'.tr(), 'icon': 'r', 'color': Pallete.bege};
      case CollectibleType.activeNuke:
        return {'name': 'activeNuke'.tr(), 'desc': 'activeNukeDesc'.tr(), 'icon': 'nuke', 'color': Pallete.cinzaCla};
      case CollectibleType.activeKamikaze:
        return {'name': 'activeKamikaze'.tr(), 'desc': 'activeKamikazeDesc'.tr(), 'icon': 'nuke2', 'color': Pallete.branco};
      case CollectibleType.retribuicao:
        return {'name': 'retribuicao'.tr(), 'desc': 'retribuicaoDesc'.tr(), 'icon': 'retribuicao', 'color': Pallete.vermelho};
      case CollectibleType.machadoArremeco:
        return {'name': 'machadoArremeco'.tr(), 'desc': 'machadoArremecoDesc'.tr(), 'icon': 'machadoArremeco', 'color': Pallete.lilas};
      case CollectibleType.bloquel:
        return {'name': 'bloquel'.tr(), 'desc': 'bloquelDesc'.tr(), 'icon': 'bloquel', 'color': Pallete.cinzaCla};
      case CollectibleType.glifoEquilibrio:
        return {'name': 'glifoEquilibrio'.tr(), 'desc': 'glifoEquilibrioDesc'.tr(), 'icon': 'glifo', 'color': Pallete.azulCla};
      case CollectibleType.activeCleaver:
        return {'name': 'activeCleaver'.tr(), 'desc': 'activeCleaverDesc'.tr(), 'icon': 'machado', 'color': Pallete.vermelho};
      case CollectibleType.bombaBuracoNegro:
        return {'name': 'bombaBuracoNegro'.tr(), 'desc': 'bombaBuracoNegroDesc'.tr(), 'icon': 'bombaBuracoNegro', 'color': Pallete.cinzaEsc};
      case CollectibleType.activeBloodBag:
        return {'name': 'activeBloodBag'.tr(), 'desc': 'activeBloodBagDesc'.tr(), 'icon': 'bloodBag', 'color': Pallete.vermelho};
      case CollectibleType.bltFireHazard:
        return {'name': 'bltFireHazard'.tr(), 'desc': 'bltFireHazardDesc'.tr(), 'icon': 'bltRastroFogo', 'color': Pallete.laranja};
      case CollectibleType.trofelCampeao:
        return {'name': 'trofelCampeao'.tr(), 'desc': 'trofelCampeaoDesc'.tr(), 'icon': 'cinturao', 'color': Pallete.vermelho};
      case CollectibleType.bltBuracoNegro:
        return {'name': 'bltBuracoNegro'.tr(), 'desc': 'bltBuracoNegroDesc'.tr(), 'icon': 'bltBuracoNegro', 'color': Pallete.branco};
      case CollectibleType.bltSparks:
        return {'name': 'bltSparks'.tr(), 'desc': 'bltSparksDesc'.tr(), 'icon': 'raio', 'color': Pallete.azulCla};
      case CollectibleType.familiarLanca:
        return {'name': 'familiarLanca'.tr(), 'desc': 'familiarLancaDesc'.tr(), 'icon': 'lanca', 'color': Pallete.verdeEsc};
      case CollectibleType.activeWoodenCoin:
        return {'name': 'activeWoodenCoin'.tr(), 'desc': 'activeWoodenCoinDesc'.tr(), 'icon': 'coin', 'color': Pallete.marrom};
      case CollectibleType.paralisia:
        return {'name': 'paralisia'.tr(), 'desc': 'paralisiaDesc'.tr(), 'icon': 'seringa', 'color': Pallete.lilas};
      case CollectibleType.devilInside:
        return {'name': 'devilInside'.tr(), 'desc': 'devilInsideDesc'.tr(), 'icon': 'devil', 'color': Pallete.vermelho};
      case CollectibleType.rainbowShot:
        return {'name': 'rainbowShot'.tr(), 'desc': 'rainbowShotDesc'.tr(), 'icon': 'cajado', 'color': Pallete.rosa};
      case CollectibleType.masterOrb:
        return {'name': 'masterOrb'.tr(), 'desc': 'masterOrbDesc'.tr(), 'icon': 'masterOrb', 'color': Pallete.lilas};
      default:
        return {'name': 'Item', 'desc': '???', 'icon': '', 'color': Pallete.cinzaCla};
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

List<CollectibleType> retornaSalas(){
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

List<CollectibleType> retornaItensComuns(player) {
    List<CollectibleType> itens = [
      // Atributos base e cura (do seu exemplo original)
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range,
      CollectibleType.keys,
      CollectibleType.dash,
      CollectibleType.sanduiche,
      
      // Itens Comuns
      CollectibleType.bombas,
      CollectibleType.piercing,
      CollectibleType.fogo,
      CollectibleType.veneno,
      CollectibleType.sangramento,
      CollectibleType.druidScroll,
      CollectibleType.dotBook,
      CollectibleType.chaveNegra,
      CollectibleType.mine,
      CollectibleType.bloodstone,
      CollectibleType.bounce,
      CollectibleType.spectral,
      CollectibleType.cupon,
      CollectibleType.pocaVeneno,
      CollectibleType.rastroFogo,
      CollectibleType.activeHeal,
      CollectibleType.activePoisonBomb,
      CollectibleType.activeBattery,
      CollectibleType.battery,
      CollectibleType.activeArtHp,
      CollectibleType.activeMagicKey,
      CollectibleType.activeHoming,
      CollectibleType.activeGift,
      CollectibleType.activeBandage,
      CollectibleType.activeMidas,
      CollectibleType.boloDinheiro,
      CollectibleType.restock,
      CollectibleType.primeiroInimigoPocaVeneno,
      CollectibleType.activeCircularShots,
      CollectibleType.keysToBombs,
      CollectibleType.activeRandPillUnico,
      CollectibleType.activeBloodBag,
      CollectibleType.activeDullRazor,
      CollectibleType.activeBoxSpider,
      CollectibleType.machadoArremeco,
      CollectibleType.bloquel,
      CollectibleType.activeWoodenCoin,
      CollectibleType.activeTurretRotate,
      CollectibleType.activeDiarreiaExplosiva,
      CollectibleType.jumpersCable,
      CollectibleType.gravitacao,
      CollectibleType.saw,
      CollectibleType.familiarBouncer,
      CollectibleType.familiarPrisma,
      CollectibleType.activeBombardeioUnico,
      CollectibleType.defensiveFairys,
      CollectibleType.foice,
      CollectibleType.familiarAtira,
    ];
    
    return _filtrarPool(itens, player);
  }

  List<CollectibleType> retornaItensRaros(player) {
    List<CollectibleType> itens = [
      CollectibleType.activeRerollItem,
      CollectibleType.goldDmg,
      CollectibleType.activeUnicornUnico,
      CollectibleType.activeTurretUnico,
      CollectibleType.activeD10,
      CollectibleType.orbitalShield,
      CollectibleType.itemExtraBoss,
      CollectibleType.activeSlot,
      CollectibleType.activeFreezeBomb,
      CollectibleType.activeBltDetonator,
      CollectibleType.bumerangue,
      CollectibleType.activeGoldenrazor,
      CollectibleType.activeGlassStaff,
      CollectibleType.activeBuracoNegro,
      CollectibleType.cardinalShot,
      CollectibleType.activeLoja,
      CollectibleType.activeFear,
      CollectibleType.goldShot,
      CollectibleType.familiarFinger,
      CollectibleType.familiarRefletor,
      CollectibleType.berserk,
      CollectibleType.audacious,
      CollectibleType.steroids,
      CollectibleType.cafe,
      CollectibleType.freeze,
      CollectibleType.magicShield,
      CollectibleType.alcool,
      CollectibleType.concentration,
      CollectibleType.soda,
      CollectibleType.defBurst,
      CollectibleType.kinetic,
      CollectibleType.heavyShot,
      CollectibleType.decoy,
      CollectibleType.magicMush,
      CollectibleType.activeMagicKeyChain,
      CollectibleType.molotov,
      CollectibleType.activeTurret,
      CollectibleType.flail,
      CollectibleType.glifoEquilibrio,
      CollectibleType.bltFireHazard,
      CollectibleType.trofelCampeao,
      CollectibleType.familiarLanca,
      CollectibleType.familiarDmgBns,
      CollectibleType.activeRestart,
      CollectibleType.activeCleaver,
      CollectibleType.bombaBuracoNegro,
      CollectibleType.activeKamikaze,
      CollectibleType.retribuicao,
      CollectibleType.activeSacrifFamiliar,
      CollectibleType.masterOrb,
      CollectibleType.voo,
      CollectibleType.activeJarroFadas,
      CollectibleType.retaliar,
      CollectibleType.familiarFreeze,
      CollectibleType.activeJarroDeVida,
      CollectibleType.evasao,
      CollectibleType.activeConvBruta,
      CollectibleType.familiarBlock,
      CollectibleType.revive,
    ];

    return _filtrarPool(itens, player);
  }

  List<CollectibleType> retornaItensEpicos(player) {
    List<CollectibleType> itens = [
      CollectibleType.antimateria,
      CollectibleType.homing,
      CollectibleType.conqCrown,
      CollectibleType.tornado,
      CollectibleType.tripleShot,
      CollectibleType.activeLicantropia,
      CollectibleType.regenShield,
      CollectibleType.activeD6,
      CollectibleType.splitShot,
      CollectibleType.confuseCrit,
      CollectibleType.pregos,
      CollectibleType.bombDecoy,
      CollectibleType.activeHeartConverter,
      CollectibleType.activeDivineShield,
      CollectibleType.activeRitualDagger,
      CollectibleType.activeMagicMirror,
      CollectibleType.charmOnCrit,
      CollectibleType.freezeDash,
      CollectibleType.activeStunBomb,
      CollectibleType.activeFairy,
      CollectibleType.activeUnicorn,
      CollectibleType.activeBombardeio,
      CollectibleType.curaCrit,
      CollectibleType.laser,
      CollectibleType.wave,
      CollectibleType.activeSuborno,
      CollectibleType.pilNanicolina,
      CollectibleType.encolheOnCrit,
      CollectibleType.familiarGlitch,
      CollectibleType.familiarDmgBuff,
      CollectibleType.familiarCircProt,
      CollectibleType.glitterBomb,
      CollectibleType.clusterShot,
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
      CollectibleType.activeScroll,
      CollectibleType.familiarMastery,
      CollectibleType.activeGoldenBox,
      CollectibleType.activePa,
      CollectibleType.activeBoxOfFriends,
      CollectibleType.activeDupliItem,
      CollectibleType.activeSuperLaser,
      CollectibleType.activeNuke,
      CollectibleType.bltBuracoNegro,
      CollectibleType.bltSparks,
      CollectibleType.paralisia,
      CollectibleType.devilInside,
      CollectibleType.rainbowShot,
    ];

    return _filtrarPool(itens, player);
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
            game.world.add(FloatingText(
                text: text,
                position: player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.vermelho,
              ));
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
            player.reviveIcon = GameSprite(
              imagePath: 'sprites/condicoes/cruz.png',
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
          text = "soda";
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
            player.cuponIcon = GameSprite(
              imagePath: 'sprites/condicoes/cupon.png',
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
          //  print('tem item');
            if(currentItems[0]!.maxCharge == 1){
             // print('tem item custo 1');
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
          player.curaHp(player.maxHealth - player.healthNotifier.value);
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
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextLevel, 
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
               //   print('item raro');
                }else{
                  novoTipo = pool[Random().nextInt(pool.length)];
               //   print('item comum');
                }
                Vector2 pos = item.position.clone();
                
                item.removeFromParent();
                
                game.world.add(Collectible(position: pos, type: novoTipo));
                game.onInteractAction = null;
                game.canInteractNotifier.value = false;
                
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
            player.dmgBuffIcon = GameSprite(
              imagePath: 'sprites/condicoes/espada.png',
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
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextLevel, 
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
            cor:Pallete.laranja,
            corBorda:Pallete.marrom
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
            cor:Pallete.verdeCla,
            corBorda:Pallete.verdeEsc
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
              hbSize: player.isHeavyShot ? Vector2.all(16) : Vector2.all(4),
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
              txt = 'dmg'.tr();
              break;
            case 1:
              player.increaseFireRate(0.8);
              txt = 'fire_rate'.tr();
              break;
            case 2:
              player.increaseMovementSpeed(1.2);
              txt = 'moveSpeed'.tr();
              break;
            case 3:
              player.increaseRange(1.2);
              txt = 'range'.tr();
              break;
            case 4:
              player.critChance += 5;
              txt = 'critChance'.tr();
              break;
            case 5:
              player.critDamage *= 1.15;
              txt = 'critDamage'.tr();
              break;
            case 6:
              player.increaseHp(2);
              txt = 'health'.tr();
              break;
            case 7:
              player.dot *= 1.5;
              txt = 'dot'.tr();
              break;
          }
          
          game.world.add(FloatingText(
                text: txt,
                position: player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.branco,
              ));
          text = txt;
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeRandPillUnico:
          String txt = '';
          int rnd = Random().nextInt(8);

          switch(rnd){
            case 0:
              player.increaseDamage(1.2);
              txt = 'dmg'.tr();
              break;
            case 1:
              player.increaseFireRate(0.8);
              txt = 'fire_rate'.tr();
              break;
            case 2:
              player.increaseMovementSpeed(1.2);
              txt = 'moveSpeed'.tr();
              break;
            case 3:
              player.increaseRange(1.2);
              txt = 'range'.tr();
              break;
            case 4:
              player.critChance += 5;
              txt = 'critChance'.tr();
              break;
            case 5:
              player.critDamage *= 1.15;
              txt = 'critDamage'.tr();
              break;
            case 6:
              player.increaseHp(2);
              txt = 'health'.tr();
              break;
            case 7:
              player.dot *= 1.5;
              txt = 'dot'.tr();
              break;
          }

          game.world.add(FloatingText(
                text: txt,
                position: player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.branco,
              ));

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
            cor:Pallete.vermelho,
            corBorda:Pallete.vinho
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
          player.criaVisual(reset : true,image:player.classImage,color: player.classColor);
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
            player.reviveIcon = GameSprite(
              imagePath: 'sprites/condicoes/cruz.png',
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
          game.world.add(FloatingText(
                text: "\$$c",
                position: player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.vermelho,
              ));
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
            cor: Pallete.amarelo,
            corBorda: Pallete.laranja
            ));
          }
          text = "activeGoldenBox".tr();
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeSlot:
          if(game.coinsNotifier.value < 2){
            return {
              'text': "noCoins".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{
            player.collectCoin(-2);
            player.slotMachine(2,isPortatil: true);
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

            game.nextRoomReward = CollectibleType.nextLevel;
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
            CollectibleType.bank, CollectibleType.alquimista, CollectibleType.nextLevel, 
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
            cor:Pallete.lilas,
            corBorda:Pallete.azulCla
          ));
          text = "activeFreezeBomb";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeSuperLaser:
          final dir = player.velocityDash;
          final angle = atan2(player.velocityDash.y, player.velocityDash.x); 
          player.criaLaserDirecional(dir,angle,player.damage*5,0.5,2,16);
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
            player.dmgGoldBuffIcon = GameSprite(
              imagePath: 'sprites/condicoes/espada.png',
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
            game.nextRoomReward = CollectibleType.nextLevel;
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
            radius:300,
            cor:Pallete.amarelo,
            corBorda:Pallete.vermelho
          ));
          text = "activeNuke";
          //color = Pallete.vermelho;
          break;

        case CollectibleType.activeKamikaze:
          if(player.healthNotifier.value <= 1){
            return {
              'text': "noHp".tr(), 
              'color': Pallete.branco, 
              'sucesso': false
            };
          }else{  
            game.world.add(Explosion(
              position: player.position.clone(),
              damagesPlayer:false, 
              damage: 500,
              radius:300,
              cor:Pallete.amarelo,
              corBorda:Pallete.vermelho
            ));
            int dmg = 2;
            if(player.classImage == 'sprites/chars/bomberman.png'){
              dmg = 1;
            }
            player.takeDamage(dmg);
            text = "activeKamikaze";
          }
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

        case CollectibleType.machadoArremeco:
          player.adagaChance = true;
          player.increaseFireRate(0.8);
          text = "machadoArremeco";
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

        case CollectibleType.masterOrb:
          player.masterOrb = 1.5;
          text = "masterOrb";
          //color = Pallete.vermelho;
          break;   

        default:
          text = "";
          break;
       }
       return {'text': text, 'color': Pallete.branco, 'sucesso': true};
   }
}