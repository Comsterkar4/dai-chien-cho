---
kind: vision
---
# Tầm nhìn

## Vấn đề
- Người chơi Roblox yêu thích thể loại nuôi thú cưng nhưng cần một vòng lặp chăm sóc trực quan và trải nghiệm tăng cấp sinh động.
- Trò chơi cần kiến trúc rõ ràng để mở rộng các tính năng gacha và thi đấu mà không bị xung đột logic cốt lõi.
- Người chơi hiện có thể quay Gacha nhưng chưa có hệ thống tiền tệ (Xu) và vòng lặp kiếm tiền từ chăm sóc thú cưng hay thả vườn để tạo động lực tích lũy và quay thú cưng mới.

## Người dùng
- Người chơi: Người tham gia nuôi thú cưng, cho ăn, tăng cấp và đưa thú cưng đi thi đấu.

## Mục tiêu
| Mã | Mục tiêu | Đo bằng | Ngưỡng |
|---|---|---|---|
| G-01 | Hoàn thiện vòng lặp nuôi dưỡng cốt lõi MVP | Tỉ lệ người chơi mới hoàn thành cho ăn và lên Level 2 | 90% |
| G-02 | Trải nghiệm phản hồi mượt mà | Thời gian cập nhật thanh EXP và hiệu ứng sau khi bấm Feed | < 200 ms |
| G-03 | Kiến trúc module hóa sẵn sàng mở rộng | Khả năng thêm thú cưng mới qua cấu hình mà không sửa code server | 100% |
| G-04 | Tạo nhịp kiếm Xu nhanh cho lần quay Gacha đầu tiên | Thời gian người chơi mới kiếm đủ 100 Xu qua chăm sóc và thả vườn | 3–5 phút |
| G-05 | Khuyến khích người chơi mới trải nghiệm vòng lặp quay Gacha sớm | Tỉ lệ người chơi mới thực hiện ít nhất 1 lần quay Gacha trong phiên đầu tiên | ≥ 70% |

## Phạm vi

### Trong
- Giai đoạn 1 (MVP): Bãi cỏ sân vườn, model chú chó ban đầu, chức năng cho ăn, tăng EXP, thăng cấp Level, giao diện HUD (tên, cấp, EXP, nút Feed) và hiệu ứng VFX.
- Giai đoạn 2: Nhiều giống chó và mèo, hệ thống Gacha mở thú cưng ngẫu nhiên theo độ hiếm, hệ thống kỹ năng thú cưng.
- Giai đoạn 3: Đấu trường Solo Battle đối kháng, hiệu ứng chiến đấu và hoàn thiện trải nghiệm.
- Hệ thống tiền tệ Xu (Coin): tặng sẵn 100 Xu khởi đầu, kiếm Xu từ hoạt động chăm sóc (cho ăn, lên cấp, dắt đi dạo) và thú cưng thả vườn tự sinh Xu theo thời gian, dùng Xu quay Gacha (100 Xu/lần đơn, 450 Xu/lần x5).

### Ngoài
- Giao dịch thú cưng giữa các người chơi ở phiên bản đầu.
- Hệ thống thanh toán tiền thật Robux ở bản MVP.
- Nạp Robux mua Xu, chuyển Xu giữa người chơi, và bán hoặc phân giải thú cưng lấy Xu.
- Cơ chế chống treo máy (AFK), giới hạn tốc độ nhận Xu và hệ số nhân Xu theo độ hiếm trong đợt này.
