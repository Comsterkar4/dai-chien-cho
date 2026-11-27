---
id: CR-01
kind: change
title: Bổ sung hiển thị số dư Xu trên HUD và trừ Xu khi quay Gacha
requested_at: 2026-11-27
affects: [SC-01, SC-03, F-02-R4, F-02-AC4, F-04-R1, F-04-R4, F-04-M1, F-04-AC1, F-04-AC4, F-04-AC5, F-04-AC6]
status: done
ideas: [I-02]
---
# CR-01. Bổ sung hiển thị số dư Xu trên HUD và trừ Xu khi quay Gacha

## Lý do
Bổ sung đơn vị tiền tệ Xu vào vòng lặp chơi theo I-02: hiển thị số dư Xu hiện tại trên giao diện chính và yêu cầu trả Xu khi quay Gacha (100 Xu cho 1 lần, 450 Xu cho 5 lần), đồng thời chặn quay khi không đủ Xu.

## Thay đổi
- SC-01 · sửa · bổ sung khu vực hiển thị số dư Xu hiện tại trên giao diện chính MainHUD; câu cũ: `Chứa thẻ thông tin thú cưng và thanh công cụ cạnh phải`
- SC-03 · sửa · bổ sung hiển thị giá 100 Xu (x1) và 450 Xu (x5) trên cửa sổ quay GachaModal; câu cũ: `Hiển thị tỷ lệ 5 cấp độ và nút quay x1 x5`
- F-02-R4 · thêm · hiển thị số dư Xu hiện tại của người chơi trên màn hình chính SC-01 và cập nhật khi số dư thay đổi
- F-02-AC4 · thêm · kiểm tra hiển thị và cập nhật số dư Xu trên màn hình chính SC-01 khi số dư tăng
- F-04-R1 · sửa · trừ 100 Xu khi quay 1 lần hoặc 450 Xu khi quay 5 lần trong Ví Xu khi đủ Xu trước khi bốc thăm thú cưng theo BR-06; câu cũ: `Khi người chơi bấm nút Quay 1 lần hoặc Quay 5 lần → hệ thống bốc thăm ngẫu nhiên thú cưng theo tỷ lệ 5 cấp độ theo BR-06.`
- F-04-R4 · thêm · không thực hiện lượt quay, giữ nguyên số dư Xu và hiện M1 khi người chơi không đủ Xu cho lượt quay đã chọn
- F-04-M1 · thêm · thông báo "Không đủ Xu để thực hiện lượt quay này." khi không đủ Xu
- F-04-AC1 · sửa · kiểm tra quay 1 lần trừ 100 Xu (100 Xu còn 0 Xu) và trả về 1 chú chó thuộc 1 trong 5 cấp độ hiếm; câu cũ: `Cho: người chơi đang mở cửa sổ Gacha · Khi: bấm nút Quay 1 lần · Thì: hệ thống trả về kết quả 1 chú chó thuộc 1 trong 5 cấp độ hiếm`
- F-04-AC4 · thêm · kiểm tra quay 5 lần trừ 450 Xu (500 Xu còn 50 Xu) và trả về 5 chú chó ngẫu nhiên
- F-04-AC5 · thêm · kiểm tra không đủ Xu khi quay 1 lần (50 Xu) thì giữ nguyên số dư và hiện M1
- F-04-AC6 · thêm · kiểm tra không đủ Xu khi quay 5 lần (300 Xu) thì giữ nguyên số dư và hiện M1

## Ảnh hưởng
- Test case: không có test case nào dựa trên mã đã đổi.
- Task cũ ở `tasks/F-04.md`:
  - `F-04-T01` (dựa trên `F-04-R1`, `F-04-AC1`)
  - `F-04-T04` (dựa trên `F-04-AC1`)
