# Garden Defense M1–M5 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Dựng vertical slice của Garden Defense: lưới 5×9, trồng cây, zombie đi/ăn, bắn đạn, sun economy, level từ JSON, thắng/thua — chạy được trên Windows desktop, logic có unit test.

**Architecture:** Sim core thuần Dart (`lib/core/`) chạy `GameState.tick(dt)` deterministic; Flame (`lib/game/`) chỉ render và chuyển tap thành lệnh qua `SyncLayer`; HUD/menu là Flutter widget overlay (`lib/ui/`). Level và balance là data (`assets/levels/*.json`, `lib/config/balance.dart`). Spec: `docs/superpowers/specs/2026-08-19-garden-defense-m1-m5-design.md`.

**Tech Stack:** Flutter 3.32.1 / Dart 3.8.1 (máy hiện có), Flame `^1.35.1` (bản cao nhất hỗ trợ Dart 3.8; docs ghi ^1.37 cần Flutter ≥ 3.41 — ghi chú trong README), `shared_preferences` (chưa dùng đến M7), `flutter_lints ^5.0.0`. Không thêm dependency khác.

## Global Constraints

- Không dùng tên/hình/âm thanh của Plants vs Zombies. Tên project `garden_defense`.
- Grid là xương sống: `lib/core/` không import Flame/Flutter, không có pixel; chỉ tầng `lib/game/` đổi `(row, col)` → pixel.
- Số liệu cân bằng chỉ nằm trong `lib/config/balance.dart` (mirror `docs/GAME_DESIGN.md`).
- Level chỉ là JSON theo `docs/LEVEL_FORMAT.md`; parser reject ID lạ, `row` ngoài 0–4, `waves` rỗng, `time` giảm.
- UI (menu, HUD, overlay) là Flutter widget; chỉ sun và thanh máu vẽ bằng Flame.
- Camera Flame `withFixedResolution(1280, 720)`; grid vùng `x 200–1240`, `y 100–700`; HUD dải `y 0–100`.
- Sprite qua `assets/images/manifest.json`; thiếu file → placeholder, không crash. Không tự tải asset (người dùng tải; ghi nguồn + license vào `assets/CREDITS.md`).
- Zombie đúng 3 state `walking / eating / dying`.
- Kết thúc mỗi task: `flutter analyze` sạch, `flutter test` pass, commit.
- Sau mỗi milestone: cập nhật `docs/HANDOFF.md` (trạng thái, cách chạy, việc còn lại) và commit.
- Dev/verify tay trên Windows (`flutter run -d windows`); verify APK để sau khi cài Android SDK.

---

## File map

| File | Trách nhiệm |
|---|---|
| `lib/main.dart` | entry; `MaterialApp` → `MenuScreen` → `GameScreen` |
| `lib/config/balance.dart` | `Balance`, `PlantSpec`, `ZombieSpec`, `PlantAction` — mọi số liệu |
| `lib/data/level_data.dart` | `LevelData`, `WaveEntry`, `LevelValidator`, `LevelFormatException` (không Flutter) |
| `lib/data/level_loader.dart` | `LevelLoader.load(id)` đọc asset qua `rootBundle` |
| `lib/core/entities.dart` | `Plant`, `Zombie`, `Projectile`, `SunDrop`, `ZombieState` |
| `lib/core/game_event.dart` | sealed `GameEvent` + subclasses, `PlantResult` |
| `lib/core/wave_spawner.dart` | `WaveSpawner` |
| `lib/core/game_state.dart` | `GameState`, `GamePhase` — toàn bộ luật chơi |
| `lib/game/garden_game.dart` | `GardenGame extends FlameGame` — tick + sync + notifier |
| `lib/game/grid_board.dart` | `GridBoard` — vẽ lưới, `cellToPixel/pixelToCell`, nhận tap |
| `lib/game/sprite_registry.dart` | `SpriteRegistry` — manifest → `Sprite`/`SpriteAnimation` hoặc null |
| `lib/game/sync_layer.dart` | `SyncLayer` — đối chiếu state ↔ component |
| `lib/game/components/plant_view.dart` | `PlantView` |
| `lib/game/components/zombie_view.dart` | `ZombieView` (+ thanh máu, hit flash) |
| `lib/game/components/projectile_view.dart` | `ProjectileView` |
| `lib/game/components/sun_view.dart` | `SunView` (tap) |
| `lib/game/components/placeholder.dart` | `PlaceholderPainter` — khối màu bo góc + chữ |
| `lib/ui/theme.dart` | màu, font, kích thước (design system) |
| `lib/ui/widgets/clay_button.dart` | `ClayButton` dùng chung |
| `lib/ui/game_screen.dart` | `GameWidget` + overlayBuilderMap |
| `lib/ui/hud/hud_bar.dart` | `HudBar`: ví sun, hàng `PlantCard`, pause |
| `lib/ui/hud/plant_card.dart` | `PlantCard` |
| `lib/ui/overlays/huge_wave_banner.dart` | banner |
| `lib/ui/overlays/result_overlay.dart` | thắng/thua |
| `lib/ui/overlays/pause_overlay.dart` | pause |
| `lib/ui/menu_screen.dart` | menu tối giản |
| `assets/images/manifest.json` | id → sprite file |
| `assets/CREDITS.md`, `docs/ASSETS.md` | nguồn asset, hướng dẫn tải |
| `docs/HANDOFF.md` | session handoff |
| `test/config/balance_test.dart`, `test/data/level_data_test.dart`, `test/core/test_helpers.dart`, `test/core/game_state_m2_test.dart` … `_m5_test.dart` | test |

---

# M1 — Khung + lưới

### Task 1: Scaffold Flutter project (android + windows)

**Files:**
- Create: scaffold do `flutter create` sinh (`android/`, `windows/`, `analysis_options.yaml`)
- Modify: `pubspec.yaml`, `.gitignore`, `lib/main.dart`

**Interfaces:** Produces `lib/main.dart` chạy được (màn hình trống "Garden Defense").

- [ ] **Step 1: Sinh scaffold**

```bash
cd "C:/Users/Admin/Documents/Quyen/Garden Defense"
flutter create . --project-name garden_defense --platforms=android,windows --org dev.quyen
```
`flutter create .` ghi đè `pubspec.yaml`, `README.md`, `.gitignore`, `lib/main.dart`, tạo `test/widget_test.dart`. Sau lệnh: `git checkout -- pubspec.yaml README.md`; giữ `.gitignore` mới; xóa `test/widget_test.dart`.

- [ ] **Step 2: Sửa `pubspec.yaml`** — `flame: ^1.35.1` (Dart 3.8.1 không resolve được ^1.37). Giữ phần còn lại như tarball.

- [ ] **Step 3: `lib/main.dart` tối giản**

```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const GardenDefenseApp());
}

class GardenDefenseApp extends StatelessWidget {
  const GardenDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Garden Defense',
      home: Scaffold(body: Center(child: Text('Garden Defense'))),
    );
  }
}
```

- [ ] **Step 4:** `flutter pub get && flutter analyze && flutter test` → pub get OK (flame 1.35.x), analyze "No issues found!", test không có test nào/pass.
- [ ] **Step 5: Commit** `git add -A && git commit -m "chore: scaffold Flutter project (android, windows)"`

### Task 2: Cập nhật docs theo spec §9

**Files:** Modify `docs/ARCHITECTURE.md`, `docs/ROADMAP.md`, `README.md`

- [ ] **Step 1: ARCHITECTURE.md** — thêm sau "Tổng quan tầng":

```markdown
## Sim core tách khỏi Flame (quyết định 2026-08-19)

`lib/core/` chứa toàn bộ luật chơi (`GameState.tick(dt)`, entity, `WaveSpawner`) bằng Dart thuần — không import Flame/Flutter, không có pixel. `lib/game/` là lớp view: `GardenGame` gọi `state.tick(dt)` mỗi frame rồi `SyncLayer` đối chiếu entity trong state với component Flame (thêm/cập nhật/xóa). Input Flame chuyển thành lệnh `state.selectPlant / tapCell / collectSun`. Nhờ vậy tiêu chí ROADMAP kiểm tra được bằng `flutter test` mà không cần Flame.

Camera: `CameraComponent.withFixedResolution(1280, 720)`; lưới chiếm `x 200–1240`, `y 100–700`; HUD (Flutter overlay) phủ dải `y 0–100`. Sprite tra qua `assets/images/manifest.json`; thiếu file → placeholder, không crash.
```
Cập nhật cây thư mục (thêm `core/`, `game/sync_layer.dart`, `game/sprite_registry.dart`, `ui/overlays/`, `ui/widgets/`). Bảng quyết định thêm dòng: `Sim core thuần Dart, Flame chỉ render | test logic không cần Flame; pixel chỉ ở render | thêm một lớp sync state↔component`.

- [ ] **Step 2: ROADMAP.md** — thêm dưới tiêu đề:

```markdown
> Dev target hiện tại: Windows desktop (`flutter run -d windows`) vì máy dev chưa có Android SDK. Verify trên APK thực hiện ở M5 (thử) và bắt buộc ở M7 sau khi cài Android SDK command-line tools.
```

- [ ] **Step 3: README.md** — quick start: `flutter create . --project-name garden_defense --platforms=android,windows`, `flutter run -d windows`; ghi chú flame ^1.35.1 vì Flutter 3.32.
- [ ] **Step 4: Commit** `git commit -am "docs: sim core layer, windows dev target"`

### Task 3: Balance + LevelData (data thuần Dart) + tests

**Files:** Create `lib/config/balance.dart`, `lib/data/level_data.dart`, `test/config/balance_test.dart`, `test/data/level_data_test.dart`

**Interfaces (Produces):**
- `Balance.plants: Map<String, PlantSpec>`, `Balance.zombies: Map<String, ZombieSpec>`, hằng số (xem code).
- `LevelData.fromJson(Map)`, `LevelData.fromJsonUnchecked(Map)`, `LevelData.parse(String)`, `LevelValidator.validate(LevelData) → List<String>`, `LevelFormatException`.

- [ ] **Step 1: Test balance**

```dart
// test/config/balance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';

void main() {
  test('plant and zombie ids match GAME_DESIGN.md', () {
    expect(Balance.plants.keys, containsAll(['sunflower', 'peashooter', 'wallnut', 'icepea']));
    expect(Balance.zombies.keys, containsAll(['walker', 'cone', 'bucket']));
  });
  test('peashooter DPS ~14.3 and walker dies in ~14s', () {
    final dps = Balance.peaDamage / Balance.fireInterval;
    expect(dps, closeTo(14.3, 0.1));
    expect(Balance.zombies['walker']!.hp / dps, closeTo(14, 0.5));
  });
  test('costs and hp mirror docs', () {
    expect(Balance.plants['sunflower']!.cost, 50);
    expect(Balance.plants['peashooter']!.cost, 100);
    expect(Balance.plants['wallnut']!.hp, 4000);
    expect(Balance.plants['icepea']!.cost, 175);
    expect(Balance.zombies['cone']!.hp, 560);
    expect(Balance.zombies['bucket']!.hp, 1300);
  });
}
```

- [ ] **Step 2:** `flutter test test/config` → FAIL (import không tồn tại).

- [ ] **Step 3: `lib/config/balance.dart`**

```dart
/// Mọi số liệu cân bằng. Mirror của docs/GAME_DESIGN.md — nếu lệch, docs thắng.
enum PlantAction { produceSun, shoot, shootIce, none }

class PlantSpec {
  const PlantSpec({
    required this.id,
    required this.name,
    required this.cost,
    required this.hp,
    required this.plantCooldown,
    required this.action,
  });
  final String id;
  final String name;
  final int cost;
  final double hp;
  final double plantCooldown; // giây
  final PlantAction action;
}

class ZombieSpec {
  const ZombieSpec({required this.id, required this.name, required this.hp});
  final String id;
  final String name;
  final double hp;
}

class Balance {
  Balance._();

  static const int rows = 5;
  static const int cols = 9;

  static const double zombieCellsPerSecond = 1 / 4.7;
  static const double zombieBiteDps = 100;
  static const double zombieDyingDuration = 0.5;

  static const int skySunValue = 25;
  static const double skySunInterval = 10;
  static const double sunLifetime = 8;
  static const int sunflowerValue = 25;
  static const double sunflowerInterval = 24;

  static const double peaDamage = 20;
  static const double peaSpeed = 6; // ô / giây
  static const double fireInterval = 1.4;
  static const double iceSlowFactor = 0.5;
  static const double iceSlowDuration = 3;
  static const double projectileHitRadius = 0.3;

  static const double hugeWaveWarningLead = 3;

  static const Map<String, PlantSpec> plants = {
    'sunflower': PlantSpec(id: 'sunflower', name: 'Hoa mặt trời', cost: 50, hp: 300, plantCooldown: 7.5, action: PlantAction.produceSun),
    'peashooter': PlantSpec(id: 'peashooter', name: 'Cây bắn đậu', cost: 100, hp: 300, plantCooldown: 7.5, action: PlantAction.shoot),
    'wallnut': PlantSpec(id: 'wallnut', name: 'Quả óc chó', cost: 50, hp: 4000, plantCooldown: 30, action: PlantAction.none),
    'icepea': PlantSpec(id: 'icepea', name: 'Đậu băng', cost: 175, hp: 300, plantCooldown: 7.5, action: PlantAction.shootIce),
  };

  static const Map<String, ZombieSpec> zombies = {
    'walker': ZombieSpec(id: 'walker', name: 'Zombie thường', hp: 200),
    'cone': ZombieSpec(id: 'cone', name: 'Zombie nón', hp: 560),
    'bucket': ZombieSpec(id: 'bucket', name: 'Zombie xô', hp: 1300),
  };
}
```

- [ ] **Step 4: Test level_data**

```dart
// test/data/level_data_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/level_data.dart';

Map<String, dynamic> valid() => {
      'id': 1, 'name': 'T', 'startingSun': 50,
      'availablePlants': ['peashooter'],
      'waves': [
        {'time': 20, 'zombie': 'walker', 'row': 2},
        {'time': 30, 'zombie': 'walker', 'row': 0, 'hugeWave': true},
      ],
    };

void main() {
  test('parses level_01.json from assets', () {
    final level = LevelData.parse(File('assets/levels/level_01.json').readAsStringSync());
    expect(level.id, 1);
    expect(level.startingSun, 150);
    expect(level.availablePlants, ['peashooter']);
    expect(level.skySuns, isTrue);
    expect(level.waves.length, 6);
    expect(level.waves.last.time, 112);
    expect(level.waves[4].hugeWave, isTrue);
    expect(level.waves[0].hugeWave, isFalse);
  });
  test('defaults skySuns=true hugeWave=false', () {
    final level = LevelData.fromJson(valid());
    expect(level.skySuns, isTrue);
    expect(level.waves[0].hugeWave, isFalse);
    expect(level.waves[1].hugeWave, isTrue);
  });
  test('rejects unknown plant id', () {
    final j = valid()..['availablePlants'] = ['peashooter', 'cactus'];
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects unknown zombie id', () {
    final j = valid();
    (j['waves'] as List)[0]['zombie'] = 'dragon';
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects row out of range', () {
    final j = valid();
    (j['waves'] as List)[0]['row'] = 5;
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects empty waves', () {
    final j = valid()..['waves'] = [];
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
  });
  test('rejects decreasing time, allows equal', () {
    final j = valid();
    (j['waves'] as List)[1]['time'] = 10;
    expect(() => LevelData.fromJson(j), throwsA(isA<LevelFormatException>()));
    final k = valid();
    (k['waves'] as List)[1]['time'] = 20;
    expect(LevelData.fromJson(k).waves.length, 2);
  });
  test('validator lists all errors', () {
    final j = valid()
      ..['availablePlants'] = ['x']
      ..['waves'] = [{'time': 5, 'zombie': 'y', 'row': 9}];
    final errors = LevelValidator.validate(LevelData.fromJsonUnchecked(j));
    expect(errors.length, 3);
  });
  test('parse handles JSON string', () {
    expect(LevelData.parse(jsonEncode(valid())).id, 1);
  });
}
```

- [ ] **Step 5: `lib/data/level_data.dart`**

```dart
import 'dart:convert';

import '../config/balance.dart';

class LevelFormatException implements Exception {
  LevelFormatException(this.errors);
  final List<String> errors;
  @override
  String toString() => 'LevelFormatException: ${errors.join('; ')}';
}

class WaveEntry {
  const WaveEntry({required this.time, required this.zombie, required this.row, this.hugeWave = false});
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
  static LevelData parse(String jsonText) => fromJson(jsonDecode(jsonText) as Map<String, dynamic>);

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
        .map((w) => WaveEntry(
              time: (w['time'] as num).toDouble(),
              zombie: w['zombie'] as String,
              row: w['row'] as int,
              hugeWave: w['hugeWave'] as bool? ?? false,
            ))
        .toList();
    return LevelData(
      id: json['id'] as int,
      name: json['name'] as String,
      startingSun: json['startingSun'] as int,
      availablePlants: (json['availablePlants'] as List<dynamic>).cast<String>(),
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
    double lastTime = double.negativeInfinity;
    for (var i = 0; i < level.waves.length; i++) {
      final w = level.waves[i];
      if (!Balance.zombies.containsKey(w.zombie)) errors.add('waves[$i]: unknown zombie id "${w.zombie}"');
      if (w.row < 0 || w.row >= Balance.rows) errors.add('waves[$i]: row ${w.row} out of 0..${Balance.rows - 1}');
      if (w.time < lastTime) errors.add('waves[$i]: time ${w.time} decreases');
      lastTime = w.time;
    }
    return errors;
  }
}
```

- [ ] **Step 6:** `flutter test` → PASS; `flutter analyze` sạch.
- [ ] **Step 7: Commit** `git add -A && git commit -m "feat: balance constants and level data parser with validator"`

### Task 4: GridBoard + GardenGame (Flame) — tap in ra (row, col)

**Files:** Create `lib/game/grid_board.dart`, `lib/game/garden_game.dart`, `lib/ui/game_screen.dart`; Modify `lib/main.dart`

**Interfaces (Produces):**
- `GridBoard extends PositionComponent with TapCallbacks`: `static const originX=200, originY=100, cellW=1040/9, cellH=600/5`; `static Vector2 cellToPixel(int row, double col)`; `static ({int row, int col})? pixelToCell(Vector2 world)`; `void Function(int row, int col)? onCellTap`.
- `GardenGame extends FlameGame` (constructor không tham số ở M1; Task 6 đổi).

- [ ] **Step 1: `lib/game/grid_board.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../config/balance.dart';

/// Nơi duy nhất biết kích thước ô theo pixel (không gian ảo 1280×720).
class GridBoard extends PositionComponent with TapCallbacks {
  GridBoard() : super(position: Vector2(originX, originY), size: Vector2(gridW, gridH));

  static const double originX = 200;
  static const double originY = 100;
  static const double gridW = 1040;
  static const double gridH = 600;
  static const double cellW = gridW / Balance.cols;
  static const double cellH = gridH / Balance.rows;

  void Function(int row, int col)? onCellTap;

  final _light = Paint()..color = const Color(0xFF6ABE45);
  final _dark = Paint()..color = const Color(0xFF5AAE3A);

  /// Tâm ô (row, col) theo world coords. col có thể là số thực (zombie/đạn).
  static Vector2 cellToPixel(int row, double col) =>
      Vector2(originX + (col + 0.5) * cellW, originY + (row + 0.5) * cellH);

  /// Ô chứa điểm world; null nếu ngoài lưới.
  static ({int row, int col})? pixelToCell(Vector2 world) {
    final c = ((world.x - originX) / cellW).floor();
    final r = ((world.y - originY) / cellH).floor();
    if (r < 0 || r >= Balance.rows || c < 0 || c >= Balance.cols) return null;
    return (row: r, col: c);
  }

  @override
  void render(Canvas canvas) {
    for (var r = 0; r < Balance.rows; r++) {
      for (var c = 0; c < Balance.cols; c++) {
        canvas.drawRect(Rect.fromLTWH(c * cellW, r * cellH, cellW, cellH), (r + c).isEven ? _light : _dark);
      }
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    final cell = pixelToCell(event.localPosition + position);
    if (cell != null) onCellTap?.call(cell.row, cell.col);
  }
}
```

- [ ] **Step 2: `lib/game/garden_game.dart`**

```dart
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'grid_board.dart';

class GardenGame extends FlameGame {
  GardenGame() : super(camera: CameraComponent.withFixedResolution(width: 1280, height: 720));

  late final GridBoard board;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    board = GridBoard()..onCellTap = (r, c) => debugPrint('tap cell (row=$r, col=$c)');
    world.add(board);
  }
}
```

- [ ] **Step 3: `lib/ui/game_screen.dart`**

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/garden_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GardenGame game = GardenGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14532D),
      body: GameWidget(game: game),
    );
  }
}
```

- [ ] **Step 4: `lib/main.dart`** — `home: const GameScreen()`; `Future<void> main() async { WidgetsFlutterBinding.ensureInitialized(); await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]); runApp(...); }`.
- [ ] **Step 5: Verify M1** `flutter analyze` sạch; `flutter run -d windows` → lưới 5×9; tap ô → console `tap cell (row=.., col=..)`.
- [ ] **Step 6: Commit** `git add -A && git commit -m "feat(m1): grid board with fixed-resolution camera and cell tap"`
- [ ] **Step 7: HANDOFF** — tạo `docs/HANDOFF.md` (mẫu cuối plan), commit `docs: handoff after M1`.

---

# M2 — Trồng cây + zombie đi

### Task 5: Sim core — entities, events, spawner, GameState (walk/eat/lose) + tests

**Files:** Create `lib/core/entities.dart`, `lib/core/game_event.dart`, `lib/core/wave_spawner.dart`, `lib/core/game_state.dart`, `test/core/test_helpers.dart`, `test/core/game_state_m2_test.dart`

**Interfaces (Produces):**
- `GameState({required LevelData level, Random? random})`; `void tick(double dt)`; `PlantResult tapCell(int row, int col)`; `void selectPlant(String? id)`; `bool collectSun(int sunId)`; `void pause()/resume()`; `List<GameEvent> takeEvents()`; `sun`, `plants`, `zombies`, `projectiles`, `suns`, `phase`, `elapsed`, `selectedPlantId`, `double cooldownRemaining(String plantId)`, `bool allWavesSpawned`, `level`.
- `WaveSpawner(List<WaveEntry>)`: `List<WaveEntry> tick(double elapsed)`; `bool allSpawned`; `List<WaveEntry> dueWarnings(double elapsed)`.

- [ ] **Step 1: `lib/core/entities.dart`**

```dart
import '../config/balance.dart';

enum ZombieState { walking, eating, dying }

class Plant {
  Plant({required this.id, required this.spec, required this.row, required this.col}) : hp = spec.hp;
  final int id;
  final PlantSpec spec;
  final int row;
  final int col;
  double hp;
  double actionTimer = 0; // đếm tới lần hành động kế
}

class Zombie {
  Zombie({required this.id, required this.spec, required this.row, this.col = 9.0}) : hp = spec.hp;
  final int id;
  final ZombieSpec spec;
  final int row;
  double col;
  double hp;
  ZombieState state = ZombieState.walking;
  double slowRemaining = 0;
  double dyingRemaining = Balance.zombieDyingDuration;
  bool get isAlive => state != ZombieState.dying;
  bool get isSlowed => slowRemaining > 0;
}

class Projectile {
  Projectile({required this.id, required this.row, required this.col, required this.damage, this.slows = false});
  final int id;
  final int row;
  double col;
  final double damage;
  final bool slows;
}

class SunDrop {
  SunDrop({required this.id, required this.row, required this.col, required this.value});
  final int id;
  final int row;
  final double col;
  final int value;
  double age = 0;
}
```

- [ ] **Step 2: `lib/core/game_event.dart`**

```dart
enum PlantResult { ok, noSelection, occupied, notEnoughSun, onCooldown, notAvailable }

sealed class GameEvent {
  const GameEvent();
}

class PlantPlaced extends GameEvent {
  const PlantPlaced(this.plantId, this.row, this.col);
  final int plantId;
  final int row;
  final int col;
}

class PlantRejected extends GameEvent {
  const PlantRejected(this.reason);
  final PlantResult reason;
}

class PlantDied extends GameEvent {
  const PlantDied(this.plantId);
  final int plantId;
}

class ZombieSpawned extends GameEvent {
  const ZombieSpawned(this.zombieId);
  final int zombieId;
}

class ZombieHit extends GameEvent {
  const ZombieHit(this.zombieId);
  final int zombieId;
}

class ZombieDied extends GameEvent {
  const ZombieDied(this.zombieId);
  final int zombieId;
}

class SunSpawned extends GameEvent {
  const SunSpawned(this.sunId);
  final int sunId;
}

class SunCollected extends GameEvent {
  const SunCollected(this.sunId, this.value);
  final int sunId;
  final int value;
}

class SunExpired extends GameEvent {
  const SunExpired(this.sunId);
  final int sunId;
}

class HugeWaveWarning extends GameEvent {
  const HugeWaveWarning();
}

class GameWon extends GameEvent {
  const GameWon();
}

class GameLost extends GameEvent {
  const GameLost();
}
```

- [ ] **Step 3: `lib/core/wave_spawner.dart`**

```dart
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
    while (_nextWarning < waves.length && waves[_nextWarning].time - Balance.hugeWaveWarningLead <= elapsed) {
      if (waves[_nextWarning].hugeWave) due.add(waves[_nextWarning]);
      _nextWarning++;
    }
    return due;
  }
}
```

- [ ] **Step 4: `lib/core/game_state.dart`** (đầy đủ cho M2–M5; test M3/M4/M5 khóa từng hành vi)

```dart
import 'dart:math';

import '../config/balance.dart';
import '../data/level_data.dart';
import 'entities.dart';
import 'game_event.dart';
import 'wave_spawner.dart';

enum GamePhase { playing, paused, won, lost }

/// Toàn bộ luật chơi. Thuần Dart, deterministic theo dt và seed.
class GameState {
  GameState({required this.level, Random? random})
      : _random = random ?? Random(),
        _spawner = WaveSpawner(level.waves),
        sun = level.startingSun {
    for (final id in level.availablePlants) {
      _cooldowns[id] = 0;
    }
  }

  final LevelData level;
  final Random _random;
  final WaveSpawner _spawner;

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
    final result = _tryPlant(row, col);
    if (result != PlantResult.ok) _events.add(PlantRejected(result));
    return result;
  }

  PlantResult _tryPlant(int row, int col) {
    final id = selectedPlantId;
    if (id == null) return PlantResult.noSelection;
    if (!level.availablePlants.contains(id)) return PlantResult.notAvailable;
    final spec = Balance.plants[id]!;
    if (plants.any((p) => p.row == row && p.col == col)) return PlantResult.occupied;
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

  bool collectSun(int sunId) {
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
      final z = Zombie(id: _nextId++, spec: Balance.zombies[w.zombie]!, row: w.row);
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
            _spawnSun(p.row, p.col.toDouble(), Balance.sunflowerValue);
          }
        case PlantAction.shoot:
        case PlantAction.shootIce:
          final hasTarget = zombies.any((z) => z.isAlive && z.row == p.row && z.col > p.col);
          if (!hasTarget) {
            p.actionTimer = Balance.fireInterval; // sẵn sàng bắn ngay khi có mục tiêu
            break;
          }
          p.actionTimer += dt;
          if (p.actionTimer >= Balance.fireInterval) {
            p.actionTimer -= Balance.fireInterval;
            projectiles.add(Projectile(
              id: _nextId++,
              row: p.row,
              col: p.col + 0.4,
              damage: Balance.peaDamage,
              slows: p.spec.action == PlantAction.shootIce,
            ));
          }
      }
    }
  }

  void _moveProjectiles(double dt) {
    final dead = <Projectile>[];
    for (final pr in projectiles) {
      pr.col += Balance.peaSpeed * dt;
      if (pr.col > Balance.cols + 0.5) {
        dead.add(pr);
        continue;
      }
      Zombie? hit;
      for (final z in zombies) {
        if (!z.isAlive || z.row != pr.row) continue;
        if ((z.col - pr.col).abs() < Balance.projectileHitRadius) {
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
            final speed = Balance.zombieCellsPerSecond * (z.isSlowed ? Balance.iceSlowFactor : 1);
            z.col -= speed * dt;
          } else {
            z.state = ZombieState.eating;
            target.hp -= Balance.zombieBiteDps * dt;
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
      _spawnSun(_random.nextInt(Balance.rows), _random.nextInt(Balance.cols).toDouble(), Balance.skySunValue);
    }
  }

  void _spawnSun(int row, double col, int value) {
    final s = SunDrop(id: _nextId++, row: row, col: col, value: value);
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
```

- [ ] **Step 5: `test/core/test_helpers.dart`**

```dart
import 'dart:math';

import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

LevelData level({
  int startingSun = 1000,
  List<String> plants = const ['peashooter', 'sunflower', 'wallnut', 'icepea'],
  bool skySuns = false,
  List<WaveEntry> waves = const [WaveEntry(time: 0, zombie: 'walker', row: 2)],
}) =>
    LevelData(id: 99, name: 'test', startingSun: startingSun, availablePlants: plants, skySuns: skySuns, waves: waves);

GameState newGame({LevelData? lvl, int seed = 1}) => GameState(level: lvl ?? level(), random: Random(seed));

/// Tick theo bước nhỏ để va chạm chính xác.
void run(GameState g, double seconds, {double step = 0.05}) {
  var t = 0.0;
  while (t < seconds - 1e-9) {
    final dt = (seconds - t) < step ? (seconds - t) : step;
    g.tick(dt);
    t += dt;
  }
}
```

- [ ] **Step 6: `test/core/game_state_m2_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';

import 'test_helpers.dart';

void main() {
  test('zombie spawns at right edge on wave time and walks left', () {
    final g = newGame();
    g.tick(0.01);
    expect(g.zombies.length, 1);
    expect(g.zombies.first.col, closeTo(9.0, 0.01));
    run(g, 4.7);
    expect(g.zombies.first.col, closeTo(8.0, 0.05));
  });
  test('zombie reaching col < 0 loses the game', () {
    final g = newGame();
    run(g, 9 * 4.7 + 1);
    expect(g.phase, GamePhase.lost);
    expect(g.takeEvents().whereType<GameLost>(), isNotEmpty);
  });
  test('placing a plant on empty cell with selection', () {
    final g = newGame();
    expect(g.tapCell(2, 4), PlantResult.noSelection);
    g.selectPlant('wallnut');
    expect(g.tapCell(2, 4), PlantResult.ok);
    expect(g.plants.single.col, 4);
    expect(g.selectedPlantId, isNull);
    g.selectPlant('wallnut');
    expect(g.tapCell(2, 4), PlantResult.occupied);
  });
  test('zombie eats plant, plant dies, zombie walks again', () {
    final g = newGame();
    g.selectPlant('sunflower');
    g.tapCell(2, 8);
    run(g, 0.6 * 4.7); // 9.0 -> ~8.4: đã qua mép phải ô 8 (8.5)
    final z = g.zombies.single;
    expect(z.state, ZombieState.eating);
    final colWhileEating = z.col;
    run(g, 1.0);
    expect(z.col, colWhileEating);
    expect(g.plants.single.hp, lessThan(300));
    run(g, 3.0); // 300 hp / 100 dps
    expect(g.plants, isEmpty);
    expect(z.state, ZombieState.walking);
    expect(g.takeEvents().whereType<PlantDied>(), isNotEmpty);
  });
  test('paused game does not advance', () {
    final g = newGame();
    g.pause();
    run(g, 5);
    expect(g.elapsed, 0);
    g.resume();
    run(g, 1);
    expect(g.elapsed, closeTo(1, 1e-6));
  });
}
```

- [ ] **Step 7:** `flutter test test/core` → PASS. `flutter analyze` sạch.
- [ ] **Step 8: Commit** `git add -A && git commit -m "feat(m2): sim core - game state, entities, wave spawner, eating"`

### Task 6: Render M2 — SpriteRegistry, placeholder, SyncLayer, PlantView/ZombieView, overlay Thua

**Files:** Create `lib/game/sprite_registry.dart`, `lib/game/components/placeholder.dart`, `lib/game/components/plant_view.dart`, `lib/game/components/zombie_view.dart`, `lib/game/sync_layer.dart`, `assets/images/manifest.json`, `lib/ui/theme.dart`, `lib/ui/widgets/clay_button.dart`, `lib/ui/overlays/result_overlay.dart`; Modify `lib/game/garden_game.dart`, `lib/ui/game_screen.dart`, `lib/main.dart`

**Interfaces (Produces):**
- `GardenGame({required LevelData level, Random? random})`; `GameState state`; `ValueNotifier<int> frame`; `ValueNotifier<List<GameEvent>> events`; `SpriteRegistry sprites`.
- `SpriteRegistry.load()`; `Sprite? sprite(String id)`; `SpriteAnimation? animation(String id)`.
- `SyncLayer(GardenGame game)`; `void sync()`; `ZombieView? zombieView(int id)`.

- [ ] **Step 1: `assets/images/manifest.json`**

```json
{
  "_comment": "id -> {file, frameSize:[w,h]?, frames?, stepTime?}. Thiếu id hoặc file => placeholder.",
  "sprites": {}
}
```

- [ ] **Step 2: `lib/game/sprite_registry.dart`**

```dart
import 'dart:convert';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/services.dart';

/// Đọc assets/images/manifest.json; trả null nếu id/file thiếu (view tự vẽ placeholder).
class SpriteRegistry {
  final Map<String, Sprite> _sprites = {};
  final Map<String, SpriteAnimation> _animations = {};

  Future<void> load() async {
    Map<String, dynamic> manifest;
    try {
      manifest = jsonDecode(await rootBundle.loadString('assets/images/manifest.json')) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    final entries = manifest['sprites'] as Map<String, dynamic>? ?? {};
    for (final e in entries.entries) {
      final cfg = e.value as Map<String, dynamic>;
      final file = cfg['file'] as String;
      try {
        final image = await Flame.images.load(file);
        final frameSize = (cfg['frameSize'] as List<dynamic>?)?.cast<num>();
        final frames = cfg['frames'] as int? ?? 1;
        if (frameSize != null && frames > 1) {
          _animations[e.key] = SpriteAnimation.fromFrameData(
            image,
            SpriteAnimationData.sequenced(
              amount: frames,
              stepTime: (cfg['stepTime'] as num? ?? 0.15).toDouble(),
              textureSize: Vector2(frameSize[0].toDouble(), frameSize[1].toDouble()),
            ),
          );
        } else {
          _sprites[e.key] = Sprite(image);
        }
      } catch (_) {
        // thiếu file: bỏ qua, view dùng placeholder
      }
    }
  }

  Sprite? sprite(String id) => _sprites[id];
  SpriteAnimation? animation(String id) => _animations[id];
}
```

- [ ] **Step 3: `lib/game/components/placeholder.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart' show Colors, FontWeight, TextStyle;

/// Khối màu bo góc + nhãn, dùng khi thiếu sprite.
class PlaceholderPainter {
  PlaceholderPainter(this.color, this.label);
  final Color color;
  final String label;

  late final _fill = Paint()..color = color;
  late final _stroke = Paint()
    ..color = const Color(0xFF1F2937)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;
  late final _text = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  );

  void paint(Canvas canvas, Vector2 size) {
    final r = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(16));
    canvas.drawRRect(r, _fill);
    canvas.drawRRect(r, _stroke);
    _text.render(canvas, label, Vector2(size.x / 2, size.y / 2), anchor: Anchor.center);
  }
}

const Map<String, Color> placeholderColors = {
  'sunflower': Color(0xFFF59E0B),
  'peashooter': Color(0xFF16A34A),
  'wallnut': Color(0xFF92400E),
  'icepea': Color(0xFF38BDF8),
  'walker': Color(0xFF6B7280),
  'cone': Color(0xFFEA580C),
  'bucket': Color(0xFF475569),
};
```

- [ ] **Step 4: `lib/game/components/plant_view.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';
import 'placeholder.dart';

class PlantView extends PositionComponent {
  PlantView(this.plant, SpriteRegistry sprites)
      : super(size: Vector2(GridBoard.cellW * 0.8, GridBoard.cellH * 0.8), anchor: Anchor.center) {
    position = GridBoard.cellToPixel(plant.row, plant.col.toDouble());
    final s = sprites.sprite(plant.spec.id);
    if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    } else {
      _placeholder = PlaceholderPainter(placeholderColors[plant.spec.id]!, plant.spec.id);
    }
    priority = 10 + plant.row;
  }

  final Plant plant;
  PlaceholderPainter? _placeholder;
  final _hpBg = Paint()..color = const Color(0xFF7F1D1D);
  final _hpFg = Paint()..color = const Color(0xFF22C55E);

  @override
  void render(Canvas canvas) {
    _placeholder?.paint(canvas, size);
    if (plant.spec.hp >= 1000) {
      // thanh máu chỉ cho wallnut
      final w = size.x * (plant.hp / plant.spec.hp).clamp(0.0, 1.0);
      canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6), _hpBg);
      canvas.drawRect(Rect.fromLTWH(0, -10, w, 6), _hpFg);
    }
  }
}
```

- [ ] **Step 5: `lib/game/components/zombie_view.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';

import '../../config/balance.dart';
import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';
import 'placeholder.dart';

class ZombieView extends PositionComponent {
  ZombieView(this.zombie, SpriteRegistry sprites)
      : super(size: Vector2(GridBoard.cellW * 0.7, GridBoard.cellH * 0.95), anchor: Anchor.bottomCenter) {
    final anim = sprites.animation('${zombie.spec.id}_walk');
    final s = sprites.sprite(zombie.spec.id);
    if (anim != null) {
      add(SpriteAnimationComponent(animation: anim, size: size));
    } else if (s != null) {
      add(SpriteComponent(sprite: s, size: size));
    } else {
      _placeholder = PlaceholderPainter(placeholderColors[zombie.spec.id]!, zombie.spec.id);
    }
    priority = 20 + zombie.row;
    syncFromState();
  }

  final Zombie zombie;
  PlaceholderPainter? _placeholder;
  double _flash = 0;
  final _hpBg = Paint()..color = const Color(0xFF7F1D1D);
  final _hpFg = Paint()..color = const Color(0xFF22C55E);
  final _slowTint = Paint()..color = const Color(0x5538BDF8);
  final _flashPaint = Paint()..color = const Color(0x99FFFFFF);

  void hitFlash() => _flash = 0.12;

  void syncFromState() {
    final center = GridBoard.cellToPixel(zombie.row, zombie.col);
    position = Vector2(center.x, center.y + GridBoard.cellH * 0.45);
    if (zombie.state == ZombieState.dying) {
      final t = (zombie.dyingRemaining / Balance.zombieDyingDuration).clamp(0.0, 1.0);
      scale = Vector2(t, t);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_flash > 0) _flash -= dt;
  }

  @override
  void render(Canvas canvas) {
    _placeholder?.paint(canvas, size);
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.x, size.y), const Radius.circular(16));
    if (zombie.isSlowed) canvas.drawRRect(rr, _slowTint);
    if (_flash > 0) canvas.drawRRect(rr, _flashPaint);
    final w = size.x * (zombie.hp / zombie.spec.hp).clamp(0.0, 1.0);
    canvas.drawRect(Rect.fromLTWH(0, -10, size.x, 6), _hpBg);
    canvas.drawRect(Rect.fromLTWH(0, -10, w, 6), _hpFg);
  }
}
```

- [ ] **Step 6: `lib/game/sync_layer.dart`** (projectile/sun thêm ở Task 9/11)

```dart
import 'package:flame/components.dart';

import '../core/entities.dart';
import 'components/plant_view.dart';
import 'components/zombie_view.dart';
import 'garden_game.dart';

/// Đối chiếu entity trong GameState với component Flame. Không có logic gameplay.
class SyncLayer {
  SyncLayer(this.game);
  final GardenGame game;

  final Map<int, PlantView> _plants = {};
  final Map<int, ZombieView> _zombies = {};

  ZombieView? zombieView(int id) => _zombies[id];

  void sync() {
    _syncList<Plant, PlantView>(game.state.plants, _plants, (p) => p.id,
        create: (p) => PlantView(p, game.sprites), update: (v) {});
    _syncList<Zombie, ZombieView>(game.state.zombies, _zombies, (z) => z.id,
        create: (z) => ZombieView(z, game.sprites), update: (v) => v.syncFromState());
  }

  void _syncList<E, V extends Component>(
    List<E> entities,
    Map<int, V> views,
    int Function(E) idOf, {
    required V Function(E) create,
    required void Function(V) update,
  }) {
    final live = <int>{};
    for (final e in entities) {
      final id = idOf(e);
      live.add(id);
      var v = views[id];
      if (v == null) {
        v = create(e);
        views[id] = v;
        game.world.add(v);
      }
      update(v);
    }
    final gone = views.keys.where((id) => !live.contains(id)).toList();
    for (final id in gone) {
      views.remove(id)!.removeFromParent();
    }
  }
}
```

- [ ] **Step 7: `lib/game/garden_game.dart`** (thay toàn bộ)

```dart
import 'dart:math';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../core/game_event.dart';
import '../core/game_state.dart';
import '../data/level_data.dart';
import 'grid_board.dart';
import 'sprite_registry.dart';
import 'sync_layer.dart';

class GardenGame extends FlameGame {
  GardenGame({required LevelData level, Random? random})
      : state = GameState(level: level, random: random),
        super(camera: CameraComponent.withFixedResolution(width: 1280, height: 720));

  final GameState state;
  final SpriteRegistry sprites = SpriteRegistry();
  late final GridBoard board;
  late final SyncLayer _sync;

  /// Tăng mỗi frame; HUD lắng nghe để rebuild.
  final ValueNotifier<int> frame = ValueNotifier(0);

  /// Sự kiện của frame vừa rồi cho UI (banner, nháy ví...).
  final ValueNotifier<List<GameEvent>> events = ValueNotifier(const []);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await sprites.load();
    board = GridBoard()..onCellTap = (r, c) => state.tapCell(r, c);
    world.add(board);
    _sync = SyncLayer(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    state.tick(dt);
    _sync.sync();
    final evs = state.takeEvents();
    if (evs.isNotEmpty) {
      for (final e in evs) {
        if (e is ZombieHit) _sync.zombieView(e.zombieId)?.hitFlash();
        if (e is HugeWaveWarning && !overlays.isActive('hugeWave')) overlays.add('hugeWave');
      }
      events.value = evs;
    }
    frame.value++;
    if ((state.phase == GamePhase.lost || state.phase == GamePhase.won) && !overlays.isActive('result')) {
      overlays.add('result');
    }
  }
}
```

- [ ] **Step 8: `lib/ui/theme.dart`**

```dart
import 'package:flutter/material.dart';

/// Design system: Claymorphism nhẹ, palette xanh cỏ + vàng nắng.
class GdColors {
  GdColors._();
  static const primary = Color(0xFF15803D);
  static const primaryDark = Color(0xFF166534);
  static const sun = Color(0xFFF59E0B);
  static const sunText = Color(0xFFFBBF24);
  static const menuBg = Color(0xFFF0FDF4);
  static const hudChip = Color(0xD90F172A);
  static const hudBar = Color(0x8014532D);
  static const danger = Color(0xFFDC2626);
  static const ink = Color(0xFF0F172A);
  static const card = Colors.white;
}

class GdText {
  GdText._();
  static const heading = TextStyle(fontFamily: 'Fredoka', fontWeight: FontWeight.w700, color: GdColors.ink);
  static const body = TextStyle(fontFamily: 'Nunito', color: GdColors.ink);
}

class GdShape {
  GdShape._();
  static const radius = 16.0;
  static const radiusLg = 24.0;
  static const border = 3.0;
  static const borderLg = 4.0;
  static const minTouch = 44.0;
  static const clayShadow = [
    BoxShadow(color: Color(0x33000000), offset: Offset(0, 6), blurRadius: 0),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 10), blurRadius: 16),
  ];
}
```

- [ ] **Step 9: `lib/ui/widgets/clay_button.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme.dart';

class ClayButton extends StatelessWidget {
  const ClayButton({super.key, required this.label, required this.onTap, this.primary = false});
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? GdColors.primary : GdColors.card,
      borderRadius: BorderRadius.circular(GdShape.radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GdShape.radius),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GdShape.radius),
            border: Border.all(color: GdColors.primaryDark, width: GdShape.border),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: GdText.body.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: primary ? Colors.white : GdColors.ink)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 10: `lib/ui/overlays/result_overlay.dart`**

```dart
import 'package:flutter/material.dart';

import '../../core/game_state.dart';
import '../theme.dart';
import '../widgets/clay_button.dart';

class ResultOverlay extends StatelessWidget {
  const ResultOverlay({super.key, required this.phase, required this.onRetry, required this.onContinue});
  final GamePhase phase;
  final VoidCallback onRetry;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final won = phase == GamePhase.won;
    return Container(
      color: const Color(0x99000000),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: GdColors.card,
          borderRadius: BorderRadius.circular(GdShape.radiusLg),
          border: Border.all(color: won ? GdColors.primaryDark : GdColors.danger, width: GdShape.borderLg),
          boxShadow: GdShape.clayShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? 'Thắng!' : 'Thua…',
                style: GdText.heading.copyWith(fontSize: 40, color: won ? GdColors.primaryDark : GdColors.danger)),
            const SizedBox(height: 20),
            Row(mainAxisSize: MainAxisSize.min, children: [
              ClayButton(label: 'Chơi lại', onTap: onRetry),
              if (won) ...[const SizedBox(width: 16), ClayButton(label: 'Tiếp tục', onTap: onContinue, primary: true)],
            ]),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 11: `lib/ui/game_screen.dart`** — nhận `LevelData`; M2 tạm chọn sẵn plant để tap trồng được:

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/level_data.dart';
import '../game/garden_game.dart';
import 'overlays/result_overlay.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.level});
  final LevelData level;
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GardenGame game;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    game = GardenGame(level: widget.level);
    game.state.selectPlant(widget.level.availablePlants.first); // M2 tạm; Task 11 thay bằng HUD
  }

  void _retry() => setState(_newGame);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14532D),
      body: GameWidget<GardenGame>(
        key: ObjectKey(game),
        game: game,
        overlayBuilderMap: {
          'result': (context, g) => ResultOverlay(
                phase: g.state.phase,
                onRetry: _retry,
                onContinue: () => Navigator.of(context).maybePop(),
              ),
        },
      ),
    );
  }
}
```

- [ ] **Step 12: `lib/main.dart`** — debug level M2 (sunflower để nhìn rõ "ăn", vì peashooter đã bắn trong core nhưng chưa có ProjectileView):

```dart
home: GameScreen(
  level: const LevelData(
    id: 0, name: 'debug', startingSun: 1000, availablePlants: ['sunflower'], skySuns: false,
    waves: [WaveEntry(time: 3, zombie: 'walker', row: 2), WaveEntry(time: 8, zombie: 'walker', row: 0)],
  ),
),
```

- [ ] **Step 13: Verify M2** `flutter analyze` sạch, `flutter test` pass, `flutter run -d windows`: zombie xuất hiện mép phải sau 3 s, đi trái; tap ô trồng placeholder; zombie dừng 3 s rồi đi tiếp, plant biến mất; chạm mép trái → overlay "Thua…"; "Chơi lại" reset.
- [ ] **Step 14: Commit** `git add -A && git commit -m "feat(m2): flame views, sync layer, placeholder sprites, lose overlay"`

### Task 7: Asset research + manifest + CREDITS (không tải)

**Files:** Create `assets/CREDITS.md`, `docs/ASSETS.md`; Modify `assets/images/manifest.json`

- [ ] **Step 1:** WebSearch/WebFetch xác minh pack CC0 (Kenney Toon Characters 1 — zombie; Kenney Platformer Pack Redux / Foliage — cây; Kenney UI Pack; Kenney Particle Pack). Ghi `docs/ASSETS.md`: bảng `id → file gợi ý trong pack, URL trang pack, license, kích thước khuyến nghị (plant 128×128, zombie 96×128, đạn 32×32, sun 64×64)`, cách đặt tên `assets/images/<id>.png` (sheet: `<id>_walk.png` ngang N frame), cách khai báo `manifest.json`.
- [ ] **Step 2:** `manifest.json` điền entry cho mọi id (`sunflower`, `peashooter`, `wallnut`, `icepea`, `walker`, `walker_walk`, `cone`, `bucket`, `pea`, `icepea_shot`, `sun`) trỏ tới file dự kiến — file chưa có → registry bỏ qua → placeholder.
- [ ] **Step 3:** `assets/CREDITS.md`: "Chưa có asset ngoài. Khi thêm: pack, tác giả, URL, license, file dùng."
- [ ] **Step 4:** Commit `docs: asset manifest and CC0 sourcing guide`.

---

# M3 — Bắn + va chạm

### Task 8: Tests M3 (khóa hành vi bắn trong core)

**Files:** Create `test/core/game_state_m3_test.dart`

- [ ] **Step 1: Test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

void main() {
  test('peashooter only fires when a zombie is in its row', () {
    final g = newGame(lvl: level(waves: const [WaveEntry(time: 1, zombie: 'walker', row: 0)]));
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 5);
    expect(g.projectiles, isEmpty);
    run(g, 7.5);
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.ok);
    run(g, 0.5);
    expect(g.projectiles, isNotEmpty);
    expect(g.projectiles.every((p) => p.row == 0), isTrue);
  });
  test('10 peas (200 dmg) kill a walker; hit and death events fire', () {
    final g = newGame(lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]));
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    var hits = 0;
    var died = false;
    var t = 0.0;
    while (t < 40 && !died) {
      run(g, 0.5);
      t += 0.5;
      for (final e in g.takeEvents()) {
        if (e is ZombieHit) hits++;
        if (e is ZombieDied) died = true;
      }
    }
    expect(died, isTrue);
    expect(hits, 10);
    expect(t, lessThan(9 * 4.7));
    run(g, Balance.zombieDyingDuration + 0.1);
    expect(g.zombies, isEmpty);
  });
  test('pea does not hit zombie in another row', () {
    final g = newGame(lvl: level(waves: const [
      WaveEntry(time: 0, zombie: 'walker', row: 1),
      WaveEntry(time: 0, zombie: 'walker', row: 2),
    ]));
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 6);
    final row1 = g.zombies.firstWhere((z) => z.row == 1);
    final row2 = g.zombies.firstWhere((z) => z.row == 2);
    expect(row1.hp, 200);
    expect(row2.hp, lessThan(200));
  });
  test('pea hits the front-most zombie only', () {
    final g = newGame(lvl: level(waves: const [
      WaveEntry(time: 0, zombie: 'walker', row: 2),
      WaveEntry(time: 4, zombie: 'walker', row: 2),
    ]));
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 8);
    final sorted = [...g.zombies]..sort((a, b) => a.col.compareTo(b.col));
    expect(sorted.first.hp, lessThan(200));
    expect(sorted.last.hp, 200);
    expect(sorted.first.state, isNot(ZombieState.dying));
  });
}
```

- [ ] **Step 2:** `flutter test test/core/game_state_m3_test.dart`. FAIL do logic → sửa `game_state.dart`.
- [ ] **Step 3: Commit** `git add -A && git commit -m "test(m3): projectile firing and row-limited hits"`

### Task 9: ProjectileView

**Files:** Create `lib/game/components/projectile_view.dart`; Modify `lib/game/sync_layer.dart`, `lib/main.dart`

- [ ] **Step 1: `projectile_view.dart`**

```dart
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';

class ProjectileView extends PositionComponent {
  ProjectileView(this.projectile, SpriteRegistry sprites) : super(size: Vector2.all(24), anchor: Anchor.center) {
    final s = sprites.sprite(projectile.slows ? 'icepea_shot' : 'pea');
    if (s != null) add(SpriteComponent(sprite: s, size: size));
    _hasSprite = s != null;
    _paint = Paint()..color = projectile.slows ? const Color(0xFF38BDF8) : const Color(0xFF22C55E);
    priority = 30;
    syncFromState();
  }

  final Projectile projectile;
  late final Paint _paint;
  late final bool _hasSprite;

  void syncFromState() {
    final c = GridBoard.cellToPixel(projectile.row, projectile.col);
    position = Vector2(c.x, c.y - GridBoard.cellH * 0.15);
  }

  @override
  void render(Canvas canvas) {
    if (!_hasSprite) canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _paint);
  }
}
```

- [ ] **Step 2: `sync_layer.dart`** thêm `final Map<int, ProjectileView> _projectiles = {};` và trong `sync()`: `_syncList<Projectile, ProjectileView>(game.state.projectiles, _projectiles, (p) => p.id, create: (p) => ProjectileView(p, game.sprites), update: (v) => v.syncFromState());`
- [ ] **Step 3: `main.dart`** debug level: `availablePlants: ['peashooter']`, waves hàng 2 t=3/15/30 + hàng 0 t=10.
- [ ] **Step 4: Verify M3** Windows: đạn bay, zombie nháy trắng khi trúng, chết co lại; đạn không trúng hàng khác. `analyze` + `test` sạch.
- [ ] **Step 5: Commit** `feat(m3): projectile view`; cập nhật `docs/HANDOFF.md`, commit `docs: handoff after M3`.

---

# M4 — Sun economy + thanh chọn plant

### Task 10: Tests M4

**Files:** Create `test/core/game_state_m4_test.dart`

- [ ] **Step 1: Test**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

const _far = [WaveEntry(time: 999, zombie: 'walker', row: 0)];

void main() {
  test('not enough sun rejects and emits PlantRejected', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.notEnoughSun);
    expect(g.takeEvents().whereType<PlantRejected>().single.reason, PlantResult.notEnoughSun);
    expect(g.sun, 50);
  });
  test('planting deducts exact cost and starts cooldown', () {
    final g = newGame(lvl: level(startingSun: 200, waves: _far));
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 0), PlantResult.ok);
    expect(g.sun, 100);
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 1), PlantResult.onCooldown);
    run(g, Balance.plants['peashooter']!.plantCooldown + 0.01);
    g.selectPlant('peashooter');
    expect(g.tapCell(0, 1), PlantResult.ok);
    expect(g.sun, 0);
  });
  test('sky sun spawns every 10s and expires after 8s', () {
    final g = newGame(lvl: level(skySuns: true, waves: _far));
    run(g, 10.05);
    expect(g.suns.length, 1);
    run(g, 7.9);
    expect(g.suns.length, 1);
    run(g, 0.2);
    expect(g.suns, isEmpty);
    expect(g.takeEvents().whereType<SunExpired>(), isNotEmpty);
  });
  test('collecting sun adds 25', () {
    final g = newGame(lvl: level(startingSun: 0, skySuns: true, waves: _far));
    run(g, 10.05);
    final id = g.suns.single.id;
    expect(g.collectSun(id), isTrue);
    expect(g.sun, 25);
    expect(g.suns, isEmpty);
    expect(g.collectSun(id), isFalse);
  });
  test('sunflower produces 25 sun every 24s', () {
    final g = newGame(lvl: level(startingSun: 50, waves: _far));
    g.selectPlant('sunflower');
    g.tapCell(1, 1);
    run(g, 23.9);
    expect(g.suns, isEmpty);
    run(g, 0.2);
    expect(g.suns.single.value, 25);
    expect(g.suns.single.row, 1);
  });
  test('wallnut blocks a walker for a long time', () {
    final g = newGame(lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]));
    g.selectPlant('wallnut');
    g.tapCell(2, 4);
    run(g, 4.7 * 4.5 + 30);
    expect(g.plants.length, 1);
    expect(g.plants.single.hp, lessThan(4000));
    expect(g.phase, isNot(GamePhase.lost));
  });
  test('icepea slows zombie by 50%', () {
    final g = newGame(lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2)]));
    g.selectPlant('icepea');
    g.tapCell(2, 0);
    var slowedSeen = false;
    for (var i = 0; i < 60; i++) {
      run(g, 0.25);
      if (g.zombies.isNotEmpty && g.zombies.first.isSlowed) {
        slowedSeen = true;
        break;
      }
    }
    expect(slowedSeen, isTrue);
    final z = g.zombies.first;
    final c0 = z.col;
    run(g, 1.0); // đạn kế tới sau 1.4 s nên 1 s này bị chậm suốt
    expect(c0 - z.col, closeTo(Balance.zombieCellsPerSecond * 0.5, 0.02));
  });
  test('cannot select plant not available in level', () {
    final g = newGame(lvl: level(plants: const ['peashooter'], waves: _far));
    g.selectPlant('icepea');
    expect(g.selectedPlantId, isNull);
  });
}
```

- [ ] **Step 2:** Chạy, sửa core nếu lệch. Commit `test(m4): sun economy, cooldown, wallnut, icepea`.

### Task 11: SunView + HUD (HudBar, PlantCard, ví sun, pause) + font

**Files:** Create `lib/game/components/sun_view.dart`, `lib/ui/hud/hud_bar.dart`, `lib/ui/hud/plant_card.dart`, `lib/ui/overlays/pause_overlay.dart`, `assets/fonts/README.md`; Modify `lib/game/sync_layer.dart`, `lib/ui/game_screen.dart`, `pubspec.yaml`, `lib/main.dart`

- [ ] **Step 1: `sun_view.dart`**

```dart
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';

import '../../config/balance.dart';
import '../../core/entities.dart';
import '../grid_board.dart';
import '../sprite_registry.dart';

class SunView extends PositionComponent with TapCallbacks {
  SunView(this.sun, SpriteRegistry sprites, this.onCollect) : super(size: Vector2.all(64), anchor: Anchor.center) {
    final s = sprites.sprite('sun');
    if (s != null) add(SpriteComponent(sprite: s, size: size));
    _hasSprite = s != null;
    priority = 100; // trên mọi thứ để bắt tap trước lưới
    _target = GridBoard.cellToPixel(sun.row, sun.col);
    position = Vector2(_target.x, GridBoard.originY - 40);
  }

  final SunDrop sun;
  final void Function(int sunId) onCollect;
  late final Vector2 _target;
  late final bool _hasSprite;
  final _fill = Paint()..color = const Color(0xFFFBBF24);
  final _ring = Paint()
    ..color = const Color(0xFFF59E0B)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  void syncFromState() {
    final t = (sun.age / 1.0).clamp(0.0, 1.0);
    position = Vector2(_target.x, lerpDouble(GridBoard.originY - 40, _target.y, t)!);
    final left = Balance.sunLifetime - sun.age;
    if (left < 2) {
      final blink = (sin(left * 12) + 1) / 2;
      _fill.color = const Color(0xFFFBBF24).withValues(alpha: 0.4 + 0.6 * blink);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_hasSprite) return;
    final c = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(c, size.x / 2 - 4, _fill);
    canvas.drawCircle(c, size.x / 2 - 4, _ring);
  }

  @override
  void onTapDown(TapDownEvent event) => onCollect(sun.id);
}
```

- [ ] **Step 2: `sync_layer.dart`** thêm `_suns` map; `create: (s) => SunView(s, game.sprites, game.state.collectSun)`, `update: (v) => v.syncFromState()`.

- [ ] **Step 3: `plant_card.dart`**

```dart
import 'package:flutter/material.dart';

import '../../config/balance.dart';
import '../theme.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.spec,
    required this.selected,
    required this.affordable,
    required this.cooldownFraction,
    required this.cooldownSeconds,
    required this.onTap,
  });
  final PlantSpec spec;
  final bool selected;
  final bool affordable;
  final double cooldownFraction; // 0 = sẵn sàng, 1 = vừa trồng
  final double cooldownSeconds;
  final VoidCallback onTap;

  static const _icons = {
    'sunflower': GdColors.sun,
    'peashooter': Color(0xFF16A34A),
    'wallnut': Color(0xFF92400E),
    'icepea': Color(0xFF38BDF8),
  };

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final ready = affordable && cooldownFraction <= 0;
    return Semantics(
      button: true,
      label: '${spec.name}, giá ${spec.cost} sun${ready ? '' : ', chưa sẵn sàng'}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
          child: Container(
            width: 72,
            height: 88,
            decoration: BoxDecoration(
              color: GdColors.card,
              borderRadius: BorderRadius.circular(GdShape.radius),
              border: Border.all(color: selected ? GdColors.sun : GdColors.primaryDark, width: GdShape.border),
              boxShadow: selected ? GdShape.clayShadow : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: affordable ? 1 : 0.4,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _icons[spec.id],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GdColors.ink, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${spec.cost}',
                        style: GdText.body.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w800, color: affordable ? GdColors.ink : GdColors.danger)),
                    if (!affordable) Text('thiếu sun', style: GdText.body.copyWith(fontSize: 10, color: GdColors.danger)),
                  ],
                ),
                if (cooldownFraction > 0)
                  Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: cooldownFraction.clamp(0.0, 1.0),
                      widthFactor: 1,
                      child: Container(
                        color: const Color(0x99000000),
                        alignment: Alignment.center,
                        child: Text('${cooldownSeconds.ceil()}s',
                            style: GdText.heading.copyWith(color: Colors.white, fontSize: 18)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: `hud_bar.dart`**

```dart
import 'package:flutter/material.dart';

import '../../config/balance.dart';
import '../../core/game_event.dart';
import '../../game/garden_game.dart';
import '../theme.dart';
import 'plant_card.dart';

/// Dải trên: ví sun | thẻ plant | pause. Rebuild mỗi frame theo game.frame.
class HudBar extends StatefulWidget {
  const HudBar({super.key, required this.game, required this.onPause});
  final GardenGame game;
  final VoidCallback onPause;
  @override
  State<HudBar> createState() => _HudBarState();
}

class _HudBarState extends State<HudBar> {
  DateTime? _rejectFlashUntil;

  @override
  void initState() {
    super.initState();
    widget.game.events.addListener(_onEvents);
  }

  @override
  void dispose() {
    widget.game.events.removeListener(_onEvents);
    super.dispose();
  }

  void _onEvents() {
    if (widget.game.events.value.any((e) => e is PlantRejected)) {
      _rejectFlashUntil = DateTime.now().add(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.game.state;
    return ValueListenableBuilder<int>(
      valueListenable: widget.game.frame,
      builder: (context, _, __) {
        final flashing = _rejectFlashUntil != null && DateTime.now().isBefore(_rejectFlashUntil!);
        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: GdColors.hudBar,
          child: Row(
            children: [
              _SunWallet(sun: state.sun, flashing: flashing),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final id in state.level.availablePlants) ...[
                        PlantCard(
                          spec: Balance.plants[id]!,
                          selected: state.selectedPlantId == id,
                          affordable: state.sun >= Balance.plants[id]!.cost,
                          cooldownFraction: state.cooldownRemaining(id) / Balance.plants[id]!.plantCooldown,
                          cooldownSeconds: state.cooldownRemaining(id),
                          onTap: () => state.selectPlant(id),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
              ),
              _PauseButton(onTap: widget.onPause),
            ],
          ),
        );
      },
    );
  }
}

class _SunWallet extends StatelessWidget {
  const _SunWallet({required this.sun, required this.flashing});
  final int sun;
  final bool flashing;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: GdColors.hudChip, borderRadius: BorderRadius.circular(GdShape.radius)),
      child: Row(children: [
        Container(width: 22, height: 22, decoration: const BoxDecoration(color: GdColors.sunText, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Semantics(
          label: 'Sun: $sun',
          child: Text('$sun', style: GdText.heading.copyWith(fontSize: 28, color: flashing ? GdColors.danger : GdColors.sunText)),
        ),
      ]),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tạm dừng',
      child: Material(
        color: GdColors.hudChip,
        borderRadius: BorderRadius.circular(GdShape.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GdShape.radius),
          child: const SizedBox(width: 48, height: 48, child: Icon(Icons.pause_rounded, color: Colors.white, size: 28)),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: `pause_overlay.dart`** — như ResultOverlay: nền mờ, card, tiêu đề "Tạm dừng", 3 `ClayButton` "Tiếp tục" (primary) / "Chơi lại" / "Thoát" với `onResume`, `onRetry`, `onQuit`.

- [ ] **Step 6: `game_screen.dart`** — bỏ `selectPlant` tạm; thêm overlay `'hud'` (luôn bật) và `'pause'`:

```dart
overlayBuilderMap: {
  'hud': (context, g) => Align(
        alignment: Alignment.topCenter,
        child: LayoutBuilder(builder: (context, c) {
          final scale = (c.maxWidth / 1280) < (c.maxHeight / 720) ? c.maxWidth / 1280 : c.maxHeight / 720;
          final letterboxTop = (c.maxHeight - 720 * scale) / 2;
          return Padding(
            padding: EdgeInsets.only(top: letterboxTop),
            child: SizedBox(
              width: 1280 * scale,
              height: 100 * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(width: 1280, height: 100, child: HudBar(game: g, onPause: _pause)),
              ),
            ),
          );
        }),
      ),
  'pause': (context, g) => PauseOverlay(onResume: _resume, onRetry: _retry, onQuit: () => Navigator.of(context).maybePop()),
  'result': ...,
},
initialActiveOverlays: const ['hud'],
```
`_pause()`: `game.state.pause(); game.overlays.add('pause');` — `_resume()`: `game.overlays.remove('pause'); game.state.resume();` — `_retry` tạo game mới như cũ.

- [ ] **Step 7: Font** — `assets/fonts/README.md` hướng dẫn tải Fredoka/Nunito (OFL) từ fonts.google.com, đặt `Fredoka-Bold.ttf`, `Nunito-Regular.ttf`, `Nunito-Bold.ttf`, rồi bỏ comment mục `fonts:` trong `pubspec.yaml`:

```yaml
  # Bỏ comment khi đã có file trong assets/fonts/ (xem assets/fonts/README.md)
  # fonts:
  #   - family: Fredoka
  #     fonts:
  #       - asset: assets/fonts/Fredoka-Bold.ttf
  #         weight: 700
  #   - family: Nunito
  #     fonts:
  #       - asset: assets/fonts/Nunito-Regular.ttf
  #       - asset: assets/fonts/Nunito-Bold.ttf
  #         weight: 700
```
Thiếu family → Flutter dùng font mặc định, không lỗi.

- [ ] **Step 8: `main.dart`** debug level: `startingSun: 50, availablePlants: ['sunflower','peashooter','wallnut','icepea'], skySuns: true`, waves t=20/40/60 hàng 2 + t=50 hàng 0.
- [ ] **Step 9: Verify M4** Windows: sun rơi, tap thu; thẻ mờ khi thiếu sun, tap ô khi thiếu → ví nháy đỏ; trừ đúng giá; lớp cooldown quét; pause dừng game + overlay. `analyze`/`test` sạch.
- [ ] **Step 10: Commit** `feat(m4): sun view, HUD plant cards, wallet, pause overlay`; HANDOFF cập nhật + commit.

---

# M5 — Level từ JSON + thắng/thua đầy đủ

### Task 12: LevelLoader + menu tối giản + route

**Files:** Create `lib/data/level_loader.dart`, `lib/ui/menu_screen.dart`; Modify `lib/main.dart`

- [ ] **Step 1: `level_loader.dart`**

```dart
import 'package:flutter/services.dart';

import 'level_data.dart';

class LevelLoader {
  LevelLoader._();
  static String pathFor(int id) => 'assets/levels/level_${id.toString().padLeft(2, '0')}.json';
  static Future<LevelData> load(int id) async => LevelData.parse(await rootBundle.loadString(pathFor(id)));
}
```

- [ ] **Step 2: `menu_screen.dart`**

```dart
import 'package:flutter/material.dart';

import '../data/level_loader.dart';
import 'game_screen.dart';
import 'theme.dart';
import 'widgets/clay_button.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _play(BuildContext context) async {
    final level = await LevelLoader.load(1);
    if (!context.mounted) return;
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GameScreen(level: level)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GdColors.menuBg,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Garden Defense', style: GdText.heading.copyWith(fontSize: 56, color: GdColors.primaryDark)),
          const SizedBox(height: 32),
          ClayButton(label: 'Chơi level 1', primary: true, onTap: () => _play(context)),
        ]),
      ),
    );
  }
}
```

- [ ] **Step 3: `main.dart`** — `home: const MenuScreen()`; xóa debug LevelData.
- [ ] **Step 4:** `flutter analyze`; Windows: menu → level 1. Commit `feat(m5): level loader and minimal menu`.

### Task 13: Tests M5 — chơi hết level_01, sửa data đổi kết quả, hugeWave

**Files:** Create `test/core/game_state_m5_test.dart`

- [ ] **Step 1: Test**

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/core/game_event.dart';
import 'package:garden_defense/core/game_state.dart';
import 'package:garden_defense/data/level_data.dart';

import 'test_helpers.dart';

LevelData level01() => LevelData.parse(File('assets/levels/level_01.json').readAsStringSync());

/// Kịch bản: peashooter hàng 2 cột 0 tại t=0 (150 sun), thu mọi sun, trồng thêm peashooter
/// hàng 2 (cột 1..3) khi đủ 100 sun và hết cooldown.
GameState playScripted(LevelData lvl, {double maxSeconds = 400}) {
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
    if (nextCol < 4 && g.sun >= 100 && g.cooldownRemaining('peashooter') == 0) {
      g.selectPlant('peashooter');
      if (g.tapCell(2, nextCol) == PlantResult.ok) nextCol++;
    }
  }
  return g;
}

void main() {
  test('level 01 is winnable with scripted play', () {
    final g = playScripted(level01());
    expect(g.phase, GamePhase.won);
    expect(g.allWavesSpawned, isTrue);
  });
  test('huge wave warning fires 3s before the flagged wave', () {
    final g = newGame(lvl: level01());
    var warnedAt = -1.0;
    while (g.elapsed < 115 && warnedAt < 0) {
      run(g, 0.25);
      if (g.takeEvents().any((e) => e is HugeWaveWarning)) warnedAt = g.elapsed;
    }
    expect(warnedAt, closeTo(107, 0.3));
  });
  test('adding waves to the level data changes the outcome without code changes', () {
    final base = level01();
    final harder = LevelData(
      id: base.id,
      name: base.name,
      startingSun: base.startingSun,
      availablePlants: base.availablePlants,
      skySuns: base.skySuns,
      waves: [
        ...base.waves,
        for (var i = 0; i < 6; i++) WaveEntry(time: 113 + i.toDouble(), zombie: 'bucket', row: 2),
      ],
    );
    final g = playScripted(harder);
    expect(g.phase, GamePhase.lost);
  });
  test('win requires all waves spawned and no zombies alive', () {
    final g = newGame(
        lvl: level(waves: const [WaveEntry(time: 0, zombie: 'walker', row: 2), WaveEntry(time: 30, zombie: 'walker', row: 2)]));
    g.selectPlant('peashooter');
    g.tapCell(2, 0);
    run(g, 20);
    expect(g.phase, GamePhase.playing);
    run(g, 40);
    expect(g.phase, GamePhase.won);
  });
}
```

- [ ] **Step 2:** Chạy. "winnable" FAIL → chỉnh kịch bản trước; vẫn thua → level_01 quá khó cho người mới: giãn wave trong `level_01.json` và ghi GAME_DESIGN.md. Commit `test(m5): scripted level completion, huge wave, data-driven outcome`.

### Task 14: HugeWaveBanner + "Tiếp tục" về menu

**Files:** Create `lib/ui/overlays/huge_wave_banner.dart`; Modify `lib/ui/game_screen.dart`

- [ ] **Step 1: `huge_wave_banner.dart`**

```dart
import 'package:flutter/material.dart';

import '../theme.dart';

class HugeWaveBanner extends StatefulWidget {
  const HugeWaveBanner({super.key, required this.onDone});
  final VoidCallback onDone;
  @override
  State<HugeWaveBanner> createState() => _HugeWaveBannerState();
}

class _HugeWaveBannerState extends State<HugeWaveBanner> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: AnimatedSlide(
          offset: _shown ? Offset.zero : const Offset(1.2, 0),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: const Color(0xCC0F172A),
            child: Text('Đợt tấn công lớn!',
                textAlign: TextAlign.center, style: GdText.heading.copyWith(fontSize: 40, color: GdColors.danger)),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: `game_screen.dart`** thêm `'hugeWave': (context, g) => HugeWaveBanner(onDone: () => g.overlays.remove('hugeWave'))`; `onContinue` của ResultOverlay: `Navigator.of(context).popUntil((r) => r.isFirst)`.
- [ ] **Step 3: Verify M5** Windows: menu → chơi trọn level 1 → banner ~107 s → thắng → "Tiếp tục" về menu. Sửa `level_01.json` thêm 1 wave, chạy lại thấy khác. `flutter test` toàn bộ pass, `flutter analyze` sạch.
- [ ] **Step 4: Commit** `feat(m5): huge wave banner, full win/lose loop`.

### Task 15: Review + handoff + push

- [ ] **Step 1:** Code review toàn bộ (ecc:code-reviewer agent); sửa lỗi nghiêm trọng.
- [ ] **Step 2:** `docs/HANDOFF.md` bản cuối M5.
- [ ] **Step 3:** `git remote add origin https://github.com/quyenanh198/garden-defense.git`; `git push -u origin main`. Repo chưa có → ghi hướng dẫn trong HANDOFF và báo người dùng.

---

## Mẫu `docs/HANDOFF.md`

```markdown
# Session handoff — Garden Defense

Cập nhật: <ngày> — sau <milestone>

## Trạng thái
- Milestone xong: …
- Đang dở: …
- `flutter analyze`: sạch/không · `flutter test`: N pass

## Chạy
flutter pub get && flutter run -d windows

## Quyết định mới (chưa vào docs khác)
- …

## Việc kế tiếp
1. …

## Chờ người dùng
- Cài Android SDK command-line tools để build APK
- Tải sprite CC0 theo docs/ASSETS.md, font theo assets/fonts/README.md
- Tạo repo GitHub `garden-defense` rồi `git push -u origin main`
```
