extends RefCounted
## Màn CHUẨN BỊ (hướng dẫn + nút Bắt đầu, đồng hồ chưa chạy) và màn TỔNG KẾT (thắng / thua) cho mini-game.
##   await MiniFrame.intro(self, "Tiêu đề", ["dòng 1", "dòng 2"])
##   await MiniFrame.result(self, true, "Tuyệt!", ["Gãi trúng 3/3"])
## Chế độ tự chơi (--autoplay) tự bấm nút.

const Shapes := preload("res://scripts/ui/shapes.gd")


static func _card(parent: Control, title: String, lines: Array, button: String, accent: Color) -> Button:
	var dim := ColorRect.new()
	dim.color = Color(0.08, 0.05, 0.06, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP  # chặn bấm nhầm vào mini-game phía sau
	dim.name = "MiniFrame"
	parent.add_child(dim)
	var p := PanelContainer.new()
	var st := Ui.box(Ui.CREAM, accent, 26, 4)
	st.content_margin_left = 36
	st.content_margin_right = 36
	st.content_margin_top = 24
	st.content_margin_bottom = 26
	p.add_theme_stylebox_override("panel", st)
	p.custom_minimum_size = Vector2(640, 0)
	dim.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	p.add_child(v)
	var t := Ui.label(title, 38, accent, Ui.font_title)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	for ln in lines:
		var l := Ui.label(str(ln), 22, Ui.TEXT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.custom_minimum_size = Vector2(568, 0)
		v.add_child(l)
	var b := Ui.button(button, 320, 26)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(b)
	# căn giữa màn hình sau khi biết kích thước
	p.reset_size()
	p.position = (Vector2(1280, 720) - p.get_combined_minimum_size()) * 0.5
	p.scale = Vector2.ONE * 0.92
	p.pivot_offset = p.get_combined_minimum_size() * 0.5
	p.create_tween().tween_property(p, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK)
	b.pressed.connect(func() -> void:
		Audio.sfx("click")
		dim.queue_free())
	if GameState.autoplay:
		b.pressed.emit.call_deferred()
	return b


## Hướng dẫn trước khi chơi. `await` trả về khi người chơi bấm "Bắt đầu!".
static func intro(parent: Control, title: String, lines: Array, button: String = "Bắt đầu!") -> Signal:
	return _card(parent, title, lines, button, Ui.PINK).pressed


## Tổng kết sau khi chơi. `await` trả về khi bấm "Tiếp tục".
static func result(parent: Control, win: bool, title: String, lines: Array, button: String = "Tiếp tục") -> Signal:
	Audio.sfx("good" if win else "bad")
	return _card(parent, title, lines, button, Color("3f8a4a") if win else Color("b0702a")).pressed
