import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';
import 'placeholder.dart';

class PlantView extends PositionComponent {
  PlantView(this.plant, SpriteRegistry sprites, GridBoard board)
      : super(
          size: Vector2(board.cellW * 0.8, board.cellH * 0.8),
          anchor: Anchor.center,
        ) {
    position = board.cellToPixel(plant.row, plant.col.toDouble());
    final s = sprites.sprite(plant.spec.id);
    if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    } else {
      _placeholder = PlaceholderPainter(
        placeholderColors[plant.spec.id]!,
        plant.spec.id,
      );
    }
    priority = 10 + plant.row;
  }

  final Plant plant;
  PlaceholderPainter? _placeholder;
  final _hpBg = Paint()..color = const Color(0xFF7F1D1D);
  final _hpFg = Paint()..color = const Color(0xFF22C55E);
  final _upgradeRing = Paint()
    ..color = const Color(0xFFF59E0B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  /// Thanh máu chỉ hiện khi cây đã mất máu.
  bool get showsHpBar => plant.hp < plant.maxHp;

  @override
  void render(Canvas canvas) {
    _placeholder?.paint(canvas, size);
    if (plant.upgraded) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _upgradeRing);
    }
    if (showsHpBar) {
      final w = size.x * (plant.hp / plant.maxHp).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6), _hpBg);
      canvas.drawRect(Rect.fromLTWH(0, -10, w, 6), _hpFg);
    }
  }
}
