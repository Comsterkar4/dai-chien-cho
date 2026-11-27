---
id: F-02
title: Giao diện HUD thú cưng
status: spec
roles: [Người chơi]
goals: [G-01, G-02]
priority: must
phase: 1
ideas: [I-01]
---
# F-02. Giao diện HUD thú cưng

Hiển thị thông tin tên, cấp độ, thanh tiến trình EXP, thanh công cụ cạnh phải và cửa sổ túi đồ.
Vào từ: SC-01, SC-02

## Quy tắc
- **R1** Luôn → hệ thống hiển thị bảng thông tin thú cưng gồm tên, cấp độ và thanh tiến trình kinh nghiệm trực quan theo UI-01.
- **R2** Luôn → hệ thống hiển thị thanh công cụ xếp dọc ở cạnh phải màn hình gồm các nút hành động theo UI-02 và UI-04.
- **R3** Khi người chơi bấm nút Túi đồ → hệ thống mở cửa sổ túi đồ hiển thị danh sách vật phẩm theo SC-02.
- **R4** Luôn → hệ thống hiển thị số dư Xu hiện tại của người chơi trên màn hình chính SC-01 và cập nhật khi số dư thay đổi.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Tên thú cưng | Thú cưng | Ví dụ Shiba |
| Cấp độ | Thú cưng | Nhãn Level |
| Thanh tiến trình | Thú cưng | Hiển thị phần trăm và số điểm |

## Tiêu chí nghiệm thu
### F-02-AC1 · Hiển thị thanh tiến trình kinh nghiệm
- Phủ: R1 · Kiểm: e2e
- Cho: người chơi đang ở trong game với chú chó cấp 1 có 50 trên 100 EXP
- Khi: quan sát giao diện HUD
- Thì: thanh tiến trình hiển thị tỷ lệ 50 phần trăm kèm nhãn 50 trên 100

### F-02-AC2 · Hiển thị thanh công cụ cạnh phải
- Phủ: R2 · Kiểm: e2e
- Cho: người chơi đang ở trong game
- Khi: quan sát khu vực cạnh phải màn hình
- Thì: các nút Cho ăn, Túi đồ, Dắt chó hiển thị ngay ngắn không che khuất phía dưới

### F-02-AC3 · Mở cửa sổ túi đồ
- Phủ: R3 · Kiểm: e2e
- Cho: người chơi đang ở màn hình chính
- Khi: bấm vào nút Túi đồ
- Thì: cửa sổ túi đồ hiển thị ở giữa màn hình kèm danh sách vật phẩm

### F-02-AC4 · Hiển thị và cập nhật số dư Xu trên HUD
- Phủ: R4 · Kiểm: e2e
- Cho: người chơi có 100 Xu ở màn hình chính SC-01
- Khi: số dư Xu tăng thêm 20 Xu
- Thì: màn hình chính SC-01 hiển thị số dư 120 Xu
