import 'package:TowerRogue/game/components/core/i18n.dart';
import 'package:TowerRogue/game/components/effects/floating_text.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import 'player.dart';
import 'collectible.dart';
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../core/interact_button.dart';

class Door extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool isOpen = false;
  bool trancada;
  bool bloqueada;
  final CollectibleType rewardType;
  final double raioBotao = 60;
  bool botaoAtivo = false;

  // CORREÇÃO 1: Mudamos de 'late GameIcon' para 'GameIcon?' (pode ser nulo)
  GameIcon? _doorIcon;
  GameIcon? _lockIcon;
  GameIcon? _blockIcon;

  InteractButton? _currentButton;

  Door({
    required Vector2 position, 
    required this.rewardType,
    this.trancada = false,
    this.bloqueada = false,
  }): super(position: position, size: Vector2(60, 40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _updateDoorIcon(MdiIcons.tunnel, Pallete.cinzaEsc);

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

  }

  void _updateDoorIcon(IconData icon, Color color) {
    if (_doorIcon != null) {
      _doorIcon!.removeFromParent();
    }
    if (_lockIcon != null) {
      _lockIcon!.removeFromParent();
    }
    if (_blockIcon != null) {
      _blockIcon!.removeFromParent();
    }

    _doorIcon = GameIcon(
      icon: icon,
      color: color,
      size: size, 
      anchor: Anchor.center,
      position: size / 2,
    );
    
    add(_doorIcon!);

    if(trancada){
      _lockIcon = GameIcon(
        icon: Icons.lock,
        color: Pallete.cinzaCla,
        size: size/2, 
        anchor: Anchor.center,
        position: size / 2,
      );
      
      add(_lockIcon!);
    }

    if(bloqueada){
      _blockIcon = GameIcon(
        icon: Icons.terrain,
        color: Pallete.marrom,
        size: size, 
        anchor: Anchor.center,
        position: size / 2 + Vector2(0,15),
      );
      
      add(_blockIcon!);
    }
  }

  void _addRewardIcon() {
    IconData iconData;
    
    switch (rewardType) {
      case CollectibleType.potion:
        iconData = Icons.favorite;
        break;
      case CollectibleType.coin:
        iconData = Icons.attach_money;
        break;
      case CollectibleType.key:
        iconData = Icons.vpn_key;
        break;
      case CollectibleType.bomba:
        iconData = MdiIcons.bomb;
        break;
      case CollectibleType.chest:
        iconData = MdiIcons.packageVariantClosed;
        break;
      case CollectibleType.rareChest:
        iconData = MdiIcons.treasureChest;
        break;
      case CollectibleType.shop:
        iconData = Icons.store_mall_directory;
        break;
      case CollectibleType.shield:
        iconData = Icons.gpp_bad;
        break;
      case CollectibleType.boss:
        iconData = MdiIcons.skull;
        break;
      case CollectibleType.healthContainer:
        iconData = Icons.favorite_outline;
        break;
      case CollectibleType.nextlevel:
        iconData = MdiIcons.stairsUp;
        break;
      case CollectibleType.bank:
        iconData = MdiIcons.bank;
        break;
      case CollectibleType.alquimista:
        iconData = MdiIcons.flaskEmptyOffOutline;
        break;
      default:
        iconData = Icons.help_outline;
    }
    
    add(GameIcon(
      icon: iconData,
      color: Pallete.branco,
      size: Vector2(20, 20),
      position: Vector2(size.x / 2, -20), 
      anchor: Anchor.center,
    ));
  }

  void destranca(){
    trancada = false;
    _updateDoorIcon(MdiIcons.tunnelOutline, Pallete.lilas);
  }

  void desbloqueia(){
    bloqueada = false;
    _updateDoorIcon(MdiIcons.tunnelOutline, Pallete.lilas);
  }

  void open() {
    if (isOpen) return;
    isOpen = true;
    
    // Troca para porta aberta
    _updateDoorIcon(MdiIcons.tunnelOutline, Pallete.lilas);
    
    _addRewardIcon();
    
  }  

  void update(double dt) {
    double dist = position.distanceTo(gameRef.player.position);
    if (dist <= raioBotao && !botaoAtivo){
      _showButton();
      botaoAtivo = true;
    }else if (dist > raioBotao && botaoAtivo){
      _hideButton();
      botaoAtivo = false;
    }
  }

/*
 @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Se o jogador chegou perto e a porta está pronta para ser usada
    if (other is Player && isOpen) {
      _showButton();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    
    // Se o jogador se afastar da porta, esconde o botão
    if (other is Player) {
      _hideButton();
    }
  }
*/

  void _showButton() {
    if (_currentButton != null) return;

    _currentButton = InteractButton(
      onTrigger: () {
        // Lógica original de mudar de sala
        if(trancada){
          if(gameRef.keysNotifier.value>0){
            destranca();
          }else{
            gameRef.world.add(FloatingText(
              text: 'trancado'.tr(),
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
          }
        }else if(bloqueada){
          gameRef.world.add(FloatingText(
              text: 'bloqueado'.tr(),
              position: position.clone(), 
              color: Pallete.branco,
              fontSize: 12,
            ));
        }else{
          gameRef.transitionEffect.startTransition(() {
            gameRef.nextLevel(rewardType);
          });
        }
        
        
        // Esconde o botão após clicar
        _hideButton();
      },
    );

    // Posiciona o botão acima da porta
    _currentButton!.position = Vector2(size.x / 2, -40); 
    
    // OPCIONAL: Se quiser mudar o texto para "ENTRAR" no InteractButton
    // (Caso você tenha adicionado uma propriedade 'text' no construtor dele)
    // _currentButton!.text = "ENTRAR"; 
    
    add(_currentButton!);
  }

  void _hideButton() {
    if (_currentButton != null) {
      _currentButton!.removeFromParent();
      _currentButton = null;
    }
  }
}