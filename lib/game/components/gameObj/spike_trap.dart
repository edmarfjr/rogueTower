import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

import 'player.dart'; // Ajuste o caminho para o seu player!

enum TrapState { hidden, warning, active }

class SpikeTrap extends PositionComponent with CollisionCallbacks {
  TrapState state = TrapState.hidden;
  double timer = 0.0;

  SpikeTrap({required Vector2 position}) : super(position: position, size: Vector2(40, 40)) {
    // Adiciona o colisor para detectar quem pisa
    add(RectangleHitbox(isSolid: true));
    
    // Fica no chão (priority baixa para não ficar por cima dos inimigos)
    priority = -2; 
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer += dt;

    // Ciclo de vida infinito: Escondido (2s) -> Aviso (1s) -> Ativo (2s)
    if (state == TrapState.hidden && timer > 2.0) {
      state = TrapState.warning;
      timer = 0.0;
    } else if (state == TrapState.warning && timer > 1.0) {
      state = TrapState.active;
      timer = 0.0;
    } else if (state == TrapState.active && timer > 2.0) {
      state = TrapState.hidden;
      timer = 0.0;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint();
    
    // --- REPRESENTAÇÃO VISUAL (Substitua por Sprites no futuro) ---
    paint.color = Pallete.azulEsc; 
    canvas.drawRect(size.toRect(), paint);
    if (state == TrapState.hidden) {
      paint.color = Pallete.cinzaEsc;
      canvas.drawRect(const Rect.fromLTWH(7, 10, 6, 2), paint);
      canvas.drawRect(const Rect.fromLTWH(27, 10, 6, 2), paint);
      canvas.drawRect(const Rect.fromLTWH(7, 30, 6, 2), paint);
      canvas.drawRect(const Rect.fromLTWH(27, 30, 6, 2), paint);
      //canvas.drawCircle(const Offset(30, 10), 3, paint);
      //canvas.drawCircle(const Offset(10, 30), 3, paint);
      //canvas.drawCircle(const Offset(30, 30), 3, paint);
      
    } 
    else if (state == TrapState.warning) {
      // Fica laranja para avisar o perigo
      //paint.color = Colors.orange.withOpacity(0.5); 
      //canvas.drawRect(size.toRect(), paint);
      
      // Pontinhas pequenas aparecendo
      paint.color = Pallete.cinzaEsc;
      canvas.drawCircle(const Offset(10, 10), 6, paint);
      canvas.drawCircle(const Offset(30, 10), 6, paint);
      canvas.drawCircle(const Offset(10, 30), 6, paint);
      canvas.drawCircle(const Offset(30, 30), 6, paint);
    } 
    else if (state == TrapState.active) {
      // Fundo vermelho sangue escuro
      //paint.color = const Color(0xFF8B0000); 
      //canvas.drawRect(size.toRect(), paint);

      // Configura a tinta para os espinhos (Branco/Prata afiado)
      paint.color = Pallete.lilas;
      paint.style = PaintingStyle.fill; // Garante que o triângulo seja preenchido

      canvas.drawCircle(const Offset(10, 10), 6, paint);
      canvas.drawCircle(const Offset(30, 10), 6, paint);
      canvas.drawCircle(const Offset(10, 30), 6, paint);
      canvas.drawCircle(const Offset(30, 30), 6, paint);

      // O 'Path' é a nossa caneta para desenhar formas complexas
      final spikePath = Path();

      // --- Espinho Superior Esquerdo ---
      spikePath.moveTo(10, -8);  // 1. Move a caneta para a ponta (topo)
      spikePath.lineTo(4, 10);  // 2. Linha até a base esquerda
      spikePath.lineTo(16, 10); // 3. Linha até a base direita
      spikePath.close();        // 4. Fecha o triângulo (volta pra ponta)

      // --- Espinho Superior Direito ---
      spikePath.moveTo(30, -8);
      spikePath.lineTo(24, 10);
      spikePath.lineTo(36, 10);
      spikePath.close();

      // --- Espinho Inferior Esquerdo ---
      // Note que a base agora é no y=40 e a ponta no y=20
      spikePath.moveTo(10, 8); // Ponta (no meio da armadilha)
      spikePath.lineTo(4, 30);  // Base baixo-esq
      spikePath.lineTo(16, 30); // Base baixo-dir
      spikePath.close();

      // --- Espinho Inferior Direito ---
      spikePath.moveTo(30, 8);
      spikePath.lineTo(24, 30);
      spikePath.lineTo(36, 30);
      spikePath.close();

      // Finalmente, desenha todos os triângulos que definimos no caminho
      canvas.drawPath(spikePath, paint);
    }
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    
    // Só machuca se estiver com os espinhos para fora!
    if (state == TrapState.active) {
      if (other is Player) {
        other.takeDamage(1);
      }
      
      // DICA DE OURO: Descomente abaixo se quiser que os espinhos 
      // machuquem os inimigos também (os jogadores adoram usar o cenário a favor deles!)
      /*
      if (other is Enemy && !other.isIntangivel) {
        other.takeDamage(1); 
      }
      */
    }
  }
}