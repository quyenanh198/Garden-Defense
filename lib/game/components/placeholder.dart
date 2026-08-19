import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

/// Khối màu bo góc + nhãn, dùng khi thiếu sprite.
class PlaceholderPainter {
  PlaceholderPainter(this.color, this.label);
  final Color color;
  final String label;

  late final _fill = Paint()..color = color;
  late final _stroke = Paint()
    ..color = const Color(0xFF1F2937)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  late final _text = TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );

  void paint(Canvas canvas, Vector2 size) {
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      const Radius.circular(16),
    );
    canvas.drawRRect(r, _fill);
    canvas.drawRRect(r, _stroke);
    _text.render(
      canvas,
      label,
      Vector2(size.x / 2, size.y / 2),
      anchor: Anchor.center,
    );
  }
}

const Map<String, Color> placeholderColors = {
  'sunflower': Color(0xFFF59E0B),
  'peashooter': Color(0xFF16A34A),
  'wallnut': Color(0xFF92400E),
  'icepea': Color(0xFF38BDF8),
  'walker': Color(0xFF6B7280),
  'cone': Color(0xFFEA580C),
  'bucket': Color(0xFF475569),
};
