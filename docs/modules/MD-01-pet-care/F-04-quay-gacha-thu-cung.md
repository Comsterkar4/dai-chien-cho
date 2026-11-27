---
id: F-04
title: Vòng quay Gacha thú cưng
status: spec
roles: [Người chơi]
goals: [G-01, G-02]
priority: should
phase: 2
ideas: [I-01]
---
# F-04. Vòng quay Gacha thú cưng

Quay nhận ngẫu nhiên các giống thú cưng theo 5 cấp độ hiếm và trang bị thú cưng đồng hành.
Vào từ: SC-01, SC-06, nút Gacha trên thanh công cụ hoặc SC-03

## Quy tắc
- **R1** Khi người chơi bấm nút Quay 1 lần (100 Xu) hoặc Quay 5 lần (450 Xu) và có đủ Xu → hệ thống thực hiện giao dịch trừ tương ứng 100 Xu hoặc 450 Xu trong Ví Xu theo TR-05, BR-11, BR-13 và chỉ bốc thăm ngẫu nhiên 1 hoặc 5 thú cưng theo BR-06 khi giao dịch trừ Xu thành công.
- **R2** Khi bốc thăm hoàn tất → hệ thống hiển thị cửa sổ kết quả SC-04 với tên, độ hiếm, chỉ số sức mạnh của thú cưng vừa trúng.
- **R3** Khi người chơi bấm nút Trang bị ngay → hệ thống thay đổi chú chó đang dắt theo sau người chơi theo BR-07.
- **R4** Nếu người chơi không đủ Xu cho lượt quay đã chọn (dưới 100 Xu khi quay 1 lần, dưới 450 Xu khi quay 5 lần) → hệ thống từ chối lượt quay, giữ nguyên số dư Xu theo BR-11 và hiện M1.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Tên giống chó | Thú cưng | Ví dụ Chó Lửa Cerberus |
| Cấp độ hiếm | Thú cưng | Thông Thường, Hiếm, Siêu Hiếm, Huyền Thoại, Thần Thoại |
| Tỷ lệ phần trăm | Cấu hình | 50%, 28%, 14%, 6%, 2% |

## Thông báo
| Mã | Khi | Nguyên văn |
|---|---|---|
| M1 | Không đủ Xu cho lượt quay đã chọn | "Không đủ Xu để thực hiện lượt quay này." |

## Tiêu chí nghiệm thu
### F-04-AC1 · Quay Gacha nhận ngẫu nhiên thú cưng
- Phủ: R1 · Kiểm: e2e
- Cho: người chơi đang có 100 Xu và mở cửa sổ Gacha
- Khi: bấm nút Quay 1 lần
- Thì: hệ thống trừ 100 Xu (số dư còn 0 Xu) và trả về kết quả 1 chú chó thuộc 1 trong 5 cấp độ hiếm

### F-04-AC2 · Hiển thị kết quả quay và độ hiếm
- Phủ: R2 · Kiểm: e2e
- Cho: vòng quay vừa hoàn tất
- Khi: quan sát cửa sổ kết quả
- Thì: hiển thị hình đại diện, tên giống chó, nhãn cấp độ hiếm và chỉ số sức mạnh cơ bản

### F-04-AC3 · Trang bị thú cưng mới trúng
- Phủ: R3 · Kiểm: e2e
- Cho: người chơi vừa quay trúng chú chó mới
- Khi: bấm nút Trang bị ngay
- Thì: chú chó mới xuất hiện bên cạnh người chơi thay thế cho chú chó cũ

### F-04-AC4 · Quay 5 lần giảm giá bằng Xu
- Phủ: R1 · Kiểm: e2e
- Cho: người chơi có 500 Xu và mở cửa sổ Gacha
- Khi: bấm nút Quay 5 lần
- Thì: hệ thống trừ 450 Xu (số dư còn 50 Xu) và trả về kết quả 5 chú chó ngẫu nhiên

### F-04-AC5 · Không đủ Xu khi Quay 1 lần
- Phủ: R4, M1, BR-11 · Kiểm: e2e
- Cho: người chơi có 50 Xu và mở cửa sổ Gacha
- Khi: bấm nút Quay 1 lần
- Thì: hệ thống không thực hiện lượt quay, số dư giữ nguyên 50 Xu và hiện "Không đủ Xu để thực hiện lượt quay này."

### F-04-AC6 · Không đủ Xu khi Quay 5 lần
- Phủ: R4, M1, BR-11 · Kiểm: e2e
- Cho: người chơi có 300 Xu và mở cửa sổ Gacha
- Khi: bấm nút Quay 5 lần
- Thì: hệ thống không thực hiện lượt quay, số dư giữ nguyên 300 Xu và hiện "Không đủ Xu để thực hiện lượt quay này."

## Lịch sử

<!-- pp-kit:history — engine ghi (history.mjs --write), không sửa tay -->
- 2026-11-27 · CR-01 · F-04-R1 · sửa · trừ 100 Xu khi quay 1 lần hoặc 450 Xu khi quay 5 lần trong Ví Xu khi đủ Xu trước khi bốc thăm thú cưng theo BR-06
- 2026-11-27 · CR-01 · F-04-R4 · thêm · không thực hiện lượt quay, giữ nguyên số dư Xu và hiện M1 khi người chơi không đủ Xu cho lượt quay đã chọn
- 2026-11-27 · CR-01 · F-04-M1 · thêm · thông báo "Không đủ Xu để thực hiện lượt quay này." khi không đủ Xu
- 2026-11-27 · CR-01 · F-04-AC1 · sửa · kiểm tra quay 1 lần trừ 100 Xu (100 Xu còn 0 Xu) và trả về 1 chú chó thuộc 1 trong 5 cấp độ hiếm
- 2026-11-27 · CR-01 · F-04-AC4 · thêm · kiểm tra quay 5 lần trừ 450 Xu (500 Xu còn 50 Xu) và trả về 5 chú chó ngẫu nhiên
- 2026-11-27 · CR-01 · F-04-AC5 · thêm · kiểm tra không đủ Xu khi quay 1 lần (50 Xu) thì giữ nguyên số dư và hiện M1
- 2026-11-27 · CR-01 · F-04-AC6 · thêm · kiểm tra không đủ Xu khi quay 5 lần (300 Xu) thì giữ nguyên số dư và hiện M1
