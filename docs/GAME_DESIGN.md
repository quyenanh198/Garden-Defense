# Thiết kế gameplay (MVP)

Nguồn sự thật cho số liệu cân bằng. Khi code, mirror các số này vào `lib/config/balance.dart` — nếu hai nơi lệch nhau, docs thắng.

## Vòng lặp cốt lõi

Thu sun → trồng plant → chặn/diệt zombie → sống sót hết wave → thắng level → mở level kế.

## Sun economy

| Thông số | Giá trị | Ghi chú |
|---|---|---|
| Sun khởi đầu | theo level (JSON) | mặc định 50 |
| Sun từ trời | 25 sun / ~10 giây | rơi vị trí ngẫu nhiên, tồn tại 8s rồi biến mất |
| Sun từ hoa mặt trời | 25 sun / 24 giây | rơi ngay cạnh cây |
| Giá trị 1 sun tap | +25 vào ví | tap để thu |

## Plants (4 loại MVP)

| ID | Tên | Giá (sun) | HP | Hành động | Cooldown trồng |
|---|---|---|---|---|---|
| `sunflower` | Hoa mặt trời | 50 | 300 | Sinh 25 sun mỗi 24s | 7.5s |
| `peashooter` | Cây bắn đậu | 100 | 300 | Bắn 1 đạn (20 dmg) mỗi 1.4s khi có zombie cùng hàng | 7.5s |
| `wallnut` | Quả óc chó | 50 | 4000 | Không hành động — tường chắn | 30s |
| `icepea` | Đậu băng | 175 | 300 | Đạn 20 dmg + làm chậm zombie 50% trong 3s | 7.5s |

Quy tắc: chỉ bắn khi có mục tiêu cùng hàng (tiết kiệm tính toán, đúng cảm giác gốc).

## Zombies (3 loại MVP)

| ID | Tên | HP | Tốc độ | Damage cắn | Ghi chú |
|---|---|---|---|---|---|
| `walker` | Zombie thường | 200 | 1 ô / 4.7s | 100 dmg/s | lính cơ bản |
| `cone` | Zombie nón | 560 | 1 ô / 4.7s | 100 dmg/s | tanky hơn |
| `bucket` | Zombie xô | 1300 | 1 ô / 4.7s | 100 dmg/s | mini-boss giai đoạn đầu |

Điểm chuẩn cân bằng: 1 peashooter DPS ≈ 14.3 → giết walker trong ~14s (~3 ô di chuyển). Nếu chỉnh số, giữ tỷ lệ này làm mốc.

## Điều kiện thắng / thua

- **Thua**: bất kỳ zombie nào chạm mép trái (qua cột 0).
- **Thắng**: đã spawn hết mọi wave trong level và không còn zombie sống trên sân.

## Cấu trúc độ khó 10 level đầu

| Level | Dạy người chơi | Nội dung mới |
|---|---|---|
| 1 | Trồng + bắn | chỉ peashooter, 1 hàng zombie |
| 2 | Kinh tế sun | mở sunflower |
| 3 | Phòng thủ | mở wallnut |
| 4 | Áp lực nhiều hàng | zombie 3 hàng |
| 5 | Zombie trâu | xuất hiện cone |
| 6 | Wave dồn dập | "huge wave" cuối level |
| 7 | Kiểm soát | mở icepea |
| 8 | Quản lý tài nguyên | sun khởi đầu thấp |
| 9 | Tổng hợp | xuất hiện bucket |
| 10 | Boss wave | mọi loại zombie, mật độ cao |

## Chế độ Endless (M8)

Chế độ sinh tồn không có điều kiện thắng: sống sót càng nhiều đợt càng tốt. Thua khi zombie chạm mép trái; kết quả = số đợt đã sống sót.

### Lưới theo nền tảng

| Nền tảng | Lưới | Ghi chú |
|---|---|---|
| Desktop (Windows/Linux/macOS) | 10×20 | không gian ảo 1280×720 giữ nguyên, ô nhỏ lại |
| Android | 5×9 | như campaign |

Lưới campaign luôn là 5×9 trên mọi nền tảng. Kích thước ô = vùng lưới (1040×600) chia đều theo số hàng/cột.

### Sinh đợt (procedural)

| Thông số | Giá trị |
|---|---|
| Sun khởi đầu | 150, mở cả 4 plant, có sun trời |
| Đợt đầu tiên | t = 20s |
| Nhịp giữa các đợt | 18s − 0.25s × (số đợt đã qua), sàn 6s |
| Cỡ đợt | 1 + đợt÷5 zombie, hàng ngẫu nhiên; trần 2×số hàng |
| Huge wave | mỗi đợt thứ 10: cỡ đợt ×2, có banner cảnh báo trước 3s |
| Tỷ lệ loại zombie | roll ngẫu nhiên mỗi con: bucket 20% (từ đợt 8), cone 30% (từ đợt 3), còn lại walker |

Sinh đợt dùng seed của ván (deterministic để test được).

### Upgrade cây (chỉ trong Endless)

Tap vào cây đã trồng khi **không** chọn thẻ nào → nâng cấp. Mỗi cây nâng cấp đúng 1 lần.

| Thông số | Giá trị |
|---|---|
| Giá | 2× giá gốc của cây |
| Hiệu lực chung | +HP gốc (wallnut 4000→8000, cây khác 300→600) |
| peashooter / icepea | damage đạn ×2 (20→40); icepea giữ nguyên slow |
| sunflower | sun sinh ra ×2 (25→50), nhịp giữ nguyên |

## Ngoài phạm vi MVP (không làm trước khi xong 10 level)

Plant/zombie mới ngoài danh sách trên, chế độ chơi khác ngoài Endless (M8), shop/tiền tệ thứ hai, daily reward, multiplayer, cloud save.
