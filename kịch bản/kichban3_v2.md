# TẬP 3 (bản v2) — Đồ Án Chung & Lời Hứa Dưới Nắng Sớm
Hợp nhất từ `kichban3.md` (Gemini) + góp ý của Claude (`memory/ai_bridge.md`). Giữ nguyên: bánh cháy, mini-game ghép UI/code,
cảnh KyKy ngủ gục, lời tỏ tình bình minh, Nlong làm đổ ly. Sửa: chỉ số, roam, thứ tự cảm xúc của Đức, vai Hải, quyết định du học.

## 0. Nguyên tắc biên kịch (đối chiếu tiêu chí của tác giả)
1. **Nhẹ nhàng, tự do:** xen 2 bản đồ đi lại giữa các cảnh (như Tập 1–2). Không cảnh nào ép người chơi chạy theo một đường.
2. **Đức tôn trọng trước, tuyên bố sau:** Đức không bao giờ quyết thay KyKy. Anh chỉ nói "em muốn gì, tôi ở đây" cho tới khi KyKy tự chọn.
3. **Mỗi nhân vật có một bước trưởng thành, thể hiện bằng hành động:**
   - **Đức:** học cách *không giữ chặt*. Tập 2 anh ghen và "đánh dấu chủ quyền"; Tập 3 anh dám đứng sau cho cô bay.
   - **KyKy:** tự tìm và sửa lỗi đồ họa (không chờ Đức cứu), rồi tự quyết chuyện học bổng.
   - **Hải:** đối thủ quân tử có lý riêng (từng bỏ lỡ cơ hội vì không dám hỏi). Anh nói chuyện riêng với Đức một lần, thẳng thắn.
   - **Trâm / M / Thảo / Đức Anh / Nlong:** mỗi người có 1 khoảnh khắc ở roam hoặc ở cảnh chung (xem bảng 3).
4. **Thân mật vừa phải:** dừng ở chạm tay, khoác áo, đỡ khuỷu tay, tựa vai. Không ôm eo hay kéo vào lòng (nhất quán với Tập 1–2).
5. **Lựa chọn có đánh đổi,** không có đáp án "luôn đúng nhất".

## 1. Chỉ số & cờ (dùng lại hệ thống hiện có)
| Kịch bản cũ | Dùng trong game | Ghi chú |
|---|---|---|
| Heartbeat | `heart` | thanh dài hơn: đề xuất `BAR_MAX_EP3.heart = 36` |
| Logic_Sync | `brain` | đổi nhãn Tập 3 thành "Đồng điệu" (cần sửa chữ HUD theo tập) |
| Tram_Trust | `tram` | giữ |
| Jealousy_Meter | `jealous` | giữ, nhưng cao = Đức nắm chặt (xem kết cục 4) |
| (mới) | `respect` | "Đức ủng hộ lựa chọn của KyKy"; hiện ở Menu → Quan hệ |
| (có sẵn) | `hai`, `nlong`, `ducanh`, `thao` | dùng tiếp |

**Mang sang từ Tập 2:** thêm `GameState.ep2_last` (giống `ep1_last`) → cờ `ep2_gau|lau|ao|dua|nlong`. Mở đầu cảnh 1 đổi theo cờ:
- `ep2_ao` / `gave_jacket`: KyKy trả áo + bánh cháy (nội dung gốc).
- `ep2_gau` / `claw_win`: gấu bông (Nlong Junior) đeo ở túi KyKy. Gấu là manh mối của nhiệm vụ roam (mục 3).
- `ep2_lau`: Trâm nhắc "bữa lẩu ra mắt" để đẩy thuyền.
- `ep2_dua`: Hải gặp Đức với vẻ tôn trọng nặng hơn, Đức thì cộc hơn lúc đầu.
- `ep2_nlong`: Nlong chủ động đi theo KyKy cả tập.

**Cờ quyết định Tập 3 (kiểm được bằng test route):** `burnt_cake_eaten`, `kyky_joined_team`, `junior_found`, `kyky_fixed_bug` (tự sửa lỗi ảnh),
`hai_talk` (nói chuyện riêng với Hải), `kyky_heard` (nghe được câu của Đức lúc ngủ), `kyky_goes` / `kyky_stays` (quyết định học bổng), `confessed`.

## 2. Mạch bước truyện (đề xuất, theo `story_steps.gd`)
| Bước | Nội dung |
|---|---|
| `vn:ep3_s1` | Sân trường 8:30. Trả áo/bánh cháy → Hải mời hợp tác → Thảo + Đức Anh xin KyKy vẽ UI đồ án |
| `roam:ep3_campus` | **Tự do (bản đồ `campus`):** nhiệm vụ "Nlong Junior mất tích" + gặp thầy khoa, sinh viên năm nhất, bảng thông báo |
| `vn:ep3_s2` | Gờ 23 giờ cao điểm: M vắng người, hai người chia việc quầy bar |
| `mini:rush` | Mini-game phối hợp ly nước (cơ chế mới, xem mục 4) |
| `vn:ep3_s2b` | Sau giờ cao điểm: chạm tay, KyKy trượt nhẹ, Đức đỡ khuỷu tay; M tặng bánh |
| `vn:ep3_s3` | Chiều tà góc sách: lỗi `Null Pointer Heartbeat`; **KyKy tự dò ra lỗi ảnh** |
| `mini:sync` | Ghép 4 cặp UI-hàm (mục 4) |
| `vn:ep3_s3b` | KyKy ngủ gục, Đức đắp áo, nói khẽ; Nlong Junior ló ra từ gầm bàn (kết nhiệm vụ nếu `junior_found`) |
| `roam:ep3_expo` | **Tự do (phố triển lãm đêm):** gian hàng, Trâm đẩy thuyền, bác bán móc khóa, Thầy, Hải, freelancer |
| `vn:ep3_s4` | Hải và Đức nói chuyện riêng; KyKy tâm sự về học bổng; **KyKy tự chọn** |
| `vn:ep3_s5` | Bình minh trước hiên: Đức tỏ tình, nhánh theo `kyky_goes/stays` |
| `phone:ep3_end` → `ending` | Tin nhắn nhóm + màn kết thúc |

## 3. Nội dung từng cảnh (bản sửa)

### Cảnh 1 — Nắng sân trường
Giữ đoạn hù/"mùi hoa cúc dại" và bánh cháy. Chỉnh:
- **Thời gian:** triển lãm là **tối thứ Bảy tuần này** (3 ngày nữa). Hồ sơ học bổng của Hải hạn **Chủ nhật**. Không còn "tháng tới".
- **Hải:** mời KyKy *đứng tên chung* vì từng xem tranh cô ở triển lãm Tập 2; không có câu nào ngụ ý anh dùng quyền trưởng ban.
- **Lựa chọn 1 (bánh cháy)**, ba hướng có cái giá riêng:
  - A: ăn liền, khen thật lòng → `heart +3`, `tram +1`, cờ `burnt_cake_eaten`.
  - B: trêu rồi giấu vào balo "không cho Đức Anh" → `heart +2`, `jealous +1`.
  - C: chỉ cách chỉnh lò 160 độ → `brain +2`, `heart -1`; KyKy bĩu môi nhưng lần sau bánh khá hơn (cờ `better_cake` đổi lời cảnh 5).
- **Lựa chọn 2 (nhóm nào?)**: Đức *không thuyết phục*, chỉ nói thật. Ba cách nói:
  - A: "Dự án cần em, nhưng em chọn." → `respect +2`, `heart +2`.
  - B: "Về đội tôi, hồ sơ năng lực của em sẽ rất mạnh." → `brain +2`, `respect +1`.
  - C: im lặng nhìn, để Trâm xung phong nhận kèo hộ → `tram +2`, `respect -1` (KyKy hơi thất vọng vì Đức không nói gì).
  - **Cả 3 đều dẫn tới `kyky_joined_team`** (KyKy chọn nhóm Đức vì đồ án gấp), nhưng lời Hải khác nhau theo `respect`.

### Roam `campus` (mới)
Nhiệm vụ: *"Nlong Junior mất tích"* (nếu `claw_win`; nếu không có gấu thì là "chiếc móc khóa Nlong" của Trâm). Người chơi hỏi đường dần:
- Thầy Trưởng khoa dưới gốc xà cừ: khen nhóm, buột miệng "cô bé thiết kế mát mắt".
- Sinh viên năm nhất chạy deadline (vòng lặp For): Đức hướng dẫn một câu, cậu ấy cúng trà sữa → KyKy nhớ lại chính mình ở Tập 1.
- Bảng thông báo triển lãm: đọc được ngày giờ, ai nộp học bổng.
- Thảo: hé lộ lý do cô cần Đức giúp đồ án (tốt nghiệp), đưa chi tiết "thầy chê giao diện".
- Trâm (hoặc Nlong thật): cho manh mối "gấu bị mèo tha về quán". Kết thúc roam khi đã nghe đủ 3 người hoặc bấm về quán.

### Cảnh 2 + mini-game rush + 2b — Giờ cao điểm
- Giữ tình huống M thiếu người. Sửa cảnh tạp dề: KyKy loay hoay, **Đức đưa sợi dây, KyKy tự thắt** (không vòng tay qua eo). Đức: "Đứng cạnh tôi, làm theo hiệu lệnh, cấm làm đổ sữa."
- 2b: cả hai với tay lấy ly, ngón tay chạm nhau; KyKy trượt, Đức nắm khuỷu tay đỡ. Cả quán ồ lên, Nlong "Meo~~". M miễn phí đồ uống cho KyKy khi đạt điểm tốt.

### Cảnh 3 + mini-game sync + 3b — Chiều tà
- **Điểm sửa quan trọng:** KyKy không chỉ chờ được cứu. Cô nhìn log, tự đoán "có phải ảnh icon 4K nặng quá?", thử xuất lại ảnh nhỏ hơn → hết một lỗi (cờ `kyky_fixed_bug`). Lỗi còn lại nằm ở hàm kết nối của Đức: anh nhận trách nhiệm ("lỗi này của tôi") và hai người sửa mỗi người một nửa. Đây là cú *chứng minh năng lực* của KyKy.
- 3b: giữ nguyên cảnh ngủ gục và câu "Lỗi logic lớn nhất đời tôi…". Thêm nhánh: nếu `brain` đạt ngưỡng, KyKy hé mắt nghe được → `kyky_heard` → ở cảnh 5 cô nói "em nghe thấy rồi" và đỡ ngượng cho Đức.
- Nlong Junior ló ra khỏi gầm bàn. KyKy đặt gấu cạnh laptop làm "linh vật đồ án".

### Roam `expo` (mới)
Phố triển lãm ban đêm, KyKy đi theo (cơ chế follower giống `street.json`). Gian hàng để chọn (tối đa 3, mỗi nơi một cảnh nhỏ):
- Gian "Trạm Dừng Chân" của nhóm: nhìn người xem, cảm xúc KyKy, Thầy chấm điểm tối đa.
- Bác bán móc khóa đôi: mua hay không (cờ `bought_keychain`, dùng ở cảnh 5 / tin nhắn kết).
- Trâm + M ở quán trà gừng: Trâm đẩy thuyền (Flag `Street_Date`): hai người "tình cờ" bị bỏ lại hai chiếc ghế cạnh nhau.
- Freelancer "cột sống đã ổn" khao nước, cảm ơn giao diện.
- Hải ở cuối phố cạnh bảng học bổng: khi người chơi đến, chuyển vào `vn:ep3_s4`.

### Cảnh 4 — Hải, Đức và quyết định của KyKy
Thay "pha khẳng định chủ quyền" bằng ba nhịp:
1. **Hải và Đức nói riêng** (cờ `hai_talk`): Hải thú nhận mình từng im lặng đến lúc mất cơ hội, nên giờ không muốn để cơ hội của KyKy trôi. Anh không đòi cô, chỉ nói "hồ sơ này xứng với cô ấy". Đức đáp: "Tôi không giữ cô ấy. Tôi chỉ muốn là người cô ấy tìm khi quay đầu lại." Hải gật: "Vậy thì đủ rồi." (Không có câu "tôi thua".)
2. **KyKy tâm sự riêng với Đức:** cô sợ đi xa, sợ không đủ giỏi, cũng sợ để lại những người mình thương. **Lựa chọn 3 (Đức nói gì?)** quyết định nhãn:
   - A: "Em đi, tôi đợi" → `respect +3`, hướng `kyky_goes`.
   - B: "Ở lại cũng không phải bỏ cuộc, miễn là em muốn" → `respect +3`, hướng `kyky_stays`.
   - C: "Tôi cũng không biết, nhưng tôi sẽ ở đây dù em chọn gì" → `heart +3`, KyKy tự cân nhắc.
   - D (chỉ hiện nếu `jealous` cao): "Đừng đi" → `jealous +3`, `respect -3`: KyKy im lặng, cảnh sau lạnh hơn.
3. **KyKy tự chọn** (người chơi chọn thay KyKy qua một câu hỏi duy nhất "Cô ấy nghĩ gì?"): chỉ các lựa chọn còn mở dựa trên chỉ số mới được bật. Kết quả đặt `kyky_goes` hoặc `kyky_stays`.

### Cảnh 5 — Bình minh trước hiên
Giữ nguyên khung: hai ly cacao, trái tim nguyên vẹn (hoặc **cháy một góc** nếu `better_cake` sai), Nlong ngủ trên đùi, áo khoác. Lời tỏ tình giữ nguyên ý chính, cắt câu "ghen lồng lộn" nếu `jealous` thấp. Nhánh theo kết cục (mục 5).

## 4. Hai mini-game (khác Tập 1–2)
- **`mini:rush` (thay "barista nhịp")**: 3 phiếu order cùng chạy đồng hồ. Người chơi làm cả hai vai bằng 2 nút: *Đức* bấm giữ để pha, *KyKy* kéo thả rót sữa. Điểm nằm ở phối hợp, không phải độ chính xác thanh trượt. Tận dụng `MiniFrame.intro/result`. Cờ kết quả `rush_good` / `rush_ok`. Có tuỳ chọn `timer_scale` (theo `GameState.settings`).
- **`mini:sync`**: ghép 4 cặp UI-hàm như bản gốc, **thêm 1 cặp gây nhiễu** (KyKy chỉ ra "cái này không hợp vì…" → tăng `brain`). Cho phép sai 2 lần, hết giờ không phạt (tôn trọng `timer_scale = 0`).

## 5. Năm kết thúc (xét theo thứ tự, ngưỡng cần hiệu chỉnh)
| # | id đề xuất | Tên | Điều kiện (khởi điểm) | Nội dung chính |
|---|---|---|---|---|
| 1 | `ep3_loi_logic` | Lỗi Logic Duy Nhất Là Em | `heart ≥ 24`, `respect ≥ 5`, `brain ≥ 4`, `kyky_fixed_bug` | KyKy nộp hồ sơ *và* tiếp tục dự án; hai người tỏ tình, hẹn "sẽ cùng nhìn nhau lớn". CG nắng sớm |
| 2 | `ep3_paris` | Hẹn Ước Dưới Bầu Trời Xa | `kyky_goes`, `heart ≥ 20`, `respect ≥ 4` | Buồn-ngọt: Đức tỏ tình *rồi* tiễn cô đi, hẹn đợi. **Không có vé bay theo.** CG sân bay |
| 3 | `ep3_dong_chu_quan` | Trạm Dừng Chân Của Riêng Hai Đứa | `kyky_stays`, `tram ≥ 3`, `heart ≥ 18` | KyKy ở lại vì dự án "Trạm Dừng Chân" mới bắt đầu; menu Gờ 23 mới. CG sau quầy bar |
| 4 | `ep3_hoc_cach_tin` | Học Cách Tin | `jealous ≥ 6` | Đức tỏ tình vụng; KyKy nói thẳng "em thích anh, nhưng đừng giữ em chặt quá". Đức xin lỗi, ghi tên đồng tác giả (có sự đồng ý của KyKy) |
| 5 | `ep3_hoang_thuong` | Hoàng Thượng Ban Hôn Lúc Bình Minh | mặc định | Nlong làm đổ ly, hai người cười lem luốc, tỏ tình bằng câu đùa |

Ghi chú: kết 5 vẫn là một lời tỏ tình thành công, nhưng 2 và 4 có vị khác để kết cục không "ngọt đều". Sau khi code xong cần chạy phân bố 250 người chơi ngẫu nhiên (như Tập 2) và chỉnh ngưỡng cho mỗi kết thúc xuất hiện hợp lý.

## 6. Việc triển khai (theo thứ tự đề xuất)
1. `GameState`: thêm `ep2_last`, `BAR_MAX_EP3`, chỉ số `respect`; `Steps.EPISODES[3]`, `ROAM_MAPS` + `ROAM_VARIANTS` cho `ep3_campus` / `ep3_expo`; `episode_of()` nhận Tập 3.
2. Dữ liệu: `data/dialogue/ep3_s1..s5*.json`, `data/roam/campus.json` + `expo.json`, `data/phone/ep3_end.json`, `endings.json` (5 mục `episode: 3`), `cgs.json`.
3. Mini-game `rush` và `sync` (dùng `MiniFrame`), thêm vào `MINI_NEXT` và `SCENES`.
4. Test: route cho từng kết cục trong `tests/run_tests.gd`, GUT cho `ep2_last` mang sang, phân bố kết cục, autoplay `--episode=3`.
5. Cập nhật `docs/STORY.md`, `docs/CREDITS.md` cho mọi asset mới.

## 7. Tài nguyên hình ảnh
- **Đã có, dùng được ngay:** `campus.jpg` (cảnh 1, roam campus), `cafe_day.jpg` (cảnh 2), `library.jpg` / `cafe_sunset.jpg` (cảnh 3), `cafe_morning.jpg` (cảnh 5), `street_rain.jpg` + `map_street.jpg` (tạm cho phố triển lãm).
- **Cần làm mới (xem `thiết kế/yeucauhinhanh.md`):** nền `exhibition_night`, `map_campus`; sprite tạp dề, váy kem, sơ mi đen, Hải cầm hoa; CG. Để bắt đầu, đề xuất **3 CG** (bánh cháy, ngủ gục chiều tà, bình minh tỏ tình) thay vì 6, các kết cục còn lại dùng ảnh nền + sprite.
- Nhạc: `morning_acoustic`, `cafe_rush`, `sunset_piano`, `first_sunlight_orchestra` chưa có trong repo. Dùng nhạc sẵn có trước, bài mới phải thêm vào `export_files` của preset `WebMusic`.

## 8. Quyết định của tác giả (2026-11-07)
- **Giữ tên "Đức Anh".** Trong lời dẫn dùng "Đức Anh" đầy đủ; Đức gọi bạn là "thằng Đức Anh".
- **Chấp nhận** kết cục buồn-ngọt (`ep3_paris`) và vai Hải "có lý riêng".
- **Tập 3 KHÔNG phải tập cuối: mọi kết cục phải để kết mở, úp mở cho Tập 4.** Quy tắc viết kết cục:
  - Không có kết "trọn đời / cưới / hết chuyện". Mỗi kết kết bằng một **lời hẹn hoặc một mầm chuyện** chưa giải xong.
  - Màn kết thúc có đoạn nhá hàng Tập 4 (như Tập 1 nhá hàng Tập 2), đổi theo kết cục.
  - Mầm chuyện gợi ý (mỗi kết một cái, lưu bằng `GameState.ep3_last` để Tập 4 đọc):
    1. `ep3_loi_logic`: hồ sơ học bổng đã nộp, kết quả sẽ có sau vài tuần. Cả hai chờ thư.
    2. `ep3_paris`: KyKy sắp bay, "6 tháng" là lời hẹn, Đức lặng lẽ nhận email từ viện nghiên cứu cùng thành phố (chưa mở).
    3. `ep3_dong_chu_quan`: Gờ 23 nhận lời mời mở chi nhánh / hợp tác, KyKy và Đức chưa biết nhận hay không.
    4. `ep3_hoc_cach_tin`: KyKy nói "cho em thời gian", Đức hứa tự sửa; Hải gửi thư mời lần nữa.
    5. `ep3_hoang_thuong`: Nlong để lại dấu chân mực trên hồ sơ học bổng, "chuyện gì sẽ đến với tờ giấy ấy?".
  - Vì vậy kết cục 2 **không** có vé bay theo (đã loại sẵn ở mục 5). Lời "đợi" phải còn nghi vấn.
