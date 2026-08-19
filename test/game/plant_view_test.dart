import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/config/balance.dart';
import 'package:garden_defense/core/entities.dart';
import 'package:garden_defense/game/components/plant_view.dart';
import 'package:garden_defense/game/grid_board.dart';
import 'package:garden_defense/game/sprite_registry.dart';

void main() {
  final board = GridBoard(rows: 5, cols: 9);
  test('hp bar shows only when the plant has taken damage', () {
    final wallnut = Plant(
      id: 1,
      spec: Balance.plants['wallnut']!,
      row: 0,
      col: 0,
    );
    expect(PlantView(wallnut, SpriteRegistry(), board).showsHpBar, isFalse);
    wallnut.hp -= 1;
    expect(PlantView(wallnut, SpriteRegistry(), board).showsHpBar, isTrue);

    // Không phụ thuộc ngưỡng hp tuyệt đối: cây thường cũng hiện khi mất máu.
    final pea = Plant(
      id: 2,
      spec: Balance.plants['peashooter']!,
      row: 0,
      col: 1,
    );
    expect(PlantView(pea, SpriteRegistry(), board).showsHpBar, isFalse);
    pea.hp -= 1;
    expect(PlantView(pea, SpriteRegistry(), board).showsHpBar, isTrue);
  });
}
