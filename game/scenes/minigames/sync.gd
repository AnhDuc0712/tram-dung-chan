extends Control
## Mini-game 2 Tập 3 "Đồng bộ UI & Logic": nối giao diện của KyKy với hàm trong code của Anh Đức.
## Bên trái 5 thành phần giao diện, bên phải 5 hàm (4 hàm đúng + 1 "bỏ đi" cho thành phần thừa). Không có đồng hồ, không thua.
## Kết quả: {"misses": số lần nối sai} -> Steps.minigame_effects("sync", ...)

const MiniFrame := preload("res://scripts/ui/mini_frame.gd")
## ui = thành phần của KyKy, fn = hàm của Anh Đức, ok = lời sau khi nối đúng
const PAIRS := [
	{"ui": "UI_Nlong_Icon  (mèo Nlong đeo tai nghe)", "fn": "cat_purr_relax()  — gừ gừ cho người dùng thư giãn",
		"ok": "Nlong gừ gừ trên màn hình. “Dễ thương thế này mà không có tiếng thì có tội.”"},
	{"ui": "UI_Warm_Tea  (tách trà gừng ấm)", "fn": "keep_heart_warm()  — nhắc người dùng nghỉ ngơi",
		"ok": "Ứng dụng nhắc: “Uống chút trà rồi hãy làm tiếp nhé.” KyKy mỉm cười."},
	{"ui": "UI_Crescent_Eyes  (đôi mắt cười trăng khuyết)", "fn": "unlock_happy_state()  — mở giao diện rạng rỡ",
		"ok": "Giao diện sáng bừng. Anh Đức đỏ tai: “Tôi không cố ý thiết kế giống em.”"},
	{"ui": "UI_Confession_Button  (nút hình bức thư)", "fn": "return_love_true()  — giải quyết lỗi logic trái tim",
		"ok": "Hàm chạy xong, không báo lỗi. Cả hai cùng im lặng nhìn màn hình một giây."},
	{"ui": "UI_Popup_Spam  (cửa sổ quảng cáo nhấp nháy)", "fn": "Bỏ đi, không cần  — xoá khỏi giao diện",
		"ok": "KyKy: “Cái này thừa, nó phá vibe quán mình.” Anh Đức: “Đồng ý. Xoá.”"},
]

var misses := 0
var _done := true
var _left_btns: Array = []
var _right_btns: Array = []
var _right_to_pair: Array = []  # chỉ số nút bên phải -> chỉ số cặp đúng
var _matched := 0
var _picked := -1  # chỉ số cặp (nút trái) đang chọn
var _msg: Label


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Nối mỗi thành phần giao diện của KyKy với hàm của Anh Đức. Có một thành phần thừa, hãy bỏ nó đi.")
	Audio.music("study")
	_build()
	await MiniFrame.intro(self, "Đồng bộ UI & Logic", [
		"Giao diện của KyKy và mã nguồn của Anh Đức chưa chịu nhận nhau.",
		"Bấm một thành phần ở BÊN TRÁI, rồi bấm hàm tương ứng ở BÊN PHẢI để nối.",
		"Có 5 thành phần, trong đó một cái là thừa: nối nó với “Bỏ đi”.",
		"Không giới hạn thời gian. Nối sai chỉ làm KyKy hơi bối rối.",
	])
	_done = false
	if GameState.autoplay:
		_autoplay()


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_sunset.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.55, 0.5, 0.5)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var order: Array = range(PAIRS.size())
	order.shuffle()
	var lp := _column("Giao diện của KyKy", Vector2(40, 160))
	for i in PAIRS.size():
		var b := Ui.button(str(PAIRS[i]["ui"]), 560, 19)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var idx := i
		b.pressed.connect(func() -> void: _pick_left(idx))
		lp.add_child(b)
		_left_btns.append(b)
	var rp := _column("Hàm của Anh Đức", Vector2(660, 160))
	for slot in order.size():
		var pair_i: int = order[slot]
		var b2 := Ui.button(str(PAIRS[pair_i]["fn"]), 580, 19)
		b2.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var s := slot
		b2.pressed.connect(func() -> void: _pick_right(s))
		rp.add_child(b2)
		_right_btns.append(b2)
		_right_to_pair.append(pair_i)
	_msg = Ui.label("Chọn một thành phần giao diện ở bên trái.", 21, Ui.TEXT_SOFT, Ui.font_italic)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.custom_minimum_size = Vector2(1100, 0)
	_msg.position = Vector2(80, 630)
	add_child(_msg)


func _column(title: String, pos: Vector2) -> VBoxContainer:
	var p := PanelContainer.new()
	p.position = pos
	p.custom_minimum_size = Vector2(580, 0)
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	v.add_child(Ui.label(title, 26, Ui.PINK, Ui.font_title))
	return v


func _say(text: String, col: Color) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", col)


func _mark(b: Button, on: bool) -> void:
	b.add_theme_color_override("font_color", Color("b03a64") if on else Ui.TEXT)


func _pick_left(i: int) -> void:
	if _done or (_left_btns[i] as Button).disabled:
		return
	if _picked >= 0:
		_mark(_left_btns[_picked], false)
	_picked = i
	_mark(_left_btns[i], true)
	Audio.sfx("hover")
	_say("Hàm nào của Anh Đức hợp với “%s”?" % str(PAIRS[i]["ui"]).split("  (")[0], Ui.TEXT)


func _pick_right(slot: int) -> void:
	if _done or (_right_btns[slot] as Button).disabled:
		return
	if _picked < 0:
		_say("Chọn một thành phần ở bên trái trước đã.", Color("c0392b"))
		return
	if int(_right_to_pair[slot]) == _picked:
		_good(slot)
	else:
		misses += 1
		Audio.sfx("bad")
		_say("Chưa khớp. Màn hình nháy đỏ một giây. (Thử nối cặp khác nhé.)", Color("c0392b"))
		var tw := create_tween()
		for k in 4:
			tw.tween_property(_right_btns[slot], "position:x", (6.0 if k % 2 == 0 else -6.0), 0.04)
		tw.tween_property(_right_btns[slot], "position:x", 0.0, 0.04)


func _good(slot: int) -> void:
	var i := _picked
	_picked = -1
	for b in [_left_btns[i], _right_btns[slot]]:
		var btn: Button = b
		btn.disabled = true
		_mark(btn, false)
		btn.add_theme_color_override("font_disabled_color", Color("3f8a4a"))
		btn.text = "Đã nối: " + btn.text
	Audio.sfx("good")
	_matched += 1
	_say(str(PAIRS[i]["ok"]), Color("3f8a4a"))
	if _matched >= PAIRS.size():
		_win()


func _win() -> void:
	_done = true
	await get_tree().create_timer(1.2).timeout
	await MiniFrame.result(self, true, "BUILD SUCCESSFUL!", [
		"WELCOME TO TRAM DUNG CHAN",
		"Số lần nối sai: %d" % misses,
	])
	Story.minigame_done("sync", {"misses": misses})


func _autoplay() -> void:
	for i in PAIRS.size():
		await get_tree().create_timer(0.4).timeout
		_pick_left(i)
		var slot := _right_to_pair.find(i)
		await get_tree().create_timer(0.2).timeout
		_pick_right(slot)
