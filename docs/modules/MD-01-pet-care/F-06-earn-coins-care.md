---
id: F-06
title: Kiếm Xu từ hoạt động chăm sóc
status: spec
roles: [Người chơi]
goals: [G-04]
depends: [F-01, F-05]
perms: [pet:feed, pet:walk, pet:bag]
ideas: [I-02]
priority: must
phase: 1
---
# F-06. Kiếm Xu từ hoạt động chăm sóc

Thưởng Xu cho người chơi khi cho thú cưng ăn, khi thú cưng thăng cấp và khi dắt thú cưng đi dạo.
Vào từ: SC-01, SC-02, SC-05, nút Feed, vật phẩm thức ăn trong túi đồ hoặc nút Dắt chó

## Quy tắc
- **R1** Khi người chơi bấm nút Feed hợp lệ ngoài thời gian hồi 0.5 giây (BR-03) → hệ thống cộng 2 Xu vào Ví Xu theo TR-04, BR-11, BR-13 và BR-14, đồng thời cập nhật số dư hiển thị trên SC-01 và SC-07 theo UI-06 trong ngưỡng NFR-01.
  [CẦN RÕ: Mức thưởng Xu cụ thể cho mỗi lần bấm Feed, mỗi lần thăng cấp và mỗi chu kỳ 3.5 giây đi dạo là bao nhiêu để khớp BR-14 và đạt mục tiêu G-04?; phương án: Feed +2 Xu, thăng cấp +15 Xu, đi dạo +3 Xu / Feed +5 Xu, thăng cấp +20 Xu, đi dạo +5 Xu; khuyến nghị: Feed +2 Xu, thăng cấp +15 Xu, đi dạo +3 Xu để kết hợp với Xu thả vườn vừa đạt 100 Xu trong 3–5 phút]
- **R2** Khi thú cưng đạt đủ EXP và thăng cấp theo TR-02 và BR-02 → hệ thống cộng thêm 15 Xu vào Ví Xu theo TR-04, BR-11, BR-13 và BR-14, đồng thời cập nhật số dư hiển thị trên SC-01 và SC-07 theo UI-06.
  Nếu thú cưng thăng cấp ngay trong lần bấm nút Feed → hệ thống cộng gộp cả Xu thưởng cho ăn (R1) và Xu thưởng thăng cấp (R2) vào Ví Xu.
- **R3** Trong khi người chơi dắt thú cưng đi dạo và di chuyển liên tục trong sân đủ mỗi chu kỳ 3.5 giây (BR-05) → hệ thống cộng 3 Xu vào Ví Xu theo TR-04, BR-11, BR-13 và BR-14, đồng thời cập nhật số dư hiển thị trên SC-01 và SC-07 theo UI-06.
- **R4** Nếu người chơi bấm nút Feed khi đang trong thời gian hồi 0.5 giây (BR-03) → hệ thống không cộng Xu vào Ví Xu và giữ nguyên số dư hiện tại.
- **R5** Nếu người chơi đang bật dây dắt chó nhưng đứng yên không di chuyển hoặc tắt dây dắt trước khi đủ chu kỳ 3.5 giây (BR-05) → hệ thống không cộng Xu đi dạo và giữ nguyên số dư hiện tại.
- **R6** Khi người chơi dùng vật phẩm thức ăn từ túi đồ SC-02 (F-01-R5) → hệ thống không cộng Xu thưởng của nút Feed, chỉ cộng Xu thưởng thăng cấp theo R2 nếu thú cưng đủ EXP thăng cấp [CẦN RÕ: Dùng vật phẩm thức ăn từ túi đồ SC-02 có được cộng Xu như bấm nút Feed không?; phương án: Không cộng Xu trực tiếp, chỉ cộng Xu thăng cấp nếu đủ EXP / Cộng cùng mức Xu như bấm nút Feed; khuyến nghị: Không cộng Xu trực tiếp, chỉ cộng Xu thăng cấp nếu đủ EXP để giữ cân bằng nhịp kiếm Xu].
- **R7** Nếu mất kết nối máy chủ hoặc Ví Xu chưa được khởi tạo khi phát sinh sự kiện cộng Xu → hệ thống không ghi nhận giao dịch cộng Xu ở máy khách, giữ nguyên số dư hợp lệ trên máy chủ theo BR-11 và đồng bộ lại số dư thực tế khi kết nối ổn định.
- **R8** Luôn → mức Xu thưởng từ các hoạt động chăm sóc áp dụng đồng nhất cho mọi độ hiếm thú cưng và không áp dụng giới hạn tích trữ hay cơ chế chống treo máy (AFK) theo BR-14.

## Dữ liệu hiển thị
| Thông tin | Nguồn | Ghi chú |
|---|---|---|
| Số dư Xu | Ví Xu | Hiển thị số nguyên không âm kèm đơn vị Xu trên SC-01 và SC-07 theo UI-06 |
| Cấp độ | Thú cưng | Tăng thêm 1 khi thăng cấp và kích hoạt thưởng Xu thăng cấp |
| EXP hiện tại | Thú cưng | Tăng khi cho ăn hoặc đi dạo để tiến tới ngưỡng thăng cấp |

## Tiêu chí nghiệm thu
### F-06-AC1 · Nhận Xu khi bấm nút Feed hợp lệ
- Phủ: R1, BR-11, BR-13, BR-14, UI-06, NFR-01 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu và chú chó Shiba cấp 1 có 0 trên 100 EXP tại SC-01, nút Feed đã hết thời gian hồi
- Khi: người chơi bấm nút Feed
- Thì: số dư Ví Xu tăng lên 102 Xu và chú chó nhận thêm 25 EXP
- Và: màn hình SC-01 và SC-07 cập nhật hiển thị 102 Xu trong thời gian dưới 200 ms

### F-06-AC2 · Cộng gộp Xu cho ăn và Xu thăng cấp khi đủ EXP
- Phủ: R1, R2, BR-02, BR-14, UI-06 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu và chú chó Shiba cấp 1 có 75 trên 100 EXP tại SC-01
- Khi: người chơi bấm nút Feed
- Thì: chú chó thăng lên cấp 2 với 0 trên 150 EXP
- Và: số dư Ví Xu tăng thêm 17 Xu thành 117 Xu và hiển thị 117 Xu trên SC-01 và SC-07

### F-06-AC3 · Nhận Xu định kỳ khi dắt thú cưng đi dạo
- Phủ: R3, BR-05, BR-14, UI-06 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu và đang bật dây dắt chú chó Shiba trong sân SC-05
- Khi: người chơi di chuyển liên tục cùng thú cưng trong 3.5 giây
- Thì: số dư Ví Xu tăng lên 103 Xu và hiển thị 103 Xu trên SC-01 và SC-07

### F-06-AC4 · Không cộng Xu khi bấm Feed trong thời gian hồi
- Phủ: R4, BR-03 · Kiểm: api
- Cho: người chơi có Ví Xu với số dư 102 Xu vừa bấm nút Feed cách đó 0.2 giây
- Khi: người chơi bấm nút Feed lần nữa trước khi hết 0.5 giây hồi
- Thì: giao dịch cộng Xu không được ghi nhận và số dư Ví Xu giữ nguyên 102 Xu

### F-06-AC5 · Không cộng Xu đi dạo khi đứng yên
- Phủ: R5, BR-05 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu đang bật dây dắt chú chó Shiba trong sân SC-05
- Khi: người chơi đứng yên không di chuyển trong 5 giây
- Thì: số dư Ví Xu giữ nguyên 100 Xu trên SC-01 và SC-07

### F-06-AC6 · Dùng vật phẩm thức ăn từ túi đồ chưa đủ EXP thăng cấp không cộng Xu
- Phủ: R6 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu, chú chó Shiba cấp 1 có 0 trên 100 EXP và túi đồ SC-02 có 5 miếng thịt tươi cộng 50 EXP mỗi miếng
- Khi: người chơi dùng 1 miếng thịt tươi từ túi đồ SC-02
- Thì: chú chó tăng lên 50 trên 100 EXP và số dư Ví Xu giữ nguyên 100 Xu

### F-06-AC7 · Giữ nguyên số dư máy chủ khi mất kết nối lúc cộng Xu
- Phủ: R7, BR-11 · Kiểm: e2e
- Cho: người chơi có Ví Xu trên máy chủ là 100 Xu và kết nối mạng tới máy chủ bị gián đoạn
- Khi: người chơi bấm nút Feed trong lúc mất kết nối
- Thì: máy chủ không ghi nhận giao dịch cộng Xu và khi kết nối lại giao diện đồng bộ hiển thị 100 Xu

### F-06-AC8 · Thưởng Xu đồng nhất cho mọi độ hiếm thú cưng
- Phủ: R8, R1, BR-14 · Kiểm: api
- Cho: người chơi có Ví Xu với số dư 100 Xu đang trang bị thú cưng độ hiếm Mythic
- Khi: người chơi bấm nút Feed hợp lệ
- Thì: số dư Ví Xu tăng đúng 2 Xu thành 102 Xu mà không áp dụng hệ số nhân theo độ hiếm

### F-06-AC9 · Dùng vật phẩm thức ăn từ túi đồ đủ EXP thăng cấp chỉ cộng Xu thăng cấp
- Phủ: R6, R2, BR-02, BR-14, UI-06 · Kiểm: e2e
- Cho: người chơi có Ví Xu với số dư 100 Xu, chú chó Shiba cấp 1 có 50 trên 100 EXP và túi đồ SC-02 có 5 miếng thịt tươi cộng 50 EXP mỗi miếng
- Khi: người chơi dùng 1 miếng thịt tươi từ túi đồ SC-02
- Thì: chú chó thăng lên cấp 2 với 0 trên 150 EXP
- Và: số dư Ví Xu tăng đúng 15 Xu thành 115 Xu mà không cộng 2 Xu của nút Feed, đồng thời hiển thị 115 Xu trên SC-01 và SC-07

## Ghi chú
Cho dev: logic cộng Xu của R1, R2 và R3 phải thực hiện phía máy chủ (Server) gắn trực tiếp vào sự kiện cho ăn, thăng cấp và chu kỳ đi dạo của F-01 để tránh gian lận từ máy khách.

### Giả định
- Mức thưởng cụ thể (Feed +2 Xu, thăng cấp +15 Xu, đi dạo +3 Xu mỗi 3.5 giây) đang viết theo khuyến nghị của BR-14 và sẽ cập nhật lại nếu người chốt con số khác.
- Nếu một hành động làm thú cưng tăng nhiều cấp liên tiếp thì thưởng Xu thăng cấp được tính cho từng cấp đã tăng.
