---
id: F-07
title: Thú cưng thả vườn tự sinh Xu
status: spec
roles: [Người chơi]
goals: [G-04]
depends: [F-05]
perms: [pet:roam, plot:claim]
ideas: [I-02]
priority: must
phase: 1
---
# F-07. Thú cưng thả vườn tự sinh Xu

Tự động sinh Xu theo thời gian từ các thú cưng đang thả tự do trong khuôn viên vườn riêng và cộng trực tiếp vào Ví Xu của người chơi.
Số dư Ví Xu cập nhật ngay trên giao diện chính sau mỗi chu kỳ sinh Xu.
Vào từ: SC-05 (Khu chuồng thú cưng 6 người chơi) và SC-01 (Giao diện chính MainHUD).

## Quy tắc
- **R1** Trong khi người chơi đang ở trong phòng game và có ít nhất một thú cưng mang trạng thái Đang thả vườn trong khuôn viên vườn riêng (SC-05) → cứ hết mỗi chu kỳ 15 giây, hệ thống tự động sinh 2 Xu cho mỗi thú cưng đang thả theo BR-15, cộng trực tiếp tổng số Xu sinh ra vào Ví Xu theo TR-04 và BR-13, và cập nhật ngay số dư hiển thị trên SC-01 và SC-07 theo UI-06.
- **R2** Luôn → tổng số Xu sinh ra mỗi chu kỳ bằng số lượng thú cưng có trạng thái Đang thả vườn nhân với mức sinh Xu của một thú cưng theo BR-15, áp dụng đồng nhất cho mọi độ hiếm (Common, Rare, Epic, Legendary, Mythic) và không giới hạn số dư Xu tích lũy.
- **R3** Nếu không có thú cưng nào mang trạng thái Đang thả vườn trong khuôn viên vườn riêng → hệ thống không sinh Xu, không thực hiện giao dịch cộng Xu và giữ nguyên số dư Ví Xu.
- **R4** Khi người chơi thay đổi trạng thái thả vườn của thú cưng giữa Đang thả vườn và Không thả vườn → chu kỳ sinh Xu kế tiếp tính theo số lượng thú cưng có trạng thái Đang thả vườn tại thời điểm kết thúc chu kỳ đó.
  [CẦN RÕ: Thú cưng đang được trang bị đồng hành cùng người chơi theo BR-07 có đồng thời giữ trạng thái Đang thả vườn để sinh Xu không?; phương án: Không, chỉ thú cưng ở trong khuôn viên vườn riêng mới sinh Xu / Có, vẫn tính như đang thả vườn; khuyến nghị: Không, để tách biệt rõ nguồn Xu đi dạo ở F-06 với nguồn Xu thả vườn ở F-07]
- **R5** Khi người chơi thoát phòng game hoặc mất kết nối khiến khu chuồng riêng được giải phóng theo BR-08 → hệ thống dừng bộ đếm chu kỳ sinh Xu của khu vườn đó và không cộng Xu cho chu kỳ chưa hoàn tất.
- **R6** Nếu giao dịch cộng Xu vào Ví Xu thất bại do lỗi đồng bộ dữ liệu hoặc số Xu tính ra không phải số nguyên dương theo BR-13 → hệ thống không làm sai lệch số dư Ví Xu hiện có theo BR-11, giữ nguyên trạng thái thả vườn của thú cưng và hiện M1.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Số dư Xu | Ví Xu | Hiển thị dạng số nguyên không âm kèm đơn vị Xu trên SC-01 và SC-07 theo UI-06, cập nhật ngay sau mỗi chu kỳ |
| Danh sách thú cưng đang thả vườn | Thú cưng | Các thú cưng có Trạng thái thả vườn là Đang thả vườn di chuyển trong khuôn viên SC-05 theo BR-10 |

## Thông báo
| Mã | Khi | Nguyên văn |
|---|---|---|
| M1 | Cộng Xu từ vườn vào Ví Xu thất bại do lỗi đồng bộ dữ liệu | "Không thể cập nhật Xu từ vườn thú cưng lúc này. Số dư của bạn vẫn được giữ nguyên." |

## Tiêu chí nghiệm thu
### F-07-AC1 · Sinh Xu định kỳ từ nhiều thú cưng thả vườn
- Phủ: R1, R2, BR-15, UI-06 · Kiểm: e2e
- Cho: người chơi Minh đang ở trong phòng game tại khu chuồng riêng SC-05 với số dư Ví Xu là 100 Xu
- Và: trong vườn có 3 thú cưng mang trạng thái Đang thả vườn gồm Shiba độ hiếm Common, Corgi độ hiếm Epic và Husky độ hiếm Mythic
- Khi: trôi qua đủ 1 chu kỳ 15 giây
- Thì: hệ thống cộng 6 Xu vào Ví Xu của Minh nâng số dư lên 106 Xu
- Và: màn hình chính SC-01 và khung SC-07 cập nhật hiển thị 106 Xu

### F-07-AC2 · Tích lũy liên tục qua nhiều chu kỳ không giới hạn trần
- Phủ: R1, R2, BR-15 · Kiểm: api
- Cho: người chơi Lan đang ở trong phòng game với số dư Ví Xu là 500 Xu và có 5 thú cưng mang trạng thái Đang thả vườn trong khu chuồng riêng
- Khi: trôi qua liên tiếp 3 chu kỳ 15 giây (tổng 45 giây)
- Thì: mỗi chu kỳ hệ thống cộng 10 Xu vào Ví Xu của Lan theo TR-04
- Và: sau 3 chu kỳ số dư Ví Xu của Lan là 530 Xu và không bị chặn bởi giới hạn tích lũy

### F-07-AC3 · Không sinh Xu khi không có thú cưng nào thả vườn
- Phủ: R3 · Kiểm: api
- Cho: người chơi Nam đang ở trong phòng game với số dư Ví Xu là 100 Xu và cả 2 thú cưng đang sở hữu đều có trạng thái Không thả vườn
- Khi: trôi qua đủ 1 chu kỳ 15 giây
- Thì: hệ thống không thực hiện giao dịch cộng Xu và số dư Ví Xu của Nam giữ nguyên 100 Xu

### F-07-AC4 · Cập nhật mức sinh Xu khi thay đổi số thú cưng thả vườn
- Phủ: R4 · Kiểm: api
- Cho: người chơi Minh đang ở trong phòng game với số dư Ví Xu là 100 Xu và có 2 thú cưng mang trạng thái Đang thả vườn
- Khi: ở giây thứ 5 của chu kỳ hiện tại, Minh chuyển thêm 1 thú cưng từ Không thả vườn sang Đang thả vườn và chờ hết chu kỳ 15 giây đó
- Thì: tại thời điểm kết thúc chu kỳ, hệ thống tính cho 3 thú cưng đang thả vườn và cộng 6 Xu vào Ví Xu của Minh nâng số dư lên 106 Xu

### F-07-AC5 · Dừng sinh Xu khi người chơi thoát phòng game
- Phủ: R5 · Kiểm: api
- Cho: người chơi Lan đang ở trong phòng game với số dư Ví Xu là 120 Xu, có 4 thú cưng mang trạng thái Đang thả vườn và chu kỳ hiện tại đã chạy được 10 giây
- Khi: Lan thoát phòng game khiến khu chuồng riêng được giải phóng theo BR-08
- Thì: hệ thống dừng bộ đếm chu kỳ sinh Xu của khu vườn và không cộng Xu cho 10 giây chưa hoàn tất
- Và: số dư Ví Xu của Lan giữ nguyên 120 Xu

### F-07-AC6 · Giữ nguyên số dư và báo lỗi khi đồng bộ Ví Xu thất bại
- Phủ: R6, M1, BR-11, BR-13 · Kiểm: e2e
- Cho: người chơi Minh đang ở trong phòng game với số dư Ví Xu là 100 Xu và có 2 thú cưng mang trạng thái Đang thả vườn
- Khi: hết chu kỳ 15 giây nhưng dịch vụ cập nhật Ví Xu trả về lỗi đồng bộ dữ liệu
- Thì: số dư Ví Xu của Minh giữ nguyên 100 Xu và các thú cưng vẫn giữ trạng thái Đang thả vườn
- Và: màn hình hiện "Không thể cập nhật Xu từ vườn thú cưng lúc này. Số dư của bạn vẫn được giữ nguyên."

## Ghi chú
Cho dev: bộ đếm chu kỳ sinh Xu phải chạy ở phía server để tránh sai lệch đồng hồ client và đảm bảo tính nhất quán với giao dịch cộng Xu của Ví Xu (F-05).

### Giả định
- Số liệu 2 Xu mỗi thú cưng mỗi 15 giây trong các quy tắc và tiêu chí nghiệm thu dùng theo khuyến nghị đang chờ chốt của BR-15.
- Xu thả vườn chỉ sinh khi người chơi đang trực tuyến trong phòng game và đang sở hữu khu chuồng riêng; không tính tích lũy Xu ngoại tuyến.
- Trong đợt này không áp dụng cơ chế chống treo máy (AFK), không giới hạn tốc độ nhận Xu và không áp dụng hệ số nhân Xu theo độ hiếm theo phạm vi tầm nhìn sản phẩm.
