---
id: MD-02
kind: module
title: Kinh tế Xu
---
# MD-02. Kinh tế Xu

Quản lý đơn vị tiền tệ Xu, khởi tạo số dư ban đầu và ghi nhận cộng trừ số dư Xu của người chơi.

## Thực thể
### Ví Xu
| Thuộc tính | Nghĩa | Ràng buộc |
|---|---|---|
| Mã người chơi | Định danh duy nhất của người chơi sở hữu ví | Bắt buộc, duy nhất, mỗi người chơi có đúng một Ví Xu |
| Số dư Xu | Số lượng Xu hiện có của người chơi | Bắt buộc, số nguyên không âm từ 0 trở lên theo BR-11 |
| Đã nhận Xu khởi đầu | Đánh dấu người chơi mới đã nhận 100 Xu ban đầu hay chưa | Bắt buộc, đúng hoặc sai, chỉ chuyển sang đúng một lần duy nhất |

## Vòng đời
### Ví Xu
| Mã | Từ | Sự kiện | Sang | Điều kiện |
|---|---|---|---|---|
| TR-03 | (mới) | Người chơi mới gia nhập game lần đầu | Đang hoạt động | BR-12 |
| TR-04 | Đang hoạt động | Ghi nhận giao dịch cộng Xu hợp lệ | Đang hoạt động | BR-11, BR-13 |
| TR-05 | Đang hoạt động | Ghi nhận giao dịch trừ Xu hợp lệ | Đang hoạt động | BR-11, BR-13 |

## Quy tắc
- **BR-12** Khi người chơi mới gia nhập game lần đầu → hệ thống khởi tạo Ví Xu với số dư ban đầu là 100 Xu và chỉ tặng một lần duy nhất cho mỗi người chơi.
- **BR-13** Luôn → mỗi giao dịch cộng hoặc trừ Xu chỉ chấp nhận số lượng là số nguyên dương và cập nhật trực tiếp vào số dư Ví Xu theo BR-11.

## Màn hình
| Mã | Màn hình | App | Ghi chú |
|---|---|---|---|
| SC-07 | Khung hiển thị Ví Xu (CoinHUD) | . | Hiển thị số dư Xu hiện tại kèm đơn vị Xu theo UI-06, nhúng trên giao diện chính của trò chơi |
