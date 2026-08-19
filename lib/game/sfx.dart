import 'package:flame_audio/flame_audio.dart';

/// Phát SFX best-effort: thiếu plugin (widget test) hay thiếu file thì bỏ
/// qua — âm thanh là tô điểm, không bao giờ được làm hỏng game/test.
class Sfx {
  Sfx._();

  static Future<void> play(String name) async {
    try {
      await FlameAudio.play('$name.wav');
    } catch (_) {
      // im lặng
    }
  }
}
