import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/src/foundation/change_notifier.dart';
import '../../tower_game.dart';

// --- IMPORTS DE OBJETOS DO JOGO ---
import '../gameObj/door.dart';
import '../gameObj/collectible.dart';
import '../gameObj/wall.dart';
import '../gameObj/chest.dart';
import '../gameObj/bank_atm.dart';
import '../gameObj/unlockable_item.dart';
import '../effects/explosion.dart';
import '../core/pallete.dart';

// --- NOVA INTEGRAÇÃO DE INIMIGOS ---
import '../enemies/enemy.dart'; 
import '../enemies/enemy_factory.dart'; // <--- O novo arquivo fábrica
import '../enemies/enemy_boss2.dart';   // Mantemos o Boss separado por ser único

// Define a assinatura da função que cria inimigos
typedef EnemyFactoryFunction = Enemy Function(Vector2 position);

class RoomManager extends Component with HasGameRef<TowerGame> {
  
  bool _levelCleared = false;
  double _checkTimer = 0.0; 

  bool teveShop = false;
  bool teveBanco = false;

  int get bossRoom => gameRef.bossRoom;

  final double _minTimeBeforeClear = 0.5; // Tempo mínimo para evitar clear instantâneo
  
  final List<EnemyFactoryFunction> _enemyRoster1 = [
    (pos) => EnemyFactory.createRat(pos), 
    (pos) => EnemyFactory.createFungi(pos),  
    (pos) => EnemyFactory.createBeeHive(pos),
    (pos) => EnemyFactory.createBug(pos),    
    (pos) => EnemyFactory.createSnail(pos),  
    (pos) => EnemyFactory.createSlimeM(pos),  
  ];

  final List<EnemyFactoryFunction> _enemyRoster2 = [
    (pos) => EnemyFactory.createBat(pos), 
    (pos) => EnemyFactory.createSnake(pos),  
    (pos) => EnemyFactory.createMere(pos),  
    (pos) => EnemyFactory.createSpider(pos),  
    (pos) => EnemyFactory.createCoffin(pos),  
    (pos) => EnemyFactory.createHorseMan(pos),   
  ];

  ValueListenable<int>? get currentRoomNotifier => null;

  @override
  void update(double dt) {
    super.update(dt);
    
    _checkTimer += dt;
    if (_checkTimer < _minTimeBeforeClear) return;

    if (!_levelCleared) {
      // Verifica se ainda existem inimigos vivos
      final enemies = gameRef.world.children.query<Enemy>();
      
      if (enemies.isEmpty) {
        _unlockDoors();
        _levelCleared = true;
      }
    }
  }

  void startRoom(int roomNumber) {
    
    _levelCleared = false;
    _checkTimer = 0.0; 

    if (gameRef.nextRoomReward == CollectibleType.bank){
      _spawnBankRoom(); 
      return;
    } 

    if (gameRef.player.magicShield) gameRef.player.activateShield();
    
    // Geração do Mapa (Obstáculos)
    if (gameRef.nextRoomReward != CollectibleType.shop && roomNumber > 0) _generateMap(roomNumber);
    
    // --- LÓGICA DE SPAWN ---
    if (roomNumber == bossRoom) {
      print("ALERTA: BOSS FIGHT!");
      
      // O Boss ainda usa sua classe própria pois tem lógica complexa de HUD e fases
      if (gameRef.currentLevel == 1){
        gameRef.world.add(EnemyFactory.createKingSlime1(Vector2(0, -150)));
      }else if(gameRef.currentLevel == 2){
        gameRef.world.add(BossEnemy(
          position: Vector2(0, -150), 
          level: roomNumber 
        ));
      }
      

    } else {
      _spawnEnemies(roomNumber);
    }
    
    _spawnDoors(roomNumber);
    print("Sala $roomNumber iniciada...");
    gameRef.atualizaDebugMode();
  }

  void _generateMap(int seed) {
    // Remove paredes antigas
    gameRef.world.children.query<Wall>().forEach((w) => w.removeFromParent());

    final rng = Random();
    final List<Vector2> occupiedPositions = [Vector2.zero()];
    
    if (rng.nextDouble() > 0.8) return; 

    int obstacleCount = 3 + rng.nextInt(3); 
    int attempts = 0; 

    while (occupiedPositions.length < obstacleCount + 1 && attempts < 100) {
      attempts++;

      double x = (rng.nextDouble() * 300) - 150;
      double y = (rng.nextDouble() * 400) - 200; 
      final candidatePos = Vector2(x, y);

      // Validação de Posição
      if (y < -200) continue; // Longe das portas

      bool tooClose = false;
      for (final pos in occupiedPositions) {
        if (candidatePos.distanceTo(pos) < 50) { 
          tooClose = true;
          break;
        }
      }

      if (tooClose) continue; 

      gameRef.world.add(Wall(position: candidatePos));
      occupiedPositions.add(candidatePos);
    }
  }

  void _spawnEnemies(int roomNumber) {
    if (roomNumber == 0) return;
    
    final rng = Random();
    
    // Dificuldade progressiva
    int baseCount = 2 + (roomNumber ~/ 2); 
    int targetEnemyCount = baseCount + rng.nextInt(3);
    if (targetEnemyCount > 12) targetEnemyCount = 12;

    int enemiesSpawned = 0;
    int attempts = 0; 

    while (enemiesSpawned < targetEnemyCount && attempts < 100) {
      attempts++;

      double x = (rng.nextDouble() * 180) - 130;
      double y = (rng.nextDouble() * 150) - 200;
      final pos = Vector2(x, y);

      // Zona segura no centro para o player nascer
      if (pos.distanceTo(Vector2.zero()) < 140) {
        continue; 
      }

      // Escolha do Inimigo
      EnemyFactoryFunction selectedFactory;
      
      switch (gameRef.currentLevelNotifier.value){
        case 1:
          selectedFactory = _enemyRoster1[rng.nextInt(_enemyRoster1.length)];
        case 2:
          selectedFactory = _enemyRoster2[rng.nextInt(_enemyRoster2.length)];
        default:
          selectedFactory = _enemyRoster1[rng.nextInt(_enemyRoster1.length)];
      }
      

      // Criação usando a Factory
      gameRef.world.add(selectedFactory(pos));
      enemiesSpawned++; 
    }
    
    gameRef.atualizaDebugMode();
  }

  void _spawnDoors(int roomNumber) {
    // Porta do Boss ou Próximo Nível
    if (roomNumber == bossRoom - 1) {
      gameRef.world.add(Door(
        position: Vector2(0, -300), 
        rewardType: CollectibleType.boss,
      ));
      return;
    } else if (roomNumber == bossRoom) {
      gameRef.world.add(Door(
        position: Vector2(0, -300), 
        rewardType: CollectibleType.nextlevel,
      ));
      return;
    }

    final rng = Random();

    // Pool de Recompensas
    Set<CollectibleType> possibleRewards = {
      CollectibleType.coin,
      CollectibleType.potion,
      CollectibleType.shield,
      CollectibleType.key,
      CollectibleType.healthContainer,
    };

    if (roomNumber > 1){
      possibleRewards.add(CollectibleType.chest);
      if (gameRef.nextRoomReward != CollectibleType.shop){
        possibleRewards.add(CollectibleType.shop);
      }
      if (gameRef.nextRoomReward != CollectibleType.bank && !teveBanco){
        possibleRewards.add(CollectibleType.bank);
      }
    }

    List<CollectibleType> finalPool = possibleRewards.toList();

    while (finalPool.length < 2) {
      if (!finalPool.contains(CollectibleType.key)) {
        finalPool.add(CollectibleType.key);
      } else if (!finalPool.contains(CollectibleType.chest)) {
        finalPool.add(CollectibleType.chest);
      }
    }

    finalPool.shuffle();
    CollectibleType rewardLeft = finalPool[0];
    CollectibleType rewardRight = finalPool[1];

   // garantir que tenha shop pelomenos antes do boss
    if(rewardLeft == CollectibleType.shop || rewardRight == CollectibleType.shop){
      teveShop = true;
    }

    if (gameRef.currentRoomNotifier.value == gameRef.bossRoom-2 && !teveShop){
      rewardLeft = CollectibleType.shop;
    }

    //garantir que tenha mais de um banco por andar
    if(rewardLeft == CollectibleType.bank || rewardRight == CollectibleType.bank){
      teveBanco = true;
    }

    //limpar as var de sala unica por andar

    if (gameRef.currentRoomNotifier.value == gameRef.bossRoom){
      teveShop = false;
      teveBanco = false;
    } 

    gameRef.world.add(Door(
      position: Vector2(-100, -300), 
      rewardType: rewardLeft,
    ));

    gameRef.world.add(Door(
      position: Vector2(100, -300),
      rewardType: rewardRight,
    ));
  }
  void _spawnBankRoom() {
      // 1. Cria o ATM no centro
      gameRef.world.add(BankAtm(position: Vector2(0, 0)));
      
    }
  void _generateShopRoom(){
    gameRef.world.add(Collectible(
        position: Vector2(-80, -50),
        type: CollectibleType.potion,
        naoEsgota: true,
        custo : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(80, -50),
        type: CollectibleType.shield,
        naoEsgota: true,
        custo : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(-80, 50),
        type: CollectibleType.key,
        naoEsgota: true,
        custo : 15
      ));

      int preco = 30;
      _generateItemAleatorio(Vector2(80,50), preco); 
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
    
    if (doors.isEmpty) return;

    for (final door in doors) {
      door.open();
    }
    
    // Cria a recompensa no centro
    if (gameRef.nextRoomReward == CollectibleType.chest) {
      _explosaoCriaItem();
      gameRef.world.add(Chest(position: Vector2(0, 0)));
      
    } else if (gameRef.nextRoomReward == CollectibleType.shop){
      _generateShopRoom();
    } else if (gameRef.nextRoomReward == CollectibleType.nextlevel){
      _generateZeroRoom();
    } else if (gameRef.nextRoomReward == CollectibleType.boss){
      _explosaoCriaItem();
      _generateBossReward();
    } else {
      _explosaoCriaItem();
      gameRef.world.add(Collectible(
        position: Vector2(0, 0),
        type: gameRef.nextRoomReward,
      ));
    }

    gameRef.atualizaDebugMode();
  }

  void _generateItemAleatorio(Vector2 pos, [int preco = 0]) {
     final rng = Random();

    final List<CollectibleType> possibleRewards = [
      CollectibleType.damage,
      CollectibleType.fireRate,
      CollectibleType.moveSpeed, 
      CollectibleType.range, 
      CollectibleType.healthContainer,
      CollectibleType.steroids,
      CollectibleType.cafe, 
      CollectibleType.keys, 
      CollectibleType.dash,
    ];
    if (!gameRef.player.isBerserk) possibleRewards.add(CollectibleType.berserk);
    if (!gameRef.player.isAudaz) possibleRewards.add(CollectibleType.audacious);
    if (!gameRef.player.isFreeze) possibleRewards.add(CollectibleType.freeze);
    if (!gameRef.player.magicShield) possibleRewards.add(CollectibleType.magicShield);

    final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];
    
    gameRef.world.add(Collectible(position: pos, type: lootType, custo: preco));
  }
  
  void _generateBossReward() {
    _generateItemAleatorio(Vector2(0,0));
    gameRef.world.add(Collectible(position: Vector2(30,0), type: CollectibleType.coin));
    gameRef.world.add(Collectible(position: Vector2(-30,0), type: CollectibleType.coin));
  }
  
  void _explosaoCriaItem() {
    final directions = [
      Vector2(0, 0), Vector2(20, 0), Vector2(-20, 0),
      Vector2(0, 20), Vector2(0, -20), Vector2(20, 20),
      Vector2(20, -20), Vector2(-20, -20), Vector2(-20, 20),
    ];

    for (var dir in directions) {
      createExplosion(gameRef.world, dir, Pallete.lilas, count: 10);
    }
  }
}