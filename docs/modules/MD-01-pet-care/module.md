---
id: MD-01
kind: module
title: Chăm sóc thú cưng
depends: [MD-02]
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
| Trạng thái thả vườn | Cho biết thú cưng có đang được thả tự do trong khuôn viên vườn riêng hay không | Bắt buộc, một trong Đang thả vườn, Không thả vườn |

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
- **BR-10** Khi thú cưng ở trong khuôn viên vườn riêng → hệ thống tự động điều khiển di chuyển tự do, linh hoạt trong phạm vi rào chắn (đi dạo ngẫu nhiên, ghé thăm bát ăn, bát nước, đệm nằm, dốc đồ chơi) với hiệu ứng bước đi nhấp nhô vui vẻ (Bouncy Walk) và hành vi ngẫu nhiên (ngửi đất, nhảy cẫng, xoay vòng) mà không vượt quá hàng rào.
- **BR-14** Khi người chơi thực hiện hoạt động chăm sóc thú cưng (bấm nút Feed, thú cưng thăng cấp hoặc dắt thú cưng đi dạo di chuyển đủ chu kỳ 3.5 giây) → hệ thống tự động cộng Xu thưởng vào Ví Xu (MD-02) theo mức thưởng của từng hoạt động [CẦN RÕ: Mức thưởng Xu cụ thể cho mỗi lần bấm Feed, mỗi lần thăng cấp và mỗi chu kỳ 3.5 giây dắt đi dạo là bao nhiêu để người chơi mới đạt mục tiêu G-04 (kiếm đủ 100 Xu trong 3–5 phút)?; phương án: Feed +2 Xu, thăng cấp +15 Xu, đi dạo +3 Xu mỗi 3.5 giây / Feed +5 Xu, thăng cấp +20 Xu, đi dạo +5 Xu mỗi 3.5 giây; khuyến nghị: Feed +2 Xu, thăng cấp +15 Xu, đi dạo +3 Xu mỗi 3.5 giây để kết hợp với Xu thả vườn vừa đạt 100 Xu trong khoảng 3–5 phút].
- **BR-15** Trong khi thú cưng có trạng thái Đang thả vườn trong khuôn viên vườn riêng → hệ thống tự động sinh Xu theo chu kỳ cố định cho mỗi thú cưng đang thả và cộng trực tiếp vào Ví Xu (MD-02), không áp dụng hệ số nhân theo độ hiếm và không giới hạn mức Xu tích trữ [CẦN RÕ: Mỗi thú cưng đang thả trong vườn tự sinh bao nhiêu Xu và theo chu kỳ bao nhiêu giây để đạt mục tiêu G-04 (kiếm đủ 100 Xu trong 3–5 phút)?; phương án: 2 Xu mỗi thú cưng mỗi 15 giây / 1 Xu mỗi thú cưng mỗi 10 giây; khuyến nghị: 2 Xu mỗi thú cưng mỗi 15 giây để dễ quan sát tiến trình cộng Xu mà không làm lạm phát quá nhanh khi thả 5 đến 10 thú cưng].

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
| SC-01 | Giao diện chính MainHUD | . | Chứa thẻ thông tin thú cưng, khu vực hiển thị số dư Xu hiện tại và thanh công cụ cạnh phải |
| SC-02 | Cửa sổ túi đồ InventoryModal | . | Hiển thị danh sách vật phẩm thức ăn và đồ chơi |
| SC-03 | Cửa sổ quay GachaModal | . | Hiển thị tỷ lệ 5 cấp độ và nút quay x1 (100 Xu), x5 (450 Xu) |
| SC-04 | Cửa sổ kết quả GachaResultPopup | . | Hiển thị thú cưng vừa trúng kèm nút trang bị |
| SC-05 | Khu chuồng thú cưng 6 người chơi | . | 6 khuôn viên riêng biệt có nhà doghouse, hàng rào và bát ăn |
| SC-06 | Quảng trường Gacha và Đấu trường Solo | . | Khu vực quay trứng thần bí và võ đài chiến đấu solo |

## Dùng của mảng khác
- Đọc số dư và cộng trừ Xu trên thực thể Ví Xu của MD-02 (hiển thị trên SC-01 ở F-02, trừ Xu khi quay Gacha ở F-04, cộng Xu từ chăm sóc ở F-06 và từ thú cưng thả vườn ở F-07).
