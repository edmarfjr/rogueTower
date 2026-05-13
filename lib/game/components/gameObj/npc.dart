import 'dart:math';
import 'dart:ui';

import 'package:flame/collisions.dart';
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

  double _breathTimer = 0;
  final double _breathSpeed = 3.0; 
  final double _breathAmplitude = 0.05;
  final bool anim;

  late ShadowComponent _shadow;
  
  // Controle interno para saber se já ativamos o botão
  bool _isPlayerNear = false; 

  Npc({
    required Vector2 position,
    required this.imagePath,
    required this.dialogs,
    this.cor = Pallete.branco,
    this.anim = true
  }) : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    visual = GameSprite(
      imagePath: imagePath,
      size: size,
      color: cor,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y)
    );
    add(visual);

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true
    ));

    _shadow=ShadowComponent(parentSize:size);
    add(_shadow);
    priority = position.y.toInt();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(anim)_animateMovement(dt);
    
    double distance = position.distanceTo(gameRef.player.position);

    if (distance < size.y * 1.5) {
      // Se chegou perto e o botão ainda não apareceu...
      if (!_isPlayerNear) {
        _isPlayerNear = true;
        gameRef.canInteractNotifier.value = true; // Mostra o botão "!" na HUD
        gameRef.onInteractAction = iniciarDialogo; // Diz que o botão vai abrir o diálogo!
      }else {
        // CORREÇÃO: Se o item sumiu e limpou a ação, a máquina pega o botão de volta imediatamente!
        if (gameRef.onInteractAction == null) {
          gameRef.canInteractNotifier.value = true;
          gameRef.onInteractAction = iniciarDialogo;
        }
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
    gameRef.activeDialogs = List.from(dialogs);
    
    // 3. Abre a caixa de diálogo (o overlay que criamos antes)
    gameRef.overlays.add('DialogOverlay'); 
    
    // 4. Pausa o jogo para eles conversarem em paz
    gameRef.pauseEngine(); 
  }

  void _animateMovement(double dt) {
    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

     _breathTimer += dt * _breathSpeed;

    // A matemática da respiração: uma onda constante e suave
    double breathWave = sin(_breathTimer);
    
    // Incha o X e o Y para simular os pulmões enchendo e esvaziando
    currentScaleX = 1.0 + (breathWave * _breathAmplitude); 
    currentScaleY = 1.0 + (breathWave * (_breathAmplitude * 0.5)); 

    visual.scale.setValues(currentScaleX, currentScaleY);
    visual.angle = currentAngle; 

  }
}

class ServiceNpc extends PositionComponent with HasGameRef<TowerGame> {
  final String imagePath;
  bool _isInfoVisible = false;
  Color cor;
  late GameSprite visual;

  double _breathTimer = 0;
  final double _breathSpeed = 3.0; 
  final double _breathAmplitude = 0.05;
  final bool anim;

  ServiceNpc({
    required Vector2 position, 
    required this.imagePath,
    this.cor = Pallete.branco,
    this.anim = true
  }): super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true, // Bloqueia o caminho do jogador
    ));

    // Desenha o NPC
    visual = GameSprite(
      imagePath: imagePath,
      size: size,
      color: cor,
      anchor: Anchor.bottomCenter,
      position: Vector2(size.x / 2, size.y)
    );
    add(visual);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if(anim)_animateMovement(dt);

    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    if (dist <= size.y * 1.5) {
      if (!_isInfoVisible) {
        if (gameRef.canInteractNotifier.value) return;
        
        _isInfoVisible = true;
        gameRef.canInteractNotifier.value = true;
        
        // A AÇÃO DE INTERAÇÃO DO NPC É ABRIR O MENU!
        gameRef.onInteractAction = _abrirMenuDeServico; 
        
      } else if (gameRef.onInteractAction == null) {
        // Pega o botão de volta se o overlay fechou
        gameRef.canInteractNotifier.value = true;
        gameRef.onInteractAction = _abrirMenuDeServico;
      }
    } else {
      if (_isInfoVisible) {
        _isInfoVisible = false;
        gameRef.canInteractNotifier.value = false;
        gameRef.onInteractAction = null;
      }
    }
  }

  void _animateMovement(double dt) {
    double currentScaleX = 1.0;
    double currentScaleY = 1.0;
    double currentAngle = 0.0;

     _breathTimer += dt * _breathSpeed;

    // A matemática da respiração: uma onda constante e suave
    double breathWave = sin(_breathTimer);
    
    // Incha o X e o Y para simular os pulmões enchendo e esvaziando
    currentScaleX = 1.0 + (breathWave * _breathAmplitude); 
    currentScaleY = 1.0 + (breathWave * (_breathAmplitude * 0.5)); 

    visual.scale.setValues(currentScaleX, currentScaleY);
    visual.angle = currentAngle; 

  }

  void _abrirMenuDeServico() {
    // 1. Pausa o jogo (opcional, mas recomendado para menus)
    gameRef.pauseEngine();
    
    // 2. Tira o botão de interação da tela (para não ficar desenhado no fundo)
    gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;

    // 3. Abre a tela do Flutter que criamos no Passo 1
    gameRef.overlays.add('ServiceMenu');
  }
}