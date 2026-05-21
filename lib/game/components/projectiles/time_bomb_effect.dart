import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
import 'package:towerrogue/game/components/core/pallete.dart';
import 'package:towerrogue/game/components/enemies/enemy.dart';
import 'package:towerrogue/game/components/projectiles/explosion.dart';
import '../../tower_game.dart';
// Importe a sua classe Enemy aqui!

class TimeBombEffect extends PositionComponent with HasGameRef<TowerGame> {
  final Enemy target;
  final double dano;
  final bool canSpread; // É isso que impede a explosão infinita!
  final double raioExplosao = 62.0;
  
  double _timer = 0;
  final double _duration = 3.0; // 3 segundos até explodir
  bool _exploded = false; // Trava de segurança

  late GameSprite _bombSprite;
  late TextComponent _timerText;

  TimeBombEffect({
    required this.target,
    required this.dano,
    this.canSpread = true, // A primeira bomba sempre espalha
  }) {
    // Coloca a bomba visualmente em cima da cabeça do inimigo
    position = Vector2(target.size.x / 2, -4); 
    anchor = Anchor.bottomCenter;
  }

  @override
  Future<void> onLoad() async {
   _bombSprite = GameSprite(
      imagePath: 'sprites/projeteis/bombaRelogio.png', 
      size: Vector2.all(16), 
      color: Pallete.vermelho, // Ou Pallete.vermelho se quiser ela destacada
      anchor: Anchor.bottomCenter,
      position: Vector2(0, 0),
    );
    add(_bombSprite);

    // 2. Adiciona o Texto do Contador numérico
    _timerText = TextComponent(
      text: _duration.toInt().toString(), // Começa desenhando o '3'
      textRenderer: TextPaint(
        style: const TextStyle(
          fontFamily: 'pixelFont', // Usa a sua fonte pixelada nativa
          color: Pallete.amarelo, // Amarelo ou vermelho dão sensação de alerta
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
      anchor: Anchor.bottomCenter,
      // Posiciona o número flutuando um pouquinho acima do sprite da bomba
      position: Vector2(0, -14), 
    );
    add(_timerText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_exploded) return;

    _timer += dt;

    int tempoRestante = (_duration - _timer).ceil();
    if (tempoRestante >= 0) {
      _timerText.text = tempoRestante.toString();
    }

    // Se o inimigo morrer ANTES da bomba explodir, ela explode antecipadamente!
    // (Isso deixa o jogo muito mais fluido)
    if (target.hp <= 0 && !_exploded) {
      _explodir();
      return;
    }

    // Explode pelo tempo
    if (_timer >= _duration) {
      _explodir();
    }
  }

  void _explodir() {
    _exploded = true;
    
    // 1. Toca o som e cria o efeito visual no mundo
    // AudioManager.playSfx('explosion.mp3');
    // gameRef.world.add(ExplosionVisualEffect(position: target.absoluteCenter));

    // 2. Dano no alvo original (só aplica se ele ainda estiver vivo)
    if (target.hp > 0) {
      gameRef.world.add(Explosion(position: target.absoluteCenter, damagesPlayer:false, damage:dano, radius:raioExplosao, owner: gameRef.player));
    }

    // 3. A REAÇÃO EM CADEIA (Espalhar para outros)
    if (canSpread) {
      final outrosInimigos = gameRef.world.children
          .whereType<Enemy>()
          .where((e) => e != target && e.hp > 0);

      for (final inimigo in outrosInimigos) {
        double dist = target.absoluteCenter.distanceTo(inimigo.absoluteCenter);
        
        if (dist <= raioExplosao) {
          // VERIFICAÇÃO IMPORTANTE: Só adiciona se o inimigo já não tiver uma bomba!
          bool jaTemBomba = inimigo.children.whereType<TimeBombEffect>().isNotEmpty;
          
          if (!jaTemBomba) {
            // Adiciona a bomba secundária (metade do dano, NÃO ESPALHA)
            inimigo.add(TimeBombEffect(
              target: inimigo,
              dano: dano * 0.5, 
              canSpread: false, // <-- A MÁGICA QUE IMPEDE O LOOP INFINITO
            ));
          }
        }
      }
    }

    // Remove a bomba do inimigo
    removeFromParent();
  }
}