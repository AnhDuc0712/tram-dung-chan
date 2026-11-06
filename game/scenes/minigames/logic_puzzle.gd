extends Control
## Mini-game 2 Tập 2 "Gỡ rối tâm tư & Bài kiểm tra vòng lặp trái tim".
## Ghép 3 mảnh lệnh (tiếng Việt đời thường) để chibi KyKy chạy tới chỗ chibi Anh Đức dưới mưa.
## Kết quả: {"first_try": số mảnh chọn đúng ngay lần đầu (0..3)}

const Shapes := preload("res://scripts/ui/shapes.gd")
const MiniFrame := preload("res://scripts/ui/mini_frame.gd")
## "wrong": câu phản hồi RIÊNG cho từng đáp án sai (chỉ số đáp án -> câu), khớp đúng hành động đã chọn.
const ROWS := [
	{"head": "Nếu (Trời đổ mưa) thì…", "options": ["Đứng yên ở hiên quán đợi Anh Đức", "Cầm ngược bản đồ chạy lung tung", "Đội cuốn sổ lên đầu chạy về"], "right": 0,
		"wrong": {1: "Chibi KyKy cầm ngược bản đồ… lao thẳng vào bức tường quen thuộc.",
			2: "Chibi KyKy đội cuốn sổ lên đầu chạy ào ra mưa… sổ ướt nhẹp, bài tập nhoè hết."}},
	{"head": "Trong khi (Đang buồn hoặc đói bụng) thì…", "options": ["Gặm bút thỏ", "Uống ca cao nóng & nựng mèo Nlong", "Đếm cánh hoa cúc"], "right": 1,
		"wrong": {0: "Chibi KyKy gặm bút thỏ… tai thỏ méo xệch mà bụng vẫn kêu ọt ọt.",
			2: "Hoa cúc bảo “có”… nhưng cái bụng vẫn kêu ọt ọt."}},
	{"head": "Kết quả trả về (Return):", "options": ["Hộp bánh matcha", "Lỗi 404: Không tìm thấy não", "Nụ cười của KyKy"], "right": 2,
		"wrong": {0: "Anh Đức nheo mắt nhìn hộp bánh matcha. Rất lâu. (Ai tặng thế?)",
			1: "Anh Đức gõ bút lên trán KyKy: “Não em vẫn ở đây, chỉ đang bận nghĩ linh tinh thôi.”"}},
]

var first_try := 0
var _row := 0
var _missed := false
var _done := false
var _head: Label
var _opts: VBoxContainer
var _msg: Label
var _code: RichTextLabel
var _scene: Control
var _run_t := -1.0
var _locked := false


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Ghép đúng 3 mảnh lệnh để chibi KyKy tìm được đường tới chỗ Anh Đức dưới mưa.")
	Audio.music("study")
	_build()
	_show_row()
	if GameState.autoplay:
		for i in ROWS.size():
			await get_tree().create_timer(1.0).timeout  # > thời gian khoá sau câu đúng (0,7 giây)
			_pick(int(ROWS[i]["right"]))


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_sunset.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.55, 0.5, 0.5)
	add_child(bg)
	# màn hình laptop: đoạn "code" đang ghép
	var lap := PanelContainer.new()
	lap.add_theme_stylebox_override("panel", Ui.box(Color("2a2438"), Color("1a1624"), 14, 6))
	lap.position = Vector2(60, 165)  # dưới thanh Rung động / Hiểu bài
	lap.custom_minimum_size = Vector2(560, 310)
	add_child(lap)
	_code = RichTextLabel.new()
	_code.bbcode_enabled = true
	_code.fit_content = true
	_code.add_theme_font_override("normal_font", Ui.font_mono)
	_code.add_theme_font_size_override("normal_font_size", 20)
	_code.add_theme_color_override("default_color", Color("e8e0f5"))
	lap.add_child(_code)
	# cảnh chibi chạy dưới mưa
	_scene = Control.new()
	_scene.position = Vector2(60, 500)
	_scene.size = Vector2(560, 150)
	_scene.draw.connect(_draw_scene)
	add_child(_scene)
	# bảng chọn
	var p := PanelContainer.new()
	p.position = Vector2(660, 165)
	p.custom_minimum_size = Vector2(560, 0)
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	v.add_child(Ui.label("Bài kiểm tra vòng lặp trái tim", 28, Ui.PINK, Ui.font_title))
	_head = Ui.label("", 22, Ui.TEXT, Ui.font_bold)
	v.add_child(_head)
	_opts = VBoxContainer.new()
	_opts.add_theme_constant_override("separation", 10)
	v.add_child(_opts)
	_msg = Ui.label("Anh Đức gõ nhẹ bút lên trán KyKy: “Tập trung vào.”", 19, Ui.TEXT_SOFT, Ui.font_italic)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.custom_minimum_size = Vector2(520, 0)
	v.add_child(_msg)


func _code_text() -> String:
	var lines := PackedStringArray(["[color=#9aa3b5]# chibi_kyky.py — tìm đường tới Anh Đức[/color]"])
	for i in ROWS.size():
		var r: Dictionary = ROWS[i]
		var ans := "[color=#7be0a8]" + str(r["options"][r["right"]]) + "[/color]" if i < _row else ("[color=#ffd166]???[/color]" if i == _row else "[color=#555]...[/color]")
		lines.append("[color=#ff8fab]" + str(r["head"]) + "[/color]")
		lines.append("    " + ans)
	return "\n".join(lines)


func _show_row() -> void:
	_code.text = _code_text()
	for c in _opts.get_children():
		c.queue_free()
	if _row >= ROWS.size():
		return
	var r: Dictionary = ROWS[_row]
	_head.text = "Mảnh %d/3 — %s" % [_row + 1, r["head"]]
	_missed = false
	for i in (r["options"] as Array).size():
		var b := Ui.button(str(r["options"][i]), 520, 21)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var idx := i
		b.pressed.connect(func() -> void: _pick(idx, b))
		_opts.add_child(b)


func _mark(b: Button, ok: bool) -> void:
	## tô màu nút đã chọn: xanh = đúng, đỏ = sai (sai thì khoá luôn nút đó)
	if b == null:
		return
	var col := Color("3f8a4a") if ok else Color("c0392b")
	for st in ["normal", "hover", "pressed", "disabled"]:
		b.add_theme_stylebox_override(st, Ui.box(Color("e3f4e6") if ok else Color("fbe3df"), col, 18, 3, false))
	b.add_theme_color_override("font_color", col)
	b.add_theme_color_override("font_disabled_color", col)
	b.text = ("Đúng: " if ok else "Sai: ") + b.text
	b.disabled = true


func _pick(i: int, b: Button = null) -> void:
	if _done or _row >= ROWS.size() or _locked:
		return
	var r: Dictionary = ROWS[_row]
	if i == int(r["right"]):
		if not _missed:
			first_try += 1
		Audio.sfx("good")
		_mark(b, true)
		_msg.add_theme_color_override("font_color", Color("3f8a4a"))
		_msg.text = "Đúng rồi! " + ["“Trời mưa thì đứng yên đó, tôi tới.”", "“Ừ. Buồn thì có ca cao với hoàng thượng.”", "“…Đúng. Kết quả trả về là cái đó.”"][_row]
		_locked = true
		await get_tree().create_timer(0.7).timeout
		_locked = false
		_row += 1
		_show_row()
		if _row >= ROWS.size():
			_win()
	else:
		_missed = true
		Audio.sfx("bad")
		_mark(b, false)
		_msg.add_theme_color_override("font_color", Color("c0392b"))
		_msg.text = "Sai rồi! " + str((r["wrong"] as Dictionary).get(i, "Chưa đúng, thử đáp án khác nhé."))
		var tw := create_tween()
		for k in 4:
			tw.tween_property(_opts, "position:x", (6.0 if k % 2 == 0 else -6.0), 0.04)
		tw.tween_property(_opts, "position:x", 0.0, 0.04)


func _win() -> void:
	_done = true
	_head.text = "Hoàn thành!"
	_run_t = 0.0
	await get_tree().create_timer(1.8).timeout
	await MiniFrame.result(self, first_try >= 2, "Chạy tới nơi rồi!" if first_try >= 2 else "Tới nơi… sau vài lần lạc",
		["Chibi KyKy đã tìm được đường tới chỗ Anh Đức dưới mưa.", "Đúng ngay lần đầu: %d / 3 mảnh lệnh" % first_try])
	Story.minigame_done("logic", {"first_try": first_try})


func _process(delta: float) -> void:
	if _run_t >= 0.0:
		_run_t = minf(_run_t + delta * 0.6, 1.0)
	_scene.queue_redraw()


func _draw_scene() -> void:
	var w := _scene.size.x
	_scene.draw_rect(Rect2(0, 0, w, 150), Color(0.12, 0.14, 0.24, 0.9))
	var t := Time.get_ticks_msec() / 1000.0
	for i in 40:  # mưa
		var x := fposmod(i * 37.0 + t * 60.0, w)
		var y := fposmod(i * 23.0 + t * 260.0, 150.0)
		_scene.draw_line(Vector2(x, y), Vector2(x - 3, y + 10), Color(0.7, 0.8, 1.0, 0.5), 1.5)
	_scene.draw_rect(Rect2(0, 120, w, 30), Color(0.25, 0.25, 0.32))
	# chibi Anh Đức bên phải (ô đen), chibi KyKy chạy từ trái
	_chibi(Vector2(w - 70, 118), Color("2b2b33"), true)
	var p := 0.15 + 0.55 * clampf(float(_row) / 3.0, 0.0, 1.0) + 0.2 * maxf(_run_t, 0.0)
	_chibi(Vector2(w * p, 118 - absf(sin(t * 9.0)) * 4.0), Color("d0477a"), false)
	if _run_t >= 1.0:
		Shapes.draw_heart(_scene, Vector2(w - 110, 50), 30.0, Color("f06292"), Color("c2185b"))


func _chibi(foot: Vector2, col: Color, umbrella: bool) -> void:
	_scene.draw_circle(foot + Vector2(0, -44), 14.0, Color("f6d2b8"))
	_scene.draw_rect(Rect2(foot + Vector2(-10, -30), Vector2(20, 30)), col)
	if umbrella:
		_scene.draw_arc(foot + Vector2(0, -60), 34.0, PI, TAU, 24, Color("1a1a22"), 6.0)
		_scene.draw_line(foot + Vector2(0, -60), foot + Vector2(0, -20), Color("1a1a22"), 3.0)
