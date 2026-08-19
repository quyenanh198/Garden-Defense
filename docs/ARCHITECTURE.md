# Kiến trúc hệ thống

## Mục tiêu & ràng buộc
- Game tower defense 2D theo lưới, mobile Android, chơi dọc màn hình ngang (landscape).
- Offline hoàn toàn, không backend. Tiến độ lưu local.
- Thêm nội dung (level, plant, zombie mới) phải rẻ: data-driven, ít đụng code.

## Tổng quan tầng

```
┌─────────────────────────────────────────┐
│ Flutter UI layer (widgets)              │  menu, chọn level, HUD, pause, thắng/thua
│ — overlay trên GameWidget               │
├─────────────────────────────────────────┤
│ Flame game layer                        │
│  GardenGame (FlameGame)                 │  game loop, quản lý trận đấu
│   ├── GridBoard                         │  lưới 5×9, tọa độ ô ↔ pixel
│   ├── PlantComponent (mỗi plant)        │  HP, cooldown hành động
│   ├── ZombieComponent (mỗi zombie)      │  HP, di chuyển, state machine
│   ├── ProjectileComponent               │  đạn bay theo hàng, va chạm
│   ├── SunComponent                      │  sun rơi/sinh ra, tap để thu
│   └── WaveSpawner                       │  đọc LevelData, sinh zombie theo thời gian
├─────────────────────────────────────────┤
│ Data layer                              │
│  LevelData (parse assets/levels/*.json) │
│  Balance (lib/config/balance.dart)      │  toàn bộ số liệu cân bằng
│  ProgressStore (shared_preferences)     │  level đã mở khóa
└─────────────────────────────────────────┘
```

## Hệ tọa độ lưới (xương sống)

- Lưới **5 hàng × 9 cột**. `GridBoard` là nơi duy nhất biết kích thước ô theo pixel.
- Mọi logic gameplay dùng `(row, col)`. Chuyển đổi:
  - `cellToPixel(row, col)` → tâm ô, dùng khi đặt plant / spawn sun.
  - `pixelToCell(x, y)` → ô, dùng khi xử lý tap.
- Zombie di chuyển theo pixel liên tục nhưng **thuộc về một hàng cố định** — va chạm chỉ xét trong cùng hàng, không cần hệ va chạm 2D tổng quát.

## Luồng một trận đấu

1. UI chọn level → load `LevelData` từ JSON → tạo `GardenGame(levelData)`.
2. `WaveSpawner` chạy theo đồng hồ trận đấu, spawn zombie đúng `time` / `row` khai báo.
3. Mỗi frame (`update(dt)`):
   - Plant đếm cooldown → hành động (bắn projectile / sinh sun).
   - Projectile bay sang phải, trúng zombie đầu tiên cùng hàng → trừ HP.
   - Zombie đi sang trái; gặp plant cùng ô phía trước → chuyển state ăn.
4. Điều kiện kết thúc:
   - **Thua**: zombie bất kỳ vượt qua cột 0 (mép trái).
   - **Thắng**: hết mọi wave và không còn zombie sống.
5. Kết quả → `ProgressStore` mở khóa level kế → UI hiện màn thắng/thua.

## State machine của zombie

`walking → eating → walking` (khi plant trước mặt chết) và `* → dying → removed` (HP ≤ 0).
Giữ đúng 3 state này cho MVP — không thêm state trước khi có zombie đặc biệt cần nó.

## Cấu trúc thư mục dự kiến

```
lib/
├── main.dart              # entry, route menu ↔ game
├── config/
│   └── balance.dart       # MỌI số liệu cân bằng (mirror GAME_DESIGN.md)
├── data/
│   ├── level_data.dart    # model + parser JSON level
│   └── progress_store.dart
├── game/
│   ├── garden_game.dart   # FlameGame chính
│   ├── grid_board.dart
│   ├── wave_spawner.dart
│   └── components/
│       ├── plant.dart     # base + các loại plant
│       ├── zombie.dart    # base + các loại zombie
│       ├── projectile.dart
│       └── sun.dart
└── ui/
    ├── menu_screen.dart
    ├── level_select_screen.dart
    └── hud/               # thanh chọn plant, đếm sun, pause
```

## Quyết định & đánh đổi

| Quyết định | Lý do | Đánh đổi chấp nhận |
|---|---|---|
| Va chạm theo hàng, không dùng collision engine tổng quát | PvZ chỉ cần va chạm 1 chiều trong hàng — đơn giản, nhanh, dễ debug | Nếu sau này có plant/đạn xuyên hàng chéo thì phải mở rộng |
| Level bằng JSON tĩnh trong assets | Thêm level không cần code, dễ test cân bằng | Không có level editor trực quan (chấp nhận ở quy mô cá nhân) |
| UI bằng Flutter widget overlay | Đúng sở trường Flutter sẵn có, nhanh hơn vẽ UI trong Flame | Hai hệ tọa độ UI/game phải giao tiếp qua GardenGame |
| shared_preferences cho tiến độ | Chỉ cần lưu "đã qua level nào" — key-value là đủ | Nếu sau này có meta-progression phức tạp thì chuyển sang file JSON riêng |
