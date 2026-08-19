import 'package:shared_preferences/shared_preferences.dart';

/// Tiến độ người chơi — spec trong docs/GAME_DESIGN.md ("Tiến độ & mở khóa").
/// Hai khóa, cả hai chỉ tăng: highestUnlocked (mặc định 1), endlessBest.
class ProgressStore {
  ProgressStore(this._prefs);
  final SharedPreferences _prefs;

  static const _kUnlocked = 'highestUnlocked';
  static const _kEndlessBest = 'endlessBest';

  static Future<ProgressStore> load() async =>
      ProgressStore(await SharedPreferences.getInstance());

  int get highestUnlocked => _prefs.getInt(_kUnlocked) ?? 1;
  int get endlessBest => _prefs.getInt(_kEndlessBest) ?? 0;

  Future<void> unlock(int level) async {
    if (level > highestUnlocked) await _prefs.setInt(_kUnlocked, level);
  }

  Future<void> recordEndless(int waves) async {
    if (waves > endlessBest) await _prefs.setInt(_kEndlessBest, waves);
  }
}
