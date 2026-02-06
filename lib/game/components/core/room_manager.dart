import 'dart:math';
import 'package:TowerRogue/game/components/gameObj/unlockable_item.dart';
import 'package:flame/components.dart';
import '../../tower_game.dart';
import '../gameObj/door.dart';
import '../gameObj/collectible.dart';
import '../gameObj/wall.dart';
import '../gameObj/chest.dart';
//importacao de inimigos
import '../enemies/enemy.dart';
import '../enemies/enemy_shooter.dart';
import '../enemies/enemy_bouncer.dart';
import '../enemies/enemy_dasher.dart';
import '../enemies/enemy_spinner.dart';
import '../enemies/enemy_boss1.dart';

typedef EnemyFactory = PositionComponent Function(Vector2 position);

class RoomManager extends Component with HasGameRef<TowerGame> {
  
  bool _levelCleared = false;
  // Timer para evitar que a sala complete no frame 0
  double _checkTimer = 0.0; 

  int get bossRoom => gameRef.bossRoom;

  final double _minTimeBeforeClear = 0.2; // 1 segundo de espera antes de verificar
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
    
    if (gameRef.nextRoomReward != CollectibleType.shop && roomNumber > 0) _generateMap(roomNumber);
    
    // LÓGICA DE SPAWN DO BOSS
    if (roomNumber == bossRoom) {
      // É SALA DE CHEFE!
      print("ALERTA: BOSS FIGHT!");
      
      // Spawna apenas O CHEFE no centro (ou um pouco acima)
      gameRef.world.add(BossEnemy(
        position: Vector2(0, -150), 
        level: roomNumber // Boss fica mais forte em salas avançadas
      ));
      
      // gameRef.world.add(ShooterEnemy(position: Vector2(-100, -150)));
      // gameRef.world.add(ShooterEnemy(position: Vector2(100, -150)));

    } else {
      // SALA NORMAL
      _spawnEnemies(roomNumber);
    }
    
    _spawnDoors(roomNumber);
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

    int obstacleCount = 3 + rng.nextInt(3); 
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
    if (roomNumber == 0) return;
    
    final rng = Random();
    
    int baseCount = 2 + (roomNumber ~/ 2); 
    int targetEnemyCount = baseCount + rng.nextInt(3);
    if (targetEnemyCount > 12) targetEnemyCount = 12;

    int enemiesSpawned = 0;
    int attempts = 0; 

    while (enemiesSpawned < targetEnemyCount && attempts < 100) {
      attempts++;

      double x = (rng.nextDouble() * 300) - 150;
      double y = (rng.nextDouble() * 150) - 200;//-50 a - 220
      final pos = Vector2(x, y);

      if (pos.distanceTo(Vector2.zero()) < 140) {
        continue; 
      }

      EnemyFactory selectedEnemyFactory;
      if (roomNumber == 1) {
        selectedEnemyFactory = _enemyRoster[0]; 
      } else {
        selectedEnemyFactory = _enemyRoster[rng.nextInt(_enemyRoster.length)];
      }

      gameRef.world.add(selectedEnemyFactory(pos));
      enemiesSpawned++; 
    }
    
    print("Tentativa de spawnar: $targetEnemyCount | Spawnados: $enemiesSpawned");
  }

void _spawnDoors(int roomNumber) {
    if (roomNumber == bossRoom-1) {
      gameRef.world.add(Door(
        position: Vector2(0, -300), 
        rewardType: CollectibleType.boss,
      ));
      return;
    }else if(roomNumber == bossRoom) {
      gameRef.world.add(Door(
        position: Vector2(0, -300), 
        rewardType: CollectibleType.nextlevel,
      ));
      return;
    }
    final rng = Random();

    // 1. DEFINIR O POOL DE RECOMPENSAS
    // Começamos com as básicas que queremos que apareçam com frequência
    // Usamos um Set para garantir que não haja duplicatas na lista inicial
    Set<CollectibleType> possibleRewards = {
      CollectibleType.coin,
      CollectibleType.potion,
      CollectibleType.shield,
    };

    // 2. ADICIONAR RECOMPENSAS RARAS (Com base na sorte)
    
    // Chance de Chave
    if (rng.nextDouble() < 0.40) possibleRewards.add(CollectibleType.key);
    
    // Chance de Baú
    if (rng.nextDouble() < 0.25) possibleRewards.add(CollectibleType.chest);

    // Chance de conteiner de vida
    if (rng.nextDouble() < 0.25) possibleRewards.add(CollectibleType.healthContainer);
    
    // --- NOVO: Chance de Loja (15% a 20%) ---
    // Só aparece se não for a própria loja (para não ter loop de lojas infinitas, se quiser)
    if (gameRef.nextRoomReward != CollectibleType.shop && rng.nextDouble() < 0.20) {
      possibleRewards.add(CollectibleType.shop);
    }

    // 3. CONVERTER PARA LISTA E COMPLETAR (SEGURANÇA)
    // Precisamos de no mínimo 2 itens diferentes.
    List<CollectibleType> finalPool = possibleRewards.toList();

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

  void _generateShopRoom(){
    gameRef.world.add(Collectible(
        position: Vector2(-80, -50),
        type: CollectibleType.potion,
        custo : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(80, -50),
        type: CollectibleType.shield,
        custo : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(-80, 50),
        type: CollectibleType.key,
        custo : 15
      ));

      final rng = Random();

      final List<CollectibleType> shopPool = [
        CollectibleType.damage,
        CollectibleType.fireRate,
        CollectibleType.moveSpeed,
        CollectibleType.range,
      ];

      final selectedType = shopPool[rng.nextInt(shopPool.length)];

      int preco = 50;

      gameRef.world.add(Collectible(
        position: Vector2(80, 50),
        type: selectedType,
        custo : preco
      ));
  }

  void _generateZeroRoom(){
    switch (gameRef.currentLevel){
      case 1:
        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, -60),
          id: 'permanent_shield_1', 
          type: CollectibleType.shield,
          soulCost: 200,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, 0),
          id: 'permanent_health_1', 
          type: CollectibleType.healthContainer,
          soulCost: 500,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, 60),
          id: 'permanent_fire_rate_1', 
          type: CollectibleType.fireRate,
          soulCost: 900,
        ));
        break;
      case 2:
        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, 0),
          id: 'permanent_health_2', 
          type: CollectibleType.healthContainer,
          soulCost: 800,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, -60),
          id: 'permanent_shield_2', 
          type: CollectibleType.shield,
          soulCost: 500,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(-80, 60),
          id: 'permanent_damage_2', 
          type: CollectibleType.damage,
          soulCost: 1200,
        ));
        break;
      default:
        break;
    }
    
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
      
    } else if (gameRef.nextRoomReward == CollectibleType.shop){
      _generateShopRoom();
    }else if (gameRef.nextRoomReward == CollectibleType.nextlevel){
      _generateZeroRoom();
    }else {
      // Se for Moeda, Poção ou Chave, cria o item direto
      gameRef.world.add(Collectible(
        position: Vector2(0, 0),
        type: gameRef.nextRoomReward,
      ));
    }

    print("SALA LIMPA! ${doors.length} PORTAS ABERTAS.");
  }
}