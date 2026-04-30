//import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flutter/material.dart';
//import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
//import 'package:towerrogue/game/components/core/game_icon.dart';
import 'package:towerrogue/game/components/core/game_sprite.dart';
//import 'package:towerrogue/game/components/core/interact_button.dart';
import '../../tower_game.dart';
import '../core/pallete.dart';
import '../effects/floating_text.dart';
//import '../core/audio_manager.dart';

class SecretDoor extends PositionComponent with HasGameRef<TowerGame> {
  bool isLocked;
  bool isExit; 
  bool requiresBomb; 
  bool temInimigos = true;
  bool _isEntering = false;

  GameSprite? _doorIcon;

  bool botaoAtivo = false;
  final double raioBotao = 16.0; // Mesma distância das suas portas normais

  SecretDoor({
    required Vector2 position,
    this.isLocked = true,
    this.isExit = false,
    this.requiresBomb = false,
  }) : super(position: position, size: Vector2.all(16), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    if (isExit) isLocked = false;
    if(requiresBomb) {
      _updateDoorIcon('sprites/tileset/salaSecretaBomba.png');
    } else if(isExit) {
      _updateDoorIcon('sprites/tileset/salaSecretaSaida.png');
    }else {
      _updateDoorIcon('sprites/tileset/salaSecretaChave.png');
    }
    if(isExit) temInimigos = false;
    priority = -1000;
  }

  void _updateDoorIcon(String image) {
    if (_doorIcon != null) {
      _doorIcon!.removeFromParent();
    }

    Color color = _getLevelColor(gameRef.currentLevelNotifier.value);

    _doorIcon = GameSprite(
      imagePath: image,
      size: size,
      color: color, 
      position: size / 2
    );
    
    add(_doorIcon!);
  }

  @override
  void update(double dt) {
    super.update(dt); 

    if (_isEntering) {
      if (gameRef.camera.viewfinder.zoom < 3.0) {
        gameRef.camera.viewfinder.zoom += dt * 2.0; 
      }
    }

    //if(temInimigos)return;

    // Calcula a distância para o jogador
    double dist = position.distanceTo(gameRef.player.position);
    
    // Mostra o botão se estiver perto
    if (dist <= raioBotao && !botaoAtivo) {
      _showButton();
      botaoAtivo = true;
    } 
    // Esconde se afastar
    else if (dist > raioBotao && botaoAtivo) {
      _hideButton();
      botaoAtivo = false;
    }
  }

  void _showButton() {
    if(gameRef.canInteractNotifier.value) return;
    gameRef.onInteractAction = () {
        _hideButton();
        botaoAtivo = false;
        // --- 1. SE FOR A PORTA DE SAÍDA ---
        if (isExit) {
          _isEntering = true; 
          
          // LIBERTA A CÂMERA: Expande os limites para ela conseguir ir até a porta
          gameRef.camera.setBounds(
            Rectangle.fromCenter(center: Vector2.zero(), size: Vector2(4000, 4000)),
            considerViewport: false,
          );
            
          _hideButton();
          botaoAtivo = false;

          gameRef.transitionEffect.startTransition(() {
            
          _isEntering = false; 

          // RESET DO ZOOM E POSIÇÃO
          gameRef.camera.viewfinder.zoom = 1.0; 
          gameRef.camera.viewfinder.position = Vector2.zero(); 
            
            // DEVOLVE A TRAVA ORIGINAL DA CÂMERA
            gameRef.camera.setBounds(
              Rectangle.fromCenter(center: Vector2.zero(), size: Vector2(120, 100)),
              considerViewport: false,
            );
            gameRef.sairDaSalaSecreta();
            return;
          });
          
        }

        // --- 2. SE ESTIVER TRANCADA ---
        if (isLocked) {
          if (!requiresBomb) {
            if (gameRef.keysNotifier.value > 0) {
              gameRef.keysNotifier.value--;
              abrirPorta();
            } else {
              gameRef.world.add(FloatingText(
                text: 'Sem Chaves!', // ou 'noKeys'.tr()
                position: position.clone(), 
                color: Pallete.vermelho,
                fontSize: 12,
              ));
            }
          }
        } 

        // --- 3. SE ESTIVER DESTRANCADA (ENTRAR!) ---
        else {
          _isEntering = true; 
          
          // LIBERTA A CÂMERA: Expande os limites para ela conseguir ir até a porta
          gameRef.camera.setBounds(
            Rectangle.fromLTWH(-2000, -2000, 4000, 4000),
            considerViewport: false,
          );
            
          _hideButton();
          botaoAtivo = false;

          gameRef.transitionEffect.startTransition(() {
            
          _isEntering = false; 

          // RESET DO ZOOM E POSIÇÃO
          gameRef.camera.viewfinder.zoom = 1.0; 
          gameRef.camera.viewfinder.position = Vector2.zero(); 
            
            // DEVOLVE A TRAVA ORIGINAL DA CÂMERA
            gameRef.camera.setBounds(
              Rectangle.fromLTWH(-60, -60, 120, 130),
              considerViewport: false,
            );
            gameRef.entrarNaSalaSecreta();
          });
          
        }
      };

    gameRef.canInteractNotifier.value = true;
  }

  void _hideButton() {
    gameRef.canInteractNotifier.value = false;
    gameRef.onInteractAction = null;
  }

  void abrirPorta() {
    isLocked = false;
    //AudioManager.playSfx('secret_found.mp3'); 
    if (requiresBomb){
      _updateDoorIcon('sprites/tileset/salaSecretaEntrada.png');
    }else{
      _updateDoorIcon('sprites/tileset/salaSecretaEntradaChave.png');
    }
    
    gameRef.world.add(FloatingText(
      text: "Aberta!", 
      position: position.clone(), 
      color: Pallete.verdeCla,
      fontSize: 12,
    ));
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
      default: return Pallete.azulEsc;
    }
  } 

  @override
  void render(Canvas canvas) {
    super.render(canvas);
   /* // 1. O FUNDO DA PORTA (A Parede Falsa)
    final bgPaint = Paint()..color = isExit ? Pallete.azulCla : Pallete.cinzaEsc;
    canvas.drawRect(size.toRect(), bgPaint);

    // Borda para destacar a porta do resto da parede
    final borderPaint = Paint()
      ..color = Pallete.preto
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRect(size.toRect(), borderPaint);

    // 2. SE A PORTA ESTIVER ABERTA OU FOR SAÍDA
    if (!isLocked || isExit) {
      // Desenha um "buraco negro" no meio para indicar passagem
      final openHolePaint = Paint()..color = Pallete.azulEsc;
      final openRect = Rect.fromCenter(
          center: Offset(size.x / 2, size.y / 2 + 5),
          width: size.x * 0.6,
          height: size.y * 0.7);
      
      // Um arco no topo para parecer uma entrada de caverna/porta
      canvas.drawRRect(
          RRect.fromRectAndRadius(openRect, const Radius.circular(10)),
          openHolePaint);
      return; // Acaba o render aqui se estiver aberta
    }

    // 3. SE A PORTA ESTIVER TRANCADA
    if (requiresBomb) {
      // --- DESENHA A RACHADURA (Ziguezague) ---
      final crackPath = Path();
      // Começa no topo, um pouco deslocado
      crackPath.moveTo(size.x * 0.4, 5); 
      // Vai descendo e quebrando a linha
      crackPath.lineTo(size.x * 0.6, size.y * 0.3);
      crackPath.lineTo(size.x * 0.35, size.y * 0.5);
      crackPath.lineTo(size.x * 0.55, size.y * 0.75);
      crackPath.lineTo(size.x * 0.45, size.y - 5);

      final crackPaint = Paint()
        ..color = Pallete.azulEsc
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeJoin = StrokeJoin.round; // Deixa as quinas mais suaves

      canvas.drawPath(crackPath, crackPaint);
      
    } else {
      // --- DESENHA O ALÇAPÃO (Para Chaves) ---
      final centerX = size.x / 2;
      final centerY = size.y / 2;

      // Fundo de madeira do alçapão
      final woodPaint = Paint()..color = Pallete.marrom; 
      final trapdoorRect = Rect.fromCenter(
          center: Offset(centerX, centerY), 
          width: size.x * 0.7, 
          height: size.y * 0.7
      );
      canvas.drawRect(trapdoorRect, woodPaint);

      // Borda de ferro e linhas das tábuas de madeira
      final ironPaint = Paint()
        ..color = Pallete.preto
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
        
      canvas.drawRect(trapdoorRect, ironPaint); // Borda
      
      // Tábuas verticais
      canvas.drawLine(Offset(centerX - size.x * 0.15, centerY - size.y * 0.35), 
                      Offset(centerX - size.x * 0.15, centerY + size.y * 0.35), ironPaint);
      canvas.drawLine(Offset(centerX + size.x * 0.15, centerY - size.y * 0.35), 
                      Offset(centerX + size.x * 0.15, centerY + size.y * 0.35), ironPaint);

      // --- CADEADO DOURADO NO CENTRO ---
      final padlockBody = Paint()..color = Pallete.amarelo;
      final padlockShackle = Paint()
        ..color = Pallete.cinzaCla
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Haste do cadeado (arco prateado)
      canvas.drawArc(
          Rect.fromCircle(center: Offset(centerX, centerY - 2), radius: 5), 
          3.14, 3.14, false, padlockShackle);
      
      // Corpo do cadeado (retângulo dourado arredondado)
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(centerX, centerY + 5), width: 14, height: 10), 
              const Radius.circular(2)
          ), 
          padlockBody
      );
      
      // Furo da chave no cadeado (pontinho preto)
      final holePaint = Paint()..color = Pallete.preto;
      canvas.drawCircle(Offset(centerX, centerY + 5), 1.5, holePaint);
    }
    */
  }

  @override
  void onRemove() {
    // Garantia de segurança: Se a porta for destruída, limpa o botão do HUD
    _hideButton();
    super.onRemove();
  }
}
