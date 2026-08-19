import 'package:flutter/material.dart';

import '../data/level_loader.dart';
import '../data/progress_store.dart';
import 'game_screen.dart';
import 'theme.dart';

/// Chọn level 1–10; level khóa không bấm được. Thắng level N mở N+1.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key, required this.store});
  final ProgressStore store;

  static const levelCount = 10;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  bool _launching = false;

  Future<void> _play(int id) async {
    if (_launching) return;
    _launching = true;
    try {
      final level = await LevelLoader.load(id);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => GameScreen(
            level: level,
            onWon: () => widget.store.unlock(id + 1),
          ),
        ),
      );
      if (mounted) setState(() {}); // refresh ô vừa mở khóa
    } finally {
      _launching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = widget.store.highestUnlocked;
    return Scaffold(
      backgroundColor: GdColors.menuBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Text(
              'Chọn level',
              style: GdText.heading.copyWith(
                fontSize: 40,
                color: GdColors.primaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (var id = 1; id <= LevelSelectScreen.levelCount; id++)
                      _LevelTile(
                        id: id,
                        locked: id > unlocked,
                        onTap: () => _play(id),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Về menu',
                  style: GdText.body.copyWith(
                    fontSize: 18,
                    color: GdColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  const _LevelTile({required this.id, required this.locked, required this.onTap});
  final int id;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: locked ? 'Level $id (khóa)' : 'Level $id',
      child: Material(
        color: locked ? const Color(0xFFE2E8F0) : GdColors.card,
        borderRadius: BorderRadius.circular(GdShape.radius),
        child: InkWell(
          onTap: locked ? null : onTap,
          borderRadius: BorderRadius.circular(GdShape.radius),
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GdShape.radius),
              border: Border.all(
                color: locked ? const Color(0xFF94A3B8) : GdColors.primaryDark,
                width: GdShape.border,
              ),
            ),
            child: locked
                ? const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 32)
                : Text(
                    '$id',
                    style: GdText.heading.copyWith(
                      fontSize: 32,
                      color: GdColors.primaryDark,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
