extends Control
## Màn hình chính: Bắt đầu / Tiếp tục / Kỷ niệm (các kết thúc đã mở) / Cài đặt / Ghi công / Thoát.

const Rain := preload("res://scripts/vn/rain.gd")
const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const Steps := preload("res://scripts/story_steps.gd")


var _gallery: PanelContainer
var _credits: PanelContainer
var _episodes: PanelContainer


func _ready() -> void:
	Hud.set_visible_hud(false)
	Hud.close_all()
	Dialogue.clear_stage()
	Audio.music("title")
	Audio.ambient("rain_loop")
	_build()
	if GameState.autoplay and GameState.ending_id == "":
		# tự chơi: "-- --autoplay --episode=2" để chơi thử Tập 2
		var ep := 1
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--episode="):
				ep = int(a.substr(10))
		get_tree().create_timer(0.5).timeout.connect(func() -> void: Story.new_game(ep))


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/street_rain.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	add_child(bg)
	var rain := Rain.new()
	rain.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rain)
	# dải tối bên trái cho dễ đọc chữ
	var shade := TextureRect.new()
	var grad := Gradient.new()
	grad.set_color(0, Color(0.06, 0.04, 0.08, 0.85))
	grad.set_color(1, Color(0.06, 0.04, 0.08, 0.0))
	var gt := GradientTexture2D.new()
	gt.gradient = grad
	gt.fill_from = Vector2(0, 0)
	gt.fill_to = Vector2(1, 0)
	shade.texture = gt
	shade.position = Vector2.ZERO
	shade.size = Vector2(760, 720)
	shade.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	add_child(shade)

	# hai nhân vật chính
	for info in [["duc_front", Vector2(930, 735), 0.78, false], ["kyky_hug", Vector2(1110, 740), 0.8, false]]:
		var t := Ui.char_tex(info[0])
		if t:
			var s := Sprite2D.new()
			s.texture = t
			s.centered = false
			s.offset = Vector2(-t.get_width() * 0.5, -t.get_height())
			s.position = info[1]
			s.scale = Vector2.ONE * float(info[2])
			add_child(s)
			var tw := s.create_tween().set_loops()
			tw.tween_property(s, "position:y", (info[1] as Vector2).y - 6, 1.6 + randf() * 0.4).set_trans(Tween.TRANS_SINE)
			tw.tween_property(s, "position:y", (info[1] as Vector2).y, 1.6).set_trans(Tween.TRANS_SINE)

	var title := Ui.label("Trạm\nDừng Chân", 92, Color("fff1dc"), Ui.font_title)
	title.position = Vector2(70, 40)
	title.add_theme_constant_override("line_spacing", -30)
	title.add_theme_color_override("font_outline_color", Color("d0477a"))
	title.add_theme_constant_override("outline_size", 14)
	add_child(title)
	var sub := Ui.label("Quán Gờ 23 · ghé lại một chút", 24, Color("ffc7d8"), Ui.font_mono)
	sub.position = Vector2(80, 276)
	add_child(sub)
	# nền mờ tối phía sau 2 dòng phụ -> không chìm vào ảnh cửa quán
	var plate := Panel.new()
	plate.position = Vector2(66, 272)
	plate.size = Vector2(560, 76)
	plate.add_theme_stylebox_override("panel", Ui.box(Color(0.1, 0.06, 0.07, 0.62), Color(0, 0, 0, 0), 14, 0, false))
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(plate)
	move_child(plate, sub.get_index())
	var ep := Ui.label("Tập 1 · Cú va chạm  —  Tập 2 · Cơn bão nhỏ (mới)", 24, Color("fff4e6"), Ui.font_bold)
	ep.position = Vector2(80, 310)
	for l in [sub, ep]:
		l.add_theme_color_override("font_outline_color", Color(0.12, 0.06, 0.08))
		l.add_theme_constant_override("outline_size", 6)
	add_child(ep)

	var menu := VBoxContainer.new()
	menu.position = Vector2(80, 360)
	menu.add_theme_constant_override("separation", 12)
	add_child(menu)
	var b_new := Ui.button("Bắt đầu", 300)
	b_new.pressed.connect(_on_new)
	menu.add_child(b_new)
	var b_cont := Ui.button("Tiếp tục", 300)
	b_cont.disabled = not GameState.has_save()
	b_cont.pressed.connect(func() -> void: Story.continue_game())
	menu.add_child(b_cont)
	var total := DialogueData.load_json(DialogueData.ENDINGS_PATH).size()
	var b_gal := Ui.button("Kỷ niệm  (%d/%d)" % [GameState.unlocked_endings.size(), total], 300)
	b_gal.pressed.connect(func() -> void: _gallery.visible = true)
	menu.add_child(b_gal)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	menu.add_child(row)
	var b_set := Ui.button("Cài đặt", 144, 20)
	b_set.pressed.connect(func() -> void: Hud.open_settings())
	row.add_child(b_set)
	var b_cre := Ui.button("Ghi công", 144, 20)
	b_cre.pressed.connect(func() -> void: _credits.visible = true)
	row.add_child(b_cre)
	if Ui.is_web() or Ui.touch:
		# trình duyệt không "thoát" được -> thay bằng nút toàn màn hình (điện thoại: khoá luôn màn hình ngang)
		var b_fs := Ui.button("Toàn màn hình", 300)
		b_fs.pressed.connect(func() -> void: Ui.toggle_fullscreen())
		menu.add_child(b_fs)
	else:
		var b_quit := Ui.button("Thoát", 300)
		b_quit.pressed.connect(func() -> void: get_tree().quit())
		menu.add_child(b_quit)

	var ver := Ui.label("Ver " + str(ProjectSettings.get_setting("application/config/version", "1.0")) + " · làm bằng Godot", 16, Color(1, 1, 1, 0.55))
	ver.position = Vector2(14, 694)
	add_child(ver)

	_gallery = _build_gallery()
	_credits = _build_credits()


func _on_new() -> void:
	if _episodes == null:
		_episodes = _build_episodes()
	_episodes.visible = true


## Chọn tập: tập nào cũng chơi được ngay (game mở, không khoá); Tập 2 mang theo kết thúc Tập 1 gần nhất.
func _build_episodes() -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Ui.box(Ui.CREAM, Ui.BORDER, 26, 4))
	p.position = Vector2(330, 150)
	p.custom_minimum_size = Vector2(620, 0)
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	p.add_child(v)
	v.add_child(Ui.label("Chọn tập", 38, Ui.TEXT, Ui.font_title))
	for ep in Steps.EPISODES:
		var info: Dictionary = Steps.EPISODES[ep]
		var b := Ui.button(str(info["title"]), 560, 24)
		var e: int = ep
		b.pressed.connect(func() -> void: Story.new_game(e))
		v.add_child(b)
	var note := "Tập 2 tiếp nối kết thúc Tập 1 bạn chơi gần nhất"
	if GameState.ep1_last != "":
		var last_title := str(DialogueData.load_json(DialogueData.ENDINGS_PATH).get(GameState.ep1_last, {}).get("title", ""))
		note += " (" + last_title + ")."
	else:
		note += " — chưa chơi Tập 1 thì theo mạch “Dưới Một Chiếc Ô”."
	var nl := Ui.label(note, 18, Ui.TEXT_SOFT)
	nl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	nl.custom_minimum_size = Vector2(560, 0)
	v.add_child(nl)
	var close := Ui.button("Quay lại", 200, 20)
	close.pressed.connect(func() -> void: p.visible = false)
	v.add_child(close)
	return p


func _panel(title_text: String) -> Array:
	var p := PanelContainer.new()
	var st := Ui.box(Ui.CREAM, Ui.BORDER, 26, 4)
	st.content_margin_left = 34
	st.content_margin_right = 34
	st.content_margin_top = 22
	st.content_margin_bottom = 22
	p.add_theme_stylebox_override("panel", st)
	p.position = Vector2(170, 50)
	p.custom_minimum_size = Vector2(940, 620)
	p.visible = false
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	p.add_child(v)
	v.add_child(Ui.label(title_text, 38, Ui.TEXT, Ui.font_title))
	var sc := ScrollContainer.new()
	sc.custom_minimum_size = Vector2(870, 470)
	sc.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(sc)
	var close := Ui.button("Đóng", 200)
	close.pressed.connect(func() -> void: p.visible = false)
	v.add_child(close)
	return [p, sc]


func _build_gallery() -> PanelContainer:
	var parts := _panel("Kỷ niệm — Kết thúc & Ảnh sự kiện")
	var list := VBoxContainer.new()
	list.add_theme_constant_override("separation", 12)
	list.custom_minimum_size = Vector2(850, 0)
	(parts[1] as ScrollContainer).add_child(list)
	# --- ảnh sự kiện (Event CG)
	var cgs := DialogueData.load_json(DialogueData.CG_PATH)
	list.add_child(Ui.label("Ảnh sự kiện  (%d/%d)" % [GameState.unlocked_cgs.size(), cgs.size()], 28, Ui.TEXT, Ui.font_title))
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	list.add_child(grid)
	for id in cgs:
		var info: Dictionary = cgs[id]
		var got := GameState.unlocked_cgs.has(id)
		var b := Button.new()
		b.custom_minimum_size = Vector2(270, 168)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_stylebox_override("normal", Ui.box(Color("fffdf8"), Ui.PINK if got else Color("d8c8b4"), 12, 2, false))
		b.add_theme_stylebox_override("hover", Ui.box(Color("fff1f4"), Ui.PINK, 12, 3, false))
		var vb := VBoxContainer.new()
		vb.set_anchors_preset(Control.PRESET_FULL_RECT)
		vb.mouse_filter = Control.MOUSE_FILTER_IGNORE
		b.add_child(vb)
		var tr := TextureRect.new()
		tr.texture = load("res://assets/art/cg/%s.jpg" % str(info.get("img", id)))
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		tr.custom_minimum_size = Vector2(250, 118)
		tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if not got:
			tr.modulate = Color(0.12, 0.1, 0.14)
		vb.add_child(tr)
		var cap := Ui.label(str(info.get("title", "")) if got else "??? — Tập %d" % int(info.get("episode", 1)), 16, Ui.TEXT if got else Ui.TEXT_SOFT, Ui.font_bold)
		cap.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cap.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cap.custom_minimum_size = Vector2(250, 0)
		vb.add_child(cap)
		if got:
			var tex := tr.texture
			b.pressed.connect(func() -> void: _view_cg(tex))
		else:
			b.disabled = true
		grid.add_child(b)
	# --- các kết thúc, theo tập
	var endings := DialogueData.load_json(DialogueData.ENDINGS_PATH)
	var last_ep := 0
	for id in endings:
		var e: Dictionary = endings[id]
		var ep := int(e.get("episode", 1))
		if ep != last_ep:
			last_ep = ep
			list.add_child(Ui.label("Kết thúc Tập %d" % ep, 28, Ui.TEXT, Ui.font_title))
		var got := GameState.unlocked_endings.has(id)
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", Ui.box(Color("fffdf8") if got else Color("efe5d8"), Ui.PINK if got else Color("d8c8b4"), 16, 2, false))
		list.add_child(card)
		var v := VBoxContainer.new()
		card.add_child(v)
		var t := Ui.label(str(e.get("title", id)) if got else "??? (Chưa mở khóa)", 26, Ui.PINK if got else Ui.TEXT_SOFT, Ui.font_title)
		v.add_child(t)
		var rank := Ui.label(str(e.get("rank", "")), 18, Ui.TEXT_SOFT, Ui.font_bold)
		v.add_child(rank)
		var d := Ui.label(str(e.get("text", "")) if got else "Gợi ý: " + str(e.get("hint", "")), 20, Ui.TEXT)
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		d.custom_minimum_size = Vector2(800, 0)
		v.add_child(d)
	return parts[0]


## Xem CG toàn màn hình, chạm để đóng.
func _view_cg(tex: Texture2D) -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var tr := TextureRect.new()
	tr.texture = tex
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg.add_child(tr)
	bg.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed:
			bg.queue_free())


func _build_credits() -> PanelContainer:
	var parts := _panel("Ghi công")
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.custom_minimum_size = Vector2(850, 0)
	r.add_theme_font_size_override("normal_font_size", 20)
	r.add_theme_font_size_override("bold_font_size", 20)
	r.text = "\n".join([
		"[b]Ý tưởng, kịch bản & thiết kế nhân vật:[/b] tác giả game (bạn!)",
		"[b]Lập trình & dựng game:[/b] cùng Claude (Anthropic) trên Godot Engine 4.7 (MIT)",
		"",
		"[b]Nhạc nền (CC0, OpenGameArt.org):[/b] First Light Particles, Starfield Romance — Yoiyami · Wooden Inn — Indieteur · "
		+ "Etirwer — Kistol · Chill Lofi Inspired — omfgdude · Chill (Loopable), chill guitar — Pro Sensory (Alex McCulloch) · "
		+ "Softpiano20 — Tozan · JRPG Piano — Joth",
		"[b]Âm thanh (CC0):[/b] Interface Sounds — Kenney.nl · Cat Purr & Meow — Kerzoven · Meow — IgnasD · Kitten Mew — antumdeluge · "
		+ "Doorbell — frosty ham · Pleasing Bell — Spring Spring · Heartbeat — bart · Rain (loopable) — Ylmir · Rain on Window — alxl",
		"[b]Phông chữ (SIL OFL):[/b] Baloo 2 — Ek Type · Nunito — Vernon Adams · JetBrains Mono — JetBrains",
		"",
		"Danh sách đầy đủ kèm đường dẫn: docs/CREDITS.md",
	])
	(parts[1] as ScrollContainer).add_child(r)
	return parts[0]
