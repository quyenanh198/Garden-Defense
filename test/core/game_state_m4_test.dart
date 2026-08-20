import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

const _far = [WaveEntry(time: 999, zombie: 'walker', row: 0)];

void main() {
  test('not enough sun rejects and emits PlantRejected', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.notEnoughSun);
    expect(
      g.takeEvents().whereType<PlantRejected>().single.reason,
      PlantResult.notEnoughSun,
    );
    expect(g.sun, 50);
  });
  test('planting deducts exact cost and starts cooldown', () {
    final g = newGame(lvl: level(startingSun: 200, waves: _far));
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.ok);
    expect(g.sun, 100);
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 1), PlantResult.onCooldown);
    run(g, Balance.plants['peashooter']!.plantCooldown + 0.01);
    // thẻ vẫn đang được chọn sau lần bị từ chối
    expect(g.selectedPlantId, 'peashooter');
    expect(g.tapCell(0, 1), PlantResult.ok);
    expect(g.sun, 0);
  });
  test('sky sun spawns from 5s and expires after 8s', () {
    final g = newGame(lvl: level(skySuns: true, waves: _far));
    run(g, 5.05);
    expect(g.suns.length, 1);
    run(g, 7.9);
    expect(g.suns.length, 1);
    run(g, 0.2);
    expect(g.suns, isEmpty);
    expect(g.takeEvents().whereType<SunExpired>(), isNotEmpty);
  });
  test('collecting sun adds 25', () {
    final g = newGame(
      lvl: level(startingSun: 0, skySuns: true, waves: _far),
    );
    run(g, 5.05);
    final id = g.suns.single.id;
    expect(g.collectSun(id), isTrue);
    expect(g.sun, 25);
    expect(g.suns, isEmpty);
    expect(g.collectSun(id), isFalse);
  });
  test('sunflower produces 25 sun every 15s', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('sunflower');
    g.tapCell(1, 1);
    run(g, 14.9);
    expect(g.suns, isEmpty);
    run(g, 0.2);
    expect(g.suns.single.value, 25);
    expect(g.suns.single.row, 1);
  });
  test('wallnut blocks a walker for a long time', () {
    final g = newGame(
      lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]),
    );
    g.selectPlant('wallnut');
    g.tapCell(2, 4);
    run(g, 4.7 * 4.5 + 30);
    expect(g.plants.length, 1);
    expect(g.plants.single.hp, lessThan(4000));
    expect(g.phase, isNot(GamePhase.lost));
  });
  test('icepea slows zombie by 50%', () {
    final g = newGame(
      lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]),
    );
    g.selectPlant('icepea');
    g.tapCell(2, 0);
    var slowedSeen = false;
    for (var i = 0; i < 60; i++) {
      run(g, 0.25);
      if (g.zombies.isNotEmpty && g.zombies.first.isSlowed) {
        slowedSeen = true;
        break;
      }
    }
    expect(slowedSeen, isTrue);
    final z = g.zombies.first;
    final c0 = z.col;
    run(g, 1.0); // đạn kế tới sau 1.4 s nên 1 s này bị chậm suốt
    expect(c0 - z.col, closeTo(Balance.zombieCellsPerSecond * 0.5, 0.02));
  });
  test('cannot select plant not available in level', () {
    final g = newGame(lvl: level(plants: const ['peashooter'], waves: _far));
    g.selectPlant('icepea');
    expect(g.selectedPlantId, isNull);
  });
}
