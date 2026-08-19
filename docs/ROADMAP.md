# Lộ trình — 7 milestone

Mỗi milestone chỉ được coi là xong khi **chạy được tiêu chí xác minh trên thiết bị/emulator Android thật**. Không làm trước tính năng của milestone sau.

## M1 — Khung + lưới
Setup Flame trong project, vẽ lưới 5×9 chiếm màn hình landscape.
→ **Verify**: chạy APK debug, thấy lưới; tap vào ô bất kỳ in ra đúng `(row, col)` qua debug log.

## M2 — Trồng cây + zombie đi
Đặt plant tĩnh vào ô bằng tap. Zombie spawn từ mép phải, đi sang trái theo hàng.
→ **Verify**: zombie chạm mép trái → hiện "thua"; zombie gặp plant → dừng lại ăn, plant hết HP thì biến mất và zombie đi tiếp.

## M3 — Bắn + va chạm
Peashooter bắn đạn khi có zombie cùng hàng; đạn trúng zombie đầu tiên, trừ HP.
→ **Verify**: 10 đạn (200 dmg) giết 1 walker; đạn không trúng zombie khác hàng.

## M4 — Sun economy + thanh chọn plant
Sun rơi từ trời + sinh từ sunflower, tap để thu. Thanh chọn plant với giá + cooldown.
→ **Verify**: không đủ sun → không trồng được; trồng xong bị trừ đúng giá; cooldown chặn spam.

## M5 — Level từ JSON + thắng/thua đầy đủ
WaveSpawner đọc `level_01.json`. Điều kiện thắng/thua theo GAME_DESIGN.md. Có test cho parser.
→ **Verify**: chơi trọn level 1 từ đầu đến thắng; sửa JSON (thêm 1 wave) thay đổi trận đấu mà không sửa code; `flutter test` pass cho parser + validator.

**→ Hết M5 = vertical slice. Từ đây chỉ còn mở rộng nội dung.**

## M6 — Nội dung: 4 plants, 3 zombies, 10 levels
Đủ bảng số liệu trong GAME_DESIGN.md, 10 file level theo cấu trúc độ khó đã định.
→ **Verify**: chơi lần lượt cả 10 level; mỗi level thắng được nhưng không thắng "rảnh tay" (có ít nhất một lần suýt thua ở level 8–10).

## M7 — Vòng lặp hoàn chỉnh + polish
Menu, chọn level, unlock tiến độ (shared_preferences), pause, âm thanh cơ bản (thêm `flame_audio` ở bước này), hiệu ứng chết/trúng đạn tối thiểu.
→ **Verify**: vòng lặp menu → chơi → thắng → level sau mở khóa → thoát app mở lại vẫn giữ tiến độ; build `flutter build apk --release` cài được trên máy thật.

## Nguyên tắc khi thực thi

- Mỗi milestone là một nhánh việc độc lập; kết thúc bằng `flutter analyze` sạch + `flutter test` pass.
- Gặp quyết định thiết kế mới → cập nhật docs trước, code sau.
- Số liệu cân bằng chỉnh trong `GAME_DESIGN.md` + `balance.dart`, không sửa tại chỗ trong component.
