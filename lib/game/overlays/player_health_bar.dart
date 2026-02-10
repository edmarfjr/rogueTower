import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart'; // Importe os ícones
import '../tower_game.dart';
import '../components/core/pallete.dart';

class PlayerHealthBar extends PositionComponent with HasGameRef<TowerGame> {
  
  // Cache para não recriar text/paints a todo frame se não mudar
  int _lastHp = -1;
  int _lastMaxHp = -1;

  PlayerHealthBar() : super(position: Vector2(10, 10), anchor: Anchor.topLeft);

  @override
  void update(double dt) {
    super.update(dt);
    
    final player = gameRef.player;
    // Otimização: Só redesenha se a vida mudou
    if (player.healthNotifier.value != _lastHp || player.maxHealth != _lastMaxHp) {
      _lastHp = player.healthNotifier.value;
      _lastMaxHp = player.maxHealth;
      _redrawHearts();
    }
  }

  void _redrawHearts() {
    // Limpa os corações antigos
    removeAll(children);

    final int currentHp = _lastHp;
    final int maxHp = _lastMaxHp;

    // Tamanho visual do ícone
    const double iconSize = 24.0;
    const double spacing = 4.0;

    // Quantos corações desenhar no total (Ex: 6 HP = 3 Corações)
    // .ceil() garante que se você tiver 5 HP max, desenha 3 corações (2.5 arredondado para 3)
    final int totalHearts = (maxHp / 2).ceil();

    for (int i = 0; i < totalHearts; i++) {
      IconData icon;
      Color color = Pallete.vermelho;

      // Valor de HP que este coração específico representa
      // Ex: i=0 (Primeiro coração) representa HP 1 e 2
      //     i=1 (Segundo coração) representa HP 3 e 4
      int heartValueTimesTwo = (i + 1) * 2; 

      if (currentHp >= heartValueTimesTwo) {
        // [CHEIO] A vida atual cobre totalmente este coração
        icon = MdiIcons.heart; 
      } else if (currentHp >= heartValueTimesTwo - 1) {
        // [METADE] A vida atual cobre apenas 1 ponto deste coração
        icon = MdiIcons.heartHalfFull; 
      } else {
        // [VAZIO] A vida não chega neste coração
        icon = MdiIcons.heartOutline; 
        color = Pallete.cinzaCla; // Opcional: deixar o vazio mais escuro
      }

      // Adiciona o componente visual
      add(TextComponent(
        text: String.fromCharCode(icon.codePoint),
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: iconSize,
            fontFamily: icon.fontFamily,
            package: icon.fontPackage, // Necessário para MdiIcons
            color: color,
          ),
        ),
        position: Vector2(i * (iconSize + spacing), 0),
      ));
    }
  }
}