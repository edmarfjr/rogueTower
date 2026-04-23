import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../core/pallete.dart'; // Ajuste o caminho para a sua paleta

class AttackWarningEffect extends PositionComponent {
  final double maxRadius;
  final double duration;
  final Color color;
  final PositionComponent owner;
  
  double _timer = 0;
  late Paint _movingPaint;
  //late Paint _targetPaint;

  AttackWarningEffect({
    required Vector2 position,
    required this.owner,
    this.maxRadius = 32.0,
    this.duration = 1.0, 
    this.color = Pallete.vermelho,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    // A linha que vai encolher
    _movingPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..isAntiAlias = false
      //..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ;
      

    
   // _targetPaint = Paint()
    //  ..color = color.withOpacity(0.5)
    //  ..style = PaintingStyle.stroke
    //  ..isAntiAlias = false
     // ..strokeWidth = 1.0;
      
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timer += dt;

    position = owner.position.clone();
    
    // Quando o tempo acaba, o efeito destrói-se a si mesmo
    if (_timer >= duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    double progress = (_timer / duration).clamp(0.0, 1.0);
    
    double currentRadius = maxRadius * (1.0 - progress);

    //canvas.drawCircle(Offset.zero, 10.0, _targetPaint);
    
    canvas.drawCircle(Offset.zero, currentRadius, _movingPaint);
  }
}