import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class Pallete {
  static const Color colorDarkest = Color.fromRGBO(15, 56, 15, 1);
  static const Color colorDark = Color.fromRGBO(48, 98, 48, 1);
  static const Color colorLight = Color.fromRGBO(139, 172, 15, 1);
  static const Color colorLightest = Color.fromRGBO(155, 188, 15, 1);
  static const Color colorBackground = Color.fromRGBO(202, 220, 159, 1);

  static const Color preto = Color(0xFF000000);//0xFF0A0E18
  static const Color azulEsc = Color(0xFF1D2B53);
  static const Color vinho = Color(0xFF7E2553);
  static const Color verdeEsc = Color(0xFF008751);
  static const Color marrom = Color(0xFFAB5236);
  static const Color cinzaEsc = Color(0xFF5F574F);
  static const Color cinzaCla = Color(0xFFC2C3C7);
  static const Color branco = Color(0xFFFFF1E8);
  static const Color vermelho = Color(0xFFFF004D);
  static const Color laranja = Color(0xFFFFA300);
  static const Color amarelo = Color(0xFFFFEC27);
  static const Color verdeCla = Color(0xFF00E436);
  static const Color azulCla = Color(0xFF29ADFF);
  static const Color lilas = Color(0xFF83769C);
  static const Color rosa = Color(0xFFFF77A8);
  static const Color bege = Color(0xFFFFCCAA);

  static final List<Shadow> shadows = [
    const Shadow(color: Colors.black, offset: Offset(1, 0), blurRadius: 0),   // Direita
    const Shadow(color: Colors.black, offset: Offset(-1, 0), blurRadius: 0),  // Esquerda
    const Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 0),   // Baixo
    const Shadow(color: Colors.black, offset: Offset(0, -1), blurRadius: 0),  // Cima
    const Shadow(color: Colors.black, offset: Offset(1, 1), blurRadius: 0),   // Diagonal Inf-Dir
    const Shadow(color: Colors.black, offset: Offset(-1, -1), blurRadius: 0), // Diagonal Sup-Esq
    const Shadow(color: Colors.black, offset: Offset(1, -1), blurRadius: 0),  // Diagonal Sup-Dir
    const Shadow(color: Colors.black, offset: Offset(-1, 1), blurRadius: 0),  // Diagonal Inf-Esq
  ];

  static final List<Shadow> shadowsG = [
    const Shadow(color: Colors.black, offset: Offset(4, 0), blurRadius: 0),   // Direita
    const Shadow(color: Colors.black, offset: Offset(-4, 0), blurRadius: 0),  // Esquerda
    const Shadow(color: Colors.black, offset: Offset(0, 4), blurRadius: 0),   // Baixo
    const Shadow(color: Colors.black, offset: Offset(0, -4), blurRadius: 0),  // Cima
    const Shadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),   // Diagonal Inf-Dir
    const Shadow(color: Colors.black, offset: Offset(-4, -4), blurRadius: 0), // Diagonal Sup-Esq
    const Shadow(color: Colors.black, offset: Offset(4, -4), blurRadius: 0),  // Diagonal Sup-Dir
    const Shadow(color: Colors.black, offset: Offset(-4, 4), blurRadius: 0),  // Diagonal Inf-Esq
  ];

  static final TextPaint textoPadrao = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFFFFF1E8)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,  
    ),
  );

  static final TextPaint textoLaranja = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFFFFA300)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,  
    ),
  );

  static final TextPaint textoVerde = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFF00E436)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
    ),
  );

  static final TextPaint textoVermelho = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFFFF004D)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
    ),
  );

  static final TextPaint textoAmarelo = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFFFFEC27)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
    ),
  );

  static final TextPaint textoCinzaEsc = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFF5F574F)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
    ),
  );

  static final TextPaint textoLilas = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 8,
      foreground: Paint()
        ..color = const Color(0xFF83769C)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
    ),
  );

  static final TextPaint textoDanoCritico = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      foreground: Paint()
        ..color = const Color(0xFFFFEC27)
        ..filterQuality = FilterQuality.none // Exige pixels secos
        ..isAntiAlias = false,
      shadows: shadows,
      fontSize: 10,
    ),
  );

  static final TextPaint textoDescricaoGigante = TextPaint(
    style: TextStyle(
      fontFamily: 'pixelFont',
      fontSize: 32,
      foreground: Paint()
        ..color = const Color(0xFFFFF1E8)
        ..style = PaintingStyle.fill
        ..filterQuality = FilterQuality.none
        ..isAntiAlias = false,
        
      // O SEGREDO: 8 sombras apontando para todas as direções simulando a borda grossa!
      shadows: shadowsG,
    ),
  );

  
}