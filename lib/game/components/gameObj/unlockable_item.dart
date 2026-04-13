import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
//import 'package:towerrogue/game/components/core/interact_button.dart'; // Import do novo botão
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import './player.dart';
import '../core/game_icon.dart';
import 'collectible.dart';
import '../effects/floating_text.dart';

class UnlockableItem extends PositionComponent with HasGameRef<TowerGame> {
  final String id;            
  final CollectibleType type;  
  final int soulCost;          
  
  bool _isUnlocked = false;
  bool _isPicked = false;
  
  // Controle de Interface (Igual ao Collectible)
  bool _isInfoVisible = false;
  final double _interactRange = 48.0;

  TextComponent? _nameText;
  TextComponent? _descText;

  UnlockableItem({
    required Vector2 position,
    required this.id,
    required this.type,
    required this.soulCost,
  }) : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _isUnlocked = gameRef.progress.isUnlocked(id);
    _updateVisuals();
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center,
      position: size/2,
      isSolid: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // Checa distância do player para mostrar/esconder o botão
    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= _interactRange) {
      if (!_isInfoVisible && !_isPicked){
        _showButton();
        _showItemInfo();  
      } 
    } else {
      if (_isInfoVisible){
        _hideButton();
        _hideItemInfo();
      }
    }
    priority = position.y.toInt();
  }

  void _showItemInfo() {
    final attrs = Collectible.getAttributes(type); 
    String itemName = attrs['name'] ?? "Unknown Item";
    String itemDesc = attrs['desc'] ?? "Unknown Description";

    _nameText = TextComponent(
      text: itemName.toUpperCase(),
      textRenderer: Pallete.textoDanoCritico,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, -12), 
    );
    add(_nameText!);

    _descText = TextComponent(
      text: itemDesc,
      textRenderer: Pallete.textoPadrao,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, -5), 
    );
    add(_descText!);
  }

  void _hideItemInfo() {
    if (_nameText != null && _nameText!.parent != null) {
      remove(_nameText!);
      _nameText = null;
    }
    if (_descText != null && _descText!.parent != null) {
      remove(_descText!);
      _descText = null;
    }
  }

  void _showButton() {
    _isInfoVisible = true;
    gameRef.onInteractAction = (){
        if (_isUnlocked) {
          _handleTake();
        } else {
          _handleUnlock();
        }
      };
    gameRef.canInteractNotifier.value = true;  
  }

  void _hideButton() {
    _isInfoVisible = false;
    gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;
  }

  void _updateVisuals() {
    removeAll(children.whereType<GameIcon>());
    removeAll(children.whereType<GameSprite>());
    removeAll(children.whereType<TextComponent>());
    add(GameSprite(
        imagePath: 'sprites/gameObjs/pedestal.png',
        color: Pallete.cinzaEsc,
        size: size,
        scale: Vector2.all(1.0), // Adicionado para evitar erro de required
        anchor: Anchor.center,
        position: Vector2(8,24),
      ));

    if (!_isPicked){
      add(GameSprite(
        imagePath: 'sprites/itens/${_getIconForType(type)}.png',
        color: _getColorForType(type),
        size: Vector2.all(16),
       // scale: Vector2.all(1.0), // Adicionado para evitar erro de required
        anchor: Anchor.center,
        position: size / 2,
      ));
    }
      
    if (!_isUnlocked) {
      add(GameSprite(
        imagePath: 'sprites/gameObjs/lock.png',
        color: Colors.grey,
        size: size,
        scale: Vector2.all(1.0),
        anchor: Anchor.center,
        position: Vector2(8,16),
      ));
      _addText("$soulCost Souls", Colors.blueAccent);
    }
  }

  void _addText(String text, Color color) {
    add(TextComponent(
      text: text,
      textRenderer: Pallete.textoPadrao,
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 16),
    ));
  }

  void _handleTake() {
    if(!_isPicked){
      _hideItemInfo();
      _giveItem(gameRef.player);
      _isPicked = true;
      _updateVisuals();
      _hideButton();
      //removeFromParent();
    }
    
  }

  Future<void> _handleUnlock() async {
    bool success = await gameRef.progress.spendSouls(soulCost);

    if (success) {
      await gameRef.progress.unlockItem(id);
      _isUnlocked = true;
      
      // Esconde o botão antigo e atualiza visuais
      //_hideButton();
      _updateVisuals();
      
      gameRef.world.add(FloatingText(
        text: "Unlocked!",
        position: position + Vector2(0, -30),
        color: Colors.blueAccent,
      ));
    } else {
      gameRef.world.add(FloatingText(
        text: "Need Souls!",
        position: position + Vector2(0, -30),
        color: Pallete.vermelho,
      ));
    }
  }

  void _giveItem(Player player) {
    Collectible.applyEffect(type: type, game: gameRef);
  }

  // --- Helpers de ícone (Pode usar o Collectible.getAttributes se quiser centralizar) ---
  String _getIconForType(CollectibleType type) {
      if (type == CollectibleType.damage) return 'potion';
      if (type == CollectibleType.healthContainer) return 'hpVazio';
      if (type == CollectibleType.shield) return 'escudo';
      if (type == CollectibleType.fireRate) return 'potion';
      if (type == CollectibleType.critChance) return 'potion';
      return 'potion';
  }

  Color _getColorForType(CollectibleType type) {
      if (type == CollectibleType.damage) return Pallete.vermelho;
      if (type == CollectibleType.healthContainer) return Pallete.vermelho;
      if (type == CollectibleType.shield) return Pallete.lilas;
      if (type == CollectibleType.fireRate) return Pallete.laranja;
      if (type == CollectibleType.critChance) return Pallete.cinzaCla;
      return Pallete.branco;
  }
}