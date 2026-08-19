import '../config/balance.dart';

enum ZombieState { walking, eating, dying }

class Plant {
  Plant({
    required this.id,
    required this.spec,
    required this.row,
    required this.col,
  })  : hp = spec.hp,
        // cây bắn: sẵn sàng bắn ngay phát đầu; cây sinh sun: đếm từ 0
        actionTimer = (spec.action == PlantAction.shoot ||
                spec.action == PlantAction.shootIce)
            ? Balance.fireInterval
            : 0;
  final int id;
  final PlantSpec spec;
  final int row;
  final int col;
  double hp;
  double actionTimer; // đếm tới lần hành động kế
}

class Zombie {
  Zombie({
    required this.id,
    required this.spec,
    required this.row,
    this.col = Balance.cols * 1.0, // mép phải lưới
  }) : hp = spec.hp;
  final int id;
  final ZombieSpec spec;
  final int row;
  double col;
  double hp;
  ZombieState state = ZombieState.walking;
  double slowRemaining = 0;
  double dyingRemaining = Balance.zombieDyingDuration;
  bool get isAlive => state != ZombieState.dying;
  bool get isSlowed => slowRemaining > 0;
}

class Projectile {
  Projectile({
    required this.id,
    required this.row,
    required this.col,
    required this.damage,
    this.slows = false,
  });
  final int id;
  final int row;
  double col;
  final double damage;
  final bool slows;
}

class SunDrop {
  SunDrop({
    required this.id,
    required this.row,
    required this.col,
    required this.value,
  });
  final int id;
  final int row;
  final double col;
  final int value;
  double age = 0;
}
