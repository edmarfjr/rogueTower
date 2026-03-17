import 'dart:math';
import 'package:TowerRogue/game/components/core/audio_manager.dart';
import 'package:TowerRogue/game/components/gameObj/spike_trap.dart';
import 'package:flame/components.dart';
// ignore: implementation_imports
import 'package:flutter/src/foundation/change_notifier.dart';
import '../../tower_game.dart';

// --- IMPORTS DE OBJETOS DO JOGO ---
import '../gameObj/door.dart';
import '../gameObj/collectible.dart';
import '../gameObj/wall.dart';
import '../gameObj/chest.dart';
import '../gameObj/bank_atm.dart';
import '../gameObj/unlockable_item.dart';
import '../effects/explosion_effect.dart';
import '../core/pallete.dart';

// --- NOVA INTEGRAÇÃO DE INIMIGOS ---
import '../enemies/enemy.dart'; 
import '../enemies/enemy_factory.dart'; 

// Define a assinatura da função que cria inimigos
typedef EnemyFactoryFunction = Enemy Function(Vector2 position);

class RoomManager extends Component with HasGameRef<TowerGame> {
  
  bool _levelCleared = false;
  double _checkTimer = 0.0; 

  bool teveShop = false;
  bool teveDarkShop = false;
  bool teveBanco = false;
  bool teveDesafio = false;
  bool teveAlquimista = false;

  bool isSpawnningBoss = false;

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
    (pos) => EnemyFactory.createGhost(pos),  
    (pos) => EnemyFactory.createMere(pos),  
    (pos) => EnemyFactory.createSpider(pos),  
    (pos) => EnemyFactory.createCoffin(pos),  
    (pos) => EnemyFactory.createHorseMan(pos),   
  ];

  final List<EnemyFactoryFunction> _enemyRoster3 = [
    (pos) => EnemyFactory.createChessKnight(pos), 
    (pos) => EnemyFactory.createChessPawn(pos), 
    (pos) => EnemyFactory.createChessRook(pos), 
    (pos) => EnemyFactory.createChessBishop(pos), 
    (pos) => EnemyFactory.createChessKing(pos), 
    (pos) => EnemyFactory.createChessQueen(pos), 
  ];

  final List<EnemyFactoryFunction> _enemyRoster4 = [
    (pos) => EnemyFactory.createRabbit(pos), 
    (pos) => EnemyFactory.createUnicorn(pos), 
    (pos) => EnemyFactory.createElephant(pos), 
    (pos) => EnemyFactory.createBird(pos), 
    (pos) => EnemyFactory.createSnake(pos), 
    (pos) => EnemyFactory.createTortoise(pos), 
  ];

  final List<EnemyFactoryFunction> _enemyRoster5 = [
    (pos) => EnemyFactory.createFish(pos), 
    (pos) => EnemyFactory.createJellyfish(pos), 
    (pos) => EnemyFactory.createFishBowl(pos), 
    (pos) => EnemyFactory.createShark(pos), 
    (pos) => EnemyFactory.createTurtle(pos), 
    (pos) => EnemyFactory.createDolphin(pos), 
  ];

  ValueListenable<int>? get currentRoomNotifier => null;

  @override
  void update(double dt) {
    super.update(dt);
    
    _checkTimer += dt;
    if (_checkTimer < _minTimeBeforeClear) return;

    if (!_levelCleared) {
      
      final allEnemies = gameRef.world.children.query<Enemy>();
      
      final realEnemies = allEnemies.where((enemy) => !enemy.isDummy && !enemy.isCharmed);
      final charmedEnemies = allEnemies.where((enemy) => !enemy.isDummy && enemy.isCharmed);
      
      if (realEnemies.isEmpty && !isSpawnningBoss) {
        // limpa inimigos charmeds
        charmedEnemies.forEach((e) => e.removeFromParent());

        _unlockDoors();
        _levelCleared = true;
        if(gameRef.currentRoom == 0 && gameRef.currentLevel==1)return;
        gameRef.saveGame();
      }
    }
  }

  void startRoom(int roomNumber,{continuar = false}) {
    
    _levelCleared = false;
    _checkTimer = 0.0; 

    // TESTES DE OBJETOS
    if (roomNumber == 0) {
      //teste de inimigos
      gameRef.world.add(EnemyFactory.createDummy(Vector2(50, 50)));

      //teste de itens
      //gameRef.world.add(Chest(position: Vector2(0, 0)));
      //gameRef.world.add(Collectible(position: Vector2(0, 0), type: CollectibleType.activeHeal));
      //gameRef.world.add(Collectible(position: Vector2(0,-80), type: CollectibleType.activeArtHp));

      //teste de armadilhas
      //gameRef.world.add(Chest(position: Vector2(0, 0)));
      
    }
    
    if (gameRef.nextRoomReward == CollectibleType.bank){
      _spawnBankRoom(); 
      _spawnDoors(roomNumber);
      return;
    } 

    if (gameRef.nextRoomReward == CollectibleType.shop){
      _generateShopRoom(); 
      _spawnDoors(roomNumber);
      return;
    } 

    if (gameRef.nextRoomReward == CollectibleType.darkShop){
      List<CollectibleType> possibleRewards = gameRef.itensRarosPoolCurrent;

      final CollectibleType lootType = possibleRewards[0];

      gameRef.itensRarosPoolCurrent.remove(lootType);
      gameRef.world.add(Collectible(position: Vector2(0,0), type: lootType, custoVida: true));
      _spawnDoors(roomNumber);
      return;
    } 

    if (gameRef.nextRoomReward == CollectibleType.alquimista){
      _generateAlquimistaRoom(); 
      _spawnDoors(roomNumber);
      return;
    } 
     if (gameRef.nextRoomReward == CollectibleType.desafio) gameRef.challengeHitsNotifier.value = 0;

    if (gameRef.player.magicShield) gameRef.player.activateShield();
    
    // Geração do Mapa (Obstáculos)
    if (gameRef.nextRoomReward != CollectibleType.shop && roomNumber > 0) _generateMap(roomNumber);
    
    // --- LÓGICA DE SPAWN ---
    if (roomNumber == bossRoom) {
      _triggerBossSpawnSequence(); 
    } else {
      _spawnEnemies(roomNumber);
    }
    
    _spawnDoors(roomNumber);
    //print("Sala $roomNumber iniciada...");
  //  gameRef.atualizaDebugMode();
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

      const double margin = 40.0;

      const double spawnWidth = TowerGame.gameWidth - (margin * 2);
      const double spawnHeight = TowerGame.gameHeight - (margin * 2);

      double x = (rng.nextDouble() * spawnWidth) - (spawnWidth / 2);
      double y = (rng.nextDouble() * spawnHeight) - (spawnHeight / 2);

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

    if(gameRef.nextRoomReward == CollectibleType.desafio) targetEnemyCount = 12;

    int enemiesSpawned = 0;
    int attempts = 0; 

    while (enemiesSpawned < targetEnemyCount && attempts < 100) {
      attempts++;

      const double margin = 40.0;

      const double spawnWidth = TowerGame.gameWidth - (margin * 2);
      const double spawnHeight = TowerGame.gameHeight - (margin * 4);

      double x = (rng.nextDouble() * spawnWidth) - (spawnWidth / 2);
      double y = (rng.nextDouble() * spawnHeight) - (spawnHeight / 2);

      final pos = Vector2(x, y);

      // Zona segura no centro para o player nascer
      if (pos.distanceTo(Vector2(0,180)) < 140) {
        continue; 
      }

      // Escolha do Inimigo
      EnemyFactoryFunction selectedFactory;
      
      switch (gameRef.currentLevelNotifier.value){
        case 1:
          selectedFactory = _enemyRoster1[rng.nextInt(_enemyRoster1.length)];
        case 2:
          selectedFactory = _enemyRoster2[rng.nextInt(_enemyRoster2.length)];
        case 3:
          selectedFactory = _enemyRoster3[rng.nextInt(_enemyRoster3.length)];
        case 4:
          selectedFactory = _enemyRoster4[rng.nextInt(_enemyRoster4.length)];
        case 5:
          selectedFactory = _enemyRoster5[rng.nextInt(_enemyRoster5.length)];  
        default:
          selectedFactory = _enemyRoster1[rng.nextInt(_enemyRoster1.length)];
      }
      

      // Criação usando a Factory
      gameRef.world.add(selectedFactory(pos));
      enemiesSpawned++; 
    }
    
    gameRef.atualizaDebugMode();
  }

  void _triggerBossSpawnSequence() {
    AudioManager.stopBgm();
    isSpawnningBoss = true;
    // A posição onde o Boss vai cair/nascer
    final spawnPos = Vector2(0, -150);


    // 1. Opcional: Se você tiver um som de "porta trancando" ou "vento", pode tocar aqui!
    // AudioManager.playSfx('lock.mp3');

    // 2. O Suspense: Um Timer de 1.5 segundos
    add(TimerComponent(
      period: 1.5,
      repeat: false,
      removeOnFinish: true, // Se limpa da memória depois de rodar
      onTick: () {
        
        // 3. O Impacto Visual (Explosões e Tremor)
        createExplosionEffect(gameRef.world, spawnPos, Pallete.vermelho, count: 40);
        gameRef.shakeCamera(intensity: 6.0, duration: 1.0);
        
        // Toca o som de impacto
        AudioManager.playSfx('explosion.mp3');

        // 4. O Spawn: Cria o Boss na arena de acordo com o andar atual
        if (gameRef.currentLevel == 1) {
          gameRef.world.add(EnemyFactory.createRatKing(spawnPos));
        } else if (gameRef.currentLevel == 2) {
          gameRef.world.add(EnemyFactory.createGhostKnight(spawnPos));
        } else if (gameRef.currentLevel == 3) {
          gameRef.world.add(EnemyFactory.createTruQueen(spawnPos));
        } else if (gameRef.currentLevel == 4) {
          gameRef.world.add(EnemyFactory.createBeast(spawnPos));
        } else if (gameRef.currentLevel == 5) {
          gameRef.world.add(EnemyFactory.createMegalodon(spawnPos));
        }
        AudioManager.playBgm('retro_plat.mp3');
        isSpawnningBoss = false;
        // 5. Interface: 
        // Aqui o Boss já foi adicionado. Se você tiver uma classe de HUD para a vida do Boss,
        // o ideal é que a própria classe do Boss (EnemyBoss) avise o HUD no seu método `onLoad`!
      },
    ));
  }

  void reloadDoors(){
    gameRef.world.children.query<Door>().forEach((d) => d.removeFromParent());
    _spawnDoors(gameRef.currentRoom);
    _levelCleared = false;
  }

  void _spawnDoors(int roomNumber) {
    // Porta do Boss ou Próximo Nível
    if (roomNumber == bossRoom - 1) {
      gameRef.world.add(Door(
        position: Vector2(0, -400), 
        rewardType: CollectibleType.boss,
      ));
      return;
    } else if (roomNumber == bossRoom) {
      gameRef.world.add(Door(
        position: Vector2(0, -400), 
        rewardType: CollectibleType.nextlevel,
      ));
      return;
    }

    // Pool de Recompensas
    Set<CollectibleType> possibleRewards = {
      CollectibleType.coin,
      CollectibleType.potion,
      CollectibleType.shield,
      CollectibleType.key,
      CollectibleType.bomba,
      CollectibleType.healthContainer,
      CollectibleType.chest,
    };

    if (roomNumber > 1){
      possibleRewards.add(CollectibleType.rareChest);
      

      if (gameRef.nextRoomReward != CollectibleType.shop){
        possibleRewards.add(CollectibleType.shop);
      }

      if (gameRef.nextRoomReward != CollectibleType.darkShop && !teveDarkShop){
        possibleRewards.add(CollectibleType.darkShop);
      }

      if (gameRef.nextRoomReward != CollectibleType.bank && !teveBanco){
        possibleRewards.add(CollectibleType.bank);
      }

      if (gameRef.nextRoomReward != CollectibleType.desafio && !teveDesafio){
        possibleRewards.add(CollectibleType.desafio);
      }

      if (gameRef.nextRoomReward != CollectibleType.alquimista && !teveAlquimista){
        possibleRewards.add(CollectibleType.alquimista);
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

    //garantir que nao tenha mais de um alquimista por andar
    if(rewardLeft == CollectibleType.alquimista || rewardRight == CollectibleType.alquimista){
      teveAlquimista = true;
    }

    //garantir que nao tenha mais de um desafio por andar
    if(rewardLeft == CollectibleType.desafio || rewardRight == CollectibleType.desafio){
      teveDesafio = true;
    }

    //garantir que nao tenha mais de um darkShop por andar
    if(rewardLeft == CollectibleType.darkShop || rewardRight == CollectibleType.darkShop){
      teveDarkShop = true;
    }

    //limpar as var de sala unica por andar
    if (gameRef.currentRoomNotifier.value == gameRef.bossRoom){
      teveShop = false;
      teveBanco = false;
      teveAlquimista = false;
      teveDesafio = false;
      teveDarkShop = false;
    } 

    bool tranca1 = false;
    bool bloq1 = false;
    bool bites1 = false;

    bool tranca2 = false;
    bool bloq2 = false;
    bool bites2 = false;

    final rng = Random();
    
    if (roomNumber > 1 && rng.nextDouble() < 0.90) {
      bool leftDoorGetsObstacle = rng.nextBool(); 
      int obstacleType = rng.nextInt(3); 
      if (leftDoorGetsObstacle) {
        if (obstacleType == 0) {
          tranca1 = true;
        } else if (obstacleType == 1) {
          bloq1 = true;
        } else {
          bites1 = true;
        }
      } else {
        if (obstacleType == 0) {
          tranca2 = true;
        } else if (obstacleType == 1) {
          bloq2 = true;
        } else {
          bites2 = true;
        }
      }
    }

    gameRef.world.add(Door(
      position: Vector2(-100, -400), 
      rewardType: rewardLeft,
      trancada: tranca1,
      bloqueada: bloq1,
      bites: bites1,
    ));

    gameRef.world.add(Door(
      position: Vector2(100, -400),
      rewardType: rewardRight,
      trancada: tranca2,
      bloqueada: bloq2,
      bites: bites2,
    ));
  }
  void _spawnBankRoom() {
      // 1. Cria o ATM no centro
      gameRef.world.add(BankAtm(position: Vector2(0, 0)));
      
    }
  void _generateShopRoom(){
    gameRef.world.add(Collectible(
        position: Vector2(160, 0),
        type: CollectibleType.potion,
        naoEsgota: true,
        custo : game.player.hasCupon ? 10 : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(80, 0),
        type: CollectibleType.shield,
        naoEsgota: true,
        custo : game.player.hasCupon ? 10 : 15
      ));

      gameRef.world.add(Collectible(
        position: Vector2(0, 0),
        type: CollectibleType.bomba,
        naoEsgota: true,
        custo : game.player.hasCupon ? 10 : 15
      ));

    gameRef.world.add(Collectible(
        position: Vector2(-80, 0),
        type: CollectibleType.key,
        naoEsgota: true,
        custo : game.player.hasCupon ? 10 : 15
      ));

      int preco = game.player.hasCupon ? 20 : 30;
      _generateItemAleatorio(Vector2(-160,0), preco); 
  }

  void _generateAlquimistaRoom(){
      bool isBomba1 = Random().nextBool();
      bool isBomba2 = Random().nextBool();
      bool isBomba3 = Random().nextBool();
      _generatePocoesAleatorias(Vector2(-80,-50), 2,isBomba1); 
      _generatePocoesAleatorias(Vector2(0,-50), 2,isBomba2); 
      _generatePocoesAleatorias(Vector2(80,-50), 2,isBomba3); 
  }

  void _generateZeroRoom(){
    double x1 =-120;
    double y1 =-100;
    double y2 =-0;
    double y3 = 100;
    switch (gameRef.currentLevel){
      
      case 1:
        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y1),
          id: 'permanent_shield_1', 
          type: CollectibleType.shield,
          soulCost: 200,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y2),
          id: 'permanent_health_1', 
          type: CollectibleType.healthContainer,
          soulCost: 500,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y3),
          id: 'permanent_fire_rate_1', 
          type: CollectibleType.fireRate,
          soulCost: 900,
        ));
        break;
      case 2:
        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y1),
          id: 'permanent_health_2', 
          type: CollectibleType.healthContainer,
          soulCost: 800,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y2),
          id: 'permanent_shield_2', 
          type: CollectibleType.shield,
          soulCost: 500,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y3),
          id: 'permanent_damage_2', 
          type: CollectibleType.damage,
          soulCost: 1200,
        ));
        break;
      case 3:
      gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y1),
          id: 'permanent_shield_3', 
          type: CollectibleType.shield,
          soulCost: 700,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y2),
          id: 'permanent_health_3', 
          type: CollectibleType.healthContainer,
          soulCost: 1000,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y3),
          id: 'permanent_crit_3', 
          type: CollectibleType.critChance,
          soulCost: 1500,
        ));
        break;
      case 4:
      gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y1),
          id: 'permanent_shield_4', 
          type: CollectibleType.shield,
          soulCost: 700,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y2),
          id: 'permanent_health_4', 
          type: CollectibleType.healthContainer,
          soulCost: 1000,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y3),
          id: 'permanent_critDmg_4', 
          type: CollectibleType.critDamage,
          soulCost: 1500,
        ));
        break;
      case 5:
      gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y1),
          id: 'permanent_shield_5', 
          type: CollectibleType.shield,
          soulCost: 900,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y2),
          id: 'permanent_health_5', 
          type: CollectibleType.healthContainer,
          soulCost: 1200,
        ));

        gameRef.world.add(UnlockableItem(
          position: Vector2(x1, y3),
          id: 'permanent_fireRate_5', 
          type: CollectibleType.fireRate,
          soulCost: 1800,
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
    
    if (gameRef.nextRoomReward == CollectibleType.bank || gameRef.nextRoomReward == CollectibleType.shop
    || gameRef.nextRoomReward == CollectibleType.alquimista || gameRef.nextRoomReward == CollectibleType.darkShop){
      return;
    } else if (gameRef.nextRoomReward == CollectibleType.chest) {
      _explosaoCriaItem();
      gameRef.world.add(Chest(position: Vector2(0, 0)));
    } else if (gameRef.nextRoomReward == CollectibleType.rareChest) {
      _explosaoCriaItem();
      gameRef.world.add(Chest(position: Vector2(0, 0), isLock: true));
    } else if (gameRef.nextRoomReward == CollectibleType.nextlevel){
      _generateZeroRoom();
    } else if (gameRef.nextRoomReward == CollectibleType.desafio){
      _spawnChallengeReward();
    } else if (gameRef.nextRoomReward == CollectibleType.boss){
      _explosaoCriaItem();
      _generateBossReward();
      ();
    } else {
      if(gameRef.nextRoomReward == CollectibleType.potion || gameRef.nextRoomReward == CollectibleType.shield){
        double itExtras = Random().nextDouble();
        if (itExtras <= 0.2){
          int numExtra = Random().nextInt(2) + 1;
          for(var i=0;i<numExtra;i++){
            gameRef.world.add(Collectible(
              position: Vector2(-80 + (160 * i.toDouble()), 0),
              type: gameRef.nextRoomReward,
            ));
          }
        }
      }
      _explosaoCriaItem();
      gameRef.world.add(Collectible(
        position: Vector2(0, 0),
        type: gameRef.nextRoomReward,
      ));
    }
  }

  void _spawnChallengeReward() {
    int hitsTomados = gameRef.challengeHitsNotifier.value;
    
    // Desliga o modo desafio para a próxima sala
    gameRef.challengeHitsNotifier.value = -1; 

    Vector2 centerOfRoom = Vector2.zero(); // Ou a posição central da sua sala

    if (hitsTomados == 0) {
      List<CollectibleType> possibleRewards = gameRef.itensRarosPoolCurrent;

      final CollectibleType lootType = possibleRewards[0];

      gameRef.itensRarosPoolCurrent.remove(lootType);
      gameRef.world.add(Collectible(position: centerOfRoom, type: lootType));
      
      
    } else if (hitsTomados == 1) {
      List<CollectibleType> possibleRewards = gameRef.itensComunsPoolCurrent;

      final CollectibleType lootType = possibleRewards[0];

      gameRef.itensRarosPoolCurrent.remove(lootType);
      gameRef.world.add(Collectible(position: centerOfRoom, type: lootType));
      
      
    } else if (hitsTomados == 2) {
      gameRef.world.add(Collectible(position: centerOfRoom, type: CollectibleType.potion));
      
      
    } 
  }

  void _generateItemAleatorio(Vector2 pos, [int preco = 0]) {
    final rng = Random();
    final rngPool = rng.nextDouble();
    List<CollectibleType> possibleRewards;

    if (rngPool <= 0.2){
      possibleRewards = retornaItensRaros(gameRef.player);
    }else if(rngPool > 0.2 && rngPool <= 0.6){
      possibleRewards = retornaItensComuns(gameRef.player);
    }else{
      possibleRewards = retornaPocoes();
    }

    final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];
    
    gameRef.world.add(Collectible(position: pos, type: lootType, custo: preco));
  }

  void _generatePocoesAleatorias(Vector2 pos, int preco, bool isBomba ) {
     final rng = Random();

    final List<CollectibleType> possibleRewards = retornaPocoes();

    final CollectibleType lootType = possibleRewards[rng.nextInt(possibleRewards.length)];

    int precoKey = 0;
    int precoBomb = 0;

    if (isBomba){
      precoBomb = preco;
    }else{
      precoKey = preco;
    }
    
    gameRef.world.add(Collectible(position: pos, type: lootType, custoKeys: precoKey, custoBombs: precoBomb));
  }
  
  void _generateBossReward() {
    List<CollectibleType> possibleRewards = gameRef.itensRarosPoolCurrent;

    final CollectibleType lootType = possibleRewards[0];

    gameRef.itensRarosPoolCurrent.remove(lootType);
    gameRef.world.add(Collectible(position: Vector2(0,0), type: lootType));
    //final direc = [Vector2(50, 0), Vector2(-50, 0), Vector2(0, 50), Vector2(0, -50)];
    //for (var dir in direc)
   // {
   //   bool isCoin = Random().nextBool();
    //   gameRef.world.add(Collectible(position: dir, type: isCoin? CollectibleType.coin : CollectibleType.potion));
   // }
    
  }
  
  void _explosaoCriaItem() {
    final directions = [
      Vector2(0, 0), Vector2(20, 0), Vector2(-20, 0),
      Vector2(0, 20), Vector2(0, -20), Vector2(20, 20),
      Vector2(20, -20), Vector2(-20, -20), Vector2(-20, 20),
    ];

    for (var dir in directions) {
      createExplosionEffect(gameRef.world, dir, Pallete.lilas, count: 10);
    }
  }
}