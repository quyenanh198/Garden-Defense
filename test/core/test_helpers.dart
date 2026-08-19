import 'dart:math';

import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

LevelData level({
  int startingSun = 1000,
  List<String> plants = const ['peashooter', 'sunflower', 'wallnut', 'icepea'],
  bool skySuns = false,
  List<WaveEntry> waves = const [WaveEntry(time: 0, zombie: 'walker', row: 2)],
}) =>
    LevelData(
      id: 99,
      name: 'test',
      startingSun: startingSun,
      availablePlants: plants,
      skySuns: skySuns,
      waves: waves,
    );

GameState newGame({LevelData? lvl, int seed = 1}) =>
    GameState(level: lvl ?? level(), random: Random(seed));

/// Tick theo bước nhỏ để va chạm chính xác.
void run(GameState g, double seconds, {double step = 0.05}) {
  var t = 0.0;
  while (t < seconds - 1e-9) {
    final dt = (seconds - t) < step ? (seconds - t) : step;
    g.tick(dt);
    t += dt;
  }
}
