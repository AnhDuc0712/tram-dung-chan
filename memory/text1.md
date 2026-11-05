cả thư mục này mỗi phiên làm việc bạn làm gì bạn cứ note vào đây và có lỗi hay lần cấn gì bạn cứ note vào đây 

---

# Nhật ký làm việc

## Phiên 1 — 2026-11-05 (sáng): setup môi trường + demo "Phố Hoa"
- Cài Godot 4.7.2 (portable, `tools/godot/`), rembg (`tools/.venv-art/`), dựng demo top-down "Phố Hoa" + harness (check/screenshot/test/hook).
- Vướng: PowerShell 5.1 đọc sai file .ps1 không có BOM → mọi .ps1 phải lưu UTF-8 có BOM. Biến `$args` trùng biến tự động.
- Hệ thống không cho Claude tự ghi `.claude/settings.json` → hook nằm ở `tools/hooks/settings.recommended.json`, bạn tự chép nếu muốn bật.

## Phiên 2 — 2026-11-05 (trưa): dựng **Ver 1 — "Lỗi Logic Trái Tim" Tập 1**
Đọc: `kịch bản/kichban1.md`, `mô tả/mối quan hệ nhân vật.md`, ảnh `thiết kế/char/*` (4 bảng nhân vật), `thiết kế/env/*` (quán top-down, quán hoàng hôn, phố mưa "Gờ 23", mockup UI).

**Đã làm**
- Bỏ demo Phố Hoa, chuyển game sang: visual novel + 2 màn đi lại tự do trong quán + 3 mini-game + điện thoại + 5 kết thúc.
- Cắt 17 tư thế nhân vật từ bảng thiết kế (rembg isnet-anime; mèo dùng "loang màu nền") → `game/assets/art/chars/`.
  Script: `tools/art/cut_sprites.py` (sửa bảng CROPS để cắt thêm). Cắt thêm 6 ô phác thảo biểu cảm (`*_x_*.png`) làm "ô biểu cảm manga".
- Ảnh nền: `cafe_map` (bản đồ đi lại), `cafe_day` (ảnh hoàng hôn chỉnh sang ánh chiều), `cafe_sunset`, `street_rain`.
- Tải tài nguyên CC0 từ OpenGameArt: 9 nhạc nền (guitar mộc, lofi, piano…), 26 âm thanh (Kenney UI, mèo kêu/rừ rừ, chuông cửa, nhịp tim, mưa).
  Font OFL có tiếng Việt: Baloo 2, Nunito, JetBrains Mono. Ghi công đầy đủ: `docs/CREDITS.md`.
- Kịch bản: 4 phân cảnh theo đúng kịch bản của bạn + mở rộng: lựa chọn đếm giờ (sổ bay), tờ note con rùa, bút thỏ,
  "học phí", đếm cánh hoa, mèo đè bàn phím chạm tay, ô hồng chị M, đút súp Nlong, tin nhắn tối + nhóm "Hội Đồ Án IT".
- Viewport đổi 640×360 → 1280×720, lọc ảnh linear (tranh vẽ chứ không phải pixel art).
- Harness: `tools/check.ps1` giờ có 4 bước (import → 14 test dữ liệu + chơi thử 5 kết thúc → chạy từng màn → **tự chơi trọn Tập 1 từ màn hình chính tới kết thúc**).
  `tools/screenshot.ps1` thêm `-Clicks`, `-Extra`; chế độ kiểm thử `--autoplay`, `--autoroam`, `--debug-walk`, `--flags=`.

**Lỗi / vướng đã gặp (để lần sau tránh)**
- Heredoc trong Bash tool đôi khi hỏng khi nội dung dài có dấu nháy → viết file JSON bằng công cụ Write.
- GDScript: hàm tên `mini()` trùng hàm có sẵn; `var x := node.thuoc_tinh` lỗi khi node khai báo kiểu chung (Node2D) → ghi kiểu rõ `var x: float = ...`.
- Gọi hàm coroutine mà không `await` thì không chờ được → `Story.show_card()` trả về Tween để `await tw.finished`.
- Chữ trong hộp thoại bị trắng mờ: theme gốc không áp vào RichTextLabel dưới CanvasLayer → đặt `theme` cho Control gốc + override màu.
- `powershell -File ... -Extra "a","b"` truyền thành một chuỗi "a,b" → script tự tách dấu phẩy.
- Lần import đầu tiên sau khi thêm nhiều ảnh, test báo "thiếu ảnh" (import chưa xong) → chạy lại là hết.
- Chế độ tự chơi lỡ ghi "đã mở kết thúc" vào file meta thật → đã xoá, và giờ autoplay dùng file lưu riêng `autoplay_*.json`.
- Ảnh nhân vật mới có 2 tư thế/người (toàn mặt cười) → biểu cảm buồn/giật mình dùng emote vẽ thêm + ô phác thảo. Muốn đẹp hơn: tạo thêm ảnh biểu cảm màu.

**Chưa làm (chờ bạn quyết)**
- Đóng gói (Windows .exe / bản web cho điện thoại) — chưa chạy theo dặn trước đó.
- Ảnh biểu cảm màu cho KyKy/Anh Đức (khóc, giận, ngại…), ảnh ngồi; Tập 2.

## Phiên 3 — 2026-11-05: đổi tên game thành **"Trạm Dừng Chân"**
- Đổi tên ở: `game/project.godot` (tên + mô tả), `game/export_presets.cfg` (tên sản phẩm, file `TramDungChan.exe`), `tools/build.ps1`,
  màn hình chính (`title_screen.gd`: tiêu đề "Trạm / Dừng Chân", dòng phụ "Quán Gờ 23 · ghé lại một chút" thay cho "Runtime Error: Heartbeat"),
  `README.md`, `docs/STORY.md`, `CLAUDE.md`, skill `viet-hoi-thoai`.
- Giữ nguyên: file gốc của bạn trong `kịch bản/`, `mô tả/` và món nước "Lỗi Logic" trong phân cảnh 2 (là tên món trong truyện).
- Lưu ý: Godot đặt thư mục lưu game theo tên game → cài đặt âm lượng cũ (lưu dưới tên cũ) không mang sang; chưa có file save thật nên không mất gì.
- `tools/check.ps1`: ALL CHECKS PASSED.

## Phiên 4 — 2026-11-05: **ảnh biểu cảm cho tất cả nhân vật** + chọn mặt theo ngữ cảnh
- Công cụ mới `tools/art/make_expressions.py`: từ sprite gốc, tự xoá mắt/miệng/lông mày cũ (loang màu da, giữ gọng kính và tóc)
  rồi vẽ lại → **62 ảnh** `<ảnh gốc>_<biểu cảm>.png` (Anh Đức 17, KyKy 14, chị M 9, Trâm 6, Thảo 4, Đức Anh 5, Hải 4, Nlong 3).
  Biểu cảm: cười híp, cười lớn (> <), sốc mắt tròn, ngạc nhiên, buồn rưng rưng, khóc, giận, hờn "hmph", ngại đỏ mặt, lo lắng,
  tỉnh bơ (deadpan), nhếch mép, hoảng loạn, mệt, lườm, mèo lim dim/lườm/ngủ. Bảng xem nhanh: `build/shots/expressions_sheet.png`.
- `characters.json`: các pose cũ trỏ sang ảnh mới, thêm pose mới (deadpan, panic, hmph, angry, surprised, worried, smug, doze...),
  bỏ ô phác thảo (inset) vì mặt đã tự thể hiện. Danh sách pose + gợi ý chọn mặt: `docs/DIALOGUE_FORMAT.md`.
- Kịch bản: đổi ~30 chỗ và thêm mặt cho ~20 câu chưa có (vd "Keo kiệt!" → hmph; "Chầu lẩu đó là của anh." → deadpan;
  "Cô bé nghe thấy hết rồi." → panic). Mini-game tìm bug: KyKy nghĩ → vui khi đúng / buồn khi sai; giữ bình tĩnh: KyKy ngơ ngác khi anh "lag".
- Tin nhắn: sticker KyKy đổi sang ảnh `kyky_hug_love`.
- `tools/check.ps1`: ALL CHECKS PASSED.

**Lỗi / vướng**
- Lông mày dính vào tóc (Anh Đức nghiêng, Hải) → xoay/xoá bị loang vuông vào tóc → tắt sửa lông mày cho 2 ảnh này; ảnh khác dò nét lông mày theo cột.
- Nhân vật đeo kính: xoá mắt làm mất gọng → khai báo vị trí tròng kính (`lenses`) để giữ gọng.
- Python `-I` bỏ qua biến PYTHONIOENCODING → in tiếng Việt phải `sys.stdout.reconfigure(encoding="utf-8")`.
- Viết chuỗi có `tools\art` trong Python thường → `\a` thành ký tự chuông; dùng công cụ Edit hoặc chuỗi raw.
- Ảnh tạo bằng thuật toán, không phải vẽ tay: soi kỹ (phóng to) còn vài vệt nhỏ ở đuôi lông mày KyKy, trong tròng kính hơi sáng hơn khi mắt nhắm.

## Phiên 5 — 2026-11-05: **kiểm thử kỹ bằng mã nguồn mở** (GUT + gdtoolkit)
- Tải & dùng:
  - **GUT 9.7.1** (Godot Unit Test, MIT, github.com/bitwes/Gut) → `game/addons/gut` (bị loại khỏi bản export).
  - **gdtoolkit 4.5** (`gdlint`, MIT, github.com/Scony/godot-gdscript-toolkit) → `tools/.venv-lint`, cấu hình `game/gdlintrc`.
- Bộ test mới `game/tests/gut/` — 42 test, 608 phép kiểm:
  - đồ thị kịch bản: node thừa, vòng lặp tự chạy, duyệt HẾT mọi tổ hợp lựa chọn, cảnh truyện luôn dẫn sang bước sau, cờ đọc mà không ai bật;
  - chữ & font: mọi ký tự tiếng Việt có trong font, câu thoại không quá 3 dòng, lựa chọn không quá 2 dòng, ngoặc/BBCode cân, dấu cách đôi, emoji;
  - 400 lượt "người chơi ngẫu nhiên" chơi trọn Tập 1 (chọn bừa, đi lại bừa, mini-game bừa) → không lượt nào kẹt; gặp đủ 5 kết thúc;
  - save hỏng / save cũ / thiếu trường / cài đặt rác; tài nguyên thiếu (âm thanh gõ sai tên trước đây bị bỏ qua im lặng);
  - chạy thật giao diện: mọi kịch bản x 3 nhánh, mọi nhân vật x mọi biểu cảm, từng màn chơi.
- `tools/check.ps1` giờ 6 bước: import · gdlint · test cũ · GUT · chạy từng màn · tự chơi trọn. ALL CHECKS PASSED.
- Đã thử gài lỗi cố ý (sfx gõ sai, nối nhầm câu thoại) → test bắt được cả hai.

**Lỗi thật tìm ra & đã sửa**
- `cafe.gd` gãy (Parse Error) do lúc sửa lint đổi tên tham số mà sót 1 chỗ — GUT bắt được ngay. Bài học: sửa xong PHẢI chạy check.ps1.
- Lời giải thích mini-game tìm bug dùng ký tự "→" mà font Nunito không có (bản web sẽ hiện ô vuông) → đổi thành chữ.
- File save/cài đặt hỏng làm engine in lỗi đỏ → `_read_json` dùng `JSON.new().parse()`, chỉ cảnh báo nhẹ.
- gdlint: nạp `shapes.gd` 2 lần trong cùng file, biến khai báo sai thứ tự, tên tham số `name_`, dòng quá dài.

**Vướng**
- Trong Bash tool, `\n` trong heredoc Python bị biến thành xuống dòng thật → chuỗi GDScript gãy (Godot vẫn chấp nhận, gdlint thì không). Dùng công cụ Edit cho chuỗi có `\`.
- GUT coi mọi lỗi engine trong lúc test là trượt (kể cả lỗi in ra từ `JSON.parse_string`) — tốt, nhưng code phải xử lý lỗi êm.
- Test giao diện đặt `Story.busy = true` để chặn chuyển cảnh (nếu không sẽ phá trình chạy GUT) và `Engine.time_scale = 12` cho nhanh.
