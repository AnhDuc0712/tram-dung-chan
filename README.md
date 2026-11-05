# Trạm Dừng Chân — Ver 1

Game 2D tình cảm: **visual novel + đi lại tự do trong quán cà phê + mini-game**, làm bằng Godot 4.7.
Ver 1 = **Tập 1: Cú va chạm ở quán cà phê** (4 phân cảnh theo `kịch bản/kichban1.md`), chơi khoảng 20–30 phút, **5 kết thúc**.

## Có gì trong Ver 1
- 4 phân cảnh VN với nhân vật cắt từ bảng thiết kế của bạn (Anh Đức, KyKy, chị M, mèo Nlong), biểu cảm vẽ thêm + ô biểu cảm kiểu manga.
- 2 màn **tự do đi lại** trong quán Gờ 23 (chiều nắng / tối mưa): làm việc theo thứ tự tuỳ thích, nựng Nlong (mèo tự đi dạo), đàn guitar, tìm bút thỏ, lấy giáo trình, mượn ô hồng của chị M…
- 3 mini-game: **Pha chế** (kéo thả, vẽ bọt sữa) · **Tìm bug** trong code của KyKy · **Giữ bình tĩnh** khi KyKy ghé sát.
- Lựa chọn **có đếm giờ**, thanh ❤ Rung động & 💡 Hiểu bài, nhật ký hội thoại, tua nhanh (giữ Ctrl), cài đặt âm lượng / tốc độ chữ.
- Cuối tập: **điện thoại nhắn tin** (KyKy + nhóm “Hội Đồ Án IT”), nội dung đổi theo những gì bạn đã làm.
- Tự lưu ở mỗi cảnh, “Tiếp tục” từ màn hình chính; mục **Kỷ niệm** xem các kết thúc đã mở.

## Bắt đầu nhanh (PowerShell, tại `C:\devgame2D`)
| Việc | Lệnh |
|---|---|
| **Chơi thử** | `powershell -ExecutionPolicy Bypass -File tools\run.ps1` |
| Mở Godot editor | `powershell -ExecutionPolicy Bypass -File tools\edit.ps1` |
| Kiểm tra lỗi + lint + test (GUT) + chạy thử mọi màn | `powershell -ExecutionPolicy Bypass -File tools\check.ps1` |
| Chụp màn hình tự động | `... tools\screenshot.ps1 -Scene vn -Talk ep1_s2 -Clicks 5 -Frames 250 -Name s2` |
| Cắt lại nhân vật từ `thiết kế/char` | `tools\.venv-art\Scripts\python.exe -I tools\art\cut_sprites.py` |
| Tạo lại ảnh biểu cảm nhân vật | `tools\.venv-art\Scripts\python.exe -I tools\art\make_expressions.py` |
| Đóng gói Windows/Web | `... tools\install_export_templates.ps1` (~110 MB) rồi `... tools\build.ps1 -Web` |
| Đưa web lên Vercel từ máy | `... tools\deploy_web.ps1` (xem thử) · `-Prod` (chính thức) |

**CI/CD:** mỗi PR trên GitHub được kiểm tra 6 bước và có link Vercel xem thử; merge vào `main` thì bản chính thức tự cập nhật.
Quy trình sửa lỗi / ra tập mới / phát hành / quay lui: `docs/CICD.md`. Kho: https://github.com/AnhDuc0712/tram-dung-chan

**Điều khiển:** chuột / chạm để đọc tiếp, chọn, đi tới chỗ muốn đến · WASD / mũi tên để đi · E / Space để tương tác · Ctrl giữ để tua · L nhật ký · Esc menu.

## Cấu trúc
```
game/
  autoload/      GameState (chỉ số, cờ, lưu) · Ui (phong cách) · Audio · Story (chuyển cảnh)
                 Dialogue (hộp thoại + sân khấu VN) · Hud (thanh ❤💡, menu, nhật ký)
  scenes/        ui/ (màn hình chính, kết thúc) · vn/ · world/ (quán Gờ 23) · minigames/ · phone/
  scripts/       dialogue/ (logic, test được) · vn/ (nhân vật, emote, mưa, ô) · ui/ · story_steps.gd
  data/          dialogue/*.json (KỊCH BẢN) · characters.json · endings.json · roam/cafe.json
                 phone/ep1.json · minigames/*.json
  assets/        art/chars, art/bg, audio/music, audio/sfx, fonts
  tests/         run_tests.gd (chơi thử tự động cả 5 kết thúc)
docs/            STORY (mạch truyện, cờ, kết thúc) · DIALOGUE_FORMAT · CREDITS · RESOURCES
memory/          nhật ký làm việc từng phiên
```
