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
import 'enemies/enemy_bouncer.dart';
import 'enemies/enemy_dasher.dart';
import 'enemies/enemy_spinner.dart';
import 'enemies/enemy_boss1.dart';

typedef EnemyFactory = PositionComponent Function(Vector2 position);

class RoomManager extends Component with HasGameRef<TowerGame> {
  
  bool _levelCleared = false;
  
  // Timer para evitar que a sala complete no frame 0
  double _checkTimer = 0.0; 
  final double _minTimeBeforeClear = 1.0; // 1 segundo de espera antes de verificar
  final List<EnemyFactory> _enemyRoster = [
    (pos) => Enemy(position: pos),         // 0: Segue (Comum)
    (pos) => ShooterEnemy(position: pos),  // 1: Atira (Comportamento de torre/kite)
    (pos) => SpinnerEnemy(position: pos),  // 2: Aleatório + 4 Tiros
    (pos) => DasherEnemy(position: pos),   // 3: Mira e Investe
    (pos) => BouncerEnemy(position: pos),  // 4: Rebate
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
    if (rng.nextDouble() > 0.5) return; 

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

    // 1. DEFINIR O POOL DE RECOMPENSAS
    // Começamos com as básicas que queremos que apareçam com frequência
    // Usamos um Set para garantir que não haja duplicatas na lista inicial
    Set<CollectibleType> possibleRewards = {
      CollectibleType.coin,
      CollectibleType.potion,
    };

    // 2. ADICIONAR RECOMPENSAS RARAS (Com base na sorte)
    
    // 40% de chance de aparecer uma Chave na seleção
    if (rng.nextDouble() < 0.40) {
      possibleRewards.add(CollectibleType.key);
    }
    
    // 25% de chance de aparecer um Baú na seleção (Upgrades)
    // (Pode aumentar essa chance se o jogador estiver em salas avançadas)
    if (rng.nextDouble() < 0.25) {
      possibleRewards.add(CollectibleType.chest);
    }

    // 3. CONVERTER PARA LISTA E COMPLETAR (SEGURANÇA)
    // Precisamos de no mínimo 2 itens diferentes.
    List<CollectibleType> finalPool = possibleRewards.toList();

    // Se por azar o RNG não adicionou chaves nem baús e só temos [coin, potion], 
    // já temos 2. Mas se no futuro você mudar a lógica e tiver menos de 2,
    // esse while garante que o jogo não trave.
    while (finalPool.length < 2) {
      // Adiciona tipos forçados se faltar opção
      if (!finalPool.contains(CollectibleType.key)) {
        finalPool.add(CollectibleType.key);
      } else if (!finalPool.contains(CollectibleType.chest)) {
        finalPool.add(CollectibleType.chest);
      }
    }

    // 4. EMBARALHAR (SHUFFLE)
    // Isso mistura a lista. Ex: vira [Key, Coin, Potion]
    finalPool.shuffle();

    // 5. PEGAR OS DOIS PRIMEIROS
    // Como a lista foi embaralhada, pegamos o índice 0 e o índice 1.
    // Como são índices diferentes da mesma lista de itens únicos, nunca serão iguais.
    CollectibleType rewardLeft = finalPool[0];
    CollectibleType rewardRight = finalPool[1];

    // --- CRIA AS PORTAS ---

    // Porta da Esquerda
    gameRef.world.add(Door(
      position: Vector2(-100, -300), // Ajuste a posição Y conforme seu mapa
      rewardType: rewardLeft,
    ));

    // Porta da Direita
    gameRef.world.add(Door(
      position: Vector2(100, -300),
      rewardType: rewardRight,
    ));
    
    print("Portas geradas: $rewardLeft e $rewardRight");
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