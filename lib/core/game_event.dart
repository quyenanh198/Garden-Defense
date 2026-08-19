enum PlantResult {
  ok,
  noSelection,
  occupied,
  notEnoughSun,
  onCooldown,
  notAvailable,
  notPlaying,
  alreadyUpgraded,
}

sealed class GameEvent {
  const GameEvent();
}

class PlantPlaced extends GameEvent {
  const PlantPlaced(this.plantId, this.row, this.col);
  final int plantId;
  final int row;
  final int col;
}

class PlantRejected extends GameEvent {
  const PlantRejected(this.reason);
  final PlantResult reason;
}

class PlantUpgraded extends GameEvent {
  const PlantUpgraded(this.plantId);
  final int plantId;
}

class PlantDied extends GameEvent {
  const PlantDied(this.plantId);
  final int plantId;
}

class ZombieSpawned extends GameEvent {
  const ZombieSpawned(this.zombieId);
  final int zombieId;
}

class ZombieHit extends GameEvent {
  const ZombieHit(this.zombieId);
  final int zombieId;
}

class ZombieDied extends GameEvent {
  const ZombieDied(this.zombieId);
  final int zombieId;
}

class SunSpawned extends GameEvent {
  const SunSpawned(this.sunId);
  final int sunId;
}

class SunCollected extends GameEvent {
  const SunCollected(this.sunId, this.value);
  final int sunId;
  final int value;
}

class SunExpired extends GameEvent {
  const SunExpired(this.sunId);
  final int sunId;
}

class HugeWaveWarning extends GameEvent {
  const HugeWaveWarning();
}

class GameWon extends GameEvent {
  const GameWon();
}

class GameLost extends GameEvent {
  const GameLost();
}
