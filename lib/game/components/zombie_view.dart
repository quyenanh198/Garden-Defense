import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/balance.dart';
import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';
import 'placeholder.dart';

class ZombieView extends PositionComponent {
  ZombieView(this.zombie, SpriteRegistry sprites)
      : super(
          size: Vector2(GridBoard.cellW * 0.7, GridBoard.cellH * 0.95),
          anchor: Anchor.bottomCenter,
        ) {
    final anim = sprites.animation('${zombie.spec.id}_walk');
    final s = sprites.sprite(zombie.spec.id);
    if (anim != null) {
      add(SpriteAnimationComponent(animation: anim, size: size));
    } else if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    } else {
      _placeholder = PlaceholderPainter(
        placeholderColors[zombie.spec.id]!,
        zombie.spec.id,
      );
    }
    priority = 20 + zombie.row;
    syncFromState();
  }

  final Zombie zombie;
  PlaceholderPainter? _placeholder;
  double _flash = 0;
  final _hpBg = Paint()..color = const Color(0xFF7F1D1D);
  final _hpFg = Paint()..color = const Color(0xFF22C55E);
  final _slowTint = Paint()..color = const Color(0x5538BDF8);
  final _flashPaint = Paint()..color = const Color(0x99FFFFFF);

  void hitFlash() => _flash = 0.12;

  void syncFromState() {
    final center = GridBoard.cellToPixel(zombie.row, zombie.col);
    // lệch phải 1/4 ô để khi ăn, zombie đứng sát mép phải plant thay vì đè lên
    position = Vector2(
      center.x + GridBoard.cellW * 0.25,
      center.y + GridBoard.cellH * 0.45,
    );
    if (zombie.state == ZombieState.dying) {
      final t = (zombie.dyingRemaining / Balance.zombieDyingDuration).clamp(
        0.0,
        1.0,
      );
      scale = Vector2(t, t);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash -= dt;
  }

  @override
  void render(Canvas canvas) {
    _placeholder?.paint(canvas, size);
    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    if (zombie.isSlowed) canvas.drawRRect(rr, _slowTint);
    if (_flash > 0) canvas.drawRRect(rr, _flashPaint);
    final w = size.x * (zombie.hp / zombie.spec.hp).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6), _hpBg);
    canvas.drawRect(Rect.fromLTWH(0, -10, w, 6), _hpFg);
  }
}
