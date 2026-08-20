import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

const _far = [WaveEntry(time: 999, zombie: 'walker', row: 0)];

// Tái hiện khiếu nại cân bằng: zombie đầu tiên vào giây 20 nhưng kinh tế
// quá chậm để mua peashooter kịp lúc. Chuẩn mới:
// - sun trời rơi lần đầu ở giây skySunFirstDrop (5), sau đó mỗi 10s
// - sunflower sinh sun mỗi 15s
// - kịch bản level 2 (100 sun, mua sunflower ngay): đủ 100 sun cho
//   peashooter trước giây 20 nếu nhặt đủ sun.
void main() {
  test('first sky sun drops at 5s, not 10s', () {
    final g = newGame(lvl: level(skySuns: true, waves: _far));
    run(g, Balance.skySunFirstDrop - 0.1);
    expect(g.suns, isEmpty);
    run(g, 0.2);
    expect(g.suns.length, 1);
  });

  test('sky suns keep 10s cadence after the early first drop', () {
    final g = newGame(lvl: level(skySuns: true, waves: _far));
    // rơi ở 5 và 15 → sau 15.1s đã spawn đúng 2 sun (đếm qua sự kiện vì
    // sun đầu hết hạn ở giây 13).
    var spawned = 0;
    for (var t = 0.0; t < 15.1; t += 0.1) {
      run(g, 0.1);
      spawned += g.takeEvents().whereType<SunSpawned>().length;
    }
    expect(spawned, 2);
  });

  test('level-2 scenario: peashooter affordable before first zombie at 20s',
      () {
    final g = newGame(
      lvl: level(
        startingSun: 100,
        skySuns: true,
        plants: const ['peashooter', 'sunflower'],
        waves: _far,
      ),
    );
    g.selectPlant('sunflower');
    expect(g.tapCell(2, 0).name, 'ok');
    // Nhặt mọi sun ngay khi rơi, dừng khi đủ tiền peashooter.
    final cost = Balance.plants['peashooter']!.cost;
    var t = 0.0;
    while (g.sun < cost && t < 20) {
      run(g, 0.1);
      t += 0.1;
      for (final s in List.of(g.suns)) {
        g.collectSun(s.id);
      }
    }
    expect(g.sun, greaterThanOrEqualTo(cost),
        reason: 'phải đủ $cost sun trước giây 20, chỉ đạt ${g.sun} ở ${t}s');
  });
}
