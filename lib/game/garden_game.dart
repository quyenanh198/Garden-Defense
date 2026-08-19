import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import '../config/balance.dart';
import '../core/game_event.dart';
import '../core/game_state.dart';
import '../data/level_data.dart';
import 'grid_board.dart';
import 'sprite_registry.dart';
import 'sync_layer.dart';

class GardenGame extends FlameGame {
  GardenGame({
    required LevelData level,
    Random? random,
    int rows = Balance.rows,
    int cols = Balance.cols,
    bool endless = false,
  })  : state = GameState(
          level: level,
          random: random,
          rows: rows,
          cols: cols,
          endless: endless,
        ),
        super(
          camera: CameraComponent.withFixedResolution(width: 1280, height: 720),
        );

  final GameState state;
  final SpriteRegistry sprites = SpriteRegistry();
  late final GridBoard board;
  late final SyncLayer _sync;

  /// Tăng mỗi frame; HUD lắng nghe để rebuild.
  final ValueNotifier<int> frame = ValueNotifier(0);

  /// Sự kiện của frame vừa rồi cho UI (banner, nháy ví...).
  final ValueNotifier<List<GameEvent>> events = ValueNotifier(const []);

  /// Tăng mỗi cảnh báo huge wave; GameScreen dùng làm key để banner
  /// mới thay banner cũ (timer 3s chạy lại) thay vì bị nuốt.
  int hugeWaveSeq = 0;

  @override
  Color backgroundColor() => const Color(0xFF14532D);

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    await sprites.load();
    board = GridBoard(rows: state.rows, cols: state.cols)
      ..onCellTap = (r, c) => state.tapCell(r, c);
    world.add(board);
    _sync = SyncLayer(this);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Engine bị pause khi tạm dừng (GameScreen); khi thắng/thua overlay hiện
    // và không còn gì để sync — tránh rebuild HUD vô ích.
    if (state.phase == GamePhase.won || state.phase == GamePhase.lost) return;
    state.tick(dt);
    _sync.sync();
    final evs = state.takeEvents();
    if (evs.isNotEmpty) {
      for (final e in evs) {
        if (e is ZombieHit) _sync.zombieView(e.zombieId)?.hitFlash();
        if (e is HugeWaveWarning) {
          hugeWaveSeq++;
          overlays.remove('hugeWave');
          overlays.add('hugeWave');
        }
      }
      events.value = evs;
    }
    frame.value++;
    if ((state.phase == GamePhase.lost || state.phase == GamePhase.won) &&
        !overlays.isActive('result')) {
      overlays.add('result');
    }
  }
}
