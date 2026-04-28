import 'dart:ui';

import 'package:flame/components.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/effects/shadow_component.dart';
import '../../tower_game.dart';

class Npc extends PositionComponent with HasGameRef<TowerGame> {
  final String imagePath;
  final List<String> dialogs;
  late GameSprite visual;
  Color cor;

  late ShadowComponent _shadow;
  
  // Controle interno para saber se já ativamos o botão
  bool _isPlayerNear = false; 

  Npc({
    required Vector2 position,
    required this.imagePath,
    required this.dialogs,
    this.cor = Pallete.branco,
  }) : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    visual = GameSprite(
      imagePath: imagePath,
      size: size,
      color: cor,
      anchor: Anchor.center,
      position: size / 2
    );
    add(visual);

    _shadow=ShadowComponent(parentSize:size);
    add(_shadow);
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    double distance = position.distanceTo(gameRef.player.position);

    if (distance < 24) {
      // Se chegou perto e o botão ainda não apareceu...
      if (!_isPlayerNear) {
        _isPlayerNear = true;
        gameRef.canInteractNotifier.value = true; // Mostra o botão "!" na HUD
        gameRef.onInteractAction = iniciarDialogo; // Diz que o botão vai abrir o diálogo!
      }
    } else {
      // Se o jogador se afastar...
      if (_isPlayerNear) {
        _isPlayerNear = false;
        
        // Só esconde o botão se a ação atual ainda for a deste NPC
        // (Isso evita apagar o botão se ele chegou perto de um baú logo em seguida)
        if (gameRef.onInteractAction == iniciarDialogo) {
          gameRef.canInteractNotifier.value = false;
          gameRef.onInteractAction = null;
        }
      }
    }
  }

  // Essa é a função que o seu botão da HUD vai chamar!
  void iniciarDialogo() {
    if (dialogs.isEmpty) return;
    
    // 1. Esconde o botão de exclamação para limpar a tela durante o papo
    gameRef.canInteractNotifier.value = false;
    
    // 2. Prepara os textos
    gameRef.activeDialogs = dialogs; 
    
    // 3. Abre a caixa de diálogo (o overlay que criamos antes)
    gameRef.overlays.add('DialogOverlay'); 
    
    // 4. Pausa o jogo para eles conversarem em paz
    gameRef.pauseEngine(); 
  }
}