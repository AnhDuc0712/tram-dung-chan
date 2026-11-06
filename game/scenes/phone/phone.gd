extends Control
## Màn hình điện thoại cuối tập: tin nhắn hiện dần, người chơi chọn sticker / câu trả lời.
## Dữ liệu: data/phone/<id>.json (xem docs/DIALOGUE_FORMAT.md, mục "Điện thoại").

const Steps := preload("res://scripts/story_steps.gd")
const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const PHONE_DIR := "res://data/phone/"


class Doodle extends Control:
	## Ảnh "chụp lén" trong tin nhắn: hình vẽ chibi / con rùa.
	var kind := "chibi"
	var tex_a: Texture2D
	var tex_b: Texture2D

	func _draw() -> void:
		var r := Rect2(Vector2.ZERO, size)
		draw_rect(r, Color("fffdf5"))
		for i in range(1, 9):
			var y := size.y * i / 9.0
			draw_line(Vector2(6, y), Vector2(size.x - 6, y), Color("cfe0f0"), 1.0)
		draw_rect(r, Color("d8c8b4"), false, 2.0)
		var ink := Color("4a3a8a")
		if kind == "chibi":
			var c := size * 0.5
			draw_arc(c, size.y * 0.33, 0, TAU, 40, ink, 2.0)
			for k in 3:
				var a := -0.6 + k * 0.25
				draw_line(c + Vector2(cos(a), sin(a)) * size.y * 0.33, c + Vector2(cos(a - 0.15), sin(a - 0.15)) * size.y * 0.33 + Vector2(-6, 4), ink, 2.0)
			if tex_a:
				draw_texture_rect(tex_a, Rect2(c + Vector2(-size.y * 0.42, -size.y * 0.3), Vector2(64, 64)), false)
			if tex_b:
				draw_texture_rect(tex_b, Rect2(c + Vector2(size.y * 0.1, size.y * 0.0), Vector2(64, 64)), false)
			draw_string(Ui.font_bold, Vector2(10, size.y - 10), "i = 1, 2, 3 ... chạy thôi!", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)
		else:
			var c2 := size * 0.5 + Vector2(0, 8)
			draw_set_transform(c2, 0.0, Vector2(1.0, 0.7))
			draw_circle(Vector2.ZERO, 44, Color("a8d5a0"))
			draw_arc(Vector2.ZERO, 44, 0, TAU, 32, ink, 2.0)
			draw_set_transform(Vector2.ZERO)
			draw_circle(c2 + Vector2(56, -10), 15, Color("a8d5a0"))
			draw_circle(c2 + Vector2(60, -14), 3, ink)
			draw_arc(c2 + Vector2(58, -4), 5, 0.2, PI - 0.2, 8, ink, 2.0)
			for a in [-2.5, -0.6, 0.6, 2.5]:
				draw_circle(c2 + Vector2(cos(a) * 44, sin(a) * 30 + 6), 9, Color("a8d5a0"))
			draw_string(Ui.font_bold, Vector2(10, 24), "Rùa con đã hết khóc rồi :)", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, ink)


var data: Dictionary = {}
var _phone_id := "ep1"
var _thread_i := 0
var _scroll: ScrollContainer
var _list: VBoxContainer
var _title: Label
var _subtitle: Label
var _avatar: TextureRect
var _typing: Label
var _choices: VBoxContainer
var _members: Dictionary = {}
var _skip := false


func _ready() -> void:
	Hud.set_visible_hud(false)
	Audio.ambient("rain_loop")
	Audio.music("phone")
	var a := Steps.arg(Story.current_step)
	if a != "":
		_phone_id = a
	data = DialogueData.load_json(PHONE_DIR + _phone_id + ".json")
	_build()
	_run()


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/street_rain.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.35, 0.32, 0.42)
	add_child(bg)
	var hint := Ui.label("Tối hôm đó, điện thoại của Anh Đức rung lên…", 26, Color("f3e6d3"), Ui.font_italic)
	hint.position = Vector2(40, 60)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.custom_minimum_size = Vector2(340, 0)
	add_child(hint)

	var frame := PanelContainer.new()
	var fs := Ui.box(Color("1d1b22"), Color("3a3640"), 46, 6)
	fs.content_margin_left = 14
	fs.content_margin_right = 14
	fs.content_margin_top = 18
	fs.content_margin_bottom = 18
	frame.add_theme_stylebox_override("panel", fs)
	frame.position = Vector2(420, 12)
	frame.custom_minimum_size = Vector2(440, 696)
	add_child(frame)
	var screen := PanelContainer.new()
	var ss := Ui.box(Color("fdf6f8"), Color(0, 0, 0, 0), 32, 0, false)
	ss.content_margin_left = 0
	ss.content_margin_right = 0
	ss.content_margin_top = 0
	ss.content_margin_bottom = 0
	screen.add_theme_stylebox_override("panel", ss)
	screen.clip_contents = true
	frame.add_child(screen)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 0)
	screen.add_child(v)

	var header := PanelContainer.new()
	var hs := Ui.box(Color("f7d3df"), Color(0, 0, 0, 0), 0, 0, false)
	hs.content_margin_left = 14
	hs.content_margin_top = 8
	hs.content_margin_bottom = 8
	header.add_theme_stylebox_override("panel", hs)
	v.add_child(header)
	var hh := HBoxContainer.new()
	hh.add_theme_constant_override("separation", 10)
	header.add_child(hh)
	_avatar = _make_avatar(null, 46)
	hh.add_child(_avatar.get_parent())
	var tv := VBoxContainer.new()
	tv.add_theme_constant_override("separation", -4)
	hh.add_child(tv)
	_title = Ui.label("", 22, Ui.TEXT, Ui.font_title)
	tv.add_child(_title)
	_subtitle = Ui.label("", 17, Ui.TEXT_SOFT)
	tv.add_child(_subtitle)

	_scroll = ScrollContainer.new()
	_scroll.custom_minimum_size = Vector2(400, 470)
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(_scroll)
	var pad := MarginContainer.new()
	pad.add_theme_constant_override("margin_left", 10)
	pad.add_theme_constant_override("margin_right", 10)
	pad.add_theme_constant_override("margin_top", 10)
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scroll.add_child(pad)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 8)
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.add_child(_list)

	_typing = Ui.label("", 17, Ui.TEXT_SOFT, Ui.font_italic)
	_typing.custom_minimum_size = Vector2(0, 22)
	var tpad := MarginContainer.new()
	tpad.add_theme_constant_override("margin_left", 14)
	tpad.add_child(_typing)
	v.add_child(tpad)
	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override("separation", 6)
	var cpad := MarginContainer.new()
	cpad.add_theme_constant_override("margin_left", 10)
	cpad.add_theme_constant_override("margin_right", 10)
	cpad.add_theme_constant_override("margin_bottom", 10)
	cpad.add_child(_choices)
	v.add_child(cpad)

	var tip := Ui.label("Chạm (hoặc giữ Ctrl) để tin nhắn hiện nhanh hơn", 18, Color(1, 1, 1, 0.5))
	tip.position = Vector2(890, 680)
	add_child(tip)


func _make_avatar(tex: Texture2D, s: float) -> TextureRect:
	var holder := Panel.new()
	holder.custom_minimum_size = Vector2(s, s)
	holder.add_theme_stylebox_override("panel", Ui.box(Color("ffffff"), Color("e3b3c2"), int(s / 2), 2, false))
	holder.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	var tr := TextureRect.new()
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.set_anchors_preset(Control.PRESET_FULL_RECT)
	holder.add_child(tr)
	return tr


func _unhandled_input(ev: InputEvent) -> void:
	if (ev is InputEventMouseButton and ev.pressed) or ev.is_action_pressed("interact"):
		_skip = true


func _wait(sec: float) -> void:
	if GameState.autoplay:
		sec = 0.05
	var t := 0.0
	while t < sec:
		if _skip or Input.is_action_pressed("skip"):
			break
		await get_tree().process_frame
		t += get_process_delta_time()
	_skip = false


func _run() -> void:
	var threads: Array = data.get("threads", [])
	for ti in threads.size():
		var th: Dictionary = threads[ti]
		_open_thread(th)
		await _wait(0.6)
		await _play_messages(th.get("messages", []))
		await _wait(0.8)
		if ti < threads.size() - 1:
			var nxt: Dictionary = threads[ti + 1]
			_typing.text = ""
			var b := Ui.button("Tin nhắn mới: " + str(nxt.get("title", "")), 400, 19)
			_choices.add_child(b)
			Audio.sfx("msg")
			if GameState.autoplay:
				b.pressed.emit.call_deferred()
			await b.pressed
			_clear_choices()
	var end_b := Ui.button(str(data.get("end_button", "Tắt điện thoại, đi ngủ")), 400, 20)
	_choices.add_child(end_b)
	if GameState.autoplay:
		print("[autoplay] điện thoại xong")
		end_b.pressed.emit.call_deferred()
	await end_b.pressed
	Story.phone_done(_phone_id)


func _open_thread(th: Dictionary) -> void:
	for c in _list.get_children():
		c.queue_free()
	_clear_choices()
	_title.text = str(th.get("title", ""))
	_subtitle.text = str(th.get("subtitle", ""))
	_members = th.get("members", {})
	var first := ""
	for k in _members:
		first = str(_members[k])
		break
	_avatar.texture = Ui.head_tex(first) if first != "" else null


func _play_messages(msgs: Array) -> void:
	for m in msgs:
		var msg: Dictionary = m
		if not GameState.check(msg.get("if", {})):
			continue
		var ends: Array = msg.get("if_ending", [])
		if not ends.is_empty() and not ends.has(GameState.ending_id):
			continue
		if msg.has("choices"):
			var picked: Dictionary = await _ask(msg["choices"])
			GameState.apply(picked.get("effects", {}))
			_add_bubble("me", str(picked.get("text", "")), str(picked.get("sticker", "")))
			Audio.sfx("pop")
			await _play_messages(picked.get("reply", []))
			continue
		var who := str(msg.get("from", ""))
		var text := str(msg.get("text", ""))
		_typing.text = "%s đang soạn tin…" % Dialogue.character_name(who)
		await _wait(clampf(0.5 + text.length() * 0.025, 0.6, 2.0))
		_typing.text = ""
		_add_bubble(who, text, str(msg.get("image", "")))
		Audio.sfx("msg", -8.0)
		await _wait(0.35)


func _ask(choices: Array) -> Dictionary:
	_clear_choices()
	var picked := {}
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	_choices.add_child(row)
	var holder := {"done": false, "pick": {}}
	for c in choices:
		var ch: Dictionary = c
		var b := Button.new()
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(124, 132 if ch.has("sticker") else 76)
		b.add_theme_stylebox_override("normal", Ui.box(Color("ffffff"), Color("e3b3c2"), 14, 2, false))
		b.add_theme_stylebox_override("hover", Ui.box(Color("fff1f4"), Ui.PINK, 14, 2, false))
		b.add_theme_stylebox_override("pressed", Ui.box(Ui.PINK_SOFT, Ui.PINK, 14, 2, false))
		var bv := VBoxContainer.new()
		bv.set_anchors_preset(Control.PRESET_FULL_RECT)
		bv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bv.alignment = BoxContainer.ALIGNMENT_CENTER
		b.add_child(bv)
		if ch.has("sticker"):
			var st := TextureRect.new()
			st.texture = Ui.char_tex(str(ch["sticker"]))
			st.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			st.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			st.custom_minimum_size = Vector2(110, 58)
			st.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bv.add_child(st)
		var l := Ui.label(str(ch.get("text", "")), 16, Ui.TEXT, Ui.font_bold)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.custom_minimum_size = Vector2(112, 0)
		l.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bv.add_child(l)
		b.pressed.connect(func() -> void:
			Audio.sfx("click")
			holder["pick"] = ch
			holder["done"] = true)
		row.add_child(b)
	if GameState.autoplay:
		holder["pick"] = choices[0]
		holder["done"] = true
	while not holder["done"]:
		await get_tree().process_frame
	picked = holder["pick"]
	_clear_choices()
	return picked


func _clear_choices() -> void:
	for c in _choices.get_children():
		c.queue_free()


func _add_bubble(who: String, text: String, image: String) -> void:
	var me := who == "me"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.alignment = BoxContainer.ALIGNMENT_END if me else BoxContainer.ALIGNMENT_BEGIN
	_list.add_child(row)
	if not me:
		var av := _make_avatar(Ui.head_tex(str(_members.get(who, "kyky_hug"))), 34)
		row.add_child(av.get_parent())
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	row.add_child(col)
	if not me and _members.size() > 1:
		col.add_child(Ui.label(Dialogue.character_name(who), 15, Ui.TEXT_SOFT, Ui.font_bold))
	if image != "":
		col.add_child(_make_image(image))
	if text != "":
		var bub := PanelContainer.new()
		var bs := Ui.box(Ui.PINK if me else Color("ffffff"), Color(0, 0, 0, 0) if me else Color("eadde2"), 16, 1, false)
		bs.content_margin_left = 12
		bs.content_margin_right = 12
		bs.content_margin_top = 6
		bs.content_margin_bottom = 6
		bub.add_theme_stylebox_override("panel", bs)
		var l := Ui.label(text, 19, Color.WHITE if me else Ui.TEXT)
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var fnt: Font = Ui.font_body
		var w := minf(fnt.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 17).x + 4, 260)
		l.custom_minimum_size = Vector2(w, 0)
		bub.add_child(l)
		col.add_child(bub)
	row.modulate.a = 0.0
	create_tween().tween_property(row, "modulate:a", 1.0, 0.2)
	await get_tree().process_frame
	await get_tree().process_frame
	_scroll.scroll_vertical = int(_scroll.get_v_scroll_bar().max_value)


func _make_image(image: String) -> Control:
	if image == "chibi" or image == "turtle":
		var d := Doodle.new()
		d.kind = image
		d.custom_minimum_size = Vector2(230, 150)
		d.tex_a = Ui.head_tex("duc_front")
		d.tex_b = Ui.head_tex("kyky_hug")
		return d
	var tr := TextureRect.new()
	tr.texture = Ui.char_tex("cat_sit" if image == "nlong" else image)
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tr.custom_minimum_size = Vector2(150, 150)
	return tr
