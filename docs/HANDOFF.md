# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau M1

## Trạng thái
- Milestone xong: M1 (lưới 5×9 + tap in `(row, col)`), verify trên Windows desktop bằng screenshot + log.
- Đang dở: M2 (core sim đã có entities/events/wave_spawner, chưa có `game_state.dart`, chưa có view).
- `flutter analyze`: sạch · `flutter test`: 12 pass (balance + level_data).
- Nhánh: `feat/m1-m5-vertical-slice` (merge vào `main` khi xong M5).

## Chạy
```
flutter pub get
flutter run -d windows
```
Build debug exe: `flutter build windows --debug` → `build/windows/x64/runner/Debug/garden_defense.exe`.
Lưu ý: nếu build báo `LNK1168 cannot open ... garden_defense.exe` thì app còn đang chạy — `taskkill /F /IM garden_defense.exe`.

## Quyết định mới (chưa vào docs khác)
- Flame ghim `^1.35.1` (Flutter 3.32.1 / Dart 3.8.1 không resolve ^1.37).
- Dev target Windows; APK verify để sau khi cài Android SDK.
- Plan chi tiết: `docs/superpowers/plans/2026-08-19-garden-defense-m1-m5.md`; spec: `docs/superpowers/specs/2026-08-19-garden-defense-m1-m5-design.md`.

## Việc kế tiếp
1. Task 5: `lib/core/game_state.dart` + `test/core/game_state_m2_test.dart`.
2. Task 6: SpriteRegistry, placeholder, SyncLayer, PlantView/ZombieView, overlay thua.
3. Task 7: asset manifest + docs/ASSETS.md.

## Chờ người dùng
- Cài Android SDK command-line tools để build APK.
- Tải sprite CC0 theo `docs/ASSETS.md` (sẽ có ở Task 7), font theo `assets/fonts/README.md` (Task 11).
- Tạo repo GitHub `quyenanh198/garden-defense` (trống) rồi: `git remote add origin https://github.com/quyenanh198/garden-defense.git && git push -u origin main`.
