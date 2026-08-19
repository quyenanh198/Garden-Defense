import 'dart:math';

import '../config/balance.dart';
import '../data/level_data.dart';
import 'wave_spawner.dart';

/// Sinh đợt vô hạn cho chế độ Endless — spec trong docs/GAME_DESIGN.md:
/// nhịp co dần tới sàn, cỡ đợt tăng, huge wave mỗi [Balance.endlessHugeEvery]
/// đợt. Deterministic theo [Random] được truyền vào.
class EndlessSpawner implements Spawner {
  EndlessSpawner({required this.rows, required Random random})
      : _random = random;

  final int rows;
  final Random _random;

  /// Số đợt đã sinh (hiện trên HUD và màn kết quả).
  int wave = 0;

  double _nextTime = Balance.endlessFirstWaveTime;
  bool _warned = false;

  @override
  bool get allSpawned => false; // không bao giờ thắng

  bool _isHuge(int w) => w % Balance.endlessHugeEvery == 0;

  @override
  List<WaveEntry> dueWarnings(double elapsed) {
    if (_warned || !_isHuge(wave + 1)) return const [];
    if (elapsed < _nextTime - Balance.hugeWaveWarningLead) return const [];
    _warned = true;
    return const [WaveEntry(time: 0, zombie: 'walker', row: 0, hugeWave: true)];
  }

  @override
  List<WaveEntry> tick(double elapsed) {
    if (elapsed < _nextTime) return const [];
    wave++;
    _warned = false;
    var size = 1 + wave ~/ 5;
    if (_isHuge(wave)) size *= 2;
    if (size > rows * 2) size = rows * 2;
    final batch = [
      for (var i = 0; i < size; i++)
        WaveEntry(
          time: elapsed,
          zombie: _pickZombie(),
          row: _random.nextInt(rows),
        ),
    ];
    final interval =
        Balance.endlessBaseInterval - wave * Balance.endlessIntervalStep;
    _nextTime = elapsed + max(Balance.endlessMinInterval, interval);
    return batch;
  }

  String _pickZombie() {
    final roll = _random.nextDouble();
    if (wave >= Balance.endlessBucketFromWave &&
        roll < Balance.endlessBucketChance) {
      return 'bucket';
    }
    if (wave >= Balance.endlessConeFromWave &&
        roll < Balance.endlessBucketChance + Balance.endlessConeChance) {
      return 'cone';
    }
    return 'walker';
  }
}
