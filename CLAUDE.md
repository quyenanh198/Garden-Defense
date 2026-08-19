# CLAUDE.md — Quy ước làm việc trong repo Garden Defense

## Bối cảnh
Game tower defense 2D theo lưới 5×9, Flutter + Flame, target Android APK sideload, offline hoàn toàn.
Docs trong `docs/` là nguồn sự thật. Đọc `docs/ARCHITECTURE.md` và `docs/ROADMAP.md` trước khi viết code.

## 4 nguyên tắc bắt buộc

### 1. Think before coding
- Không đoán mò. Nếu yêu cầu mơ hồ, nêu các cách hiểu và hỏi trước khi code.
- Nếu có cách đơn giản hơn yêu cầu ban đầu, đề xuất trước.

### 2. Simplicity first
- Code tối thiểu giải quyết đúng milestone hiện tại trong ROADMAP.md — không làm trước tính năng của milestone sau.
- Không tạo abstraction cho code dùng một lần. Không xử lý lỗi cho kịch bản bất khả thi.

### 3. Surgical changes
- Chỉ chạm vào file liên quan trực tiếp đến yêu cầu. Không refactor/format lại code xung quanh.
- Xóa orphan (import/biến/hàm chết) do chính thay đổi của mình tạo ra; không xóa dead code có sẵn.

### 4. Goal-driven execution
- Mỗi milestone trong ROADMAP.md có tiêu chí xác minh — không báo "xong" khi chưa chạy được tiêu chí đó.
- Fix bug = viết test tái hiện bug trước, rồi làm nó pass.

## Quy ước kỹ thuật

- **Grid là xương sống**: mọi vị trí gameplay tính theo ô lưới (row, col), chỉ đổi sang pixel ở tầng render. Không hardcode pixel trong logic.
- **Level là JSON**: game logic đọc `assets/levels/*.json` theo schema trong `docs/LEVEL_FORMAT.md`. Thêm level không được đòi hỏi sửa code Dart.
- **Số liệu cân bằng** (HP, damage, cost, cooldown) tập trung trong `docs/GAME_DESIGN.md` và mirror vào một file Dart duy nhất (`lib/config/balance.dart` khi tạo) — không rải rác trong component.
- **UI (menu, HUD) là Flutter widget overlay**, không vẽ UI bằng Flame trừ phần tử nằm trong thế giới game (sun rơi, thanh máu).
- **Không thêm dependency mới** khi Flame/Flutter core làm được. Mỗi dependency mới phải nêu lý do.
- Dart style: theo `flutter_lints` mặc định, không tùy chỉnh rule.

## Lệnh thường dùng

```bash
flutter pub get
flutter analyze                 # phải sạch trước khi kết thúc task
flutter test                    # phải pass trước khi kết thúc task
flutter run                     # test thủ công trên thiết bị
flutter build apk --release
```

## Cấm

- Không dùng tên, hình ảnh, âm thanh, asset gốc của Plants vs Zombies.
- Không thêm backend/analytics/dịch vụ online — game offline 100%.
- Không commit asset không rõ license.
