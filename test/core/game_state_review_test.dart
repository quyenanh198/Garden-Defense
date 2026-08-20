import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

const _far = [WaveEntry(time: 999, zombie: 'walker', row: 0)];

void main() {
  test('pea still hits when one frame moves it past the zombie', () {
    final g = newGame(lvl: level(waves: _far));
    final z = Zombie(id: 1000, spec: Balance.zombies['walker']!, row: 2)
      ..col = 5;
    g.zombies.add(z);
    g.projectiles.add(
      Projectile(id: 1001, row: 2, col: 1, damage: Balance.peaDamage),
    );
    // dt lớn (giật 1 s): đạn đi 6 ô, vượt qua vị trí zombie trong một bước.
    g.tick(1.0);
    expect(z.hp, Balance.zombies['walker']!.hp - Balance.peaDamage);
    expect(g.projectiles, isEmpty);
    expect(g.takeEvents().whereType<ZombieHit>(), isNotEmpty);
  });

  test('swept hit picks the nearest zombie on the pea path', () {
    final g = newGame(lvl: level(waves: _far));
    final near = Zombie(id: 1000, spec: Balance.zombies['walker']!, row: 2)
      ..col = 3;
    final far = Zombie(id: 1001, spec: Balance.zombies['walker']!, row: 2)
      ..col = 5;
    g.zombies.addAll([near, far]);
    g.projectiles.add(
      Projectile(id: 1002, row: 2, col: 1, damage: Balance.peaDamage),
    );
    g.tick(1.0);
    expect(near.hp, Balance.zombies['walker']!.hp - Balance.peaDamage);
    expect(far.hp, Balance.zombies['walker']!.hp);
  });

  test('sunflower sun drops beside the flower with its source recorded', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('sunflower');
    g.tapCell(1, 1);
    run(g, Balance.sunflowerInterval + 0.2);
    final s = g.suns.single;
    expect(s.row, 1);
    expect(s.col, 2); // ô bên phải hoa (docs: "rơi ngay cạnh cây")
    expect(s.fromCol, 1);
  });

  test('sunflower at the right edge drops sun to its left', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('sunflower');
    g.tapCell(1, 8);
    run(g, Balance.sunflowerInterval + 0.2);
    expect(g.suns.single.col, 7);
  });

  test('sky sun has no source flower', () {
    final g = newGame(lvl: level(skySuns: true, waves: _far));
    run(g, 10.05);
    expect(g.suns.single.fromCol, isNull);
  });

  test('zombie spawn column derives from Balance.cols', () {
    final z = Zombie(id: 1, spec: Balance.zombies['walker']!, row: 0);
    expect(z.col, Balance.cols.toDouble());
  });

  test('slowed zombie eats at half DPS', () {
    final g = newGame(lvl: level(waves: _far));
    g.selectPlant('wallnut');
    g.tapCell(2, 4);
    final z = Zombie(id: 1000, spec: Balance.zombies['walker']!, row: 2)
      ..col = 4.2
      ..slowRemaining = 100;
    g.zombies.add(z);
    run(g, 1.0);
    final eaten = Balance.plants['wallnut']!.hp - g.plants.single.hp;
    expect(eaten, closeTo(Balance.zombieBiteDps * Balance.iceSlowFactor, 0.5));
  });
}
