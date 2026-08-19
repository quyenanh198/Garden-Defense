import '../config/balance.dart';
import '../data/level_data.dart';

class WaveSpawner {
  WaveSpawner(this.waves);
  final List<WaveEntry> waves;
  int _next = 0;
  int _nextWarning = 0;

  bool get allSpawned => _next >= waves.length;

  /// Entry có time <= elapsed, mỗi entry trả đúng một lần.
  List<WaveEntry> tick(double elapsed) {
    final due = <WaveEntry>[];
    while (_next < waves.length && waves[_next].time <= elapsed) {
      due.add(waves[_next]);
      _next++;
    }
    return due;
  }

  /// hugeWave entry đến hạn cảnh báo (time - lead <= elapsed), mỗi entry một lần.
  List<WaveEntry> dueWarnings(double elapsed) {
    final due = <WaveEntry>[];
    while (_nextWarning < waves.length &&
        waves[_nextWarning].time - Balance.hugeWaveWarningLead <= elapsed) {
      if (waves[_nextWarning].hugeWave) due.add(waves[_nextWarning]);
      _nextWarning++;
    }
    return due;
  }
}
