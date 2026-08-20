import 'package:flutter/material.dart';

import '../../config/balance.dart';
import '../theme.dart';

class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.spec,
    required this.selected,
    required this.affordable,
    required this.cooldownFraction,
    required this.cooldownSeconds,
    required this.onTap,
  });
  final PlantSpec spec;
  final bool selected;
  final bool affordable;
  final double cooldownFraction; // 0 = sẵn sàng, 1 = vừa trồng
  final double cooldownSeconds;
  final VoidCallback onTap;

  static const _icons = {
    'sunflower': GdColors.sun,
    'peashooter': Color(0xFF16A34A),
    'wallnut': Color(0xFF92400E),
    'icepea': Color(0xFF38BDF8),
  };

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final ready = affordable && cooldownFraction <= 0;
    return Semantics(
      button: true,
      label:
          '${spec.name}, giá ${spec.cost} sun${ready ? '' : ', chưa sẵn sàng'}',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.05 : 1.0,
          duration:
              reduceMotion ? Duration.zero : const Duration(milliseconds: 150),
          child: Container(
            width: 72,
            height: 88,
            decoration: BoxDecoration(
              color: GdColors.card,
              borderRadius: BorderRadius.circular(GdShape.radius),
              border: Border.all(
                color: selected ? GdColors.sun : GdColors.primaryDark,
                width: GdShape.border,
              ),
              boxShadow: selected ? GdShape.clayShadow : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Opacity(
                      opacity: affordable ? 1 : 0.4,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _icons[spec.id],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GdColors.ink, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${spec.cost}',
                      style: GdText.body.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: affordable ? GdColors.ink : GdColors.danger,
                      ),
                    ),
                    if (!affordable)
                      // 1 dòng co giãn theo bề ngang thẻ — để chữ tự xuống
                      // dòng sẽ làm Column cao quá 88px của thẻ.
                      SizedBox(
                        width: 56,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'thiếu sun',
                            maxLines: 1,
                            style: GdText.body.copyWith(
                              fontSize: 10,
                              color: GdColors.danger,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (cooldownFraction > 0)
                  Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: cooldownFraction.clamp(0.0, 1.0),
                      widthFactor: 1,
                      child: Container(
                        color: const Color(0x99000000),
                        alignment: Alignment.center,
                        child: Text(
                          '${cooldownSeconds.ceil()}s',
                          style: GdText.heading.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
