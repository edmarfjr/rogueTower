import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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
      children: [
        // 2. O SEU JOGO INTEIRO FICA AQUI (NO FUNDO)
        widget.child, 
        
        // 3. A PELÍCULA DO SHADER FICA POR CIMA DE TUDO
        if (_program != null)
          Positioned.fill(
            child: IgnorePointer( 
              // O IgnorePointer é VITAL! Ele impede que o shader bloqueie seus toques na tela
              child: CustomPaint(
                painter: CrtPainter(_program!, _time),
              ),
            ),
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