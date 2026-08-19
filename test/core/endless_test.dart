import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/endless_spawner.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';

import 'test_helpers.dart';

GameState endlessGame({int rows = 5, int cols = 9, int seed = 1}) => GameState(
      level: GameState.endlessConfig(),
      rows: rows,
      cols: cols,
      endless: true,
      random: Random(seed),
    );

/// Chạy spawner qua [seconds] giây (bước 0.5s), gom mọi entry sinh ra.
List<List<dynamic>> drive(EndlessSpawner s, double seconds) {
  final batches = <List<dynamic>>[];
  for (var t = 0.0; t < seconds; t += 0.5) {
    final b = s.tick(t);
    if (b.isNotEmpty) batches.add(b);
  }
  return batches;
}

void main() {
  test('endless spawner is deterministic for the same seed', () {
    final a = EndlessSpawner(rows: 5, random: Random(7));
    final b = EndlessSpawner(rows: 5, random: Random(7));
    for (var t = 0.0; t < 200; t += 0.5) {
      final ba = a.tick(t);
      final bb = b.tick(t);
      expect(ba.map((w) => '${w.zombie}/${w.row}').toList(),
          bb.map((w) => '${w.zombie}/${w.row}').toList());
    }
  });

  test('batches escalate and huge wave doubles every 10th', () {
    final s = EndlessSpawner(rows: 5, random: Random(1));
    final batches = drive(s, 400);
    expect(s.wave, greaterThanOrEqualTo(20));
    // Đợt 1 nhỏ hơn đợt 15 (leo thang).
    expect(batches[0].length, lessThan(batches[14].length));
    // Đợt 10: cỡ 2×(1 + 10÷5) = 6; đợt 9: 1 + 9÷5 = 2.
    expect(batches[9].length, 2 * (1 + 10 ~/ 5));
    expect(batches[8].length, 1 + 9 ~/ 5);
    // Mọi hàng trong biên.
    for (final b in batches) {
      for (final w in b) {
        expect(w.row, inInclusiveRange(0, 4));
      }
    }
  });

  test('warning fires before each huge wave', () {
    final s = EndlessSpawner(rows: 5, random: Random(1));
    var warnings = 0;
    for (var t = 0.0; t < 400; t += 0.5) {
      if (s.dueWarnings(t).isNotEmpty) warnings++;
      s.tick(t);
    }
    // Tới ~400s có hơn 20 đợt → 2 huge wave (đợt 10, 20) → 2 cảnh báo.
    expect(warnings, 2);
  });

  test('interval shrinks toward the floor', () {
    final s = EndlessSpawner(rows: 5, random: Random(1));
    final times = <double>[];
    for (var t = 0.0; t < 900; t += 0.25) {
      if (s.tick(t).isNotEmpty) times.add(t);
    }
    final lastGap = times[times.length - 1] - times[times.length - 2];
    expect(lastGap, closeTo(Balance.endlessMinInterval, 0.3));
  });

  test('endless never wins even with no zombies alive', () {
    final g = endlessGame();
    run(g, 10); // trước đợt đầu (t=20): sân trống, không được thắng
    expect(g.phase, GamePhase.playing);
  });

  test('zombies spawn at the right edge of a 10x20 grid', () {
    final g = endlessGame(rows: 10, cols: 20);
    run(g, Balance.endlessFirstWaveTime + 0.5);
    expect(g.zombies, isNotEmpty);
    expect(g.zombies.first.col, closeTo(20, 0.15)); // spawn mép phải, đã đi nhẹ
    expect(g.zombies.first.row, inInclusiveRange(0, 9));
  });

  test('sky sun stays inside the larger grid', () {
    final g = endlessGame(rows: 10, cols: 20, seed: 3);
    run(g, 10.1);
    expect(g.suns, isNotEmpty);
    for (final s in g.suns) {
      expect(s.row, inInclusiveRange(0, 9));
      expect(s.col, inInclusiveRange(0, 19));
    }
  });

  group('upgrade', () {
    test('costs 2x, applies once, doubles hp', () {
      final g = endlessGame();
      g.selectPlant('peashooter');
      expect(g.tapCell(2, 1), PlantResult.ok); // sun 150 → 50
      expect(g.tapCell(2, 1), PlantResult.notEnoughSun); // cần 200
      g.sun = 400;
      expect(g.tapCell(2, 1), PlantResult.ok);
      expect(g.sun, 200);
      final p = g.plants.single;
      expect(p.upgraded, isTrue);
      expect(p.hp, 600);
      expect(p.maxHp, 600);
      expect(g.takeEvents().whereType<PlantUpgraded>(), isNotEmpty);
      expect(g.tapCell(2, 1), PlantResult.alreadyUpgraded);
    });

    test('upgraded shooter projectile carries 2x damage', () {
      final g = endlessGame();
      g.sun = 400;
      g.selectPlant('peashooter');
      g.tapCell(2, 1);
      g.tapCell(2, 1); // nâng cấp (thẻ tự bỏ chọn sau khi trồng)
      g.zombies.add(
        Zombie(id: 1000, spec: Balance.zombies['walker']!, row: 2)..col = 7,
      );
      run(g, 0.3); // đủ để bắn phát đầu
      expect(g.projectiles, isNotEmpty);
      expect(g.projectiles.first.damage, Balance.peaDamage * 2);
    });

    test('upgraded sunflower drops double sun', () {
      final g = endlessGame();
      g.sun = 400;
      g.selectPlant('sunflower');
      g.tapCell(0, 0);
      g.tapCell(0, 0); // nâng cấp
      run(g, Balance.sunflowerInterval + 0.1);
      final drop = g.suns.firstWhere((s) => s.row == 0);
      expect(drop.value, Balance.sunflowerValue * 2);
    });

    test('campaign mode has no upgrade path', () {
      final g = newGame(); // campaign 5×9 mặc định
      g.selectPlant('peashooter');
      g.tapCell(2, 1);
      expect(g.tapCell(2, 1), PlantResult.noSelection);
      expect(g.plants.single.upgraded, isFalse);
    });
  });
}
