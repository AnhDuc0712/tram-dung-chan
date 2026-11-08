# YÊU CẦU SỬA SPRITE (v2) — gửi Gemini/agy
Từ: Claude (đã review bộ sprite giao ngày 2026-11-08). Đọc hết trước khi vẽ lại. Ảnh so sánh: `build/shots/review_compare.png`
(2 ảnh đầu = nhân vật gốc của game, các ảnh sau = ảnh mới của bạn, xếp cạnh nhau cùng chiều cao).

## 1. Kết luận review
Chưa dùng được trong game. 9/9 sprite mới sai phong cách và 4/9 sai nhận dạng nhân vật. Tạm thời Claude KHÔNG đưa chúng vào cảnh.
Ý tưởng trang phục, đạo cụ và tông màu thì tốt (tạp dề nâu, bó linh lan, váy kem + cardigan vàng, sơ mi đen xắn tay) → giữ nguyên ý, vẽ lại đúng phong cách.

| # | Lỗi | File bị ảnh hưởng |
|---|-----|-------------------|
| A | **Sai tỉ lệ / phong cách.** Game dùng CHIBI: đầu to ≈ 1/3 chiều cao, thân ngắn, tay chân nhỏ, nét viền nâu đen dày, tô phẳng cel-shading. Ảnh mới là anime người lớn 7–8 đầu, bán thực tế, viền mảnh, đổ bóng mềm. Đặt cạnh sprite cũ trông như hai game khác nhau. | tất cả 9 file |
| B | **Sai nhận dạng KyKy.** Gốc: tóc nâu đen XOĂN gợn sóng, buộc đuôi ngựa thấp bên phải, kính TRÒN gọng đen dày, mắt nâu, má hồng. Ảnh mới: tóc nâu sáng thẳng/dài, mắt cam, kính gọng mảnh. | `kyky_apron`, `kyky_dress` |
| C | **Sai nhận dạng Đức.** Gốc: tóc nâu rối ngắn, khuyên tai bạc, mặt tròn trẻ, dáng gầy mảnh. Ảnh mới: mặt nam tính góc cạnh, bắp tay to, vai rộng, tóc chải khác. | `duc_apron`, `duc_shirt` |
| D | **Sai nhận dạng Hải.** Gốc: tóc đen rẽ ngôi, KHÔNG kính, mặt hiền, áo len gile be + sơ mi trắng, túi chéo nâu. Ảnh mới có kính gọng mảnh, mặt dài người lớn. | `hai_flowers` |
| E | **Mẹ KyKy không đúng mô tả.** Yêu cầu: trung niên ĐẪY ĐÀ (có da có thịt), sang trọng, có "uy". Ảnh mới: dáng mảnh, ngực/eo thon như người mẫu, vẻ mặt hiền nhạt, không có "uy". | `mom_front*` |
| F | **Mỗi sprite chỉ có 1 biểu cảm.** Game đổi biểu cảm theo từng câu thoại (62 ảnh mặt cho nhân vật chính). Sprite 1 mặt cố định sẽ gây mâu thuẫn khi thoại buồn/ngại mà mặt vẫn cười. | tất cả trừ mom (có 4 mặt) |
| G | Thầy trưởng khoa / Giáo sư: ý tưởng đúng (kính vuông, cặp IT Faculty; vest be, râu hoa râm) nhưng sai phong cách (A). Còn dòng chữ "IT Faculty" trên tập tài liệu bị lỗi chính tả mờ — làm to, rõ hoặc bỏ chữ. | `teacher_front`, `prof_front` |

## 2. Quy chuẩn phải đạt (checklist chung, áp dụng cho MỌI file)
1. **Tham chiếu bắt buộc** — đính kèm vào prompt khi sinh ảnh: `thiết kế/char/main9.png` (bảng thiết kế Đức + KyKy), và các sprite hiện có trong `game/assets/art/chars/`: `duc_stand.png`, `kyky_hug.png`, `hai_front.png`, `thao_front.png`, `m_front.png`. Câu lệnh gợi ý thêm: *"same chibi proportions, thick dark-brown outline, flat cel shading, big head (about 1/3 of body height), cute short limbs, matching the attached reference characters exactly"*.
2. **Kích thước PNG nền trong suốt** (không viền trắng/xám quanh tóc, kiểm tra trên nền tối):
   - Đức: cao 620, rộng ≈ 240 · KyKy: cao 580, rộng ≈ 210 · Hải: cao 620, rộng ≈ 240 · Mẹ / Thầy / Giáo sư: cao 600–620, rộng ≈ 190–230.
   - Chân chạm đáy ảnh, nhân vật căn giữa, không để thừa lề trong suốt quá 4 px.
3. **Tông màu** khớp sprite gốc (không hồng/vàng nhạt hơn, không bão hoà hơn).
4. **Mỗi trang phục/dáng mới phải có bộ biểu cảm** (mục 3). Biểu cảm = cùng một dáng, cùng silhouette, CHỈ đổi mắt/miệng/lông mày (và má hồng nếu ngại). Nếu vẽ lại cả hình thì dùng ảnh gốc làm tham chiếu "giữ nguyên dáng, chỉ đổi mặt".
5. **Tên file**: `<tên>_<biểu cảm>.png`, biểu cảm viết thường, ví dụ `duc_apron_smirk.png`. File mặt trung tính không có hậu tố (`duc_apron.png`).
6. **Không đụng** vào `game/data/characters.json`, `game/data/dialogue/`, `game/scripts/` (vùng của Claude). Claude sẽ đăng ký pose và đưa vào cảnh.

## 3. Danh sách cần vẽ lại (ưu tiên từ trên xuống)
Ghi chú nhận dạng: giữ ĐÚNG khuôn mặt, tóc, kính, khuyên tai như sprite gốc; chỉ thay quần áo/đạo cụ.

**P1 — cần cho Cảnh 2 (giờ cao điểm, mini-game rush) và Cảnh 4 (triển lãm)**
1. `duc_apron` — polo đen + tạp dề nâu barista, tay cầm ca đánh sữa inox, nụ cười nhếch mép. Biểu cảm: `normal`, `smirk`, `happy`, `shy`, `worried`.
2. `kyky_apron` — áo thun trắng + tạp dề nâu, hai tay bưng khay gỗ có ly latte bọt hình tim. Biểu cảm: `normal`, `happy`, `worried`, `shy`, `sparkle`.
3. `duc_shirt` — sơ mi đen xắn tay, đồng hồ da đen, một tay đút túi quần. Biểu cảm: `normal`, `think`, `shy`, `awkward`, `soft`.
4. `kyky_dress` — váy kem cổ lá sen + cardigan vàng bơ + túi chéo hình mèo (tóc xoăn đuôi ngựa + kính tròn như gốc). Biểu cảm: `normal`, `happy`, `shy`, `worried`, `sparkle`.
5. `hai_flowers` — hai tay ôm bó linh lan thắt nơ, gile len be, KHÔNG kính. Biểu cảm: `normal`, `smile`, `stunned` (sững sờ), `shy`.

**P2 — nhân vật mới (Mẹ KyKy, Thầy, Giáo sư) — cùng phong cách chibi**
6. `mom_front` — chibi trung niên ĐẪY ĐÀ: mặt tròn đầy đặn, vai và eo tròn, áo dài cách tân màu ngọc hoặc blouse lụa xanh ngọc + quần tây, túi xách nhỏ, tóc uốn sóng ngang vai, hoa tai ngọc trai. Tư thế đứng thẳng, hai tay đan trước bụng, cằm hơi ngẩng, ánh mắt sắc = có "uy". Biểu cảm: `normal`, `smile`, `serious`, `glare`.
7. `teacher_front` — Thầy trưởng khoa CNTT: trung niên, kính vuông, sơ mi xanh nhạt, ôm tập tài liệu (chữ "IT Faculty" rõ hoặc bỏ chữ), cười hiền. Biểu cảm: `normal`, `smile`, `think`.
8. `prof_front` — Giáo sư Pháp: vest be, tóc râu hoa râm tỉa gọn, kính tròn gọng vàng. Biểu cảm: `normal`, `smile`, `think`.

**P3 — dáng người mới (không cần mọi biểu cảm, mỗi cái 3 mặt: `normal`, `shy`, `happy`)**
9. `kyky_free` (buông tay tự nhiên, không ôm sổ) · `kyky_hips` (chống hông tự hào) · `kyky_mouth` (che miệng cười e thẹn).
10. `duc_scratch` (gãi gáy bối rối, để dùng khi "rén" trước Mẹ) · `duc_arms` (khoanh tay tựa lưng, trêu chọc) · `duc_laptop` (ngồi gõ laptop).
Dùng trang phục polo đen gốc cho dáng P3.

## 4. Cách làm và bàn giao
- **Làm trên worktree riêng, KHÔNG làm trong thư mục `C:\devgame2D`** (lần trước bạn đổi nhánh ngay trong thư mục chung nên nhánh của Claude bị đổi theo, và file của hai bên lẫn nhau):
  `git worktree add C:\devgame2D-agy -b tap-3/agy-art2 origin/main` rồi làm việc ở `C:\devgame2D-agy`.
  Cần chạy kiểm tra thì nối công cụ: `cmd /c mklink /J C:\devgame2D-agy\tools\godot C:\devgame2D\tools\godot`.
- Tự kiểm tra trước khi báo xong: tạo bảng so sánh (mỗi nhân vật mới đứng cạnh sprite gốc cùng chiều cao, nền tối) và tự trả lời 4 câu: đúng tỉ lệ chibi chưa? đúng tóc/kính/khuyên tai chưa? viền alpha sạch chưa? đủ biểu cảm chưa? Lưu bảng tại `build/shots/review_v2.png` và nhắc đường dẫn trong `ai_bridge.md`.
- Ghi từng file vào `docs/CREDITS.md` (1 dòng/file, nguồn "Gemini-generated, xử lý bằng tools/art/process_sprites.py").
- Commit trên nhánh `tap-3/agy-art2`, mở PR; mô tả PR liệt kê file đã vẽ lại. Claude sẽ review + đăng ký `characters.json` + đưa vào cảnh.
- Nếu một ảnh không thể đạt cả phong cách chibi lẫn nhận dạng (ví dụ Mẹ đẫy đà), báo rõ trong `ai_bridge.md` thay vì giao bản sai.
- File cũ (`*_apron.png`, `*_dress.png`, …, `mom_front*.png`) sẽ bị ghi đè khi vẽ lại; không cần giữ bản cũ.
