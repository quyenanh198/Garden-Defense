# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau session code review toàn bộ `lib/` (không đổi code)

## Trạng thái
- Milestone xong: **M1–M5** theo `docs/ROADMAP.md`. Verify tay trên Windows desktop bằng screenshot tự động: lưới + tap, zombie đi/ăn/thua, đạn + trừ máu đúng hàng, sun rơi/thu, HUD thẻ plant (chọn / thiếu sun / cooldown), pause, chơi trọn level 1 → banner "Đợt tấn công lớn!" ở ~107 s → Thắng → "Tiếp tục" về menu.
- `flutter analyze`: sạch · `flutter test`: 35 pass (balance, level parser/validator, core M2–M5).
- Nhánh: `main` là mới nhất. Session này chạy trên `claude/caveman-code-review-2gxbxp` (ngang `main`, chỉ thêm handoff này).
- Asset: chưa có sprite/font (placeholder vẽ bằng code). Hướng dẫn: `docs/ASSETS.md`, `assets/fonts/README.md`.

## Kết quả session này: code review `lib/` (~1.900 dòng) + fix cả 7 finding
Review effort cao ra 7 finding, **đã fix hết** (test-first; test trong `test/core/game_state_review_test.dart`, `test/data/level_data_test.dart`, `test/ui/menu_screen_test.dart`, `test/ui/huge_wave_banner_test.dart`, `test/game/plant_view_test.dart`).

1. ✅ **Đạn xuyên qua zombie khi lag** — `lib/core/game_state.dart` `_moveProjectiles`: chuyển sang va chạm quét (swept) cả đoạn đường đạn đi trong frame, dt lớn không còn nhảy qua zombie; vẫn trúng zombie gần nhất trên đường bay.
2. ✅ **JSON level sai kiểu crash bằng cast error** — `lib/data/level_data.dart`: đọc field qua `_read<T>` có kiểm tra kiểu, thiếu/sai kiểu ném `LevelFormatException` nêu tên field (vd `waves[0].row: expected int, got String`); JSON hỏng / top-level không phải object cũng thành `LevelFormatException`.
3. ✅ **Double-tap "Chơi level 1" push 2 GameScreen** — `lib/ui/menu_screen.dart`: chuyển sang StatefulWidget với guard `_launching`.
4. ✅ **Ice slow giờ giảm cả bite DPS** (quyết định: docs thắng, giống PvZ gốc) — `lib/core/game_state.dart`: zombie bị chậm cắn `zombieBiteDps * iceSlowFactor`; wallnut sau icepea trụ 80 s thay vì 40 s.
5. ✅ **Banner huge wave thứ 2 bị nuốt** — `GardenGame.hugeWaveSeq` tăng mỗi cảnh báo; overlay remove+add và `HugeWaveBanner` nhận `ValueKey(hugeWaveSeq)` nên banner mới thay banner cũ với timer 3s chạy lại.
6. ✅ **Cột spawn zombie hardcode `9.0`** — `lib/core/entities.dart`: default `Balance.cols * 1.0`.
7. ✅ **Thanh máu wallnut gate bằng heuristic `hp >= 1000`** — `PlantView.showsHpBar` (hiện khi `plant.hp < plant.spec.hp`), mọi cây hiện thanh khi mất máu.

Sau toàn bộ session: `flutter analyze` sạch · `flutter test` 61 pass.

**PlantCard overflow (finding phát sinh) — đã fix:** dòng "thiếu sun" giờ là 1 dòng trong `FittedBox` co giãn (`lib/ui/hud/plant_card.dart`), có widget test tái hiện (`test/ui/plant_card_test.dart`).

## M6 (phần level): 10 file level + test mô phỏng
- `assets/levels/level_02.json` … `level_10.json` theo đúng bảng độ khó trong `docs/GAME_DESIGN.md` (L2 sunflower, L3 wallnut, L4 ba hàng, L5 cone, L6 huge wave, L7 icepea, L8 sun 25, L9 bucket, L10 boss ~200s).
- `test/data/levels_m6_test.dart`: bot chơi tổng quát (thu sun, phủ cây bắn theo hàng bị đe dọa, tường cột 5 cho zombie trâu, tăng cường theo áp lực HP, sunflower khi rảnh — kèm cờ `log:` để tune level sau này). Test khẳng định: **cả 10 level bot thắng**; **level 8–10 đánh bại kịch bản "rảnh tay" 1 hàng** (proxy cho "không thắng rảnh tay" của ROADMAP).
- Bài học cân bằng khi tune: thu nhập ≈ 5 sun/s (sky 2.5 + 2–3 sunflower) → mỗi lần mở hàng mới (100 sun) cần cách nhau ~15–20s; cone = tường (50) + 1 cây bắn; bucket = tường + 2 cây bắn.
- **Chưa xong M6**: verify tay trên thiết bị ("mỗi level thắng được nhưng không thắng rảnh tay") — sim chỉ là proxy; và phần asset CC0 (sprite/font) vẫn chờ.

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
1. M6: chơi tay level 2–10 trên thiết bị để verify độ khó thật (sim đã chứng minh thắng được; cảm giác "suýt thua" ở 8–10 cần người thật).
2. M6: sprite CC0 theo `docs/ASSETS.md` + font OFL; cập nhật `manifest.json`, `CREDITS.md`, bỏ comment `fonts:` trong pubspec.
3. M7: `MenuScreen` đầy đủ + `LevelSelectScreen` + `ProgressStore` (shared_preferences), âm thanh (`flame_audio`), hiệu ứng, build APK.
4. Cải tiến nhỏ từ verify M5: icon thẻ plant đang là ô màu (thay bằng sprite khi có); zombie spawn ở col 9 ngoài lưới (ổn, có thể thêm nền "đường vào").

## Chờ người dùng
- Cài Android SDK command-line tools → `flutter doctor` xanh Android → `flutter build apk --release`.
- Tải sprite CC0 + font theo hướng dẫn trên.
- GitHub: `main` đã trên https://github.com/quyenanh198/Garden-Defense (remote `origin`); handoff này trên nhánh `claude/caveman-code-review-2gxbxp`.
