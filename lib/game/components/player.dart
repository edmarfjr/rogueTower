import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
//import 'package:flame/events.dart'; // Necessário para KeyboardHandler
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para LogicalKeyboardKey

import 'package:tower/game/tower_game.dart'; // Import para acessar as cores e classes do jogo
import 'enemies/enemy.dart'; 
import 'projectile.dart';
import './game_icon.dart';
import 'pallete.dart';
import 'wall.dart';

class Player extends PositionComponent 
    with HasGameRef<TowerGame>, KeyboardHandler, CollisionCallbacks {
  // ValueNotifier permite que o HUD "escute" mudanças na vida
  int maxHealth = 3;
  ValueNotifier<int> healthNotifier = ValueNotifier<int>(3);
  
  // I-Frames (Invencibilidade)
  bool _isInvincible = false;
  double _invincibilityTimer = 0;
  double _invincibilityDuration = 1.0; // 1 segundo de invencibilidade
  // -----------------------
  double speed = 150;
  double attackRange = 150; 
  double _attackTimer = 0;
  double damage = 10.0;
  double fireRate = 0.4; // Tempo entre tiros (menor = mais rápido)
  double moveSpeed = 150.0;

  Vector2 velocity = Vector2.zero();
  Vector2 velocityDash = Vector2(1, 0);
  
  // Variável para armazenar input do teclado
  Vector2 _keyboardInput = Vector2.zero(); 

  bool isDashing = false;
  double _dashTimer = 0;
  double _dashDuration = 0.2; // Duração curta (200ms)
  double _dashSpeed = 450;    // 3x a velocidade normal (150)
  
  double _dashCooldownTimer = 0;
  double _dashCooldown = 1.0; // 1 segundo de espera
  Vector2 _dashDirection = Vector2.zero();

  

  Player() : super(size: Vector2.all(32), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // Visual do Player
    add(GameIcon(
      icon: Icons.directions_walk, // Ícone de Heroi
      color: Pallete.branco, // Cor escura para destacar no fundo
      size: size,
      anchor: Anchor.center, // O ponto de referência do ícone é o meio dele
      position: size / 2,    // Coloca esse meio EXATAMENTE no meio do Player (16, 16)
    ));

    // Debug visual do alcance
    add(CircleComponent(
      radius: attackRange,
      anchor: Anchor.center,
      position: size / 2,
      paint: Paint()..style = PaintingStyle.stroke ..color = Pallete.cinzaEsc.withOpacity(0.5) ..strokeWidth = 1,
    ));
    
    // Para centralizar num componente Anchor.center, a posição deve ser:
    // metade negativa do tamanho da hitbox.
    add(RectangleHitbox(
      size: size * 0.8,
      anchor: Anchor.center, // O ponto de referência da caixa é o meio dela
      position: size / 2,    // Coloca no meio do Player
      isSolid: true,
    ));
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Reset input
    _keyboardInput = Vector2.zero();
    
    // Checa teclas pressionadas para movimento (WASD ou Setas)
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp) || keysPressed.contains(LogicalKeyboardKey.keyW)) {
      _keyboardInput.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown) || keysPressed.contains(LogicalKeyboardKey.keyS)) {
      _keyboardInput.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) || keysPressed.contains(LogicalKeyboardKey.keyA)) {
      _keyboardInput.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) || keysPressed.contains(LogicalKeyboardKey.keyD)) {
      _keyboardInput.x = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      startDash();
    }
    
    // Retorna true para permitir que outros componentes também processem teclas se necessário
    return true;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Processa Cooldown
    if (_dashCooldownTimer > 0) {
      _dashCooldownTimer -= dt;
    }

    // Lógica do Movimento (Alterada para suportar Dash)
    if (isDashing) {
      _handleDashMovement(dt); // Movimento forçado do dash
    } else {
      _handleMovement(dt);     // Movimento normal
    }

    if (velocity.x.abs() > 0.1) {
      // Busca o componente visual (O ícone)
      final visual = children.whereType<GameIcon>().first;
      
      // Se velocidade X < 0 (Esquerda), escala X vira -1. Se > 0 (Direita), vira 1.
      // O scale.y mantemos 1.
      visual.scale = Vector2(velocity.x < 0 ? -1 : 1, 1);
    }

    _handleAutoAttack(dt);
    _handleInvincibility(dt);
    _keepInBounds(); 
  }

  void startDash() {
    // Só dasha se não estiver em cooldown e não estiver dashando
    if (_dashCooldownTimer > 0 || isDashing) return;

    isDashing = true;
    _dashTimer = _dashDuration;
    _dashCooldownTimer = _dashCooldown;

    // Define a direção: Se estiver andando, vai naquela direção. Se parado, vai pra direita (padrão)
    //if (velocity.isZero()) {
    //  _dashDirection = Vector2(1, 0); 
    //} else {
    //  _dashDirection = velocity.normalized();
    //}
    _dashDirection = velocityDash.normalized();
    // Efeito Visual simples: Muda a cor para branco (flash)
    children.whereType<RectangleComponent>().first.paint.color = Colors.white;
    
    // Invencibilidade do Dash
    _isInvincible = true; 
    
    print("DASH!");
  }

  void _handleDashMovement(double dt) {
    _dashTimer -= dt;
    
    // Move na velocidade alta
    position += _dashDirection * _dashSpeed * dt;

    // Fim do Dash
    if (_dashTimer <= 0) {
      isDashing = false;
      _isInvincible = false; // Tira invencibilidade
      
      // Restaura cor original
      children.whereType<RectangleComponent>().first.paint.color = Pallete.branco;
    }
  }

  void _keepInBounds() {
    // Tamanho da tela definido no Viewport (360 x 640)
    // O centro é (0,0). Então vai de -180 a +180 no X, e -320 a +320 no Y.
    // Subtraímos metade do tamanho do player (16) para ele não "entrar" na parede.
    
    double limitX = 180 - 16;
    double limitY = 320 - 16;

    // Se a posição passar do limite, forçamos ela de volta
    if (position.x < -limitX) position.x = -limitX;
    if (position.x > limitX) position.x = limitX;
    
    if (position.y < -limitY) position.y = -limitY;
    if (position.y > limitY) position.y = limitY;
  }

  // --- Lógica de Dano e Colisão ---

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    
    // Se colidir com Inimigo e NÃO estiver invencível
    if (other is Enemy && !_isInvincible) {
      takeDamage(1);
    }
  }

  void takeDamage(int amount) {
    if (healthNotifier.value <= 0) return;

    // Reduz vida
    healthNotifier.value -= amount;
    
    // Ativa invencibilidade
    _isInvincible = true;
    _invincibilityTimer = _invincibilityDuration;

    // Feedback visual (Player fica transparente/piscando)
    // Aqui aplicamos opacidade simples no componente pai
    // Nota: Em versões novas do Flame, usar OpacityEffect é melhor, 
    // mas vamos simplificar alterando o paint dos filhos ou a lógica de render.
    // Para MVP, vamos apenas imprimir no console:
    print("Dano recebido! Vida restante: ${healthNotifier.value}");

    if (healthNotifier.value <= 0) {
      _die();
    }
  }

  void _handleInvincibility(double dt) {
    if (_isInvincible) {
      _invincibilityTimer -= dt;
      
      // Efeito de piscar simples (alterna visibilidade a cada frame ímpar/par é muito rápido, 
      // então usamos opacidade baseada no tempo)
      if (_invincibilityTimer % 0.2 < 0.1) {
         // Oculta (gambiarra visual rápida)
         children.whereType<RectangleComponent>().first.paint.color = Pallete.vermelho.withOpacity(0.2);
      } else {
         // Mostra
         children.whereType<RectangleComponent>().first.paint.color = Pallete.branco;
      }

      if (_invincibilityTimer <= 0) {
        _isInvincible = false;
        children.whereType<RectangleComponent>().first.paint.color = Pallete.branco; // Restaura cor
      }
    }
  }

  void _die() {
    print("GAME OVER");
    gameRef.onGameOver();
    //gameRef.pauseEngine(); // Pausa o jogo
    // Futuramente: gameRef.overlays.add('GameOverMenu');
  }

  void _handleMovement(double dt) {
    velocity = Vector2.zero();

    // 1. Tenta Joystick (Mobile)
    // Precisamos verificar se o joystick existe (pode ser desktop)
    bool joystickActive = false;
    try {
      if (gameRef.joystick.direction != JoystickDirection.idle) {
        velocity = gameRef.joystick.relativeDelta * speed;
        joystickActive = true;
      }
    } catch (e) {
      // Joystick não inicializado (Desktop), ignorar erro
    }

    // 2. Se não tem joystick, usa Teclado
    if (!joystickActive) {
       // Normaliza para não andar mais rápido na diagonal
       if (_keyboardInput != Vector2.zero()) {
         velocity = _keyboardInput.normalized() * speed;
       }
    }
    if(velocity!=Vector2.zero()) velocityDash = velocity;
    
    position += velocity * dt;
  }

  void _handleAutoAttack(double dt) {
    _attackTimer += dt;
    if (_attackTimer < fireRate) return;

    // Busca inimigos na cena
    final enemies = gameRef.world.children.query<Enemy>();
    
    Enemy? target;
    double closestDist = attackRange;

    for (final enemy in enemies) {
      final dist = position.distanceTo(enemy.position);
      if (dist <= attackRange && dist < closestDist) {
        closestDist = dist;
        target = enemy;
      }
    }

    if (target != null) {
      _attackTimer = 0;
      _shootAt(target);
    }
  }

  void _shootAt(Enemy target) {
    final direction = (target.position - position).normalized();
    // Cria o projétil no mundo
    gameRef.world.add(Projectile(position: position.clone(), direction: direction));
  }

  void reset() {
    // Restaura a vida para 3
    healthNotifier.value = 3;
    
    // Reseta invencibilidade
    _isInvincible = false;
    _invincibilityTimer = 0;
    
    // Garante que o player esteja visível (caso tenha morrido invisível/piscando)
    // Nota: Como usamos RectangleComponent como filho, acessamos ele para pintar
    children.whereType<RectangleComponent>().first.paint.color = Pallete.colorLightest;
    
    // Zera velocidade residual
    velocity = Vector2.zero();
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // colisão com PAREDE (Wall)
    if (other is Wall) {
      _handleWallCollision(intersectionPoints, other);
    }
  }

  void _handleWallCollision(Set<Vector2> points, PositionComponent wall) {
    // Se colidiu, precisamos "deslizar" ou empurrar o player para fora.
    // Lógica simples de separação:
    
    // 1. Calcula o vetor do centro da parede até o player
    final separationVector = (position - wall.position).normalized();
    
    // 2. Empurra o player para fora na direção oposta, apenas um pouquinho
    // Isso evita que ele "entre" na parede
    position += separationVector * 2.0; 
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Só desenha a barra se estiver em Cooldown
    if (_dashCooldownTimer > 0) {
      
      // Configurações da Barra
      const double barHeight = 4.0;
      final double barWidth = size.x; // Largura igual à do player
      final double yOffset = size.y + 5; // 5 pixels abaixo do pé

      // Calcula a porcentagem restante (0.0 a 1.0)
      // Queremos que ela "decresça", ou seja, comece cheia e vá diminuindo
      double percent = _dashCooldownTimer / _dashCooldown;

      // 1. Desenha o Fundo (Preto/Cinza)
      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth, barHeight),
        Paint()..color = Pallete.preto.withOpacity(0.5),
      );

      // 2. Desenha a Barra Verde (Decrescente)
      canvas.drawRect(
        Rect.fromLTWH(0, yOffset, barWidth * percent, barHeight),
        Paint()..color = Pallete.verdeCla,
      );
    }
  }

//upgrades

  // 1. AUMENTA DANO (Força bruta)
  void increaseDamage() {
    damage += 5.0; // Aumenta 5 pontos de dano
    // Opcional: Feedback visual (piscar cor diferente)
  }

  // 2. AUMENTA VELOCIDADE (Metralhadora)
  void increaseFireRate() {
    fireRate *= 0.85; // Reduz o tempo entre tiros em 15%
    
    // Limite máximo para não quebrar o jogo (não atirar mais rápido que 0.1s)
    if (fireRate < 0.1) fireRate = 0.1; 
  }

  void increaseMovementSpeed(){
    moveSpeed *= 1.2;
  }

  void increaseRange(){
    attackRange *= 1.2;
  }

  void increaseHp(){
    maxHealth++;
    healthNotifier.value++;
  }

}