import 'package:flutter/material.dart';

/// Design system: Claymorphism nhẹ, palette xanh cỏ + vàng nắng.
class GdColors {
  GdColors._();
  static const primary = Color(0xFF15803D);
  static const primaryDark = Color(0xFF166534);
  static const sun = Color(0xFFF59E0B);
  static const sunText = Color(0xFFFBBF24);
  static const menuBg = Color(0xFFF0FDF4);
  static const hudChip = Color(0xD90F172A);
  static const hudBar = Color(0x8014532D);
  static const danger = Color(0xFFDC2626);
  static const ink = Color(0xFF0F172A);
  static const card = Colors.white;
}

class GdText {
  GdText._();
  static const heading = TextStyle(
    fontFamily: 'Fredoka',
    fontWeight: FontWeight.w700,
    color: GdColors.ink,
  );
  static const body = TextStyle(fontFamily: 'Nunito', color: GdColors.ink);
}

class GdShape {
  GdShape._();
  static const radius = 16.0;
  static const radiusLg = 24.0;
  static const border = 3.0;
  static const borderLg = 4.0;
  static const clayShadow = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 6), blurRadius: 0),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 16),
  ];
}
