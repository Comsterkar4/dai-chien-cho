---
id: F-03
title: Hiệu ứng phát triển thú cưng
status: spec
roles: [Người chơi]
goals: [G-01, G-02]
priority: must
phase: 1
ideas: [I-01]
---
# F-03. Hiệu ứng phát triển thú cưng

Tạo hiệu ứng hình ảnh sinh động khi thú cưng ăn thức ăn và khi thăng cấp độ.
Vào từ: SC-01

## Quy tắc
- **R1** Khi thú cưng nhận thức ăn → hệ thống phát hiệu ứng hạt thức ăn xuất hiện quanh miệng thú cưng.
- **R2** Khi thú cưng thăng cấp độ → hệ thống kích hoạt cột ánh sáng vàng rực rỡ và phát tia hạt ánh sáng xung quanh thú cưng.

## Tiêu chí nghiệm thu
### F-03-AC1 · Hiệu ứng khi ăn thức ăn
- Phủ: R1 · Kiểm: e2e
- Cho: chú chó đang đứng cạnh người chơi
- Khi: người chơi bấm nút Feed
- Thì: hiệu ứng hạt thức ăn xuất hiện quanh miệng chú chó

### F-03-AC2 · Hiệu ứng khi thú cưng thăng cấp
- Phủ: R2 · Kiểm: e2e
- Cho: chú chó chuẩn bị tăng lên cấp 2
- Khi: điểm kinh nghiệm đạt ngưỡng thăng cấp
- Thì: cột ánh sáng thăng cấp xuất hiện bao quanh chú chó trong 2 giây
