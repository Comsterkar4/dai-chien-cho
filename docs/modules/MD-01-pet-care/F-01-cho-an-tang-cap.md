---
id: F-01
title: Cho ăn và tăng cấp thú cưng
status: spec
roles: [Người chơi]
goals: [G-01, G-02]
priority: must
phase: 1
ideas: [I-01]
---
# F-01. Cho ăn và tăng cấp thú cưng

Cho phép người chơi cho thú cưng ăn, dắt chó đi dạo để nhận EXP và tăng cấp độ khi tích lũy đủ EXP.
Vào từ: SC-01, SC-05, nút Feed, nút Dắt chó hoặc SC-02

## Quy tắc
- **R1** Khi người chơi gia nhập game lần đầu → hệ thống khởi tạo thú cưng cấp 1 với 0 điểm kinh nghiệm theo TR-01 và BR-01.
- **R2** Khi người chơi bấm nút Feed → hệ thống cộng 25 điểm EXP cho thú cưng đang chọn theo BR-03.
- **R3** Khi điểm EXP của thú cưng đạt hoặc vượt mức EXP tối đa của cấp hiện tại → hệ thống tăng Level thêm 1 theo TR-02, nâng EXP tối đa và tăng điểm sức mạnh theo BR-02 và BR-04.
- **R4** Khi người chơi dắt thú cưng đi dạo di chuyển trong công viên → hệ thống cộng 15 điểm EXP định kỳ theo BR-05.
- **R5** Khi người chơi mở túi đồ và dùng vật phẩm thức ăn → hệ thống trừ 1 số lượng vật phẩm và cộng điểm EXP tương ứng cho thú cưng.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Cấp độ | Thú cưng | Hiển thị số nguyên từ 1 |
| Điểm EXP hiện tại | Thú cưng | Tăng 25 mỗi lần ăn |
| Điểm EXP tối đa | Thú cưng | Cấp 1 là 100, tăng 50 mỗi cấp |

## Tiêu chí nghiệm thu
### F-01-AC1 · Người chơi bấm Feed nhận 25 EXP
- Phủ: R2 · Kiểm: e2e
- Cho: người chơi sở hữu chú chó cấp 1 có 0 EXP trên 100 EXP
- Khi: người chơi bấm nút Feed
- Thì: điểm EXP của chú chó tăng lên 25 trên 100 EXP

### F-01-AC2 · Thú cưng đủ EXP tự động thăng cấp
- Phủ: R3 · Kiểm: e2e
- Cho: chú chó cấp 1 có 75 EXP trên 100 EXP
- Khi: người chơi bấm nút Feed
- Thì: chú chó tăng lên cấp 2 và điểm EXP hiển thị là 0 trên 150 EXP

### F-01-AC3 · Khởi tạo thú cưng ban đầu
- Phủ: R1 · Kiểm: e2e
- Cho: người chơi mới lần đầu vào game
- Khi: hệ thống hoàn tất tải dữ liệu
- Thì: người chơi sở hữu 1 chú chó cấp 1 với 0 trên 100 EXP

### F-01-AC4 · Dắt chó đi dạo nhận EXP định kỳ
- Phủ: R4 · Kiểm: e2e
- Cho: người chơi đang bật dây dắt chó
- Khi: người chơi di chuyển liên tục trong 3.5 giây
- Thì: chú chó nhận 15 điểm EXP và thanh kinh nghiệm tăng lên tương ứng

### F-01-AC5 · Dùng thức ăn từ túi đồ
- Phủ: R5 · Kiểm: e2e
- Cho: người chơi mở túi đồ có 5 miếng thịt tươi
- Khi: người chơi bấm nút Cho ăn ở ô thịt tươi
- Thì: số lượng thịt tươi giảm còn 4 và chú chó nhận 50 điểm EXP
