import 'package:towerrogue/game/tower_game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart';

class ArenaBorder extends PositionComponent with HasGameRef<TowerGame> {
  final double wallThickness;
  final double radius;

  late Sprite tile;
  late Sprite tileQ1;
  late Sprite tileQ2;
  late Sprite tileQ3;
  late Sprite tileQ4;

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
    tile = await Sprite.load('sprites/tileset/parede.png');
    tileQ1 = await Sprite.load('sprites/tileset/paredeQuina1.png');
    tileQ2 = await Sprite.load('sprites/tileset/paredeQuina2.png');
    tileQ3 = await Sprite.load('sprites/tileset/paredeQuina3.png');
    tileQ4 = await Sprite.load('sprites/tileset/paredeQuina4.png');
  }

  Color _getLevelColor(int level) {
    switch (level) {
      case 1: return Pallete.marrom;      
      case 2: return Pallete.cinzaEsc; 
      case 3: return Pallete.azulEsc; 
      case 4: return Pallete.verdeEsc; 
      case 5: return Pallete.azulCla; 
      default: return Pallete.azulEsc;
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
    }
  }

  @override
  void render(Canvas canvas) {
    //canvas.drawRRect(_rRect, _borderPaint);
    
    tileQ1.render(
        canvas,
        position: Vector2(0, 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
    tileQ2.render(
        canvas,
        position: Vector2(16*32, 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
    tileQ3.render(
      canvas,
      position: Vector2(0, 28*32), // Posição local (0,0 é o canto superior esquerdo deste componente)
      size: Vector2(32, 32),  
      overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
    );
  tileQ4.render(
      canvas,
      position: Vector2(16*32, 28*32), // Posição local (0,0 é o canto superior esquerdo deste componente)
      size: Vector2(32, 32),  
      overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
    ); 
    for(int i=32; i<16*32; i+=32){
     canvas.drawLine(
        Offset(i.toDouble(), 0),
       Offset(i.toDouble(), 900),
        _borderPaint,
      );
      tile.render(
        canvas,
        position: Vector2(i.toDouble(), 0), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
      tile.render(
        canvas,
        position: Vector2(i.toDouble(), 32*28), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),      
        overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
      );
    }
    for(int i=32; i<32*28; i+=32){
      canvas.drawLine(
        Offset(0,i.toDouble()),
       Offset(16*32,i.toDouble()),
        _borderPaint,
      );
      tile.render(
        canvas,
        position: Vector2(0, i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),  
        overridePaint: paintDeCor,             // Estica a imagem para preencher todo o tamanho do componente
      );
      tile.render(
        canvas,
        position: Vector2(16*32,i.toDouble()), // Posição local (0,0 é o canto superior esquerdo deste componente)
        size: Vector2(32, 32),      
        overridePaint: paintDeCor,         // Estica a imagem para preencher todo o tamanho do componente
      );
    }
  }
}