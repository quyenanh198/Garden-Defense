import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';

void main() {
  test('plant and zombie ids match GAME_DESIGN.md', () {
    expect(
      Balance.plants.keys,
      containsAll(['sunflower', 'peashooter', 'wallnut', 'icepea']),
    );
    expect(Balance.zombies.keys, containsAll(['walker', 'cone', 'bucket']));
  });
  test('peashooter DPS ~14.3 and walker dies in ~14s', () {
    final dps = Balance.peaDamage / Balance.fireInterval;
    expect(dps, closeTo(14.3, 0.1));
    expect(Balance.zombies['walker']!.hp / dps, closeTo(14, 0.5));
  });
  test('costs and hp mirror docs', () {
    expect(Balance.plants['sunflower']!.cost, 50);
    expect(Balance.plants['peashooter']!.cost, 100);
    expect(Balance.plants['wallnut']!.hp, 4000);
    expect(Balance.plants['icepea']!.cost, 175);
    expect(Balance.zombies['cone']!.hp, 560);
    expect(Balance.zombies['bucket']!.hp, 1300);
  });
}
