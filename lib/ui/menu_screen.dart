import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../config/balance.dart';
import '../core/game_state.dart';
import '../data/progress_store.dart';
import 'game_screen.dart';
import 'level_select_screen.dart';
import 'theme.dart';
import 'widgets/clay_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Chặn tap lặp: các handler có await trước khi push.
  bool _launching = false;
  ProgressStore? _store;

  @override
  void initState() {
    super.initState();
    ProgressStore.load().then((s) {
      if (mounted) setState(() => _store = s);
    });
  }

  Future<void> _openLevelSelect() async {
    final store = _store;
    if (_launching || store == null) return;
    _launching = true;
    try {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => LevelSelectScreen(store: store),
        ),
      );
      if (mounted) setState(() {}); // refresh kỷ lục/tiến độ
    } finally {
      _launching = false;
    }
  }

  Future<void> _playEndless() async {
    final store = _store;
    if (_launching || store == null) return;
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
            onEndlessEnd: store.recordEndless,
          ),
        ),
      );
      if (mounted) setState(() {});
    } finally {
      _launching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final best = _store?.endlessBest ?? 0;
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
              label: 'Chơi',
              primary: true,
              onTap: _openLevelSelect,
            ),
            const SizedBox(height: 16),
            ClayButton(
              label: 'Endless',
              onTap: _playEndless,
            ),
            if (best > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Kỷ lục Endless: $best đợt',
                style: GdText.body.copyWith(
                  fontSize: 16,
                  color: GdColors.primaryDark,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
