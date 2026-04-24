import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:towerrogue/game/components/core/game_progress.dart';

// 1. Criamos um StatefulWidget para controlar a passagem do tempo
class CrtOverlayWidget extends StatefulWidget {
  final Widget child; // O jogo e os menus vão entrar aqui!
  
  const CrtOverlayWidget({Key? key, required this.child}) : super(key: key);

  @override
  State<CrtOverlayWidget> createState() => _CrtOverlayWidgetState();
}

class _CrtOverlayWidgetState extends State<CrtOverlayWidget> with SingleTickerProviderStateMixin {
  ui.FragmentProgram? _program;
  late Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _loadShader();
    
    // O Ticker é o equivalente do Flutter para o método "update(dt)" do Flame
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMicroseconds / 1000000.0; // Converte para segundos
      });
    });
    _ticker.start();
  }

  void _loadShader() async {
    _program = await ui.FragmentProgram.fromAsset('shaders/crt_overlay.frag');
    setState(() {}); // Força a tela a redesenhar quando o shader carregar
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children:[
        // 1. AUMENTA O BRILHO E CONTRASTE DO JOGO (Fósforo CRT)
        ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.3,  0.0,  0.0,  0.0,  15.0, // Canal Vermelho: 30% mais contraste, +15 de brilho puro
            0.0,  1.3,  0.0,  0.0,  15.0, // Canal Verde:   30% mais contraste, +15 de brilho puro
            0.0,  0.0,  1.3,  0.0,  15.0, // Canal Azul:    30% mais contraste, +15 de brilho puro
            0.0,  0.0,  0.0,  1.0,   0.0, // Canal Alpha (Transparência): Intacto
          ]),
          // 2. O NOSSO FILTRO DO FUNDO QUASE PRETO (Que fizemos antes)
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0xFF0A0E18), 
              BlendMode.lighten, 
            ),
            child: widget.child, // O jogo roda aqui!
          ),
        ),
        
        // 3. A PELÍCULA CRT (Que escuta o botão de liga/desliga)
        ValueListenableBuilder<bool>(
          valueListenable: GameProgress.crtEnabled,
          builder: (context, crtOn, child) {
            if (crtOn && _program != null) {
              return Positioned.fill(
                child: IgnorePointer( 
                  child: CustomPaint(
                    painter: CrtPainter(_program!, _time),
                  ),
                ),
              );
            }
            return const SizedBox.shrink(); 
          },
        ),
      ],
    );
  }
}

// 4. O Pintor que desenha o GLSL na tela
class CrtPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;

  CrtPainter(this.program, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    var shader = program.fragmentShader();
    
    // Pegamos a resolução física real da tela do dispositivo
    final physicalSize = ui.PlatformDispatcher.instance.views.first.physicalSize;
    
    shader.setFloat(0, physicalSize.width);
    shader.setFloat(1, physicalSize.height);
    shader.setFloat(2, time);

    shader.setFloat(3, 0.2); // Densidade (Menor = Mais espaçado)
    shader.setFloat(4, 0.65); // Grossura (Maior = Mais fina)
    shader.setFloat(5, 0.3);     // Alpha (Maior = Mais Escura)

    var paint = Paint()..shader = shader;
    
    // Pinta a tela inteira com a película
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CrtPainter oldDelegate) {
    // Redesenha a cada frame (já que o tempo está mudando)
    return oldDelegate.time != time;
  }
}