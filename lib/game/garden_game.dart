import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

import 'grid_board.dart';

class GardenGame extends FlameGame {
  GardenGame()
      : super(
          camera: CameraComponent.withFixedResolution(width: 1280, height: 720),
        );

  late final GridBoard board;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();
    board = GridBoard()
      ..onCellTap = (r, c) => debugPrint('tap cell (row=$r, col=$c)');
    world.add(board);
  }
}
