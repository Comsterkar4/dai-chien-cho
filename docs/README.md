# Tài liệu sản phẩm

Cây này theo khuôn docs của pp-kit 3.0.
Sản phẩm chia thành mảng nghiệp vụ, mỗi mảng một thư mục `modules/MD-xx-<tên>/` gồm `module.md` và các tính năng `F-xx-<tên>.md` của mảng; PR merge vào nhánh mặc định là duyệt.

<!-- pp-kit:map:begin -->
## Bản đồ tính năng

Engine ghi khối này (`map.mjs --write`), không sửa tay. Mỗi mảng nghiệp vụ một bảng; vòng đời đầy đủ của F (đã merge, test case, task) xem bằng `/pp-kit:next`.

### [MD-01](modules/MD-01-pet-care/module.md) · Chăm sóc thú cưng

Quản lý thông tin và sự phát triển của thú cưng do người chơi sở hữu.

| F | Tên | Vai | App | Giai đoạn | Ưu tiên | Phụ thuộc | Câu hỏi mở |
|---|---|---|---|---|---|---|---|
| [F-01](modules/MD-01-pet-care/F-01-cho-an-tang-cap.md) | Cho ăn và tăng cấp thú cưng | Người chơi | — | 1 | must | — | 0 |
| [F-02](modules/MD-01-pet-care/F-02-giao-dien-hud.md) | Giao diện HUD thú cưng | Người chơi | — | 1 | must | — | 0 |
| [F-03](modules/MD-01-pet-care/F-03-hieu-ung-thu-cung.md) | Hiệu ứng phát triển thú cưng | Người chơi | — | 1 | must | — | 0 |
| [F-06](modules/MD-01-pet-care/F-06-earn-coins-care.md) | Kiếm Xu từ hoạt động chăm sóc | Người chơi | — | 1 | must | F-01, F-05 | 0 |
| [F-07](modules/MD-01-pet-care/F-07-garden-coin-income.md) | Thú cưng thả vườn tự sinh Xu | Người chơi | — | 1 | must | F-05 | 0 |
| [F-04](modules/MD-01-pet-care/F-04-quay-gacha-thu-cung.md) | Vòng quay Gacha thú cưng | Người chơi | — | 2 | should | — | 0 |

### [MD-02](modules/MD-02-coin-economy/module.md) · Kinh tế Xu

Quản lý đơn vị tiền tệ Xu, khởi tạo số dư ban đầu và ghi nhận cộng trừ số dư Xu của người chơi.

| F | Tên | Vai | App | Giai đoạn | Ưu tiên | Phụ thuộc | Câu hỏi mở |
|---|---|---|---|---|---|---|---|
| [F-05](modules/MD-02-coin-economy/F-05-coin-wallet.md) | Ví Xu và tặng Xu khởi đầu | Người chơi | — | 1 | must | — | 0 |

### Quyền

| Quyền | Mảng | Vai | F |
|---|---|---|---|
| pet:feed | MD-01 | Người chơi | F-06 |
| pet:walk | MD-01 | Người chơi | F-06 |
| pet:bag | MD-01 | Người chơi | F-06 |
| pet:gacha | MD-01 | Người chơi | — |
| pet:equip | MD-01 | Người chơi | — |
| pet:roam | MD-01 | Người chơi | F-07 |
| plot:claim | MD-01 | Người chơi | F-07 |

### Thực thể

| Thực thể | Mảng | Chuyển trạng thái |
|---|---|---|
| Thú cưng | MD-01 | TR-01, TR-02 |
| Ví Xu | MD-02 | TR-03, TR-04, TR-05 |

### Thay đổi gần đây

- CR-01 (2026-11-27): Bổ sung hiển thị số dư Xu trên HUD và trừ Xu khi quay Gacha → F-02, F-04, SC-01, SC-03
<!-- pp-kit:map:end -->

## Đọc gì trước

1. `product/vision.md`: vấn đề, người dùng, mục tiêu (G-xx), phạm vi.
2. `modules/`: các mảng nghiệp vụ (bản đồ ở trên).
3. `module.md` của mảng: thực thể, vòng đời (TR-xx), quy tắc của mảng (BR-xx), quyền, màn hình (SC-xx), luồng.
4. `F-xx-*.md` trong thư mục mảng: quy tắc (R), thông báo (M), tiêu chí nghiệm thu (F-xx-ACn) của từng tính năng.
5. Phần còn lại của `product/`: vai, quy tắc xuyên mảng, quy ước giao diện, phi chức năng, quan hệ giữa các mảng, thuật ngữ, hệ thống ngoài.
6. `tests/F-xx.md`, `tasks/F-xx.md`: test case và task sinh từ tính năng đã merge.

Trước khi code F-xx, chạy `ctx F-xx` của pp-kit để có đủ ngữ cảnh trong một lần đọc (kể cả task và thay đổi gần đây).

## Mã nằm ở đâu

| Mã | Nằm ở |
|---|---|
| G-xx | `product/vision.md`, mục Mục tiêu |
| MD-xx | thư mục `modules/MD-xx-*/`, file `module.md` |
| TR-xx | `modules/MD-xx-*/module.md`, mục Vòng đời |
| SC-xx | `modules/MD-xx-*/module.md`, mục Màn hình |
| F-xx | `modules/MD-xx-*/F-xx-*.md` |
| R, M trong F (F-xx-Rn, F-xx-Mn khi trỏ từ ngoài) | mục Quy tắc, Thông báo của F |
| F-xx-ACn | mục Tiêu chí nghiệm thu của F |
| BR-xx | `product/rules.md` (xuyên mảng) hay mục Quy tắc của `module.md` (của một mảng) |
| UI-xx | `product/ui.md` |
| NFR-xx | `product/nfr.md` |
| EXT-xx | `product/integrations.md` |
| I-xx | `ideas/I-xx-*.md` (ghi chú khám phá, không phải yêu cầu) |
| CR-xx | `changes/CR-xx-*.md` |
| F-xx-TCnn | `tests/F-xx.md` |
| F-xx-Tnn | `tasks/F-xx.md` |

Mã đã cấp không dùng lại; mục bỏ giữ mã và bị gạch.
Vai, thực thể và quyền trỏ bằng tên, khớp `product/roles.md` và mục Thực thể, Quyền của `module.md`.
`kit/.run/` là chỗ tạm của các lượt chạy, không commit.
