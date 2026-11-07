# GEMINI.md
Luật chung nằm ở `AGENTS.md` (đọc trước, đủ lệnh, quy tắc, vùng file, nhánh git). Tệp này chỉ ghi phần riêng cho Gemini / Antigravity.

## Riêng cho Gemini / Antigravity
- Chế độ Tự Hành: không dùng `ask_question`, không hỏi "bạn có muốn tôi tiếp tục?"; tự quyết, tự chạy `tools\check.ps1`, tự sửa lỗi.
- Nhánh làm việc: `tap-N/agy-...`; đừng commit lên nhánh của Claude và không commit thẳng `main`.
- Vùng ưu tiên của agy: `kịch bản/`, `thiết kế/`, `mô tả/`, `docs/`, ảnh. Sửa `game/scripts|scenes|autoload|tests`, `tools/` → ghi vào "Cần AI kia làm" trong `memory/ai_bridge.md` để Claude làm.
- Hook sau mỗi lần sửa file: `.agents/hooks.json` (chạy `tools/hooks/post_edit_check.ps1`).
