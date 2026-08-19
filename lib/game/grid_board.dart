import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../config/balance.dart';

/// Nơi duy nhất biết kích thước ô theo pixel (không gian ảo 1280×720).
class GridBoard extends PositionComponent with TapCallbacks {
  GridBoard()
      : super(position: Vector2(originX, originY), size: Vector2(gridW, gridH));

  static const double originX = 200;
  static const double originY = 100;
  static const double gridW = 1040;
  static const double gridH = 600;
  static const double cellW = gridW / Balance.cols;
  static const double cellH = gridH / Balance.rows;

  void Function(int row, int col)? onCellTap;

  final _light = Paint()..color = const Color(0xFF6ABE45);
  final _dark = Paint()..color = const Color(0xFF5AAE3A);

  /// Tâm ô (row, col) theo world coords. col có thể là số thực (zombie/đạn).
  static Vector2 cellToPixel(int row, double col) =>
      Vector2(originX + (col + 0.5) * cellW, originY + (row + 0.5) * cellH);

  /// Ô chứa điểm world; null nếu ngoài lưới.
  static ({int row, int col})? pixelToCell(Vector2 world) {
    final c = ((world.x - originX) / cellW).floor();
    final r = ((world.y - originY) / cellH).floor();
    if (r < 0 || r >= Balance.rows || c < 0 || c >= Balance.cols) return null;
    return (row: r, col: c);
  }

  @override
  void render(Canvas canvas) {
    for (var r = 0; r < Balance.rows; r++) {
      for (var c = 0; c < Balance.cols; c++) {
        canvas.drawRect(
          Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH),
          (r + c).isEven ? _light : _dark,
        );
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final cell = pixelToCell(event.localPosition + position);
    if (cell != null) onCellTap?.call(cell.row, cell.col);
  }
}
