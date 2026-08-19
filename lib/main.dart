import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/menu_screen.dart';

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
      home: MenuScreen(),
    );
  }
}
