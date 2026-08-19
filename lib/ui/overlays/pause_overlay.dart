import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/clay_button.dart';

class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRetry,
    required this.onQuit,
  });
  final VoidCallback onResume;
  final VoidCallback onRetry;
  final VoidCallback onQuit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x99000000),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: GdColors.card,
          borderRadius: BorderRadius.circular(GdShape.radiusLg),
          border: Border.all(
            color: GdColors.primaryDark,
            width: GdShape.borderLg,
          ),
          boxShadow: GdShape.clayShadow,
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tạm dừng',
                style: GdText.heading.copyWith(
                  fontSize: 36,
                  color: GdColors.primaryDark,
                ),
              ),
              const SizedBox(height: 20),
              ClayButton(label: 'Tiếp tục', onTap: onResume, primary: true),
              const SizedBox(height: 12),
              ClayButton(label: 'Chơi lại', onTap: onRetry),
              const SizedBox(height: 12),
              ClayButton(label: 'Thoát', onTap: onQuit),
            ],
          ),
        ),
      ),
    );
  }
}
