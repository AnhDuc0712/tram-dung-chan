extends Control
## Mini-game "Giữ bình tĩnh": KyKy ghé sát, tim Anh Đức đập loạn. Bấm (Space / chạm) khi kim
## nằm trong vùng xanh. 3 lượt — trúng >= 2 là "bình tĩnh" (calm_ok), không thì "lag" (calm_fail).
## Cả hai kết quả đều dễ thương, chỉ khác lời thoại.

const Icon := preload("res://scripts/ui/icon.gd")
const MiniFrame := preload("res://scripts/ui/mini_frame.gd")
const TRIES := 3
const DARK_HIT := ["Chỉnh lại cặp kính bị lệch trên sống mũi cô ấy.", "Cài lại chiếc kẹp tóc bị tuột.", "Cúi xuống ngang tầm mắt KyKy… và đèn bật sáng!"]
const DARK_MISS := ["Tay run quá, chạm nhầm vào má cô ấy…", "Thình thịch… thình thịch…", "Tim đập to đến mức chắc cô ấy nghe thấy mất."]

var tries := 0
var hits := 0
var _pos := 0.0  # 0..1
var _dir := 1.0
var _speed := 0.75
var _zone := Vector2(0.4, 0.6)
var _locked := false
var _track: Control
var _heart: Control
var _msg: Label
var _count: Label
var _beat_t := 0.0
var _ky: Sprite2D
var _btn: Button
## "dark" = mini-game 3 Tập 2 (Nhịp đập trong bóng tối, scene dark.tscn): cùng cơ chế, khác hình + lời.
var _mode := "heartbeat"


func _ready() -> void:
	if scene_file_path.ends_with("dark.tscn"):
		_mode = "dark"
	Hud.set_visible_hud(true)
	if _mode == "dark":
		Hud.set_objective("Nhịp đập trong bóng tối: chạm khi vòng tròn khớp với vòng sáng (3 lần).")
	else:
		Hud.set_objective("Giữ bình tĩnh! Bấm Space / chạm màn hình khi kim nằm trong vùng xanh.")
	Audio.music("")
	_build()
	_new_zone()
	_locked = true
	if _mode == "dark":
		await MiniFrame.intro(self, "Nhịp đập trong bóng tối", [
			"Mất điện. KyKy run run túm áo bạn. Giữ bình tĩnh để dỗ cô ấy.",
			"Vòng tròn hồng co giãn theo nhịp tim. Chạm vào BẤT KỲ đâu trên màn hình (hoặc Space) đúng lúc nó nằm trong vòng sáng vàng.",
			"3 lượt — trúng 2 lượt là bình tĩnh được.",
		])
	else:
		await MiniFrame.intro(self, "Giữ bình tĩnh!", [
			"KyKy ghé sát quá… tim Anh Đức đập loạn xạ.",
			"Chạm vào BẤT KỲ đâu trên màn hình (hoặc Space) khi kim hồng nằm trong vùng xanh.",
			"3 lượt — trúng 2 lượt là qua.",
		])
	_locked = false
	if GameState.autoplay:
		for i in TRIES:
			await get_tree().create_timer(0.5).timeout
			_pos = (_zone.x + _zone.y) * 0.5
			_press()
			await get_tree().create_timer(1.0).timeout


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/library.jpg" if _mode == "dark" else "res://assets/art/bg/cafe_sunset.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	var pink := ColorRect.new()
	pink.color = Color(0.02, 0.02, 0.06, 0.86) if _mode == "dark" else Color(1.0, 0.6, 0.7, 0.18)
	pink.set_anchors_preset(Control.PRESET_FULL_RECT)
	pink.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pink)
	var tex := Ui.char_tex("kyky_wave_panic" if _mode == "dark" else "kyky_wave")
	if tex:
		var s := Sprite2D.new()
		_ky = s
		s.texture = tex
		s.centered = false
		s.offset = Vector2(-tex.get_width() * 0.5, -tex.get_height())
		s.position = Vector2(1030, 1010)
		s.scale = Vector2(1.4, 1.4)
		add_child(s)

	_heart = Icon.new("heart", 150.0)
	_heart.position = Vector2(655, 175) if _mode == "dark" else Vector2(265, 150)
	add_child(_heart)

	var p := PanelContainer.new()
	p.position = Vector2(80, 170 if _mode == "dark" else 360)  # bảng chế độ tối cao hơn -> đặt cao lên để không tràn mép dưới
	p.custom_minimum_size = Vector2(560, 0)
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	v.add_child(Ui.label("Nhịp đập trong bóng tối" if _mode == "dark" else "Giữ bình tĩnh!", 32, Ui.PINK, Ui.font_title))
	var intro := "Cô bé đang ở rất gần… Hít thở. Mày là đại thần IT."
	if _mode == "dark":
		intro = "Mất điện. KyKy túm chặt vạt áo bạn, run run. Ánh đèn điện thoại là thứ duy nhất còn sáng…"
	_msg = Ui.label(intro, 20, Ui.TEXT)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.custom_minimum_size = Vector2(520, 0)
	v.add_child(_msg)
	_track = Control.new()
	_track.custom_minimum_size = Vector2(520, 210 if _mode == "dark" else 46)
	_track.draw.connect(_draw_track)
	v.add_child(_track)
	_count = Ui.label("", 20, Ui.TEXT_SOFT, Ui.font_bold)
	v.add_child(_count)
	var b := Ui.button("BẤM!", 520, 26)
	b.pressed.connect(_press)
	v.add_child(b)
	_btn = b
	_update_count()


func _draw_track() -> void:
	var w := _track.size.x
	var h := _track.size.y
	if _mode == "dark":
		# vòng sáng mục tiêu (vùng khớp) + vòng nhịp tim co giãn
		var c := Vector2(w * 0.5, h * 0.5)
		var rmax := h * 0.48
		_track.draw_circle(c, rmax, Color(1, 0.95, 0.8, 0.06))
		_track.draw_arc(c, rmax * (_zone.x + _zone.y) * 0.5, 0, TAU, 64, Color(1, 0.92, 0.6, 0.35), rmax * (_zone.y - _zone.x))
		_track.draw_arc(c, maxf(4.0, rmax * _pos), 0, TAU, 64, Ui.PINK, 5.0, true)
		return
	_track.draw_rect(Rect2(0, h * 0.25, w, h * 0.5), Color("f1e4d2"))
	_track.draw_rect(Rect2(w * _zone.x, h * 0.25, w * (_zone.y - _zone.x), h * 0.5), Color("8fd6a8"))
	_track.draw_rect(Rect2(0, h * 0.25, w, h * 0.5), Ui.BORDER, false, 2.0)
	var x := w * _pos
	_track.draw_rect(Rect2(x - 4, 0, 8, h), Ui.PINK)


func _new_zone() -> void:
	var width := (0.3 if _mode == "dark" else 0.24) - tries * 0.04
	var start := randf_range(0.25 if _mode == "dark" else 0.1, 0.9 - width)  # vòng sáng không quá nhỏ ở giữa
	_zone = Vector2(start, start + width)
	_speed = (0.6 + tries * 0.2) if _mode == "dark" else (0.8 + tries * 0.35)


func _process(delta: float) -> void:
	var bpm := 80.0 + (tries - hits) * 30.0 + tries * 12.0
	_beat_t += delta
	if _beat_t > 60.0 / bpm:
		_beat_t = 0.0
		_heart.call("bump")
	if _locked:
		return
	_pos += _dir * _speed * delta
	if _pos > 1.0:
		_pos = 1.0
		_dir = -1.0
	elif _pos < 0.0:
		_pos = 0.0
		_dir = 1.0
	_track.queue_redraw()


func _unhandled_input(ev: InputEvent) -> void:
	# chạm bất kỳ đâu cũng tính (trước chỉ nút BẤM -> trên điện thoại dễ chạm trượt)
	var tap: bool = ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT
	if ev.is_action_pressed("interact") or tap:
		get_viewport().set_input_as_handled()
		_press()


func _press() -> void:
	if _locked or tries >= TRIES:
		return
	_locked = true
	_btn.disabled = true
	_btn.text = "Thở đều…"  # báo rõ đang chờ lượt sau, không phải bấm không ăn
	tries += 1
	if _pos >= _zone.x and _pos <= _zone.y:
		hits += 1
		Audio.sfx("heart_slow")
		_face("kyky_wave_surprised" if _mode == "dark" else "kyky_wave")
		_msg.text = (DARK_HIT if _mode == "dark" else ["Phù… ổn. Vẫn ổn.", "Bình tĩnh… vòng lặp… biến i…", "Giọng vẫn đều. Đại thần IT không lag!"])[tries - 1]
	else:
		Audio.sfx("heart_fast")
		_face("kyky_wave_worried" if _mode == "dark" else ("kyky_wave_surprised" if tries < TRIES else "kyky_wave_think"))
		_msg.text = (DARK_MISS if _mode == "dark" else ["Thình thịch!! Mùi tóc thơm quá…", "Thình thịch thình thịch!!!", "TIM ƠI BÌNH TĨNH!!!"])[tries - 1]
		var tw0 := create_tween()
		for i in 6:
			tw0.tween_property(self, "position", Vector2(randf_range(-8, 8), randf_range(-6, 6)), 0.04)
		tw0.tween_property(self, "position", Vector2.ZERO, 0.04)
	_update_count()
	await get_tree().create_timer(0.6).timeout
	if tries >= TRIES:
		var win := hits >= 2
		var end_text := ""
		if _mode == "dark":
			end_text = "Đèn bật sáng!" if win else "Đèn bật sáng… đúng lúc bạn đang lóng ngóng nhất."
		else:
			end_text = "Bình tĩnh được rồi!" if win else "…Hỏng rồi. Mặt nóng ran."
		_msg.text = end_text
		await get_tree().create_timer(0.5).timeout
		await MiniFrame.result(self, win, "Bình tĩnh như đại thần IT!" if win else "Tim đập loạn mất rồi…",
			[end_text, "Trúng nhịp: %d / %d lượt" % [hits, TRIES]])
		Story.minigame_done(_mode, {"hits": hits})
		return
	_new_zone()
	_btn.disabled = false
	_btn.text = "BẤM!"
	_locked = false


## KyKy phản ứng: anh Đức lag là cô bé ngơ ngác nhìn sang.
func _face(img: String) -> void:
	var t := Ui.char_tex(img)
	if _ky != null and t != null:
		_ky.texture = t


func _update_count() -> void:
	_count.text = "Lượt: %d / %d    Bình tĩnh: %d" % [tries, TRIES, hits]
