import 'dart:math';

import '../config/balance.dart';
import '../data/level_data.dart';
import 'endless_spawner.dart';
import 'entities.dart';
import 'game_event.dart';
import 'wave_spawner.dart';

enum GamePhase { playing, paused, won, lost }

/// Toàn bộ luật chơi. Thuần Dart, deterministic theo dt và seed.
/// Lưới mặc định 5×9 (campaign); Endless truyền rows/cols riêng.
class GameState {
  GameState({
    required this.level,
    Random? random,
    this.rows = Balance.rows,
    this.cols = Balance.cols,
    this.endless = false,
  })  : _random = random ?? Random(),
        sun = level.startingSun {
    _spawner =
        endless ? EndlessSpawner(rows: rows, random: _random) : WaveSpawner(level.waves);
    for (final id in level.availablePlants) {
      _cooldowns[id] = 0;
    }
  }

  /// Cấu hình kinh tế cho chế độ Endless (waves sinh động, không từ JSON).
  static LevelData endlessConfig() => LevelData(
        id: 0,
        name: 'Endless',
        startingSun: Balance.endlessStartingSun,
        availablePlants: Balance.plants.keys.toList(),
        skySuns: true,
        waves: const [],
      );

  final LevelData level;
  final Random _random;
  final int rows;
  final int cols;
  final bool endless;
  late final Spawner _spawner;

  /// Số đợt Endless đã sinh (0 ở campaign).
  int get endlessWave {
    final s = _spawner;
    return s is EndlessSpawner ? s.wave : 0;
  }

  int sun;
  double elapsed = 0;
  GamePhase phase = GamePhase.playing;
  String? selectedPlantId;

  final List<Plant> plants = [];
  final List<Zombie> zombies = [];
  final List<Projectile> projectiles = [];
  final List<SunDrop> suns = [];

  final Map<String, double> _cooldowns = {};
  final List<GameEvent> _events = [];
  int _nextId = 1;
  double _skySunTimer = 0;

  double cooldownRemaining(String plantId) => _cooldowns[plantId] ?? 0;
  bool get allWavesSpawned => _spawner.allSpawned;

  /// Trả và xóa sự kiện đã tích lũy (view gọi mỗi frame).
  List<GameEvent> takeEvents() {
    final out = List<GameEvent>.unmodifiable(_events);
    _events.clear();
    return out;
  }

  // ---------- lệnh từ UI ----------

  void selectPlant(String? id) {
    if (id != null && !level.availablePlants.contains(id)) return;
    selectedPlantId = (selectedPlantId == id) ? null : id;
  }

  PlantResult tapCell(int row, int col) {
    if (phase != GamePhase.playing) return PlantResult.notPlaying;
    final result = _tryPlant(row, col);
    if (result != PlantResult.ok) _events.add(PlantRejected(result));
    return result;
  }

  PlantResult _tryPlant(int row, int col) {
    final id = selectedPlantId;
    if (id == null) {
      // Endless: tap cây đã trồng khi không chọn thẻ = nâng cấp.
      return endless ? _tryUpgrade(row, col) : PlantResult.noSelection;
    }
    if (!level.availablePlants.contains(id)) return PlantResult.notAvailable;
    final spec = Balance.plants[id]!;
    if (plants.any((p) => p.row == row && p.col == col)) {
      return PlantResult.occupied;
    }
    if (sun < spec.cost) return PlantResult.notEnoughSun;
    if (cooldownRemaining(id) > 0) return PlantResult.onCooldown;
    final plant = Plant(id: _nextId++, spec: spec, row: row, col: col);
    plants.add(plant);
    sun -= spec.cost;
    _cooldowns[id] = spec.plantCooldown;
    selectedPlantId = null;
    _events.add(PlantPlaced(plant.id, row, col));
    return PlantResult.ok;
  }

  PlantResult _tryUpgrade(int row, int col) {
    Plant? target;
    for (final p in plants) {
      if (p.row == row && p.col == col) {
        target = p;
        break;
      }
    }
    if (target == null) return PlantResult.noSelection;
    if (target.upgraded) return PlantResult.alreadyUpgraded;
    final cost = target.spec.cost * Balance.upgradeFactor;
    if (sun < cost) return PlantResult.notEnoughSun;
    sun -= cost;
    target.upgraded = true;
    target.hp += target.spec.hp; // +HP gốc cho mọi cây (docs/GAME_DESIGN.md)
    _events.add(PlantUpgraded(target.id));
    return PlantResult.ok;
  }

  bool collectSun(int sunId) {
    if (phase != GamePhase.playing) return false;
    final i = suns.indexWhere((s) => s.id == sunId);
    if (i < 0) return false;
    final s = suns.removeAt(i);
    sun += s.value;
    _events.add(SunCollected(s.id, s.value));
    return true;
  }

  void pause() {
    if (phase == GamePhase.playing) phase = GamePhase.paused;
  }

  void resume() {
    if (phase == GamePhase.paused) phase = GamePhase.playing;
  }

  // ---------- vòng lặp ----------

  void tick(double dt) {
    if (phase != GamePhase.playing) return;
    elapsed += dt;
    _spawnWaves();
    _plantsAct(dt);
    _moveProjectiles(dt);
    _moveZombies(dt);
    _skySun(dt);
    _ageSuns(dt);
    _tickCooldowns(dt);
    _checkEnd();
  }

  void _spawnWaves() {
    for (final _ in _spawner.dueWarnings(elapsed)) {
      _events.add(const HugeWaveWarning());
    }
    for (final w in _spawner.tick(elapsed)) {
      final z = Zombie(
        id: _nextId++,
        spec: Balance.zombies[w.zombie]!,
        row: w.row,
        col: cols.toDouble(),
      );
      zombies.add(z);
      _events.add(ZombieSpawned(z.id));
    }
  }

  void _plantsAct(double dt) {
    for (final p in plants) {
      switch (p.spec.action) {
        case PlantAction.none:
          break;
        case PlantAction.produceSun:
          p.actionTimer += dt;
          if (p.actionTimer >= Balance.sunflowerInterval) {
            p.actionTimer -= Balance.sunflowerInterval;
            // Sun rơi ngay cạnh cây (docs/GAME_DESIGN.md); sát mép phải thì
            // rơi sang trái.
            final beside = p.col + 1 < cols ? p.col + 1 : p.col - 1;
            _spawnSun(
              p.row,
              beside.toDouble(),
              Balance.sunflowerValue * (p.upgraded ? Balance.upgradeFactor : 1),
              fromCol: p.col.toDouble(),
            );
          }
        case PlantAction.shoot:
        case PlantAction.shootIce:
          final hasTarget = zombies.any(
            (z) => z.isAlive && z.row == p.row && z.col > p.col,
          );
          // Nạp đạn cả khi không có mục tiêu (tối đa 1 phát sẵn sàng):
          // có mục tiêu thì bắn ngay, nhưng nhịp giữa hai phát không bao giờ
          // nhanh hơn fireInterval dù mục tiêu vào/ra tầm liên tục.
          p.actionTimer += dt;
          if (p.actionTimer > Balance.fireInterval) {
            p.actionTimer = Balance.fireInterval;
          }
          if (!hasTarget) break;
          if (p.actionTimer >= Balance.fireInterval) {
            p.actionTimer -= Balance.fireInterval;
            projectiles.add(
              Projectile(
                id: _nextId++,
                row: p.row,
                col: p.col + 0.4,
                damage: Balance.peaDamage *
                    (p.upgraded ? Balance.upgradeFactor : 1),
                slows: p.spec.action == PlantAction.shootIce,
              ),
            );
          }
      }
    }
  }

  void _moveProjectiles(double dt) {
    final dead = <Projectile>[];
    for (final pr in projectiles) {
      // Quét cả đoạn đường đi trong frame: dt lớn (máy giật) không được
      // làm đạn nhảy qua zombie mà không trúng.
      final from = pr.col;
      pr.col += Balance.peaSpeed * dt;
      Zombie? hit;
      for (final z in zombies) {
        if (!z.isAlive || z.row != pr.row) continue;
        if (z.col >= from - Balance.projectileHitRadius &&
            z.col <= pr.col + Balance.projectileHitRadius) {
          if (hit == null || z.col < hit.col) hit = z;
        }
      }
      if (hit != null) {
        hit.hp -= pr.damage;
        if (pr.slows) hit.slowRemaining = Balance.iceSlowDuration;
        _events.add(ZombieHit(hit.id));
        dead.add(pr);
        if (hit.hp <= 0) {
          hit.state = ZombieState.dying;
          _events.add(ZombieDied(hit.id));
        }
      } else if (pr.col > cols + 0.5) {
        dead.add(pr);
      }
    }
    projectiles.removeWhere(dead.contains);
  }

  void _moveZombies(double dt) {
    final removeZ = <Zombie>[];
    for (final z in zombies) {
      if (z.slowRemaining > 0) z.slowRemaining -= dt;
      switch (z.state) {
        case ZombieState.dying:
          z.dyingRemaining -= dt;
          if (z.dyingRemaining <= 0) removeZ.add(z);
        case ZombieState.walking:
        case ZombieState.eating:
          final target = _plantInFront(z);
          if (target == null) {
            z.state = ZombieState.walking;
            final speed = Balance.zombieCellsPerSecond *
                (z.isSlowed ? Balance.iceSlowFactor : 1);
            z.col -= speed * dt;
          } else {
            z.state = ZombieState.eating;
            // Bị làm chậm thì ăn cũng chậm (docs/GAME_DESIGN.md: chậm 50%).
            target.hp -= Balance.zombieBiteDps *
                (z.isSlowed ? Balance.iceSlowFactor : 1) *
                dt;
            if (target.hp <= 0) {
              plants.remove(target);
              _events.add(PlantDied(target.id));
            }
          }
      }
    }
    zombies.removeWhere(removeZ.contains);
  }

  Plant? _plantInFront(Zombie z) {
    for (final p in plants) {
      if (p.row != z.row) continue;
      if (z.col <= p.col + 0.5 && z.col > p.col - 0.5) return p;
    }
    return null;
  }

  void _skySun(double dt) {
    if (!level.skySuns) return;
    _skySunTimer += dt;
    if (_skySunTimer >= Balance.skySunInterval) {
      _skySunTimer -= Balance.skySunInterval;
      _spawnSun(
        _random.nextInt(rows),
        _random.nextInt(cols).toDouble(),
        Balance.skySunValue,
      );
    }
  }

  void _spawnSun(int row, double col, int value, {double? fromCol}) {
    final s = SunDrop(
      id: _nextId++,
      row: row,
      col: col,
      value: value,
      fromCol: fromCol,
    );
    suns.add(s);
    _events.add(SunSpawned(s.id));
  }

  void _ageSuns(double dt) {
    final expired = <SunDrop>[];
    for (final s in suns) {
      s.age += dt;
      if (s.age >= Balance.sunLifetime) expired.add(s);
    }
    for (final s in expired) {
      suns.remove(s);
      _events.add(SunExpired(s.id));
    }
  }

  void _tickCooldowns(double dt) {
    for (final id in _cooldowns.keys) {
      final v = _cooldowns[id]! - dt;
      _cooldowns[id] = v < 0 ? 0 : v;
    }
  }

  void _checkEnd() {
    if (zombies.any((z) => z.isAlive && z.col < 0)) {
      phase = GamePhase.lost;
      _events.add(const GameLost());
      return;
    }
    if (_spawner.allSpawned && zombies.isEmpty) {
      phase = GamePhase.won;
      _events.add(const GameWon());
    }
  }
}
