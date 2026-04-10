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

  late Sprite currTile;
  late Sprite currTileQ;

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

  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1:
        return Pallete.marrom;      
      case 2: 
        return Pallete.cinzaCla; 
      case 3: 
        return Pallete.lilas; 
      case 4: 
        return Pallete.verdeEsc; 
      case 5: 
        return Pallete.azulCla; 
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
      }else if(currLevel == 2 || currLevel == 3){
        currTile = tile2;
        currTileQ = tileQ2;
      }else if(currLevel == 4){
        currTile = tile3;
        currTileQ = tileQ3;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    //canvas.drawRRect(_rRect, _borderPaint);

    // Canto Superior Esquerdo (Sem rotação)
    _desenharQuinaRotacionado(canvas, Vector2(0, 0), 0);

    // Canto Superior Direito (Rotaciona 90 graus = pi / 2)
    _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 0), pi / 2);

    // Canto Inferior Esquerdo (Rotaciona 270 graus = esquerda = pi * 1.5)
    _desenharQuinaRotacionado(canvas, Vector2(0, 28 * 16), pi * 1.5);

    // Canto Inferior Direito (Rotaciona 180 graus = cabeça para baixo = pi)
    _desenharQuinaRotacionado(canvas, Vector2(16 * 16, 28 * 16), pi);

    /*

    tileQ2.render(
        canvas,
        position: Vector2(16*16, 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(16, 16),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
    tileQ3.render(
      canvas,
      position: Vector2(0, 28*16), // Posição local (0,0 é o canto superior esquerdo deste componente)
      size: Vector2(16, 16),  
      overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
    );
    tileQ4.render(
        canvas,
        position: Vector2(16*16, 28*16), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(16, 16),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      ); 

    */
    for(int i=16; i<16*16; i+=16){
     /*canvas.drawLine(
        Offset(i.toDouble(), 0),
       Offset(i.toDouble(), 28*16),
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
        position: Vector2(i.toDouble(), 16*28), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(16, 16),      
        overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
      );
    }
    for(int i=16; i<16*28; i+=16){
    /*  canvas.drawLine(
        Offset(0,i.toDouble()),
       Offset(16*16,i.toDouble()),
        _borderPaint,
      ); */
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

  void _desenharQuinaRotacionado(Canvas canvas, Vector2 posicao, double angulo) {
    canvas.save(); // 1. Isola este desenho do resto do mundo
    
    // 2. Movemos o eixo do canvas exatamente para o CENTRO de onde o tile deve ficar.
    // (Posição X + 8) e (Posição Y + 8)
    canvas.translate(posicao.x + 8, posicao.y + 8); 
    
    // 3. Rotaciona o canvas
    canvas.rotate(angulo);

    // 4. Desenha o tile
    currTileQ.render(
      canvas,
      position: Vector2(0, 0), 
      size: Vector2(16, 16),
      
      // O SEGREDO: Como movemos o canvas para o centro do tile, 
      // precisamos avisar o Flame que o ponto (0,0) é o centro da imagem!
      anchor: Anchor.center, 
      
      overridePaint: paintDeCor,
    );

    canvas.restore(); // 5. Desfaz tudo, deixando o canvas limpo para o próximo tile!
  }

}