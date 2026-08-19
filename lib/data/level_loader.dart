import 'package:flutter/services.dart';

import 'level_data.dart';

/// Đọc assets/levels/level_XX.json. Tách khỏi level_data.dart để core test
/// không cần Flutter binding.
class LevelLoader {
  LevelLoader._();

  static String pathFor(int id) =>
      'assets/levels/level_${id.toString().padLeft(2, '0')}.json';

  static Future<LevelData> load(int id) async =>
      LevelData.parse(await rootBundle.loadString(pathFor(id)));
}
