import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/balance.dart';
import '../core/game_state.dart';
import '../data/level_loader.dart';
import 'game_screen.dart';
import 'theme.dart';
import 'widgets/clay_button.dart';

/// Menu tối giản cho M5. Chọn level + unlock làm ở M7.
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Chặn tap lặp: _play có await trước khi push nên tap đúp sẽ push 2 lần.
  bool _launching = false;

  Future<void> _play() async {
    if (_launching) return;
    _launching = true;
    try {
      final level = await LevelLoader.load(1);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => GameScreen(level: level)),
      );
    } finally {
      _launching = false;
    }
  }

  Future<void> _playEndless() async {
    if (_launching) return;
    _launching = true;
    try {
      // Desktop: lưới 10×20; Android giữ 5×9 (docs/GAME_DESIGN.md).
      final desktop = defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(
            level: GameState.endlessConfig(),
            rows: desktop ? Balance.endlessRowsDesktop : Balance.rows,
            cols: desktop ? Balance.endlessColsDesktop : Balance.cols,
            endless: true,
          ),
        ),
      );
    } finally {
      _launching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GdColors.menuBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Garden Defense',
              style: GdText.heading.copyWith(
                fontSize: 56,
                color: GdColors.primaryDark,
              ),
            ),
            const SizedBox(height: 32),
            ClayButton(
              label: 'Chơi level 1',
              primary: true,
              onTap: _play,
            ),
            const SizedBox(height: 16),
            ClayButton(
              label: 'Endless',
              onTap: _playEndless,
            ),
          ],
        ),
      ),
    );
  }
}
