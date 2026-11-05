# Trạm Dừng Chân — Tập 1

Nguồn ý tưởng gốc của tác giả: `kịch bản/kichban1.md`, `mô tả/mối quan hệ nhân vật.md`, ảnh trong `thiết kế/`.
File này tóm tắt **những gì đã có trong game Ver 1** để người viết thêm nội dung nắm được cờ (flag), chỉ số và kết thúc.

## Người chơi & chỉ số
- Người chơi vào vai **Anh Đức** (21 tuổi, “đại thần” IT kiêm barista quán **Gờ 23**).
- `heart` — ❤ **Rung động** của KyKy (thanh tối đa hiển thị 18).
- `brain` — 💡 **Hiểu bài** của KyKy (thanh tối đa 6).
- `nlong` — độ thân với mèo **Nlong** (ẩn, hiện ở màn kết thúc).

## Mạch truyện Tập 1 (bước truyện → file)
| Bước | Nội dung | File |
|---|---|---|
| `vn:ep1_s1` | Phân cảnh 1 — cú va chạm, sổ bay (lựa chọn **có đếm giờ**), tờ note con rùa | `data/dialogue/ep1_s1.json` |
| `roam:day` | **Tự do đi lại** trong quán (chiều): chị M, KyKy, Nlong, đàn, kệ sách, menu, cửa sổ, phòng nhân viên, bút thỏ | `data/roam/cafe.json`, `data/dialogue/roam_*.json` |
| `mini:barista` | Mini-game pha chế (kéo thả nguyên liệu + vẽ bọt sữa) | `scenes/minigames/barista.gd`, `data/minigames/barista.json` |
| `vn:ep1_s2` | Phân cảnh 2 — ly nước đặc biệt, “học phí” | `ep1_s2.json` |
| `vn:ep1_s3` | Phân cảnh 3 — học kèm, đếm cánh hoa, búng kính / vẽ chibi / giáo trình | `ep1_s3.json` |
| `mini:debug` | Mini-game “Tìm bug” trong bài của KyKy (3 vòng) | `data/minigames/debug_ep1.json` |
| `vn:ep1_s3b` | Mèo đè bàn phím → chạm tay | `ep1_s3b.json` |
| `mini:heartbeat` | Mini-game “Giữ bình tĩnh” khi KyKy ghé sát | `scenes/minigames/heartbeat.gd` |
| `vn:ep1_s3c` | Khoảnh khắc rung động, trời đổ mưa | `ep1_s3c.json` |
| `roam:evening` | **Tự do đi lại** (tối, mưa): lấy ô / mượn ô hồng chị M, đút súp cho Nlong cùng KyKy | như trên |
| `vn:ep1_s4` | Phân cảnh 4 — trước hiên, cơn mưa, lời hứa ngày mai | `ep1_s4.json` |
| `phone:ep1` | Tin nhắn tối: KyKy (nội dung đổi theo lựa chọn) + nhóm “Hội Đồ Án IT” | `data/phone/ep1.json` |
| `ending` | Màn kết thúc + nhá hàng Tập 2 | `scenes/ui/ending.gd`, `data/endings.json` |

## Kết thúc (xét theo thứ tự, ở node `final` của `ep1_s4.json`)
1. `hoang_thuong` — **Hoàng Thượng Đã Duyệt** (bí mật): có ô + đã đút súp cho Nlong + heart ≥ 15 + nlong ≥ 4
2. `duoi_mot_chiec_o` — **Dưới Một Chiếc Ô**: có ô + heart ≥ 10
3. `uot_sung` — **Ướt Sũng Mà Vui**: không ô, chạy mưa cùng nhau + heart ≥ 7
4. `gia_su` — **Gia Sư Tận Tâm**: brain ≥ 5
5. `nguoi_tot_bung` — **Người Lạ Tốt Bụng**: mặc định

Kết thúc đã mở được lưu riêng (`user://meta.json`), xem ở mục **Kỷ niệm** ngoài màn hình chính.

## Cờ (flags) quan trọng
- Phân cảnh 1: `caught_notebook` (bắt sổ → rơi bút thỏ), `saved_coffee`, `notebook_wet` (hết giờ), `called_princess`, `gentle_first`, `returned_turtle` / `kept_turtle`
- Map chiều: `day_intro_done`, `talked_kyky_day`, `promised_drink`, `skip_drink`, `kyky_saw_catvoice`, `played_guitar`, `got_textbook`, `found_pen`, `seen_<id>`
- Pha chế: `drink_made`, `drink_cacao|coffee|peach`, `drink_weird`, `art_smile|heart|turtle|cat|none`
- Phân cảnh 2–3: `turtle_seen`, `free_tutor`, `shifu`, `flicked`, `drew_chibi`, `used_textbook`, `debug_done`, `debug_perfect`, `hand_stay`, `catvoice_study`, `calm_ok` / `calm_fail`
- Map tối: `is_evening`, `evening_intro_done`, `has_umbrella`, `umbrella_black`, `umbrella_pink`, `has_treat`, `fed_treat`, `m_turtle_talk`, `m_blessing`
- Phân cảnh 4: `lied_way`, `promised_3pm`, `ran_rain`, `bag_shield`, `called_car`

## Nhân vật (data/characters.json)
`duc`, `kyky`, `m`, `nlong` có mặt trong Tập 1. `tram`, `thao`, `ducanh`, `hai` đã có ảnh — Thảo & Đức Anh xuất hiện trong nhóm chat, Trâm & Hải nhá hàng ở màn kết thúc (dành cho Tập 2).

## Ý tưởng cho Tập 2 (từ hồ sơ nhân vật)
- Trâm tới quán “thẩm vấn” Anh Đức → mini-game hỏi đáp nhanh.
- Hải xuất hiện, kích hoạt “chế độ ghen” của Anh Đức (mang Nlong ra làm “vũ khí”).
- Thanh Thảo bàn đồ án thân thiết làm KyKy chạnh lòng → lựa chọn giải thích.
- Điện thoại nâng cấp: nhắn tin nhiều ngày, chọn sticker ảnh hưởng chỉ số.
