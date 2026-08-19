import 'package:flutter/material.dart';

import '../../core/game_state.dart';
import '../theme.dart';
import '../widgets/clay_button.dart';

class ResultOverlay extends StatelessWidget {
  const ResultOverlay({
    super.key,
    required this.phase,
    required this.onRetry,
    required this.onContinue,
  });
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
          border: Border.all(
            color: won ? GdColors.primaryDark : GdColors.danger,
            width: GdShape.borderLg,
          ),
          boxShadow: GdShape.clayShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won ? 'Thắng!' : 'Thua…',
              style: GdText.heading.copyWith(
                fontSize: 40,
                color: won ? GdColors.primaryDark : GdColors.danger,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClayButton(label: 'Chơi lại', onTap: onRetry),
                if (won) ...[
                  const SizedBox(width: 16),
                  ClayButton(
                    label: 'Tiếp tục',
                    onTap: onContinue,
                    primary: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
