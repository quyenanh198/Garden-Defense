# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau M4

## Trạng thái
- Milestone xong: M1–M4 — verify trên Windows desktop bằng screenshot (grid, zombie đi/ăn, thua, đạn, sun rơi/thu, HUD thẻ plant + cooldown + thiếu sun, pause).
- Đang dở: M5 (LevelLoader + menu, test M5, HugeWaveBanner, vòng thắng/thua đầy đủ).
- `flutter analyze`: sạch · `flutter test`: 29 pass.
- Lưu ý Windows: sau `flutter build windows`, thư mục `build/unit_test_assets` bị read-only làm `flutter test` lỗi "failed to delete" — xóa thư mục đó (PowerShell `Remove-Item -Recurse -Force`) rồi chạy lại.
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
1. Task 12: `lib/data/level_loader.dart`, `lib/ui/menu_screen.dart`, main → MenuScreen.
2. Task 13: `test/core/game_state_m5_test.dart`.
3. Task 14: HugeWaveBanner + Tiếp tục về menu. Task 15: review + push.

## Chờ người dùng
- Cài Android SDK command-line tools để build APK.
- Tải sprite CC0 theo `docs/ASSETS.md` (sẽ có ở Task 7), font theo `assets/fonts/README.md` (Task 11).
- Tạo repo GitHub `quyenanh198/garden-defense` (trống) rồi: `git remote add origin https://github.com/quyenanh198/garden-defense.git && git push -u origin main`.
