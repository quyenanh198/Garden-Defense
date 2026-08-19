import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

import '../core/test_helpers.dart';

LevelData loadLevel(int id) => LevelData.parse(
      File('assets/levels/level_${id.toString().padLeft(2, '0')}.json')
          .readAsStringSync(),
    );

/// Bot chơi tổng quát: thu mọi sun; tường cột 5 khi zombie tới gần; 1–3 cây
/// bắn cột 1–3 theo áp lực HP từng hàng; sunflower cột 0 khi rảnh.
GameState playBot(LevelData lvl, {double maxSeconds = 600, bool log = false}) {
  final g = newGame(lvl: lvl);
  final has = lvl.availablePlants.toSet();
  var t = 0.0;

  bool free(int r, int c) => !g.plants.any((p) => p.row == r && p.col == c);

  bool tryPlant(String id, int r, int c) {
    if (!has.contains(id)) return false;
    if (g.sun < Balance.plants[id]!.cost) return false;
    if (g.cooldownRemaining(id) > 0) return false;
    if (!free(r, c)) return false;
    g.selectPlant(id);
    final ok = g.tapCell(r, c) == PlantResult.ok;
    if (ok && log) {
      // ignore: avoid_print
      print('t=${t.toStringAsFixed(1)} plant $id r${r}c$c sunLeft=${g.sun}');
    }
    return ok;
  }

  while (g.phase == GamePhase.playing && t < maxSeconds) {
    run(g, 0.25);
    t += 0.25;
    for (final s in [...g.suns]) {
      g.collectSun(s.id);
    }
    var acted = true;
    while (acted && g.phase == GamePhase.playing) {
      acted = false;
      final nearest = <int, double>{};
      final rowHp = <int, double>{};
      for (final z in g.zombies.where((z) => z.isAlive)) {
        nearest[z.row] = min(nearest[z.row] ?? 99, z.col);
        rowHp[z.row] = (rowHp[z.row] ?? 0) + z.hp;
      }
      final ordered = nearest.keys.toList()
        ..sort((a, b) => nearest[a]!.compareTo(nearest[b]!));
      int shooterCount(int r) => g.plants
          .where((p) =>
              p.row == r &&
              (p.spec.action == PlantAction.shoot ||
                  p.spec.action == PlantAction.shootIce))
          .length;
      int wantFor(int r) {
        final hp = rowHp[r]!;
        return hp > 1000 ? 3 : hp > 250 ? 2 : 1;
      }

      // Hành động cần nhất cho một hàng: với zombie trâu sắp vào tầm cột 5,
      // tường rẻ hơn và mua ~40s — ưu tiên trước cả cây bắn của hàng đó.
      (String, int, int)? actionFor(int r) {
        final wallReady = has.contains('wallnut') &&
            g.cooldownRemaining('wallnut') == 0 &&
            free(r, 5);
        if (rowHp[r]! > 250 &&
            nearest[r]! > 5.5 &&
            nearest[r]! <= 7.5 &&
            wallReady &&
            !g.plants.any((p) => p.row == r && p.spec.id == 'wallnut')) {
          return ('wallnut', r, 5);
        }
        if (shooterCount(r) < wantFor(r)) {
          final id = shooterCount(r) >= 1 &&
                  has.contains('icepea') &&
                  g.sun >= Balance.plants['icepea']!.cost &&
                  g.cooldownRemaining('icepea') == 0
              ? 'icepea'
              : 'peashooter';
          for (final c in [1, 2, 3]) {
            if (free(r, c)) return (id, r, c);
          }
        }
        return null;
      }

      // Lấy hành động khẩn cấp nhất; chưa đủ sun thì giữ tiền chờ nó.
      (String, int, int)? next;
      for (final r in ordered) {
        next = actionFor(r);
        if (next != null) break;
      }
      if (next != null) {
        final (id, r, c) = next;
        if (tryPlant(id, r, c)) {
          acted = true;
          continue;
        }
        break; // thiếu sun/cooldown cho việc khẩn cấp nhất → không tiêu khác
      }
      final danger =
          nearest.values.isEmpty ? 99.0 : nearest.values.reduce(min);
      final sunflowers =
          g.plants.where((p) => p.spec.action == PlantAction.produceSun).length;
      if (sunflowers < 3 &&
          danger > 5 &&
          g.sun >= (g.zombies.any((z) => z.isAlive) ? 150 : 50)) {
        for (final r in const [0, 4, 1, 3, 2]) {
          if (free(r, 0)) {
            if (tryPlant('sunflower', r, 0)) acted = true;
            break;
          }
        }
      }
    }
  }
  return g;
}

/// Kịch bản "rảnh tay" của M5: chỉ peashooter hàng 2 — phải thua level khó.
GameState playNaive(LevelData lvl, {double maxSeconds = 600}) {
  final g = newGame(lvl: lvl);
  g.selectPlant('peashooter');
  g.tapCell(2, 0);
  var t = 0.0;
  var nextCol = 1;
  while (g.phase == GamePhase.playing && t < maxSeconds) {
    run(g, 0.25);
    t += 0.25;
    for (final s in [...g.suns]) {
      g.collectSun(s.id);
    }
    if (nextCol < 4 &&
        g.sun >= 100 &&
        g.cooldownRemaining('peashooter') == 0) {
      g.selectPlant('peashooter');
      if (g.tapCell(2, nextCol) == PlantResult.ok) nextCol++;
    }
  }
  return g;
}

void main() {
  test('levels 2-10 parse, validate, and follow the difficulty table', () {
    for (var id = 2; id <= 10; id++) {
      final lvl = loadLevel(id);
      expect(lvl.id, id, reason: 'level $id: id sai');
      expect(lvl.waves, isNotEmpty, reason: 'level $id: waves rỗng');
    }
    expect(loadLevel(2).availablePlants, contains('sunflower'));
    expect(loadLevel(3).availablePlants, contains('wallnut'));
    expect(loadLevel(5).waves.map((w) => w.zombie), contains('cone'));
    expect(loadLevel(6).waves.any((w) => w.hugeWave), isTrue);
    expect(loadLevel(7).availablePlants, contains('icepea'));
    expect(loadLevel(8).startingSun, lessThanOrEqualTo(50));
    expect(loadLevel(9).waves.map((w) => w.zombie), contains('bucket'));
    expect(
      loadLevel(10).waves.where((w) => w.zombie == 'bucket').length,
      greaterThanOrEqualTo(2),
    );
  });

  for (var id = 1; id <= 10; id++) {
    test('level $id is winnable by the bot', () {
      final g = playBot(loadLevel(id));
      expect(g.phase, GamePhase.won, reason: 'level $id: bot không thắng');
    });
  }

  for (final id in const [8, 9, 10]) {
    test('level $id defeats the naive single-row script', () {
      final g = playNaive(loadLevel(id));
      expect(g.phase, GamePhase.lost,
          reason: 'level $id: thắng quá dễ (kịch bản 1 hàng vẫn thắng)');
    });
  }
}
