# Pet Dog Simulator - Kiến trúc & Quy hoạch bản đồ thế giới

## 1. Tổng quan dự án
* **Tên dự án:** Pet Dog Simulator
* **Quy mô phòng:** Tối đa 6 người chơi cùng tham gia.
* **Cấu trúc thế giới:** Bản đồ chia thành 4 phân khu chuyên biệt kết nối qua Ngã Tư Trung Tâm (Central Crossroads Hub).

## 2. Quy hoạch 4 phân khu trên bản đồ (280 x 280 studs)

### 2.1. Khu 6 Chuồng Riêng Cho 6 Người Chơi (Phía Nam)
* **Quy mô:** 6 khuôn viên riêng biệt (Plot 1 đến Plot 6, kích thước 28x28 studs mỗi chuồng) bố trí dọc Đại lộ miền Nam.
* **Chi tiết mỗi chuồng:**
  * Ngôi nhà thú cưng Doghouse bằng gỗ có mái chữ A sắc màu riêng biệt (Đỏ, Xanh biển, Xanh lá, Cam, Tím, Hồng).
  * Hàng rào trắng bao quanh với cổng vào và biển tên cá nhân hóa (`🐾 CHUỒNG #X - Chủ: [Tên Player]`).
  * Bát thức ăn (`Bát Thức Ăn`), bát nước (`Bát Nước`) và đệm lót nằm êm ái.
  * Điểm xuất phát riêng (`PlotSpawn`) - người chơi vào game sẽ tự động spawn tại chuồng của mình.

### 2.2. Khu Quảng Trường Gacha Thần Bí (Phía Tây)
* Sàn đá hoa cương tím huyền bí (đường kính 44 studs) viền neon phát sáng.
* Cổng chào mạ vàng `⭐ KHU QUAY GACHA ⭐`.
* Bệ hoa cương với Trứng Thần Bí khổng lồ bay lơ lửng, hiệu ứng sao lấp lánh và 4 trụ tinh thể pha lê.
* Tương tác mở Vòng quay Gacha 5 cấp độ hiếm (50% Thường, 28% Hiếm, 14% Siêu Hiếm, 6% Huyền Thoại, 2% Thần Thoại).

### 2.3. Khu Đấu Trường Solo Pet (Phía Đông)
* Sàn võ đài nâng cao (đường kính 42 studs, cao 3 studs) bằng bê tông cốt thép viền đỏ rực lửa.
* Cổng chào kim loại `⚔️ ĐẤU TRƯỜNG SOLO PET ⚔️`.
* Võ đài trung tâm với 4 cột góc, dây thừng sàn đấu và 2 vòng tròn thi đấu: Góc Đỏ vs Góc Xanh.

### 2.4. Khu Công Viên Thú Cưng (Phía Bắc)
* Khuôn viên bãi cỏ xanh rộng lớn (90 x 80 studs) có hàng rào bao quanh.
* Cổng vòm gỗ `🌳 CÔNG VIÊN THÚ CƯNG 🌳`.
* Chướng ngại vật dạo chơi cho thú cưng: 3 bục nhảy gỗ (Agility Hurdles), 2 vòng nhảy neon (Agility Hoops).
* Rải rác các khúc xương phát sáng (`Pickups`) để cún nhặt khi dắt đi dạo.

### 2.5. Ngã Tư Trung Tâm (Central Crossroads Hub)
* Quảng trường trung tâm lát đá hoa cương có viền neon vàng.
* Cột biển chỉ dẫn 4 hướng bằng gỗ với các mũi tên màu sắc trực quan:
  * ⬆️ CÔNG VIÊN
  * ⬅️ KHU GACHA
  * ➡️ ĐẤU TRƯỜNG
  * ⬇️ 6 KHU CHUỒNG
