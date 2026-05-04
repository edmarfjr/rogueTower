import 'dart:math';

import 'package:towerrogue/game/tower_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart';

class ArenaBorder extends PositionComponent with HasGameRef<TowerGame> {
  final double wallThickness;
  final double radius;

  late Sprite tile;
  late Sprite tileQ;

  late Sprite tile2;
  late Sprite tileQ2;

  late Sprite tile3;
  late Sprite tileQ3;

  late Sprite tile4;
  late Sprite tile42;
  late Sprite tileQ4;
  late Sprite tileQ42;

  late Sprite tile5;
  late Sprite tile52;
  late Sprite tileQ5;
  late Sprite tileQ52;

  late Sprite tile6;
  late Sprite tileQ6;

  late Sprite currTile;
  late Sprite currTile2;
  late Sprite currTileQ;
  late Sprite currTileQ2;

  final Paint _borderPaint = Paint()..style = PaintingStyle.stroke
                                    ..strokeWidth = 1.0
                                    ..color = Pallete.cinzaCla.withAlpha(50);
  final paintDeCor = Paint();

  int _lastLevel = -1;

  ArenaBorder({
    required Vector2 size,
    this.wallThickness = 10.0,
    this.radius = 220.0,
  }) : super(
          size: size,
          anchor: Anchor.center,
          position: Vector2.zero(), 
          priority: -10000,
        ) {
    // Configura a espessura da linha
    //_borderPaint.strokeWidth = 1;

    // Pré-calcula a matemática geométrica na hora que a arena é criada
   /* _rect = Rect.fromCenter(
      center: Offset(size.x / 2, size.y / 2),
      width: size.x,
      height: size.y,
    );
    
    _rRect = RRect.fromRectAndRadius(_rect, Radius.circular(radius));
    */
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // 2. Carrega a imagem (Lembre-se: não precisa escrever 'assets/images/')
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
      case 1:
        return Pallete.marrom;      
      case 2: 
        return Pallete.verdeEsc; 
      case 3: 
        return Pallete.cinzaCla; 
      case 4: 
        return Pallete.lilas; 
      case 5: 
        return Pallete.azulCla; 
      case 6: 
        return Pallete.marrom; 
      case 7: 
        return Pallete.azulCla; 
      case 8: 
        return Pallete.rosa; 
      default: 
        return Pallete.azulEsc;
    }
  }  

  @override
  void update(double dt) {
    super.update(dt);
    
    // 3. ATUALIZAÇÃO CONDICIONAL: 
    // Muda a cor da tinta apenas se o nível tiver mudado, sem recriar o Paint()
    final int currLevel = gameRef.currentLevelNotifier.value;
    if (currLevel != _lastLevel) {
      _lastLevel = currLevel;
      paintDeCor.colorFilter = ColorFilter.mode(_getLevelColor(currLevel), BlendMode.modulate);
      if(currLevel == 1 || currLevel == 5){
        currTile = tile;
        currTileQ = tileQ;
      }else if(currLevel == 4 || currLevel == 3){
        currTile = tile2;
        currTileQ = tileQ2;
      }else if(currLevel == 2){
        currTile = tile3;
        currTileQ = tileQ3;
      }else if(currLevel == 6){
        currTile = tile4;
        currTileQ = tileQ4;
        currTile2 = tile42;
        currTileQ2 = tileQ42;
      }else if(currLevel == 7){
        currTile = tile5;
        currTileQ = tileQ5;
        currTile2 = tile52;
        currTileQ2 = tileQ52;
      }
      else if(currLevel == 8){
        currTile = tile6;
        currTileQ = tileQ6;
      }
      
    }
  }

  @override
  void render(Canvas canvas) {
    //canvas.drawRRect(_rRect, _borderPaint);
    if(gameRef.currentLevelNotifier.value != 6 && gameRef.currentLevelNotifier.value != 7){
      _desenharQuinaRotacionado(canvas, Vector2(0, 0), 0);
      _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 0), pi / 2);
      _desenharQuinaRotacionado(canvas, Vector2(0, 32 * 16), pi * 1.5);
      _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 32 * 16), pi);
    }else{
      _desenharQuinaRotacionado(canvas, Vector2(0, 0), 0);
      _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 0),0,flipX: -1);
      _desenharQuinaRotacionado(canvas, Vector2(0, 32 * 16), 0,quina2: true);
      _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 32 * 16),0,flipX: -1,quina2:true);
    }
    
    for(int i=16; i<16*16; i+=16){
     /*canvas.drawLine(
        Offset(i.toDouble(), 0),
       Offset(i.toDouble(), 32*16),
        _borderPaint,
      );*/
      currTile.render(
        canvas,
        position: Vector2(i.toDouble(), 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(16, 16),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
      currTile.render(
        canvas,
        position: Vector2(i.toDouble(), 16*32), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(16, 16),      
        overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
      );
    }
    for(int i=16; i<16*32; i+=16){
    /*  canvas.drawLine(
        Offset(0,i.toDouble()),
       Offset(16*16,i.toDouble()),
        _borderPaint,
      ); */
      if(gameRef.currentLevelNotifier.value == 6 || gameRef.currentLevelNotifier.value == 7){
        currTile2.render(
          canvas,
          position: Vector2(0, i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
          size: Vector2(16, 16),  
          overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
        );
        if(gameRef.currentLevelNotifier.value == 7){
          _desenharParedeDireitaFlipada(canvas, Vector2(17*16, i.toDouble()));
        }else{
          currTile2.render(
            canvas,
            position: Vector2(16*16,i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
            size: Vector2(16, 16),      
            overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
          );
        }
        
      }else{
        currTile.render(
          canvas,
          position: Vector2(0, i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
          size: Vector2(16, 16),  
          overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
        );
        currTile.render(
          canvas,
          position: Vector2(16*16,i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
          size: Vector2(16, 16),      
          overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
        );
      }
      
    }
  }

  void _desenharParedeDireitaFlipada(Canvas canvas, Vector2 posicao) {
    canvas.save(); 
    canvas.translate(posicao.x, posicao.y);
    canvas.scale(-1, 1); // Inverte horizontalmente
    currTile2.render(
      canvas,
      position: Vector2(0, 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
      size: Vector2(16, 16),  
      overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
    );
    canvas.restore();
  }

  void _desenharQuinaRotacionado(Canvas canvas, Vector2 posicao, double angulo, {double flipX = 1, double flipY = 1,bool quina2 = false}) {
    canvas.save(); 
    canvas.translate(posicao.x + 8, posicao.y + 8); 
    
    canvas.rotate(angulo);
    canvas.scale(flipX, flipY); 
    if(quina2){
      currTileQ2.render(
      canvas,
      position: Vector2(0, 0), 
      size: Vector2(16, 16),
      anchor: Anchor.center, 
      
      overridePaint: paintDeCor,
    );
    }else{
      currTileQ.render(
      canvas,
      position: Vector2(0, 0), 
      size: Vector2(16, 16),
      anchor: Anchor.center, 
      
      overridePaint: paintDeCor,
    );
    }
    

    canvas.restore();
  }

}