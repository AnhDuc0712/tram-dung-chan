# Tài nguyên mã nguồn mở & asset miễn phí cho game 2D nhập vai tình cảm

> ⚠️ Luôn đọc giấy phép (license) trên **từng** asset trước khi dùng và ghi lại vào `docs/CREDITS.md`.

## 1. Engine & phần mềm (đều miễn phí)
| Công cụ | Dùng để | License | Link | Đã cài? |
|---|---|---|---|---|
| **Godot 4.7.2** | engine làm game (project này) | MIT | https://godotengine.org | ✅ `tools/godot/` |
| **rembg** (Python) | tách nền ảnh nhân vật -> PNG trong suốt | MIT | https://github.com/danielgatis/rembg | ✅ `tools/.venv-art/` |
| Pixelorama | vẽ pixel art, animation đi bộ | MIT | https://pixelorama.org | tự cài |
| LibreSprite | bản mã nguồn mở của Aseprite | GPLv2 | https://libresprite.github.io | tự cài |
| Krita | vẽ chân dung (portrait) kiểu anime/webtoon | GPL | https://krita.org | tự cài |
| Tiled | ghép bản đồ từ tileset | GPL | https://www.mapeditor.org | tùy chọn* |
| LDtk | ghép bản đồ (giao diện dễ hơn Tiled) | MIT | https://ldtk.io | tùy chọn* |
| Audacity | cắt / chỉnh âm thanh | GPL | https://www.audacityteam.org | tự cài |
| jsfxr / sfxr | tạo hiệu ứng âm thanh 8-bit | MIT | https://sfxr.me | chạy trên web |
| LMMS / BeepBox | sáng tác nhạc nền | GPL / MIT | https://lmms.io , https://www.beepbox.co | tùy chọn |

\* **Gợi ý cho người mới:** Godot đã có sẵn trình vẽ bản đồ (node `TileMapLayer`) — dùng nó là
đơn giản nhất, không cần Tiled/LDtk. Nếu vẫn muốn dùng Tiled thì cài plugin **YATI**
(Tiled importer cho Godot 4), dùng LDtk thì cài plugin **LDtk Importer** từ Godot AssetLib.

### Plugin Godot có thể cân nhắc thêm (chưa cài)
| Plugin | Dùng để | License |
|---|---|---|
| Dialogic 2 | soạn hội thoại bằng giao diện kéo-thả | MIT |
| Dialogue Manager (Nathan Hoad) | viết hội thoại dạng script text | MIT |

Project này đang dùng **hệ thống hội thoại JSON tự viết** (`docs/DIALOGUE_FORMAT.md`) vì:
nhẹ, kiểm tra tự động được (`tools/check.ps1`), và Claude sửa trực tiếp được.

## 2. Asset hình ảnh
| Trang | Có gì | License thường gặp | Lưu ý |
|---|---|---|---|
| **Kenney.nl** | tileset thị trấn (Tiny Town 16px), dungeon, UI Pack, RPG Audio | **CC0** — dùng thoải mái, không cần ghi tên | vào trang -> Download -> chọn "Continue without donating" |
| **OpenGameArt.org** | tileset, nhân vật, nhạc, SFX | CC0 / CC-BY / CC-BY-SA / GPL (tùy file) | lọc theo License khi tìm kiếm |
| **itch.io** (game-assets) | rất nhiều pack đẹp: tìm tag `cozy`, `top-down`, `visual novel`, `romance`, lọc **Free** | mỗi pack một kiểu — đọc mục license trên trang | pack nổi tiếng: *Ninja Adventure* (CC0, đủ nhân vật + map + nhạc), *Sprout Lands*, *Pixel Art Top Down Basic (Cainos)*, nền visual novel của *Noraneko Games* |
| **CraftPix.net** (mục Freebies) | tileset, nhân vật, UI, nền | license riêng của CraftPix: dùng được trong game, không được bán lại asset | cần tạo tài khoản |
| **Google Fonts** | font hỗ trợ tiếng Việt: *Be Vietnam Pro*, *Nunito*, *Quicksand* | OFL | bỏ `.ttf` vào `game/assets/fonts/` |

**Kích thước khuyên dùng:** tileset 16×16 px (khớp Kenney Tiny Town / Ninja Adventure), viewport game 640×360.

## 3. Âm thanh
| Trang | License | Lưu ý |
|---|---|---|
| **freesound.org** | CC0 / CC-BY / CC-BY-NC (tùy âm thanh) | cần tài khoản để tải; ưu tiên lọc **CC0**; CC-BY phải ghi tên |
| Kenney (RPG Audio, Interface Sounds, Music Jingles) | CC0 | |
| OpenGameArt (mục Music) | tùy file | nhiều nhạc nền lofi/piano nhẹ nhàng |

Định dạng: nhạc nền dùng **.ogg** (lặp mượt), hiệu ứng ngắn dùng .ogg hoặc .wav.
Ver 1 đã có sẵn 9 bản nhạc + 26 hiệu ứng (CC0, xem `docs/CREDITS.md`). Muốn thay: giữ nguyên tên file trong
`game/assets/audio/music/` (title, cafe_day, roam_day, barista, study, evening, rain_night, phone, ending) hoặc
dùng tên mới rồi ghi vào kịch bản (`"music": "ten_file"`).

## 4. Quy trình làm nhân vật
**a) Chân dung hội thoại (portrait, nhiều biểu cảm)**
1. Vẽ bằng Krita, hoặc dùng AI tạo ảnh (Stable Diffusion chạy local qua ComfyUI/Fooocus, Leonardo.ai, Midjourney)
   với cùng một nhân vật, chỉ đổi biểu cảm: normal / smile / blush / sad / surprised.
   - Máy bạn có GTX 1650 (4GB VRAM): chạy được Stable Diffusion 1.5 (chậm), SDXL thì khó.
   - Nếu dùng **ảnh thật của người quen** làm mẫu: hỏi ý họ trước, nhất là với game tình cảm.
   - Đọc điều khoản của dịch vụ AI về quyền dùng ảnh tạo ra.
2. Tách nền:
   `tools\.venv-art\Scripts\python.exe tools\art\remove_bg.py raw\kyky --out game\assets\art\chars --height 600`
   (bảng thiết kế nhiều tư thế thì dùng `tools\art\cut_sprites.py`, sửa bảng CROPS trong file).
3. Đặt tên vd `kyky_cry.png` rồi sửa `game/data/characters.json`: `"cry": {"img": "kyky_cry"}` — kịch bản dùng `"show": {"kyky": "cry"}` là hiện.

**b) Nhân vật đi trên map (pixel art)**
1. Lấy sprite sẵn (Ninja Adventure, Kenney) hoặc tự vẽ bằng Pixelorama/LibreSprite (có thể đặt ảnh gốc mờ bên dưới để đồ lại).
2. Trong Godot: tạo `SpriteFrames` có animation `idle`, `walk_down`, `walk_up`, `walk_side`
   -> gán vào thuộc tính `sprite_frames` của Player. NPC thì gán `sprite`.

## 5. Phát hành cho nhóm nhỏ (< 10 người) — làm SAU
- Đóng gói: `tools\install_export_templates.ps1` (1 lần) rồi `tools\build.ps1` -> `build\PhoHoa-windows.zip`.
- Chia sẻ: gửi file zip qua Google Drive, hoặc đăng **itch.io** ở chế độ *Restricted* / có mật khẩu (bản Web: `tools\build.ps1 -Web`).
