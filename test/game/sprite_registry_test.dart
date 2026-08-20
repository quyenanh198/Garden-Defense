import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/game/sprite_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('registry loads the real manifest: all sprites and walk animations',
      () async {
    final r = SpriteRegistry();
    await r.load();
    for (final id in [
      'sunflower', 'peashooter', 'wallnut', 'icepea',
      'walker', 'cone', 'bucket', 'pea', 'icepea_shot', 'sun',
    ]) {
      expect(r.sprite(id), isNotNull, reason: 'thiếu sprite $id');
    }
    for (final id in [
      'walker_walk', 'cone_walk', 'bucket_walk',
      'peashooter_idle', 'icepea_idle', 'sunflower_idle', 'wallnut_idle',
      'sun_idle', 'pea_idle', 'icepea_shot_idle',
    ]) {
      expect(r.animation(id), isNotNull, reason: 'thiếu animation $id');
    }
  });
}
