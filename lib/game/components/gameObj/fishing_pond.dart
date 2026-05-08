import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/effects/floating_text.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/tower_game.dart';
import '../core/pallete.dart';

enum FishingState { idle, casting, biting, cooldown }

// REMOVI O TapCallbacks, já que o botão na HUD (interactiveButton) quem fará o clique!
class FishingPond extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  FishingState state = FishingState.idle;
  
  bool _isPlayerNear = false;
  double _timer = 0;

  bool _isInfoVisible = false;
  
  // AUMENTADO PARA 60! Como o lago é "isSolid: true", o player esbarra na borda 
  // antes do centro dele chegar a 32 pixels do centro do lago.
  final double _interactRange = 36.0; 
  
  int fishesLeft = 3; 
  
  late Sprite exclamationSprite;
  late Sprite rodSprite;

  FishingPond({required Vector2 position}) : super(position: position, size: Vector2(60, 42), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    add(GameSprite(
      imagePath: 'sprites/gameObjs/pond.png',
      color: Pallete.azulCla,
      size: Vector2(64, 64),
      anchor: Anchor.center,
      position: size / 2,
    ));

    add(RectangleHitbox(
      size: size,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));
    
    exclamationSprite = await Sprite.load('sprites/gameObjs/exclamacao.png');
    rodSprite = await Sprite.load('sprites/doorIcons/pescaria.png');

    priority = -1000;

    add(FishingOverlay(this));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    // MUDANÇA: Verifica se o player está perto E se ainda tem peixes para pescar!
    if (dist <= _interactRange) {
      if (!_isInfoVisible) {
        _isInfoVisible = true; // CORREÇÃO: Avisamos ao sistema que o botão já está visível
        gameRef.canInteractNotifier.value = true;
        gameRef.onInteractAction = pescar;
      }
    } else {
      if (_isInfoVisible) {
        _isInfoVisible = false; // CORREÇÃO: Avisamos que o botão deve sumir
        gameRef.canInteractNotifier.value = false;
        gameRef.onInteractAction = null;
      }
    }
    
    if (state == FishingState.casting) {
      int segundoAnterior = _timer.ceil();
      _timer -= dt;

      if (_timer.ceil() < segundoAnterior && _timer > 0) {
        gameRef.world.add(FloatingText(
          text: "...", 
          position: absoluteCenter.clone()..add(Vector2(0, -16)),
        ));
      }
      
      if (_timer <= 0) {
        state = FishingState.biting;
        _timer = 1.0; 
      }
    } 
    else if (state == FishingState.biting) {
      _timer -= dt;
      if (_timer <= 0) {
        _escapou();
        gameRef.player.parado = false;
      }
    }
    else if (state == FishingState.cooldown) {
      _timer -= dt;
      if (_timer <= 0) state = FishingState.idle;
    }
  }

  void pescar() {
    if (fishesLeft <= 0) {
      game.world.add(FloatingText(
                text: "sem mais iscas!",
                position: gameRef.player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.branco,
              ));
      return;
    }
    if (state == FishingState.idle) {
      _jogarIsca();
      gameRef.player.parado = true;
    } else if (state == FishingState.biting) {
      _pescarRecompensa();
      gameRef.player.parado = false;
    } else if (state == FishingState.casting) {
      _escapou();
      gameRef.player.parado = false;
    }
  }

  void _jogarIsca() {
    state = FishingState.casting;
    _timer = Random().nextDouble() * 3 + 2; 
  }

  void _escapou() {
    state = FishingState.cooldown;
    _timer = 2.0; 
    fishesLeft--;
    if (fishesLeft <= 0) {
      game.world.add(FloatingText(
                text: "sem mais iscas!",
                position: gameRef.player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.branco,
              ));
      _isInfoVisible = false;
      gameRef.canInteractNotifier.value = false;
      gameRef.onInteractAction = null;
    }
  }

  void _pescarRecompensa() {
    state = FishingState.cooldown;
    _timer = 1.0;
    fishesLeft--;

    // Se a pescaria acabou, tira o botão interativo da tela IMEDIATAMENTE
    if (fishesLeft <= 0) {
      game.world.add(FloatingText(
                text: "sem_iscas",
                position: gameRef.player.absoluteCenter.clone() + Vector2(0, -30),
                color: Pallete.branco,
              ));
      _isInfoVisible = false;
      gameRef.canInteractNotifier.value = false;
      gameRef.onInteractAction = null;
    }

    CollectibleType loot = _sortearLootDePesca();

    final item = Collectible(position: gameRef.player.absoluteCenter.clone() + Vector2(0,-16), type: loot);
    gameRef.world.add(item);
    double posx = 32;
    if(gameRef.player.absoluteCenter.x < 0) posx = -32;
    item.pop(Vector2(posx, 20), altura: -100);
  }

  CollectibleType _sortearLootDePesca() {
    var rnd = Random();
    var pool = retornaPescados();
    
    return pool[rnd.nextInt(pool.length)];                     
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Player) _isPlayerNear = true;
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is Player) {
      _isPlayerNear = false;
      if (state == FishingState.casting) state = FishingState.idle; 
    }
  }
}

class FishingOverlay extends PositionComponent {
  final FishingPond pond;
  double _time = 0;
  FishingOverlay(this.pond) : super(size: pond.size);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt; 
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // O AVISO DE FISGADA!
    if (pond.state == FishingState.biting) {
      pond.exclamationSprite.render(
        canvas, 
        // Centraliza a imagem no eixo X subtraindo a metade da largura dela
        position: Vector2(size.x / 2 - (pond.exclamationSprite.srcSize.x / 2), -24),
        overridePaint: Paint()..color = Pallete.amarelo
      );
    }
    
    // A BOIA NA ÁGUA (Casting)
    if (pond.state == FishingState.casting) {
      double offsetX = 30;
      double offsetY = 24 + (sin(_time * 3) * 2);
      canvas.drawCircle( Offset(offsetX, offsetY), 2, Paint()..color = Pallete.branco ..isAntiAlias = false);
      canvas.drawArc(
        Rect.fromCircle(center: Offset(offsetX, offsetY), radius: 2), 
        pi, 
        pi, 
        true, 
        Paint()..color = Pallete.vermelho ..isAntiAlias = false,
      );
      canvas.drawCircle( 
      Offset(offsetX, offsetY), 
      2, 
      Paint()..color = Pallete.preto 
            ..isAntiAlias = false..style = PaintingStyle.stroke 
            ..strokeWidth = 0.5
      );

      if(pond.gameRef.player.absoluteCenter.x > 0){
        canvas.save();
        double posX = pond.gameRef.player.position.x ; 
        double posY = pond.gameRef.player.position.y;

        canvas.translate(posX, posY);
        canvas.scale(-1.0, 1.0);
        pond.rodSprite.render(canvas, position: Vector2(-24, 0),overridePaint: Paint()..color = Pallete.bege);
        canvas.restore();
      }else{
        pond.rodSprite.render(
          canvas, 
          position: Vector2(pond.gameRef.player.position.x + 20,pond.gameRef.player.position.y),
          overridePaint: Paint()..color = Pallete.bege 
        );
      }

      
    }
  }
}