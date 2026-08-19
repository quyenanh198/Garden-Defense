# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau M3

## Trạng thái
- Milestone xong: M1, M2, M3 — verify trên Windows desktop bằng screenshot (grid, zombie đi/ăn, thua, đạn bay + trừ máu đúng hàng).
- Đang dở: M4 (sun economy + HUD). Core đã có sẵn logic sun/cooldown/icepea; còn test M4 + SunView + HUD Flutter.
- `flutter analyze`: sạch · `flutter test`: 21 pass.
- Asset: chưa có sprite; `assets/images/manifest.json` đã khai báo ID, thiếu file → placeholder. Nguồn gợi ý: `docs/ASSETS.md`.
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
1. Task 10: `test/core/game_state_m4_test.dart`.
2. Task 11: SunView, HudBar/PlantCard, PauseOverlay, font README.
3. M5: LevelLoader + menu, test M5, HugeWaveBanner.

## Chờ người dùng
- Cài Android SDK command-line tools để build APK.
- Tải sprite CC0 theo `docs/ASSETS.md` (sẽ có ở Task 7), font theo `assets/fonts/README.md` (Task 11).
- Tạo repo GitHub `quyenanh198/garden-defense` (trống) rồi: `git remote add origin https://github.com/quyenanh198/garden-defense.git && git push -u origin main`.
