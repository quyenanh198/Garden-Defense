import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';

class ProjectileView extends PositionComponent {
  ProjectileView(this.projectile, SpriteRegistry sprites, this.board)
      : super(size: Vector2.all(24), anchor: Anchor.center) {
    final id = projectile.slows ? 'icepea_shot' : 'pea';
    final anim = sprites.animation('${id}_idle');
    final s = sprites.sprite(id);
    if (anim != null) {
      add(SpriteAnimationComponent(animation: anim, size: size));
    } else if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    }
    _hasSprite = anim != null || s != null;
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
  final GridBoard board;
  late final Paint _paint;
  late final Paint _outline;
  late final bool _hasSprite;

  void syncFromState() {
    final c = board.cellToPixel(projectile.row, projectile.col);
    position = Vector2(c.x, c.y - board.cellH * 0.15);
  }

  @override
  void render(Canvas canvas) {
    if (_hasSprite) return;
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, size.x / 2 - 2, _paint);
    canvas.drawCircle(c, size.x / 2 - 2, _outline);
  }
}
