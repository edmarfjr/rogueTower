import 'dart:math';
import 'dart:ui';

import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/gameObj/player.dart';
import 'package:towerrogue/game/components/projectiles/black_hole.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import 'package:towerrogue/game/components/projectiles/projectile.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
//import '../core/game_icon.dart';

class Bomb extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  double _timer = 0;
  GameSprite? visual;
  final double duration;
  final double damage;
  final bool isMine;
  final bool isEnemy;
  final PositionComponent? owner;
  final bool splits;
  final int splitCount;
  final bool isDecoy;
  final double attractionRadius = 100;
  final bool isGlitterBomb; 
  final bool isBuracoNegro;

  double _contadorPiscar = 0.0;
  bool _mostrarBranco = false;
  Color cor = Pallete.preto;

  late final Vector2 direction;
  Bomb({required Vector2 position, 
        this.duration = 2.0, 
        this.damage = 10, 
        this.isMine = false, 
        this.isEnemy = false, 
        this.owner,
        this.splits = false,
        this.splitCount = 8,
        this.isDecoy = false,
        this.isGlitterBomb = false,
        this.isBuracoNegro = false,
        Vector2? direction}) 
      : super(position: position, size: Vector2.all(16), anchor: Anchor.center) {
    this.direction = direction ?? Vector2.zero();
  }

  @override
  Future<void> onLoad() async {

    cor = isEnemy ? Pallete.vermelho : isMine ?Pallete.verdeEsc:Pallete.lilas;
    
    visual = GameSprite(
      imagePath: isMine ? 'sprites/projeteis/mina.png' : 'sprites/projeteis/bomba.png', 
      color: cor,
      size: size,
      anchor: Anchor.center,
      position: size / 2,
    );

    add(visual!);

    // Hitbox Sólida
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center,
      position: size / 2,
      isSolid: true,
    ));
    /*if(isDecoy){
      add(CircleComponent(
        radius: attractionRadius,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 2,
      ));
    }*/
    _timer = duration;
    priority = position.y.toInt() - 500;
  }

   @override
  void update(double dt) {
    super.update(dt);
    _timer -= dt;

    //logica de piscar
    double progresso = 1.0 - (_timer / duration).clamp(0.0, 1.0);

    const double velocidadeInicial = 0.4;
    const double velocidadeFinal = 0.05;
    double intervaloAtual = lerpDouble(
      velocidadeInicial, 
      velocidadeFinal, 
      Curves.easeIn.transform(progresso)
    )!;

    _contadorPiscar += dt;
    if (_contadorPiscar >= intervaloAtual) {
      _contadorPiscar = 0;
      _mostrarBranco = !_mostrarBranco; // Alterna o estado
    }
    if(!isMine){
      if (_mostrarBranco) {
        visual!.changeColor(Pallete.branco);
      } else {
        visual!.changeColor(cor);
      }
    }

    if (isDecoy){
      final enemies = gameRef.world.children.whereType<Enemy>();
    
      for (var enemy in enemies) {
        double dist = position.distanceTo(enemy.position);

        if (dist <= attractionRadius) {
          // Hackeia a mente do inimigo!
          enemy.lureTarget = this; 
        } else if (enemy.lureTarget == this) {
          // Se o inimigo for empurrado para fora do raio, ele acorda da hipnose
          enemy.lureTarget = null; 
        }
      }
    }

    if (_timer <= 0 && !isMine) {
      if (isEnemy) {
        gameRef.world.add(Explosion(position: position, damagesPlayer:true, damage:damage, radius:48, owner: owner));
      } else {
        gameRef.world.add(Explosion(position: position, damagesPlayer:false, damage:damage, radius:64, owner: owner, isGlitter:isGlitterBomb));
      }

      if(splits){
        _doSplit();
      }
      if(isBuracoNegro){
        game.world.add(BuracoNegro(position: position.clone()));
      }
      
      removeFromParent();
    }
    if (isMine && _timer >= duration/1.25) {
      position.addScaled(direction, 100 * dt);
    }
  }

@override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (isDecoy) {
      final center = Offset(size.x / 2, size.y / 2);

      final fillPaint = Paint()
        ..color = Pallete.azulEsc.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      final borderPaint = Paint()
        ..color = Pallete.lilas.withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center, attractionRadius, fillPaint);
      canvas.drawCircle(center, attractionRadius, borderPaint);
      canvas.drawCircle(center, attractionRadius/2, borderPaint);
    }
  }

@override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (!isMounted) return;
    super.onCollisionStart(intersectionPoints, other);
    if (isMine){
      if (!isEnemy && other is Enemy && !other.isIntangivel) {
        gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:false, damage:damage, radius:60));
        removeFromParent();
      }else if (isEnemy && other is Player) {
        gameRef.world.add(Explosion(position: position.clone(), damagesPlayer:true, damage:1, radius:60));
        removeFromParent();
      }
    }
  }

  void _doSplit() {
    for (int i = 0; i < splitCount; i++) {
      double angle = (2 * pi / splitCount) * i; 
      Vector2 newDir = Vector2(cos(angle), sin(angle));
      
      gameRef.world.add(Projectile(
        position: position.clone(), 
        direction: newDir,
        speed: 250 * 0.8, 
        damage: damage / 3, 
        isEnemyProjectile: isEnemy,
        owner: owner,
        dieTimer: 1.0, 
        hbSize: Vector2.all(6), 
        canBounce: false,
        explodes: false, 
        splits: false, 
      ));
    }
  }


}