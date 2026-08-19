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

## Ngoài phạm vi MVP (không làm trước khi xong 10 level)

Plant/zombie mới ngoài danh sách trên, chế độ chơi khác, shop/tiền tệ thứ hai, daily reward, multiplayer, cloud save.
