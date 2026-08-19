import 'package:flame/components.dart';

import '../core/entities.dart';
import 'components/plant_view.dart';
import 'components/projectile_view.dart';
import 'components/sun_view.dart';
import 'components/zombie_view.dart';
import 'garden_game.dart';

/// Đối chiếu entity trong GameState với component Flame. Không có logic gameplay.
class SyncLayer {
  SyncLayer(this.game);
  final GardenGame game;

  final Map<int, PlantView> _plants = {};
  final Map<int, ZombieView> _zombies = {};
  final Map<int, ProjectileView> _projectiles = {};
  final Map<int, SunView> _suns = {};

  ZombieView? zombieView(int id) => _zombies[id];

  void sync() {
    _syncList<Plant, PlantView>(
      game.state.plants,
      _plants,
      (p) => p.id,
      create: (p) => PlantView(p, game.sprites),
      update: (v) {},
    );
    _syncList<Zombie, ZombieView>(
      game.state.zombies,
      _zombies,
      (z) => z.id,
      create: (z) => ZombieView(z, game.sprites),
      update: (v) => v.syncFromState(),
    );
    _syncList<Projectile, ProjectileView>(
      game.state.projectiles,
      _projectiles,
      (p) => p.id,
      create: (p) => ProjectileView(p, game.sprites),
      update: (v) => v.syncFromState(),
    );
    _syncList<SunDrop, SunView>(
      game.state.suns,
      _suns,
      (s) => s.id,
      create: (s) => SunView(s, game.sprites, game.state.collectSun),
      update: (v) => v.syncFromState(),
    );
  }

  void _syncList<E, V extends Component>(
    List<E> entities,
    Map<int, V> views,
    int Function(E) idOf, {
    required V Function(E) create,
    required void Function(V) update,
  }) {
    final live = <int>{};
    for (final e in entities) {
      final id = idOf(e);
      live.add(id);
      var v = views[id];
      if (v == null) {
        v = create(e);
        views[id] = v;
        game.world.add(v);
      }
      update(v);
    }
    final gone = views.keys.where((id) => !live.contains(id)).toList();
    for (final id in gone) {
      views.remove(id)!.removeFromParent();
    }
  }
}
