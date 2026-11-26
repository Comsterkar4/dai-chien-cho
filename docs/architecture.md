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

### 2.4. Khu Công Viên Thú Cưng Hoàng Gia - Pet Wonderland (Phía Bắc)
* Khuôn viên đại công viên siêu rộng (126 x 104 studs) với thảm cỏ non tươi mát, hàng rào trắng phong cách châu Âu cao 4.2 studs.
* Cổng chào Hoàng Gia đá cẩm thạch trắng viền vàng cao 16 studs với biển hiệu neon: `✨ CÔNG VIÊN THÚ CƯNG VIP - PET WONDERLAND ✨`.
* Đại lộ đá hoa cương dẫn vào trung tâm công viên với các đường nhánh kết nối các phân khu chức năng.
* Hồ bơi cún cưng (Doggy Splash Pool) nước trong suốt pha lê có đài phun nước 3 tầng (`FountainCenter`) và các phao cứu sinh Donut rực rỡ nổi trên mặt nước.
* Chòi nghỉ mát lục giác Hoàng Gia (Royal Gazebo) bằng gỗ sồi mái ngói đỏ kẹo ngọt, có bàn picnic và ghế nghỉ ngơi.
* Khu vận động thể lực: Cầu trượt kẹo ngọt sắc màu (Playground Slide) có bậc thang và máng trượt dốc, kết hợp 4 vòng nhảy Neon phát sáng vượt chướng ngại vật.
* Vườn cây hoa anh đào (Sakura Grove) rủ cánh hoa hồng rơi lơ lửng, ghế băng công viên gỗ cổ điển (Park Benches) đặt dưới bóng râm.
* Hệ thống 8 điểm phần thưởng phát sáng phong phú: Xương Hoàng Kim (+100 EXP), Xương Bạc (+50 EXP), Bánh Cầu Vồng Thần Kỳ, Quả Bóng Phép Thuật.

### 2.5. Ngã Tư Trung Tâm (Central Crossroads Hub)
* Quảng trường trung tâm lát đá hoa cương có viền neon vàng.
* Cột biển chỉ dẫn 4 hướng bằng gỗ với các mũi tên màu sắc trực quan:
  * ⬆️ CÔNG VIÊN
  * ⬅️ KHU GACHA
  * ➡️ ĐẤU TRƯỜNG
  * ⬇️ 6 KHU CHUỒNG
