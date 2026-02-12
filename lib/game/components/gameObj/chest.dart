import 'dart:math';

import 'package:TowerRogue/game/components/core/interact_button.dart';
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
   

    // Grupo para facilitar remover tudo de uma vez
    _infoGroup = PositionComponent(position: Vector2(size.x / 2, -10), anchor: Anchor.bottomCenter);


    // 3. Botão de Pegar
    final btn = InteractButton(
      onTrigger: _openChest,
    )..position = Vector2(0, -50); 

    _infoGroup.add(btn);

    add(_infoGroup);
  }

  void _hideInfo() {
    _isInfoVisible = false;
    if (contains(_infoGroup)) {
      remove(_infoGroup);
    }
  }


  void _openChest() {
    if (gameRef.keysNotifier.value <= 0 && isLock) {
      return;
    }
    _isOpen = true;
    
    // Consome a chave
    if(isLock)gameRef.keysNotifier.value--;
    
    // Muda visual
    //_updateIcon(Icons.lock_open, const Color(0xFFF0E68C)); 
    
    final rng = Random();

    
    List<CollectibleType> possibleRewards = retornaItensComuns();

    if(isLock) possibleRewards = retornaItensRaros(game.player);

    // 2. Sorteia um índice aleatório da lista (0 até o tamanho da lista - 1)
    // rng.nextInt(N) retorna um número de 0 a N-1.
    final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];

    // 3. Cria o item sorteado
    gameRef.world.add(Collectible(
      position: position + Vector2(0, -40),
      type: lootType,
    ));

    removeFromParent();
  }
  
}
