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
    // M2 tạm thời: chọn sẵn plant đầu tiên để tap là trồng. Task 11 thay bằng HUD.
    game.state.selectPlant(widget.level.availablePlants.first);
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
