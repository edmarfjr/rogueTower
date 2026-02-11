import 'dart:ui';
import 'package:flame/components.dart';
import '../../tower_game.dart';

enum TransitionState { idle, fadingIn, fadingOut }

class ScreenTransition extends PositionComponent with HasGameRef<TowerGame> {
  
  // Configurações
  final Color color;
  final double duration;
  
  // Controle interno
  TransitionState _state = TransitionState.idle;
  double _timer = 0;
  VoidCallback? _onFullBlack; // Ação para executar quando a tela estiver preta
  late Paint _paint; // Cache da tinta para performance

  ScreenTransition({
    this.color = const Color(0xFF000000), // Preto
    this.duration = 0.5, 
  }) : super(priority: 1000); // Prioridade ALTA para ficar na frente de tudo

  @override
  Future<void> onLoad() async {
    // Pega o tamanho da tela virtual (viewport)
    size = gameRef.camera.viewport.virtualSize;
    position = Vector2.zero();
    
    // Inicializa o pincel totalmente transparente
    _paint = Paint()..color = color.withOpacity(0.0);
  }
  
  // Se o tamanho da tela mudar (redimensionar janela), atualiza o tamanho da transição
  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = gameRef.camera.viewport.virtualSize;
  }

  // Método público para iniciar
  void startTransition(VoidCallback onFullBlack) {
    if (_state != TransitionState.idle) return; 
    
    _onFullBlack = onFullBlack;
    _state = TransitionState.fadingIn;
    _timer = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (_state == TransitionState.idle) return;

    double opacity = 0.0;

    // --- FASE 1: ESCURECENDO (Fade In) ---
    if (_state == TransitionState.fadingIn) {
      _timer += dt;
      opacity = (_timer / duration).clamp(0.0, 1.0);
      
      if (_timer >= duration) {
        _state = TransitionState.fadingOut; // Troca para clarear
        _timer = 0; 
        
        // EXECUTA A LÓGICA (Trocar fase)
        _onFullBlack?.call(); 
        _onFullBlack = null;
        
        opacity = 1.0; // Garante preto total nesse frame
      }
    } 
    
    // --- FASE 2: CLAREANDO (Fade Out) ---
    else if (_state == TransitionState.fadingOut) {
      _timer += dt;
      opacity = 1.0 - (_timer / duration).clamp(0.0, 1.0);
      
      if (_timer >= duration) {
        _state = TransitionState.idle; // Acabou
        opacity = 0.0;
      }
    }
    
    // Atualiza a cor do pincel
    _paint.color = color.withOpacity(opacity);
  }

  @override
  void render(Canvas canvas) {
    if (_state == TransitionState.idle) return;

    // Desenha o retângulo usando o pincel atualizado
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      _paint,
    );
  }
}