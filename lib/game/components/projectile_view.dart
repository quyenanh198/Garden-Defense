import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';

class ProjectileView extends PositionComponent {
  ProjectileView(this.projectile, SpriteRegistry sprites)
      : super(size: Vector2.all(24), anchor: Anchor.center) {
    final s = sprites.sprite(projectile.slows ? 'icepea_shot' : 'pea');
    if (s != null) add(SpriteComponent(sprite: s, size: size));
    _hasSprite = s != null;
    _paint = Paint()
      ..color =
          projectile.slows ? const Color(0xFF38BDF8) : const Color(0xFF22C55E);
    _outline = Paint()
      ..color = const Color(0xFF14532D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    priority = 30;
    syncFromState();
  }

  final Projectile projectile;
  late final Paint _paint;
  late final Paint _outline;
  late final bool _hasSprite;

  void syncFromState() {
    final c = GridBoard.cellToPixel(projectile.row, projectile.col);
    position = Vector2(c.x, c.y - GridBoard.cellH * 0.15);
  }

  @override
  void render(Canvas canvas) {
    if (_hasSprite) return;
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, size.x / 2 - 2, _paint);
    canvas.drawCircle(c, size.x / 2 - 2, _outline);
  }
}
