# Pet Dog Simulator - Kiến trúc & Kế hoạch triển khai MVP

## 1. Tổng quan dự án
* **Tên dự án:** Pet Dog Simulator
* **Mục tiêu Giai đoạn 1 (MVP):** Người chơi vào game sở hữu 1 chú chó ban đầu, có thể cho chó ăn, nhận EXP, tăng Level, hiển thị HUD đẹp mắt và có hiệu ứng thăng cấp.

## 2. Kiến trúc hệ thống trong Roblox Studio

### 2.1. Workspace (Môi trường & Models)
* `GameMap`: Khu vực bãi cỏ rộng rãi, hàng rào gỗ, cây cối trang trí phong cách Low-Poly / Roblox Simulator.
* `PetModel`: Model chú chó ban đầu (Shiba / Puppy) có animation đi theo người chơi hoặc đứng cạnh người chơi.

### 2.2. ReplicatedStorage (Giao tiếp & Dữ liệu chia sẻ)
* `Events`:
  * `FeedPet` (RemoteEvent): Client gửi yêu cầu cho thú cưng ăn.
  * `UpdatePetData` (RemoteEvent): Server gửi dữ liệu cập nhật (EXP, Level, Stats) về Client.
* `Modules`:
  * `PetConfig`: Bảng dữ liệu cấu hình giống thú cưng, lượng EXP mỗi lần ăn, công thức EXP lên cấp (`MaxEXP = Level * 100`).

### 2.3. ServerScriptService (Xử lý Backend Game)
* `PetServer`:
  * Khởi tạo dữ liệu Pet cho người chơi khi gia nhập game.
  * Xử lý xác thực cho ăn (cooldown chống spam click).
  * Tính toán tăng EXP và kích hoạt thăng cấp (Level Up).
  * Spawn pet và gán quyền sở hữu cho người chơi.

### 2.4. StarterGui (Giao diện người dùng - HUD)
* `MainHUD` (ScreenGui):
  * **PetInfoCard:** Khung hiển thị Tên Pet, Cấp độ (Level), Thanh EXP tiến trình (ProgressBar) có chữ `EXP: xx/xx`.
  * **ActionButtonPanel:** 
    * Nút `FEED` to rõ, màu cam/xanh bắt mắt, có hiệu ứng nảy nút (bounce) khi bấm.
    * Các nút tính năng mở rộng: `Pets`, `Gacha`, `Battle` (tạm thời đánh dấu mở ở Giai đoạn sau).

### 2.5. StarterPlayerScripts (Client Logic)
* `PetController`: Bắt sự kiện bấm nút Feed, gửi request lên Server, hiển thị hiệu ứng âm thanh và hạt ánh sáng (Particle/VFX) khi lên cấp.

---

## 3. Các bước triển khai Giai đoạn 1 (MVP)
1. **Bước 1:** Dựng Map khu vườn xanh cho Pet Simulator (bãi cỏ, hàng rào, cây cối, ánh sáng rực rỡ).
2. **Bước 2:** Tạo Model chú chó đầu tiên (Shiba Inu phong cách Roblox dễ thương) và gắn hiệu ứng hạt quanh chân.
3. **Bước 3:** Tạo các RemoteEvents trong `ReplicatedStorage` và code `PetServer` trong `ServerScriptService`.
4. **Bước 4:** Thiết kế giao diện `MainHUD` trong `StarterGui` (Thanh EXP, Level, nút Feed).
5. **Bước 5:** Thêm hiệu ứng VFX khi cho ăn và khi lên cấp (Level Up).
6. **Bước 6:** Chạy Playtest trực tiếp để kiểm tra trải nghiệm thực tế.
