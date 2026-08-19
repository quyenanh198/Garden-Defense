import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

/// Đọc assets/images/manifest.json; trả null nếu id/file thiếu
/// (view tự vẽ placeholder). Không bao giờ ném lỗi vì thiếu asset.
class SpriteRegistry {
  final Map<String, Sprite> _sprites = {};
  final Map<String, SpriteAnimation> _animations = {};

  Future<void> load() async {
    Map<String, dynamic> manifest;
    try {
      manifest =
          jsonDecode(await rootBundle.loadString('assets/images/manifest.json'))
              as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final entries = manifest['sprites'] as Map<String, dynamic>? ?? {};
    for (final e in entries.entries) {
      final cfg = e.value as Map<String, dynamic>;
      final file = cfg['file'] as String;
      try {
        final image = await Flame.images.load(file);
        final frameSize = (cfg['frameSize'] as List<dynamic>?)?.cast<num>();
        final frames = cfg['frames'] as int? ?? 1;
        if (frameSize != null && frames > 1) {
          _animations[e.key] = SpriteAnimation.fromFrameData(
            image,
            SpriteAnimationData.sequenced(
              amount: frames,
              stepTime: (cfg['stepTime'] as num? ?? 0.15).toDouble(),
              textureSize: Vector2(
                frameSize[0].toDouble(),
                frameSize[1].toDouble(),
              ),
            ),
          );
        } else {
          _sprites[e.key] = Sprite(image);
        }
      } catch (_) {
        // thiếu file: bỏ qua, view dùng placeholder
      }
    }
  }

  Sprite? sprite(String id) => _sprites[id];
  SpriteAnimation? animation(String id) => _animations[id];
}
