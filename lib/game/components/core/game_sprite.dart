import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class GameSprite extends SpriteComponent{
  final String imagePath;
  Color _color;

  GameSprite({
    required this.imagePath,
    required Color color, // Agora exigimos uma cor no construtor
    required Vector2 super.size,
    super.position,
    super.scale,
    super.anchor = Anchor.center,
  }) : _color = color;

  @override
  Future<void> onLoad() async {
    // Carrega a sprite branca
    sprite = await Sprite.load(imagePath);
    
    // Aplica a cor inicial
    _updateColorFilter();
  }

  // Permite mudar a cor dinamicamente (ex: poção mudando de tipo)
  void changeColor(Color newColor) {
    _color = newColor;
    if (isLoaded) {
      _updateColorFilter();
    }
  }

  // --- A MÁGICA ESTÁ AQUI ---
  void _updateColorFilter() {
    // Usamos BlendMode.srcIn. 
    // Isso pega a forma da sprite (tudo que não é transparente) 
    // e preenche com a cor escolhida.
    //paint.colorFilter = ColorFilter.mode(_color, BlendMode.srcIn);
    paint.colorFilter = ColorFilter.mode(_color, BlendMode.modulate);
    
    // Nota: O Flame/Flutter lida com o alfa (transparência) automaticamente.
    // Se a sprite branca tiver 50% de opacidade num pixel, a cor aplicada 
    // também terá 50% de opacidade ali.
  }
}