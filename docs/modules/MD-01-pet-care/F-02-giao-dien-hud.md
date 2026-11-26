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

Hiển thị thông tin tên, cấp độ, thanh tiến trình EXP và các nút chức năng trên màn hình người chơi.
Vào từ: SC-01

## Quy tắc
- **R1** Luôn → hệ thống hiển thị bảng thông tin thú cưng gồm tên, cấp độ và thanh tiến trình kinh nghiệm trực quan theo UI-01.
- **R2** Luôn → hệ thống hiển thị nút Feed to nổi bật ở phía dưới màn hình và các nút chức năng phụ theo UI-02.

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

### F-02-AC2 · Hiển thị nút Feed
- Phủ: R2 · Kiểm: e2e
- Cho: người chơi đang ở trong game
- Khi: quan sát khu vực dưới màn hình
- Thì: nút Feed hiển thị nổi bật với màu sắc tươi sáng
