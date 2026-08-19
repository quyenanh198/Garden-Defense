# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau M5 (vertical slice hoàn tất)

## Trạng thái
- Milestone xong: **M1–M5** theo `docs/ROADMAP.md`. Verify tay trên Windows desktop bằng screenshot tự động: lưới + tap, zombie đi/ăn/thua, đạn + trừ máu đúng hàng, sun rơi/thu, HUD thẻ plant (chọn / thiếu sun / cooldown), pause, chơi trọn level 1 → banner "Đợt tấn công lớn!" ở ~107 s → Thắng → "Tiếp tục" về menu.
- `flutter analyze`: sạch · `flutter test`: 35 pass (balance, level parser/validator, core M2–M5).
- Nhánh: `feat/m1-m5-vertical-slice` → merge vào `main`.
- Asset: chưa có sprite/font (placeholder vẽ bằng code). Hướng dẫn: `docs/ASSETS.md`, `assets/fonts/README.md`.

## Chạy
```
flutter pub get
flutter run -d windows
flutter test
```
- Build debug exe: `flutter build windows --debug` → `build/windows/x64/runner/Debug/garden_defense.exe`.
- Lỗi `LNK1168 cannot open ... garden_defense.exe`: app còn chạy → `taskkill /F /IM garden_defense.exe`.
- Lỗi `flutter test` "failed to delete build\unit_test_assets" (sau khi build windows): PowerShell `Remove-Item build\unit_test_assets -Recurse -Force` rồi chạy lại.

## Quyết định mới (đã phản ánh vào docs)
- Sim core thuần Dart (`lib/core/`) + Flame chỉ render (`lib/game/`) + Flutter overlay (`lib/ui/`) — `docs/ARCHITECTURE.md`, spec `docs/superpowers/specs/2026-08-19-garden-defense-m1-m5-design.md`.
- Flame ghim `^1.35.1` (Flutter 3.32.1 / Dart 3.8.1). Nâng Flutter ≥ 3.41 để dùng ^1.38.
- Cây bắn (peashooter/icepea) bắn ngay phát đầu khi có mục tiêu (actionTimer khởi tạo = fireInterval).
- Thẻ plant vẫn được chọn sau khi tap ô bị từ chối (giống PvZ); bỏ chọn sau khi trồng thành công.
- Sau code review: engine Flame `pauseEngine()` khi tạm dừng; `tapCell/collectSun` bị chặn khi không `playing` (`PlantResult.notPlaying`); cây bắn nạp đạn cả khi không có mục tiêu (nhịp ≥ 1.4 s kể cả mục tiêu vào/ra tầm). Chưa làm: dispose `ValueNotifier` trong `GardenGame` (dispose trước khi HudBar gỡ listener sẽ assert; để GC).
- Plan đã thực thi: `docs/superpowers/plans/2026-08-19-garden-defense-m1-m5.md`.

## Việc kế tiếp (M6–M7, cần spec/plan riêng)
1. M6: 10 file level theo bảng độ khó trong `docs/GAME_DESIGN.md` (level 2–10), chơi thử từng level; chỉ thêm JSON.
2. M6: sprite CC0 theo `docs/ASSETS.md` + font OFL; cập nhật `manifest.json`, `CREDITS.md`, bỏ comment `fonts:` trong pubspec.
3. M7: `MenuScreen` đầy đủ + `LevelSelectScreen` + `ProgressStore` (shared_preferences), âm thanh (`flame_audio`), hiệu ứng, build APK.
4. Cải tiến nhỏ đã thấy khi verify: icon thẻ plant đang là ô màu (thay bằng sprite khi có); zombie spawn ở col 9 nằm ngoài lưới (ổn, nhưng có thể thêm nền "đường vào").

## Chờ người dùng
- Cài Android SDK command-line tools → `flutter doctor` xanh Android → `flutter build apk --release` (verify M5/M7 trên máy thật).
- Tải sprite CC0 + font theo hướng dẫn trên.
- GitHub: máy không có `gh`, Claude không tạo repo được. Tạo repo trống `quyenanh198/garden-defense` trên GitHub rồi chạy:
  ```
  git remote add origin https://github.com/quyenanh198/garden-defense.git
  git push -u origin main
  ```
  (nếu remote đã được thêm sẵn thì chỉ cần `git push -u origin main`).
