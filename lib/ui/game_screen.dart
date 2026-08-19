import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/garden_game.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GardenGame game = GardenGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF14532D),
      body: GameWidget(game: game),
    );
  }
}
