import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
import 'package:towerrogue/game/components/effects/floating_text.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import 'collectible.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../core/interact_button.dart';

class Door extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool isOpen = false;
  bool trancada;
  bool bloqueada;
  bool bites;
  final CollectibleType rewardType;
  final double raioBotao = 60;
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
    
    switch (rewardType) {
      case CollectibleType.potion: iconData = 'sprites/doorIcons/hpCheio.png'; break;
      case CollectibleType.coin: iconData = 'sprites/doorIcons/coin.png'; break;
      case CollectibleType.key: iconData = 'sprites/doorIcons/key.png'; break;
      case CollectibleType.bomba: iconData = 'sprites/doorIcons/bomb.png'; break;
      case CollectibleType.chest: iconData = 'sprites/doorIcons/bau.png'; break;
      case CollectibleType.rareChest: iconData = 'sprites/doorIcons/bauTrancado.png'; break;
      case CollectibleType.shop: iconData = 'sprites/doorIcons/loja.png'; break;
      case CollectibleType.shield: iconData = 'sprites/doorIcons/escudo.png'; break;
      case CollectibleType.boss: iconData = 'sprites/doorIcons/boss.png'; break;
      case CollectibleType.healthContainer: iconData = 'sprites/doorIcons/hpVazio.png'; break;
      case CollectibleType.nextLevel: iconData = 'sprites/doorIcons/nextLevel.png'; break;
      case CollectibleType.bank: iconData = 'sprites/doorIcons/bank.png'; break;
      case CollectibleType.alquimista: iconData = 'sprites/doorIcons/alquimista.png'; break;
      case CollectibleType.desafio: iconData = 'sprites/doorIcons/desafio.png'; break;
      case CollectibleType.darkShop: iconData = 'sprites/doorIcons/lojaEvil.png'; break;
      case CollectibleType.doacaoSangue: iconData = 'sprites/doorIcons/blood.png'; break;
      case CollectibleType.slotMachine: iconData = 'sprites/doorIcons/slot.png'; break;
      default: iconData = 'sprites/doorIcons/hpCheio';
    }
    
    rewardIcon = GameSprite(
      imagePath: iconData,
      color: Pallete.branco,
      size: Vector2(16, 16),
      position: Vector2(size.x / 2, -12), 
      anchor: Anchor.center,
    );
    add(rewardIcon!);
  }

  void destranca(){
    trancada = false;
    _updateDoorIcon('sprites/tileset/portaAberta.png', Pallete.lilas);
  }

  void desbloqueia(){
    bloqueada = false;
    _updateDoorIcon('sprites/tileset/portaBloqueada.png', Pallete.lilas);
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

    final screenSize = gameRef.camera.viewport.size;
    final hudPosition = Vector2(screenSize.x/2-(5*16),screenSize.y/2-(3.5*16));

    _currentButton = InteractButton(
      position: hudPosition,
      onTrigger: () {
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
            Rectangle.fromLTWH(-2000, -2000, 4000, 4000),
            considerViewport: false,
          );


          gameRef.transitionEffect.startTransition(() {
            _isEntering = false; 
            
            // RESET DO ZOOM E POSIÇÃO
            gameRef.camera.viewfinder.zoom = 1.0; 
            gameRef.camera.viewfinder.position = Vector2.zero(); 
            
            // DEVOLVE A TRAVA ORIGINAL DA CÂMERA
            gameRef.camera.setBounds(
              Rectangle.fromLTWH(-60, -60, 120, 130),
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
      },
    );

    gameRef.camera.viewport.add(_currentButton!);
  }

  void _hideButton() {
    if (_currentButton != null) {
      gameRef.camera.viewport.remove(_currentButton!);
      _currentButton = null;
    }
  }
}