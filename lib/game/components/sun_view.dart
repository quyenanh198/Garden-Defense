import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../config/balance.dart';
import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';

class SunView extends PositionComponent with TapCallbacks {
  SunView(this.sun, SpriteRegistry sprites, this.onCollect, GridBoard board)
      : super(size: Vector2.all(64), anchor: Anchor.center) {
    final anim = sprites.animation('sun_idle');
    final s = sprites.sprite('sun');
    if (anim != null) {
      add(SpriteAnimationComponent(animation: anim, size: size));
    } else if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    }
    _hasSprite = anim != null || s != null;
    priority = 100; // trên mọi thứ để bắt tap trước lưới
    _target = board.cellToPixel(sun.row, sun.col);
    // Sun từ sunflower bật ra từ hoa; sun trời rơi từ mép trên.
    _from = sun.fromCol == null
        ? null
        : board.cellToPixel(sun.row, sun.fromCol!) - Vector2(0, 24);
    position = _from ?? Vector2(_target.x, GridBoard.originY - 40);
  }

  final SunDrop sun;
  final void Function(int sunId) onCollect;
  late final Vector2 _target;
  late final Vector2? _from;
  late final bool _hasSprite;
  final _fill = Paint()..color = const Color(0xFFFBBF24);
  final _ring = Paint()
    ..color = const Color(0xFFF59E0B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  void syncFromState() {
    if (_from != null) {
      // Vồng parabol ngắn từ hoa sang ô cạnh.
      final t = (sun.age / 0.6).clamp(0.0, 1.0);
      position = Vector2(
        lerpDouble(_from.x, _target.x, t)!,
        lerpDouble(_from.y, _target.y, t)! - 36 * 4 * t * (1 - t),
      );
    } else {
      final t = (sun.age / 1.0).clamp(0.0, 1.0);
      position = Vector2(
        _target.x,
        lerpDouble(GridBoard.originY - 40, _target.y, t)!,
      );
    }
    final left = Balance.sunLifetime - sun.age;
    if (left < 2) {
      final blink = (sin(left * 12) + 1) / 2;
      _fill.color = const Color(
        0xFFFBBF24,
      ).withValues(alpha: 0.4 + 0.6 * blink);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_hasSprite) return;
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, size.x / 2 - 4, _fill);
    canvas.drawCircle(c, size.x / 2 - 4, _ring);
  }

  @override
  void onTapDown(TapDownEvent event) => onCollect(sun.id);
}
