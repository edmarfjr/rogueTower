import 'dart:math';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../tower_game.dart'; 
import '../core/game_icon.dart';
import '../core/pallete.dart';
import '../gameObj/wall.dart';
import '../effects/floating_text.dart';
import 'enemy_behaviors.dart'; // Importe os comportamentos

class Enemy extends PositionComponent with HasGameRef<TowerGame>, CollisionCallbacks {
  
  // Status
  double hp;
  double speed;
  int soul;
  bool rotates;
  double weight;
  
  // Controle
  bool canMove = true; // Behaviors podem travar isso (ex: Laser)
  late Color originalColor;
  
  // Efeitos de Status
  bool _isHit = false;
  double _hitTimer = 0;
  bool isFreeze = false;
  double get speedInicial => _baseSpeed;
  late double _baseSpeed;
  double freezeTimer = 0.0;
  
  // COMPONENTES DE LÓGICA (Strategy Pattern)
  late MovementBehavior movementBehavior;
  late AttackBehavior attackBehavior;
  final IconData iconData;

  Enemy({
    required Vector2 position,
    required this.movementBehavior,
    required this.attackBehavior,
    this.hp = 30,
    this.speed = 80,
    this.soul = 1,
    this.weight = 1.0,
    this.rotates = false,
    this.iconData = Icons.pest_control_rodent,
    this.originalColor = Pallete.vermelho,
  }) : super(position: position, size: Vector2.all(32), anchor: Anchor.center) {
    _baseSpeed = speed;
    
    // Vincula os behaviors a este inimigo
    movementBehavior.enemy = this;
    attackBehavior.enemy = this;
  }

  @override
  Future<void> onLoad() async {
    add(GameIcon(
      icon: iconData,
      color: originalColor,
      size: size,
      anchor: Anchor.center,
      position: size / 2, 
    ));

    add(RectangleHitbox(
      size: size, 
      anchor: Anchor.center,
      position: size / 2, 
      isSolid: true,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    // 1. Executa Comportamentos
    movementBehavior.update(dt);
    attackBehavior.update(dt);

    // 2. Mantém na Arena (Lógica Global)
    _keepInsideArena();

    // 3. Status Effects (Freeze, Hit Flash)
    _updateStatus(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Repassa colisão para o movimento (Ex: Bouncer precisa saber se bateu)
    movementBehavior.onCollision(intersectionPoints, other);

    if (other is Wall) {
      final separation = (position - other.position).normalized();
      position += separation * 1.0; 
    } 
    // COLISÃO COM INIMIGOS (Lógica de Peso)
    else if (other is Enemy) {
      _handleEnemyCollision(other);
    }
  }

  void _handleEnemyCollision(Enemy other) {
    // 1. Se eu sou MAIS PESADO que o outro, eu NÃO me movo (sou uma rocha)
    if (this.weight > other.weight) {
       return; 
    }

    // 2. Se temos o MESMO PESO, nos empurramos igualmente
    if (this.weight == other.weight) {
      final separation = (position - other.position).normalized();
      position += separation * 1.0; 
    }

    // 3. Se sou MAIS LEVE, sou empurrado com força
    if (this.weight < other.weight) {
      final separation = (position - other.position).normalized();
      position += separation * 3.0; // Empurrão forte
    }
  }

  void takeDamage(double damage) {
    if (hp <= 0) return;
    hp -= damage;
    
    // Lógica de Freeze
    if(gameRef.player.isFreeze){
      final rng = Random();
      if (rng.nextDouble() <= 0.8){
        isFreeze = true;
        speed = speed/4;
      }
    }

    // Flash Branco
    if (!_isHit) { 
        _isHit = true; 
        _hitTimer = 0.1; 
        children.whereType<GameIcon>().firstOrNull?.setColor(Pallete.branco);
    }

    gameRef.world.add(FloatingText(
      text: damage.toInt().toString(),
      position: position + Vector2(0, -10), 
      color: Colors.white, 
      fontSize: 14,
    ));

    if (hp <= 0) {
      gameRef.progress.addSouls(soul);
      removeFromParent();
    }
  }

  void _keepInsideArena() {
    double halfWidth = TowerGame.arenaWidth / 2;
    double halfHeight = TowerGame.arenaHeight / 2;
    double padding = size.x / 2; 

    position.x = position.x.clamp(-halfWidth + padding, halfWidth - padding);
    position.y = position.y.clamp(-halfHeight + padding, halfHeight - padding);
  }

  void _updateStatus(double dt) {
    // Freeze
    if (isFreeze){
      freezeTimer += dt;
      if (freezeTimer >= 5.0){
        isFreeze = false;
        freezeTimer = 0.0;
        speed = _baseSpeed;
        children.whereType<GameIcon>().firstOrNull?.setColor(originalColor);
      }
    }
    // Hit Flash
    if (_isHit) {
      _hitTimer -= dt;
      if (_hitTimer <= 0) {
        _isHit = false;
        Color cor = originalColor;
        if (isFreeze) cor = Pallete.azulCla;
        children.whereType<GameIcon>().firstOrNull?.setColor(cor);
      }
    }
  }
}