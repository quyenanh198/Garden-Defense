import 'package:flutter/material.dart';

import '../data/level_loader.dart';
import 'game_screen.dart';
import 'theme.dart';
import 'widgets/clay_button.dart';

/// Menu tối giản cho M5. Chọn level + unlock làm ở M7.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  Future<void> _play(BuildContext context) async {
    final level = await LevelLoader.load(1);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GameScreen(level: level)),
    );
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
              onTap: () => _play(context),
            ),
          ],
        ),
      ),
    );
  }
}
