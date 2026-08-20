import 'package:flutter/material.dart';

import '../theme.dart';

/// Banner "Đợt tấn công lớn!" trượt vào, tự tắt sau 3 s (gọi onDone).
class HugeWaveBanner extends StatefulWidget {
  const HugeWaveBanner({super.key, required this.onDone});
  final VoidCallback onDone;

  @override
  State<HugeWaveBanner> createState() => _HugeWaveBannerState();
}

class _HugeWaveBannerState extends State<HugeWaveBanner> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _shown = true);
    });
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Align(
        alignment: const Alignment(0, -0.2),
        child: AnimatedSlide(
          offset: _shown ? Offset.zero : const Offset(1.2, 0),
          duration: reduce ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: const Color(0xCC0F172A),
            child: Text(
              'Đợt tấn công lớn!',
              textAlign: TextAlign.center,
              style: GdText.heading.copyWith(
                fontSize: 40,
                color: GdColors.danger,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
