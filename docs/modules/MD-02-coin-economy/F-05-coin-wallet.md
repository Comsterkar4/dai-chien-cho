---
id: F-05
title: Ví Xu và tặng Xu khởi đầu
status: spec
roles: [Người chơi]
goals: [G-05]
ideas: [I-02]
priority: must
phase: 1
---
# F-05. Ví Xu và tặng Xu khởi đầu

Khởi tạo 100 Xu cho người chơi mới và quản lý cộng trừ số dư Xu không âm.
Số dư Ví Xu được hiển thị liên tục để người chơi theo dõi quá trình tích lũy Xu.
Vào từ: SC-07 (Khung hiển thị Ví Xu (CoinHUD)), hiển thị sẵn trên giao diện chính khi người chơi vào trò chơi.

## Quy tắc
- **R1** Khi người chơi mới gia nhập trò chơi lần đầu và chưa có Ví Xu → hệ thống khởi tạo Ví Xu ở trạng thái Đang hoạt động theo TR-03 với Số dư Xu bằng 100, đặt Đã nhận Xu khởi đầu là đúng theo BR-12 và hiển thị số dư trên SC-07 theo UI-06.
- **R2** Khi người chơi đã có Ví Xu với Đã nhận Xu khởi đầu là đúng gia nhập lại trò chơi → hệ thống không tặng lại 100 Xu khởi đầu theo BR-12 và hiển thị đúng Số dư Xu hiện có trên SC-07 theo UI-06.
- **R3** Khi hệ thống ghi nhận giao dịch cộng Xu hợp lệ (số nguyên dương theo BR-13) → cộng số Xu tương ứng vào Số dư Xu của Ví Xu theo TR-04, bảo đảm số dư không âm theo BR-11 và cập nhật ngay hiển thị trên SC-07 theo UI-06.
- **R4** Khi hệ thống ghi nhận giao dịch trừ Xu hợp lệ (số nguyên dương theo BR-13) và Số dư Xu lớn hơn hoặc bằng số Xu cần trừ → trừ số Xu tương ứng khỏi Số dư Xu của Ví Xu theo TR-05, bảo đảm số dư không âm theo BR-11 và cập nhật ngay hiển thị trên SC-07 theo UI-06.
- **R5** Nếu giao dịch trừ Xu có số lượng lớn hơn Số dư Xu hiện tại → hệ thống từ chối giao dịch và giữ nguyên Số dư Xu hiện tại theo BR-11.
- **R6** Nếu giao dịch cộng hoặc trừ Xu có số lượng bằng 0, số âm hoặc không phải số nguyên → hệ thống từ chối giao dịch và giữ nguyên Số dư Xu hiện tại theo BR-13.
- **R7** Nếu có nhiều giao dịch cộng hoặc trừ Xu xảy ra đồng thời trên cùng một Ví Xu → hệ thống xử lý tuần tự từng giao dịch để bảo đảm Số dư Xu không bao giờ âm theo BR-11 và không mất lượt cập nhật.
- **R8** Nếu mất kết nối giữa giao diện và máy chủ trong lúc giao dịch Xu → hệ thống giữ nguyên Số dư Xu đã ghi nhận trên máy chủ theo BR-11 và đồng bộ lại số dư lên SC-07 theo UI-06 khi kết nối phục hồi.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Số dư Xu | Ví Xu | Số nguyên không âm kèm đơn vị Xu theo UI-06, hiển thị trên SC-07 |

## Tiêu chí nghiệm thu
### F-05-AC1 · Khởi tạo Ví Xu và tặng 100 Xu khởi đầu cho người chơi mới
- Phủ: R1, BR-12, UI-06 · Kiểm: e2e
- Cho: người chơi Minh lần đầu gia nhập trò chơi và chưa có Ví Xu
- Khi: Minh hoàn tất vào trò chơi
- Thì: hệ thống tạo Ví Xu cho Minh ở trạng thái Đang hoạt động với Số dư Xu bằng 100 và Đã nhận Xu khởi đầu là đúng
- Và: khung hiển thị SC-07 hiển thị 100 Xu

### F-05-AC2 · Người chơi cũ gia nhập lại không nhận thêm Xu khởi đầu
- Phủ: R2, BR-12, UI-06 · Kiểm: e2e
- Cho: người chơi Minh đã có Ví Xu với Đã nhận Xu khởi đầu là đúng và Số dư Xu bằng 40
- Khi: Minh gia nhập lại trò chơi
- Thì: Số dư Xu của Minh giữ nguyên bằng 40, không cộng thêm 100 Xu khởi đầu
- Và: khung hiển thị SC-07 hiển thị 40 Xu

### F-05-AC3 · Cộng Xu hợp lệ vào Ví Xu
- Phủ: R3, BR-11, BR-13, UI-06 · Kiểm: e2e
- Cho: người chơi Lan có Ví Xu đang hoạt động với Số dư Xu bằng 100
- Khi: hệ thống ghi nhận giao dịch cộng 25 Xu cho Lan
- Thì: Số dư Xu của Lan tăng lên 125
- Và: khung hiển thị SC-07 cập nhật hiển thị 125 Xu

### F-05-AC4 · Trừ Xu hợp lệ khi đủ số dư
- Phủ: R4, BR-11, BR-13, UI-06 · Kiểm: e2e
- Cho: người chơi Hùng có Ví Xu đang hoạt động với Số dư Xu bằng 500
- Khi: hệ thống ghi nhận giao dịch trừ 450 Xu cho Hùng
- Thì: Số dư Xu của Hùng giảm còn 50
- Và: khung hiển thị SC-07 cập nhật hiển thị 50 Xu

### F-05-AC5 · Từ chối trừ Xu khi số dư không đủ
- Phủ: R5, BR-11 · Kiểm: api
- Cho: người chơi Hùng có Ví Xu đang hoạt động với Số dư Xu bằng 50
- Khi: hệ thống nhận yêu cầu trừ 100 Xu từ Ví Xu của Hùng
- Thì: giao dịch bị từ chối và Số dư Xu của Hùng giữ nguyên bằng 50

### F-05-AC6 · Từ chối giao dịch với số lượng Xu không phải số nguyên dương
- Phủ: R6, BR-13 · Kiểm: api
- Cho: người chơi Lan có Ví Xu đang hoạt động với Số dư Xu bằng 100
- Khi: hệ thống nhận yêu cầu cộng 0 Xu vào Ví Xu của Lan
- Thì: giao dịch bị từ chối và Số dư Xu của Lan giữ nguyên bằng 100

### F-05-AC7 · Xử lý tuần tự hai giao dịch trừ Xu đồng thời
- Phủ: R7, BR-11 · Kiểm: api
- Cho: người chơi Minh có Ví Xu đang hoạt động với Số dư Xu bằng 100
- Khi: hai yêu cầu trừ 100 Xu được gửi đồng thời tới Ví Xu của Minh
- Thì: đúng một yêu cầu thành công làm Số dư Xu giảm về 0 và yêu cầu còn lại bị từ chối
- Và: Số dư Xu của Minh không giảm xuống dưới 0

### F-05-AC8 · Đồng bộ lại số dư Ví Xu sau khi mất kết nối
- Phủ: R8, BR-11, UI-06 · Kiểm: e2e
- Cho: người chơi Lan có Ví Xu đang hoạt động với Số dư Xu bằng 100 và bị mất kết nối ngay khi máy chủ vừa cộng 20 Xu
- Khi: kết nối của Lan phục hồi
- Thì: Số dư Xu phía máy chủ là 120 và khung hiển thị SC-07 đồng bộ hiển thị 120 Xu

## Ghi chú
Cho dev: toàn bộ kiểm tra số dư và cộng trừ Xu (R3, R4, R5, R6, R7) phải thực hiện ở phía máy chủ trong cùng một luồng xử lý tuần tự để tránh lỗi số dư âm khi có nhiều yêu cầu đồng thời; phía giao diện chỉ hiển thị dữ liệu đồng bộ từ máy chủ lên SC-07.

### Giả định
- Dữ liệu Ví Xu (Số dư Xu và Đã nhận Xu khởi đầu) gắn với Mã người chơi và được duy trì xuyên suốt các phiên chơi.
- Các tính năng phát sinh hoặc tiêu thụ Xu (chăm sóc thú cưng, thả vườn, quay Gacha) gọi giao dịch cộng trừ qua Ví Xu thay vì tự thay đổi số dư trực tiếp.
