<!-- pp-kit:begin -->
## pp-kit

Tài liệu sản phẩm nằm ở `docs/` (đọc `docs/README.md` trước). Mỗi tính năng là một file `docs/modules/MD-xx-*/F-xx-*.md` trong thư mục mảng của nó, cạnh `module.md` của mảng.
- `<kit>` là thư mục plugin pp-kit trên máy bạn (đường tuyệt đối; repo này không giữ bản chép script nào). Claude Code chèn dòng `pp-kit: <kit>` ở đầu phiên. Không có dòng đó (OMP, hook tắt): nạp skill `pp-kit:spec-ask` và lấy `<kit>` theo mục Đầu vào của nó.
- Trước khi code F-xx: chạy `node <kit>/scripts/ctx.mjs F-xx --docs docs` ở gốc repo và đọc hết kết quả (F, mảng của F: thực thể, vòng đời, quy tắc, quyền, màn hình, luồng; quy tắc chung, phi chức năng, vai, thay đổi gần đây, test case, task).
- Gói ctx mở đầu bằng "CÒN … CÂU HỎI [CẦN RÕ]": không code phần liên quan tới câu hỏi đó; hỏi người phụ trách.
- Commit và PR code ghi mã AC đã làm (vd. `F-03-AC1, F-03-AC2`).
- Không sửa `docs/modules/` trong PR code, trừ hai dòng `status`, `built` của F ở PR code cuối (dòng dưới). Spec sai hay thiếu: sửa qua `/pp-kit:ba-master` trên nhánh `spec/*` riêng.
- PR code cuối của F, khi code đã khớp F và trước khi rebase hay merge main vào nhánh: người dev đặt `status: built` và `built: { at: YYYY-MM-DD, code: [<thư mục hay file chính>], pr: "#<số>" }` trong frontmatter của F, chạy `node <kit>/scripts/stale.mjs accept F-xx --in built --docs docs`, commit vào chính PR đó. Agent không làm việc này.
- Gói `ctx` có dòng `> CODE ĐI SAU SPEC`, hay bình luận CI của PR có `BUILT-BEHIND`: code lại đúng các mã nó nêu trước khi làm việc khác; `> F ĐÃ BỎ, CODE CÒN`: không code thêm theo F đó.
<!-- pp-kit:end -->
