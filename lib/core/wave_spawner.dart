import '../config/balance.dart';
import '../data/level_data.dart';

/// Nguồn zombie cho GameState: theo kịch bản JSON (campaign) hoặc sinh
/// vô hạn (Endless).
abstract class Spawner {
  /// Entry đến hạn spawn, mỗi entry trả đúng một lần.
  List<WaveEntry> tick(double elapsed);

  /// Cảnh báo huge wave đến hạn (trước [Balance.hugeWaveWarningLead] giây).
  List<WaveEntry> dueWarnings(double elapsed);

  /// true khi không còn gì để spawn (điều kiện thắng campaign).
  bool get allSpawned;
}

class WaveSpawner implements Spawner {
  WaveSpawner(this.waves);
  final List<WaveEntry> waves;
  int _next = 0;
  int _nextWarning = 0;

  @override
  bool get allSpawned => _next >= waves.length;

  /// Entry có time <= elapsed, mỗi entry trả đúng một lần.
  @override
  List<WaveEntry> tick(double elapsed) {
    final due = <WaveEntry>[];
    while (_next < waves.length && waves[_next].time <= elapsed) {
      due.add(waves[_next]);
      _next++;
    }
    return due;
  }

  /// hugeWave entry đến hạn cảnh báo (time - lead <= elapsed), mỗi entry một lần.
  @override
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
