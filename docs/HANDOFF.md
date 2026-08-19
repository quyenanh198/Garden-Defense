# Session handoff — Garden Defense

Cập nhật: 2026-08-19 — sau session code review toàn bộ `lib/` (không đổi code)

## Trạng thái
- Milestone xong: **M1–M5** theo `docs/ROADMAP.md`. Verify tay trên Windows desktop bằng screenshot tự động: lưới + tap, zombie đi/ăn/thua, đạn + trừ máu đúng hàng, sun rơi/thu, HUD thẻ plant (chọn / thiếu sun / cooldown), pause, chơi trọn level 1 → banner "Đợt tấn công lớn!" ở ~107 s → Thắng → "Tiếp tục" về menu.
- `flutter analyze`: sạch · `flutter test`: 35 pass (balance, level parser/validator, core M2–M5).
- Nhánh: `main` là mới nhất. Session này chạy trên `claude/caveman-code-review-2gxbxp` (ngang `main`, chỉ thêm handoff này).
- Asset: chưa có sprite/font (placeholder vẽ bằng code). Hướng dẫn: `docs/ASSETS.md`, `assets/fonts/README.md`.

## Kết quả session này: code review `lib/` (~1.900 dòng, effort cao)
Chưa sửa gì — theo quy ước CLAUDE.md, fix bug phải viết test tái hiện trước. Các finding, nặng → nhẹ:

1. **Đạn xuyên qua zombie khi lag** — `lib/core/game_state.dart:175`. Va chạm kiểu điểm-bán kính với cửa sổ trúng 0.6 ô, nhưng dùng `dt` thô không clamp; frame giật > ~100 ms làm đạn nhảy qua zombie, mất sát thương âm thầm trên máy Android yếu (đích của game). Fix: clamp `dt` hoặc kiểm tra va chạm theo đoạn (swept).
2. **JSON level sai kiểu crash bằng cast error thay vì `LevelFormatException`** — `lib/data/level_data.dart:59`. Ví dụ `"row": "2"` (string) ném `type String is not a subtype of num` trước khi validator chạy — vi phạm hợp đồng "thêm level không sửa Dart".
3. **Double-tap "Chơi level 1" push 2 GameScreen** — `lib/ui/menu_screen.dart:15`. `_play` await load level trước `Navigator.push`, không có guard chống tap lặp.
4. **Ice slow không giảm bite DPS** — `lib/core/game_state.dart:219`. Zombie bị chậm vẫn cắn full 100 DPS; `docs/GAME_DESIGN.md` ghi "làm chậm zombie 50%" không giới hạn ở di chuyển — docs thắng, cần chọn 1 phía (sửa code hoặc làm rõ docs).
5. **Banner huge wave thứ 2 bị nuốt** — `lib/game/garden_game.dart:58`. Guard `overlays.isActive('hugeWave')` bỏ qua wave B nếu banner wave A (3 s) còn hiện; event đã tiêu thụ nên banner B không bao giờ xuất hiện.
6. **Cột spawn zombie hardcode `9.0`** — `lib/core/entities.dart:30`, trùng lặp `Balance.cols`. Đổi số cột sẽ làm zombie spawn lệch vào trong lưới.
7. **Thanh máu wallnut gate bằng heuristic `hp >= 1000`** — `lib/game/components/plant_view.dart:37`. Điều kiện đúng hơn: hiện thanh khi `plant.hp < plant.spec.hp`.

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
1. **Fix 7 finding ở trên** (test-first, ưu tiên 1–3): làm trên nhánh mới hoặc `claude/caveman-code-review-2gxbxp`; `flutter analyze` + `flutter test` sạch trước khi kết thúc.
2. M6: 10 file level theo bảng độ khó trong `docs/GAME_DESIGN.md` (level 2–10), chơi thử từng level; chỉ thêm JSON.
3. M6: sprite CC0 theo `docs/ASSETS.md` + font OFL; cập nhật `manifest.json`, `CREDITS.md`, bỏ comment `fonts:` trong pubspec.
4. M7: `MenuScreen` đầy đủ + `LevelSelectScreen` + `ProgressStore` (shared_preferences), âm thanh (`flame_audio`), hiệu ứng, build APK.
5. Cải tiến nhỏ từ verify M5: icon thẻ plant đang là ô màu (thay bằng sprite khi có); zombie spawn ở col 9 ngoài lưới (ổn, có thể thêm nền "đường vào").

## Chờ người dùng
- Quyết định finding #4 (ice slow): docs hay code thắng — cần chọn trước khi fix.
- Cài Android SDK command-line tools → `flutter doctor` xanh Android → `flutter build apk --release`.
- Tải sprite CC0 + font theo hướng dẫn trên.
- GitHub: `main` đã trên https://github.com/quyenanh198/Garden-Defense (remote `origin`); handoff này trên nhánh `claude/caveman-code-review-2gxbxp`.
