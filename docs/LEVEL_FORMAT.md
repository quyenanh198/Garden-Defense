# Định dạng level (JSON)

Mỗi level là một file `assets/levels/level_XX.json`. Thêm level mới = thêm file, **không sửa code Dart**. Parser: `lib/data/level_data.dart`.

## Schema

```jsonc
{
  "id": 1,                      // số thứ tự, trùng tên file
  "name": "Bãi cỏ đầu tiên",     // hiện ở màn chọn level
  "startingSun": 50,            // sun khởi đầu
  "availablePlants": [          // plant được phép dùng — theo ID trong GAME_DESIGN.md
    "peashooter"
  ],
  "skySuns": true,              // có sun rơi từ trời không
  "waves": [                    // danh sách zombie spawn, sắp theo time tăng dần
    { "time": 20,  "zombie": "walker", "row": 2 },
    { "time": 45,  "zombie": "walker", "row": 1 },
    { "time": 60,  "zombie": "walker", "row": 3, "hugeWave": true }
  ]
}
```

## Quy tắc field

| Field | Kiểu | Bắt buộc | Ghi chú |
|---|---|---|---|
| `id` | int | ✔ | duy nhất, dùng cho unlock tiến độ |
| `name` | string | ✔ | |
| `startingSun` | int | ✔ | |
| `availablePlants` | string[] | ✔ | ID phải tồn tại trong balance — parser reject ID lạ |
| `skySuns` | bool | ✖ (mặc định `true`) | |
| `waves` | object[] | ✔ | ít nhất 1 entry |
| `waves[].time` | number (giây) | ✔ | tính từ lúc trận bắt đầu |
| `waves[].zombie` | string | ✔ | ID phải tồn tại trong balance |
| `waves[].row` | int 0–4 | ✔ | 0 = hàng trên cùng |
| `waves[].hugeWave` | bool | ✖ | hiện cảnh báo "đợt tấn công lớn" trước 3s |

## Quy tắc thiết kế level

- Zombie đầu tiên không sớm hơn giây 15–20 (người chơi cần gây dựng kinh tế).
- Khoảng cách wave giảm dần về cuối level để tạo cao trào.
- Level dạy plant mới: đưa plant đó vào `availablePlants` và thiết kế wave buộc phải dùng nó.
- Validator (khi viết) phải bắt: ID lạ, `row` ngoài 0–4, `waves` rỗng, `time` không tăng dần.
