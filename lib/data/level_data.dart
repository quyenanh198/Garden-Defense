import 'dart:convert';

import '../config/balance.dart';

class LevelFormatException implements Exception {
  LevelFormatException(this.errors);
  final List<String> errors;
  @override
  String toString() => 'LevelFormatException: ${errors.join('; ')}';
}

class WaveEntry {
  const WaveEntry({
    required this.time,
    required this.zombie,
    required this.row,
    this.hugeWave = false,
  });
  final double time;
  final String zombie;
  final int row;
  final bool hugeWave;
}

class LevelData {
  const LevelData({
    required this.id,
    required this.name,
    required this.startingSun,
    required this.availablePlants,
    required this.skySuns,
    required this.waves,
  });

  final int id;
  final String name;
  final int startingSun;
  final List<String> availablePlants;
  final bool skySuns;
  final List<WaveEntry> waves;

  /// Parse + validate. Ném [LevelFormatException] nếu sai schema.
  static LevelData parse(String jsonText) =>
      fromJson(jsonDecode(jsonText) as Map<String, dynamic>);

  static LevelData fromJson(Map<String, dynamic> json) {
    final level = fromJsonUnchecked(json);
    final errors = LevelValidator.validate(level);
    if (errors.isNotEmpty) throw LevelFormatException(errors);
    return level;
  }

  /// Chỉ đọc field, không kiểm tra luật — dùng cho validator test.
  static LevelData fromJsonUnchecked(Map<String, dynamic> json) {
    final waves = (json['waves'] as List<dynamic>? ?? const [])
        .map((w) => w as Map<String, dynamic>)
        .map(
          (w) => WaveEntry(
            time: (w['time'] as num).toDouble(),
            zombie: w['zombie'] as String,
            row: w['row'] as int,
            hugeWave: w['hugeWave'] as bool? ?? false,
          ),
        )
        .toList();
    return LevelData(
      id: json['id'] as int,
      name: json['name'] as String,
      startingSun: json['startingSun'] as int,
      availablePlants:
          (json['availablePlants'] as List<dynamic>).cast<String>(),
      skySuns: json['skySuns'] as bool? ?? true,
      waves: waves,
    );
  }
}

class LevelValidator {
  LevelValidator._();

  static List<String> validate(LevelData level) {
    final errors = <String>[];
    for (final p in level.availablePlants) {
      if (!Balance.plants.containsKey(p)) errors.add('unknown plant id "$p"');
    }
    if (level.waves.isEmpty) errors.add('waves must not be empty');
    var lastTime = double.negativeInfinity;
    for (var i = 0; i < level.waves.length; i++) {
      final w = level.waves[i];
      if (!Balance.zombies.containsKey(w.zombie)) {
        errors.add('waves[$i]: unknown zombie id "${w.zombie}"');
      }
      if (w.row < 0 || w.row >= Balance.rows) {
        errors.add('waves[$i]: row ${w.row} out of 0..${Balance.rows - 1}');
      }
      if (w.time < lastTime) errors.add('waves[$i]: time ${w.time} decreases');
      lastTime = w.time;
    }
    return errors;
  }
}
