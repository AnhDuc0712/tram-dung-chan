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

## Phiên 6 — 2026-11-05: **chơi trên điện thoại + Vercel + CI/CD**
**Giao diện điện thoại**
- Nút "Tua »" trong khung thoại (thay giữ Ctrl), gợi ý trong quán đổi "E ·" → "Chạm ·" và chạm vào gợi ý cũng tương tác,
  vùng chạm nhân vật/đồ vật to hơn, chữ nhỏ 13–17 → 15–19, màn "Xoay ngang điện thoại" khi cầm dọc,
  nút "Toàn màn hình" (màn hình chính trên web/điện thoại + Cài đặt); vào toàn màn hình thì Android tự khoá ngang.
- Trang web: chặn kéo/zoom/bôi đen khi chạm, màu nền, thẻ meta cho điện thoại (`html/head_include` trong export_presets.cfg).
- Thử thật bản web bằng Chrome giả lập Pixel 8 (puppeteer-core): vào game, chạm, tua, cầm dọc — chạy tốt.
- Bản web: 68 MB (wasm 39 MB — Vercel nén còn ~9 MB khi gửi; pck 31 MB).

**Đóng gói nhẹ**: `tools/get_templates.py` chỉ tải template cần (web 20 MB / windows ~90 MB) bằng HTTP Range thay vì gói 1.3 GB.

**CI/CD** (chi tiết `docs/CICD.md`)
- Kho công khai: https://github.com/AnhDuc0712/tram-dung-chan (nhánh `main`).
- `.github/workflows/ci.yml`: PR/push → Linux chạy `tools/check.ps1` 6 bước → xuất bản web → Vercel (PR: preview + bot gắn link; main: production).
- `.github/workflows/release.yml`: tag `vX.Y.Z` (trùng `config/version`) → GitHub Release kèm Windows .zip + Web .zip.
- `tools/deploy_web.ps1` deploy từ máy; `tools/common.ps1` chạy được cả Windows lẫn Linux (`$env:GODOT`).
- Phiên bản game: `config/version` trong project.godot (hiện 1.1.0), màn hình chính đọc từ đó.

**Lỗi / vướng**
- `scenes/world/player.gd` bị sửa ngoài phiên làm việc (15:31): thêm tăng tốc + NavigationAgent2D nhưng `move_and_slide()` bị
  thụt vào nhầm nhánh → **Anh Đức không đi được**. Đã sửa giữ nguyên ý tưởng (tăng tốc khi đi bằng phím, hỗ trợ NavigationAgent2D),
  bản trước khi sửa lưu ở `build/player.gd.ban_chinh_sua_15h31.bak`. Thêm test `test_player_move.gd` để lỗi này không lọt lại.
- GitHub không nhận yêu cầu Range kiểu "N byte cuối" (thư viện remotezip hỏng) → tự viết đọc zip từ xa bằng khoảng byte cụ thể.
- WSL Ubuntu trên máy bị hỏng ổ đĩa ảo, Docker không chạy → thử Linux trực tiếp trên GitHub Actions.
- Trong Bash tool, `\` trong heredoc Python bị nuốt → dùng `chr(92)` hoặc công cụ Edit.

## Phiên 7 — 2026-11-06: **Tập 2 — Cơn bão nhỏ ở Gờ 23** + Event CG + gợi ý trong mota.md
Đọc: `kịch bản/kichban2.md`, `memory/mota.md`, 5 ảnh bối cảnh + bảng NPC/biểu cảm mới (`thiết kế/env/`), 5 Event CG.

**Ảnh** (`tools/art/process_ep2.py`)
- Xoá dấu ngôi sao Gemini ở góc mọi ảnh (cả 4 nền Tập 1), cắt phụ đề in sẵn trên 5 CG, cắt 3 nền nhỏ + 2 NPC học sinh +
  10 ô biểu cảm (chị M, Trâm, Đức Anh, Hải) từ bảng thiết kế; nền mới: quán đêm mưa, khu trò chơi, bản đồ phố.

**Engine**
- Event CG (khóa `cg`, lia máy chậm, mở khoá vào Kỷ niệm → Ảnh sự kiện); chọn tập ở màn hình chính; màn kết thúc có “Sang Tập 2”.
- Hiệu ứng cánh bướm: chỉ số Trâm tin tưởng / ghen ngầm / Đức Anh / Thảo → HUD báo “Trâm sẽ nhớ chuyện này”; Menu → Quan hệ.
- Gợi ý mota.md: nhân vật xích lại gần khi Rung động tăng, tiếng lách cách khi chữ chạy, Nlong ở góc màn hình kể
  “tâm tư Anh Đức” (không cộng chỉ số), đa kết cục + sưu tầm CG.
- Bản đồ theo dữ liệu: nhiều map/biến thể, mở màn, mục tiêu, KyKy đi theo trên phố, NPC môi trường (freelancer, cặp đôi cấp 3,
  cô bán hoa, bác bảo vệ). Điện thoại: lựa chọn có hiệu ứng.
- 3 mini-game: giải cứu bàn phím (gãi 3 điểm + kéo súp), ghép lệnh vòng lặp trái tim, nhịp đập trong bóng tối.

**Nội dung**: 34 file kịch bản + 2 điện thoại; bám kịch bản 2 và mở rộng buổi chiều tự do với hội bạn, buổi tối tự do trên phố
(5 nơi hẹn, tối đa 2), 5 kết cục (3 theo kịch bản + “Chiếc Áo Khoác” theo mota + “Gấu Bông Hoàng Thượng” bí mật).

**Kiểm thử**: 19 test tuyến (thêm 5 tuyến Tập 2), GUT 55 test / 1316 phép kiểm (người chơi ngẫu nhiên chơi cả 2 tập),
check.ps1 tự chơi trọn cả Tập 1 lẫn Tập 2 → ALL CHECKS PASSED.

**Lỗi / vướng**
- Đặt tên node `"end"` → trùng từ khoá kết thúc hội thoại, cảnh truyện đứng lại → thêm luật validator cấm tên này.
- Node rẽ nhánh mang `show`/`hide`/`bg` bị bỏ qua (đã biết từ Tập 1) — lặp lại 6 lần khi viết nhanh; validator bắt hết.
- Rung động Tập 2 vượt thanh 18 → thanh theo tập (`bar_max`, Tập 2 = 28).
- Cân bằng: kết “Áo Khoác” chỉ 1/250 lượt → đổi điều kiện (khoác áo thật) + ưu tiên trước kết ghen.
- Bảng thông tin mini-game Nlong che mặt mèo → dời sang phải; Nlong góc màn hình ẩn khi chơi mini-game.
- Lọc trung vị cửa sổ lớn trên ảnh 2752px quá chậm (>10 phút) → đổi sang lọc Gauss.

## Phiên 8 — 2026-11-06: cài secret Vercel cho CI
- Người dùng chạy `tools\setup_ci_secrets.ps1` → 3 secret đã có, chạy lại CI của PR #1: phần kiểm tra xanh, **deploy lỗi**
  `You defined "--token", but its contents are invalid`.
- Nguyên nhân: token lưu trên GitHub dài **1 ký tự** — Ctrl+V trong ô `Read-Host -AsSecureString` của Windows PowerShell 5.1
  ghi ký tự điều khiển ^V thay vì dán. (VERCEL_ORG_ID / VERCEL_PROJECT_ID không bị ảnh hưởng: lấy từ file.)
- Sửa (commit 8879341 trên nhánh tap-2/co-ban): script đọc token từ **clipboard**, kiểm tra `^[A-Za-z0-9_]{16,}$` rồi mới cài,
  sau đó xoá clipboard; CI thêm bước kiểm tra định dạng token, báo lỗi tiếng Việt kèm độ dài (không in token).
- Chờ người dùng: copy token trên vercel.com → chạy lại script → báo để chạy lại CI lấy link xem thử → merge PR #1.
- Người dùng chép token vào `tokenvercel.md` (KHÔNG commit — file untracked) → Claude kiểm tra định dạng (60 ký tự) và cài
  VERCEL_TOKEN theo yêu cầu. CI chạy lại: deploy OK, bot gắn link xem thử vào PR #1. Link preview trả 302 = Vercel bảo vệ
  bản xem thử (phải đăng nhập Vercel mới mở được).

## Phiên 9 — 2026-11-06: kiểm thử lại toàn bộ (bản web + điện thoại) và sửa lỗi
Cách kiểm: check.ps1 6 bước; tự chơi trọn 2 tập có ĐỒ HOẠ thật + chụp mỗi 40 frame (`--snap`) rồi duyệt bằng mắt;
đóng gói web, cho Chrome headless tự chơi trọn Tập 2 trên bản web; giả lập điện thoại ngang có cảm ứng, chạm từng bước.
**Lỗi tìm được + đã sửa**
- NGHIÊM TRỌNG: khung lựa chọn của hộp thoại (lớp 10) luôn "hiện" và nhận chuột → nuốt mọi cú chạm ở giữa màn
  (290–990 × 196–496): không bấm được Tập 1/Tập 2 trong bảng chọn tập, chỗ chạm giữa bản đồ / mini-game. → mouse_filter IGNORE
  + test mới `test_input_blockers.gd` (rà mọi lớp phủ của Dialogue/Hud ở 6 màn).
- Dòng báo thái độ ("Trâm sẽ nhớ…") chồng chữ, khó đọc → mỗi dòng 1 ô nền, tối đa 4 dòng.
- Ô biểu cảm tràn khỏi mép phải khi nhân vật đứng sát mép → tự đổi bên / kéo vào trong.
- Ô biểu cảm Trâm vẽ SAI người (tóc nâu, áo hồng) → chỉnh màu tóc đen + áo tím (ảnh gốc giữ ở build/tram_inset_bak).
- Mini-game ghép lệnh: thanh Hiểu bài che dòng đầu khung code → dời xuống. Mini-game bóng tối: bảng tràn mép dưới → dời lên.
- Lời nghĩ thầm hiện "((" ở 3 câu → sửa dữ liệu + test chặn.
- Ngôi sao "Trâm tin tưởng" ở màn kết thúc to gấp đôi, đè chữ (draw_star nhận bán kính).
- Nhãn "E · Đọc menu" đè ô nhiệm vụ / nút Menu → đặt xuống dưới.
- Trạm xe buýt dùng nền mặt tiền Gờ 23 → câu dẫn nói rõ trạm ngay trước cửa quán.
- Màn hình chính vẫn ghi chỉ "Tập 1" → ghi cả Tập 2. Phiên bản 1.2.0.
**Còn lại (không sửa được ở đây)**: Chrome headless (SwiftShader) in nhiều cảnh báo WebGL "bindBuffer… different target" —
game vẫn chạy trọn tập; cần thử trên điện thoại thật xem có vệt/thiếu hình không.

## Phiên 10 — 2026-11-06: vào game nhanh hơn (bản web)
Đo: bản web phải tải index.wasm (nén br còn 9,5 MB) + **index.pck 42,5 MB không nén được** → mạng 20 Mbps mất ~24 s mới thấy màn hình chính.
Nguyên nhân: 112 ảnh import kiểu **lossless** (JPG 470 KB phình thành 1,8 MB) + 15 MB nhạc nền nằm chung gói.
**Đã làm**
- Ảnh → Lossy WebP chất lượng 0,85 (`[importer_defaults]` trong project.godot cho ảnh thêm sau): ảnh 27 MB → 5,5 MB, mắt không thấy khác.
- Nhạc nền tách gói riêng `music.pck` (preset "WebMusic"); gói chính bỏ `assets/audio/music/*`. `Audio` trên web tự tải ngầm
  ngay khi mở game, bài đang chờ tự phát khi tải xong. Bản Windows / test / editor vẫn có đủ nhạc như cũ.
- Màn hình chờ: ảnh "Trạm Dừng Chân" thay logo Godot (`tools/art/make_splash.py`) + dòng "Đang tải trò chơi… N%".
- Kết quả: index.pck 41,5 MB → **7,5 MB**; mạng 20 Mbps vào game **9 s** (trước 24 s), nhạc có sau ~16 s.
- Test mới `test_web_export.gd`: nhạc mới phải có trong preset WebMusic, ảnh không được import lossless. CI/release/build/deploy xuất thêm music.pck.
- Phiên bản 1.2.1.
**Vướng mắc đã gặp**: HTTPRequest trên web — (1) tự giải nén lần 2 khi máy chủ gửi br/gzip → lỗi 8 → `accept_gzip = false`;
(2) `download_file` không ghi được file trên web → nhận vào bộ nhớ rồi tự ghi user://music.pck; (3) mặc định đọc 64 KB/khung hình
→ 15 MB mất >10 s → `download_chunk_size = 1 MB`.

## Phiên 11 — 2026-11-06 (tối): sửa theo góp ý chơi thử (`memory/fix.md`)
Nhánh `fix/gop-y-choi-thu`. Chi tiết từng mục + ngày giờ ghi ở cuối `memory/fix.md`.
**Đã làm (chính)**
- Mở game nhanh hơn: thẻ chữ mở đầu gộp 1 + bấm để tua; hết lộ HUD giữa chừng (tween màn đen của Story xung đột với thẻ chữ);
  font cắt chỉ giữ Latin + tiếng Việt (1,4 MB → 0,57 MB); ảnh `_x_` (inset) loại khỏi bản xuất (−1,2 MB); lời nhắc "lần đầu tải hơi lâu".
- Hộp thoại: nút lựa chọn dồn xuống sát hộp thoại; giờ chọn dài ×1,5 + tuỳ chọn "Không giới hạn"; cỡ chữ, tự chuyển câu, tắt rung;
  Tua tự dừng khi có ảnh sự kiện; bỏ inset (chân dung hiện 2 lần); chân dung trên bản đồ nhỏ + ẩn ở câu dẫn truyện.
- Anh Đức dáng đứng thường (không vẫy tay) — ảnh mới `duc_stand*` (make_stand.py); KyKy dáng thường ôm sổ.
- HUD: mèo vẽ dưới cửa sổ pop-up; nút Lưu game; "Đã tự lưu"; "+1" bay lên + giải thích chỉ số; nhật ký dùng icon quyển sổ.
- Bản đồ: sao vàng = việc chính, chấm hồng nhỏ = việc phụ; mũi tên + vòng sáng trên nhân vật mình; "E · Nói chuyện với <tên>";
  nhớ vị trí theo từng bản đồ (sau mini-game / địa điểm không bị dịch chuyển); cầm ly nước khi đang mang đồ uống.
- Pha chế: lớp màu từng nguyên liệu + đá + đường, bấm Xong khuấy đều, hình vẽ nằm trên bọt sữa, công thức đánh dấu, dòng hướng dẫn đổi theo bước;
  thêm Ca cao đá, Matcha sữa, Matcha kem phô mai (+ câu phản ứng của KyKy).
- Chat điện thoại: avatar cỡ cố định + viền màu riêng; nút trả lời không bị cắt; tin hiện nhanh ×3; tự cuộn khi có nút "Tin nhắn mới".
- Mini-game Tập 2: màn chuẩn bị + màn tổng kết (`scripts/ui/mini_frame.gd`); nhịp đập: chạm đâu cũng được, vòng to hơn, báo "Thở đều…";
  logic: câu phản hồi riêng từng đáp án sai, tô đỏ/xanh; balo + sổ vẽ lại.
- Nền: quán buổi sáng mới (`cafe_morning.jpg`), công viên không còn dùng ảnh sân trường nắng; "9 giờ tối" ghi rõ; cảnh mất điện tối hẳn.
**Vướng mắc**: heredoc trong Bash làm hỏng ký tự `\n` và chữ Việt khi chạy Python inline → viết script ra file rồi chạy.
Test mới: `test_playtest_fixes.gd`, `test_web_export.gd` (từ phiên 10). check.ps1: ALL CHECKS PASSED (66 test GUT).

## Phiên 12 — 2026-11-07: Cài đặt Harness kiểm tra toàn diện & Chế độ Tự Hành (Autonomous Mode)
Người dùng yêu cầu: thiết lập chế độ tự hành (không hỏi câu hỏi xác nhận, tự động thực thi và chỉ trả về kết quả), đồng thời cài đặt harness cho repo.
**Đã làm**
- Thiết lập quy tắc hoạt động tự hành (Autonomous Mode) trong `GEMINI.md` và `AGENTS.md`: cấm hỏi xác nhận rườm rà, AI chủ động phân tích, tự quyết định kỹ thuật, tự động sửa lỗi và báo cáo kết quả hoàn thiện. Cập nhật `CLAUDE.md`.
- Cài đặt & cấu hình Harness kiểm tra:
  - Cập nhật `tools/hooks/post_edit_check.ps1` hỗ trợ cả Claude Code và Antigravity format.
  - Tạo `.agents/hooks.json` tự động kích hoạt harness sau mỗi lần chỉnh sửa file mã nguồn.
  - Cài đặt Git hook `.git/hooks/pre-commit` tự động chạy `tools/check.ps1 -Quick` trước mỗi lần commit.
  - Đồng bộ cấu hình `.claude/settings.json` từ file khuyến nghị.
  - Tạo script cài đặt trọn gói `tools/install_harness.ps1`.
- Kiểm thử: `tools/install_harness.ps1` chạy thành công, toàn bộ 6 bước kiểm tra của harness đều PASSED (66 test GUT, 19 test dữ liệu, 10 màn chơi, autoplay trọn 2 tập).

## Phiên 13 — 2026-11-07: Tạo Sổ tay Giao tiếp & Bàn giao gián tiếp giữa các AI (`memory/ai_bridge.md`)
Người dùng yêu cầu: đọc kỹ thư mục `memory/` và tạo thêm một file `.md` trong đó để làm kênh giao tiếp gián tiếp giữa Antigravity và Claude.
**Đã làm**
- Đọc và phân tích toàn bộ `memory/text1.md`, `memory/fix.md`, `memory/mota.md`.
- Tạo `memory/ai_bridge.md` đóng vai trò là "Sổ tay chuyển giao & phối hợp giữa các AI (Antigravity ↔ Claude)":
  - Quy định quy trình kiểm tra đầu phiên và cập nhật cuối phiên cho mọi AI.
  - Tóm tắt snapshot hiện trạng kỹ thuật (v1.3.0, tình trạng harness, kịch bản Tập 1, Tập 2, định hướng Tập 3).
  - Bản ghi nhật ký trao đổi (Message Board) với thông điệp đầu tiên từ Antigravity gửi Claude về hạ tầng harness, các bài học về sandbox/cache, và hướng dẫn cho phiên tiếp theo.
- Cập nhật liên kết hướng dẫn tại `CLAUDE.md`, `GEMINI.md`, `AGENTS.md` để cả 2 AI đều tự động đọc và cập nhật file này.

## Phiên 14 — 2026-11-07: Thảo luận với Claude về Định hướng Phát triển & Cải thiện Tiếp theo
Người dùng yêu cầu: thảo luận với Claude (đang chạy song song) về các hướng phát triển và hoàn thiện tiếp theo cho dự án.
**Đã làm**
- Đăng tải thông điệp thảo luận chi tiết lên `memory/ai_bridge.md`:
  - Định hướng Cốt truyện & Nội dung Tập 3 ("Đồ án chung & Tiếng lòng Gờ 23"): Tận dụng bối cảnh trường học `campus`, ca làm thêm chung ở quán, tình huống cạnh tranh từ nhân vật Hải, 3 ý tưởng mini-game mới (UI/Logic sync, Barista giờ cao điểm, chụp ảnh/tìm Nlong).
  - Nâng cấp "Game Feel" (Sprite Tweening nảy/rung/xích lại gần, SFX typewriter gõ máy, ambient loop quán & mưa rơi).
  - Mở rộng tính năng giữ chân (Retention): Sổ tay pha chế và Bộ sưu tập tâm tư Nlong trong menu Kỷ niệm.
- Cả hai AI sẵn sàng hiệp đồng tác chiến trên cùng mục tiêu.

## Phiên 15 — 2026-11-07: Tổng Kiểm Thử Độc Lập (QA/QC Tester Audit & Xử lý Tối ưu)
Người dùng yêu cầu: đóng vai trò Senior QA/QC Tester kiểm tra toàn diện, khách quan lại Tập 1 & Tập 2 về logic cốt truyện, UX/UI, nhân vật/bối cảnh (thừa/thiếu ảnh), hiệu năng/hạ tầng vận hành và xử lý trực tiếp các vấn đề phát hiện.
**Đánh giá & Xử lý**
- **Trải nghiệm Nhân vật & UX (Sprite Juice):**
  - Phát hiện: Nhân vật nói chuyện còn hơi "đơ", thiếu nhịp nảy khi bắt đầu câu thoại như tác giả đã mô tả trong `mô tả/note1.md`.
  - Đã xử lý: Thêm hàm `speak_pulse()` trong `scripts/vn/actor.gd` (nảy nhẹ 6px trong 0.12s) và gọi tự động trong `dialogue_manager.gd` mỗi khi nhân vật bắt đầu thoại.
- **Thư viện Kỷ niệm (UX Clarity):**
  - Phát hiện: Mục "Ảnh sự kiện" trong menu Kỷ niệm hiển thị `(0/6)` sau khi người chơi mới kết thúc Tập 1, dễ gây hiểu lầm là game lỗi không lưu ảnh (thực tế 6 CG đều thuộc Tập 2).
  - Đã xử lý: Đổi tiêu đề rõ ràng thành `"Ảnh sự kiện (Tập 2)"` trong `title_screen.gd`.
- **Hiệu năng & Tối ưu WebGL (Infrastructure & Performance):**
  - Phát hiện: `scripts/vn/rain.gd` vẽ 220 đường kẻ và splash không giới hạn mỗi frame gây cảnh báo `bufferSubData` trên WebGL SwiftShader.
  - Đã xử lý: Tối ưu số giọt mưa trên Web (`drops = mini(drops, 120)`), giới hạn tối đa 16 splash đồng thời. Giảm tải GPU frame-by-frame mà mắt thường vẫn thấy mưa dày đặc.
- **Kiểm thử xác nhận:** Chạy toàn bộ 6 bước harness kiểm tra (`tools/check.ps1`) -> `ALL CHECKS PASSED` 100%.

## Phiên 16 — 2026-11-07: Biên soạn Hoàn chỉnh Kịch bản Tập 3 & Thiết kế Yêu cầu Hình ảnh Chi tiết
Người dùng yêu cầu:
- Đọc note trong `kịch bản/kichban3.md`: Gemini thiết kế kịch bản trước, Claude sẽ đọc và hoàn thiện sau; sau khi làm xong note các yêu cầu hình ảnh vào `thiết kế/yeucauhinhanh.md` chi tiết rõ ràng cho từng mục.
- Phân tích kỹ các kịch bản trước đó (`kichban1.md`, `kichban2.md`), đảm bảo tiêu chí game nhẹ nhàng, tự do (Roam/Choice freedom), kịch bản chặt chẽ, đặc sắc thú vị và phát triển tốt chiều sâu tâm lý nhân vật.

**Đã làm**
1. **Thiết kế & Biên soạn Kịch bản Hoàn chỉnh Tập 3 (`kịch bản/kichban3.md`):**
   - **Tựa đề:** *TẬP 3: Đồ Án Chung, Bước Nhảy Trái Tim & Lời Hứa Dưới Nắng Sớm*.
   - **Khâu liên kết chặt chẽ với Tập 2:** Kế thừa trọn vẹn 5 kết thúc của Tập 2 (nồi lẩu ra mắt, gấu Nlong avatar, áo khoác cho mượn kèm hộp bánh cháy, cơn ghen với Hải).
   - **5 Phân cảnh lớn giàu cảm xúc & kịch tính lãng mạn:**
     - *Phân cảnh 1: Nắng Sân Trường & Dự Án Bất Đắc Dĩ (`campus_day`)*: KyKy trả áo khoác kèm hộp bánh hạnh nhân nướng cháy viền; Hải xuất hiện mời KyKy dự triển lãm và học bổng du học Pháp; nhóm IT của Anh Đức thiếu chuyên gia UI/UX; Anh Đức khẳng định: "Giao diện 'Trạm Dừng Chân' sinh ra là vì em".
     - *Phân cảnh 2: Ca Làm Thêm Giờ Cao Điểm Tại Gờ 23 (`cafe_day_rush`)*: KyKy làm nhân viên thử việc; Anh Đức vòng tay thắt nơ tạp dề sau lưng cô (Heartbeat Trigger); Mini-game 1: Barista Rush Hour Sync.
     - *Phân cảnh 3: Phòng Tự Học, Deadline Áp Sát & Lỗi Logic Cuối Cùng (`study_sunset`)*: Xung đột thư viện `Null Pointer Heartbeat`; Mini-game 2: Nối dây đồng bộ UI & Logic code; KyKy ngủ gục trên bàn đồ án, Anh Đức cởi áo đắp cho cô và khẽ vuốt tóc trong nắng hoàng hôn.
     - *Phân cảnh 4: Đêm Triển Lãm Rực Rỡ & Pha Khẳng Định Chủ Quyền (`exhibition_night`)*: Đồ án đạt giải xuất sắc; Hải tặng hoa linh lan mời ăn tối cùng đoàn giáo sư Pháp; Anh Đức công khai kéo KyKy sát vào mình, công bố kế hoạch visa đôi song hành.
     - *Phân cảnh 5: Bình Minh Trước Hiên Quán & Lời Tỏ Tình Chính Thức (`cafe_sunrise`)*: Hai người ngồi trên bậc thềm gỗ Gờ 23 lúc 6:00 sáng, mười ngón tay đan chặt trên lưng mèo Nlong; Anh Đức tỏ tình: "Lỗi logic duy nhất trong cuộc đời tôi là không thể nào ngừng thích em được."
   - **Hệ thống 5 Kết cục phân nhánh:** True Ending ("Lỗi Logic Duy Nhất Là Em"), Sweet Scholarship Ending ("Hẹn Ước Dưới Bầu Trời Paris"), Cozy Barista Ending ("Trạm Dừng Chân Của Riêng Hai Đứa"), Dominant Ending ("Bản Hợp Đồng Trọn Đời"), Comedy Ending ("Hoàng Thượng Ban Hôn Lúc Bình Minh").

2. **Soạn thảo Tài liệu Yêu cầu Thiết kế Hình ảnh Toàn diện (`thiết kế/yeucauhinhanh.md`):**
   - Quy chuẩn mỹ thuật: 2D Anime/Manga phong cách Shinkai/KyoAni, bảng màu ấm áp, thông số 1920x1080 (16:9), format Lossy WebP/PNG trong suốt.
   - 5 Bối cảnh môi trường kèm Prompt sinh ảnh AI chi tiết (`campus_day`, `cafe_day_rush`, `study_sunset`, `exhibition_night`, `cafe_sunrise`).
   - Sprite & Biểu cảm mới: Anh Đức đeo tạp dề & sơ mi đen xắn tay, KyKy đeo tạp dề & váy kem triển lãm, Hải cầm hoa linh lan, Trâm đẩy thuyền, Đức Anh quỳ vái, mèo Nlong sưởi nắng/dính bọt sữa.
   - 6 Tác phẩm Event CG đỉnh cao (16:9): CG buộc tạp dề sau lưng, CG ngủ gục bên bàn đồ án chiều tà, CG khẳng định chủ quyền đêm triển lãm, CG tỏ tình bình minh (True Ending), CG hộp bánh cháy, CG bọt sữa hoàng thượng ban hôn.
   - Chi tiết danh mục đạo cụ (Props), icon minigame và bảng phân bổ tài nguyên theo từng phân cảnh.

3. **Đồng bộ Sổ tay AI Bridge & Harness:**
   - Cập nhật thông điệp chi tiết cho Claude tại `memory/ai_bridge.md`.
   - Chạy kiểm tra chất lượng `tools/check.ps1 -Quick` đảm bảo toàn bộ hệ thống code hiện hữu luôn đạt `ALL CHECKS PASSED`.







## Phiên Claude (2026-11-07) — Tập 3: hợp nhất kịch bản + nền trạng thái
- Viết `kịch bản/kichban3_v2.md` (bản dùng để code). Quyết định tác giả: giữ tên "Đức Anh", chấp nhận kết buồn-ngọt + Hải có lý riêng, **Tập 3 không phải tập cuối: mọi kết cục để kết mở, úp mở Tập 4**.
- `game/autoload/game_state.gd`: thêm `BAR_MAX_EP3`, `ep2_last`, `ep3_last` (lưu trong meta), `start_episode(3)` (mang cờ `ep2_*`, `claw_win`, `gave_jacket`, thêm chỉ số `respect`, `hai`).
- Thêm `game/tests/gut/test_ep3_state.gd` (6 test). check.ps1: ALL CHECKS PASSED (72 test GUT).
- CHƯA đăng ký `Steps.EPISODES[3]` (tránh hiện Tập 3 ở menu / làm fuzz test lỗi khi chưa có nội dung). Làm tiếp theo mục 6 của v2: dữ liệu `ep3_*.json`, roam `campus`/`expo`, mini-game `rush`/`sync`, `endings.json`, test route.


## Phiên Claude (2026-11-07) — Tập 3 alpha đầu tiên
- Nội dung: `ep3_s1/s2/s2b/s3/s3b/s4/s5.json`, 7 hội thoại roam sân trường (`roam_ep3c_*`), 6 roam phố triển lãm (`roam_ep3e_*`), `data/roam/campus.json`, biến thể `ep3_expo` trong `street.json`, `phone/ep3_end.json`, 5 kết cục (`endings.json`), 4 CG (`cgs.json`).
- Mini-game mới: `scenes/minigames/rush.gd` (3 phiếu order, Đức chọn món + KyKy rót vùng xanh) và `sync.gd` (nối 5 cặp UI–hàm, 1 cặp thừa). Hiệu ứng ở `Steps.minigame_effects("rush"|"sync")`.
- Ảnh: `tools/art/process_ep3.py` → `cg_burnt/asleep/expo/sunrise.jpg`, `map_campus.jpg`. CREDITS đã ghi.
- Đăng ký `Steps.EPISODES[3]`, `ROAM_MAPS/VARIANTS`, `MINI_NEXT`, `PHONE_NEXT`; ending.gd/hud.gd hiện chỉ số `respect`; title_screen đổi nhãn CG thành "Ảnh sự kiện" (chung cho mọi tập); check.ps1 tự chơi cả Tập 3.
- Test: 5 route Tập 3 trong `run_tests.gd`, fuzz 250 lượt Tập 3 + `test_ep3_maps_run` + `test_ep3_state` (GUT). Kết quả: **ALL CHECKS PASSED** (24 test dữ liệu, 74 GUT, autoplay 3 tập).
- Phân bố kết cục Tập 3 (250 người chơi ngẫu nhiên): quán 34% · Paris 25% · hài 22% · logic 12% · học cách tin 8%.
- Sửa kịch bản v2 khi code: lựa chọn C ở cảnh 4 là `kyky_both` (nộp hồ sơ + tiếp tục dự án) → kết `ep3_loi_logic`; lựa chọn D chỉ hiện khi `jealous` ≥ 2.
- Còn thiếu / việc sau: nền `exhibition_night`, trang phục mới (tạp dề, váy kem, sơ mi đen), CG riêng cho từng kết cục và CG buộc tạp dề; nhạc mới (`morning_acoustic`... hiện dùng nhạc có sẵn); polygon đi được ở `campus.json` còn lấn nhẹ ra lòng đường (chưa chỉnh); chưa tăng `config/version` và chưa commit/PR.

## Phiên 19 — 2026-11-07: Tinh chỉnh Bản đồ Khuôn viên Trường (Campus Roam) & Nâng cấp Phiên bản 1.4.0
**Đã làm**
- **Tinh chỉnh Polygon đi lại `data/roam/campus.json`:**
  - Soi kỹ qua ảnh chụp debug `--debug-walk` (`build/shots/campus_walk_clear.png` và `campus_walk_refined.png`).
  - Cắt bỏ phần polygon lấn sang khu nhà dân/xe máy ở mép phải (`X = 1010`), gọt gọn lại bám sát đúng vạch kẻ đường cho người đi bộ (zebra crossing) và mép vỉa hè phía trạm xe buýt.
  - Loại bỏ đoạn đường cắt chéo qua giữa lòng đường xe chạy, giúp đường đi của nhân vật tự nhiên, logic và đúng luật giao thông hơn khi di chuyển giữa cổng trường, bãi xe và trạm xe buýt.
- **Nâng cấp phiên bản game (`game/project.godot`):**
  - Cập nhật `config/version = "1.4.0"`.
  - Cập nhật mô tả: `config/description = "Tập 1: Cú va chạm · Tập 2: Cơn bão nhỏ · Tập 3: Đồ án chung & lời hứa dưới nắng sớm."`.
- **Kiểm thử toàn diện 6 bước (`tools/check.ps1`):**
  - 1/6 Import: OK.
  - 2/6 gdlint: OK (44 files).
  - 3/6 Test dữ liệu & Kết thúc: 24 passed, 0 failed.
  - 4/6 GUT: 13 script, 74 test, 1850 asserts passed 100%.
  - 5/6 Chạy thử 10 màn: OK.
  - 6/6 Headless Autoplay: Chơi trọn vẹn cả 3 Tập (Tập 1 -> `hoang_thuong`, Tập 2 -> `ep2_gau`, Tập 3 -> `ep3_paris`).
  - **Kết quả:** `ALL CHECKS PASSED`.

## Phiên 20 — 2026-11-08: Rà soát Biểu cảm & Đăng ký Chỉ đạo Nâng cấp Toàn diện (Tập 3 Cao trào)
**Đã làm**
- **Audit Kiểm thử Biểu cảm & Dàn nhân vật:**
  - Viết công cụ `tools/audit_characters.py` thống kê toàn bộ tần suất thoại (duc: 227, kyky: 204, m: 38, tram: 34, ducanh: 32, hai: 19, thao: 15) và tần suất 718 lượt đổi pose.
  - Đánh giá chi tiết 2 vấn đề tác giả quan tâm: số lượng nhân vật (đạt chuẩn 8 nhân vật cho dòng Slice-of-life Romance) và các điểm nghẽn biểu cảm (khuôn mặt phong phú với 62 ảnh màu nhưng hình thái cơ thể và trang phục bị đóng khung).
- **Hệ thống hóa Chỉ đạo Nâng cấp Toàn diện vào `memory/ai_bridge.md` cho Claude:**
  - *Thanh Thảo:* Tăng đất diễn qua các mẩu trò chuyện ngẫu nhiên / roam dialogue tâm sự phụ nữ với Kỳ, giải mã tính cách con trai IT.
  - *Tuyến gia đình (Mẹ KyKy):* Thêm nhân vật Mẹ của KyKy từ Tập 3 (phụ nữ trung niên đẫy đà, hiện đại, uy quyền, cực kỳ thương con gái nhưng làm nam chính Anh Đức "khá rén"), đẩy cao trào tập 3 với xung đột du học / gia đình bên cạnh Hải.
  - *Thầy Trưởng khoa & Giáo sư Pháp:* Tìm kiếm/cắt ghép mã nguồn mở hình mẫu đơn giản.
  - *Điểm nghẽn Body Poses & Outfits:* Kế hoạch bổ sung tư thế buông tay / chống hông cho KyKy, gãi gáy cho Đức; bổ sung trang phục tạp dề barista và dạ hội đêm triển lãm.
- **Duy trì Quality Gate:** Hệ thống test luôn sẵn sàng để Claude tiếp tục nâng cấp code và tài nguyên.


