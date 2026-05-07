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

    add(FishingOverlay(this));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final player = gameRef.player;
    double dist = position.distanceTo(player.position);

    // MUDANÇA: Verifica se o player está perto E se ainda tem peixes para pescar!
    if (dist <= _interactRange && fishesLeft > 0) {
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
      _timer -= dt;
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
  }

  void _pescarRecompensa() {
    state = FishingState.cooldown;
    _timer = 1.0;
    fishesLeft--;

    // Se a pescaria acabou, tira o botão interativo da tela IMEDIATAMENTE
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

    CollectibleType loot = _sortearLootDePesca();

    final item = Collectible(position: gameRef.player.absoluteCenter.clone() + Vector2(0,-16), type: loot);
    gameRef.world.add(item);
    item.pop(Vector2(Random().nextDouble() * 40 - 20, 20), altura: -100);
  }

  CollectibleType _sortearLootDePesca() {
    int rnd = Random().nextInt(100);
    
    if (rnd < 40) return CollectibleType.coinUm;          
    if (rnd < 70) return CollectibleType.coin;          
    if (rnd < 85) return CollectibleType.potion;        
    if (rnd < 95) return CollectibleType.bombas;        
    return CollectibleType.chest;                       
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

  // Recebe o lago e copia o tamanho exato dele
  FishingOverlay(this.pond) : super(size: pond.size);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // O AVISO DE FISGADA!
    if (pond.state == FishingState.biting) {
      pond.exclamationSprite.render(
        canvas, 
        // Centraliza a imagem no eixo X subtraindo a metade da largura dela
        position: Vector2(size.x / 2 - (pond.exclamationSprite.srcSize.x / 2), -24) 
      );
    }
    
    // A BOIA NA ÁGUA (Casting)
    if (pond.state == FishingState.casting) {
      canvas.drawCircle(const Offset(32, 32), 2, Paint()..color = Pallete.branco ..isAntiAlias = false);
      canvas.drawCircle(const Offset(32, 32), 2, Paint()..color = Pallete.preto ..isAntiAlias = false..style = PaintingStyle.stroke
      ..strokeWidth = 0.5);
       pond.rodSprite.render(
        canvas, 
        position: Vector2(pond.gameRef.player.position.x + 24,pond.gameRef.player.position.y) 
      );
    }
  }
}