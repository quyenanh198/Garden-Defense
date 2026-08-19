import 'package:flutter/material.dart';

import '../../config/balance.dart';
import '../../core/game_event.dart';
import '../../game/garden_game.dart';
import '../theme.dart';
import 'plant_card.dart';

/// Dải trên: ví sun | thẻ plant | pause. Rebuild mỗi frame theo game.frame.
class HudBar extends StatefulWidget {
  const HudBar({super.key, required this.game, required this.onPause});
  final GardenGame game;
  final VoidCallback onPause;

  @override
  State<HudBar> createState() => _HudBarState();
}

class _HudBarState extends State<HudBar> {
  DateTime? _rejectFlashUntil;

  @override
  void initState() {
    super.initState();
    widget.game.events.addListener(_onEvents);
  }

  @override
  void dispose() {
    widget.game.events.removeListener(_onEvents);
    super.dispose();
  }

  void _onEvents() {
    if (widget.game.events.value.any((e) => e is PlantRejected)) {
      _rejectFlashUntil = DateTime.now().add(const Duration(milliseconds: 300));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.game.state;
    return ValueListenableBuilder<int>(
      valueListenable: widget.game.frame,
      builder: (context, _, __) {
        final flashing = _rejectFlashUntil != null &&
            DateTime.now().isBefore(_rejectFlashUntil!);
        return Container(
          height: 100,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: GdColors.hudBar,
          child: Row(
            children: [
              _SunWallet(sun: state.sun, flashing: flashing),
              const SizedBox(width: 16),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final id in state.level.availablePlants) ...[
                        PlantCard(
                          spec: Balance.plants[id]!,
                          selected: state.selectedPlantId == id,
                          affordable: state.sun >= Balance.plants[id]!.cost,
                          cooldownFraction: state.cooldownRemaining(id) /
                              Balance.plants[id]!.plantCooldown,
                          cooldownSeconds: state.cooldownRemaining(id),
                          onTap: () => state.selectPlant(id),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ],
                  ),
                ),
              ),
              _PauseButton(onTap: widget.onPause),
            ],
          ),
        );
      },
    );
  }
}

class _SunWallet extends StatelessWidget {
  const _SunWallet({required this.sun, required this.flashing});
  final int sun;
  final bool flashing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: GdColors.hudChip,
        borderRadius: BorderRadius.circular(GdShape.radius),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: GdColors.sunText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: 'Sun: $sun',
            child: Text(
              '$sun',
              style: GdText.heading.copyWith(
                fontSize: 28,
                color: flashing ? GdColors.danger : GdColors.sunText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  const _PauseButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Tạm dừng',
      child: Material(
        color: GdColors.hudChip,
        borderRadius: BorderRadius.circular(GdShape.radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GdShape.radius),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.pause_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
