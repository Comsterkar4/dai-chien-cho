---
id: MD-01
kind: module
title: Chăm sóc thú cưng
---
# MD-01. Chăm sóc thú cưng

Quản lý thông tin và sự phát triển của thú cưng do người chơi sở hữu.
Cung cấp cơ chế cho ăn, dắt thú cưng đi dạo, quản lý túi đồ thức ăn, vòng quay Gacha, khu chuồng riêng và thăng cấp độ.

## Thực thể
### Thú cưng
| Thuộc tính | Nghĩa | Ràng buộc |
|---|---|---|
| Mã định danh | Mã duy nhất của thú cưng | Bắt buộc, chuỗi ký tự |
| Loài | Tên giống thú cưng | Bắt buộc, ví dụ Shiba |
| Độ hiếm | Cấp bậc phân loại từ vòng quay | Bắt buộc, một trong Common, Rare, Epic, Legendary, Mythic |
| Giới tính | Phân loại giống đực hoặc cái | Bắt buộc, một trong Male, Female |
| Cấp độ | Cấp độ phát triển hiện tại | Bắt buộc, số nguyên dương từ 1 |
| EXP hiện tại | Điểm kinh nghiệm đã tích lũy | Bắt buộc, số nguyên từ 0 |
| EXP tối đa | Ngưỡng điểm để thăng cấp tiếp theo | Bắt buộc, số nguyên dương |
| Sức mạnh | Chỉ số chiến đấu cơ bản | Bắt buộc, số nguyên dương |

## Vòng đời
### Thú cưng
| Mã | Từ | Sự kiện | Sang | Điều kiện |
|---|---|---|---|---|
| TR-01 | (mới) | Người chơi vào game | Cấp 1 | BR-01 |
| TR-02 | Đang nuôi | Cho ăn đủ điểm EXP | Thăng cấp | BR-02 |

## Quy tắc
- **BR-01** Khi người chơi gia nhập game lần đầu → hệ thống tự động cấp một thú cưng khởi đầu là chú chó Shiba ở cấp độ 1.
- **BR-02** Khi thú cưng nhận đủ điểm kinh nghiệm đạt ngưỡng thăng cấp → hệ thống tự động tăng Level thêm 1 và trừ điểm kinh nghiệm theo ngưỡng của cấp đó.
- **BR-03** Khi người chơi bấm nút Feed → hệ thống cộng 25 điểm EXP cho thú cưng đang chọn và áp dụng thời gian hồi 0.5 giây.
- **BR-04** Khi thăng cấp → hệ thống tăng EXP tối đa thêm 50 điểm và tăng sức mạnh thêm 5 điểm.
- **BR-05** Khi dắt thú cưng đi dạo di chuyển trong sân → hệ thống cộng 15 điểm EXP định kỳ mỗi 3.5 giây.
- **BR-06** Khi người chơi quay Gacha → hệ thống chọn ngẫu nhiên thú cưng theo 5 cấp độ với tỷ lệ: Thông Thường (50%), Hiếm (28%), Siêu Hiếm (14%), Huyền Thoại (6%), Thần Thoại (2%).
- **BR-07** Khi người chơi trang bị thú cưng mới → hệ thống chuyển linh thú đồng hành theo người chơi và cập nhật lại chỉ số sức mạnh tương ứng.
- **BR-08** Khi người chơi gia nhập phòng game → hệ thống tự động gán 1 trong 6 chuồng thú cưng riêng biệt có biển tên hiển thị tên người chơi và điểm xuất phát tại chuồng; khi người chơi thoát → chuồng được giải phóng về trạng thái sẵn sàng.
- **BR-09** Khi người chơi sở hữu nhiều thú cưng → có thể thả từ 5 đến 10 chú chó ra dạo chơi tự do trong khuôn viên vườn riêng của mình; mỗi chú chó mang giới tính Đực (♂) hoặc Cái (♀) với đặc điểm ngoại hình riêng biệt.

## Quyền
| Quyền | Nghĩa | Vai |
|---|---|---|
| pet:feed | Cho thú cưng ăn | Người chơi |
| pet:walk | Dắt thú cưng đi dạo | Người chơi |
| pet:bag | Mở túi đồ hành trang | Người chơi |
| pet:gacha | Quay vòng quay thú cưng | Người chơi |
| pet:equip | Trang bị thú cưng | Người chơi |
| pet:roam | Thả thú cưng tự do trong vườn | Người chơi |
| plot:claim | Sở hữu chuồng riêng trong phòng | Người chơi |

## Màn hình
| Mã | Màn hình | App | Ghi chú |
|---|---|---|---|
| SC-01 | Giao diện chính MainHUD | . | Chứa thẻ thông tin thú cưng và thanh công cụ cạnh phải |
| SC-02 | Cửa sổ túi đồ InventoryModal | . | Hiển thị danh sách vật phẩm thức ăn và đồ chơi |
| SC-03 | Cửa sổ quay GachaModal | . | Hiển thị tỷ lệ 5 cấp độ và nút quay x1 x5 |
| SC-04 | Cửa sổ kết quả GachaResultPopup | . | Hiển thị thú cưng vừa trúng kèm nút trang bị |
| SC-05 | Khu chuồng thú cưng 6 người chơi | . | 6 khuôn viên riêng biệt có nhà doghouse, hàng rào và bát ăn |
| SC-06 | Quảng trường Gacha và Đấu trường Solo | . | Khu vực quay trứng thần bí và võ đài chiến đấu solo |
