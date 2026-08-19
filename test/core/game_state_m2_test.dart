import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';

import 'test_helpers.dart';

void main() {
  test('zombie spawns at right edge on wave time and walks left', () {
    final g = newGame();
    g.tick(0.01);
    expect(g.zombies.length, 1);
    expect(g.zombies.first.col, closeTo(9.0, 0.01));
    run(g, 4.7);
    expect(g.zombies.first.col, closeTo(8.0, 0.05));
  });
  test('zombie reaching col < 0 loses the game', () {
    final g = newGame();
    run(g, 9 * 4.7 + 1);
    expect(g.phase, GamePhase.lost);
    expect(g.takeEvents().whereType<GameLost>(), isNotEmpty);
  });
  test('placing a plant on empty cell with selection', () {
    final g = newGame();
    expect(g.tapCell(2, 4), PlantResult.noSelection);
    g.selectPlant('wallnut');
    expect(g.tapCell(2, 4), PlantResult.ok);
    expect(g.plants.single.col, 4);
    expect(g.selectedPlantId, isNull);
    g.selectPlant('wallnut');
    expect(g.tapCell(2, 4), PlantResult.occupied);
  });
  test('zombie eats plant, plant dies, zombie walks again', () {
    final g = newGame();
    g.selectPlant('sunflower');
    g.tapCell(2, 8);
    run(g, 0.6 * 4.7); // 9.0 -> ~8.4: đã qua mép phải ô 8 (8.5)
    final z = g.zombies.single;
    expect(z.state, ZombieState.eating);
    final colWhileEating = z.col;
    run(g, 1.0);
    expect(z.col, colWhileEating);
    expect(g.plants.single.hp, lessThan(300));
    run(g, 3.0); // 300 hp / 100 dps
    expect(g.plants, isEmpty);
    expect(z.state, ZombieState.walking);
    expect(g.takeEvents().whereType<PlantDied>(), isNotEmpty);
  });
  test('paused game does not advance', () {
    final g = newGame();
    g.pause();
    run(g, 5);
    expect(g.elapsed, 0);
    g.resume();
    run(g, 1);
    expect(g.elapsed, closeTo(1, 1e-6));
  });
}
