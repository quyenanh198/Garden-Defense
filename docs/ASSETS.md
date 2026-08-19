# Asset — nguồn CC0 và cách thêm vào game

Game chạy được **không cần asset nào**: thiếu sprite thì `SpriteRegistry` bỏ qua và view vẽ placeholder (khối màu + chữ id). Thêm asset = thả file PNG vào `assets/images/`, khai báo trong `assets/images/manifest.json`, ghi nguồn vào `assets/CREDITS.md`. Không sửa code Dart.

## Quy tắc

- Chỉ dùng asset CC0 (hoặc license cho phép dùng thương mại không attribution bắt buộc; nếu cần attribution thì ghi vào CREDITS.md).
- **Không** dùng tên/hình/âm thanh của Plants vs Zombies.
- PNG nền trong suốt. Kích thước khuyến nghị (không bắt buộc, view tự scale):
  - plant: 128×128
  - zombie: 96×128 (sheet đi bộ: N frame xếp ngang, mỗi frame 96×128)
  - đạn: 32×32 · sun: 64×64

## Manifest

```jsonc
{
  "sprites": {
    "peashooter":  { "file": "peashooter.png" },
    "walker":      { "file": "walker.png" },                         // sprite tĩnh
    "walker_walk": { "file": "walker_walk.png", "frameSize": [96, 128], "frames": 6, "stepTime": 0.12 },
    "pea":         { "file": "pea.png" },
    "sun":         { "file": "sun.png" }
  }
}
```

`file` là đường dẫn tương đối trong `assets/images/` (Flame `Flame.images.load`). ID zombie dạng `<id>_walk` được ưu tiên dùng làm animation đi bộ; không có thì dùng `<id>` tĩnh; không có nữa thì placeholder.

ID cần có: `sunflower`, `peashooter`, `wallnut`, `icepea`, `walker`, `cone`, `bucket`, `pea`, `icepea_shot`, `sun` (+ tùy chọn `walker_walk`, `cone_walk`, `bucket_walk`).

## Nguồn gợi ý (CC0) — xác minh nội dung khi tải

| Nhu cầu | Pack | Ghi chú |
|---|---|---|
| Zombie (cartoon, có animation) | Kenney — *Toon Characters 1* https://kenney.nl/assets/toon-characters (270 file, CC0) | Có nhân vật zombie theo tài liệu của Kenney; cắt frame đi bộ, đổi hat/áo để làm `cone`/`bucket` (vẽ thêm nón/xô đơn giản). |
| Zombie (thay thế) | Kenney — *Animated Characters 3* (itch.io kenney-assets) | Có skin zombie nam/nữ, có anim idle/run. |
| Plant | Kenney — *Foliage Sprites* / *Tower Defense (Top-Down)* https://kenney.nl/assets/tower-defense-top-down | Chưa có pack CC0 "cây bắn đậu" sẵn; phương án: dùng cây/hoa cartoon của Kenney + vẽ thêm miệng/nòng, hoặc đặt vẽ riêng ở M6. |
| UI khung/nút | Kenney — *UI Pack* https://kenney.nl/assets/ui-pack | HUD hiện vẽ bằng Flutter, chỉ cần nếu muốn khung 9-slice. |
| Đạn, sun, hạt | Kenney — *Particle Pack* https://kenney.nl/assets/particle-pack | Hình tròn/ngôi sao tô màu lại. |
| Tìm thêm | OpenGameArt lọc CC0: https://opengameart.org/content/all-cc0-uploader-kenney · https://opengameart.org/content/good-cc0-art | |

Quy trình: chọn pack → tải zip → cắt/đổi tên file theo ID → đặt vào `assets/images/` → cập nhật `manifest.json` + `CREDITS.md` → `flutter run -d windows` kiểm tra.

## Font (OFL)

Xem `assets/fonts/README.md` (Fredoka + Nunito từ Google Fonts). Thiếu font → Flutter dùng font mặc định, không lỗi.
