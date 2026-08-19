import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/level_data.dart';
import 'ui/game_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const GardenDefenseApp());
}

class GardenDefenseApp extends StatelessWidget {
  const GardenDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Garden Defense',
      debugShowCheckedModeBanner: false,
      // Level debug cho M2 — Task 12 thay bằng MenuScreen + LevelLoader.
      home: GameScreen(
        level: LevelData(
          id: 0,
          name: 'debug',
          startingSun: 50,
          availablePlants: ['sunflower', 'peashooter', 'wallnut', 'icepea'],
          skySuns: true,
          waves: [
            WaveEntry(time: 20, zombie: 'walker', row: 2),
            WaveEntry(time: 40, zombie: 'walker', row: 2),
            WaveEntry(time: 50, zombie: 'walker', row: 0),
            WaveEntry(time: 60, zombie: 'cone', row: 2),
          ],
        ),
      ),
    );
  }
}
