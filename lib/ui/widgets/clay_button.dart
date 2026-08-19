import 'package:flutter/material.dart';

import '../theme.dart';

class ClayButton extends StatelessWidget {
  const ClayButton({
    super.key,
    required this.label,
    required this.onTap,
    this.primary = false,
  });
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
            border: Border.all(
              color: GdColors.primaryDark,
              width: GdShape.border,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GdText.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: primary ? Colors.white : GdColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}
