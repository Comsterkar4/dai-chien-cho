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
- **R1** Khi người chơi bấm nút Quay 1 lần hoặc Quay 5 lần → hệ thống bốc thăm ngẫu nhiên thú cưng theo tỷ lệ 5 cấp độ theo BR-06.
- **R2** Khi bốc thăm hoàn tất → hệ thống hiển thị cửa sổ kết quả SC-04 với tên, độ hiếm, chỉ số sức mạnh của thú cưng vừa trúng.
- **R3** Khi người chơi bấm nút Trang bị ngay → hệ thống thay đổi chú chó đang dắt theo sau người chơi theo BR-07.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Tên giống chó | Thú cưng | Ví dụ Chó Lửa Cerberus |
| Cấp độ hiếm | Thú cưng | Thông Thường, Hiếm, Siêu Hiếm, Huyền Thoại, Thần Thoại |
| Tỷ lệ phần trăm | Cấu hình | 50%, 28%, 14%, 6%, 2% |

## Tiêu chí nghiệm thu
### F-04-AC1 · Quay Gacha nhận ngẫu nhiên thú cưng
- Phủ: R1 · Kiểm: e2e
- Cho: người chơi đang mở cửa sổ Gacha
- Khi: bấm nút Quay 1 lần
- Thì: hệ thống trả về kết quả 1 chú chó thuộc 1 trong 5 cấp độ hiếm

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
