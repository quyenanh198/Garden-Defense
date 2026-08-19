import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

LevelData level01() =>
    LevelData.parse(File('assets/levels/level_01.json').readAsStringSync());

/// Kịch bản: peashooter hàng 2 cột 0 tại t=0 (150 sun), thu mọi sun, trồng
/// thêm peashooter hàng 2 (cột 1..3) khi đủ 100 sun và hết cooldown.
GameState playScripted(LevelData lvl, {double maxSeconds = 400}) {
  final g = newGame(lvl: lvl);
  g.selectPlant('peashooter');
  g.tapCell(2, 0);
  var t = 0.0;
  var nextCol = 1;
  while (g.phase == GamePhase.playing && t < maxSeconds) {
    run(g, 0.25);
    t += 0.25;
    for (final s in [...g.suns]) {
      g.collectSun(s.id);
    }
    if (nextCol < 4 && g.sun >= 100 && g.cooldownRemaining('peashooter') == 0) {
      g.selectPlant('peashooter');
      if (g.tapCell(2, nextCol) == PlantResult.ok) nextCol++;
    }
  }
  return g;
}

void main() {
  test('level 01 is winnable with scripted play', () {
    final g = playScripted(level01());
    expect(g.phase, GamePhase.won);
    expect(g.allWavesSpawned, isTrue);
  });
  test('huge wave warning fires 3s before the flagged wave', () {
    // peashooter giữ hàng 2 để trận không thua sớm (thua thì elapsed đứng yên)
    final g = newGame(lvl: level01());
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    var warnedAt = -1.0;
    var t = 0.0;
    while (t < 115 && warnedAt < 0) {
      run(g, 0.25);
      t += 0.25;
      if (g.takeEvents().any((e) => e is HugeWaveWarning)) {
        warnedAt = g.elapsed;
      }
    }
    expect(warnedAt, closeTo(107, 0.3));
  });
  test('adding waves to level data changes outcome without code changes', () {
    final base = level01();
    final harder = LevelData(
      id: base.id,
      name: base.name,
      startingSun: base.startingSun,
      availablePlants: base.availablePlants,
      skySuns: base.skySuns,
      waves: [
        ...base.waves,
        for (var i = 0; i < 6; i++)
          WaveEntry(time: 113 + i.toDouble(), zombie: 'bucket', row: 2),
      ],
    );
    final g = playScripted(harder);
    expect(g.phase, GamePhase.lost);
  });
  test('win requires all waves spawned and no zombies alive', () {
    final g = newGame(
      lvl: level(
        waves: const [
          WaveEntry(time: 0, zombie: 'walker', row: 2),
          WaveEntry(time: 30, zombie: 'walker', row: 2),
        ],
      ),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 20);
    expect(g.phase, GamePhase.playing);
    run(g, 40);
    expect(g.phase, GamePhase.won);
  });
}
