extends CanvasLayer
## HUD: thanh Rung Động (❤) + Hiểu Bài (💡), nút Nhật ký / Menu, mục tiêu, thông báo nhỏ,
## menu tạm dừng + cài đặt + nhật ký hội thoại. Autoload "Hud".
##   Hud.set_visible_hud(true)   Hud.set_objective("Nói chuyện với chị M")   Hud.toast("+1")

const Icon := preload("res://scripts/ui/icon.gd")
const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
## Thông báo "hiệu ứng cánh bướm" khi lựa chọn làm thay đổi thái độ nhân vật phụ.
const ATTITUDE := {
	"tram": ["Trâm tin tưởng Anh Đức hơn.", "Trâm nhíu mày… cô ấy sẽ nhớ chuyện này."],
	"jealous": ["Anh Đức… đang ghen ngầm.", "Anh Đức bình tĩnh lại một chút."],
	"thao": ["Thanh Thảo nhìn bạn bằng ánh mắt khác.", "Thanh Thảo thở dài."],
	"ducanh": ["Đức Anh coi bạn là chiến hữu.", "Đức Anh hơi chột dạ."],
	"hai": ["Hải bắt đầu để ý Anh Đức.", "Hải lùi lại một bước."],
}

var _root: Control
var _bars: Control
var _heart_bar: ProgressBar
var _brain_bar: ProgressBar
var _heart_icon: Control
var _brain_icon: Control
var _buttons: HBoxContainer
var _objective: PanelContainer
var _objective_label: Label
var _toast_box: VBoxContainer
var _overlay: ColorRect
var _pause_panel: PanelContainer
var _settings_panel: PanelContainer
var _log_panel: PanelContainer
var _log_text: RichTextLabel
var _hud_on := false
var _rotate_layer: CanvasLayer  # "Xoay ngang điện thoại" khi cầm dọc
var _fs_btn: Button
var _relations: Label  # bảng quan hệ trong menu tạm dừng
var _prev := {}  # giá trị chỉ số lần trước -> biết tăng hay giảm
var _cat: TextureRect  # Nlong nằm góc màn hình
var _thought: PanelContainer
var _thought_label: Label
var _thought_tw: Tween
var _thoughts: Array = []
var _cat_cool := 0.0



func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	_build_cat()
	_build_rotate_hint()
	GameState.var_changed.connect(_on_var_changed)
	set_visible_hud(false)


# ---------------------------------------------------------------- điện thoại cầm dọc
func _build_rotate_hint() -> void:
	_rotate_layer = CanvasLayer.new()
	_rotate_layer.layer = 100
	add_child(_rotate_layer)
	var bg := ColorRect.new()
	bg.color = Color("1c1418")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP  # chặn bấm nhầm vào game phía sau
	_rotate_layer.add_child(bg)
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 30)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(v)
	var ic := Icon.new("phone", 190.0)
	ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	ic.pivot_offset = Vector2(95, 95)
	ic.rotation = -PI / 2.0
	v.add_child(ic)
	var tw := ic.create_tween().set_loops()
	tw.tween_property(ic, "rotation", 0.0, 0.9).set_delay(0.6).set_trans(Tween.TRANS_BACK)
	tw.tween_property(ic, "rotation", -PI / 2.0, 0.6).set_delay(0.8)
	var t := Ui.label("Xoay ngang điện thoại để chơi nhé!", 76, Color("fff1dc"), Ui.font_title)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var t2 := Ui.label("(Tắt khoá xoay màn hình nếu đang bật)", 44, Color("ffc7d8"), Ui.font_bold)
	t2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t2)
	get_tree().root.size_changed.connect(_check_orientation)
	_check_orientation()


func _check_orientation() -> void:
	update_orientation(Vector2(get_tree().root.size))


## Hiện màn nhắc xoay ngang nếu cửa sổ cao hơn rộng (điện thoại cầm dọc).
func update_orientation(win: Vector2) -> void:
	_rotate_layer.visible = win.y > win.x * 1.05


func is_rotate_hint_visible() -> bool:
	return _rotate_layer.visible


func set_visible_hud(on: bool) -> void:
	_hud_on = on
	_bars.visible = on
	_buttons.visible = on
	_cat.visible = on and not Story.current_step.begins_with("mini:")  # mini-game cần chỗ trống
	if not on:
		_thought.visible = false
	refresh()


func set_objective(text: String) -> void:
	_objective.visible = text != ""
	_objective_label.text = text


func refresh() -> void:
	_heart_bar.max_value = GameState.bar_max("heart")
	_brain_bar.max_value = GameState.bar_max("brain")
	_heart_bar.value = GameState.get_var("heart")
	_brain_bar.value = GameState.get_var("brain")


func toast(text: String, color: Color = Ui.PINK) -> void:
	# mỗi dòng báo nằm trong một ô nền kem riêng -> nhiều dòng cùng lúc vẫn đọc rõ, không đè lên nhau
	var l := PanelContainer.new()
	var sb := Ui.box(Color(1.0, 0.98, 0.94, 0.94), color, 12, 2, false)
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	l.add_theme_stylebox_override("panel", sb)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var t := Ui.label(text, 20, color, Ui.font_bold)
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l.add_child(t)
	_toast_box.add_child(l)
	while _toast_box.get_child_count() > 4:  # tối đa 4 dòng
		var old := _toast_box.get_child(0)
		_toast_box.remove_child(old)
		old.queue_free()
	l.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(l, "modulate:a", 1.0, 0.2)
	tw.tween_interval(1.6)
	tw.tween_property(l, "modulate:a", 0.0, 0.5)
	tw.tween_callback(l.queue_free)


func _on_var_changed(var_name: String, value: int) -> void:
	refresh()
	var delta: int = value - int(_prev.get(var_name, 0))
	_prev[var_name] = value
	if not _hud_on:
		return
	if ATTITUDE.has(var_name) and delta != 0:
		toast(ATTITUDE[var_name][0 if delta > 0 else 1], Color("7a4fa0") if var_name == "tram" else Color("c0392b") if var_name == "jealous" else Ui.TEXT_SOFT)
	# hiệu ứng nhỏ khi chỉ số đổi
	match var_name:
		"heart":
			_heart_icon.call("bump")
			Audio.sfx("sparkle", -6.0)
		"brain":
			_brain_icon.call("bump")
			Audio.sfx("good", -6.0)
		"nlong":
			toast("Nlong thân với bạn hơn rồi!", Color("6d6d80"))


# ======================================================================= dựng UI
func _build() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = Ui.theme
	add_child(_root)

	_bars = VBoxContainer.new()
	_bars.position = Vector2(18, 14)
	_bars.add_theme_constant_override("separation", 8)
	_bars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_bars)
	var hb := _make_bar("heart", "Rung động", Color("f06292"))
	_heart_bar = hb[0]
	_heart_icon = hb[1]
	var bb := _make_bar("bulb", "Hiểu bài", Color("f5c84c"))
	_brain_bar = bb[0]
	_brain_icon = bb[1]

	_buttons = HBoxContainer.new()
	_buttons.position = Vector2(1060, 14)
	_buttons.add_theme_constant_override("separation", 10)
	_root.add_child(_buttons)
	_buttons.add_child(_round_button("phone", "Nhật ký", _open_log))
	_buttons.add_child(_round_button("menu", "Menu", open_pause))

	_objective = PanelContainer.new()
	_objective.add_theme_stylebox_override("panel", Ui.box(Color(1, 0.97, 0.93, 0.92), Ui.BORDER, 20, 2))
	_objective.position = Vector2(400, 16)
	_objective.custom_minimum_size = Vector2(480, 0)
	_objective.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_objective)
	_objective_label = Ui.label("", 20, Ui.TEXT, Ui.font_bold)
	_objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_objective.add_child(_objective_label)
	_objective.visible = false

	_toast_box = VBoxContainer.new()
	_toast_box.position = Vector2(20, 156)
	_toast_box.add_theme_constant_override("separation", 6)
	_toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_toast_box)

	_overlay = ColorRect.new()
	_overlay.color = Color(0.1, 0.06, 0.05, 0.55)
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.visible = false
	_root.add_child(_overlay)

	# --- menu tạm dừng
	_pause_panel = _panel(Vector2(440, 150), Vector2(400, 0))
	var pv := VBoxContainer.new()
	pv.add_theme_constant_override("separation", 12)
	_pause_panel.add_child(pv)
	var pt := Ui.label("Tạm dừng", 38, Ui.TEXT, Ui.font_title)
	pt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(pt)
	var b1 := Ui.button("Chơi tiếp", 340)
	b1.pressed.connect(close_all)
	pv.add_child(b1)
	var b2 := Ui.button("Cài đặt", 340)
	b2.pressed.connect(func() -> void:
		_pause_panel.visible = false
		_settings_panel.visible = true
		_update_fs_label())
	pv.add_child(b2)
	var b3 := Ui.button("Lưu & về màn hình chính", 340)
	b3.pressed.connect(func() -> void:
		close_all()
		if GameState.step.begins_with("roam"):
			GameState.save_game()
		Story.goto("title", false))
	pv.add_child(b3)
	var tip := Ui.label("Mẹo: bấm nút “Tua »” (hoặc giữ Ctrl) để tua nhanh hội thoại.", 18, Ui.TEXT_SOFT)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(340, 0)
	_relations = Ui.label("", 19, Ui.TEXT, Ui.font_bold)
	_relations.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(_relations)
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pv.add_child(tip)

	# --- cài đặt
	_settings_panel = _panel(Vector2(390, 140), Vector2(500, 0))
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 10)
	_settings_panel.add_child(sv)
	var st := Ui.label("Cài đặt", 38, Ui.TEXT, Ui.font_title)
	st.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sv.add_child(st)
	sv.add_child(_slider("Nhạc nền", "music", 0.0, 1.0))
	sv.add_child(_slider("Âm thanh", "sfx", 0.0, 1.0))
	sv.add_child(_slider("Tốc độ chữ", "text_speed", 15.0, 120.0))
	_fs_btn = Ui.button("Toàn màn hình", 300, 22)
	_fs_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_fs_btn.pressed.connect(func() -> void:
		Ui.toggle_fullscreen()
		_update_fs_label.call_deferred())
	sv.add_child(_fs_btn)
	var sb := Ui.button("Xong", 200)
	sb.pressed.connect(func() -> void:
		GameState.save_settings()
		_settings_panel.visible = false
		if get_tree().paused:
			_pause_panel.visible = true
		else:
			_overlay.visible = false)
	sv.add_child(sb)

	# --- nhật ký hội thoại
	_log_panel = _panel(Vector2(160, 70), Vector2(960, 580))
	var lv := VBoxContainer.new()
	_log_panel.add_child(lv)
	var lt := Ui.label("Nhật ký hội thoại", 34, Ui.TEXT, Ui.font_title)
	lv.add_child(lt)
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(900, 440)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lv.add_child(sc)
	_log_text = RichTextLabel.new()
	_log_text.bbcode_enabled = true
	_log_text.fit_content = true
	_log_text.custom_minimum_size = Vector2(880, 0)
	_log_text.add_theme_font_size_override("normal_font_size", 21)
	_log_text.add_theme_font_size_override("bold_font_size", 21)
	_log_text.add_theme_font_size_override("italics_font_size", 21)
	_log_text.add_theme_color_override("default_color", Ui.TEXT)
	sc.add_child(_log_text)
	var lb := Ui.button("Đóng", 200)
	lb.pressed.connect(close_all)
	lv.add_child(lb)


func _make_bar(icon_kind: String, title: String, fill: Color) -> Array:
	var p := PanelContainer.new()
	var s := Ui.box(Color(1, 0.973, 0.933, 0.94), Ui.BORDER, 22, 3)
	s.content_margin_left = 10
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	p.add_theme_stylebox_override("panel", s)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bars.add_child(p)
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	p.add_child(h)
	var ic := Icon.new(icon_kind, 46.0)
	h.add_child(ic)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	h.add_child(v)
	v.add_child(Ui.label(title, 19, Ui.TEXT, Ui.font_title))
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(190, 16)
	bar.show_percentage = false
	var fs := Ui.box(fill, Color(0, 0, 0, 0), 10, 0, false)
	bar.add_theme_stylebox_override("fill", fs)
	v.add_child(bar)
	return [bar, ic]


func _round_button(icon_kind: String, text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.custom_minimum_size = Vector2(92, 76)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", Ui.box(Color(1, 0.973, 0.933, 0.95), Ui.BORDER, 38, 3))
	b.add_theme_stylebox_override("hover", Ui.box(Color("fff1f4"), Ui.PINK, 38, 3))
	b.add_theme_stylebox_override("pressed", Ui.box(Ui.PINK_SOFT, Ui.PINK, 38, 3, false))
	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", -4)
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	b.add_child(v)
	var ic := Icon.new(icon_kind, 34.0)
	ic.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	v.add_child(ic)
	var l := Ui.label(text, 17, Ui.TEXT, Ui.font_bold)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(l)
	b.pressed.connect(func() -> void:
		Audio.sfx("click")
		cb.call())
	return b


func _panel(pos: Vector2, min_size: Vector2) -> PanelContainer:
	var p := PanelContainer.new()
	p.position = pos
	p.custom_minimum_size = min_size
	var s := Ui.box(Ui.CREAM, Ui.BORDER, 26, 4)
	s.content_margin_left = 30
	s.content_margin_right = 30
	s.content_margin_top = 20
	s.content_margin_bottom = 24
	p.add_theme_stylebox_override("panel", s)
	p.visible = false
	_root.add_child(p)
	return p


func _slider(title: String, key: String, lo: float, hi: float) -> Control:
	var v := VBoxContainer.new()
	v.add_child(Ui.label(title, 22, Ui.TEXT, Ui.font_bold))
	var s := HSlider.new()
	s.min_value = lo
	s.max_value = hi
	s.step = (hi - lo) / 100.0
	s.value = float(GameState.settings.get(key, hi))
	s.custom_minimum_size = Vector2(420, 30)
	s.value_changed.connect(func(val: float) -> void:
		GameState.settings[key] = val
		Audio.refresh_volume())
	v.add_child(s)
	return v


# ======================================================================= mở / đóng
func open_pause() -> void:
	if Story.busy:
		return
	get_tree().paused = true
	_overlay.visible = true
	_pause_panel.visible = true
	_relations.text = relations_text()


## Bảng quan hệ (Tập 2 có thêm thái độ của Trâm và độ ghen của Anh Đức).
func relations_text() -> String:
	var lines := PackedStringArray(["Quan hệ hiện tại"])
	lines.append("KyKy — Rung động %d · Hiểu bài %d" % [GameState.get_var("heart"), GameState.get_var("brain")])
	if GameState.episode >= 2:
		lines.append("Trâm — tin tưởng %d" % GameState.get_var("tram"))
		lines.append("Anh Đức — ghen ngầm %d" % GameState.get_var("jealous"))
	lines.append("Nlong — thân thiết %d" % GameState.get_var("nlong"))
	return "\n".join(lines)


# ---------------------------------------------------------------- Nlong góc màn hình
func _build_cat() -> void:
	_cat = TextureRect.new()
	_cat.texture = Ui.char_tex("cat_loaf")
	_cat.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cat.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	_cat.size = Vector2(104, 66)
	_cat.position = Vector2(300, 74)
	_cat.pivot_offset = Vector2(52, 66)
	_cat.tooltip_text = "Nựng Nlong"
	_cat.gui_input.connect(_on_cat_input)
	_root.add_child(_cat)
	_thought = PanelContainer.new()
	_thought.add_theme_stylebox_override("panel", Ui.box(Color(1, 0.98, 0.95, 0.97), Color("e3b3c2"), 16, 3))
	_thought.position = Vector2(300, 146)
	_thought.custom_minimum_size = Vector2(420, 0)
	_thought.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_thought.visible = false
	_root.add_child(_thought)
	_thought_label = Ui.label("", 19, Ui.TEXT, Ui.font_italic)
	_thought_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_thought_label.custom_minimum_size = Vector2(390, 0)
	_thought.add_child(_thought_label)
	_thoughts = DialogueData.load_json("res://data/nlong_thoughts.json").get("thoughts", [])


func _on_cat_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		pet_cat()


## Chạm Nlong: rừ rừ + một mẩu "tâm tư Anh Đức" (Đức chỉ tâm sự với mèo). Không cộng chỉ số -> không phá kết thúc.
func pet_cat() -> String:
	var tw := _cat.create_tween()
	tw.tween_property(_cat, "scale", Vector2(1.12, 0.9), 0.08)
	tw.tween_property(_cat, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	Audio.sfx(["purr", "mew_soft", "meow"][randi() % 3], -4.0)
	if _cat_cool > 0.0:
		return ""
	_cat_cool = 2.5
	var text := ""
	for t in _thoughts:
		var th: Dictionary = t
		if int(th.get("ep", 1)) > GameState.episode or GameState.seen_thoughts.has(str(th["id"])):
			continue
		if GameState.check(th.get("if", {})):
			text = "Tâm tư Anh Đức: “" + str(th["text"]) + "”"
			GameState.mark_thought(str(th["id"]))
			break
	if text == "":
		var idle := [
			"Nlong rừ rừ, nheo mắt nhìn bạn như hoàng thượng nhìn thần dân.",
			"Nlong lật ngửa bụng… rồi cào nhẹ một phát.",
			"“Meo.” (Hết chuyện để kể rồi, mai quay lại nhé.)",
		]
		text = idle[randi() % idle.size()]
	_thought_label.text = text
	_thought.visible = true
	_thought.modulate.a = 1.0
	if _thought_tw:
		_thought_tw.kill()
	_thought_tw = create_tween()
	_thought_tw.tween_interval(clampf(text.length() * 0.06, 3.0, 7.0))
	_thought_tw.tween_property(_thought, "modulate:a", 0.0, 0.5)
	_thought_tw.tween_callback(func() -> void: _thought.visible = false)
	return text


func _process(delta: float) -> void:
	if _cat_cool > 0.0:
		_cat_cool -= delta


func open_settings() -> void:
	_overlay.visible = true
	_settings_panel.visible = true
	_update_fs_label()


func _update_fs_label() -> void:
	_fs_btn.text = "Thoát toàn màn hình" if Ui.is_fullscreen() else "Toàn màn hình"


func _open_log() -> void:
	get_tree().paused = true
	_overlay.visible = true
	var lines := PackedStringArray()
	for h in Dialogue.history:
		var nm := str(h.get("name", ""))
		if nm != "":
			lines.append("[b][color=#b0476b]%s[/color][/b]  %s" % [nm, str(h.get("text", ""))])
		else:
			lines.append(str(h.get("text", "")))
	_log_text.text = "\n\n".join(lines) if not lines.is_empty() else "[i](Chưa có hội thoại nào)[/i]"
	_log_panel.visible = true
	await get_tree().process_frame
	var sc := _log_text.get_parent() as ScrollContainer
	sc.scroll_vertical = int(sc.get_v_scroll_bar().max_value)


func close_all() -> void:
	_overlay.visible = false
	_pause_panel.visible = false
	_settings_panel.visible = false
	_log_panel.visible = false
	get_tree().paused = false


func any_open() -> bool:
	return _overlay.visible


func _unhandled_input(ev: InputEvent) -> void:
	if not _hud_on:
		return
	if ev.is_action_pressed("menu"):
		get_viewport().set_input_as_handled()
		if any_open():
			close_all()
		else:
			open_pause()
	elif ev.is_action_pressed("log") and not any_open():
		get_viewport().set_input_as_handled()
		_open_log()
