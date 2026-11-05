# Định dạng kịch bản (JSON)

Mỗi cảnh / hội thoại là một file `game/data/dialogue/<id>.json`. Sửa xong chạy `tools\check.ps1` — nó báo lỗi kèm tên node nếu gõ sai.

```json
{
  "title": "Mô tả ngắn (không bắt buộc)",
  "start": "start",
  "nodes": {
    "start": {"card": "15:00 — Quán Gờ 23", "bg": "cafe_day", "music": "cafe_day", "next": "a"},
    "a": {"show": {"duc": "normal@left", "kyky": "shock@right"}, "speaker": "kyky", "text": "Á! Xin lỗi anh!", "next": "b"},
    "b": {
      "speaker": "duc", "think": true, "text": "Nói gì bây giờ?",
      "timer": 5, "timeout": "c",
      "choices": [
        {"text": "Trêu cô bé", "effects": {"heart": 1, "set_flags": ["teased"]}, "next": "c"},
        {"text": "Đi luôn", "then": "roam:day"}
      ]
    },
    "c": {"text": "…", "then": "roam:day"}
  }
}
```

## Khóa của một node
| Khóa | Ý nghĩa |
|---|---|
| `text` | Lời thoại. Không có `speaker` → lời dẫn (chữ nghiêng). Dùng được BBCode: `[b]đậm[/b]`, `[color=#e8608c]…[/color]` |
| `speaker` | id nhân vật trong `data/characters.json` (`duc`, `kyky`, `m`, `nlong`, …) |
| `name` | Tên hiển thị tự đặt (vd `"Chị M (từ quầy)"`) khi nhân vật không đứng trên sân khấu |
| `think` | `true` = suy nghĩ trong đầu (chữ nghiêng, trong ngoặc) |
| `next` | node tiếp theo. Không có `next` và không có lựa chọn → hội thoại kết thúc |
| `then` | khi hội thoại kết thúc thì chuyển sang **bước truyện** (xem dưới) |
| `choices` | danh sách lựa chọn: `text`, `next` hoặc `then`, `effects`, `if` (ẩn nếu không thỏa) |
| `timer` + `timeout` | lựa chọn có đếm giờ (giây); hết giờ nhảy tới node `timeout` |
| `effects` | hiệu ứng khi vào node (hoặc khi chọn) |
| `branch` + `default` | node rẽ nhánh theo điều kiện, không hiển thị gì: `"branch": [{"if": {...}, "next": "x"}], "default": "y"` |
| `bg` | ảnh nền `assets/art/bg/<tên>.jpg` (`cafe_day`, `cafe_sunset`, `street_rain`, `cafe_map`) hoặc `"none"` |
| `music` / `ambient` / `sfx` | nhạc nền / tiếng môi trường lặp (`rain_loop`, `""` để tắt) / hiệu ứng (tên file trong `assets/audio/...`) |
| `show` | `{"kyky": "shock@right"}` — biểu cảm @ vị trí (`farleft`, `left`, `center`, `right`, `farright`, hoặc số x như `"760"`) |
| `hide` | `["m"]` hoặc `"all"` |
| `emote` / `anim` | ép biểu cảm vẽ thêm (`!`, `?`, `sweat`, `blush`, `heart`, `sparkle`, `gloom`, `anger`, `zzz`, `flowers`, `tears`, `dots`) / chuyển động (`hop`, `shake`) |
| `fx` | `shake`, `flash`, `rain_on`, `rain_off`, `umbrella_on`, `umbrella_off`, `dark`, `light`, `zoom`, `unzoom` (một chuỗi hoặc danh sách) |
| `card` | thẻ chữ toàn màn hình (vd mốc thời gian). `card_hold` = số giây |
| `wait` | node không chữ, chờ N giây rồi đi tiếp |
| `event` | gửi tín hiệu cho màn đang chơi (vd `nlong_pet` → tim bay quanh mèo) |

**Node `branch` chỉ được có** `branch`, `default`, `effects` — muốn đổi nền/nhạc thì đặt ở node đích.

## Điều kiện `if`
```json
{"flags": ["a"], "not_flags": ["b"], "min": {"heart": 5, "nlong": 2}, "below": {"brain": 3}}
```
`min` = lớn hơn hoặc bằng, `below` = nhỏ hơn hẳn. Tất cả phải đúng.

## Hiệu ứng `effects`
```json
{"heart": 1, "brain": 2, "add": {"nlong": 1}, "set_flags": ["x"], "clear_flags": ["y"], "ending": "duoi_mot_chiec_o"}
```

## Bước truyện (`then`)
`vn:<id hội thoại>` · `roam:day` / `roam:evening` · `mini:barista` / `mini:debug` / `mini:heartbeat` · `phone:<id>` · `ending` · `title`.
Mini-game xong đi tiếp tới đâu: xem `MINI_NEXT` trong `game/scripts/story_steps.gd`.

## Nhân vật & biểu cảm (`data/characters.json`)
```json
"kyky": {"name": "KyKy", "color": "#d0477a", "face": [0.47, 0.2],
  "poses": {"shock": {"img": "kyky_wave_shock", "faces": "left", "emote": "!", "anim": "shake"}}}
```
- `img`: ảnh `assets/art/chars/<img>.png` (nền trong suốt). `faces`: ảnh đang nhìn về `left`/`right` → game tự lật cho nhân vật nhìn vào giữa.
- `emote`/`anim`: hiệu ứng vẽ thêm mặc định. `inset`: ô phác thảo biểu cảm kiểu manga hiện cạnh đầu.
- `face`: vị trí khuôn mặt trên ảnh (tỉ lệ 0–1) để đặt emote.
- **Ảnh biểu cảm** `<ảnh gốc>_<biểu cảm>.png` (vd `kyky_wave_sad`, `duc_front_angry`) sinh tự động từ sprite gốc bằng
  `tools\.venv-art\Scripts\python.exe -I tools\art\make_expressions.py` (vẽ lại mắt / lông mày / miệng / má hồng / nước mắt).
  Thêm biểu cảm: sửa `PLAN`/`RECIPES` trong script, chạy lại, rồi thêm pose vào đây. Có ảnh vẽ tay đẹp hơn thì chép đè cùng tên.
- **Bảng tư thế hiện có** (dùng trong `show`):
  - `duc`: normal, smirk, tease, blush, awkward, think, glare, curious, soft, wave, happy, laugh, shock, surprised, panic, worried, shy, sad, angry, deadpan
  - `kyky`: normal, sparkle, shock, panic, surprised, confused, worried, sad, angry, pout, smug, happy, laugh, hmph, shy, cry, love
  - `m`: normal, tease, love, laugh, shock, worried, glare, walk, busy, surprised, smirk
  - `nlong`: normal, grumpy, love, doze, sleep, walk, shock
  - `tram`: normal, walk, suspicious, smug, glare, shock, happy, pout · `thao`: normal, walk, happy, shock, worried, smug
  - `ducanh`: normal, tired, walk, happy, laugh, shock, worried · `hai`: normal, shy, happy, shock, worried
- Gợi ý chọn mặt theo hoàn cảnh: nói đùa tỉnh bơ → `deadpan`; bị bắt quả tang / chối → `blush`, `panic`; hờn dỗi kiểu
  "Keo kiệt!" → `hmph`; tức thật → `angry`; ngạc nhiên nhẹ "Ơ…" → `surprised`, giật mình mạnh → `shock`; lo cho người kia → `worried`.

## Bản đồ tự do (`data/roam/cafe.json`)
Toạ độ theo ảnh `cafe_map.jpg` (1280×714). `walk` = đa giác vùng đi được, `obstacles` = [x, y, rộng, cao], `npcs`/`spots` có `dialogue`, `stand` (chỗ đứng để tương tác), `when` (biến thể day/evening), `if`.
Xem trực quan: `tools\screenshot.ps1 -Scene cafe -Extra "--debug-walk" -Clicks 7 -Frames 330 -Name dbg`.

## Điện thoại (`data/phone/<id>.json`)
`threads[]` → `title`, `subtitle`, `members` (`{"kyky": "kyky_hug"}` = ảnh đại diện), `messages[]`:
`{"from": "kyky", "text": "...", "image": "chibi|turtle|nlong|<ảnh nhân vật>", "if": {...}, "if_ending": ["gia_su"]}`
hoặc `{"choices": [{"sticker": "cat_sit", "text": "...", "reply": [ ...tin nhắn... ]}]}`.
