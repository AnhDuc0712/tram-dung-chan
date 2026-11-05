---
name: viet-hoi-thoai
description: Viết hoặc sửa kịch bản / phân cảnh / lựa chọn / kết thúc / tin nhắn điện thoại cho game "Trạm Dừng Chân" (game/data/dialogue/*.json, data/phone/*.json). Dùng khi người dùng muốn thêm cảnh, tập mới, nhân vật, lựa chọn, chỉ số Rung động/Hiểu bài hoặc kết thúc mới.
---

# Viết kịch bản cho "Trạm Dừng Chân"

1. Đọc `docs/STORY.md` (mạch truyện, cờ, kết thúc), `docs/DIALOGUE_FORMAT.md` (schema) và ý tưởng gốc của tác giả
   trong `kịch bản/`, `mô tả/`. Giữ đúng tính cách: Anh Đức "mỏ hỗn" nhưng tinh tế, gap-moe khi nói với mèo Nlong;
   KyKy ngây thơ, não cá vàng, sợ ma, mù công nghệ; chị M lầy lội đẩy thuyền.
2. Người chơi là Anh Đức. Mỗi lựa chọn phải có ý nghĩa (đổi `heart`/`brain`/`nlong`, bật cờ, mở nhánh) — không có lựa chọn "giả".
   Nên có ít nhất một lựa chọn hài hước. Câu ngắn: hộp thoại chứa ~3 dòng (~170 ký tự).
3. Sân khấu: `show` với biểu cảm có trong `data/characters.json` — chọn mặt khớp cảm xúc từng câu (danh sách pose + gợi ý trong `docs/DIALOGUE_FORMAT.md`, vd đùa tỉnh bơ → `deadpan`, hờn → `hmph`). Cần mặt mới: thêm vào `tools/art/make_expressions.py` (PLAN/RECIPES) rồi khai báo pose. `bg`, `music`, `fx`.
   Node `branch` không được chứa khóa hiển thị.
4. Cảnh mới nối vào mạch truyện bằng `then` (`vn:<id>`, `roam:day|evening`, `mini:*`, `phone:<id>`). Mini-game mới → thêm vào `scripts/story_steps.gd`.
5. Kết thúc mới → `data/endings.json` + nhánh trong node `final` + test route trong `game/tests/run_tests.gd` (hàm `play(id, s, picks)`, `run_mini`).
6. Cập nhật `docs/STORY.md`.
7. Chạy `powershell -ExecutionPolicy Bypass -File tools\check.ps1` — phải ALL CHECKS PASSED.
8. Xem hiển thị: `tools\screenshot.ps1 -Scene vn -Talk <id> -Clicks <n> -Frames <n*25+100> -Name <id>` rồi Read `build\shots\<id>.png`.
