import 'dart:math';

import 'package:TowerRogue/game/components/core/interact_button.dart';
import 'package:TowerRogue/game/components/effects/shadow_component.dart';
import 'package:flame/events.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../core/pallete.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart';
import 'player.dart';
import '../core/game_icon.dart';
import 'collectible.dart';

class Chest extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  bool _isOpen = false;
  bool isLock;
  InteractButton? _currentButton;
  // Guardamos a referência do ícone para trocar (fechado -> aberto)
  GameIcon? _iconComponent;

  // Controle de Interface
  bool _isInfoVisible = false;
  final double _pickupRange = 60.0; // Distância para aparecer o botão
  late Component _infoGroup; // Grupo que contém texto e botão

  Chest({required Vector2 position, this.isLock = false}) 
      : super(position: position, size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // 1. Visual (Baú Fechado)
    if(isLock){
      _updateIcon(MdiIcons.treasureChest, Pallete.laranja);
    }else{
      _updateIcon(MdiIcons.packageVariantClosed, Pallete.marrom);
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

  void _updateIcon(IconData icon, Color color) {
    if (_iconComponent != null) _iconComponent!.removeFromParent();
    
    _iconComponent = GameIcon(
      icon: icon,
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
    _isInfoVisible = true;
   
    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);


    // 3. Botão de Pegar
    if (_currentButton != null) return;
    final screenSize = gameRef.camera.viewport.size;
    final hudPosition = Vector2(screenSize.x - 150, screenSize.y - 170);

    _currentButton = InteractButton(
      position: hudPosition,
      onTrigger:(){
        _openChest();
        _hideInfo(); 
      } ,
    );

    gameRef.camera.viewport.add(_currentButton!);

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


  void _openChest() {
    if (gameRef.keysNotifier.value <= 0 && isLock && !gameRef.player.hasChaveNegra) {
      return;
    }
    _isOpen = true;
    
    // Consome a chave
    if(isLock){
      if(gameRef.keysNotifier.value <=0 && gameRef.player.hasChaveNegra){
        gameRef.player.takeDamage(1);
      }
      gameRef.keysNotifier.value--;
    }
    gameRef.itensComunsPoolCurrent.shuffle();
    List<CollectibleType> possibleRewards = gameRef.itensComunsPoolCurrent;

    if(isLock){
      gameRef.itensComunsPoolCurrent.shuffle();
      possibleRewards = gameRef.itensRarosPoolCurrent;
    } 

    final CollectibleType lootType = possibleRewards[0];

    if(isLock) {
      gameRef.itensRarosPoolCurrent.remove(lootType);
    } else {
      gameRef.itensComunsPoolCurrent.remove(lootType);
    }
    // 3. Cria o item sorteado
    final item =Collectible(
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
