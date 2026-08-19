# Garden Defense

Game tower defense 2D theo lưới (lấy cảm hứng từ cơ chế Plants vs Zombies), viết bằng **Flutter + Flame**, chạy trên Android (APK sideload).

> ⚠️ Tên `garden_defense` là tên tạm. Không dùng tên/hình ảnh/asset của Plants vs Zombies (IP của EA/PopCap) trong bất kỳ bản build nào.

## Trạng thái

Giai đoạn: **M1–M5 vertical slice đang triển khai** (xem `docs/HANDOFF.md`). Xem lộ trình tại [docs/ROADMAP.md](docs/ROADMAP.md).

## Quick start

```bash
# Yêu cầu: Flutter SDK (stable), Android SDK
flutter create . --project-name garden_defense --platforms=android,windows
flutter pub get
flutter run -d windows                 # dev nhanh trên Windows
flutter run                            # chạy trên máy/emulator Android
flutter build apk --release            # build APK sideload
```

> Flame ghim `^1.35.1` vì máy dev dùng Flutter 3.32 / Dart 3.8. Nâng Flutter ≥ 3.41 để dùng flame ^1.38.

## Tài liệu

| File | Nội dung |
|---|---|
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | Kiến trúc hệ thống, cấu trúc thư mục, luồng game loop |
| [docs/GAME_DESIGN.md](docs/GAME_DESIGN.md) | Thiết kế gameplay: plants, zombies, sun economy, số liệu cân bằng MVP |
| [docs/LEVEL_FORMAT.md](docs/LEVEL_FORMAT.md) | Schema JSON của level + quy tắc thiết kế level |
| [docs/ROADMAP.md](docs/ROADMAP.md) | 7 milestone với tiêu chí xác minh từng bước |
| [CLAUDE.md](CLAUDE.md) | Quy ước làm việc cho Claude Code trong repo này |

## Nguyên tắc dự án

1. **Docs là nguồn sự thật** — thay đổi thiết kế thì sửa docs trước, code sau.
2. **Level là data, không phải code** — thêm level mới chỉ bằng cách thêm file JSON vào `assets/levels/`.
3. **Offline hoàn toàn, $0 chi phí** — không backend, không dịch vụ trả phí.
4. **Asset phải là free/CC0** — nguồn gợi ý: Kenney.nl, OpenGameArt, itch.io (mục free assets).
