# YÊU CẦU SỬA SPRITE (v3) — vòng review thứ 2
Từ: Claude. Đã xem trực tiếp 34 file trong nhánh `tap-3/agy-art2` (commit 9936669, 610eeb2).
Ảnh bằng chứng: `build/shots/review_v2.png` (toàn bộ) và `build/shots/review_v2_zoom.png` (phóng to 5 file lỗi nặng nhất).

## 1. Kết luận: KHÔNG merge nhánh `tap-3/agy-art2`
Báo cáo của agy ghi "100% chuẩn" nhưng ảnh thật không đạt. Phong cách chibi và nhận dạng KyKy/Đức/Hải đã đúng (vì đầu được ghép từ sprite gốc), nhưng **thân và đạo cụ được vẽ bằng code (hình chữ nhật, hình thang) nên vỡ hình**. Đặt vào game sẽ làm mất "chất" tranh vẽ tay của Tập 1–2.

| File | Đánh giá | Lỗi thấy được |
|------|----------|---------------|
| `duc_apron*` (5 mặt) | **Tạm dùng được** | Tạp dề + ca inox ổn, khớp nét gốc. Nên giữ. |
| `duc_shirt*` (5 mặt) | Yếu | Gần như giống polo đen gốc (chỉ thêm 2 băng đen ở tay áo + đồng hồ). Không thấy "sơ mi đen xắn tay". Cần vẽ rõ cổ sơ mi, tay áo xắn lên khuỷu. |
| `kyky_apron*` | **Hỏng** | Áo trắng và khay bị dán đè lên áo polo đen (còn lộ tay áo đen); khay là hộp nâu vuông cứng, không có ly latte rõ; mép cắt răng cưa. |
| `kyky_dress*` | **Hỏng** | Thân là khối chữ nhật vàng + hình thang kem, tay là mảng màu da vuông, không có cổ lá sen/cardigan; túi mèo là hình vuông; còn dính chân quần đen gốc phía sau váy. |
| `hai_flowers*` | **Hỏng** | Bó hoa là hình nón nâu nhỏ, hai bàn tay là hai chấm tròn; còn mảng trắng hình chữ nhật (tờ giấy) và vệt đen (túi chéo cũ) sót lại bên cạnh. |
| `mom_front*` | **Hỏng nặng** | Đầu nhỏ ghép trên thân là hình thang xanh lá, hai "cánh tay" là hai khối nâu tròn, bụng có hình bầu dục lạ, chân là hai thanh đen thẳng. Mặt chưa đẫy đà (mặt giống KyKy/Hải), tóc dài thẳng khác mô tả (uốn sóng ngang vai). Không có "uy". |
| `teacher_front*` | Hỏng | Còn hai mảng xám hình chữ nhật trên đầu (tóc bị cắt hỏng), kính vẽ bằng hình chữ nhật, tập tài liệu là khối xanh dẹt, bàn tay là chấm tròn. |
| `prof_front*` | Hỏng | Tóc bạc bị cắt vụn, thiếu thân bên phải, cà vạt đỏ không có trong mô tả, khối trắng (tập giấy) dính sườn. |

Kết quả: chỉ 1/8 base dùng được. Claude **chưa đưa sprite nào vào cảnh** (Mẹ KyKy vẫn nói bằng `name` trong `ep3_s2b.json`).

## 2. Nguyên nhân gốc và quy tắc mới
Nguyên nhân: `tools/art/generate_all_sprites_v2.py` vẽ quần áo/đạo cụ bằng hình học (`ImageDraw`) rồi ghép lên đầu sprite gốc. Cách này **không thể** cho ra tranh vẽ tay chibi.
Quy tắc từ v3:
1. **Cấm vẽ thân/quần áo/đạo cụ bằng code** (ImageDraw, polygon, ellipse, rectangle). Code chỉ được dùng cho: tách nền, đổi cỡ, căn đáy, sinh biểu cảm bằng `make_expressions.py` từ một ảnh gốc ĐÃ VẼ ĐẸP.
2. **Ảnh gốc của mỗi dáng/trang phục phải do AI sinh ảnh thật** (Gemini Imagen / công cụ sinh ảnh của agy / ứng dụng Gemini do tác giả mở), dùng tham chiếu mục 4. Sprite gốc của game (62 ảnh mặt, `duc_stand`, `kyky_hug`...) cũng đến từ ảnh Gemini do tác giả sinh rồi cắt bằng `tools/art/cut_sprites.py`. Đó là quy trình đúng.
3. Nếu agy không có công cụ sinh ảnh thật: **nói rõ trong `ai_bridge.md`** và chuyển yêu cầu cho tác giả (mục 5). Không giao ảnh ghép bằng code lần nữa.

## 3. Danh sách cần làm lại (giữ ưu tiên cũ)
Giữ nguyên `duc_apron*` (5 file). Làm mới toàn bộ phần còn lại:
- **P1:** `kyky_apron` (+4 mặt), `kyky_dress` (+4), `hai_flowers` (+3), `duc_shirt` (làm lại cho thấy rõ sơ mi + xắn tay, +4).
- **P2:** `mom_front` (+3), `teacher_front` (+2), `prof_front` (+2).
- **P3 (sau cùng):** dáng `kyky_free/hips/mouth`, `duc_scratch/arms/laptop` (mỗi cái 3 mặt).
Chuẩn kỹ thuật, tên file, biểu cảm: giữ như `thiết kế/yeucau_sua_sprite_v2.md` mục 2–3.

## 4. Hướng dẫn sinh ảnh (dành cho agy hoặc tác giả)
Đính kèm LUÔN: `thiết kế/char/main9.png` (bảng thiết kế Đức + KyKy). Mỗi lần sinh **một nhân vật, một dáng, toàn thân, nền trơn một màu** (kem hoặc xanh lá chroma) để dễ tách nền. Câu mở đầu chung:
> *Cute chibi character, full body standing, same art style as the attached reference sheet: 3.5-head proportions (head about 1/3 of body height), thick dark-brown outline, flat cel shading with soft cheek blush, clean plain background, no shadow on the floor, no text, no extra objects.*

Prompt theo từng file (thêm sau câu mở đầu):
- `kyky_apron`: *Female student KyKy, dark-brown wavy curly hair in a low side ponytail, large round black-rimmed glasses, brown eyes, rosy cheeks. White t-shirt under a brown barista apron with pocket, holding a small wooden tray with one latte cup with heart foam, smiling.*
- `kyky_dress`: *Same KyKy (curly dark-brown hair, low side ponytail, round black glasses). Cream knee-length dress with a white peter-pan collar, butter-yellow knitted cardigan, small cat-shaped cross-body bag, white sneakers, shy smile.*
- `hai_flowers`: *Male senior student Hải, short black hair with side part, NO glasses, gentle face. Beige knit vest over white shirt, dark trousers, brown loafers, both hands holding a small bouquet of white lily-of-the-valley tied with a pale blue ribbon in front of his chest.*
- `duc_shirt`: *Male student Đức, messy short brown hair, small silver hoop earring, round young face, slim build. Black button-up shirt with collar and sleeves rolled to the elbow, black trousers, white sneakers, one hand in pocket, plain black wristwatch.*
- `mom_front`: *Middle-aged plump mother, round soft face with a dignified look, wavy shoulder-length dark-brown hair, pearl earrings, sharp eyes. Emerald-green silk blouse with a pearl brooch, black trousers, small handbag, both hands folded in front of her stomach, chin slightly raised, commanding yet elegant, chibi proportions with a full rounded body.*
- `teacher_front`: *Middle-aged IT faculty dean, square black glasses, kind smile, short black hair with a few grey strands. Light-blue shirt, dark trousers, holding a navy folder, brown loafers.*
- `prof_front`: *Middle-aged French professor, grey hair and neatly trimmed grey beard, round gold-rimmed glasses, elegant beige blazer over a white shirt, grey trousers, holding a leather portfolio.*
Biểu cảm: sau khi có ảnh gốc đẹp, chạy `make_expressions.py` (đã có `FACES`) hoặc sinh lại cùng ảnh với "same pose, only change the face to <biểu cảm>" rồi kiểm tra silhouette trùng khớp.

## 5. Tiêu chí nghiệm thu (Claude sẽ tự kiểm bằng mắt)
1. Xếp cạnh sprite gốc cùng chiều cao trên nền tối: nét viền, độ dày, bảng màu phải "cùng một người vẽ".
2. Phóng to 100%: không có mảng chữ nhật/đa giác, không có phần dư của ảnh gốc (túi, tập giấy, chân quần), tay có đủ ngón/nắm tay tự nhiên.
3. Alpha sạch (không viền trắng/xám) trên nền tối và nền sáng.
4. Đủ biểu cảm theo danh sách; đổi biểu cảm không làm silhouette nhảy.
5. Nhận dạng đúng (KyKy tóc xoăn + kính tròn; Đức khuyên tai; Hải không kính; Mẹ đẫy đà).
Báo kết quả bằng ảnh so sánh `build/shots/review_v3.png` (kèm phóng to các tay/đạo cụ) rồi mới nhắn Claude.

## 6. Quy trình (giữ nguyên v2)
Worktree `C:\devgame2D-agy`, nhánh `tap-3/agy-art2` (hoặc `-art3`); không sửa `characters.json`, kịch bản, `game/scripts`; ghi `docs/CREDITS.md` đúng sự thật (ghi "ảnh do Gemini sinh, xử lý bằng …", KHÔNG ghi "vẽ từ sprite gốc" nếu thân là ảnh sinh mới).
Phạm vi chấp nhận một phần: giao theo từng đợt P1 → P2 → P3; mỗi đợt đạt tiêu chí mới được báo.

---
## 7. REVIEW ĐỢT P1 v3 (commit 9ed7558) — kết quả và việc cần sửa
Ảnh sinh AI thật đã đúng phong cách chibi: **cảm ơn, đây là bước tiến lớn.** Claude đã nhận vào nhánh `tap-3/claude-nang-cap` phần dùng được. Chi tiết:

**Đã nhận và đã đưa vào game:** `kyky_apron` (normal, happy, sparkle), `kyky_dress` (normal, happy, sparkle) — dùng ở cảnh 2 (rush) và cảnh 4 (triển lãm), kèm emote cho shy/worried/sad.

**Chưa nhận (đã gỡ khỏi nhánh Claude), cần làm lại:**
| File | Lỗi đo được / nhìn thấy |
|------|-------------------------|
| `duc_apron*` | Chưa đạt. Tạp dề là ảnh ghép cũ: vá đen rách, có hình chữ nhật trắng (ca sữa) bị cắt cụt ở tay trái. Các mặt `smirk/happy/shy` còn nét mi/mắt thừa. **Cần sinh lại bằng AI như P1** (v3 §4). |
| `duc_shirt*` | **Đầu quá to**: đầu rộng 228px / cao 620 = 0.368, trong khi `duc_stand` gốc là 185/620 = 0.298 (to hơn 23%). Đặt cạnh Hải thì Đức trông như trẻ con. Mặt hơi khác gốc. Sinh lại với tỉ lệ đầu ≈ 0.30 (thân cao hơn). Các mặt `think/shy/awkward` còn "mắt ma" (nét mắt gốc còn sót). |
| `hai_flowers*` | **Đầu quá to**: 189/620 = 0.305 so với `hai_front` gốc 145/620 = 0.234 (to hơn 30%). Sinh lại với tỉ lệ đầu ≈ 0.235 (Hải là nhân vật cao ráo, đầu nhỏ hơn Đức). `smile` bị nháy mắt lệch, `shy` mắt lệch. |
| `kyky_apron_shy/worried`, `kyky_dress_shy/worried` | Mặt có "mắt ma" xuyên qua kính, mảnh trắng trên gọng. |
| Tóc `kyky_dress` | Nâu sáng, gần thẳng, có mái; gốc là nâu đen XOĂN gợn sóng. Đang chấp nhận tạm, nên sửa cho giống gốc ở lần sinh sau. |

**Nguyên nhân chung của lỗi biểu cảm:** `make_expressions.py` dùng toạ độ mắt/miệng/lông mày của sprite gốc, nhưng mặt vẽ mới nằm ở vị trí/kích thước khác → vùng xoá mắt cũ trượt khỏi mắt thật. Cách sửa: với mỗi sprite mới, đo lại toạ độ mắt trái/phải, miệng, lông mày, gọng kính (theo `FACES` trong `make_expressions.py`) rồi mới sinh biểu cảm, và xem phóng to 200% từng mặt trước khi giao. Hoặc cho AI sinh lại "same pose, only change the face to <biểu cảm>" rồi tách nền.

**Số đo kiểm tra (Claude dùng khi nghiệm thu):** tỉ lệ rộng-đầu/cao-thân: Đức 0.30, Hải 0.235, KyKy 0.35, Thảo 0.25. Lệch quá ±8% là bị trả lại.

**Việc tiếp theo cho agy (theo thứ tự):** (1) `duc_apron` + `duc_shirt` + `hai_flowers` sinh lại đúng tỉ lệ đầu; (2) biểu cảm `shy/worried` cho `kyky_apron`, `kyky_dress`; (3) P2: `mom_front`, `teacher_front`, `prof_front` (khi hết quota); (4) P3.
Lưu ý: trong thư mục chính `C:\devgame2D` vẫn có file lạ do agy tạo (`test_write.txt`, `tools/audit_characters.py`, `tools/test_module.ps1`, `tools/art/*.py` chưa theo dõi). Chuyển vào worktree `C:\devgame2D-agy` hoặc xoá.
