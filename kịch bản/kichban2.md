# KỊCH BẢN GAME TƯƠNG TÁC (INTERACTIVE NOVEL SCRIPT)
**Dự án:** TRẠM DỪNG CHÂN (LỖI LOGIC TRÁI TIM)  
**TẬP 2: Cơn Bão Nhỏ Ở Gờ 23 & Bài Kiểm Tra Của Hội Bạn Thân**

* **Phong cách biên kịch:** Chuyển thể tiểu thuyết thanh xuân – đô thị sang trải nghiệm tương tác thực tế (Interactive Drama). Kết hợp sự ngọt ngào tinh tế của *Vụng Trộm Không Thể Giấu* (Tang Trĩ – Đoàn Gia Hứa), những màn "đấu trí" giữ chủ quyền ngầm cực cuốn của *Yêu Em Từ Cái Nhìn Đầu Tiên* (Tiêu Nại), chất thơ đời thường của *Đi Đến Nơi Có Gió* và không khí quán cà phê ấm cúng của *Coffee Talk*.
* **Điểm nâng cấp cốt lõi Tập 2:**
  1. **Hệ thống "Hiệu ứng cánh bướm" (Butterfly Effect & Dynamic Attitude):** Mỗi câu trả lời không chỉ cộng điểm chung chung mà thay đổi trực tiếp **Thái độ của các nhân vật phụ** (Trâm có duyệt Anh Đức hay không, Đức Anh có buột miệng "bóc phốt" hay không, Hải có tiến tới mạnh hơn không).
  2. **Hệ sinh thái NPC Môi trường (Living World NPCs):** Quán cà phê và khuôn viên trường có khách hàng, người qua đường với mẩu chuyện riêng giúp không gian sống động như đời thật.
  3. **3 Mini-game tương tác sâu & 3 Kết cục (Multi-Endings)** mở ra các nhánh cốt truyện khác nhau cho Tập 3.

---

## I. HỆ THỐNG BIẾN SỐ & CHỈ SỐ THIỆN CẢM (STATE VARIABLES)

Để code dễ dàng quản lý mạch truyện phân nhánh, Tập 2 sử dụng 4 chỉ số và 3 biến cờ (Flags):

### 1. Bốn Chỉ Số Cốt Lõi (Core Meters)
* `❤️ Heartbeat (Độ Rung Động của KyKy & Anh Đức)`: Mức độ tình cảm lãng mạn giữa hai nhân vật chính.
* `💡 Study (Độ Hiểu Bài của KyKy)`: Ảnh hưởng đến kết quả bài kiểm tra thử cuối tập.
* `🛡️ Tram_Approval (Độ Tin Cậy của Trâm)`: Quyết định xem cô bạn thân "hộ vệ" Trâm sẽ trở thành **Đồng minh đẩy thuyền** hay **Rào cản ngăn cấm**.
* `🔥 Jealousy_Meter (Chỉ số Ghen Ngầm của Anh Đức)`: Khi chỉ số này chạm ngưỡng cao do sự xuất hiện của **Hải**, Anh Đức sẽ mở khóa các hành động và câu thoại "đánh dấu chủ quyền" cực ngầu.

### 2. Hệ Thống NPC Môi Trường (Ambient NPCs - Tăng độ "Real")
Người chơi có thể click vào các nhân vật ngồi rải rác trong quán cà phê *Gờ 23* để nghe lỏm hoặc tương tác ngắn trước khi vào mạch truyện chính:
* **NPC 1 – Anh Freelancer "Cột Sống Bất Ổn" (Ngồi bàn góc cạnh ổ điện):** Luôn gõ phím cạch cạch với 2 ly Espresso. Khi click vào: *"Sửa lại theo bản thiết kế đầu tiên là bản nào hả trời... À em ơi, cho anh thêm một ly bạc xỉu nhiều đá, ít tuyệt vọng!"*
* **NPC 2 – Cặp Đôi Học Sinh Cấp 3 (Ngồi bàn sát cửa kính):** Đang ngại ngùng chia nhau một cặp tai nghe dây. Khi KyKy nhìn họ, Anh Đức sẽ buông một câu bình luận tùy theo điểm `❤️ Heartbeat`.
* **NPC 3 – Bác Bảo Vệ Khu Phố & Cô Bán Hoa Dạo (Ngoài hiên quán):** Thường xuyên ghé cho mèo **Nlong** ăn cá khô và khen Anh Đức với KyKy "nhìn có tướng phu thê".

---

## II. KỊCH BẢN CHI TIẾT TẬP 2 (5 PHÂN CẢNH LỚN)

### PHÂN CẢNH 1: Tin Nhắn Nửa Đêm & "Hoàng Thượng" Nlong Làm Loạn
* **Bối cảnh:** Mở đầu bằng giao diện **Điện Thoại Ảo (00:15 Đêm)** sau cơn mưa cuối Tập 1, sau đó chuyển sang **Map 1: Quán Cà Phê Gờ 23 (9:00 Sáng Thứ Bảy)**.
* **Nhạc nền:** Tiếng gõ phím lách cách buổi đêm $\rightarrow$ Chuyển sang nhạc Acoustic guitar sáng sớm trong trẻo.

#### [Giai đoạn 1A: Giao diện Chat đêm khuya - Nhánh mở đầu]
Màn hình hiện cuộc hội thoại giữa **KyKy** và **Anh Đức**. KyKy gửi bức ảnh chụp trang vở có hình vẽ chibi hai người chạy dưới mưa mà Đức vẽ lúc chiều, kèm góc bàn có cái đuôi xám trắng của mèo **Nlong**.
* **Tin nhắn của KyKy:** *"Gia sư Đức ơi, em về tới nhà rồi ạ! Mà lúc nãy anh che ô nghiêng sang bên em nhiều quá, vai áo anh ướt hết trơn... Anh có bị cảm không đó? 🥺"*

> **🔀 LỰA CHỌN TƯƠNG TÁC 1 (Góc nhìn Anh Đức trả lời tin nhắn):**
> * **Lựa chọn A (Style "Mỏ hỗn" nhưng ấm áp):** *"Cảm thì chưa, nhưng nếu ngày mai có người vẫn quên công thức vòng lặp thì tôi sẽ tăng xông máu đấy. Ngủ đi đồ ngốc, mai 9h sáng tại quán."*
>   * **Kết quả:** `+10 ❤️ Heartbeat`. KyKy thả tim tin nhắn, gửi sticker mèo lăn lộn rồi ôm điện thoại cười tủm tỉm.
> * **Lựa chọn B (Style Dịu dàng thẳng thắn):** *"Tôi khỏe như vâm, ướt chút không sao. Chỉ sợ công chúa nào đó dính mưa mai lại lấy cớ trốn học thôi. Uống nước ấm rồi ngủ sớm đi nhé."*
>   * **Kết quả:** `+15 ❤️ Heartbeat`, mở khóa biến `Flag_Sweet_Text = true` (Sáng hôm sau KyKy sẽ mang lén cho Đức một túi trà gừng).
> * **Lựa chọn C (Style Cộc lốc hệ Coder):** *"Không sao. Đang fix bug đồ án. Mai 9h đừng đi muộn."*
>   * **Kết quả:** `+5 💡 Study`, `-5 ❤️ Heartbeat`. KyKy nhắn lại Trâm than thở: *"Ông gia sư này đúng là khúc gỗ biết gõ code mà!"*

#### [Giai đoạn 1B: Sáng hôm sau tại Quán Gờ 23]
* **Diễn biến:** Anh Đức đang đứng sau quầy bar pha cà phê. Chị **Quản Lý M** (tóc búi củ tỏi gọn gàng trên đỉnh đầu, đeo kính tròn) vừa kiểm kê sổ sách vừa liếc nhìn chiếc áo khoác vắt trên ghế của Đức.
* **Chị M** *(Sprite: Nháy mắt tinh quái)*: *"Này Đức, chị nhớ nhà em ở hướng đường Nguyễn Trãi cơ mà? Sao tối qua bảo vệ khu phố bảo thấy cậu barista quán chị cầm ô đi bộ tít sang khu Cầu Giấy ngược đường thế kia?"*
* **Anh Đức** *(Sprite: Gãi đầu, tai hơi đỏ, quay sang vuốt lông mèo Nlong đang nằm trên quầy)*: *"Đi dạo cho tiêu cơm thôi chị. Nlong nhỉ? Hôm nay đứa nào hỏi nhiều là cắt pate của đứa đấy."*
* **Mèo Nlong** *(Sprite: Mắt vàng hổ phách nhìn "quạu" sang chảnh, kêu "Meow~")*: Nằm ườn ra bàn, lấy chân sau đạp nhẹ vào tay Đức đòi gãi cằm.

---

### 🎮 MINI-GAME 1: "Giải Cứu Bàn Phím Khỏi Hoàng Thượng Nlong"
* **Ngữ cảnh:** Đúng 9h00, KyKy chạy vào quán (nếu có `Flag_Sweet_Text = true`, cô nàng rụt rè đặt hộp trà gừng lên mặt bàn). Khi Anh Đức vừa mở laptop ra kiểm tra bài cũ, chú mèo béo **Nlong** thấy KyKy liền nhảy phốc lên bàn, nằm ườn đè thẳng lên bàn phím laptop và cuốn sổ của KyKy.
* **Cơ chế chơi (Gameplay Mechanics):**
  * Màn hình hiện cận cảnh chú mèo tai cụp lông xám bạc **Nlong** đang nằm chễm chệ trên laptop, thanh **"Độ Phê Của Nlong"** hiện lên từ `0%` đến `100%`.
  * Người chơi có 15 giây thực hiện tổ hợp thao tác:
    1. **Vuốt (Swipe):** Gãi đúng 3 vị trí "điểm yếu" của Nlong (Dưới cằm, sau tai cụp, má phúng phính) – tránh chạm vào đuôi kẻo Nlong quạu.
    2. **Kéo thả (Drag & Drop):** Lấy thanh súp thưởng từ balo của Anh Đức đưa qua phía cuốn sổ để dụ Nlong dịch chuyển khỏi bàn phím.
* **Sự kiện Rung Động (Heartbeat Trigger):** Ở giây cuối cùng khi Nlong lăn người sang bên, cả Anh Đức và KyKy cùng đưa tay ra đỡ chú mèo khỏi lăn xuống đất. Bàn tay thon dài của Đức vô tình nắm trọn lấy bàn tay nhỏ nhắn của KyKy trên lớp lông xám mềm mại của Nlong.
* **Đối thoại sau Mini-game:**
  * **KyKy** *(Sprite: Đỏ mặt tía tai, mắt tròn xoe sau cặp kính)*: *"Á... em chỉ định đỡ Nlong thôi, nó nặng quá..."*
  * **Anh Đức** *(Sprite: Hơi khựng lại 2 giây, không rút tay về ngay mà khẽ dùng ngón cái chạm nhẹ vào mu bàn tay cô rồi mới buông ra, giọng trầm xuống)*: *"Ừ, tại Nlong béo quá đấy. Không phải tại em."*

---

### PHÂN CẢNH 2: Cuộc "Đột Kích" Của Đội Quân Hộ Vệ & Tổ Đội IT
* **Bối cảnh:** Quán Cà Phê Gờ 23 – 10:30 Sáng. Không khí trong quán bắt đầu đông khách (NPC Anh Freelancer đang gọi cốc cà phê thứ 3).
* **Diễn biến:** Cửa quán bật mở cùng lúc bởi hai nhóm người hoàn toàn không hẹn trước:
  1. Từ phía KyKy: **Trâm** (tóc đen dài cài kẹp màu sắc, áo cardigan tím hồng pastel, tay cầm điện thoại) bước vào với khí thế "chị đại đi kiểm tra lý lịch con rể".
  2. Từ phía Anh Đức: **Đức Anh** (tóc ngắn Short Quiff nhuộm vàng chói lọi, đeo tai nghe quanh cổ) và **Thanh Thảo** (tóc búi cao, mặc hoodie xanh navy, ôm iPad) kéo đến tìm Đức để bàn nốt phần giao diện đồ án.

#### [Tình huống Va Chạm & Tạo Phản Ứng Hóa Học]
* **Đức Anh** vừa bước vào đã oang oang: *"Đức ơi cứu anh em với! Tối qua mày bỏ rơi bọn tao giữa trận rank để đi che ô cho... Ối chào hai bạn nữ xinh đẹp!"* (Đức Anh lập tức đứng hình khi chạm mắt với ánh nhìn sắc lẹm của Trâm).
* **Thanh Thảo** đẩy gọng kính, nhìn lướt qua bàn học có hai ly nước, chú mèo Nlong đang nằm ngủ trong lòng KyKy và tờ giấy nháp có chữ viết tay của Đức: *"Thảo nào sáng nay bảo bận việc đại sự không lên phòng lab. Hóa ra đại thần IT đi mở lớp phụ đạo 1-kèm-1."*
* **KyKy** *(Nhìn thấy Thanh Thảo vừa xinh vừa thông minh đứng cạnh Đức rất tự nhiên, cộng thêm câu nói "lên phòng lab cùng nhau", ánh mắt KyKy thoáng chút tự ti, hai tay ôm chặt cuốn sổ vào ngực - Sprite: Pout/Bối rối)*.

> **🔀 LỰA CHỌN TƯƠNG TÁC 2 (Khi Trâm bắt đầu "thẩm vấn" và KyKy đang hiểu lầm mối quan hệ giữa Đức & Thanh Thảo):**
> **Trâm** khoanh tay nhìn Anh Đức: *"Chào anh. Em là Trâm, bạn thân nhất của KyKy. Nghe bảo anh dạy kèm giỏi lắm, nhưng bạn em hơi ngốc, lại dễ tin người. Anh dạy kèm vì nhiệt tình thật, hay vì thấy con bé dễ bắt nạt đấy?"*
>
> * **Lựa chọn A (Thẳng thắn ghi điểm với cả Trâm lẫn KyKy):** Anh Đức bình thản kéo ghế cho KyKy ngồi ngay ngắn, rồi nhìn thẳng vào mắt Trâm: *"Tôi chỉ bắt nạt một mình KyKy thôi, người ngoài muốn bắt nạt cô ấy thì phải bước qua tôi trước. Còn chị bạn cầm iPad kia là Thanh Thảo – đồng đội làm đồ án cùng thằng tóc vàng này, không phải đối tượng cần cảnh giác đâu."*
>   * **Kết quả:** `+20 🛡️ Tram_Approval`, `+15 ❤️ Heartbeat`. KyKy thở phào nhẹ nhõm, cười tít mắt. Thanh Thảo bật cười: *"Đấy, chưa gì đã vội vàng thanh minh chưa kìa!"*
> * **Lựa chọn B (Trêu chọc đúng chất ngông của Đức):** *"Bắt nạt thì có đấy, tại nhìn cái mặt ngơ ngác của bạn em lúc làm sai bài thú vị phết. Nhưng yên tâm, học trò của Anh Đức này thì không ai khác được phép đụng vào."*
>   * **Kết quả:** `+10 🛡️ Tram_Approval`, `+10 ❤️ Heartbeat`. Trâm hơi nhíu mày nhưng thấy KyKy kéo áo mình cười hì hì nên cũng dịu xuống.
> * **Lựa chọn C (Để Đức Anh và Thanh Thảo tự giải thích):** Anh Đức im lặng uống nước, để Đức Anh nhảy vào giải thích hộ.
>   * **Kết quả:** `-10 🛡️ Tram_Approval`, `-5 ❤️ Heartbeat`. Trâm đánh giá Đức hơi kiêu ngạo, và KyKy vẫn còn hơi lăn tăn chuyện Thanh Thảo học giỏi.

---

### PHÂN CẢNH 3: Sự Xuất Hiện Của "Vệ Tinh" Hải & Cơn Bão Ghen Ngầm
* **Bối cảnh:** Chuyển sang **Map 2: Khu vực Bàn Gỗ lớn & Kệ Sách của quán (Buổi chiều nắng dịu)**. Nhóm Đức Anh, Thanh Thảo và Trâm ngồi ở bàn bên cạnh vừa ăn bánh ngọt vừa "hóng chuyện" (Đức Anh đang ra sức bắt chuyện xin Instagram của Trâm nhưng bị Trâm phũ đẹp).
* **Sự kiện Nút Thắt (Plot Twist):** Một chàng trai mặc sơ mi trắng lồng áo gile len màu be, đeo túi da chéo vai bước vào quán với nụ cười ấm áp chuẩn mực — đó là **Hải** (đàn anh khóa trên lớp ngoại ngữ của KyKy).
* **Hải** *(Sprite: Cười dịu dàng, tiến tới bàn của KyKy)*: *"Ơ, KyKy? Trùng hợp thật đấy! Anh vừa đi mua sách ngang qua thấy bóng lưng giống em nên ghé vào. Đây, cuốn tài liệu luyện thi từ vựng và hộp bánh Matcha anh mua cho em ở tiệm hôm trước em khen ngon này."*
* **KyKy** *(Sprite: Bất ngờ)*: *"Á, anh Hải! Em cảm ơn anh nhiều ạ, anh chu đáo quá..."*

#### [Miêu Tả Tâm Lý & Biểu Cảm Đắt Giá Của Anh Đức]
* Ngồi ngay đối diện, **Anh Đức** đang xoay chiếc bút bi trên ngón tay bỗng nhiên **dừng phắt lại**. Nụ cười bất cần trên môi tắt hẳn. Ánh mắt sắc lạnh quét từ hộp bánh Matcha trên tay Hải sang nụ cười lễ phép của KyKy.
* Ở bàn bên cạnh, **Đức Anh** hích khuỷu tay vào **Thanh Thảo** thì thầm: *"Thôi xong, áp suất không khí giảm đột ngột. Tao cá với mày 50k là trong vòng 3 câu nữa thằng Đức sẽ giở trò."*
* **Hải** quay sang nhìn Anh Đức, lịch sự hỏi: *"Chào bạn, bạn là anh trai hay gia sư của KyKy thế? Hôm nay thứ Bảy mà hai người học chăm quá. Hay học xong KyKy đi xem triển lãm sách với anh nhé, anh có dư một vé."*

> **🔀 LỰA CHỌN TƯƠNG TÁC 3 (Pha "Đánh Dấu Chủ Quyền" Kinh Điển Của Anh Đức):**
> * **Lựa chọn A (Đòn tấn công tinh tế + Dùng mèo Nlong làm vũ khí):** Anh Đức bế bổng chú mèo **Nlong** đặt thẳng vào lòng KyKy, đồng thời tự nhiên vươn tay lấy hộp bánh Matcha đặt sang một góc bàn, đẩy ly Cacao nóng do chính tay mình pha tới trước mặt cô: *"Cảm ơn ý tốt của anh bạn, nhưng học trò của tôi dạ dày yếu, sáng chưa ăn gì không hợp đồ trà xanh. Với lại chiều nay cô ấy có lịch... trông mèo cùng tôi tới tối rồi."*
>   * **Kết quả:** `+25 ❤️ Heartbeat`, `+20 🔥 Jealousy_Meter`, `+15 🛡️ Tram_Approval` (Trâm ngồi bàn bên gật gù: *"Được đấy, pha chặn họng này chị chấm 9 điểm!"*).
> * **Lựa chọn B (Đòn áp đảo trí tuệ "Đại thần IT"):** Anh Đức mỉm cười nửa miệng, nghiêng người chống tay lên thành ghế của KyKy (khoảng cách cực gần khiến Hải phải lùi lại nửa bước): *"Tôi là người đang giữ sinh mệnh môn Tin học của cô ấy. Vé triển lãm của anh chắc phải để dịp khác rồi, vì hôm nay cô ấy còn nợ tôi 20 bài tập thực hành. Đúng không, KyKy?"*
>   * **Kết quả:** `+20 ❤️ Heartbeat`, `+10 💡 Study`, `+25 🔥 Jealousy_Meter`. KyKy đỏ mặt gật đầu lia lịa trước ánh mắt vừa bá đạo vừa có chút "dỗi" của Đức.
> * **Lựa chọn C (Giả vờ lịch sự đẩy quyết định cho KyKy):** *"Tùy em đấy KyKy, học xong muốn đi đâu với ai là quyền của em."*
>   * **Kết quả:** `-15 ❤️ Heartbeat`, `+30 🔥 Jealousy_Meter` (Chuyển thành **Chiến tranh lạnh**). KyKy vẫn từ chối Hải vì muốn học với Đức, nhưng thấy thái độ lạnh nhạt của Đức nên cô nàng tủi thân.

---

### 🎮 MINI-GAME 2: "Gỡ Rối Tâm Tư & Bài Kiểm Tra Vòng Lặp Trái Tim"
* **Ngữ cảnh:** Sau khi Hải rời đi, không khí trên bàn học giữa Anh Đức và KyKy có chút kỳ lạ (vừa ngượng ngùng vừa có chút hờn dỗi trẻ con của Đức). Anh Đức gõ nhẹ bút lên trán cô: *"Tập trung vào. Nhìn người ta cười tươi thế, giờ làm thử bài kiểm tra nhỏ này xem còn nhớ chữ nào trong đầu không."*
* **Cơ chế chơi (Gameplay Mechanics - Interactive Coding Puzzle cho người không biết code):**
  * Màn hình hiển thị cuốn sổ tay của KyKy và màn hình Laptop của Anh Đức.
  * Đề bài được thiết kế dưới dạng câu đố logic tình cảm cực kỳ đáng yêu: **"Giúp nhân vật Chibi KyKy tìm đường chạy đến chỗ Chibi Anh Đức dưới mưa mà không bị lạc đường"**.
  * Người chơi chọn lắp ghép 3 mảnh ghép lệnh bằng tiếng Việt đời thường:
    1. `Nếu (Trời đổ mưa)` $\rightarrow$ Chọn: `Đứng yên ở hiên quán đợi Anh Đức` (Đúng) / `Cầm ngược bản đồ chạy lung tung` (Sai).
    2. `Trong khi (Đang buồn hoặc đói bụng)` $\rightarrow$ Chọn: `Uống Cacao nóng & Nựng mèo Nlong` (Đúng).
    3. `Kết quả trả về (Return)` $\rightarrow$ Chọn: `Nụ cười của KyKy` (Hoàn thành!).
* **Phản hồi theo kết quả:**
  * Nếu ghép đúng ngay lần đầu: `+20 💡 Study`, Anh Đức bất ngờ nhướng mày, khóe môi cong lên một nụ cười cực kỳ dịu dàng, đưa tay xoa nhẹ lên mái tóc xoăn của KyKy: *"Giỏi lắm. Hóa ra không phải não cá vàng hoàn toàn."*

---

### PHÂN CẢNH 4: Sự Cố Cúp Điện Ở Phòng Kho & Khoảnh Khắc "Gần Trong Gang Tấc"
* **Bối cảnh:** Cuối buổi chiều (17:30). Trời bên ngoài chuyển mây âm u.
* **Diễn biến:** Chị Quản Lý M nhờ KyKy và Anh Đức vào khu vực **Góc Kệ Sách Sâu Phía Trong (Map 2)** để lấy giúp tập tài liệu cũ và túi hạt cà phê dự trữ. Trong lúc đó, ngoài quầy chính, **Đức Anh** vì muốn thể hiện tài sửa đồ điện trước mặt **Trâm** nên đã cắm thử máy nướng bánh mới... và làm **nhảy cầu dao điện toàn quán**!
* **Hiệu ứng hình ảnh & Âm thanh:** Toàn bộ màn hình vụt tắt tối om trong 1 giây, kèm tiếng *"Phựt!"* và tiếng hét nhỏ của KyKy. Ngay sau đó, ánh sáng mờ ảo từ màn hình điện thoại của Anh Đức bật lên, hắt sáng góc kệ sách hẹp.
* **Hành động (Tận dụng điểm yếu "Sợ bóng tối/Sợ ma" của KyKy trong Hồ sơ nhân vật):**
  * Vì không gian đột ngột tối sầm cộng thêm tiếng mèo Nlong vô tình làm rơi cuốn sách ngoài kia kêu *"Bộp!"*, KyKy theo phản xạ nhắm tịt mắt, lao thẳng tới túm chặt lấy vạt áo polo đen của Anh Đức, vùi mặt vào ngực anh run nhẹ.
  * **KyKy** *(Giọng lắp bắp, sắp khóc)*: *"Anh Đức ơi... tối quá... có phải có cái gì vừa rơi không ạ? Em sợ..."*
  * **Anh Đức** *(Đứng im cho cô ôm, một tay cầm điện thoại chiếu sáng, tay kia chần chừ một nhịp rồi nhẹ nhàng đặt lên lưng cô vỗ về, giọng nói không còn chút trêu chọc nào mà trầm ấm tuyệt đối)*: *"Không có ma đâu. Chỉ có thằng Đức Anh đang phá quán ngoài kia thôi. Đừng sợ, tôi ở ngay đây rồi."*

---

### 🎮 MINI-GAME 3 (QUICK-TIME EVENT): "Nhịp Đập Trong Bóng Tối"
* **Cơ chế chơi:** Khi hai người đứng sát nhau giữa hai dãy kệ sách hẹp, trên màn hình xuất hiện hiệu ứng nhịp tim đập (`Thình thịch... Thình thịch...`).
* Một vòng tròn cảm xúc co giãn theo nhịp tim. Người chơi cần chạm đúng vào tâm vòng tròn 3 lần để giúp Anh Đức thực hiện các hành động dỗ dành KyKy:
  1. *Nhịp 1:* Chỉnh lại cặp kính tròn bị lệch trên sống mũi của KyKy.
  2. *Nhịp 2:* Lấy chiếc kẹp tóc nhỏ bị tuột cài lại gọn gàng lên lọn tóc xoăn của cô.
  3. *Nhịp 3:* Cúi đầu xuống ngang tầm mắt KyKy khi đèn trong quán bất ngờ sáng bừng trở lại!

---

## III. PHÂN NHÁNH ĐA KẾT CỤC TẬP 2 (MULTI-ENDINGS)

Khi đèn quán bật sáng, **Chị M**, **Trâm**, **Thanh Thảo** và **Đức Anh** đồng loạt thò đầu vào nhìn cảnh Anh Đức đang một tay vịn lên kệ sách phía sau lưng KyKy (tư thế *Kabedon* vô tình), khoảng cách giữa hai khuôn mặt chưa đầy một gang tay.

Tùy thuộc vào tổng điểm các biến số mà người chơi tích lũy từ đầu tập, Tập 2 sẽ rẽ sang **1 trong 3 Kết Cục (Endings)** hoàn toàn khác nhau:

### 🌟 ENDING 1 (TRUE / SWEET ENDING): "Lời Mời Chính Thức Từ Đại Thần"
* **Điều kiện mở khóa:** `❤️ Heartbeat >= 50` VÀ `🛡️ Tram_Approval >= 20`.
* **Diễn biến:**
  * Dù bị cả hội bắt gặp, Anh Đức không hề luống cuống rút tay về. Anh bình thản đứng thẳng dậy, đỡ KyKy ra ngoài rồi quay sang nhìn **Trâm** và **Đức Anh**: *"Tiện có mặt đủ bạn thân của hai bên ở đây, tối nay tôi mời cả bọn đi ăn lẩu. Coi như... ra mắt bạn bè của học trò luôn."*
  * **Trâm** nhìn cảnh KyKy được Đức che chở kỹ càng liền bật cười, giơ điện thoại lên: *"Chấp nhận lời mời! Nhưng nói trước, anh mà làm con bé khóc là tôi với chị Thanh Thảo đây xử đẹp anh đấy!"*
  * **Cảnh Cutscene Kết:** Cả nhóm 6 người (Anh Đức, KyKy, Trâm, Đức Anh, Thanh Thảo, Chị M) cùng chú mèo béo **Nlong** ngồi quanh bàn lẩu bốc khói nghi ngút. Dưới gầm bàn, Anh Đức lặng lẽ gắp phần thịt bò ngon nhất bỏ đầy vào bát của KyKy kèm câu nói nhỏ chỉ hai người nghe thấy: *"Thưởng cho học trò hôm nay đạt điểm 10."*
* **Hệ quả sang Tập 3:** Trâm chính thức gia nhập phe "Đẩy thuyền", mở khóa **Bản đồ Phố Đi Bộ Đêm** và buổi hẹn hò riêng.

### 🔥 ENDING 2 (JEALOUS / DRAMA ENDING): "Cuộc Đua Không Khoan Nhượng"
* **Điều kiện mở khóa:** `🔥 Jealousy_Meter >= 40` VÀ người chơi từng chọn các đáp án lạnh lùng/trêu quá đà khiến `❤️ Heartbeat < 50`.
* **Diễn biến:**
  * Khi ra khỏi góc kệ sách, điện thoại của KyKy trên bàn đổ chuông — là tin nhắn của **Hải** hỏi thăm xem cô về chưa và gửi lịch học nhóm tuần sau.
  * Anh Đức nhìn thấy màn hình điện thoại sáng lên tên Hải. Thay vì rủ cả nhóm đi ăn, Đức cầm lấy cuốn sổ của KyKy, ghi thẳng số điện thoại cá nhân và lịch học kín mít các buổi tối trong tuần vào trang đầu tiên bằng nét chữ dứt khoát.
  * **Anh Đức** *(Ánh mắt sâu thẳm, nửa đùa nửa thật)*: *"Từ tuần sau, mọi lịch học thêm của em đều do tôi quản lý. Không nhận lịch hẹn của bất kỳ 'đàn anh khóa trên' nào khác. Nghe rõ chưa, công chúa?"*
* **Hệ quả sang Tập 3:** Mạch truyện chuyển sang hướng **"Theo đuổi bá đạo & Phá giải hiểu lầm"**, Hải sẽ xuất hiện nhiều hơn để cạnh tranh trực tiếp với Anh Đức.

### 😂 ENDING 3 (COMEDY / CHAOS ENDING): "Hội Những Người Sợ Hoàng Thượng Nlong"
* **Điều kiện mở khóa:** `💡 Study >= 30` nhưng điểm tình cảm và điểm của Trâm ở mức trung bình.
* **Diễn biến:**
  * Đúng lúc cả bọn đang nhìn Anh Đức và KyKy trong góc kệ sách, chú mèo béo **Nlong** từ trên nóc tủ sách nhảy bộp xuống trúng đầu **Đức Anh**, làm cậu chàng tóc vàng ngã nhào kéo theo cả đĩa bánh ngọt.
  * Cả quán nhốn nháo dọn dẹp dưới sự chỉ đạo của **Chị M**. Anh Đức và KyKy phải đeo tạp dề đứng phạt lau cốc cùng nhau trong tiếng cười鬧 của cả hội bạn. Lúc KyKy vô tình làm bọt xà phòng dính lên chóp mũi Anh Đức, cả hai nhìn nhau bật cười xóa tan mọi khoảng cách.
* **Hệ quả sang Tập 3:** Mở khóa nhánh cốt truyện **"Làm thêm cùng nhau tại quán Gờ 23"** với nhiều tình huống dở khóc dở cười.

---

## IV. BẢNG TỔNG HỢP BIỂU CẢM CODE & ÂM THANH CẦN DÙNG CHO TẬP 2 (DEV NOTES)

Để khớp với hệ thống `characters.json` bạn đã dựng (dùng 2 tư thế gốc + vẽ thêm biểu cảm bằng code), Tập 2 chỉ cần gọi các hiệu ứng code sau:
1. `VFX_SweatDrop (Giọt mồ hôi)`: Gắn cho **Đức Anh** khi bị Trâm lườm, và gắn cho **KyKy** khi bị kiểm tra bài cũ.
2. `VFX_Blush (Má hồng đậm + Hơi nước)`: Gắn cho **KyKy** và **Anh Đức** trong Mini-game 1 (Chạm tay trên lưng mèo Nlong) và Phân cảnh 4 (Cúp điện góc kệ sách).
3. `VFX_Exclamation (!)` & `VFX_AngerVein (Ngọn lửa nhỏ/Khí đen)`: Gắn cho **Anh Đức** ở Phân cảnh 3 khi **Hải** xuất hiện tặng bánh Matcha.
4. `VFX_HeartBubble (Bong bóng trái tim)`: Bay lên từ đầu chú mèo **Nlong** mỗi khi người chơi vuốt ve thành công.