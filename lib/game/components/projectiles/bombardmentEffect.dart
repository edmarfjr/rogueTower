import 'dart:math';
import 'package:flame/components.dart';
import '../../tower_game.dart';
import '../projectiles/explosion.dart'; // Verifique o caminho da sua classe Explosion

class BombardmentEffect extends Component with HasGameRef<TowerGame> {
  final int totalExplosions;
  final double interval;
  final double damage;
  final double radius;
  
  double _timer = 0;
  int _count = 0;
  final Random _rnd = Random();

  BombardmentEffect({
    this.totalExplosions = 10, // Quantas bombas vão cair no total
    this.interval = 0.25,      // Tempo entre cada bomba (0.25 segundos)
    required this.damage,
    this.radius = 150,
  });

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    // Quando o tempo limite é atingido, solta uma bomba!
    if (_timer >= interval) {
      _timer = 0; // Zera o relógio para a próxima bomba
      _spawnExplosion();
      _count++;

      // Se já soltou todas as bombas, este gerenciador apaga-se a si mesmo
      if (_count >= totalExplosions) {
        removeFromParent();
      }
    }
  }

  void _spawnExplosion() {
    final playerPos = gameRef.player.position;
    
    final offsetX = (_rnd.nextDouble() - 0.5) * TowerGame.gameWidth;
    final offsetY = (_rnd.nextDouble() - 0.5) * TowerGame.gameHeight;

    final targetPos = playerPos + Vector2(offsetX, offsetY);

    gameRef.world.add(Explosion(
      position: targetPos,
      damagesPlayer: false, 
      damage: damage,
      radius: radius, 
    ));
  }
}