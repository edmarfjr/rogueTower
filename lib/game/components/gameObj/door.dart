import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/effects/floating_text.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import 'collectible.dart';
//import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../core/interact_button.dart';

class Door extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool isOpen = false;
  bool trancada;
  bool bloqueada;
  bool bites;
  final CollectibleType rewardType;
  final double raioBotao = 24;
  bool botaoAtivo = false;

  // --- NOVA VARIÁVEL DE CONTROLE DE ZOOM ---
  bool _isEntering = false;

  GameSprite? _doorIcon;
  GameSprite? _lockIcon;
  GameSprite? _blockIcon;
  GameSprite? _bitesIcon;
  GameSprite? rewardIcon;

  InteractButton? _currentButton;

  Door({
    required Vector2 position, 
    required this.rewardType,
    this.trancada = false,
    this.bloqueada = false,
    this.bites = false,
  }): super(position: position, size: Vector2(16, 16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _updateDoorIcon('sprites/tileset/portaFechada.png', Pallete.cinzaEsc);

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

    priority = position.y.toInt();
  }

  void _updateDoorIcon(String image, Color color) {
    if (_doorIcon != null) {
      _doorIcon!.removeFromParent();
    }
    if (_lockIcon != null) {
      _lockIcon!.removeFromParent();
    }
    if (_blockIcon != null) {
      _blockIcon!.removeFromParent();
    }

    _doorIcon = GameSprite(
          imagePath: image,
          size: size,
          color: color, 
          anchor: Anchor.center,
          position: size / 2
        );
    
    add(_doorIcon!);

    if(trancada){
      _lockIcon = GameSprite(
          imagePath: 'sprites/tileset/portaTrancada.png',
          size: size,
          color: color, 
          anchor: Anchor.center,
          position: size / 2
        );
      add(_lockIcon!);
    }

    if(bloqueada){
      _blockIcon = GameSprite(
        imagePath: 'sprites/tileset/bloqueio.png',
        color: Pallete.marrom,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      );
      add(_blockIcon!);
    }

      if(bites && isOpen){
      _bitesIcon = GameSprite(
        imagePath: 'sprites/tileset/portaBites.png',
        color: Pallete.lilas,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      );
      add(_bitesIcon!);
    }
  }

  void _addRewardIcon() {
    String iconData;
    Color cor = Pallete.branco;
    String nome = '';
    String descr = '';
    
    switch (rewardType) {
      case CollectibleType.potion: 
        iconData = 'sprites/doorIcons/hpCheio.png'; 
        cor = Pallete.vermelho;
        nome = 'cura';
        descr = 'curaDesc';
        break;
      case CollectibleType.coin: 
        iconData = 'sprites/doorIcons/coin.png'; 
        cor = Pallete.amarelo;
        nome = 'moeda';
        descr = 'moedaDesc';
        break;
      case CollectibleType.key: 
        iconData = 'sprites/doorIcons/key.png'; 
        cor = Pallete.amarelo;
        nome = 'chave';
        descr = 'chaveDesc';
        break;
      case CollectibleType.bomba: 
        iconData = 'sprites/doorIcons/bomb.png';
        cor = Pallete.lilas;
        nome = 'bomba';
        descr = 'bombaDesc';
        break;
      case CollectibleType.chest: 
        iconData = 'sprites/doorIcons/bau.png'; 
        cor = Pallete.marrom;
        nome = 'bau';
        descr = 'bauDesc';
        break;
      case CollectibleType.rareChest: 
        iconData = 'sprites/doorIcons/bauTrancado.png'; 
        cor = Pallete.laranja;
        nome = 'bauRaro';
        descr = 'bauRaroDesc';
        break;
      case CollectibleType.shop: 
        iconData = 'sprites/doorIcons/loja.png'; 
        cor = Pallete.marrom;
        nome = 'shop';
        descr = 'shopDesc';
        break;
      case CollectibleType.shield: 
        iconData = 'sprites/doorIcons/escudo.png'; 
        cor = Pallete.cinzaCla;
        nome = 'escudo';
        descr = 'escudoDesc';
        break;
      case CollectibleType.boss: 
        iconData = 'sprites/doorIcons/boss.png'; 
        cor = Pallete.vermelho;
        nome = 'boss';
        descr = 'bossDesc';
        break;
      case CollectibleType.healthContainer: 
        iconData = 'sprites/doorIcons/hpVazio.png'; 
        cor = Pallete.vermelho;
        nome = 'conteinerVida';
        descr = 'conteinerVidaDesc';
        break;
      case CollectibleType.nextLevel: 
        iconData = 'sprites/doorIcons/nextLevel.png'; 
        cor = Pallete.branco;
        nome = 'proxLevel';
        descr = 'proxLevelDesc';
        break;
      case CollectibleType.bank: 
        iconData = 'sprites/doorIcons/bank.png'; 
        cor = Pallete.laranja;
        nome = 'bank';
        descr = 'bankDesc';
        break;
      case CollectibleType.alquimista: 
        iconData = 'sprites/doorIcons/alquimista.png'; 
        cor = Pallete.azulCla;
        nome = 'alquimista';
        descr = 'alquimistaDesc';
        break;
      case CollectibleType.desafio: 
        iconData = 'sprites/doorIcons/desafio.png'; 
        cor = Pallete.vermelho;
        nome = 'desafio';
        descr = 'desafioDesc';
        break;
      case CollectibleType.darkShop: 
        iconData = 'sprites/doorIcons/lojaEvil.png'; 
        cor = Pallete.vermelho;
        nome = 'darkShop';
        descr = 'darkShopDesc';
        break;
      case CollectibleType.doacaoSangue: 
        iconData = 'sprites/doorIcons/blood.png'; 
        cor = Pallete.vermelho;
        nome = 'doaSangue';
        descr = 'doaSangueDesc';
        break;
      case CollectibleType.slotMachine: 
        iconData = 'sprites/doorIcons/slot.png'; 
        cor = Pallete.laranja;
        nome = 'slot';
        descr = 'slotDesc';
        break;
      default: iconData = 'sprites/doorIcons/hpCheio';
    }
    
    rewardIcon = GameSprite(
      imagePath: iconData,
      color: cor,
      size: Vector2(16, 16),
      position: Vector2(size.x / 2, -12), 
      anchor: Anchor.center,
    );
    add(rewardIcon!);

    final textDesc = TextBoxComponent(
      text: descr.tr().toLowerCase(),
      textRenderer: Pallete.textoDescricaoGigante, // 1. Usa a fonte gigante
      anchor: Anchor.bottomCenter,
      align: Anchor.center,
      position: Vector2(size.x / 2, -16),
      scale: Vector2.all(0.25), // 2. Encolhe TUDO para o tamanho normal
      
      boxConfig: const TextBoxConfig(
        maxWidth: 600.0, // 3. A caixa agora precisa ser 4x maior (250 * 4 = 1000)
        timePerChar: 0.0, 
      ),
    );

    double espacoEntreTextos = 1.0;
    double posicaoYDoTitulo = (textDesc.position.y - textDesc.size.y - espacoEntreTextos)/4;

    // 2. Nome do Item
    final textName = TextComponent(
      text: nome.tr().toUpperCase(),
      textRenderer: Pallete.textoDanoCritico,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, posicaoYDoTitulo - 8),
    );

    add(textName);
    add(textDesc);
  }

  

  void destranca(){
    trancada = false;
    _updateDoorIcon('sprites/tileset/portaAberta.png', Pallete.lilas);
  }

  void desbloqueia(){
    bloqueada = false;
    if(isOpen){
      _updateDoorIcon('sprites/tileset/portaAberta.png', Pallete.lilas);
    }else{
      _updateDoorIcon('sprites/tileset/portaTrancada.png', Pallete.lilas);
    }
    
  }

  void open() {
    if (isOpen) return;
    isOpen = true;
    _updateDoorIcon('sprites/tileset/portaAberta.png', Pallete.lilas);
    _addRewardIcon();
  }  

  void close() {
    if (!isOpen) return;
    isOpen = false;
    _updateDoorIcon('sprites/tileset/portaTrancada.png', Pallete.cinzaEsc);
    rewardIcon!.removeFromParent();
  }  

  @override
  void update(double dt) {
    super.update(dt); 

    if (_isEntering) {
      if (gameRef.camera.viewfinder.zoom < 3.0) {
        gameRef.camera.viewfinder.zoom += dt * 2.0; 
      }
    }

    double dist = position.distanceTo(gameRef.player.position);
    
    if (dist <= raioBotao && !botaoAtivo && !bloqueada && isOpen) {
      _showButton();
      botaoAtivo = true;
    } else if (dist > raioBotao && botaoAtivo) {
      _hideButton();
      botaoAtivo = false;
    }
    
  }

  void _showButton() {
    if (_currentButton != null) return;

    gameRef.onInteractAction =() {
      if(trancada){
        if(gameRef.keysNotifier.value>0){
          gameRef.keysNotifier.value --;
          destranca();
        }else{
          if(gameRef.player.hasChaveNegra){
            gameRef.world.add(FloatingText(
              text: 'ai'.tr(),
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
            gameRef.player.takeDamage(1);
            destranca();
          }else{
            gameRef.world.add(FloatingText(
              text: 'trancado'.tr(),
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
          }
        }
      } else if(bloqueada){
        // ... (Sua lógica da bomba se mantém igual) ...
        gameRef.world.add(FloatingText(
            text: 'bloqueado'.tr(),
            position: position.clone(), 
            color: Pallete.branco,
            fontSize: 12,
          ));
      } else {
        // ==========================================
        // O JOGADOR VAI ENTRAR NA PORTA
        // ==========================================
        if(bites){
          gameRef.world.add(FloatingText(
              text: 'ai'.tr(),
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
          gameRef.player.takeDamage(1);
        }
        
        _hideButton(); 
        
        //AGIOTA
        if (gameRef.isCurrentRoomBank && gameRef.dividaNotifier.value > 0) {
            gameRef.player.position.y += 50; 
            gameRef.roomManager.triggerAgiotaTrap();
            return; 
        }
        _isEntering = true; 
        
        // LIBERTA A CÂMERA: Expande os limites para ela conseguir ir até a porta
        gameRef.camera.setBounds(
          Rectangle.fromCenter(center: Vector2.zero(), size: Vector2(4000, 4000)),
          considerViewport: false,
        );


        gameRef.transitionEffect.startTransition(() {
          _isEntering = false; 
          
          // RESET DO ZOOM E POSIÇÃO
          gameRef.camera.viewfinder.zoom = 1.0; 
          gameRef.camera.viewfinder.position = Vector2.zero(); 
          
          // DEVOLVE A TRAVA ORIGINAL DA CÂMERA
          gameRef.camera.setBounds(
            Rectangle.fromCenter(center: Vector2.zero(), size: Vector2(100, 100)),
            considerViewport: false,
          );
          if(gameRef.player.hasCupon && gameRef.nextRoomReward == CollectibleType.shop){
            gameRef.player.hasCupon = false;

            if(gameRef.player.cuponIcon !=null){
              gameRef.player.numIcons --;
              gameRef.player.cuponIcon!.removeFromParent();
              gameRef.player.cuponIcon = null;
            }
          }
          if(gameRef.player.hasShieldRegen)gameRef.player.increaseShield();
          if(gameRef.player.tempDmgBonus > 0){
            gameRef.player.tempDmgBonus = 0;

            if(gameRef.player.dmgBuffIcon !=null){
              gameRef.player.numIcons --;
              gameRef.player.dmgBuffIcon!.removeFromParent();
              gameRef.player.dmgBuffIcon = null;
            }
          }
          if(gameRef.player.tempDmgGoldBonus > 0){
            gameRef.player.tempDmgGoldBonus = 0;

            if(gameRef.player.dmgGoldBuffIcon !=null){
              gameRef.player.numIcons --;
              gameRef.player.dmgGoldBuffIcon!.removeFromParent();
              gameRef.player.dmgGoldBuffIcon = null;
            }
          }
          if(gameRef.player.regenCount > 0){
            game.player.curaHp(1);
            gameRef.player.regenCount -= 1;
          }
          gameRef.nextLevel(rewardType);
        });
      }
    };
    gameRef.canInteractNotifier.value = true;
  }

  void _hideButton() {
   gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;
  }
}