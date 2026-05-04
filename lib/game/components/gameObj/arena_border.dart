import 'dart:math';
import 'dart:ui'; // Necessário para o PictureRecorder

import 'package:towerrogue/game/tower_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart';

class ArenaBorder extends PositionComponent with HasGameRef<TowerGame> {
  final double wallThickness;
  final double radius;

  // --- Dimensões da Arena ---
  static const double tileSize = 16.0;
  static const double gridWidth = 16.0;
  static const double gridHeight = 32.0;
  static const double arenaWidth = gridWidth * tileSize;
  static const double arenaHeight = gridHeight * tileSize;

  // --- Sprites ---
  late Sprite tile, tileQ;
  late Sprite tile2, tileQ2;
  late Sprite tile3, tileQ3;
  late Sprite tile4, tile42, tileQ4, tileQ42;
  late Sprite tile5, tile52, tileQ5, tileQ52;
  late Sprite tile6, tileQ6;

  late Sprite currTile, currTileQ;
  Sprite? currTile2, currTileQ2; // Transformados em nullables pois nem todo nível usa

  final Paint paintDeCor = Paint();
  int _lastLevel = -1;

  // O SEGREDO DA PERFORMANCE: A "Foto" em cache da arena inteira
  Picture? _cachedBorder;

  ArenaBorder({
    required Vector2 size,
    this.wallThickness = 10.0,
    this.radius = 220.0,
  }) : super(
          size: size,
          anchor: Anchor.center,
          position: Vector2.zero(),
          priority: -10000,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    tile = await Sprite.load('sprites/tileset/1parede.png');
    tileQ = await Sprite.load('sprites/tileset/1paredeQuina.png');
    tile2 = await Sprite.load('sprites/tileset/2parede.png');
    tileQ2 = await Sprite.load('sprites/tileset/2paredeQuina.png');
    tile3 = await Sprite.load('sprites/tileset/3parede.png');
    tileQ3 = await Sprite.load('sprites/tileset/3paredeQuina.png');
    tile4 = await Sprite.load('sprites/tileset/4parede.png');
    tile42 = await Sprite.load('sprites/tileset/4parede2.png');
    tileQ4 = await Sprite.load('sprites/tileset/4paredeQuina.png');
    tileQ42 = await Sprite.load('sprites/tileset/4paredeQuina2.png');
    tile5 = await Sprite.load('sprites/tileset/5parede.png');
    tile52 = await Sprite.load('sprites/tileset/5parede2.png');
    tileQ5 = await Sprite.load('sprites/tileset/5paredeQuina.png');
    tileQ52 = await Sprite.load('sprites/tileset/5paredeQuina2.png');
    tile6 = await Sprite.load('sprites/tileset/6parede.png');
    tileQ6 = await Sprite.load('sprites/tileset/6paredeQuina.png');
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Pallete.marrom;
      case 2: return Pallete.verdeEsc;
      case 3: return Pallete.cinzaCla;
      case 4: return Pallete.lilas;
      case 5: return Pallete.azulCla;
      case 6: return Pallete.marrom;
      case 7: return Pallete.azulCla;
      case 8: return Pallete.rosa;
      default: return Pallete.azulEsc;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final int currLevel = gameRef.currentLevelNotifier.value;
    
    // Se o nível mudou, configuramos os tiles e "batemos a foto" da nova arena!
    if (currLevel != _lastLevel) {
      _lastLevel = currLevel;
      _updateLevelConfig(currLevel);
      _buildCachedBorder(); 
    }
  }

  // --- 1. SEPARAÇÃO DE LÓGICA: Configura as variáveis do nível ---
  void _updateLevelConfig(int level) {
    paintDeCor.colorFilter = ColorFilter.mode(_getLevelColor(level), BlendMode.modulate);
    
    // Reseta as secundárias por padrão
    currTile2 = null;
    currTileQ2 = null;

    if (level == 1 || level == 5) {
      currTile = tile; currTileQ = tileQ;
    } else if (level == 3 || level == 4) {
      currTile = tile2; currTileQ = tileQ2;
    } else if (level == 2) {
      currTile = tile3; currTileQ = tileQ3;
    } else if (level == 6) {
      currTile = tile4; currTileQ = tileQ4;
      currTile2 = tile42; currTileQ2 = tileQ42;
    } else if (level == 7) {
      currTile = tile5; currTileQ = tileQ5;
      currTile2 = tile52; currTileQ2 = tileQ52;
    } else if (level == 8) {
      currTile = tile6; currTileQ = tileQ6;
    } else {
      currTile = tile; currTileQ = tileQ; // Fallback de segurança
    }
  }

  // --- 2. O SEGREDO DA PERFORMANCE: Desenha tudo em um Canvas temporário ---
  void _buildCachedBorder() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);

    final bool usesSecondaryTiles = (_lastLevel == 6 || _lastLevel == 7);

    // 1. Quinas
    if (!usesSecondaryTiles) {
      _desenharQuina(canvas, Vector2(0, 0), 0);
      _desenharQuina(canvas, Vector2(arenaWidth, 0), pi / 2);
      _desenharQuina(canvas, Vector2(0, arenaHeight), pi * 1.5);
      _desenharQuina(canvas, Vector2(arenaWidth, arenaHeight), pi);
    } else {
      _desenharQuina(canvas, Vector2(0, 0), 0);
      _desenharQuina(canvas, Vector2(arenaWidth, 0), 0, flipX: -1);
      _desenharQuina(canvas, Vector2(0, arenaHeight), 0, quina2: true);
      _desenharQuina(canvas, Vector2(arenaWidth, arenaHeight), 0, flipX: -1, quina2: true);
    }
    
    // 2. Paredes Horizontais (Cima e Baixo)
    for (double i = tileSize; i < arenaWidth; i += tileSize) {
      _renderSprite(canvas, currTile, Vector2(i, 0));
      _renderSprite(canvas, currTile, Vector2(i, arenaHeight));
    }

    // 3. Paredes Verticais (Esquerda e Direita)
    for (double i = tileSize; i < arenaHeight; i += tileSize) {
      if (usesSecondaryTiles && currTile2 != null) {
        _renderSprite(canvas, currTile2!, Vector2(0, i));
        
        if (_lastLevel == 7) {
          _desenharParedeDireitaFlipada(canvas, Vector2(arenaWidth + tileSize, i));
        } else {
          _renderSprite(canvas, currTile2!, Vector2(arenaWidth, i));
        }
      } else {
        _renderSprite(canvas, currTile, Vector2(0, i));
        _renderSprite(canvas, currTile, Vector2(arenaWidth, i));
      }
    }

    // "Salva a foto" do Canvas
    _cachedBorder = recorder.endRecording();
  }

  // Helper para não repetir o código de render no laço
  void _renderSprite(Canvas canvas, Sprite spriteToRender, Vector2 position) {
    spriteToRender.render(
      canvas,
      position: position,
      size: Vector2(tileSize, tileSize),
      overridePaint: paintDeCor,
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Agora o nosso render só tem UMA linha! Extremamente leve.
    if (_cachedBorder != null) {
      canvas.drawPicture(_cachedBorder!);
    }
  }

  // --- Helpers de Desenho Transformado ---
  void _desenharParedeDireitaFlipada(Canvas canvas, Vector2 posicao) {
    if (currTile2 == null) return;
    canvas.save(); 
    canvas.translate(posicao.x, posicao.y);
    canvas.scale(-1, 1); 
    _renderSprite(canvas, currTile2!, Vector2.zero());
    canvas.restore();
  }

  void _desenharQuina(Canvas canvas, Vector2 posicao, double angulo, {double flipX = 1, double flipY = 1, bool quina2 = false}) {
    canvas.save(); 
    canvas.translate(posicao.x + (tileSize / 2), posicao.y + (tileSize / 2)); 
    canvas.rotate(angulo);
    canvas.scale(flipX, flipY); 
    
    final sprite = (quina2 && currTileQ2 != null) ? currTileQ2! : currTileQ;
    
    sprite.render(
      canvas,
      position: Vector2.zero(),
      size: Vector2(tileSize, tileSize),
      anchor: Anchor.center,
      overridePaint: paintDeCor,
    );
    canvas.restore();
  }
}