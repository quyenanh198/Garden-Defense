# Garden Defense — Design spec M1–M5 (vertical slice)

Ngày: 2026-08-19
Phạm vi: milestone M1–M5 trong `docs/ROADMAP.md` (khung + lưới → level từ JSON, thắng/thua đầy đủ). M6–M7 (nội dung 10 level, menu đầy đủ, âm thanh, polish) sẽ có spec riêng sau khi slice chạy được.

Tài liệu này bổ sung, không thay thế, `docs/ARCHITECTURE.md`, `docs/GAME_DESIGN.md`, `docs/LEVEL_FORMAT.md`, `docs/ROADMAP.md`. Nơi nào lệch nhau, spec này thắng cho M1–M5 và các docs gốc phải được cập nhật theo (xem mục 9).

## 1. Quyết định đã chốt

| Chủ đề | Quyết định | Lý do |
|---|---|---|
| Phạm vi | Spec + plan cho M1–M5 | Vertical slice trước, mở rộng nội dung sau |
| Dev target | Windows desktop (`--platforms=android,windows`), APK build sau khi cài Android SDK | Máy hiện chưa có Android toolchain; Flame chạy giống nhau trên desktop; hot-reload nhanh |
| Đồ họa | Sprite CC0 (Kenney / OpenGameArt) ngay từ M2, có fallback placeholder | Người dùng muốn nhìn đẹp sớm; fallback để milestone không bị chặn bởi asset |
| Tải asset | Claude tìm và đề xuất; hỏi xác nhận từng lần tải (tên, nguồn, dung lượng) | Quy tắc an toàn: không tự tải file |
| Thẩm mỹ | Cartoon tươi, béo tròn; UI theo Claymorphism nhẹ; palette xanh cỏ + vàng nắng | Gần cảm giác gốc, hợp sprite Kenney |
| Test | Logic thuần Dart có unit test; Flame chỉ render, verify tay | Test nhanh, không thêm `flame_test`; đúng "grid là xương sống, pixel chỉ ở render" |
| Input trồng cây | Tap thẻ plant → tap ô | Đơn giản, đúng PvZ mobile; kéo-thả có thể thêm ở M7 |
| Kiến trúc | **Sim core thuần Dart + Flame là view** | Testable, tách pixel khỏi logic; khác ARCHITECTURE.md hiện tại (logic trong component) → cập nhật docs |

## 2. Kiến trúc tổng thể

```
Flutter UI layer (widgets, overlay của GameWidget)   menu tối giản, HUD, banner, pause, thắng/thua
        │ lệnh: selectPlant / tapCell / collectSun / pause      ▲ đọc GameState + GameEvent
        ▼                                                        │
Flame layer  lib/game/    GardenGame (FlameGame) ── SyncLayer ── component (sprite/placeholder)
        │ state.tick(dt) mỗi frame                               ▲ GridBoard: cellToPixel / pixelToCell
        ▼                                                        │
Sim core     lib/core/    GameState + entity + WaveSpawner + Economy   (không import Flame/Flutter)
        │
Data         lib/data/    LevelData (+ validator), lib/config/balance.dart, ProgressStore (M7)
```

Nguyên tắc ranh giới:

- `lib/core/` chỉ import `dart:math`, `dart:convert`, và `lib/config/balance.dart`, `lib/data/level_data.dart` (bản thân `level_data.dart` cũng không import Flutter; phần đọc asset nằm ở `lib/data/level_loader.dart`). Không có `Vector2`, không có pixel.
- `lib/game/` là lớp view: đọc state, vẽ, chuyển tap thành lệnh. Không có công thức gameplay nào ở đây.
- `lib/ui/` là widget Flutter thuần, nhận `GameState` qua `ValueListenable`/callback do `GardenGame` cung cấp.

## 3. Sim core (`lib/core/`)

### 3.1 Hệ tọa độ logic

- Lưới `rows = 5`, `cols = 9` (`GridConfig`).
- Plant chiếm ô `(row: int, col: int)`.
- Zombie có `row: int`, `col: double`. Spawn tại `col = 9.0` (ngoài mép phải). **Thua** khi `col < 0`.
- Projectile có `row: int`, `col: double`, bay sang phải (`col` tăng).
- Sun có `row: int`, `col: double` (vị trí xuất hiện; render tự thêm hiệu ứng rơi).

Tầng render là nơi duy nhất đổi `(row, col)` sang pixel.

### 3.2 Balance (`lib/config/balance.dart`)

Mirror đúng bảng trong `docs/GAME_DESIGN.md`:

- `PlantSpec { id, cost, hp, plantCooldown, action }` cho `sunflower`, `peashooter`, `wallnut`, `icepea`.
- `ZombieSpec { id, hp, cellsPerSecond = 1/4.7, biteDps = 100 }` cho `walker`, `cone`, `bucket`.
- Hằng số sun: `skySunValue = 25`, `skySunInterval = 10s`, `skySunLifetime = 8s`, `sunflowerInterval = 24s`, `sunflowerValue = 25`.
- Đạn: `peaDamage = 20`, `peaSpeed = 6` ô/giây, `iceSlowFactor = 0.5`, `iceSlowDuration = 3s`.
- Peashooter/icepea `fireInterval = 1.4s`.

Test `balance_test` kiểm tra vài mốc (peashooter DPS ≈ 14.3, walker HP 200) để docs và code không lệch.

### 3.3 GameState

Trường chính: `sun`, `plants`, `zombies`, `projectiles`, `suns`, `elapsed`, `phase ∈ {playing, paused, won, lost}`, `plantCooldownRemaining[plantId]`, `selectedPlantId`, `events` (danh sách `GameEvent` sinh trong tick gần nhất, view đọc rồi xóa).

`tick(dt)` chạy theo thứ tự cố định, deterministic:

1. `WaveSpawner.tick` — spawn zombie đúng `time/row`; phát `hugeWaveWarning` 3 giây trước entry có `hugeWave`.
2. Plant hành động — sunflower đếm giờ sinh sun; peashooter/icepea chỉ bắn khi có zombie sống cùng hàng và `col` lớn hơn plant.
3. Projectile di chuyển; trúng zombie đầu tiên (nhỏ nhất `col`) cùng hàng thỏa `|proj.col − z.col| < 0.3` → trừ HP, icepea đặt `slowUntil`; projectile ra khỏi `col > 9.5` thì xóa.
4. Zombie — `walking`: `col -= speed * dt` (nhân 0.5 nếu đang bị chậm); nếu có plant cùng hàng với `plant.col + 0.5 >= z.col > plant.col − 0.5` → `eating`, trừ HP plant `biteDps * dt`; plant HP ≤ 0 → xóa plant, zombie về `walking`. HP zombie ≤ 0 → `dying` (giữ 0.5 s cho hiệu ứng) → xóa.
5. Sky sun — nếu `level.skySuns`, mỗi 10 s spawn 1 sun tại ô ngẫu nhiên (`Random` inject được seed); sun quá 8 s → xóa.
6. Giảm cooldown thẻ plant.
7. Điều kiện kết thúc — có zombie `col < 0` → `lost`; `spawner.allSpawned && zombies.isEmpty` → `won`.

Lệnh từ UI (chỉ đường vào mutate ngoài `tick`):

- `selectPlant(id)` — toggle chọn.
- `tapCell(row, col)` → `PlantResult { ok | noSelection | occupied | notEnoughSun | onCooldown }`; thành công thì trừ sun, đặt cooldown, bỏ chọn thẻ, phát `plantPlaced`.
- `collectSun(id)` → `sun += 25`, phát `sunCollected`.
- `pause()/resume()`.

`GameEvent` (sealed class): `plantPlaced`, `plantRejected(reason)`, `plantDied`, `zombieSpawned`, `zombieHit`, `zombieDied`, `sunSpawned`, `sunCollected`, `sunExpired`, `hugeWaveWarning`, `won`, `lost`. M1–M5 dùng cho HUD phản hồi và hiệu ứng tối thiểu; M7 dùng cho âm thanh.

### 3.4 Zombie state machine

Đúng 3 state của ARCHITECTURE.md: `walking → eating → walking` (plant chết) và `* → dying → removed`. Không thêm state.

### 3.5 WaveSpawner

- Nhận `List<WaveEntry>` đã được validator đảm bảo `time` tăng dần.
- Con trỏ `nextIndex`; mỗi tick spawn mọi entry có `time <= elapsed`.
- `allSpawned = nextIndex >= waves.length`.
- Cảnh báo huge wave: khi `elapsed >= entry.time − 3` và chưa cảnh báo cho entry đó → `hugeWaveWarning`.

## 4. Data (`lib/data/`)

- `LevelData.fromJson(Map)` theo schema `docs/LEVEL_FORMAT.md`; `skySuns` mặc định `true`, `hugeWave` mặc định `false`.
- `LevelValidator.validate(LevelData, Balance)` trả danh sách lỗi; parser ném `LevelFormatException(message)` nếu có lỗi. Bắt đúng 4 lỗi docs liệt kê: ID plant/zombie lạ, `row` ngoài 0–4, `waves` rỗng, `time` không tăng dần (không giảm; bằng nhau cho phép).
- `LevelLoader.load(int id)` đọc `assets/levels/level_XX.json` qua `rootBundle` (nằm ngoài core để core test không cần Flutter binding).
- `ProgressStore` (shared_preferences) chỉ làm ở M7; M5 chưa cần.

## 5. Render — Flame (`lib/game/`)

- `GardenGame extends FlameGame`: giữ `GameState`; `update(dt)` gọi `state.tick(dt)` khi `phase == playing`, sau đó `SyncLayer.sync()`.
- Camera: `CameraComponent.withFixedResolution(width: 1280, height: 720)`. Mọi pixel trong không gian ảo này; Flame letterbox theo màn hình thật.
- Bố cục ảo: HUD dải trên `y 0–100` (do Flutter overlay phủ), lưới `x 200–1240`, `y 100–700` → ô ≈ 115.5 × 120; lề trái `x 0–200` là "nhà" + nơi zombie đi vào để thua. Overlay Flutter tính `scale = min(screenW/1280, screenH/720)` qua `LayoutBuilder` và đặt `HudBar` cao `100 × scale` tại đỉnh vùng letterbox để khớp với không gian ảo.
- `GridBoard`: duy nhất biết kích thước ô; cung cấp `cellToPixel(row, col)` (tâm ô, `col` có thể là số thực) và `pixelToCell(x, y)`. Vẽ ô xen kẽ hai tông xanh cỏ.
- `SyncLayer`: so khớp `id` entity trong state với map component đang có; thêm mới / cập nhật vị trí, HP bar, state anim / xóa khi entity biến mất. Component không chứa logic gameplay.
- Component: `PlantView`, `ZombieView`, `ProjectileView`, `SunView` (tap được, ưu tiên bắt tap trước lưới), `HealthBar` (chỉ cho wallnut và zombie).
- Sprite: `SpriteRegistry` đọc `assets/images/manifest.json` (`id → { file, frameSize?, frames?, stepTime? }`). Thiếu entry hoặc file → `PlaceholderRenderer` vẽ khối màu bo góc + chữ id. Game không được crash vì thiếu asset.
- Input: `TapCallbacks` trên game → `pixelToCell` → `state.tapCell`. Ngoài lưới thì bỏ qua.

## 6. UI — Flutter overlay (`lib/ui/`)

Design system (từ ui-ux-pro-max, đã điều chỉnh palette):

- Style: Claymorphism nhẹ — bo góc 16–24 px, viền 3–4 px, bóng mềm, nút bấm "lún" 150–200 ms.
- Palette: primary `#15803D`, primary đậm `#166534`, accent sun `#F59E0B` (chữ vàng `#FBBF24` trên nền tối), nền menu `#F0FDF4`, chip HUD `#0F172A` alpha 85%, destructive `#DC2626`, chữ `#0F172A`. Tất cả cặp chữ/nền đạt tương phản ≥ 4.5:1.
- Font: Fredoka (heading, số lớn) + Nunito (body). Bundle TTF (OFL) trong `assets/fonts/`, khai báo trong `pubspec.yaml`. Không fetch runtime.
- Tối thiểu chạm 44×44 px, khoảng cách ≥ 8 px. Không dùng emoji làm icon; icon từ sprite/`Icons` của Flutter.
- Tôn trọng `MediaQuery.disableAnimations`.

Thành phần M1–M5:

- `HudBar` (dải trên): trái = ví sun (icon + số, Fredoka 28); giữa = `PlantCardRow`; phải = nút pause ≥ 44 px.
- `PlantCard` 72×88: icon plant + giá (Nunito 16 bold). State: bình thường / đã chọn (viền `#F59E0B`, scale 1.05, 150 ms) / không đủ sun (desaturate 60%, giá đỏ, nhãn "thiếu sun") / cooldown (lớp tối quét từ trên xuống theo % còn lại + số giây). Mọi state có dấu hiệu chữ/hình, không chỉ màu.
- Phản hồi `plantRejected`: thẻ rung nhẹ 300 ms hoặc số sun nháy đỏ.
- `HugeWaveBanner`: "Đợt tấn công lớn!" Fredoka 40, đỏ trên dải tối, slide-in, tồn tại 3 s.
- `ResultOverlay`: card Claymorphism, tiêu đề "Thắng!"/"Thua…", nút "Chơi lại" và (khi thắng) "Tiếp tục" cao ≥ 48 px. M5 "Tiếp tục" quay về menu tối giản.
- `PauseOverlay`: Tiếp tục / Chơi lại / Thoát.
- `MenuScreen` tối giản (M5): tiêu đề + nút "Chơi level 1". Chọn level đầy đủ và unlock ở M7.

## 7. Asset

- Nguồn: Kenney (CC0), OpenGameArt (lọc CC0). Ứng viên khởi điểm: Kenney *Toon Characters 1* (có zombie), Kenney *Platformer Pack Redux* / *Foliage Pack* (cây, hoa, óc chó thay thế), Kenney *UI Pack* (khung HUD), Kenney *Particle Pack* (đạn, sun). Phải xác minh nội dung thực tế khi đến bước tải; nếu không có sprite phù hợp thì dùng placeholder và ghi vào M6 việc tìm/thay.
- Quy trình: Claude tìm và đề xuất → hỏi xác nhận (tên file, nguồn, dung lượng) → tải vào `assets/images/` → cập nhật `manifest.json` và `assets/CREDITS.md` (nguồn + license).
- Không dùng tên, hình, âm thanh của Plants vs Zombies.

## 8. Test

Chạy bằng `flutter test`, không thêm dev dependency.

| File | Nội dung |
|---|---|
| `test/config/balance_test.dart` | DPS peashooter ≈ 14.3; walker 200 HP; các ID plant/zombie khớp GAME_DESIGN.md |
| `test/data/level_data_test.dart` | parse `level_01.json`; validator bắt 4 lỗi; giá trị mặc định |
| `test/core/game_state_m2_test.dart` | zombie đến `col < 0` → `lost`; gặp plant → `eating`; plant HP về 0 → plant biến mất, zombie `walking` |
| `test/core/game_state_m3_test.dart` | 10 đạn (200 dmg) giết walker; đạn không trúng zombie khác hàng; chỉ bắn khi có mục tiêu cùng hàng |
| `test/core/game_state_m4_test.dart` | không đủ sun → `notEnoughSun`; trừ đúng giá; cooldown chặn spam; sun hết hạn sau 8 s; sunflower sinh 25 sun mỗi 24 s; icepea làm chậm 50% trong 3 s |
| `test/core/game_state_m5_test.dart` | chơi hết `level_01` với kịch bản đặt sẵn → `won`; thêm 1 wave vào JSON (dữ liệu inline) → kết quả khác; hugeWave phát cảnh báo đúng thời điểm |

Verify tay theo ROADMAP thực hiện trên Windows desktop. Verify trên APK Android là bước riêng, thực hiện khi cài xong Android SDK (không chặn M1–M5).

## 9. Cập nhật docs gốc (làm trước code M1)

- `ARCHITECTURE.md`: thêm tầng `lib/core/` (sim thuần Dart), mô tả `SyncLayer`, camera fixed 1280×720, `SpriteRegistry` + manifest, cập nhật cây thư mục và bảng quyết định (thêm dòng "sim core tách khỏi Flame").
- `ROADMAP.md`: ghi chú dev target Windows; verify APK dời sang M5 (thử) và M7 (bắt buộc), sau khi cài Android SDK.
- `README.md`: quick start `flutter create . --platforms=android,windows`.
- `pubspec.yaml`: thêm `assets/fonts/` và mục `fonts:` khi có TTF; thêm `assets/images/manifest.json` vào assets.

## 10. Ngoài phạm vi spec này

10 level, sprite hoàn chỉnh cho mọi entity, animation đầy đủ, âm thanh, chọn level + unlock (`ProgressStore`), kéo-thả trồng cây, build APK release. Những mục này thuộc M6–M7.
