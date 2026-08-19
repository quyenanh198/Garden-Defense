import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../data/level_data.dart';
import '../game/garden_game.dart';
import 'hud/hud_bar.dart';
import 'overlays/huge_wave_banner.dart';
import 'overlays/pause_overlay.dart';
import 'overlays/result_overlay.dart';

/// Không gian ảo của Flame (xem GardenGame / GridBoard).
const _virtualW = 1280.0;
const _virtualH = 720.0;
const _hudH = 100.0;

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
    game = GardenGame(level: widget.level);
  }

  void _retry() => setState(() => game = GardenGame(level: widget.level));

  void _pause() {
    game.state.pause();
    game.overlays.add('pause');
    game.pauseEngine();
  }

  void _resume() {
    game.resumeEngine();
    game.overlays.remove('pause');
    game.state.resume();
  }

  void _quit() => Navigator.of(context).popUntil((r) => r.isFirst);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14532D),
      body: GameWidget<GardenGame>(
        key: ObjectKey(game),
        game: game,
        initialActiveOverlays: const ['hud'],
        overlayBuilderMap: {
          'hud': (context, g) => _HudOverlay(game: g, onPause: _pause),
          'pause': (context, g) =>
              PauseOverlay(onResume: _resume, onRetry: _retry, onQuit: _quit),
          'hugeWave': (context, g) => HugeWaveBanner(
                key: ValueKey(g.hugeWaveSeq),
                onDone: () => g.overlays.remove('hugeWave'),
              ),
          'result': (context, g) => ResultOverlay(
                phase: g.state.phase,
                onRetry: _retry,
                onContinue: _quit,
              ),
        },
      ),
    );
  }
}

/// Đặt HudBar đúng vị trí dải y 0–100 của không gian ảo sau letterbox.
class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.game, required this.onPause});
  final GardenGame game;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final sx = c.maxWidth / _virtualW;
        final sy = c.maxHeight / _virtualH;
        final scale = sx < sy ? sx : sy;
        final top = (c.maxHeight - _virtualH * scale) / 2;
        final left = (c.maxWidth - _virtualW * scale) / 2;
        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: _virtualW * scale,
              height: _hudH * scale,
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _virtualW,
                  height: _hudH,
                  child: HudBar(game: game, onPause: onPause),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
