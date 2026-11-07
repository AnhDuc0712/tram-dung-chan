# KỊCH BẢN GAME TƯƠNG TÁC (INTERACTIVE NOVEL SCRIPT)
**Dự án:** TRẠM DỪNG CHÂN (LỖI LOGIC TRÁI TIM)  
**TẬP 3: Đồ Án Chung, Bước Nhảy Trái Tim & Lời Hứa Dưới Nắng Sớm**

* **Thể loại:** 2D Visual Novel kết hợp Mini-game tương tác & Khám phá tự do (Slice-of-life Romance / Interactive Drama).
* **Cảm hứng biên kịch:**
  - Sự ấm áp, tinh tế và rung động thầm kín của *Vụng Trộm Không Thể Giấu* (Đoàn Gia Hứa – Tang Trĩ).
  - Màn phối hợp ăn ý giữa Lập trình & Thiết kế, những pha bảo vệ chủ quyền "đẳng cấp đại thần" từ *Yêu Em Từ Cái Nhìn Đầu Tiên* (Tiêu Nại – Bối Vy Vy).
  - Nét ngông nghênh nhưng hy sinh và dịu dàng đến thắt lòng của Lý Tuân (*Chiếc Bật Lửa Và Váy Công Chúa*).
  - Không khí đời thường, chữa lành và thư thái của *Đi Đến Nơi Có Gió* và *Coffee Talk*.
* **Tiêu chí cốt lõi Tập 3:**
  - **Nhẹ nhàng & Tự do:** Tiếp tục tôn vinh lối chơi tự do khám phá (Roam mode), tương tác môi trường sống động, không gượng ép.
  - **Kịch bản chặt chẽ & Đặc sắc:** Khóa trọn các nút thắt từ 5 kết thúc của Tập 2 (nồi lẩu ra mắt, gấu Nlong, hộp bánh cháy, áo khoác cho mượn, cơn ghen với Hải).
  - **Phát triển chiều sâu nhân vật (Character Arc):**
    - **Anh Đức:** Từ chàng coder giấu cảm xúc sau lớp vỏ "mỏ hỗn" bất cần đến một người đàn ông dám chịu trách nhiệm, công khai tỏ tình và trở thành chỗ dựa vững chắc cho ước mơ của người mình yêu.
    - **KyKy:** Vượt qua sự tự ti "não cá vàng/mù công nghệ", chứng minh tài năng thiết kế đồ họa đỉnh cao trong đồ án chung, can đảm đối diện với tình cảm và tương lai du học.
    - **Hải:** Đối thủ cạnh tranh quân tử, vừa là động lực thúc đẩy Anh Đức bộc lộ tình cảm, vừa mang lại sự tôn trọng lẫn nhau giữa hai chàng trai tài hoa.
    - **Hội bạn thân (Trâm, Đức Anh, Thanh Thảo, Chị M, Nlong):** Tiếp tục là chất xúc tác vừa hài hước duyên dáng, vừa ấm áp tình người.

---

## I. HỆ THỐNG BIẾN SỐ & CHỈ SỐ THIỆN CẢM (STATE VARIABLES)

Kế thừa và mở rộng hệ thống chỉ số từ Tập 1 và Tập 2:

### 1. Bốn Chỉ Số Cốt Lõi (Core Meters)
* `❤️ Heartbeat (Độ Rung Động Trái Tim)`: Thang đo tình cảm sâu sắc giữa KyKy và Anh Đức. Đạt ngưỡng cao (>= 75) sẽ mở khóa lời tỏ tình chính thức ở cảnh kết.
* `💡 Logic_Sync (Độ Đồng Điệu Đồ Án / Trí Tuệ)`: Mức độ ăn ý giữa tư duy lập trình của Đức và tư duy mỹ thuật của KyKy trong đồ án "Trạm Dừng Chân".
* `🛡️ Tram_Trust (Chỉ Số Đồng Minh Của Trâm)`: Trâm là "thuyền trưởng" kiêm kiểm duyệt con rể. Điểm cao giúp Trâm chủ động tạo ra các khoảng không gian riêng tư cho hai người.
* `🔥 Jealousy_Meter (Chỉ Số Đánh Dấu Chủ Quyền)`: Khi đối đầu với Hải, mức độ ghen ngầm của Anh Đức sẽ dẫn tới những pha "khóa chặt mục tiêu" đầy bản lĩnh.

### 2. Các Biến Cờ Mở Khóa Phân Nhánh (Story Flags)
* `Flag_Burnt_Cake (Hộp Bánh Hơi Cháy)`: Thừa hưởng từ nhánh kết thúc trả áo khoác của Tập 2.
* `Flag_Nlong_Junior (Gấu Bông Avatar)`: KyKy để ảnh avatar chú gấu bông Nlong do Đức gắp.
* `Flag_Street_Date (Buổi Hẹn Đêm)`: Nhận được lời mời đi dạo phố sách từ Trâm và Chị M.
* `Flag_Hai_Exhibition (Lời Mời Của Hải)`: Hải chính thức mời KyKy cùng tham gia triển lãm đồ họa quốc tế và phỏng vấn học bổng du học.
* `Flag_Confession_Ready`: Đủ điều kiện kích hoạt màn tỏ tình đặc biệt dưới nắng sớm hiên quán.

### 3. Hệ Sinh Thái NPC Môi Trường Mới (Living World Campus & Night Street)
Trong chế độ đi lại tự do (Roam mode), người chơi có thể tương tác với các NPC xung quanh:
* **NPC Thầy Trưởng Khoa CNTT (Dưới gốc xà cừ sân trường):** Đang cầm giáo trình và cốc cà phê Gờ 23: *"Nhóm thằng Đức làm đồ án năm nay cứng tay đấy, nhưng nghe bảo tìm đâu ra được cô bé thiết kế giao diện nhìn mát mắt hẳn, không còn cục mịch như mấy dòng lệnh của nó nữa!"*
* **NPC Cậu Sinh Viên Năm Nhất Chạy Deadline (Bàn đá giảng đường):** Laptop dán đầy sticker anime, tay cầm bánh mì: *"Giá mà ai đó code hộ tôi cái vòng lặp For này, tôi xin cúng một tháng trà sữa..."* (KyKy sẽ bật cười nhớ lại chính mình ở Tập 1).
* **NPC Bác Bán Đồ Lưu Niệm Dạo Phố Đêm:** Bán những chiếc móc khóa đôi hình chú mèo béo và máy tính bỏ túi: *"Hai đứa mua cặp móc khóa này đi, nhìn vừa xứng đôi vừa thông minh!"*
* **NPC Anh Freelancer "Cột Sống Đã Ổn" (Gặp lại ở Gờ 23):** Uống ly sinh tố thay vì Espresso: *"Nhờ giao diện đồ án của hai em thử nghiệm hôm nọ, web của anh chạy mượt rồi nhé! Hôm nay anh khao cả quán!"*

---

## II. BỐI CẢNH & KHÔNG GIAN MỚI (ENVIRONMENTS & MAPS)

Tập 3 sử dụng 5 bối cảnh tương ứng với dòng chảy thời gian từ sáng sớm đến đêm khuya và sáng hôm sau:
1. **Map Campus Day (Khuôn viên Đại học ban ngày):** Sân trường đầy nắng xuyên qua kẽ lá xà cừ, hàng ghế đá ven đường, bảng thông báo triển lãm đồ án sinh viên rực rỡ sắc màu.
2. **Map Cafe Morning/Noon (Gờ 23 giờ cao điểm):** Quán ngập tràn ánh nắng ấm áp, quầy pha chế bận rộn với máy xay cà phê kêu ro ro, chú mèo Nlong lim dim sưởi nắng trên bậu cửa sổ.
3. **Map Study Corner (Góc Tự Học & Thư Viện Chiều Tà):** Ánh hoàng hôn vàng cam rót qua khung cửa kính, bàn gỗ ngổn ngang bản vẽ phác thảo UI/UX của KyKy và hai chiếc laptop chạy code của Anh Đức & Thanh Thảo.
4. **Map Exhibition Street Night (Khu phố triển lãm đồ án & Phố sách đêm):** Dãy đèn lồng vàng treo dọc lối đi bộ, các gian trưng bày công nghệ và nghệ thuật sáng lung linh, gió đêm se lạnh đầu mùa.
5. **Map Cafe Sunrise (Hiên quán Gờ 23 lúc bình minh):** Không gian yên tĩnh trong trẻo, sương sớm đọng trên lá cây, tia nắng đầu tiên của ngày mới chiếu rọi bậc thềm gỗ nơi hai người lần đầu chạm mặt.

---

## III. KỊCH BẢN CHI TIẾT TẬP 3 (5 PHÂN CẢNH CHÍNH)

---

### PHÂN CẢNH 1: Nắng Sân Trường & Dự Án Bất Đắc Dĩ
* **Bối cảnh:** `campus_day` – Sân trường Đại học lúc 8:30 sáng. Ánh nắng rực rỡ, lá vàng bay nhẹ.
* **Mở màn:** 
  - Nối tiếp mạch truyện Tập 2: KyKy xuất hiện tại cổng trường với chiếc túi chéo quen thuộc, trên tay cầm theo một chiếc túi giấy nhỏ (chứa chiếc áo khoác polo của Đức đã được giặt thơm tho phẳng phiu, kèm một hộp thiếc đựng bánh quy hạnh nhân do chính tay cô nàng nướng... dù viền bánh hơi ngả màu nâu cháy).
  - Phía xa dưới gốc cây cổ thụ, Anh Đức đang tựa lưng vào lan can, tay lướt điện thoại, vai khoác balo một bên. Gió thổi làm rối mái tóc nâu hạt dẻ. Khuyên tai bạc ánh lên dưới nắng.
* **Tình huống va chạm:**
  - KyKy rón rén bước lại gần định "hù" Anh Đức từ phía sau. Nhưng chưa kịp chạm vào vai anh, Đức đã cất giọng bình thản mà không cần quay đầu lại:
  - **Anh Đức** *(Sprite: Smirk/Nhếch mép)*: "Mùi hoa cúc dại trên áo em thơm cách xa năm mét rồi, công chúa. Đi đứng lạch bạch như vịt thế mà cũng đòi dọa đại thần à?"
  - **KyKy** *(Sprite: Shock -> Pout)*: "Anh Đức có mắt sau gáy đấy à! Người ta có lòng mang áo trả cho anh này, thơm phức luôn nhé!"
  - Đức nhận lấy túi áo, mở hé nhìn thấy hộp bánh nhỏ bên trong.
  - **Anh Đức** *(Sprite: Curious -> Tease)*: "Gì đây? Hối lộ vì hôm nay tính làm sai bài tiếp hả? Nhìn màu bánh thế này... em nướng bằng lửa rồng à?"
  - **KyKy** *(Sprite: Blush/Dỗi)*: "Anh không ăn thì trả đây! Em dậy từ 6 giờ sáng canh lò đấy, chỉ hơi quá lửa một tí xíu thôi..."

> **🔀 LỰA CHỌN TƯƠNG TÁC 1 (Phản ứng của Anh Đức với chiếc bánh cháy):**
> * **Lựa chọn A (Mở nắp ăn liền + Khen ngợi kiểu độc quyền):** Anh Đức thong thả mở nắp hộp, nhón một chiếc bánh bỏ vào miệng nhai giòn rụm rồi nghiêng đầu nhìn cô: *"Bánh của em nướng thì dù cháy thành than tôi cũng ăn hết. Cơ mà... ngon hơn tôi tưởng đấy. Trừ 1 điểm cháy viền, cộng 10 điểm tấm lòng."*
>   * **Kết quả:** `+20 ❤️ Heartbeat`, `+10 🛡️ Tram_Trust`, mở khóa thoại ngọt ngào. KyKy mắt sáng lấp lánh sau cặp kính tròn, má đỏ ửng.
> * **Lựa chọn B (Trêu chọc rồi cất kỹ vào balo):** *"Để dành làm vũ khí phòng thân lúc fix bug đêm. Cơ mà cấm cho thằng Đức Anh miếng nào đấy, của tôi."*
>   * **Kết quả:** `+15 ❤️ Heartbeat`, `+10 🔥 Jealousy_Meter`. Khẳng định tính "chiếm hữu" đáng yêu.
> * **Lựa chọn C (Giảng bài thực tế về nhiệt độ nướng):** *"Lần sau chỉnh lò 160 độ trong 15 phút thôi, dùng công thức logic chứ đừng nướng bánh bằng cảm tính."*
>   * **Kết quả:** `+15 💡 Logic_Sync`, `-5 ❤️ Heartbeat`. KyKy bĩu môi lườm nhẹ.

* **Sự kiện bùng nổ phân cảnh:**
  - **Hải** bước tới trong trang phục sơ mi trắng thanh lịch, tay cầm tập hồ sơ dán logo Ban tổ chức Triển lãm Thiết kế Sinh viên Toàn thành.
  - **Hải** *(Cười ấm áp)*: "Chào KyKy! May quá gặp em ở đây. Triển lãm đồ họa tháng tới trường mình được 2 suất đặc cách gửi tác phẩm tham dự vòng quốc tế kèm cơ hội học bổng trao đổi tại Pháp. Anh đang làm trưởng ban tuyển chọn, anh rất muốn mời em đứng tên chung dự án đồ họa tương tác với anh."
  - KyKy ngơ ngác chớp mắt. Nhưng ngay lúc cô nàng còn đang bối rối, **Thanh Thảo** và **Đức Anh** từ giảng đường chạy ùa ra:
  - **Thanh Thảo**: "Đức ơi! Đồ án tốt nghiệp 'Trạm Dừng Chân' của nhóm mình thầy duyệt thuật toán rồi, nhưng thầy chê giao diện thô cứng như bảng cửu chương! Thầy bảo nếu không tìm được Designer chuyên nghiệp làm lại toàn bộ UI/UX tương tác thì không cho mang đi triển lãm đâu!"
  - **Đức Anh** chắp tay vái lạy KyKy: "Bà ngoại KyKy ơi cứu bọn tao! Nhìn nét vẽ chibi trên vở của mày tao biết mày là thiên tài thiết kế rồi! Về đội bọn tao đi!"
  - Hai lời mời cùng lúc đặt lên bàn cân: Một bên là đàn anh Hải lịch lãm với tấm vé du học danh giá, một bên là nhóm đồ án của Anh Đức đang đứng trước bờ vực khủng hoảng giao diện.
  - KyKy nhìn sang Anh Đức. Đức không vội vàng chen ngang, anh đứng thẳng người, ánh mắt sâu thẳm nhìn cô, giọng nói trầm tĩnh nhưng đầy sức nặng:
  - **Anh Đức**: "Dự án của tôi thiếu em thì chỉ là những dòng mã vô hồn. Nhưng đi đâu, làm gì là tương lai của em. Tôi không ép. Em chọn đi."

> **🔀 LỰA CHỌN TƯƠNG TÁC 2 (Cách Anh Đức thuyết phục KyKy về đội mình):**
> * **Lựa chọn A (Khẳng định vị trí không thể thay thế của KyKy):** Đức bước tới nửa bước, nhìn thẳng vào mắt Hải rồi quay sang KyKy: *"Giao diện 'Trạm Dừng Chân' lấy cảm hứng từ chính nụ cười của em ở quán Gờ 23. Dự án này sinh ra là vì em, chỉ có em mới vẽ nên được linh hồn của nó."*
>   * **Kết quả:** `+25 ❤️ Heartbeat`, `+20 🔥 Jealousy_Meter`, `+15 🛡️ Tram_Trust`. Hải thoáng khựng lại nhận ra tình cảm của Đức dành cho KyKy lớn đến mức nào. KyKy tim đập thình thịch, lập tức gật đầu đồng ý.
> * **Lựa chọn B (Dùng tinh thần đồng đội & bảo đảm đầu ra):** *"Về đội tôi, em không chỉ có điểm A đồ án, mà tôi cam đoan hồ sơ năng lực của em sẽ đủ sức đè bẹp mọi ứng viên học bổng mà không cần dựa dẫm vào ai."*
>   * **Kết quả:** `+20 💡 Logic_Sync`, `+15 ❤️ Heartbeat`. KyKy cảm thấy được tôn trọng về năng lực chuyên môn.
> * **Lựa chọn C (Im lặng để KyKy tự quyết):** Để Trâm đứng sau giật dây.
>   * **Kết quả:** `+10 🛡️ Tram_Trust`, Trâm nhảy vào gật đầu nhận kèo cho KyKy.

---

### PHÂN CẢNH 2: Ca Làm Thêm Giờ Cao Điểm Tại Gờ 23 & Thử Thách Barista
* **Bối cảnh:** `cafe_morning` -> `cafe_day` – Quán Gờ 23 lúc 11:30 trưa. Khách văn phòng và sinh viên đổ về nườm nượp.
* **Diễn biến:**
  - Để ăn mừng việc KyKy chính thức gia nhập nhóm dự án, cả nhóm kéo về Gờ 23. Nhưng trớ trêu thay, nhân viên pha chế chính của quán bị ốm đột xuất. **Chị Quản Lý M** vò đầu bứt tai giữa một rừng order nước.
  - **Chị M**: "Đức ơi cứu chị! Giờ cao điểm khách gọi tới 15 ly đồ uống một lúc, một mình em pha không xuể đâu!"
  - **KyKy** hăng hái xung phong: "Để em phụ anh Đức cho ạ! Em biết bấm máy ép với trang trí bọt sữa rồi!"
  - Anh Đức nhìn cô bé chân ngắn lon ton lấy chiếc tạp dề màu nâu đậm của quán mặc vào. Chiếc tạp dề quá dài khiến cô lúng túng không buộc được dây phía sau lưng.
  - Đức thở dài mỉm cười, bước vòng ra sau lưng cô. Đôi bàn tay thon dài vòng qua eo KyKy, kéo nhẹ dây tạp dề thắt lại thành hình chiếc nơ gọn gàng. Hơi thở ấm áp của anh phả nhẹ bên vành tai cô.
  - **Anh Đức** *(Thì thầm)*: "Vụng về thế này mà đòi làm phụ bếp của đại thần à? Đứng sát cạnh tôi, làm theo hiệu lệnh, cấm làm đổ sữa lên người đấy."
  - **KyKy** *(Đỏ bừng cả mặt, tim đập thình thịch gật đầu)*: "Rõ... rõ ạ!"

---

### 🎮 MINI-GAME 1: "Thử Thách Barista Giờ Cao Điểm (Rush Hour Coffee Sync)"
* **Cơ chế chơi (Interactive Rhythm & Matching):**
  - Màn hình hiện quầy pha chế Gờ 23 với hai nhân vật Chibi Đức & Chibi KyKy đứng cạnh nhau.
  - Các order của khách hàng hiện lên góc trên (gồm khách quen NPC Freelancer, Trâm, Thầy Trưởng khoa, và Chú mèo Nlong chờ đĩa sữa tươi).
  - Người chơi thực hiện 3 công đoạn nhịp nhàng:
    1. **Chọn nguyên liệu chuẩn xác:** Kéo đúng loại hạt cà phê / bột Cacao / siro gừng theo order của khách.
    2. **Đánh sữa & Tạo hình nghệ thuật (Latte Art):** Căn thanh trượt vào vùng xanh lá để vẽ hình mặt mèo Nlong hoặc hình trái tim.
    3. **Chuyền ly & Bấm chuông hoàn thành:** Anh Đức pha cốt nước, KyKy rót sữa và đặt bánh quy lên đĩa.
* **Hiệu ứng đặc biệt (Heartbeat Trigger):**
  - Khi hoàn thành ly "Cacao Gừng Nắng Ấm", hai người cùng lúc với tay lấy chiếc ly, ngón tay đan vào nhau. KyKy trượt chân nhẹ trên sàn gạch, Anh Đức nhanh tay kéo eo cô sát vào lòng mình, giữ cho ly nước thăng bằng không sánh một giọt.
  - Cả quán ồ lên vỗ tay, chú mèo Nlong trên nóc tủ kêu vang một tiếng "Meo~~".
* **Phản hồi sau mini-game:**
  - Nếu đạt điểm xuất sắc: `+20 ❤️ Heartbeat`, `+20 💡 Logic_Sync`. Chị M thưởng nóng cho cả hai một đĩa bánh ngọt lớn và tuyên bố miễn phí đồ uống trọn đời cho KyKy.

---

### PHÂN CẢNH 3: Góc Tự Học, Deadline Áp Sát & Lỗi Logic Cuối Cùng
* **Bối cảnh:** `library` (hoặc góc bàn gỗ lớn sát kệ sách Gờ 23 chiều tà) – 16:30 Chiều. Ánh nắng hoàng hôn nhuộm đỏ rực khung cửa kính.
* **Diễn biến:**
  - Đồ án "Trạm Dừng Chân" bước vào giai đoạn nước rút trước đêm triển lãm.
  - KyKy đã vẽ xong toàn bộ bộ nhận diện thương hiệu tuyệt đẹp: Icon ứng dụng là hình chú mèo Nlong đeo tai nghe, giao diện mang tông màu pastel ấm áp kết hợp giữa xanh navy và vàng kem.
  - Nhưng một sự cố kỹ thuật nghiêm trọng xảy ra: Khi cắm giao diện đồ họa của KyKy vào bộ mã nguồn của Anh Đức, hệ thống liên tục báo lỗi xung đột thư viện: `Runtime Error: Null Pointer Heartbeat`.
  - **Đức Anh** ôm đầu gào khóc: "Thôi toang rồi anh em ơi! Còn 4 tiếng nữa là triển lãm mở cửa rồi! Sao code của thằng Đức với đồ họa của KyKy không chịu nhận nhau thế này!"
  - **KyKy** *(Sprite: Lo lắng/Sắp khóc)*: "Có phải tại kích thước file ảnh của em nặng quá không anh Đức? Hay tại em không hiểu về định dạng code nên làm hỏng bài của mọi người rồi..."
  - Anh Đức không hề bực bội. Anh kéo ghế ngồi sát bên cạnh cô, xoay màn hình laptop về phía hai người, giọng nói dịu dàng đến mức khiến Thanh Thảo và Đức Anh phải tròn mắt kinh ngạc:
  - **Anh Đức**: "Không phải lỗi của em. Thiết kế của em hoàn hảo 100%. Lỗi là do hàm kết nối của tôi chưa mở quyền truy cập cho linh hồn của ứng dụng thôi. Nhìn này, tôi chỉ cho em sửa."

---

### 🎮 MINI-GAME 2: "Đồng Bộ UI & Logic (Code & Design In Sync)"
* **Cơ chế chơi (Creative Logic Puzzle):**
  - Màn hình chia đôi: Bên trái là các khối thành phần đồ họa của KyKy (Nút bấm, Icon, Bảng màu, Âm thanh), bên phải là các hàm chức năng trong mã nguồn của Anh Đức.
  - Người chơi kéo các sợi dây liên kết để ghép đúng 4 cặp tương thích:
    1. `UI_Nlong_Icon` (Hình ảnh chú mèo Nlong) $\rightarrow$ Nối với hàm `cat_purr_relax()` (Phát tiếng kêu gừ gừ thư giãn cho người dùng).
    2. `UI_Warm_Tea` (Tách trà gừng ấm) $\rightarrow$ Nối với hàm `keep_heart_warm()` (Nhắc nhở người dùng nghỉ ngơi).
    3. `UI_Crescent_Eyes` (Đôi mắt cười trăng khuyết của KyKy) $\rightarrow$ Nối với hàm `unlock_happy_state()` (Mở khóa giao diện rạng rỡ).
    4. `UI_Confession_Button` (Nút bấm bí mật hình bức thư) $\rightarrow$ Nối với hàm `return_love_true()` (Lỗi logic trái tim được giải quyết!).
* **Khoảnh khắc Rung Động Đỉnh Điểm (Heartbeat Moment):**
  - Khi sợi dây cuối cùng nối thành công, màn hình laptop vụt sáng với dòng chữ rực rỡ: `BUILD SUCCESSFUL! WELCOME TO TRAM DUNG CHAN`.
  - Cả hội bạn hò reo ăn mừng rồi kéo nhau ra ngoài mua đồ ăn tối, cố tình để lại không gian riêng cho hai người.
  - Trong góc phòng tĩnh lặng, KyKy vì kiệt sức sau nhiều ngày thức đêm vẽ đồ án đã gục đầu ngủ thiếp đi trên mặt bàn gỗ, má tì lên cuốn sổ tay. Cặp kính tròn hơi trượt xuống.
  - Anh Đức ngồi im ngắm nhìn gương mặt say ngủ của cô. Ánh hoàng hôn phủ lên hàng mi cong và đôi môi chúm chím. Anh nhẹ nhàng tháo cặp kính tròn của cô đặt sang bên cạnh, rồi cởi chiếc áo khoác của mình đắp nhẹ lên vai KyKy.
  - Bất chợt, KyKy trong cơn mơ khẽ cựa mình, bàn tay nhỏ vô thức nắm lấy một ngón tay của Đức kéo sát vào má mình.
  - Đức sững người. Trái tim của chàng coder "bất bại" đập loạn nhịp chưa từng có. Anh không rút tay về, mà dùng bàn tay còn lại nhẹ nhàng vuốt lọn tóc xoăn vương trên trán cô, ánh mắt chan chứa tình cảm:
  - **Anh Đức** *(Nói khẽ một mình)*: "Lỗi logic lớn nhất trong cuộc đời tôi... chính là không thể nào ngừng thích em được."

---

### PHÂN CẢNH 4: Đêm Triển Lãm Rực Rỡ & Pha Khẳng Định Chủ Quyền
* **Bối cảnh:** `street_rain` / `exhibition_night` – Phố Triển lãm Sinh viên lúc 20:00 tối. Đèn lồng lung linh, dòng người đông đúc náo nhiệt.
* **Diễn biến:**
  - Gian trưng bày ứng dụng "Trạm Dừng Chân" thu hút đông đảo khách tham quan nhất nhờ giao diện đồ họa sống động kết hợp âm nhạc thư giãn và câu chuyện chạm tới cảm xúc. Thầy Trưởng khoa tấm tắc khen ngợi và chấm điểm tối đa cho nhóm.
  - KyKy diện một chiếc váy màu kem xinh xắn, mắt cười tít rạng rỡ bên cạnh tác phẩm của mình.
  - Đúng lúc đó, **Hải** xuất hiện cùng một bó hoa linh lan trắng muốt trên tay.
  - **Hải** *(Sprite: Cười dịu dàng, tặng hoa cho KyKy)*: "Chúc mừng KyKy! Tác phẩm hôm nay của em thật sự xuất sắc. Giáo sư đối tác người Pháp của anh vừa xem qua và đánh giá rất cao phong cách của em. Thầy muốn mời em đi ăn tối cùng đoàn vào ngày mai để bàn về thủ tục cấp học bổng du học toàn phần khóa mùa thu. Đi cùng anh nhé?"
  - KyKy ngập ngừng nhìn bó hoa, rồi bất giác quay đầu tìm kiếm bóng hình của Anh Đức giữa biển người.
  - Từ phía sau lưng KyKy, **Anh Đức** bước tới. Tối nay anh mặc áo sơ mi đen xắn tay chỉn chu, toát lên phong thái đĩnh đạc và cuốn hút lạ thường. Anh bước tới đứng sát cạnh KyKy, một tay tự nhiên đặt lên vai cô, kéo nhẹ cô về phía mình:
  - **Anh Đức**: "Cảm ơn bó hoa của anh Hải. Nhưng tối mai học trò của tôi có lịch hẹn quan trọng hơn rồi."
  - **Hải** nhíu mày: "Lịch hẹn gì có thể quan trọng hơn tương lai du học của KyKy chứ?"

> **🔀 LỰA CHỌN TƯƠNG TÁC 3 (Pha đối đầu quyết định giữa Anh Đức và Hải):**
> * **Lựa chọn A (Bá đạo khẳng định chủ quyền + Ủng hộ tương lai của KyKy):** Đức nhìn thẳng vào mắt Hải, mỉm cười điềm tĩnh: *"Tương lai du học của KyKy không cần anh phải lo hộ. Học bổng đó cô ấy hoàn toàn xứng đáng nhận bằng chính năng lực của mình, không cần đi cửa sau qua bất kỳ bữa tối nào cả. Còn tối mai... cô ấy phải cùng tôi đi nộp hồ sơ xin visa đôi, vì tôi cũng vừa nhận được thư mời làm việc của viện nghiên cứu công nghệ cùng thành phố đó rồi."*
>   * **Kết quả:** `+30 ❤️ Heartbeat`, `+25 🔥 Jealousy_Meter`, `+20 🛡️ Tram_Trust`. Toàn bộ hội trường đứng hình! Trâm và Thanh Thảo hét lên vì quá ngầu! KyKy ngước nhìn Đức, xúc động đến rơi nước mắt. Hải mỉm cười bất lực nhưng đầy khâm phục: *"Được rồi, tôi thua cậu tâm phục khẩu phục."*
> * **Lựa chọn B (Dịu dàng tôn trọng quyền quyết định của KyKy):** Đức quay sang nhìn KyKy, ánh mắt tràn ngập tin tưởng: *"Em muốn đi đâu, làm gì, tôi đều sẽ đứng phía sau làm hậu phương vững chắc nhất cho em. Nhưng trước khi quyết định... hãy nhớ rằng ở thành phố này, có một người sẵn sàng chờ em bao lâu cũng được."*
>   * **Kết quả:** `+25 ❤️ Heartbeat`, `+20 💡 Logic_Sync`. KyKy cảm nhận được tình yêu bao la và sự tôn trọng tuyệt đối của Đức. Cô nàng lịch sự cảm ơn Hải nhưng từ chối bó hoa để nhận lấy ly trà gừng nóng từ tay Đức.
> * **Lựa chọn C (Đức trêu chọc biến căng thẳng thành nụ cười):** *"Anh Hải tính bao cả nhóm tôi đi ăn thì tôi cân nhắc cho em ấy đi đấy, chứ đi một mình thì không đời nào."*
>   * **Kết quả:** `+10 ❤️ Heartbeat`, `-5 🔥 Jealousy_Meter`. Không khí bớt căng thẳng nhưng thiếu một chút bùng nổ tình cảm.

---

### PHÂN CẢNH 5: Bình Minh Trước Hiên Quán & Lời Tỏ Tình Chính Thức
* **Bối cảnh:** `cafe_morning` / `cafe_sunrise` – 6:00 Sáng hôm sau tại trước hiên quán Gờ 23.
* **Diễn biến:**
  - Sau đêm triển lãm thành công rực rỡ, cả nhóm tàn tiệc. Chỉ còn lại Anh Đức và KyKy cùng nhau đi bộ về lại quán Gờ 23 để đón chú mèo Nlong.
  - Sương sớm mùa thu còn vương trên những tán lá bàng. Không khí trong lành, thoang thoảng mùi hạt cà phê rang mới và hương hoa ngọc lan ven đường.
  - KyKy ngồi đung đưa đôi chân trên bậc thềm gỗ trước cửa quán, tay ôm chú mèo béo Nlong đang ngủ say. Chiếc áo khoác của Đức vẫn choàng trên vai cô.
  - Anh Đức từ trong quán bước ra, trên tay cầm hai chiếc ly sứ bốc khói nghi ngút. Anh ngồi xuống bậc thềm ngay sát cạnh cô, đưa cho cô ly Cacao nóng có vẽ hình một trái tim nguyên vẹn.
  - **KyKy** *(Ngước nhìn bầu trời đang ửng hồng)*: "Anh Đức này... mọi chuyện cứ như một giấc mơ ấy nhỉ. Mới hôm nào em cầm ngược bản đồ lao vào quán làm rơi sổ, bị anh mắng là ngốc nghếch... thế mà giờ chúng mình đã làm xong một đồ án tuyệt vời cùng nhau rồi."
  - **Anh Đức** *(Nhìn sườn mặt nghiêng của cô, ánh mắt dịu dàng chưa từng thấy)*: "Tôi không bao giờ mắng em ngốc thật cả. Người ngốc thật sự... là tôi."
  - KyKy chớp mắt ngạc nhiên quay sang: "Dạ? Đại thần IT mà cũng có lúc ngốc á?"
  - **Anh Đức** *(Đặt ly nước xuống, quay hẳn người sang nhìn thẳng vào mắt cô)*:
  - "Ừ. Tôi viết hàng vạn dòng lệnh không sai một dấu chấm phẩy, nhưng đứng trước em thì câu chữ nào cũng lộn xộn. Tôi cố tình che ô nghiêng về phía em để bị ướt vai, cố tình ngồi trông quán mỗi sáng thứ Bảy chỉ để đợi một người cầm ngược bản đồ bước vào, cố tình ghen lồng lộn lên khi thấy người khác tặng bánh cho em... Tất cả những điều vô lý ấy, trong thuật toán của tôi chỉ có một lời giải duy nhất."
  - Anh vươn tay, nhẹ nhàng nắm lấy bàn tay nhỏ nhắn của KyKy đang đặt trên lưng mèo Nlong, mười ngón tay đan chặt vào nhau:
  - **Anh Đức**: "KyKy, tôi thích em. Không phải với tư cách gia sư dạy kèm, cũng không phải trưởng nhóm đồ án. Mà là người muốn che ô cho em suốt cả cuộc đời này. Em có đồng ý làm bạn gái của tôi không?"

---

## IV. HỆ THỐNG 5 KẾT CỤC PHÂN NHÁNH TẬP 3 (THE 5 MULTI-ENDINGS)

Dựa trên các chỉ số tích lũy (`Heartbeat`, `Logic_Sync`, `Tram_Trust`, `Jealousy`) và các lựa chọn quyết định, Tập 3 mở ra **5 Kết Cục Trọn Vẹn**:

---

### 🌟 ENDING 1 (TRUE / GRAND ROMANCE ENDING): "Lỗi Logic Duy Nhất Là Em"
* **Điều kiện:** `❤️ Heartbeat >= 80` VÀ `💡 Logic_Sync >= 40` VÀ chọn Lựa chọn A ở Phân cảnh 4.
* **Diễn biến:**
  - KyKy đỏ bừng mặt, đôi mắt ngấn lệ vì hạnh phúc. Cô nàng không ngần ngại gật đầu lia lịa rồi nhào thẳng vào vòng tay ấm áp của Anh Đức, vùi đầu vào ngực anh. Chú mèo Nlong bên cạnh kêu một tiếng "Ngoao~~" mãn nguyện.
  - Cửa quán bật mở, Chị M, Trâm, Đức Anh và Thanh Thảo đồng loạt tung pháo hoa giấy mini rợp trời: *"Thuyền cập bến rồi bà con ơi!"*
  - **Cảnh Cutscene (Event CG):** Bức tranh toàn cảnh trước hiên quán Gờ 23 dưới ánh nắng ban mai rực rỡ. Anh Đức cúi đầu hôn nhẹ lên trán KyKy, tay cô ôm chặt lấy anh, nụ cười hạnh phúc rạng ngời với đôi mắt cong hình trăng khuyết. Dưới chân là chú mèo béo Nlong ngồi ngước nhìn.
  - **Lời bạt:** *"Trong hàng triệu dòng code của vũ trụ, gặp được em là cú bug ngọt ngào nhất mà tôi nguyện không bao giờ vá lại."*

---

### ✈️ ENDING 2 (SWEET SCHOLARSHIP ENDING): "Hẹn Ước Dưới Bầu Trời Paris"
* **Điều kiện:** `❤️ Heartbeat >= 70` VÀ `💡 Logic_Sync >= 50` VÀ chọn Lựa chọn B ở Phân cảnh 4.
* **Diễn biến:**
  - KyKy quyết định nhận học bổng du học để theo đuổi ước mơ thiết kế đồ họa đỉnh cao. Nhưng lần này, cô không còn cô đơn hay lo lắng.
  - Anh Đức trao cho cô chiếc thẻ nhớ chứa toàn bộ mã nguồn của dự án "Trạm Dừng Chân", cùng chiếc vé máy bay của chính mình: *"Đi trước 6 tháng đi, tôi lo xong thủ tục chuyển giao đồ án ở trường sẽ bay sang với em. Khoảng cách địa lý không nằm trong từ điển của dân IT."*
  - **Cảnh Cutscene (Event CG):** Cảnh sân bay quốc tế. Hai người đeo tai nghe đôi, tựa trán vào nhau cùng ngắm nhìn chiếc máy bay cất cánh qua khung kính lớn, hứa hẹn một tương lai song hành rạng rỡ.

---

### ☕ ENDING 3 (COZY BARISTA ENDING): "Trạm Dừng Chân Của Riêng Hai Đứa"
* **Điều kiện:** `❤️ Heartbeat >= 60` VÀ `🛡️ Tram_Trust >= 40` (Điểm nghiên cứu kỹ thuật ở mức vừa phải).
* **Diễn biến:**
  - KyKy quyết định ở lại hoàn thành văn bằng thiết kế trong nước và chính thức trở thành "đồng chủ quán" kiêm phụ tá pha chế độc quyền của Anh Đức tại Gờ 23.
  - Cả hai cùng nhau sáng tạo ra menu đồ uống mới mang tên "Cacao Mắt Cười" và "Trà Gừng Chữa Lành", biến Gờ 23 thành điểm hẹn tình yêu nổi tiếng nhất thành phố.
  - **Cảnh Cutscene (Event CG):** Hai người đứng sau quầy bar trong chiếc tạp dề đôi, cùng nhau cầm một chiếc ca đánh sữa tạo hình trái tim lên ly cà phê, ánh mắt nhìn nhau đong đầy mật ngọt.

---

### 🔥 ENDING 4 (DOMINANT / BOLD ENDING): "Bản Hợp Đồng Trọn Đời Của Đại Thần"
* **Điều kiện:** `🔥 Jealousy_Meter >= 50` VÀ `❤️ Heartbeat >= 65`.
* **Diễn biến:**
  - Không để bất kỳ ai có cơ hội chen ngang, Anh Đức công khai mối quan hệ trên toàn bộ mạng xã hội trường và đăng ký bản quyền đồ án với tên hai tác giả: "Đức & KyKy".
  - Anh Đức đổi ảnh đại diện thành hình chụp chung với KyKy và Nlong, kèm dòng trạng thái: *"Nhà thiết kế độc quyền đã có chủ, miễn tiếp mọi lời mời hợp tác riêng."*
  - **Cảnh Cutscene (Event CG):** Anh Đức một tay khoác vai KyKy, tay kia giơ chiếc điện thoại chụp ảnh selfie hai người trước cổng trường đại học, khóe môi nhếch lên nụ cười ngạo nghễ chiến thắng.

---

### 😂 ENDING 5 (CHAOS / COMEDY ENDING): "Hoàng Thượng Ban Hôn Lúc Bình Minh"
* **Điều kiện:** Các chỉ số phân tán đồng đều, không đạt ngưỡng các Ending trên.
* **Diễn biến:**
  - Trong lúc Anh Đức đang xúc động chuẩn bị nói câu tỏ tình quan trọng nhất, chú mèo béo **Nlong** bất thình lình giật mình bởi tiếng xe rác đi ngang qua, nhảy vọt lên làm đổ nguyên ly Cacao lên áo sơ mi trắng của KyKy và làm rơi hộp bánh của Đức.
  - Cả hai cuống cuồng lấy khăn lau cho nhau, bọt sữa và bột bánh dính tùm lum lên mặt. Nhìn điệu bộ lem luốc của đối phương, cả Đức và KyKy không kìm được liền ôm bụng cười ngặt nghẽo.
  - Anh Đức vừa cười vừa gạt vệt cacao trên má KyKy: *"Thôi bỏ đi, không văn vở nữa. Làm bạn gái tôi nhé, để ngày nào tôi cũng giặt áo đền cho em!"*
  - KyKy cười tít mắt: *"Dạ, em duyệt!"*
  - **Cảnh Cutscene (Event CG):** Cả hai ngồi bệt trên bậc thềm gỗ cười rạng rỡ với khuôn mặt dính đầy bọt sữa, chú mèo Nlong ngồi giữa liếm mép đắc thắng.

---

## V. HƯỚNG DẪN KỸ THUẬT & GỢI Ý TÍCH HỢP HỆ THỐNG (DEV NOTES)

1. **Hiệu ứng đồ họa (VFX & Shaders):**
   - `VFX_Sunbeams`: Tia nắng sớm xuyên qua kẽ lá ở Phân cảnh 1 và Phân cảnh 5.
   - `VFX_HeartExplosion`: Hiệu ứng nổ hoa/tim khi KyKy đồng ý lời tỏ tình.
   - `VFX_RainDrops`: Tận dụng hệ thống mưa nhẹ mượt mà đã tối ưu cho phân cảnh đêm triển lãm.
2. **Âm thanh & Nhạc nền (BGM & SFX):**
   - BGM Mở đầu: `morning_acoustic.ogg` (Nhẹ nhàng, trong trẻo).
   - BGM Giờ cao điểm / Mini-game: `cafe_rush.ogg` (Vui nhộn, nhịp điệu nhanh).
   - BGM Tự học hoàng hôn: `sunset_piano.ogg` (Lắng đọng, ngọt ngào).
   - BGM Tỏ tình bình minh: `first_sunlight_orchestra.ogg` (Cao trào lãng mạn, ấm áp).
3. **Cơ chế lưu trữ (State Flags):**
   - Mọi tiến trình được tự động đồng bộ qua `GameState.gd` với hệ thống Auto-save sau mỗi phân cảnh và mini-game.
