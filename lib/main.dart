import 'package:flutter/material.dart';

void main() {
  runApp(const GardenDefenseApp());
}

class GardenDefenseApp extends StatelessWidget {
  const GardenDefenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Garden Defense',
      home: Scaffold(body: Center(child: Text('Garden Defense'))),
    );
  }
}
