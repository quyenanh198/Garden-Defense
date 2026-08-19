import 'package:flutter_test/flutter_test.dart';
import 'package:garden_defense/data/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults: level 1 unlocked, no endless record', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ProgressStore.load();
    expect(store.highestUnlocked, 1);
    expect(store.endlessBest, 0);
  });

  test('unlock and endless record only ever increase', () async {
    SharedPreferences.setMockInitialValues({});
    final store = await ProgressStore.load();
    await store.unlock(3);
    expect(store.highestUnlocked, 3);
    await store.unlock(2); // không tụt lùi
    expect(store.highestUnlocked, 3);
    await store.recordEndless(12);
    await store.recordEndless(7);
    expect(store.endlessBest, 12);
  });

  test('progress persists across store instances', () async {
    SharedPreferences.setMockInitialValues({});
    await (await ProgressStore.load()).unlock(5);
    expect((await ProgressStore.load()).highestUnlocked, 5);
  });
}
