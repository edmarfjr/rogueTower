import 'dart:math';
import 'package:flame/components.dart';
import '../tower_game.dart';
import 'door.dart';
import 'collectible.dart';
import 'wall.dart';
import 'chest.dart';
//importacao de inimigos
import 'enemies/enemy.dart';
import 'enemies/enemy_shooter.dart';
import 'enemies/enemy_boss1.dart';

typedef EnemyFactory = PositionComponent Function(Vector2 position);

class RoomManager extends Component with HasGameRef<TowerGame> {
  
  bool _levelCleared = false;
  
  // Timer para evitar que a sala complete no frame 0
  double _checkTimer = 0.0; 
  final double _minTimeBeforeClear = 1.0; // 1 segundo de espera antes de verificar
  final List<EnemyFactory> _enemyRoster = [
    (pos) => Enemy(position: pos),        // Inimigo Comum (Inseto)
    (pos) => ShooterEnemy(position: pos), // Inimigo Atirador (Robô)
    // Futuro: (pos) => TankEnemy(position: pos),
    // Futuro: (pos) => FastEnemy(position: pos),
  ];

  @override
  void update(double dt) {
    super.update(dt);
    
    // Incrementa o timer
    _checkTimer += dt;

    // Só começa a checar se já passou o tempo de "nascimento" dos inimigos
    if (_checkTimer < _minTimeBeforeClear) return;

    if (!_levelCleared) {
      final enemies = gameRef.world.children.query<Enemy>();
      
      // Se não tem inimigos (e já passamos do tempo de loading inicial)
      if (enemies.isEmpty) {
        _unlockDoors();
        _levelCleared = true;
      }
    }
  }

  void startRoom(int roomNumber) {
    _levelCleared = false;
    _checkTimer = 0.0; 
    
    _generateMap(roomNumber);

    // LÓGICA DE SPAWN DO BOSS
    if (roomNumber % 5 == 0) {
      // É SALA DE CHEFE!
      print("ALERTA: BOSS FIGHT!");
      
      // Spawna apenas O CHEFE no centro (ou um pouco acima)
      gameRef.world.add(BossEnemy(
        position: Vector2(0, -150), 
        level: roomNumber // Boss fica mais forte em salas avançadas
      ));
      
      // Opcional: Adicionar 2 minions para ajudar o chefe
      // gameRef.world.add(ShooterEnemy(position: Vector2(-100, -150)));
      // gameRef.world.add(ShooterEnemy(position: Vector2(100, -150)));

    } else {
      // SALA NORMAL
      _spawnEnemies(roomNumber);
    }
    
    _spawnDoors();
    print("Sala $roomNumber iniciada...");
  }

  void _generateMap(int seed) {
    // Limpeza garantida (caso resetGame não tenha rodado por algum motivo)
    gameRef.world.children.query<Wall>().forEach((w) => w.removeFromParent());

    final rng = Random();
    
    // Lista para guardar onde já colocamos coisas (paredes, player, portas)
    // Começa protegendo a área do Player (0,0)
    final List<Vector2> occupiedPositions = [Vector2.zero()];
    
    // Chance de ter obstáculos
    if (rng.nextDouble() > 0.8) return; 

    int obstacleCount = 4 + rng.nextInt(6); // 4 a 10 paredes
    int attempts = 0; // Segurança para não travar o jogo num loop infinito

    while (occupiedPositions.length < obstacleCount + 1 && attempts < 100) {
      attempts++;

      double x = (rng.nextDouble() * 300) - 150;
      double y = (rng.nextDouble() * 400) - 200; 
      final candidatePos = Vector2(x, y);

      // --- REGRAS DE VALIDAÇÃO ---
      
      // 1. Longe das Portas (Topo da tela)
      if (y < -200) continue;

      // 2. Distância Mínima de outras Paredes/Player
      // Usamos 40 de raio (32 da parede + margem)
      bool tooClose = false;
      for (final pos in occupiedPositions) {
        if (candidatePos.distanceTo(pos) < 50) { // 50px de distância mínima
          tooClose = true;
          break;
        }
      }

      if (tooClose) continue; // Tenta de novo se estiver perto

      // Se passou em tudo, adiciona!
      gameRef.world.add(Wall(position: candidatePos));
      occupiedPositions.add(candidatePos);
    }
  }

  void _spawnEnemies(int roomNumber) {
    final rng = Random();
    
    // Dificuldade: Mais inimigos conforme a sala avança
    // Sala 1: 2-3 inimigos
    // Sala 10: 5-7 inimigos
    int baseCount = 2 + (roomNumber ~/ 2); 
    int enemyCount = baseCount + rng.nextInt(3);
    if (enemyCount > 12) enemyCount = 12; // Limite para não lotar a tela

    for (int i = 0; i < enemyCount; i++) {
      double x = (rng.nextDouble() * 300) - 150;
      double y = (rng.nextDouble() * 400) - 200;

      // Área segura do player (centro)
      if (Vector2(x, y).distanceTo(Vector2.zero()) < 100) continue;

      // 2. SORTEIO INTELIGENTE
      // Se for sala 1, força apenas o inimigo básico (índice 0).
      // Se for sala > 1, sorteia qualquer um da lista.
      
      EnemyFactory selectedEnemyFactory;
      
      if (roomNumber == 1) {
        selectedEnemyFactory = _enemyRoster[0]; // Só básico
      } else {
        // Sorteia um índice da lista aleatoriamente
        selectedEnemyFactory = _enemyRoster[rng.nextInt(_enemyRoster.length)];
      }

      // Cria e adiciona
      gameRef.world.add(selectedEnemyFactory(Vector2(x, y)));
    }
  }

void _spawnDoors() {
    final rng = Random();
    
    // Lista de possíveis recompensas para aparecer nas portas
    final options = [
      CollectibleType.potion,
      CollectibleType.coin,
      CollectibleType.key,
      CollectibleType.chest
    ];

    // Escolhe duas recompensas aleatórias diferentes (opcional: ou iguais)
    CollectibleType rewardLeft = options[rng.nextInt(options.length)];
    CollectibleType rewardRight = options[rng.nextInt(options.length)];

    // Porta Esquerda
    gameRef.world.add(Door(
      position: Vector2(-80, -300), 
      rewardType: rewardLeft
    )); 
    
    // Porta Direita
    gameRef.world.add(Door(
      position: Vector2(80, -300),
      rewardType: rewardRight
    ));  
  }

  void _unlockDoors() {
    final doors = gameRef.world.children.query<Door>();
    
    if (doors.isEmpty) {
      print("AVISO: Tentei abrir portas, mas não encontrei nenhuma na lista!");
      return;
    }

    for (final door in doors) {
      door.open();
    }

   // LÓGICA DE SPAWN DA RECOMPENSA
    if (gameRef.nextRoomReward == CollectibleType.chest) {
      // Se a recompensa da sala é BAÚ, cria o objeto Chest físico
      print("Criando Baú de Recompensa!");
      
      gameRef.world.add(Chest(
        position: Vector2(0, 0), // Centro da sala
      ));
      
    } else {
      // Se for Moeda, Poção ou Chave, cria o item direto
      gameRef.world.add(Collectible(
        position: Vector2(0, 0),
        type: gameRef.nextRoomReward,
      ));
    }

    print("SALA LIMPA! ${doors.length} PORTAS ABERTAS.");
  }
}