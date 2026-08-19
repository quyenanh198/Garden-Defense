import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';
import 'placeholder.dart';

class PlantView extends PositionComponent {
  PlantView(this.plant, SpriteRegistry sprites)
      : super(
          size: Vector2(GridBoard.cellW * 0.8, GridBoard.cellH * 0.8),
          anchor: Anchor.center,
        ) {
    position = GridBoard.cellToPixel(plant.row, plant.col.toDouble());
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

  @override
  void render(Canvas canvas) {
    _placeholder?.paint(canvas, size);
    if (plant.spec.hp >= 1000) {
      // thanh máu chỉ cho wallnut
      final w = size.x * (plant.hp / plant.spec.hp).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6), _hpBg);
      canvas.drawRect(Rect.fromLTWH(0, -10, w, 6), _hpFg);
    }
  }
}
