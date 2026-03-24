import 'dart:math';
import 'package:TowerRogue/game/components/core/game_icon.dart';
import 'package:TowerRogue/game/components/enemies/enemy.dart';
import 'package:TowerRogue/game/components/gameObj/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import 'projectile.dart';

class OrbitalShield extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  final double angleOffset; 
  final double radius; 
  final double speed ;   
  final bool isEnemy;
  final bool isFoice;
  final bool isFlail;
  final PositionComponent? owner;
  double _currentAngle = 0;

  // --- NOVA VARIÁVEL DE RENDERIZAÇÃO (Zero Lixo) ---
  final Paint _chainPaint = Paint()
    ..color = Pallete.cinzaEsc // Ajuste para a cor que preferir (cinza combina com metal)
    ..style = PaintingStyle.fill;

  OrbitalShield({
    required this.angleOffset, 
    this.isEnemy = false,
    this.isFoice = false, 
    this.isFlail = false,
    this.owner,
    this.radius = 45,
    this.speed = 3,
    Vector2? size,
    }) : super(size: size ?? Vector2.all(24), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    _currentAngle = angleOffset;

    Color cor = Pallete.lilas;
    if(isFlail) cor = Pallete.vermelho;
    
    // Visual do escudo
    if(isFoice){
      add(GameIcon(
        icon: MdiIcons.sickle,
        color: cor,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      ));
    }else if(isFlail){
      add(GameIcon(
        icon: MdiIcons.mine,
        color: Pallete.lilas,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      ));
    } else {
      add(GameIcon(
        icon: MdiIcons.shield,
        color: Pallete.lilas,
        size: size, 
        anchor: Anchor.center,
        position: size / 2,
      ));
    }

    add(CircleHitbox());
  }

 @override
  void update(double dt) {
    super.update(dt);
    
    if (owner == null) return;

    _currentAngle += speed * dt;
    
    double centerX;
    double centerY;

    // A MÁGICA ESTÁ AQUI: Checar quem é o "Pai" (Parent) do escudo
    if (parent == owner) {
      // 1. Coordenada Local: O escudo é FILHO do dono (Como os Inimigos fazem)
      centerX = owner!.size.x / 2;
      centerY = owner!.size.y / 2;
    } else {
      // 2. Coordenada Global: O escudo é FILHO DO MUNDO (Como o Player faz)
      // Assume que o owner tem a âncora no centro (Anchor.center)
      centerX = owner!.position.x;
      centerY = owner!.position.y;
    }

    // Cálculo da nova posição
    final newX = centerX + cos(_currentAngle) * radius;
    final newY = centerY + sin(_currentAngle) * radius;
    
    position.setValues(newX, newY);
    
    priority = position.y.toInt();
  }

  // --- O DESENHO DA CORRENTE ---
  @override
  void render(Canvas canvas) {
    super.render(canvas); // Garante que a base do Flame rode

    if (isFlail) {
      // Ponto de partida: O centro exato da bola do Flail
      final double startX = size.x / 2;
      final double startY = size.y / 2;

      // Quantos elos a corrente vai ter (Ex: 1 elo a cada 8 pixels de raio)
      int numLinks = (radius / 8).floor(); 

      // Desenha bolinhas (elos) do centro da bola em direção ao dono
      for (int i = 1; i < numLinks; i++) {
        // Porcentagem da distância (0.0 a 1.0)
        double progress = i / numLinks; 

        // Calcula a posição do elo. 
        // Usamos subtração (-) porque estamos indo DA bola PARA o dono.
        double linkX = startX - cos(_currentAngle) * (radius * progress);
        double linkY = startY - sin(_currentAngle) * (radius * progress);

        // Desenha o elo (um círculo de raio 2.0)
        canvas.drawCircle(Offset(linkX, linkY), 2.0, _chainPaint);
      }
    }
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    if(isFoice || isFlail){ 
      if (other is Enemy && !isEnemy && !other.isInvencivel && !other.isIntangivel) {
        other.takeDamage(gameRef.player.damage);
      }else if (other is Player && isEnemy) {
        other.takeDamage(1);
      }
    }else{
      if (other is Projectile ) {
        if (isEnemy && !other.isEnemyProjectile){
          other.removeFromParent(); 
        }else if (!isEnemy && other.isEnemyProjectile){
          other.removeFromParent(); 
        } 
      }
    }
  }
}