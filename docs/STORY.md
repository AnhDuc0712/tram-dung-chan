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

# Tập 2 — Cơn bão nhỏ ở Gờ 23 & Bài kiểm tra của hội bạn thân
Nguồn: `kịch bản/kichban2.md` (5 phân cảnh, 3 mini-game, 3 kết cục) + mở rộng: buổi chiều tự do có hội bạn,
buổi tối tự do trên phố (chọn tối đa 2 nơi hẹn hò, mỗi nơi một Event CG), thêm 2 kết cục.
Bắt đầu Tập 2 mang theo kết thúc Tập 1 gần nhất (`GameState.ep1_last` → cờ `ep1_umbrella` / `ep1_wet`).

## Chỉ số Tập 2 (thanh Rung động dài 28 — `GameState.BAR_MAX_EP2`)
`heart` (Rung động) · `brain` (Hiểu bài) · `tram` (Trâm tin tưởng — đồng minh hay rào cản) · `jealous` (ghen ngầm của
Anh Đức) · `nlong` · phụ: `ducanh`, `thao`, `dates` (số nơi đã hẹn buổi tối). Mỗi lần `tram/jealous/ducanh/thao/hai` đổi,
HUD báo kiểu “Trâm sẽ nhớ chuyện này” (hiệu ứng cánh bướm); xem tổng ở Menu → Quan hệ.

## Mạch Tập 2
| Bước | Nội dung | File |
|---|---|---|
| `phone:ep2_night` | 00:15 tin nhắn KyKy (A mỏ hỗn / B dịu dàng → `sweet_text` / C cộc lốc → `cold_text`) + nhóm IT (`invited_friends`) | `data/phone/ep2_night.json` |
| `vn:ep2_s1` | 9:00 chị M trêu chuyện đi ngược đường (`honest_m`) | `ep2_s1.json` |
| `roam:ep2_morning` | Tự do: freelancer “cột sống bất ổn”, cặp đôi cấp 3, nựng Nlong (`petted_ep2` → mini-game dễ hơn), pha sẵn đồ (`cacao_ready`) | `data/roam/cafe.json` |
| `vn:ep2_s1k` → `mini:nlong` → `vn:ep2_s1b` | KyKy tới (trà gừng nếu `sweet_text`), Nlong đè bàn phím; mini-game gãi 3 điểm + súp thưởng; chạm tay trên lưng Nlong (chọn có hẹn giờ) | `ep2_s1k/s1b.json`, `nlong_rescue.gd` |
| `vn:ep2_s2` | Trâm “thẩm vấn”, Đức Anh + Thảo tới; KyKy hiểu lầm Thảo (`kyky_doubt`) | `ep2_s2.json` |
| `vn:ep2_s3` → `mini:logic` → `vn:ep2_s3b` | Hải tặng matcha + vé triển lãm; “đánh dấu chủ quyền” (`cold_war` nếu “tuỳ em”); ghép 3 mảnh lệnh | `ep2_s3/s3b.json`, `logic_puzzle.gd` |
| `roam:ep2_afternoon` | Tự do: Trâm hỏi bài kiểm tra (`knows_dark`), Đức Anh nhờ cưa Trâm (`ducanh_toaster` / `ducanh_blurt`), Thảo giải thích hộ, làm lành với KyKy (`made_up`) | `roam_ep2a_*.json` |
| `vn:ep2_s4` → `mini:dark` → `vn:ep2_s4b` | Cúp điện ở góc kệ sách, KyKy sợ tối; 3 nhịp dỗ dành; đèn sáng — cả hội nhìn thấy, phản ứng theo `tram` | `ep2_s4/s4b.json`, `heartbeat.gd` (mode dark) |
| `roam:ep2_night` | Phố trước quán, KyKy đi theo: khu trò chơi (CG gắp thú, `claw_win`), nhà sách cũ (CG ngủ gục), trạm xe buýt (CG áo khoác, `gave_jacket`), Gờ 23 vắng (CG tai nghe), xích đu (bí mật du học, tin nhắn Hải); cô bán hoa, bác bảo vệ, cửa hàng tiện lợi; hàng lẩu = về | `data/roam/street.json`, `roam_ep2n_*.json` |
| `vn:ep2_end` → `phone:ep2_end` → `ending` | Lẩu vỉa hè đêm mưa + kết cục; tin nhắn KyKy & Trâm | `ep2_end.json`, `data/phone/ep2_end.json` |

## Kết thúc Tập 2 (node `fin` của `ep2_end.json`, xét theo thứ tự)
1. `ep2_gau` — **Gấu Bông Hoàng Thượng** (bí mật): `claw_win` + heart ≥ 12 + tram ≥ 3 + nlong ≥ 2
2. `ep2_lau` — **Lời Mời Chính Thức Từ Đại Thần** (CG lẩu): heart ≥ 10 + tram ≥ 3
3. `ep2_ao` — **Chiếc Áo Khoác Dưới Mưa**: `gave_jacket` + heart ≥ 6
4. `ep2_dua` — **Cuộc Đua Không Khoan Nhượng**: jealous ≥ 8
5. `ep2_nlong` — **Hội Những Người Sợ Hoàng Thượng Nlong**: mặc định
Phân bố khi 250 “người chơi ngẫu nhiên” chơi (GUT): lẩu ~39% · hài ~28% · gấu ~16% · đua ~13% · áo ~4%.

## Event CG (`data/cgs.json`, ảnh `assets/art/cg/`)
`cg_claw` (khu trò chơi), `cg_library` (nhà sách), `cg_jacket` (trạm xe buýt / kết áo khoác), `cg_headphones` (Gờ 23 vắng),
`cg_hotpot` (kết lẩu / gấu bông). CG là phần thưởng, không phải đường ray: đi nơi nào cũng có cảnh riêng, có CG hay không
tuỳ lựa chọn. Xem lại ở Kỷ niệm → Ảnh sự kiện.

## Nlong ở góc màn hình
Chạm vào → “tâm tư Anh Đức” (`data/nlong_thoughts.json`, điều kiện theo cờ/tập), không cộng chỉ số.

# Tập 3 — Đồ án chung & lời hứa dưới nắng sớm (bản alpha đầu tiên)
Nguồn: `kịch bản/kichban3.md` (ý tưởng gốc) hợp nhất thành `kịch bản/kichban3_v2.md` (bản dùng để code). **Tập 3 không phải tập cuối: mọi kết cục để kết mở, nhá hàng Tập 4.**
Bắt đầu Tập 3 mang theo kết thúc Tập 2 gần nhất (`GameState.ep2_last` → cờ `ep2_gau|lau|ao|dua|nlong`, kèm `claw_win` / `gave_jacket`).
Đức tôn trọng trước, tuyên bố sau: không có câu “chủ quyền” nào; KyKy tự sửa lỗi và tự chọn chuyện học bổng.

## Chỉ số Tập 3 (thanh Rung động dài 30 — `GameState.BAR_MAX_EP3`, Hiểu bài dài 8)
`heart` · `brain` (“Đồng điệu” đồ án) · `tram` · `jealous` · `respect` (Đức ủng hộ lựa chọn của KyKy, hiện ở Menu → Quan hệ) · `hai` · `nlong` · phụ: `expo` (số nơi đã ghé ở phố triển lãm; ≥ 2 thì Hải xuất hiện).

## Mạch Tập 3
| Bước | Nội dung | File |
|---|---|---|
| `vn:ep3_s1` | Thứ Ba, sân trường: trả áo/bánh cháy (CG `cg_burnt`), Hải mời đứng tên chung, Thảo + Đức Anh xin vẽ UI đồ án | `ep3_s1.json` |
| `roam:ep3_campus` | **Tự do (bản đồ `map_campus`):** nhiệm vụ “Nlong Junior mất tích” — cậu sinh viên (`clue_student`), Thầy (`clue_teacher`), Trâm, Thảo → bãi xe (`junior_found`) | `data/roam/campus.json`, `roam_ep3c_*.json` |
| `vn:ep3_s2` → `mini:rush` → `vn:ep3_s2b` | Thứ Năm, giờ cao điểm Gờ 23; buộc tạp dề (tự thắt `respect` hay nhờ Đức `heart`); mini-game 3 phiếu order (Đức chọn món, KyKy rót đúng vùng xanh) | `ep3_s2/s2b.json`, `rush.gd` |
| `vn:ep3_s3` → `mini:sync` → `vn:ep3_s3b` | Thứ Bảy chiều tà: lỗi `Null Pointer — Heartbeat`, **KyKy tự dò log** (`kyky_fixed_bug`) hoặc Đức sửa hộ; nối 5 cặp UI-hàm (1 cặp thừa); KyKy ngủ gục (CG `cg_asleep`), `kyky_heard` nếu Đồng điệu ≥ 3 | `ep3_s3/s3b.json`, `sync.gd` |
| `roam:ep3_expo` | **Tự do (phố `map_street`, biến thể mới):** gian Trạm Dừng Chân (đưa micro cho KyKy `respect`), bác móc khoá (`bought_keychain`), quán trà Trâm + M (`street_date`), anh freelancer → Hải ở bảng học bổng | `data/roam/street.json`, `roam_ep3e_*.json` |
| `vn:ep3_s4` | Hải kể lý do riêng, đưa hoa chúc mừng (CG `cg_expo`); KyKy tâm sự; Đức nói: **A** “em đi, tôi đợi” (`kyky_goes`), **B** “ở lại cũng không phải bỏ cuộc” (`kyky_stays`), **C** “dù em chọn gì tôi ở đây” (`kyky_both`), **D** “đừng đi” (chỉ hiện khi `jealous` ≥ 2, `said_dont_go`) | `ep3_s4.json` |
| `vn:ep3_s5` → `phone:ep3_end` → `ending` | Chủ nhật 6:00, hiên Gờ 23 (CG `cg_sunrise`), tỏ tình + kết cục | `ep3_s5.json`, `data/phone/ep3_end.json` |

## Kết thúc Tập 3 (node `result` của `ep3_s5.json`, xét theo thứ tự)
1. `ep3_loi_logic` — **Lỗi Logic Duy Nhất Là Em**: `kyky_both` + heart ≥ 14 + respect ≥ 4 + brain ≥ 3 + jealous < 5
2. `ep3_hoc_cach_tin` — **Học Cách Tin**: `said_dont_go` hoặc jealous ≥ 5
3. `ep3_paris` — **Hẹn Ước Dưới Bầu Trời Xa** (buồn-ngọt): `kyky_goes` + heart ≥ 8
4. `ep3_dong_chu_quan` — **Trạm Dừng Chân Của Riêng Hai Đứa**: `kyky_stays` + heart ≥ 7
5. `ep3_hoang_thuong` — **Hoàng Thượng Ban Hôn Lúc Bình Minh**: mặc định
Phân bố khi 250 “người chơi ngẫu nhiên” chơi (GUT): quán ~34% · Paris ~25% · hài ~22% · logic ~12% · học cách tin ~8%.
Mỗi kết cục có `next` nhá hàng Tập 4 trong `endings.json` (`GameState.ep3_last` để Tập 4 đọc).

## Event CG Tập 3 (`data/cgs.json`)
`cg_burnt` (sân trường), `cg_asleep` (chiều tà), `cg_expo` (đêm triển lãm), `cg_sunrise` (bình minh, dùng cho mọi kết cục). Ảnh gốc xử lý bằng `tools/art/process_ep3.py`.
Chưa có (còn lại trong `thiết kế/yeucauhinhanh.md`): CG buộc tạp dề, CG riêng cho từng kết cục, nền `exhibition_night`, trang phục mới (tạp dề, váy kem, sơ mi đen) — hiện dùng sprite polo có sẵn và nền cũ.
