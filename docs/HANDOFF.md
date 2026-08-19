# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau session code review toàn bộ `lib/` (không đổi code)

## Trạng thái
- Milestone xong: **M1–M5** theo `docs/ROADMAP.md`. Verify tay trên Windows desktop bằng screenshot tự động: lưới + tap, zombie đi/ăn/thua, đạn + trừ máu đúng hàng, sun rơi/thu, HUD thẻ plant (chọn / thiếu sun / cooldown), pause, chơi trọn level 1 → banner "Đợt tấn công lớn!" ở ~107 s → Thắng → "Tiếp tục" về menu.
- `flutter analyze`: sạch · `flutter test`: 35 pass (balance, level parser/validator, core M2–M5).
- Nhánh: `main` là mới nhất. Session này chạy trên `claude/caveman-code-review-2gxbxp` (ngang `main`, chỉ thêm handoff này).
- Asset: chưa có sprite/font (placeholder vẽ bằng code). Hướng dẫn: `docs/ASSETS.md`, `assets/fonts/README.md`.

## Kết quả session này: code review `lib/` (~1.900 dòng) + fix finding 1–4
Review effort cao ra 7 finding. **Finding 1–4 đã fix (test-first, mỗi cái có test tái hiện trong `test/core/game_state_review_test.dart`, `test/data/level_data_test.dart`, `test/ui/menu_screen_test.dart`); finding 5–7 còn mở.**

1. ✅ **Đạn xuyên qua zombie khi lag** — `lib/core/game_state.dart` `_moveProjectiles`: chuyển sang va chạm quét (swept) cả đoạn đường đạn đi trong frame, dt lớn không còn nhảy qua zombie; vẫn trúng zombie gần nhất trên đường bay.
2. ✅ **JSON level sai kiểu crash bằng cast error** — `lib/data/level_data.dart`: đọc field qua `_read<T>` có kiểm tra kiểu, thiếu/sai kiểu ném `LevelFormatException` nêu tên field (vd `waves[0].row: expected int, got String`); JSON hỏng / top-level không phải object cũng thành `LevelFormatException`.
3. ✅ **Double-tap "Chơi level 1" push 2 GameScreen** — `lib/ui/menu_screen.dart`: chuyển sang StatefulWidget với guard `_launching`.
4. ✅ **Ice slow giờ giảm cả bite DPS** (quyết định: docs thắng, giống PvZ gốc) — `lib/core/game_state.dart`: zombie bị chậm cắn `zombieBiteDps * iceSlowFactor`; wallnut sau icepea trụ 80 s thay vì 40 s.
5. ⬜ **Banner huge wave thứ 2 bị nuốt** — `lib/game/garden_game.dart:58`. Guard `overlays.isActive('hugeWave')` bỏ qua wave B nếu banner wave A (3 s) còn hiện; event đã tiêu thụ nên banner B không bao giờ xuất hiện.
6. ⬜ **Cột spawn zombie hardcode `9.0`** — `lib/core/entities.dart:30`, trùng lặp `Balance.cols`. Đổi số cột sẽ làm zombie spawn lệch vào trong lưới.
7. ⬜ **Thanh máu wallnut gate bằng heuristic `hp >= 1000`** — `lib/game/components/plant_view.dart:37`. Điều kiện đúng hơn: hiện thanh khi `plant.hp < plant.spec.hp`.

Sau fix: `flutter analyze` sạch · `flutter test` 43 pass (35 cũ + 8 mới).

Đã kiểm và cố ý không flag: mutation map cooldown khi lặp (an toàn — chỉ update key có sẵn), tap priority của sun (đúng), clamp nhịp bắn, vòng đời overlay pause/retry, số liệu balance khớp `docs/GAME_DESIGN.md`.

## Chạy
```
flutter pub get
flutter run -d windows
flutter test
```
- Build debug exe: `flutter build windows --debug` → `build/windows/x64/runner/Debug/garden_defense.exe`.
- Lỗi `LNK1168 cannot open ... garden_defense.exe`: app còn chạy → `taskkill /F /IM garden_defense.exe`.
- Lỗi `flutter test` "failed to delete build\unit_test_assets" (sau khi build windows): PowerShell `Remove-Item build\unit_test_assets -Recurse -Force` rồi chạy lại.

## Quyết định trước đó (đã phản ánh vào docs)
- Sim core thuần Dart (`lib/core/`) + Flame chỉ render (`lib/game/`) + Flutter overlay (`lib/ui/`) — `docs/ARCHITECTURE.md`, spec `docs/superpowers/specs/2026-08-19-garden-defense-m1-m5-design.md`.
- Flame ghim `^1.35.1` (Flutter 3.32.1 / Dart 3.8.1). Nâng Flutter ≥ 3.41 để dùng ^1.38.
- Cây bắn (peashooter/icepea) bắn ngay phát đầu khi có mục tiêu (actionTimer khởi tạo = fireInterval).
- Thẻ plant vẫn được chọn sau khi tap ô bị từ chối (giống PvZ); bỏ chọn sau khi trồng thành công.
- Engine Flame `pauseEngine()` khi tạm dừng; `tapCell/collectSun` bị chặn khi không `playing`; cây bắn nạp đạn cả khi không có mục tiêu (nhịp ≥ 1.4 s). Chưa làm: dispose `ValueNotifier` trong `GardenGame` (để GC).
- Plan đã thực thi: `docs/superpowers/plans/2026-08-19-garden-defense-m1-m5.md`.

## Ghi chú môi trường session
- Plugin `ecc`, `multi-ai-skills`, `superpowers` (+ `ui-ux-pro-max`, `obsidian`, v.v.) **đã enable ở tài khoản** nhưng skill chỉ nạp lúc tạo session → `/caveman:full` không chạy được trong session này. Session mới sẽ có sẵn; session này dùng `/code-review` built-in thay thế.

## Việc kế tiếp
1. **Fix finding 5–7 còn lại** (test-first): banner huge wave, cột spawn, thanh máu wallnut.
2. M6: 10 file level theo bảng độ khó trong `docs/GAME_DESIGN.md` (level 2–10), chơi thử từng level; chỉ thêm JSON.
3. M6: sprite CC0 theo `docs/ASSETS.md` + font OFL; cập nhật `manifest.json`, `CREDITS.md`, bỏ comment `fonts:` trong pubspec.
4. M7: `MenuScreen` đầy đủ + `LevelSelectScreen` + `ProgressStore` (shared_preferences), âm thanh (`flame_audio`), hiệu ứng, build APK.
5. Cải tiến nhỏ từ verify M5: icon thẻ plant đang là ô màu (thay bằng sprite khi có); zombie spawn ở col 9 ngoài lưới (ổn, có thể thêm nền "đường vào").

## Chờ người dùng
- Cài Android SDK command-line tools → `flutter doctor` xanh Android → `flutter build apk --release`.
- Tải sprite CC0 + font theo hướng dẫn trên.
- GitHub: `main` đã trên https://github.com/quyenanh198/Garden-Defense (remote `origin`); handoff này trên nhánh `claude/caveman-code-review-2gxbxp`.
