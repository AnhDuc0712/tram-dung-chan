# Ghi công tài nguyên (bắt buộc cập nhật khi thêm asset)

| Tài nguyên | Tác giả | Nguồn | Giấy phép | Dùng ở |
|---|---|---|---|---|
| Thiết kế nhân vật, bối cảnh (ảnh trong `thiết kế/`) | Tác giả game (tạo bằng AI theo mô tả riêng) | — | Thuộc tác giả game | `assets/art/chars/*`, `assets/art/bg/*` (đã cắt nền / thu nhỏ bằng `tools/art/cut_sprites.py`; ảnh biểu cảm `*_<biểu cảm>.png` chỉnh từ chính các sprite này bằng `tools/art/make_expressions.py`) |
| Event CG, bối cảnh & NPC Tập 2 (`thiết kế/Event CG  Cutscene/`, `thiết kế/env/`) | Tác giả game (tạo bằng AI theo mô tả riêng) | — | Thuộc tác giả game | `assets/art/cg/*`, `assets/art/bg/{cafe_night,arcade,map_street,campus,library,hotpot}.jpg`, `chars/npc_*`, `chars/*_x_*` — xoá dấu Gemini, cắt phụ đề, tách nền bằng `tools/art/process_ep2.py` |
| First Light Particles | Yoiyami | https://opengameart.org/node/182244 | CC0 | `music/title.ogg` |
| Starfield Romance | Yoiyami | https://opengameart.org/node/182246 | CC0 | `music/ending.ogg` |
| Wooden Inn | Indieteur | https://opengameart.org/content/wooden-inn | CC0 | `music/cafe_day.ogg` |
| Etirwer (Looped) | Kistol | https://opengameart.org/content/etirwer | CC0 | `music/roam_day.ogg` |
| Chill Lofi Inspired | omfgdude | https://opengameart.org/content/chill-lofi-inspired | CC0 | `music/study.ogg` |
| Chill (Loopable) | Pro Sensory (Alex McCulloch) | https://opengameart.org/content/chill-loopable | CC0 (tác giả xin ghi tên) | `music/evening.ogg` |
| chill guitar | Pro Sensory (Alex McCulloch) | https://opengameart.org/content/chill-guitar | CC0 (tác giả xin ghi tên) | `music/barista.ogg` |
| Softpiano20 | Tozan | https://opengameart.org/content/softpiano20 | CC0 | `music/rain_night.ogg` |
| JRPG Piano | Joth | https://opengameart.org/content/jrpg-piano | CC0 | `music/phone.ogg` |
| Interface Sounds | Kenney (kenney.nl) | https://opengameart.org/content/interface-sounds | CC0 | `sfx/click, hover, good, bad, drop, cup, pop, whoosh, msg, question, scribble, toggle, glitch, sparkle` |
| Cat Purr & Meow | Kerzoven | https://opengameart.org/content/cat-purr-meow | CC0 | `sfx/purr, mew_soft, mew_food, mew_purr` |
| Meow | IgnasD | https://opengameart.org/content/meow | CC0 | `sfx/meow` |
| Kitten Mew | antumdeluge | https://opengameart.org/content/kitten-mew | CC0 | `sfx/kitten` |
| Doorbell | frosty ham | https://opengameart.org/content/doorbell | CC0 | `sfx/doorbell` |
| Pleasing Bell Sound Effect | Spring Spring | https://opengameart.org/content/pleasing-bell-sound-effect | CC0 | `sfx/bell` |
| Heartbeat sounds | bart | https://opengameart.org/content/heartbeat-sounds | CC0 | `sfx/heart_slow, heart_fast` |
| Rain (loopable) | Ylmir | https://opengameart.org/content/rain-loopable | CC0 | `sfx/rain_loop` |
| Rain on Window Loop | alxl | https://opengameart.org/content/rain-on-window-loop | CC0 | `sfx/rain_window` |
| Baloo 2 | Ek Type | https://fonts.google.com/specimen/Baloo+2 | SIL OFL 1.1 | `fonts/Baloo2.ttf` (tiêu đề, tên) |
| Nunito | Vernon Adams, Cyreal | https://fonts.google.com/specimen/Nunito | SIL OFL 1.1 | `fonts/Nunito*.ttf` (chữ thoại) |
| JetBrains Mono | JetBrains | https://fonts.google.com/specimen/JetBrains+Mono | SIL OFL 1.1 | `fonts/JetBrainsMono.ttf` (mini-game code) |
| Godot Engine 4.7 | Godot contributors | https://godotengine.org | MIT | engine |
| GUT — Godot Unit Test 9.7.1 | Butch Wesley (bitwes) | https://github.com/bitwes/Gut | MIT | `game/addons/gut` — chỉ để kiểm thử, không vào bản export |
| gdtoolkit 4.5 (gdlint) | Paweł Lampe (Scony) | https://github.com/Scony/godot-gdscript-toolkit | MIT | `tools/.venv-lint` — soi lỗi GDScript, không vào game |

File gốc tải về nằm trong `raw/dl/` (không đưa vào git). Đã chuyển sang `.ogg` bằng ffmpeg.
