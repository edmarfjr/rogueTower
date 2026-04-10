import 'dart:math';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/gameObj/collectible.dart';
import 'package:towerrogue/game/components/projectiles/poison_puddle.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';
import '../core/pallete.dart';
import 'explosion.dart'; 

class MortarShell extends PositionComponent with HasGameRef<TowerGame> {
  final Vector2 startPos;
  final Vector2 targetPos;
  final double flightDuration;
  final PositionComponent? owner;
  final bool isPoison;
  final bool isFire;
  final double explosionRadius; 
  final bool isPlayer;
  final double damage;
  final bool goldShot;
  
  double _timeElapsed = 0;
  final double _maxHeight = 75.0;
  late GameSprite _visualChild; 

  MortarShell({
    required this.startPos,
    required this.targetPos,
    this.owner,
    this.flightDuration = 1.2,
    this.isPoison = false,
    this.isFire = false,
    this.explosionRadius = 32.0,
    this.isPlayer = false,
    this.damage = 1,
    this.goldShot = false,
  }) : super(position: startPos, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {

    String image = 'sprites/projeteis/bomba.png';
    Color cor = Pallete.lilas;

    if(isFire){
      image = 'sprites/projeteis/molotov.png';
      cor = Pallete.laranja;
    }
    if(isPoison){
      cor = Pallete.verdeCla;
    }
    // Criamos o visual
    _visualChild = GameSprite(
      imagePath: image, 
      color: cor,
      size: Vector2.all(16),
      anchor: Anchor.center,
      // Importante: posição relativa ao centro do pai
      position: size / 2, 
    );
    
    // Adicionamos como filho
    add(_visualChild);
    priority = 1000; 
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (owner != null && !owner!.isMounted) {
      removeFromParent(); // O tiro some junto
      return;
    }

    _timeElapsed += dt;

    double progress = _timeElapsed / flightDuration;

    if (progress >= 1.0) {
      _explode();
      return;
    }

    // --- CÁLCULO DA POSIÇÃO (Move o componente PAI) ---
    Vector2 groundPosition = startPos + (targetPos - startPos) * progress;
    double heightOffset = sin(progress * pi) * _maxHeight;

    position.x = groundPosition.x;
    position.y = groundPosition.y - heightOffset;
    
    // --- CÁLCULO DA ROTAÇÃO (Gira apenas o FILHO visual) ---
    // ⚠️ VERIFIQUE SE VOCÊ REMOVEU 'angle += ...' DAQUI ⚠️
    
    // Gira apenas o ícone filho:
    _visualChild.angle += dt * 15; 
    //_visualChild.angle = atan2(targetPos.y, targetPos.x) + pi/4;
    
  }
  
  void _explode() {
    if(goldShot){
      int rnd = Random().nextInt(100);
      if(rnd <= 5){
        final item = Collectible(position: position, type: CollectibleType.coinUm);
        gameRef.world.add(item);
        double direcaoX = (Random().nextBool() ? 1 : -1) * 20.0;
        double altura = Random().nextDouble() * 100 + 150 * -1;
        item.pop(Vector2(direcaoX, 0), altura:altura);
      }
    }
    // Força a explosão no alvo exato
    if (isPoison) {
      gameRef.world.add(PoisonPuddle(position: targetPos, isPlayer: isPlayer, size: Vector2.all(explosionRadius*2)));
    } else {
      gameRef.world.add(Explosion(position: targetPos, damagesPlayer: !isPlayer,damage: damage ,radius: explosionRadius, owner:owner));
      if(isFire){
        gameRef.world.add(PoisonPuddle(position: targetPos, isPlayer: isPlayer, isFire: true, size: Vector2.all(explosionRadius)));
      }
    }
    removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    // Como o componente pai (MortarShell) não está girando, 
    // o eixo Y aqui aponta sempre para baixo na tela.
    
    double progress = _timeElapsed / flightDuration;
    if (progress > 1) progress = 1;
    
    double currentHeight = sin(progress * pi) * _maxHeight;

    // Desenha a sombra
    canvas.drawOval(
      Rect.fromCenter(
        // size.x/2 e size.y/2 é o centro exato do componente
        // Somamos a altura no Y para desenhar no chão
        center: Offset(size.x/2, size.y/2 + currentHeight), 
        width: 12 - (currentHeight * 0.02), // Sombra diminui um pouco com a altura
        height: 8 - (currentHeight * 0.02)
      ), 
      Paint()..color = Pallete.cinzaEsc
             ..isAntiAlias = false,
    );
    
    super.render(canvas); // Desenha o filho (ícone girando) por cima da sombra
  }


}