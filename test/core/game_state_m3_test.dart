import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

void main() {
  test('peashooter only fires when a zombie is in its row', () {
    final g = newGame(
      lvl: level(waves: const [WaveEntry(time: 1, zombie: 'walker', row: 0)]),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 5);
    expect(g.projectiles, isEmpty);
    run(g, 7.5);
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.ok);
    run(g, 0.5);
    expect(g.projectiles, isNotEmpty);
    expect(g.projectiles.every((p) => p.row == 0), isTrue);
  });
  test('10 peas (200 dmg) kill a walker; hit and death events fire', () {
    final g = newGame(
      lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    var hits = 0;
    var died = false;
    var t = 0.0;
    while (t < 40 && !died) {
      run(g, 0.5);
      t += 0.5;
      for (final e in g.takeEvents()) {
        if (e is ZombieHit) hits++;
        if (e is ZombieDied) died = true;
      }
    }
    expect(died, isTrue);
    expect(hits, 10);
    expect(t, lessThan(9 * 4.7));
    run(g, Balance.zombieDyingDuration + 0.1);
    expect(g.zombies, isEmpty);
  });
  test('pea does not hit zombie in another row', () {
    final g = newGame(
      lvl: level(
        waves: const [
          WaveEntry(time: 0, zombie: 'walker', row: 1),
          WaveEntry(time: 0, zombie: 'walker', row: 2),
        ],
      ),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 6);
    final row1 = g.zombies.firstWhere((z) => z.row == 1);
    final row2 = g.zombies.firstWhere((z) => z.row == 2);
    expect(row1.hp, 200);
    expect(row2.hp, lessThan(200));
  });
  test('fire cadence is exactly fireInterval while a target is present', () {
    final g = newGame(
      lvl: level(waves: const [WaveEntry(time: 0, zombie: 'bucket', row: 2)]),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    var spawned = 0;
    var seen = <int>{};
    for (var i = 0; i < 100; i++) {
      run(g, 0.05);
      for (final p in g.projectiles) {
        if (seen.add(p.id)) spawned++;
      }
    }
    // 5 s: bắn tại t≈0, 1.4, 2.8, 4.2
    expect(spawned, 4);
  });
  test('commands are ignored when game is not playing', () {
    final g = newGame(lvl: level(startingSun: 500));
    g.pause();
    g.selectPlant('wallnut');
    expect(g.tapCell(0, 0), PlantResult.notPlaying);
    expect(g.plants, isEmpty);
    g.resume();
    run(g, 9 * 4.7 + 1); // thua
    expect(g.tapCell(0, 1), PlantResult.notPlaying);
    expect(g.collectSun(1), isFalse);
  });
  test('pea hits the front-most zombie only', () {
    final g = newGame(
      lvl: level(
        waves: const [
          WaveEntry(time: 0, zombie: 'walker', row: 2),
          WaveEntry(time: 4, zombie: 'walker', row: 2),
        ],
      ),
    );
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 8);
    final sorted = [...g.zombies]..sort((a, b) => a.col.compareTo(b.col));
    expect(sorted.first.hp, lessThan(200));
    expect(sorted.last.hp, 200);
    expect(sorted.first.state, isNot(ZombieState.dying));
  });
}
