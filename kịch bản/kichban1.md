# DỰ ÁN GAME 2D: LỖI LOGIC TRÁI TIM (Runtime Error: Heartbeat)
**TẬP 1: Cú Va Chạm Ở Quán Cà Phê & Khóa Học Kèm Bất Đắc Dĩ**
* **Thể loại:** 2D Visual Novel kết hợp Mini-game tương tác nhẹ nhàng (Mobile Web / PWA).
* **Cảm hứng cốt truyện:** Kết hợp hình tượng đại thần IT (*Yêu Em Từ Cái Nhìn Đầu Tiên*), chàng coder ngông nghênh nhưng ấm áp và nàng công chúa nhỏ (*Chiếc Bật Lửa Và Váy Công Chúa*), cùng nhịp điệu hài hước, ngọt ngào (*Vụng Trộm Không Thể Giấu*).

---

## I. HỒ SƠ NHÂN VẬT & THIẾT LẬP "VIBE" (CHARACTER PROFILES)

### 1. Nam Chính: Anh Đức (21 tuổi)
* **Tạo hình (Dựa trên bản vẽ 2D):** Tóc nâu hạt dẻ đánh rối tự nhiên, đeo khuyên tai bạc tròn, mặc áo polo đen và quần tối màu phom rộng, đi sneaker trắng, đeo balo đen một bên vai.
* **Tính cách & Vibe:** "Đại thần" khoa Công nghệ thông tin. Vẻ ngoài lãng tử, ánh mắt hơi bất cần đời, vừa biết code giỏi vừa biết đàn hát, chơi thể thao và đi làm thêm pha chế cực mượt. Bình thường nói chuyện kiểu "mỏ hỗn" duyên dáng, hay trêu chọc người khác bằng mặt tỉnh bơ, nhưng thực chất cực kỳ tinh tế, luôn âm thầm để ý và xử lý rắc rối giúp nữ chính.
* **Trạng thái Sprite trong game:**
  * `Normal`: Đút một tay vào túi quần, miệng nhếch mép cười nhẹ.
  * `Teasing` (Trêu chọc): Nghiêng đầu, ánh mắt lém lỉnh.
  * `Awkward/Blush` (Ngại): Đưa tay gãi đầu hoặc quay mặt đi chỗ khác, hai má ửng đỏ khi bị nữ chính "tấn công" bất ngờ bằng sự ngây thơ.

### 2. Nữ Chính: KyKy (19 tuổi)
* **Tạo hình (Dựa trên bản vẽ 2D):** Tóc xoăn nâu buộc đuôi ngựa lỏng, cặp kính gọng tròn to che nửa khuôn mặt bầu bĩnh, đeo túi chéo trắng kem, tay ôm cuốn sổ tay bìa cứng.
* **Tính cách & Vibe:** "Nàng công chúa nhỏ" được gia đình chiều chuộng, đang chuẩn bị hồ sơ đi du học. Tràn đầy năng lượng tích cực, cười lên là mắt cong thành hình trăng khuyết. Hơi ngốc nghếch chuyện đời sống, não cá vàng, hay bày trò quậy phá vô tri nhưng không ai giận nổi. Điểm yếu chí mạng: Mù công nghệ và sợ ma.
* **Trạng thái Sprite trong game:**
  * `Happy`: Cười tít mắt, hai má hồng hào, xung quanh nảy hiệu ứng hoa nở.
  * `Shock/Panic`: Mắt mở to tròn sau lớp kính, miệng chữ O khi làm sai chuyện gì đó.
  * `Pout` (Dỗi/Bối rối): Lông mày cụp xuống, hai tay ôm chặt cuốn sổ trước ngực.

### 3. Nhân Vật Phụ (Tạo chất xúc tác)
* **Anh Quản Lý M (26 tuổi):** Chủ quán cà phê Acoustic nơi Anh Đức làm part-time. Ông mai bất đắc dĩ, tính tình hài hước, hay tạo cơ hội (hoặc tạo nghiệp) đẩy thuyền cho hai nhân vật chính.
* **Hội bạn thân (Thảo & Nam):** Hai "quân sư quạt mo" cùng nhóm đồ án với Anh Đức, chuyên đứng từ xa bình luận và bày trò đi chơi nhóm.

---

## II. BỐI CẢNH & MÔI TRƯỜNG (OPEN-SOURCE ASSETS CẦN DÙNG)
Chỉ cần 3 bối cảnh tĩnh (Backgrounds) lấy từ *Itch.io* cho Tập 1:
1. **Quán Cà Phê "Góc Nhỏ" (Buổi chiều nắng ấm):** Tông màu gỗ trầm, có quầy pha chế, bàn sát cửa sổ và cây xanh.
2. **Thư Viện Trường / Không gian Co-working (Buổi tối):** Ánh đèn vàng ấm, kệ sách cao, màn hình laptop phát sáng.
3. **Con Đường Trước Quán Lúc Trời Mưa (Cảnh kết Tập 1):** Hiệu ứng hạt mưa rơi nhẹ, ánh đèn đường phản chiếu dưới mặt đất.

---

## III. KỊCH BẢN CHI TIẾT TẬP 1 (4 PHÂN CẢNH - SCENES)

### PHÂN CẢNH 1: Cú "Bug" Đầu Tiên Mang Tên Em
* **Bối cảnh:** Quán Cà Phê "Góc Nhỏ" – 3 giờ chiều. Nhạc nền Acoustic nhẹ nhàng.
* **Diễn biến:** Anh Đức đang ngồi ở quầy bar vừa trông quán giúp anh M, vừa gõ code trên laptop. Cửa quán bật mở, KyKy hớt hải chạy vào. Vì vừa chạy vừa nhìn điện thoại tìm đường, cô nàng vấp nhẹ vào tấm thảm, cuốn sổ tay trên tay bay thẳng về phía bàn của Anh Đức.
* **Tương tác (Mini-choice 1):** Cuốn sổ sắp đáp xuống ly cà phê cạnh laptop của Anh Đức.
  * *Lựa chọn A (Phản xạ cực nhanh):* Chộp lấy cuốn sổ trên không trung. -> **Hiệu ứng:** Ngầu điểm 10, nhưng làm rơi chiếc bút của cô nàng.
  * *Lựa chọn B (Bê ly cà phê né ra):* Để cuốn sổ đáp xuống bàn an toàn. -> **Hiệu ứng:** Anh Đức nhìn cô nàng bằng ánh mắt "bất lực".
* **Đối thoại điểm nhấn:**
  * **KyKy** *(Sprite: Shock/Lo lắng)*: "Á! Xin lỗi anh! Máy tính của anh có sao không ạ? Tại Google Maps bảo rẽ phải ngay đây mà em không thấy..."
  * **Anh Đức** *(Sprite: Nhếch mép cười)*: Nhìn vào màn hình điện thoại cô nàng đang cầm ngược. "Google Maps không sai. Chỉ có người cầm ngược bản đồ rồi tự lao đầu vào tường mới sai thôi, công chúa ạ."
  * *Chi tiết đắt giá:* Khi trả lại sổ, Anh Đức vô tình thấy một tờ giấy note rơi ra ghi đầy những dòng công thức Tin học đại cương viết sai bét nhè kèm hình vẽ một con rùa đang khóc.

### PHÂN CẢNH 2: Vị Khách Hàng "Não Cá Vàng" & Ly Nước Đặc Biệt
* **Bối cảnh:** Vẫn tại quán cà phê, 15 phút sau.
* **Diễn biến:** Hóa ra KyKy đến quán để đợi gia sư dạy kèm môn Tin học ứng dụng (chứng chỉ bắt buộc để cô nàng hoàn tất hồ sơ du học), nhưng vị gia sư kia đột ngột hủy kèo qua tin nhắn. KyKy ngồi ở góc bàn, mặt xịu xuống *(Sprite: Buồn/Bối rối)*, chọc chọc ống hút vào ly trà sữa.
* **Sự kiện:** Anh quản lý M đi ngang qua, thấy cô bé đáng yêu đang thở dài liền nháy mắt với Anh Đức: *"Đức này, ca của em hết rồi đấy, hay ra cứu nét cho khách VIP của quán đi, anh trả lương gấp đôi bằng một chầu lẩu!"*
* **Mini-game nhỏ (Pha chế - Tùy chọn):** Người chơi kéo thả nguyên liệu pha một ly Ca cao nóng ngọt ngào có vẽ hình mặt cười bằng bọt sữa mang ra bàn cho KyKy.
* **Đối thoại điểm nhấn:**
  * **Anh Đức** *(Đặt ly nước xuống)*: "Tặng cô bé làm rơi sổ. Uống đồ ngọt vào cho não chạy lại đi, nhìn em sắp khóc ngập quán của tôi rồi."
  * **KyKy** *(Sprite: Ngước nhìn qua cặp kính tròn)*: "Em sắp rớt môn Tin học tới nơi rồi... Anh biết ai rành máy tính không, cứu em với, em trả công bằng trà sữa một tháng!"
  * **Anh Đức** *(Chống cằm nhìn cô)*: "Một tháng trà sữa thì hơi rẻ so với học phí của tôi. Nhưng thôi, nể tình em cầm bản đồ ngược cũng tìm được tới đây... đưa bài đây tôi xem."

### PHÂN CẢNH 3: Buổi Học Kèm "Tăng Huyết Áp" Đáng Yêu
* **Bối cảnh:** Bàn gỗ góc quán cà phê, trời bắt đầu chuyển sang chiều tà (Tông màu Cam Hồng - Sunset).
* **Diễn biến:** Một chàng lập trình viên hệ "chiến thần" phải giảng giải thuật toán cơ bản cho một cô nàng "công chúa hệ tâm linh" (chọn đáp án trắc nghiệm bằng cách... đếm cánh hoa).
* **Tình huống hài hước - lãng mạn:** KyKy không hiểu bài nhưng sợ Anh Đức mắng nên cứ gật đầu lia lịa, cặp kính tròn cứ tụt xuống sống mũi. Khi Anh Đức hỏi lại một câu cực dễ, cô nàng đứng hình, hai tay xoắn xuýt vào nhau, lén nhìn sang chỗ khác.
* **Tương tác (Mini-choice 2):** Khi KyKy trả lời sai một câu siêu dễ:
  * *Lựa chọn A (Búng nhẹ vào gọng kính cô nàng):* "Này, cái đầu nhỏ của em đang nghĩ tới món ăn tối đúng không?" -> *KyKy ôm trán cười hì hì (Sprite: Cười tít mắt).*
  * *Lựa chọn B (Lấy bút vẽ hình minh họa vào sổ cô nàng):* Vẽ hai nhân vật chibi đang chạy để giải thích vòng lặp `While`. -> *KyKy mắt sáng rực vì hình vẽ quá dễ thương.*
* **Khoảnh khắc Rung động (Heartbeat Moment):** Lúc KyKy cúi sát vào màn hình laptop của Anh Đức để xem kết quả chạy code, khoảng cách giữa hai người thu hẹp lại chỉ còn vài centimet. Mùi hương ngọt nhẹ từ tóc cô nàng làm chàng coder đang giảng bài cực kỳ lưu loát bỗng nhiên... nói vấp một nhịp *(Sprite Anh Đức: Đỏ mặt quay đi, giả vờ ho nhẹ)*.

### PHÂN CẢNH 4 (KẾT TẬP 1): Cơn Mưa Bất Chợt & Lời Hứa Ngày Mai
* **Bối cảnh:** Trước hiên quán cà phê lúc 6 giờ tối. Trời đổ mưa rào bất chợt.
* **Diễn biến:** KyKy đứng trước hiên quán, lục tung chiếc túi đeo chéo màu kem nhưng quên mang ô. Anh Đức từ trong quán bước ra, đeo balo lệch một vai, trên tay cầm một chiếc ô đen lớn.
* **Hành động:** Anh Đức bung ô, tự nhiên bước tới đứng che phía trên đầu cô. Vì chiều cao chênh lệch, KyKy phải ngước lên nhìn.
* **Đối thoại kết màn:**
  * **KyKy:** "Ơ, anh đi cùng đường với em hả?"
  * **Anh Đức:** "Không, nhà tôi ở hướng ngược lại. Nhưng để một người xem Google Maps ngược tự đi về dưới mưa, tôi sợ mai báo đăng tin có người đi lạc sang tận thành phố bên cạnh."
  * **KyKy** *(Cười rạng rỡ, ôm chặt cuốn sổ trước ngực)*: "Anh Đức này... anh nói chuyện đáng ghét thật đấy, nhưng mà anh tốt bụng cực kỳ! Mai... anh lại dạy kèm cho em nữa nhé?"
  * **Anh Đức** *(Sprite: Cười nhẹ, ánh mắt dịu lại)*: "Xem thái độ của học trò ngày mai thế nào đã. Đi thôi, kẻo ướt giày."
* **Cảnh kết (Ending Cutscene Tập 1):** Hình ảnh hai nhân vật 2D đi dưới một chiếc ô (chiếc ô hơi nghiêng hẳn về phía KyKy, vai áo bên trái của Anh Đức hơi ướt), dòng chữ **"Hết Tập 1 - Mở khóa tính năng Nhắn Tin Điện Thoại cho Tập 2"** hiện lên cùng tiếng nhạc piano lắng đọng.

---

## IV. CƠ CHẾ GAMEPLAY ĐƠN GIẢN ĐỂ KHÔNG NHÀM CHÁN (Dễ code bằng AI)
1. **Hệ thống "Chỉ Số Rung Động" & "Độ Hiểu Bài":** Mỗi lựa chọn của người chơi sẽ cộng điểm vào 1 trong 2 thanh này, hiển thị bằng icon Trái Tim (`❤️`) hoặc Bóng Đèn (`💡`) nhỏ ở góc màn hình.
2. **Tính năng Điện thoại ảo (Cuối tập):** Sau khi về nhà, màn hình game hiện lên giao diện chat (giống Messenger/Zalo). KyKy nhắn tin gửi bức ảnh chụp lén hình vẽ trong sổ kèm câu chúc ngủ ngon, người chơi được chọn Sticker để trả lời.