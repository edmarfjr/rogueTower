import 'dart:math';

import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/i18n.dart';
//import 'package:towerrogue/game/components/core/interact_button.dart';
import 'package:towerrogue/game/components/effects/floating_text.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';
import 'collectible.dart';

class Chest extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool _isOpen = false;
  bool isLock;
  // Guardamos a referência do ícone para trocar (fechado -> aberto)
  GameSprite? _iconComponent;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 16.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão

  Chest({required Vector2 position, this.isLock = false}) 
      : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Visual (Baú Fechado)
    if(isLock){
      _updateIcon('sprites/gameObjs/bauTrancado.png', Pallete.laranja);
    }else{
      _updateIcon('sprites/gameObjs/bau.png', Pallete.marrom);
    } 

    // 2. Hitbox Sólida (Player não atravessa o baú)
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));

    priority = position.y.toInt();
  }

  void _updateIcon(String icon, Color color) {
    if (_iconComponent != null) _iconComponent!.removeFromParent();
    
    _iconComponent = GameSprite(
      imagePath: icon,
      color: color,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );
    add(_iconComponent!);

    add(ShadowComponent(parentSize: size));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Calcula distância para o Player
    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _pickupRange) {
      if (!_isInfoVisible && ! _isOpen) _showInfo();
    } else {
      if (_isInfoVisible) _hideInfo();
    }
    
  }

  void _showInfo() {
    if(gameRef.canInteractNotifier.value) return;
    _isInfoVisible = true;
   
    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);

    gameRef.onInteractAction = () {
        _openChest();
        _hideInfo(); 
      };

    gameRef.canInteractNotifier.value = true;

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
    gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;
  }


  void _openChest() {
    if (gameRef.keysNotifier.value <= 0 && isLock && !gameRef.player.hasChaveNegra) {
      gameRef.world.add(FloatingText(
        text: "noKeys".tr(),
        position: position.clone(), 
        color: Pallete.branco,
        fontSize: 12,
      ));
      return;
    }

    Color cor = Pallete.marrom;

    if(isLock){
       cor = Pallete.laranja;
    }
    
    _updateIcon('sprites/gameObjs/bauAberto.png', cor);

    _isOpen = true;

    gameRef.itensComunsPoolCurrent.shuffle();
    List<CollectibleType> possibleRewards = gameRef.itensComunsPoolCurrent;
    
    // Consome a chave
    if(isLock){
      gameRef.itensRarosPoolCurrent.shuffle();
      possibleRewards = gameRef.itensRarosPoolCurrent;
      if(gameRef.keysNotifier.value <=0 && gameRef.player.hasChaveNegra){
        gameRef.player.takeDamage(1);
      }
      gameRef.keysNotifier.value--;
    }
    
    final CollectibleType lootType = possibleRewards[0];

    if(isLock) {
      gameRef.itensRarosPoolCurrent.remove(lootType);
    } else {
      gameRef.itensComunsPoolCurrent.remove(lootType);
    }
    // 3. Cria o item sorteado
    final item = Collectible(
      position: position.clone(),
      type: lootType,
    );
    gameRef.world.add(item);
    double direcaoX = (Random().nextBool() ? 1 : -1) * 30.0;
    double altura = Random().nextDouble() * 100 + 250 * -1;
    item.pop(Vector2(direcaoX, -16), altura:altura);
    _hideInfo();
    //removeFromParent();
  }
  
}
