import 'package:TowerRogue/game/components/core/pallete.dart';
import 'package:TowerRogue/game/components/core/interact_button.dart'; // Import do novo botão
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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
  final double _interactRange = 60.0;
  InteractButton? _currentButton;

  UnlockableItem({
    required Vector2 position,
    required this.id,
    required this.type,
    required this.soulCost,
  }) : super(position: position, size: Vector2.all(40), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _isUnlocked = gameRef.progress.isUnlocked(id);
    _updateVisuals();
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center,
      position: Vector2(20,55),
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
      if (!_isInfoVisible && !_isPicked) _showButton();
    } else {
      if (_isInfoVisible) _hideButton();
    }
  }

  void _showButton() {
    _isInfoVisible = true;
    _currentButton = InteractButton(
      //text:"DESBLOQUEAR",
      onTrigger: () {
        if (_isUnlocked) {
          _handleTake();
        } else {
          _handleUnlock();
        }
      },
    )..position = Vector2(size.x / 2, -20); // Posiciona acima do item
    
    add(_currentButton!);
  }

  void _hideButton() {
    _isInfoVisible = false;
    if (_currentButton != null) {
      _currentButton!.removeFromParent();
      _currentButton = null;
    }
  }

  void _updateVisuals() {
    removeAll(children.whereType<GameIcon>());
    removeAll(children.whereType<TextComponent>());
    add(GameIcon(
        icon: MdiIcons.archive,
        color: Pallete.cinzaEsc,
        size: size,
        scale: Vector2.all(1.0), // Adicionado para evitar erro de required
        anchor: Anchor.center,
        position: Vector2(20,55),
      ));

    if (!_isPicked){
      add(GameIcon(
        icon: _getIconForType(type),
        color: _getColorForType(type),
        size: size,
        scale: Vector2.all(1.0), // Adicionado para evitar erro de required
        anchor: Anchor.center,
        position: size / 2,
      ));
    }
      
    if (!_isUnlocked) {
      add(GameIcon(
        icon: Icons.lock,
        color: Colors.grey,
        size: size/2,
        scale: Vector2.all(1.0),
        anchor: Anchor.center,
        position: Vector2(20,55),
      ));
      _addText("$soulCost Souls", Colors.blueAccent);
    }
  }

  void _addText(String text, Color color) {
    add(TextComponent(
      text: text,
      textRenderer: TextPaint(style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
      anchor: Anchor.topCenter,
      position: Vector2(size.x / 2, size.y + 30),
    ));
  }

  void _handleTake() {
    if(!_isPicked){
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
      _hideButton();
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
  IconData _getIconForType(CollectibleType type) {
      if (type == CollectibleType.damage) return MdiIcons.flaskRoundBottom;
      if (type == CollectibleType.healthContainer) return Icons.favorite_outline;
      if (type == CollectibleType.shield) return Icons.gpp_bad;
      if (type == CollectibleType.fireRate) return MdiIcons.flaskRoundBottom;
      return Icons.star;
  }

  Color _getColorForType(CollectibleType type) {
      if (type == CollectibleType.damage) return Pallete.vermelho;
      if (type == CollectibleType.healthContainer) return Pallete.vermelho;
      if (type == CollectibleType.shield) return Pallete.lilas;
      if (type == CollectibleType.fireRate) return Pallete.laranja;
      return Pallete.branco;
  }
}