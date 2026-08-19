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
  static LevelData parse(String jsonText) {
    final Object? decoded;
    try {
      decoded = jsonDecode(jsonText);
    } on FormatException catch (e) {
      throw LevelFormatException(['invalid JSON: ${e.message}']);
    }
    if (decoded is! Map<String, dynamic>) {
      throw LevelFormatException(['top-level JSON must be an object']);
    }
    return fromJson(decoded);
  }

  static LevelData fromJson(Map<String, dynamic> json) {
    final level = fromJsonUnchecked(json);
    final errors = LevelValidator.validate(level);
    if (errors.isNotEmpty) throw LevelFormatException(errors);
    return level;
  }

  /// Chỉ đọc field (kiểm tra kiểu, không kiểm tra luật) — dùng cho
  /// validator test. Ném [LevelFormatException] nếu field thiếu/sai kiểu.
  static LevelData fromJsonUnchecked(Map<String, dynamic> json) {
    final rawWaves = _read<List<dynamic>>(json, 'waves', orElse: const []);
    final waves = <WaveEntry>[];
    for (var i = 0; i < rawWaves.length; i++) {
      final w = rawWaves[i];
      if (w is! Map<String, dynamic>) {
        throw LevelFormatException(['waves[$i]: expected object']);
      }
      waves.add(
        WaveEntry(
          time: _read<num>(w, 'time', ctx: 'waves[$i]').toDouble(),
          zombie: _read<String>(w, 'zombie', ctx: 'waves[$i]'),
          row: _read<int>(w, 'row', ctx: 'waves[$i]'),
          hugeWave: _read<bool>(w, 'hugeWave', ctx: 'waves[$i]', orElse: false),
        ),
      );
    }
    final rawPlants = _read<List<dynamic>>(json, 'availablePlants');
    final plants = <String>[];
    for (var i = 0; i < rawPlants.length; i++) {
      final p = rawPlants[i];
      if (p is! String) {
        throw LevelFormatException(['availablePlants[$i]: expected String']);
      }
      plants.add(p);
    }
    return LevelData(
      id: _read<int>(json, 'id'),
      name: _read<String>(json, 'name'),
      startingSun: _read<int>(json, 'startingSun'),
      availablePlants: plants,
      skySuns: _read<bool>(json, 'skySuns', orElse: true),
      waves: waves,
    );
  }

  static T _read<T>(
    Map<String, dynamic> json,
    String key, {
    String? ctx,
    T? orElse,
  }) {
    final v = json[key];
    if (v is T) return v;
    if (v == null && orElse != null) return orElse;
    final where = ctx == null ? key : '$ctx.$key';
    throw LevelFormatException([
      v == null
          ? '$where: missing required field ($T)'
          : '$where: expected $T, got ${v.runtimeType}',
    ]);
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
