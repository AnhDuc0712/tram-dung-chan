# TÀI LIỆU YÊU CẦU THIẾT KẾ HÌNH ẢNH & TÀI NGUYÊN ĐỒ HỌA
**Dự án:** TRẠM DỪNG CHÂN (LỖI LOGIC TRÁI TIM)  
**Phiên bản áp dụng:** Tập 3 & Hoàn thiện Visual trọn bộ (Episode 1 - 2 - 3)  
**Mục tiêu:** Cung cấp thông số, quy chuẩn mỹ thuật, góc máy, ánh sáng và chi tiết đạo cụ phục vụ họa sĩ 2D / hệ thống sinh ảnh AI (Midjourney, DALL-E 3, Stable Diffusion XL, Gemini Imagen).

---

## I. QUY CHUẨN MỸ THUẬT TỔNG THỂ (ART STYLE GUIDE & TECHNICAL SPECS)

### 1. Phong Cách Đồ Họa Chủ Đạo
* **Art Style:** 2D Anime/Manga hiện đại, đường nét mềm mại (clean line-art), đổ bóng tối giản dạng Cel-shading kết hợp hiệu ứng chuyển màu ánh sáng (Soft Gradient Glow) kiểu Kyoto Animation (*Hyouka*, *Tamako Market*) và Makoto Shinkai (*Your Name*, *Weathering With You*).
* **Vibe Cốt Lõi:** Ấm cúng (Cozy), ngọt ngào, đời thường sinh viên (Slice-of-life Youth Romance), chữa lành (Healing), nhiều vệt nắng ấm và không gian thoang thoảng hương cà phê.
* **Bảng Màu Chủ Đạo (Master Color Palette):**
  * *Màu ấm:* Nâu gỗ trầm `#4A3525`, Vàng nắng mật ong `#F6BD60`, Cam đào hoàng hôn `#F28482`, Hồng phấn pastel `#F7CAD0`.
  * *Màu lạnh điểm xuyết:* Xanh Navy tri thức `#1D3557`, Xanh Mint dịu mắt `#84DCC6`, Xám bạc ấm `#D8DBE2`.
  * *Màu nền chữ/UI:* Trắng kem `#FFF1DC`, Nâu cà phê đậm `#2B1E16`.

### 2. Thông Số Kỹ Thuật (Resolution & Formats)
* **Bối cảnh (Backgrounds - BG):**
  * Tỷ lệ khung hình: `16:9` ngang.
  * Độ phân giải chuẩn: `1920 x 1080 px` (hoặc tối thiểu `1280 x 720 px` cho bản web nhẹ).
  * Định dạng: Lossy WebP (chất lượng 82-85%) hoặc JPG nén tiêu chuẩn (< 350KB/ảnh).
* **Event CG / Cutscene:**
  * Tỷ lệ khung hình: `16:9` ngang (`1920 x 1080 px`).
  * Chi tiết ánh sáng và biểu cảm sắc nét, không bị nhòe hạt, tập trung tiêu cự vào mắt và nụ cười nhân vật.
* **Sprite Nhân Vật (Character Sprites):**
  * Định dạng: PNG-24 hoặc WebP trong suốt (Alpha channel).
  * Chiều cao chuẩn: `1200 - 1500 px` (để Godot scale mượt mà không vỡ hạt trên màn hình độ phân giải cao).
  * Điểm neo (Pivot/Anchor): Căn giữa chân nhân vật (Bottom-Center).
* **UI & Mini-game Elements (Icons/Props):**
  * PNG trong suốt, viền nét gọn gàng, kích thước chuẩn lưới `64x64`, `128x128`, `256x256` hoặc `512x512 px`.

---

## II. DANH MỤC BỐI CẢNH MÔI TRƯỜNG (BACKGROUNDS - BG)

---

### BG 1: Khuôn Viên Đại Học Ban Ngày (`campus_day`)
* **Mã tệp đề xuất:** `res://assets/art/bg/campus_day.jpg`
* **Vị trí xuất hiện:** Phân cảnh 1 Tập 3 (Mở màn, cảnh KyKy trả áo và gặp nhóm đồ án).
* **Mô tả chi tiết:**
  - Góc nhìn toàn cảnh (Wide shot) lối đi bộ rợp bóng mát trong khuôn viên trường đại học hiện đại.
  - Hai bên đường là hàng cây xà cừ cổ thụ tỏa bóng, nắng vàng rực rỡ xuyên qua kẽ lá rọi xuống mặt đường lát gạch xám nhạt những đốm sáng lung linh (Komorebi).
  - Ven đường có các băng ghế đá màu xám ấm, vài chiếc lá vàng rơi khẽ trên mặt ghế.
  - Phía xa là tòa giảng đường kiến trúc tối giản hiện đại với kính phản chiếu bầu trời xanh trong, vài bảng tin sinh viên treo poster triển lãm đầy màu sắc.
* **Thời gian & Ánh sáng:** 8:30 sáng, trời xanh mây trắng nhẹ, nắng sớm tinh khôi, độ tương phản vừa phải tạo cảm giác thư thái.
* **Prompt gợi ý:** `anime visual novel background, modern university campus, grand lush mahogany trees casting soft dappled sunlight on clean cobblestone walkway, stone benches, glass building facade in background, blue sky with fluffy white clouds, cozy morning atmosphere, makoto shinkai aesthetic, highly detailed 2D digital art, 16:9 --ar 16:9`

---

### BG 2: Quán Cà Phê Gờ 23 Giờ Cao Điểm (`cafe_day_rush`)
* **Mã tệp đề xuất:** `res://assets/art/bg/cafe_day_rush.jpg`
* **Vị trí xuất hiện:** Phân cảnh 2 Tập 3 (Ca làm thêm thử việc, Mini-game Barista).
* **Mô tả chi tiết:**
  - Không gian quầy pha chế quán cà phê Gờ 23 nhìn từ phía đối diện khách hàng.
  - Mặt quầy gỗ sồi nâu ấm bóng loáng, trên quầy có máy pha cà phê Espresso bóng gương inox đang bốc hơi nước nhẹ, máy xay cà phê chứa hạt nâu đậm.
  - Giá treo ly thủy tinh sáng loáng phía trên, các hũ siro thủy tinh nhiều màu, rổ đựng cam vàng và quế thanh.
  - Khung cửa kính lớn bên cạnh rọi ánh nắng trưa rực rỡ, nhìn ra con phố nhộn nhịp bên ngoài. Trên bậu cửa sổ, chú mèo Nlong đang lim dim sưởi nắng.
* **Thời gian & Ánh sáng:** 11:30 trưa, ánh sáng ấm áp, rực rỡ, không gian mang năng lượng bận rộn nhưng ấm cúng.
* **Prompt gợi ý:** `anime background, cozy aesthetic coffee shop interior, warm wooden bar counter, shining espresso machine with light steam, hanging glass racks, warm morning sun streaming through large front window, leafy potted plants, rich brown and warm amber lighting, slice-of-life anime style, 16:9 --ar 16:9`

---

### BG 3: Phòng Tự Học Hoàng Hôn (`study_sunset`)
* **Mã tệp đề xuất:** `res://assets/art/bg/study_sunset.jpg`
* **Vị trí xuất hiện:** Phân cảnh 3 Tập 3 (Chạy deadline đồ án, Mini-game Đồng bộ UI & Code).
* **Mô tả chi tiết:**
  - Góc tự học yên tĩnh trong thư viện trường hoặc gác lửng quán Gờ 23.
  - Chiếc bàn gỗ lớn đặt cạnh ô cửa kính kéo dài từ sàn lên trần. Trên bàn có hai chiếc laptop mở màn hình, cuốn sổ tay mở sẵn, hộp bút chì màu và vài cốc giấy cà phê đã cạn.
  - Rèm cửa voan mỏng khẽ bay trong gió chiều.
  - Ánh hoàng hôn vàng cam pha hồng tím rót rực rỡ qua khung cửa, nhuộm màu ấm áp lên mặt bàn và những cuốn sách gáy da trên kệ cao phía sau.
* **Thời gian & Ánh sáng:** 16:45 chiều tà (Golden Hour), tông màu chủ đạo là cam mật ong, đỏ tía và hổ phách, không gian tĩnh lặng, lãng mạn lắng đọng.
* **Prompt gợi ý:** `anime visual novel background, university study corner near floor-to-ceiling window, wooden desk with open laptops and sketchbooks, tall bookshelves filled with colorful books, magnificent golden hour sunset outside, warm orange and pink hues bathing the room, soft breeze fluttering sheer curtains, nostalgic and peaceful mood, 16:9 --ar 16:9`

---

### BG 4: Phố Triển Lãm Sinh Viên Ban Đêm (`exhibition_night`)
* **Mã tệp đề xuất:** `res://assets/art/bg/exhibition_night.jpg`
* **Vị trí xuất hiện:** Phân cảnh 4 Tập 3 (Đêm triển lãm, màn chạm trán giữa Đức và Hải).
* **Mô tả chi tiết:**
  - Khu phố đi bộ ngoài trời được trang hoàng thành hội chợ triển lãm công nghệ và mỹ thuật sinh viên.
  - Dọc con đường lát đá phẳng là các gian hàng mở (booth) bằng khung gỗ trang nhã, mỗi gian hàng có đèn rọi tiêu điểm màu vàng ấm.
  - Trên cao chăng những dây đèn tròn lung linh như những ngôi sao nhỏ, xen kẽ cờ tam giác trang trí pastel.
  - Xa xa có các bảng pano led hiển thị đồ họa rực rỡ, cây cối hai bên đường được quấn đèn led đom đóm, vỉa hè se lạnh bóng loáng phản chiếu ánh sáng đêm.
* **Thời gian & Ánh sáng:** 20:00 tối, bầu trời đêm xanh thẫm ánh tím, ánh đèn vàng ấm áp tương phản tạo chiều sâu thị giác huyền ảo.
* **Prompt gợi ý:** `anime visual novel background, bustling outdoor youth night exhibition, pedestrian festival street, elegant wooden showcase booths, string fairy lights glowing warmly overhead, festive atmosphere, deep twilight blue sky, gentle breeze, romantic festival vibes, 16:9 --ar 16:9`

---

### BG 5: Hiên Quán Gờ 23 Lúc Bình Minh (`cafe_sunrise`)
* **Mã tệp đề xuất:** `res://assets/art/bg/cafe_sunrise.jpg`
* **Vị trí xuất hiện:** Phân cảnh 5 Tập 3 (Cảnh tỏ tình chính thức, Ending 1 & Ending 5).
* **Mô tả chi tiết:**
  - Mặt tiền quán cà phê Gờ 23 nhìn từ góc thềm gỗ phía trước.
  - Bậc thềm gỗ thông nâu nhạt dẫn vào cửa kính quán, cạnh thềm có hai chậu cúc họa mi trắng đang hé nở, sương sớm long lanh còn đọng trên từng phiến lá.
  - Tấm biển gỗ khắc chữ "Gờ 23 Coffee & Acoustic" mộc mạc treo dưới hiên mái ngói cổ.
  - Bầu trời phía trước đang chuyển mình từ màu xanh tím lam sang sắc hồng phấn và cam nhạt của tia nắng đầu tiên trong ngày. Không khí trong trẻo, tinh khôi tuyệt đối.
* **Thời gian & Ánh sáng:** 6:00 sáng bình minh, ánh sáng phớt hồng dịu mát, trong trẻo, mang lại cảm giác hy vọng và bắt đầu mới.
* **Prompt gợi ý:** `anime background, rustic cozy cafe storefront at early dawn, wooden entrance steps with morning dew, blooming white daisies in pots, wooden cafe sign under tiled eaves, breathtaking first morning sunlight breaking on horizon, pastel pink and pale golden sky, peaceful and pristine morning atmosphere, Kyoto Animation style, 16:9 --ar 16:9`

---

## III. DANH MỤC SPRITE NHÂN VẬT & BIỂU CẢM MỚI (CHARACTER SPRITES)

---

### 1. Nam Chính: Anh Đức (21 tuổi - Coder / Barista)
* **Đặc điểm diện mạo:** Chiều cao 1m82, dáng người cao ráo, vai rộng, tóc nâu hạt dẻ đánh rối tự nhiên, khuyên tai bạc tròn bên tai trái, ánh mắt sâu thẳm sắc sảo.
* **Trang phục mới cần bổ sung:**
  1. `duc_apron`: Mặc áo polo đen bên trong, khoác tạp dề barista màu nâu sô-cô-la có dây vắt qua cổ và thắt nơ sau eo, xắn tay áo lên một nấc.
  2. `duc_shirt`: Áo sơ mi đen tay dài phom rộng (Oversize) xắn gấu tay lên đến cẳng tay, lộ đồng hồ dây da đen tối giản, quần âu tối màu phẳng phiu (Dành riêng cho đêm triển lãm & tỏ tình).
* **Bộ biểu cảm & Tư thế (Expressions & Poses):**
  * `duc_apron_smile`: Đứng đút một ngón tay vào túi tạp dề, miệng nhếch mép cười trêu chọc KyKy.
  * `duc_soft`: Đứng nghiêng góc 3/4, ánh mắt hạ xuống dịu dàng tràn ngập yêu chiều, hai má ửng hồng rất nhẹ.
  * `duc_dominant`: Đứng thẳng, một tay đút túi quần, lông mày nhíu nhẹ, ánh mắt sắc lạnh nhìn thẳng đối diện (bảo vệ chủ quyền trước Hải).
  * `duc_confess`: Đứng đối diện, tay hơi đưa ra phía trước định nắm tay, ánh mắt chân thành không còn lớp vỏ giễu cợt, hai vành tai đỏ rực.
  * `duc_messy_laugh`: Một tay gãi sau gáy cười sảng khoái, trên má dính một vệt bọt cacao nhỏ màu nâu nhạt.

---

### 2. Nữ Chính: KyKy (19 tuổi - Graphic Designer)
* **Đặc điểm diện mạo:** Chiều cao 1m60, mặt bầu bĩnh đáng yêu, tóc xoăn nâu dài buộc đuôi ngựa lệch hoặc xõa vai, cặp kính tròn to gọng vàng che nửa khuôn mặt, mắt cười cong hình trăng khuyết.
* **Trang phục mới cần bổ sung:**
  1. `kyky_apron`: Mặc áo thun trắng tay lỡ, đeo tạp dề nâu của quán Gờ 23 (hơi dài so với chiều cao, dây buộc nơ to sau lưng), tay đeo găng vải pha chế.
  2. `kyky_dress`: Váy liền màu trắng kem cổ lá sen thanh nhã, thắt nơ nhỏ trước ngực, khoác ngoài áo cardigan len dệt mỏng màu vàng bơ, đeo túi chéo mini hình con mèo.
* **Bộ biểu cảm & Tư thế (Expressions & Poses):**
  * `kyky_apron_blush`: Hai tay ôm khay gỗ trước ngực, mắt tròn xoe nhìn Đức qua cặp kính, hai má đỏ bừng vì ngại khi được buộc tạp dề.
  * `kyky_proud`: Hai tay giơ tập bản vẽ thiết kế lên ngang ngực, ngẩng cằm tự hào, mắt sáng long lanh hoa nở xung quanh.
  * `kyky_sleep`: Tư thế chibi hoặc bán thân gục đầu nghiêng trên bàn gỗ, hai mắt nhắm nghiền say sưa, miệng hơi hé mỉm cười.
  * `kyky_tear_happy`: Hai tay che miệng, mắt ngấn lệ xúc động sau cặp kính, nụ cười hạnh phúc rạng rỡ.
  * `kyky_holding_hand`: Đôi mắt cong hình trăng khuyết, hai tay ôm lấy cánh tay của Đức, nghiêng đầu tựa nhẹ vào vai anh.

---

### 3. Đàn Anh: Hải (22 tuổi - Rival / Senior Designer)
* **Đặc điểm diện mạo:** Chiều cao 1m78, phong thái nho nhã thư sinh, tóc đen rẽ ngôi 7/3 vuốt nếp gọn gàng, đeo kính cận không viền thanh lịch.
* **Trang phục:** Áo sơ mi trắng phẳng phiu, khoác ngoài áo gile len dệt kim màu be nhạt, quần kaki xám tro, đi giày oxford da nâu.
* **Bộ biểu cảm & Tư thế:**
  * `hai_front_flowers`: Hai tay ôm một bó hoa linh lan trắng thắt nơ lụa be trước ngực, nụ cười chuẩn mực dịu dàng.
  * `hai_front_serious`: Hạ bó hoa xuống, mắt nhìn thẳng vào Đức, biểu cảm kiên định nhưng lịch sự.
  * `hai_front_stunned`: Mắt mở to ngạc nhiên, môi hơi hé khi nghe Đức tuyên bố kế hoạch visa đôi.
  * `hai_front_smile_respect`: Cười nhẹ nhún vai, ánh mắt bao dung và nể phục đối thủ.

---

### 4. Hội Bạn Thân & Nhân Vật Phụ
* **Trâm (Bạn thân KyKy):**
  * `tram_ship_smug`: Cầm điện thoại giơ lên giả vờ chụp ảnh, khóe miệng cười nham hiểm kiểu "bắt quả tang hai đứa hẹn hò".
  * `tram_cheer`: Hai tay giơ ngón cái tán thưởng Anh Đức vì pha đối đáp quá ngầu.
* **Đức Anh (Chiến thần IT tóc vàng):**
  * `ducanh_pray`: Chắp hai tay trước ngực cúi rạp người xin KyKy cứu đồ án.
  * `ducanh_jawdrop`: Miệng há hốc hình chữ O, mắt trố lồi vì sốc trước màn tỏ tình của Đức.
* **Thanh Thảo (Nữ thần Code):**
  * `thao_proud`: Đẩy gọng kính đen, tay ôm laptop mỉm cười đắc thắng.
* **Chị Quản Lý M:**
  * `m_panic`: Hai tay ôm đầu, mặt toát mồ hôi hột giữa một rừng giấy order đồ uống.
  * `m_wink`: Cầm khay trà nháy mắt tinh quái ra hiệu cho Đức đưa KyKy ra ngoài dạo phố.
* **Hoàng Thượng Mèo Nlong:**
  * `cat_loaf_sun`: Nằm cuộn tròn hình ổ bánh mì sưởi nắng, đuôi ngoe nguẩy nhẹ.
  * `cat_sit_mess`: Ngồi liếm mép sang chảnh, ria mép bên phải dính một vệt bọt sữa nâu.

---

## IV. DANH MỤC EVENT CG / CUTSCENE MINH HỌA ĐỈNH CAO (FULL CG ARTWORKS)

Các bức tranh minh họa cao trào cốt truyện, tỷ lệ `16:9` (`1920 x 1080 px`), chất lượng hoàn thiện cao nhất để lưu vào mục **Bộ Sưu Tập (Gallery)**:

---

### CG 1: Buộc Tạp Dề Sau Lưng (`cg_tie_apron`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_tie_apron.jpg`
* **Vị trí cốt truyện:** Phân cảnh 2 Tập 3 (Gờ 23 giờ cao điểm).
* **Bố cục & Góc máy:** Cận cảnh ngang vai (Medium close-up) từ góc nghiêng 45 độ phía sau KyKy.
* **Mô tả hành động:**
  - KyKy đứng quay lưng lại, hai tay hơi co lại ngang ngực bối rối, đầu hơi nghiêng sang phải. Cặp kính tròn phản chiếu ánh sáng dịu. Hai má và tai cô nàng đỏ ửng như trái cà chua chín.
  - Anh Đức đứng sát ngay phía sau lưng cô. Đôi bàn tay thon dài gân guốc của anh đang khéo léo thắt chiếc nơ bằng dải ruy băng nâu đậm của tạp dề quanh vòng eo nhỏ của KyKy.
  - Đức hơi cúi đầu xuống gần vành tai cô, ánh mắt tập trung vào nút thắt nhưng khóe môi nhếch lên nụ cười trêu chọc đầy cưng chiều.
  - Phía sau là quầy bar gỗ ấm áp, ánh nắng trưa rọi qua khung cửa sổ rải những hạt bụi vàng óng ánh trong không gian.
* **Cảm xúc mang lại:** Rung động thắt tim (Heart-fluttering), sự gần gũi da thịt tinh tế, mùi hương nước giặt hòa quyện mùi cà phê.
* **Prompt gợi ý:** `masterpiece 2D anime CG illustration, intimate cafe setting, tall handsome male college student with messy brown hair and silver earring standing close behind cute petite female student with messy ponytail and round glasses, tying her brown barista apron strings around her waist, girl blushing deeply with shy expression, guy smirking gently near her ear, warm golden hour sunbeams, cozy vintage coffee shop background, makoto shinkai aesthetic, cinematic lighting, 16:9 --ar 16:9`

---

### CG 2: Ngủ Gục Bên Bàn Đồ Án Lúc Chiều Tà (`cg_sleep_sunset`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_sleep_sunset.jpg`
* **Vị trí cốt truyện:** Phân cảnh 3 Tập 3 (Khoảnh khắc yên bình sau khi fix bug thành công).
* **Bố cục & Góc máy:** Góc chụp từ trên xuống nghiêng 30 độ (Over-the-shoulder view từ vị trí của Anh Đức).
* **Mô tả hành động:**
  - KyKy kiệt sức gục đầu ngủ thiếp đi trên mặt bàn gỗ sồi. Má phải tì lên cuốn sổ tay phác thảo chi chít hình vẽ chibi. Hàng mi cong dài khép lại thanh thản, bờ môi hồng hé mở nhẹ.
  - Cặp kính tròn của cô được gỡ ra đặt cẩn thận trên một cuốn sách dày bên cạnh.
  - Trên vai KyKy choàng chiếc áo khoác polo màu đen của Anh Đức, cổ áo hơi rộng phủ lấy bờ vai gầy nhỏ nhắn.
  - Bàn tay của Anh Đức vươn ra trong khung hình, những ngón tay thon dài đang khẽ lướt nhẹ, nâng niu một lọn tóc mai xoăn vương trên trán cô gái.
  - Toàn bộ khung cảnh chìm trong sắc vàng cam rực rỡ và lãng mạn của ánh hoàng hôn xuyên qua cửa kính lớn, bụi phấn li ti lơ lửng trong không gian tĩnh mịch.
* **Cảm xúc mang lại:** Tình yêu thầm lặng, sự nâng niu bảo bọc tuyệt đối, bình yên sau giông bão deadline.
* **Prompt gợi ý:** `masterpiece anime CG, romantic study room at dusk, cute girl with curly hair sleeping peacefully on wooden desk with cheek on notebook, black oversized jacket draped over her shoulders, round glasses neatly folded beside her, handsome guy's gentle hand gently brushing a strand of hair off her forehead, glorious orange and rose sunset streaming through huge window, soft nostalgic atmosphere, emotional slice-of-life art, 16:9 --ar 16:9`

---

### CG 3: Khẳng Định Chủ Quyền Dưới Ánh Đèn Triển Lãm (`cg_protect_exhibition`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_protect_exhibition.jpg`
* **Vị trí cốt truyện:** Phân cảnh 4 Tập 3 (Đêm triển lãm, đối đầu với Hải).
* **Bố cục & Góc máy:** Cảnh trung (Medium shot) ba nhân vật, ánh sáng tương phản điện ảnh (Cinematic contrast).
* **Mô tả hành động:**
  - Ở trung tâm là Anh Đức trong chiếc áo sơ mi đen xắn tay cực ngầu. Một tay anh đút túi quần, cánh tay còn lại tự nhiên choàng qua vai KyKy, kéo cô nép sát vào ngực mình. Gương mặt anh ngẩng cao, ánh mắt kiên định, bản lĩnh và tràn đầy khí chất áp đảo.
  - KyKy mặc chiếc váy kem thanh nhã, hai tay ôm tập hồ sơ đồ án trước ngực, nép sát vào người Đức, ngước đôi mắt tròn xoe nhìn góc nghiêng của anh với vẻ bất ngờ xen lẫn tin tưởng và ngập tràn hạnh phúc.
  - Phía đối diện là đàn anh Hải cầm bó hoa linh lan trắng muốt, nụ cười lịch lãm hơi khựng lại, ánh mắt thoáng vẻ sững sờ trước tuyên bố học bổng đôi của Đức.
  - Hậu cảnh là dòng người mờ ảo của đêm hội triển lãm sinh viên, với hàng ngàn dây đèn led vàng lung linh rực sáng trên nền trời đêm xanh thẫm.
* **Cảm xúc mang lại:** Vỡ òa vì sự bảo vệ mạnh mẽ, dứt khoát của nam chính, sự khẳng định tình cảm công khai trước mọi người.
* **Prompt gợi ý:** `dramatic anime CG artwork, youth exhibition night festival, tall cool guy in black rolled-up dress shirt boldly wrapping his arm around cute girl in cream dress, pulling her close protectively, sharp intense gaze towards polite rival holding white lily bouquet, girl looking up at him with surprised sparkling eyes, bokeh fairy lights and glowing booths in festival night background, high quality anime render, 16:9 --ar 16:9`

---

### CG 4: Lời Tỏ Tình Dưới Vòm Nắng Sớm (TRUE ENDING CG) (`cg_confession_sunrise`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_confession_sunrise.jpg`
* **Vị trí cốt truyện:** Ending 1 & Cảnh kết viên mãn Tập 3.
* **Bố cục & Góc máy:** Cảnh toàn lãng mạn (Wide romantic shot), bố cục trung tâm hài hòa.
* **Mô tả hành động:**
  - Bậc thềm gỗ mộc mạc trước hiên quán cà phê Gờ 23 lúc 6:00 sáng.
  - Bầu trời phía trước rực rỡ sắc màu bình minh: ánh sáng phớt hồng, tím nhạt hòa cùng những vạt nắng vàng đầu tiên chiếu rọi hiên quán.
  - Anh Đức và KyKy ngồi sát bên nhau trên thềm gỗ. Mười ngón tay của hai người đan chặt vào nhau (interlocked fingers).
  - Đức nghiêng đầu cúi xuống, dịu dàng đặt một nụ hôn khẽ lên vầng trán của KyKy.
  - KyKy nhắm mắt mỉm cười rạng rỡ, đôi má ửng hồng phớt, hai tay ôm lấy cánh tay của anh.
  - Dưới chân hai người, chú mèo béo Nlong ngồi ngoan ngoãn ngước nhìn lên với đôi mắt vàng hổ phách tròn xoe.
  - Bên cạnh thềm là hai chiếc ly sứ màu kem bốc khói mỏng manh và chậu cúc họa mi trắng đang đung đưa trong gió sớm.
* **Cảm xúc mang lại:** Tình yêu thanh xuân trọn vẹn, ấm áp, chữa lành và ngọt ngào vĩnh cửu.
* **Prompt gợi ý:** `ultimate masterpiece anime CG, magnificent early morning sunrise at cozy rustic cafe porch, handsome guy gently kissing forehead of cute smiling girl, their fingers tightly intertwined, girl smiling blissfully with flushed cheeks, fat fluffy gray cat sitting beside them looking up, warm pastel sunrise sky with golden rays, two steaming ceramic mugs on wooden steps, pure romance and heartwarming closure, makoto shinkai aesthetic, 16:9 --ar 16:9`

---

### CG 5: Hộp Bánh Hơi Cháy & Nụ Cười Ban Mai (`cg_burnt_cookies`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_burnt_cookies.jpg`
* **Vị trí cốt truyện:** Ending 2 & Nhánh tặng áo khoác.
* **Mô tả hành động:**
  - Cận cảnh hai nhân vật ngồi trên băng ghế đá sân trường. Anh Đức đang ngửa đầu nhai chiếc bánh quy viền cháy, giơ ngón tay cái cười rạng rỡ trêu KyKy.
  - KyKy hai tay ôm chiếc hộp thiếc hoa văn vintage, mắt cong thành hình trăng khuyết cười tít mắt, nụ cười tỏa nắng xua tan mọi âu lo.
* **Prompt gợi ý:** `close-up anime CG, college bench under lush tree, cute girl laughing with crescent eyes holding vintage cookie tin, cool guy eating slightly burnt homemade cookie with affectionate smirk and thumbs up, playful romance, bright morning sun, 16:9 --ar 16:9`

---

### CG 6: Bọt Sữa & Hoàng Thượng Ban Hôn (COMEDY CG) (`cg_chaos_kiss`)
* **Mã tệp đề xuất:** `res://assets/art/cg/cg_chaos_kiss.jpg`
* **Vị trí cốt truyện:** Ending 5 (Hỗn loạn hài hước).
* **Mô tả hành động:**
  - Đức và KyKy ngồi bệt trên sàn thềm gỗ cười ngặt nghẽo. Chóp mũi của Đức bị dính một vệt bọt cacao trắng xóa, trán KyKy cũng lem một vệt bột bánh.
  - Ở giữa hai người, chú mèo béo Nlong ngồi liếm mép vẻ vô can đắc thắng, đuôi ngoe nguẩy. Cả hai nhìn nhau cười không ngớt, xóa nhòa mọi khoảng cách.
* **Prompt gợi ý:** `hilarious sweet anime CG, cute couple sitting on wooden floor laughing heartily, guy has white milk foam on nose tip, girl has cookie crumb on forehead, chubby funny gray cat sitting between them licking lips smugly, spilled cocoa cup on floor, bright morning sunlight, comedic and joyful romance, 16:9 --ar 16:9`

---

## V. DANH MỤC ĐẠO CỤ, BIỂU TƯỢNG UI & MINI-GAME (PROPS & UI ASSETS)

---

### 1. Tài Nguyên Cho Mini-game 1 (Barista Giờ Cao Điểm)
* `prop_cup_cacao`: Ly sứ trắng men dày vẽ hình chú rùa nhỏ màu nâu.
* `prop_cup_latte`: Ly thủy tinh hai lớp quai trong suốt, có bọt sữa phân tầng đẹp mắt.
* `prop_syrup_ginger`: Chai siro thủy tinh màu hổ phách có nhãn giấy kraft "Gừng ấm Gờ 23".
* `prop_milk_pitcher`: Ca đánh sữa inox 304 sáng bóng có vòi rót nhọn.
* `art_stencil_nlong`: Khuôn rắc bột cacao hình khuôn mặt mèo Nlong béo.
* `art_stencil_heart`: Khuôn rắc bột hình trái tim lồng đôi.

---

### 2. Tài Nguyên Cho Mini-game 2 (Đồng Bộ UI & Logic)
* `ui_node_nlong`: Nút bấm giao diện hình chú mèo Nlong đeo tai nghe nhạc (PNG 128x128).
* `ui_node_tea`: Biểu tượng tách trà gừng bốc khói cách điệu đường nét đơn sắc pastel (PNG 128x128).
* `ui_node_eyes`: Biểu tượng đôi mắt cười trăng khuyết lấp lánh ngôi sao (PNG 128x128).
* `ui_node_letter`: Phong thư tình phong cách retro dán tem con rùa khóc (PNG 128x128).
* `ui_cable_glow`: Hiệu ứng dây cáp phát sáng nối liền hai module khi người chơi kéo thả chính xác (Màu xanh mint `#84DCC6` và cam đào `#F28482`).

---

### 3. Đạo Cụ Cốt Truyện (Story Props - Dùng cho Roam / Inventory)
* `item_polo_jacket`: Chiếc áo khoác polo đen gấp gọn gàng, thắt ruy băng vải màu kem kèm mẩu giấy note thơm mùi hoa cúc.
* `item_cookie_box`: Hộp thiếc hình chữ nhật đựng 6 chiếc bánh quy hạnh nhân viền nâu cháy.
* `item_lily_bouquet`: Bó hoa linh lan trắng muốt bọc giấy báo phong cách Pháp cổ điển.
* `item_keychain_pair`: Cặp móc khóa đôi: một chiếc hình chiếc laptop mini mở màn hình trái tim, một chiếc hình bảng vẽ điện tử mini có hình mèo béo.

---

## VI. BẢNG PHÂN BỔ TÀI NGUYÊN THEO PHÂN CẢNH TẬP 3

| Phân Cảnh | Bối Cảnh (BG) | Nhân Vật Xuất Hiện (Sprites) | Event CG / Mini-game | Đạo Cụ (Props) |
| :--- | :--- | :--- | :--- | :--- |
| **Phân cảnh 1: Nắng Sân Trường** | `campus_day` | Anh Đức, KyKy, Hải, Đức Anh, Thanh Thảo | CG `cg_burnt_cookies` (Tùy chọn) | Áo khoác polo, Hộp bánh cháy, Hồ sơ triển lãm |
| **Phân cảnh 2: Giờ Cao Điểm Gờ 23** | `cafe_day_rush` | Anh Đức (Apron), KyKy (Apron), Chị M, Nlong | Mini-game 1: Barista Rush<br>CG `cg_tie_apron` | Tạp dề nâu, Máy pha cà phê, Ca đánh sữa |
| **Phân cảnh 3: Deadline & Hoàng Hôn** | `study_sunset` | Anh Đức, KyKy, Đức Anh, Thanh Thảo | Mini-game 2: UI Logic Sync<br>CG `cg_sleep_sunset` | Bản vẽ UI, Laptop code, Kính tròn KyKy |
| **Phân cảnh 4: Đêm Triển Lãm** | `exhibition_night` | Anh Đức (Shirt), KyKy (Dress), Hải, Trâm | CG `cg_protect_exhibition` | Bó hoa linh lan, Pano triển lãm |
| **Phân cảnh 5: Bình Minh Tỏ Tình** | `cafe_sunrise` | Anh Đức, KyKy, Nlong, Chị M, Trâm | CG `cg_confession_sunrise` (True Ending)<br>CG `cg_chaos_kiss` (Comedy Ending) | Ly cacao bốc khói, Thềm gỗ Gờ 23 |

---
*Tài liệu này được biên soạn đầy đủ để đội ngũ họa sĩ hoặc AI generator có thể trực tiếp triển khai hình ảnh chuẩn xác theo kích thước, tông màu và cảm xúc từng phân cảnh.*
