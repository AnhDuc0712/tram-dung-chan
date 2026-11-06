# CLAUDE.md — Trạm Dừng Chân (Godot 4.7.2, GDScript)

Game 2D tình cảm: visual novel + đi lại tự do (quán cà phê Gờ 23) + mini-game. Single-player, chia sẻ cho nhóm nhỏ (<10 người).
Người dùng là người mới làm game: giải thích ngắn gọn bằng **tiếng Việt**, chữ trong game cũng tiếng Việt.
Ý tưởng gốc của tác giả: `kịch bản/`, `mô tả/`, ảnh `thiết kế/` — đọc trước khi viết nội dung mới.
**Nhật ký phiên làm việc:** ghi việc đã làm + lỗi/vướng mắc vào `memory/text1.md` (người dùng yêu cầu).

## Lệnh (PowerShell, từ thư mục gốc)
- Kiểm tra (BẮT BUỘC sau mỗi thay đổi trong `game/`): `powershell -ExecutionPolicy Bypass -File tools\check.ps1`
  6 bước: import · gdlint · test dữ liệu + 5 kết thúc · **GUT** (`game/tests/gut/`) · chạy từng màn · tự chơi trọn Tập 1.
  `-Quick` chỉ chạy 3 bước đầu. Chạy riêng GUT: `tools\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gut -gexit`
  (thêm `-gtest=res://tests/gut/test_x.gd` để chạy 1 file). Test mới: file `test_*.gd` `extends GutTest` trong `game/tests/gut/`, hàm chung ở `helpers.gd`.
  gdlint: cấu hình `game/gdlintrc`, cài bằng `tools\.venv-lint` (gdtoolkit 4.x). GUT (`game/addons/gut`) và tests bị loại khỏi bản export.
- Xem bằng mắt: `tools\screenshot.ps1 -Scene <title|vn|cafe|barista|debug|heartbeat|phone|ending> [-Talk id] [-Clicks n] [-Extra "--evening","--debug-walk"] -Frames n -Name x`
  rồi Read `build\shots\x.png`. `-Clicks` tự bấm tiếp mỗi 25 frame (chọn lựa chọn đầu). Ghi PNG mỗi frame → Frames lớn rất chậm (2400 frame ≈ 10+ phút).
- Chạy cho người dùng chơi: `tools\run.ps1` (`-Scene cafe -Extra "--evening"`, `-Scene vn -Talk ep1_s3`).
- Cắt lại sprite từ bảng thiết kế: `tools\.venv-art\Scripts\python.exe -I tools\art\cut_sprites.py [tên...]`.
- Sinh ảnh biểu cảm từ sprite gốc: `tools\.venv-art\Scripts\python.exe -I tools\art\make_expressions.py [base...]` → `<base>_<biểu cảm>.png`
  + `build\shots\expressions_sheet.png` (xem lại bằng mắt). Toạ độ mắt/miệng/lông mày/gọng kính đo sẵn trong `FACES`.
  Chạy lại cut_sprites thì phải chạy lại script này. Danh sách pose theo nhân vật: `docs/DIALOGUE_FORMAT.md`.
- Đóng gói `tools\build.ps1 [-Web]` (template chỉ tải phần cần: `tools\install_export_templates.ps1` ~110 MB).
- Deploy web: `tools\deploy_web.ps1 [-Prod]` (Vercel). Bình thường để CI làm: PR → preview, merge `main` → production.
- **Git/CI:** không commit thẳng `main` — tạo nhánh `fix/...`, `tap-N/...` rồi `gh pr create`. Quy trình: `docs/CICD.md`.
  Workflow: `.github/workflows/ci.yml` (Linux, `$env:GODOT`), `release.yml` (tag `vX.Y.Z` = `config/version`).
- Soi bằng mắt cả tập: `Godot --path game -- --autoplay --episode=2 --snap=C:/devgame2D/build/snap --snap-every=40` (ảnh JPG mỗi 40 frame).
- Mở sẵn menu để chụp: `-Extra "--hud-open=pause"` (hoặc `settings`, `log`).
- Công cụ ảnh/font: `tools/art/make_stand.py` (dáng đứng Anh Đức, chạy trước make_expressions) · `make_morning.py` (nền sáng) ·
  `make_splash.py` (ảnh chờ tải web) · `subset_fonts.py` (cắt font chỉ giữ Latin + tiếng Việt) · `tools/auto_poses.py` (gợi ý biểu cảm theo câu chữ).
- Điện thoại: thử chế độ cảm ứng bằng `-Extra "--touch"`, màn dọc `-Resolution 422x844` (tools\screenshot.ps1).

## Kiến trúc
- Autoload: `GameState` (vars heart/brain/nlong, flags, step, save, meta kết thúc, settings) · `Ui` (theme, font, màu) ·
  `Audio` (`music/ambient/sfx` theo tên file) · `Story` (`goto(step)`, chuyển cảnh, thẻ chữ, mini-game xong) ·
  `Dialogue` (hộp thoại + sân khấu VN: nền, nhân vật, emote, inset, mưa, ô) · `Hud` (thanh ❤💡, menu, nhật ký, cài đặt).
- Bước truyện `vn:<id> | roam:day|evening | mini:<x> | phone:<id> | ending | title` → `scripts/story_steps.gd` (bảng scene + MINI_NEXT).
- Logic hội thoại tách UI: `scripts/dialogue/dialogue_data.gd` (load/validate) + `dialogue_runner.gd`. Test dùng thẳng 2 file này.
- Dữ liệu: `data/dialogue/*.json` (schema `docs/DIALOGUE_FORMAT.md`), `characters.json`, `endings.json`, `roam/cafe.json`, `phone/*.json`, `minigames/*.json`.
- UI dựng bằng code; các `.tscn` chỉ là node gốc + script.

## Tập 2 (mới)
- `Steps.EPISODES` (tập → bước đầu), `Story.new_game(ep)`, `GameState.start_episode()` (mang `ep1_last` sang), `bar_max()` theo tập.
- Bản đồ: `Steps.ROAM_MAPS` biến thể → `data/roam/<map>.json` (cafe, street); dữ liệu bản đồ khai báo intros/objectives/follower/autoplay.
- Event CG: khóa `cg` trong kịch bản + `data/cgs.json`; ảnh xử lý bằng `tools/art/process_ep2.py`. Tự chơi Tập 2: `-- --autoplay --episode=2`.
- Mở thẳng bản đồ để chụp: `tools\screenshot.ps1 -Scene cafe -Extra "--variant=ep2_night"`.

## Quy tắc
- Mỗi kết thúc / tuyến mới → thêm test route trong `tests/run_tests.gd`. Cập nhật `docs/STORY.md` khi thêm nội dung.
- Mỗi asset thêm vào `game/assets/` → ghi 1 dòng vào `docs/CREDITS.md`. Không dùng asset không rõ license.
- GDScript: không dùng `:=` với giá trị Variant (`dict.get()`, thuộc tính của biến kiểu Node2D chung); không đặt tên tham số/biến là `name`
  (trùng Node.name); không đặt hàm trùng hàm có sẵn (`mini`, `max`…). Tab để thụt lề.
- Coroutine: muốn `await` thì hàm phải trả về signal/Tween (vd `Story.show_card()` trả Tween → `await tw.finished`).
- Asset đã import kiểm tra bằng `ResourceLoader.exists()`; `.json` vào bản export nhờ `include_filter="*.json"`.
- Viewport 1280×720, stretch `canvas_items`, filter linear (tranh vẽ, không phải pixel art), renderer GL Compatibility.
- Control trong autoload (Dialogue/Hud, lớp cao) luôn hiện mà không phải nút → `mouse_filter = IGNORE`, nếu không sẽ nuốt
  cú chạm cả màn bên dưới (test `test_input_blockers.gd`).
- Bản web tải nhanh: ảnh import **Lossy** (test chặn lossless); nhạc nền nằm trong `music.pck` (preset `WebMusic` trong
  `export_presets.cfg`) — thêm bài nhạc mới phải thêm vào `export_files` của preset đó (test `test_web_export.gd`).
- Mini-game mới: dùng `scripts/ui/mini_frame.gd` — `await MiniFrame.intro(...)` trước khi chạy đồng hồ, `MiniFrame.result(...)` khi xong.
- Cài đặt người chơi (`GameState.settings`): `timer_scale` (0 = không giới hạn giờ chọn), `text_size`, `auto`, `shake` — code mới phải tôn trọng.
- Không dùng emoji / ký tự hiếm (♥ ★ ♪) trong chữ — font web không có; vẽ bằng `scripts/ui/shapes.gd` / `icon.gd`.
- Không sửa `tools/godot/`, `game/.godot/` (sinh tự động).
