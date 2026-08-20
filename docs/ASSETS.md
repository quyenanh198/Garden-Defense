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

`file` là đường dẫn tương đối trong `assets/images/` (Flame `Flame.images.load`). Quy ước animation: zombie ưu tiên `<id>_walk`; cây/đạn/sun ưu tiên `<id>_idle`; không có animation thì dùng `<id>` tĩnh; không có nữa thì placeholder.

ID cần có: `sunflower`, `peashooter`, `wallnut`, `icepea`, `walker`, `cone`, `bucket`, `pea`, `icepea_shot`, `sun` (+ tùy chọn `<zombie>_walk` và `<id>_idle` cho cây/đạn/sun).

## Nguồn gợi ý (CC0) — xác minh nội dung khi tải

| Nhu cầu | Pack | Ghi chú |
|---|---|---|
| Zombie (cartoon, có animation) | Kenney — *Toon Characters 1* https://kenney.nl/assets/toon-characters (270 file, CC0) | Có nhân vật zombie theo tài liệu của Kenney; cắt frame đi bộ, đổi hat/áo để làm `cone`/`bucket` (vẽ thêm nón/xô đơn giản). |
| Zombie (thay thế) | Kenney — *Animated Characters 3* (itch.io kenney-assets) | Có skin zombie nam/nữ, có anim idle/run. |
| Plant | Kenney — *Foliage Sprites* / *Tower Defense (Top-Down)* https://kenney.nl/assets/tower-defense-top-down | Chưa có pack CC0 "cây bắn đậu" sẵn; phương án: dùng cây/hoa cartoon của Kenney + vẽ thêm miệng/nòng, hoặc đặt vẽ riêng ở M6. |
| UI khung/nút | Kenney — *UI Pack* https://kenney.nl/assets/ui-pack | HUD hiện vẽ bằng Flutter, chỉ cần nếu muốn khung 9-slice. |
| Đạn, sun, hạt | Kenney — *Particle Pack* https://kenney.nl/assets/particle-pack | Hình tròn/ngôi sao tô màu lại. |
| Tìm thêm | OpenGameArt lọc CC0: https://opengameart.org/content/all-cc0-uploader-kenney · https://opengameart.org/content/good-cc0-art | |

### Nguồn bổ sung (tra cứu 2026-08-19 — kiểm tra license từng trang trước khi dùng)

| Nhu cầu | Nguồn | License | Ghi chú |
|---|---|---|---|
| Zombie có anim đi bộ | OpenGameArt — "Zombie RPG sprites" https://opengameart.org/content/zombie-rpg-sprites | CC0 | sheet đi bộ nhiều hướng, cần scale về 96×128 |
| Zombie sprite sheet | OpenGameArt — "The Zombie - Free Sprites" https://opengameart.org/content/the-zombie-free-sprites | xem trang | kiểm tra license trước khi dùng |
| Nhân vật vector module hóa | OpenGameArt — "Free CC0 Modular Animated Vector Characters 2D" https://opengameart.org/content/free-cc0-modular-animated-vector-characters-2d | CC0 | ghép bộ phận, dễ chế cone/bucket |
| Tổng hợp CC0 | OpenGameArt — CC0 resources https://opengameart.org/content/cc0-resources | CC0 | danh mục lớn do cộng đồng lọc |
| Zombie chất lượng cao | CraftPix freebies https://craftpix.net/freebies/2d-game-zombie-character-free-sprite-pack-1/ | license riêng của CraftPix | miễn phí nhưng KHÔNG phải CC0 — đọc kỹ điều khoản |
| Bộ đầy đủ đủ thể loại | Kenney All-in-1 https://kenney.nl/ (Toon Characters, Tower Defense, Particle Pack, UI Pack) | CC0 | 30.000+ asset, an toàn nhất về license |

**Âm thanh** (thay file WAV cùng tên trong `assets/audio/`): freesound.org (lọc license CC0), Kenney *Audio* packs (CC0), hoặc tự sinh bằng jsfxr/sfxr. Tránh nguồn "royalty-free" không ghi rõ license.

**Lưu ý khi tải trong Claude Code Remote**: proxy của môi trường remote chặn kenney.nl / opengameart.org / itch.io / craftpix.net — các link trên dành cho máy dev. Sprite + animation hiện tại trong repo là bản vẽ gốc bằng script (xem `assets/CREDITS.md`), ghi đè file cùng tên là thay được.

Quy trình: chọn pack → tải zip → cắt/đổi tên file theo ID → đặt vào `assets/images/` → cập nhật `manifest.json` + `CREDITS.md` → `flutter run -d windows` kiểm tra.

## Font (OFL)

Xem `assets/fonts/README.md` (Fredoka + Nunito từ Google Fonts). Thiếu font → Flutter dùng font mặc định, không lỗi.
