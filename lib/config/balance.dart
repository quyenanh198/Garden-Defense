/// Mọi số liệu cân bằng. Mirror của docs/GAME_DESIGN.md — nếu lệch, docs thắng.
enum PlantAction { produceSun, shoot, shootIce, none }

class PlantSpec {
  const PlantSpec({
    required this.id,
    required this.name,
    required this.cost,
    required this.hp,
    required this.plantCooldown,
    required this.action,
  });
  final String id;
  final String name;
  final int cost;
  final double hp;
  final double plantCooldown; // giây
  final PlantAction action;
}

class ZombieSpec {
  const ZombieSpec({required this.id, required this.name, required this.hp});
  final String id;
  final String name;
  final double hp;
}

class Balance {
  Balance._();

  static const int rows = 5;
  static const int cols = 9;

  static const double zombieCellsPerSecond = 1 / 4.7;
  static const double zombieBiteDps = 100;
  static const double zombieDyingDuration = 0.5;

  static const int skySunValue = 25;
  static const double skySunInterval = 10;
  static const double skySunFirstDrop = 5; // sun trời đầu tiên rơi sớm
  static const double sunLifetime = 8;
  static const int sunflowerValue = 25;
  static const double sunflowerInterval = 15;

  // Hằng hiển thị sun (view đọc, không ảnh hưởng luật chơi).
  static const double sunFallDuration = 1; // giây rơi từ trời xuống ô
  static const double sunBlinkThreshold = 2; // còn <2s thì nhấp nháy

  static const double peaDamage = 20;
  static const double peaSpeed = 6; // ô / giây
  static const double fireInterval = 1.4;
  static const double iceSlowFactor = 0.5;
  static const double iceSlowDuration = 3;
  static const double projectileHitRadius = 0.3;

  static const double hugeWaveWarningLead = 3;

  // Endless (M8) — spec trong docs/GAME_DESIGN.md.
  static const int endlessStartingSun = 150;
  static const double endlessFirstWaveTime = 20;
  static const double endlessBaseInterval = 18;
  static const double endlessIntervalStep = 0.25;
  static const double endlessMinInterval = 6;
  static const int endlessHugeEvery = 10;
  static const int endlessRowsDesktop = 10;
  static const int endlessColsDesktop = 20;
  static const double endlessBucketChance = 0.2;
  static const double endlessConeChance = 0.3;
  static const int endlessConeFromWave = 3;
  static const int endlessBucketFromWave = 8;

  /// Nâng cấp cây (chỉ Endless): giá ×2, hiệu lực ×2, mỗi cây 1 lần.
  static const int upgradeFactor = 2;

  static const Map<String, PlantSpec> plants = {
    'sunflower': PlantSpec(
      id: 'sunflower',
      name: 'Hoa mặt trời',
      cost: 50,
      hp: 300,
      plantCooldown: 7.5,
      action: PlantAction.produceSun,
    ),
    'peashooter': PlantSpec(
      id: 'peashooter',
      name: 'Cây bắn đậu',
      cost: 100,
      hp: 300,
      plantCooldown: 7.5,
      action: PlantAction.shoot,
    ),
    'wallnut': PlantSpec(
      id: 'wallnut',
      name: 'Quả óc chó',
      cost: 50,
      hp: 4000,
      plantCooldown: 30,
      action: PlantAction.none,
    ),
    'icepea': PlantSpec(
      id: 'icepea',
      name: 'Đậu băng',
      cost: 175,
      hp: 300,
      plantCooldown: 7.5,
      action: PlantAction.shootIce,
    ),
  };

  static const Map<String, ZombieSpec> zombies = {
    'walker': ZombieSpec(id: 'walker', name: 'Zombie thường', hp: 200),
    'cone': ZombieSpec(id: 'cone', name: 'Zombie nón', hp: 560),
    'bucket': ZombieSpec(id: 'bucket', name: 'Zombie xô', hp: 1300),
  };
}
