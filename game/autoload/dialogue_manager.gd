extends CanvasLayer
## Hộp thoại + sân khấu visual novel (nền, nhân vật, hiệu ứng). Autoload "Dialogue".
##   Dialogue.start("ep1_s1")
## Định dạng file kịch bản: docs/DIALOGUE_FORMAT.md
## Logic chạy node nằm ở scripts/dialogue/dialogue_runner.gd (test được không cần UI).

signal dialogue_started(id: String)
signal dialogue_finished(id: String, then_step: String)
signal event(ev_name: String)

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const DialogueRunner := preload("res://scripts/dialogue/dialogue_runner.gd")
const Actor := preload("res://scripts/vn/actor.gd")
const Rain := preload("res://scripts/vn/rain.gd")
const Umbrella := preload("res://scripts/vn/umbrella.gd")

const CHAR_PATH := "res://data/characters.json"
const BG_DIR := "res://assets/art/bg/"
const SLOTS := {"farleft": 190.0, "left": 360.0, "center": 640.0, "right": 920.0, "farright": 1090.0}
const ACTOR_SCALE := 1.2
const BASELINE := 905.0
const MAX_HISTORY := 120

var characters: Dictionary = {}
var history: Array = []  # [{name, text}]

var _runner = null
var _id := ""
var _token := 0
var _autoclicks := 0  # chỉ để chụp màn hình tự động (tools\screenshot.ps1 -Clicks N)
var _autoclick_t := 0
var _typing := false
var _shown := 0.0
var _wait_input := false
var _choice_time := 0.0
var _choice_left := 0.0
var _auto_timer := 0.0

var _root: Control
var _bg: TextureRect
var _bg_key := ""
var _stage: Node2D
var _actors: Dictionary = {}  # id -> Actor
var _umbrella: Node2D
var _rain: Control
var _flash: ColorRect
var _box: PanelContainer
var _name_plate: PanelContainer
var _name_label: Label
var _text: RichTextLabel
var _next_hint: Control
var _choice_box: VBoxContainer
var _timer_bar: ProgressBar
var _skip_btn: Button
var _cg: TextureRect  # Event CG toàn màn hình (khóa "cg" trong kịch bản)
var _cg_id := ""
var _cg_tw: Tween
var _cgs: Dictionary = {}
var _tick_at := 0  # tiếng lách cách khi chữ chạy
var _skip_on := false  # nút "Tua" (thay cho giữ Ctrl trên điện thoại)


func _ready() -> void:
	layer = 10
	characters = DialogueData.load_json(CHAR_PATH)
	_build_ui()
	GameState.var_changed.connect(_on_heart_changed)
	_hide_box()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--autoclick="):
			_autoclicks = int(a.substr(12))
	if GameState.autoplay:
		_autoclicks = 1000000



func _physics_process(_delta: float) -> void:
	if _autoclicks <= 0 or not is_active():
		return
	_autoclick_t += 1
	if _autoclick_t % 25 != 0 or not _box.visible or _typing:
		return
	_autoclicks -= 1
	if _choice_box.get_child_count() > 0:
		_on_choice(0)
	else:
		_advance()


# ======================================================================= API
func start(id: String) -> void:
	var data := DialogueData.load_dialogue(id)
	if data.is_empty():
		return
	_id = id
	_set_skip(false)
	_runner = DialogueRunner.new(data, GameState)
	_runner.begin()
	dialogue_started.emit(id)
	_show_current()


func _set_skip(on: bool) -> void:
	_skip_on = on
	_skip_btn.set_pressed_no_signal(on)


func is_active() -> bool:
	return _runner != null and not _runner.finished


## Xoá nền + nhân vật + hiệu ứng (Story gọi khi chuyển cảnh).
func clear_stage() -> void:
	for id in _actors.keys():
		(_actors[id] as Node).queue_free()
	_actors.clear()
	_bg.texture = null
	_bg.modulate.a = 0.0
	_bg_key = ""
	_rain.visible = false
	_umbrella.visible = false
	_hide_cg(true)
	_hide_box()


# ---------------------------------------------------------------- Event CG
## Ảnh sự kiện toàn màn hình, máy quay lia chậm (Ken Burns). Lần đầu xem -> mở khoá trong mục Kỷ niệm.
func _show_cg(id: String) -> void:
	if id == "none" or id == "":
		_hide_cg(false)
		return
	if _cgs.is_empty():
		_cgs = DialogueData.load_json(DialogueData.CG_PATH)
	var info: Dictionary = _cgs.get(id, {})
	var path := "res://assets/art/cg/%s.jpg" % str(info.get("img", id))
	if not ResourceLoader.exists(path):
		push_warning("Thiếu ảnh CG: " + path)
		return
	if id == _cg_id and _cg.visible:
		return
	_cg_id = id
	_cg.texture = load(path)
	_cg.visible = true
	_cg.modulate.a = 0.0
	_cg.scale = Vector2.ONE * 1.02
	_cg.position = Vector2(-14, 0)
	if _cg_tw:
		_cg_tw.kill()
	_cg_tw = create_tween().set_parallel()
	_cg_tw.tween_property(_cg, "modulate:a", 1.0, 0.7)
	_cg_tw.tween_property(_cg, "scale", Vector2.ONE * 1.1, 16.0).set_trans(Tween.TRANS_SINE)
	_cg_tw.tween_property(_cg, "position:x", 14.0, 16.0).set_trans(Tween.TRANS_SINE)
	Audio.sfx("sparkle", -10.0)
	if not GameState.unlocked_cgs.has(id):
		GameState.unlock_cg(id)
		Hud.toast("Mở khoá ảnh kỷ niệm: " + str(info.get("title", id)))


func _hide_cg(instant: bool) -> void:
	_cg_id = ""
	if _cg_tw:
		_cg_tw.kill()
	if instant or not _cg.visible:
		_cg.visible = false
		return
	_cg_tw = create_tween()
	_cg_tw.tween_property(_cg, "modulate:a", 0.0, 0.5)
	_cg_tw.tween_callback(func() -> void: _cg.visible = false)


func character_name(id: String) -> String:
	var c: Dictionary = characters.get(id, {})
	return str(c.get("name", id))


# ======================================================================= dựng UI
func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = Ui.theme
	add_child(_root)

	_bg = TextureRect.new()
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bg.modulate.a = 0.0
	_root.add_child(_bg)

	_stage = Node2D.new()
	_root.add_child(_stage)
	_umbrella = Umbrella.new()
	_umbrella.position = Vector2(700, 150)
	_umbrella.visible = false
	_umbrella.z_index = 0
	_stage.add_child(_umbrella)

	_rain = Rain.new()
	_rain.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rain.visible = false
	_root.add_child(_rain)

	_cg = TextureRect.new()
	_cg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_cg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_cg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cg.pivot_offset = Vector2(640, 360)
	_cg.visible = false
	_root.add_child(_cg)

	_flash = ColorRect.new()
	_flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color.WHITE
	_flash.modulate.a = 0.0
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_flash)

	_box = PanelContainer.new()
	_box.position = Vector2(70, 522)
	_box.size = Vector2(1140, 180)
	var st := Ui.box(Color(1.0, 0.973, 0.933, 0.96), Ui.BORDER, 24, 3)
	st.content_margin_left = 40
	st.content_margin_right = 40
	st.content_margin_top = 30
	st.content_margin_bottom = 18
	_box.add_theme_stylebox_override("panel", st)
	_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_box)
	_text = RichTextLabel.new()
	_text.bbcode_enabled = true
	_text.fit_content = false
	_text.scroll_active = false
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.add_theme_font_size_override("normal_font_size", 27)
	_text.add_theme_font_size_override("italics_font_size", 27)
	_text.add_theme_font_size_override("bold_font_size", 27)
	_text.add_theme_constant_override("line_separation", 6)
	_text.add_theme_color_override("default_color", Ui.TEXT)
	_text.add_theme_font_override("normal_font", Ui.font_body)
	_text.add_theme_font_override("italics_font", Ui.font_italic)
	_text.add_theme_font_override("bold_font", Ui.font_bold)
	_box.add_child(_text)

	_name_plate = PanelContainer.new()
	_name_plate.position = Vector2(110, 494)
	var ns := Ui.box(Color("fff4ea"), Color("e3b3c2"), 16, 3)
	ns.content_margin_left = 34
	ns.content_margin_right = 34
	ns.content_margin_top = 0
	ns.content_margin_bottom = 0
	_name_plate.add_theme_stylebox_override("panel", ns)
	_name_plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_name_plate)
	_name_label = Ui.label("", 30, Color("6b3a2a"), Ui.font_title)
	_name_plate.add_child(_name_label)

	_skip_btn = Ui.button("Tua »", 128, 21)
	_skip_btn.toggle_mode = true
	_skip_btn.custom_minimum_size = Vector2(128, 50)
	_skip_btn.position = Vector2(1062, 474)
	_skip_btn.tooltip_text = "Tua nhanh hội thoại (hoặc giữ Ctrl)"
	_skip_btn.toggled.connect(func(on: bool) -> void: _skip_on = on)
	_skip_btn.visible = false
	_root.add_child(_skip_btn)

	_next_hint = Control.new()
	_next_hint.position = Vector2(1120, 668)
	_next_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_next_hint)
	var nl := Ui.label("tiếp", 22, Ui.PINK, Ui.font_bold)
	nl.position = Vector2(-50, -18)
	_next_hint.add_child(nl)
	var tri := Polygon2D.new()
	tri.polygon = PackedVector2Array([Vector2(0, -10), Vector2(16, 0), Vector2(0, 10)])
	tri.color = Ui.PINK
	tri.position = Vector2(8, -2)
	_next_hint.add_child(tri)

	_timer_bar = ProgressBar.new()
	_timer_bar.position = Vector2(390, 168)
	_timer_bar.size = Vector2(500, 14)
	_timer_bar.show_percentage = false
	_timer_bar.max_value = 1.0
	_timer_bar.step = 0.0
	_timer_bar.visible = false
	_root.add_child(_timer_bar)

	_choice_box = VBoxContainer.new()
	_choice_box.position = Vector2(290, 196)
	_choice_box.size = Vector2(700, 300)
	_choice_box.alignment = BoxContainer.ALIGNMENT_CENTER
	_choice_box.add_theme_constant_override("separation", 14)
	_root.add_child(_choice_box)


func _hide_box() -> void:
	_box.visible = false
	_skip_btn.visible = false
	_name_plate.visible = false
	_next_hint.visible = false
	_timer_bar.visible = false
	_clear_choices()


func _clear_choices() -> void:
	for c in _choice_box.get_children():
		c.queue_free()
	_timer_bar.visible = false
	_choice_time = 0.0


# ======================================================================= chạy node
func _show_current() -> void:
	_token += 1
	var my := _token
	_clear_choices()
	if _runner == null:
		return
	if _runner.finished:
		_finish()
		return
	var n: Dictionary = _runner.current
	_wait_input = false
	if n.has("card"):
		_hide_box()
		if n.has("hide"):
			_apply_hide(n)
		var card_tw: Tween = Story.show_card(str(n["card"]), float(n.get("card_hold", 1.6)))
		# đổi nền/nhạc ngay sau khi thẻ chữ che màn hình
		await get_tree().create_timer(0.4).timeout
		if my != _token:
			return
		if n.has("bg"):
			_set_bg(str(n["bg"]))
		if n.has("music"):
			Audio.music(str(n["music"]))
		await card_tw.finished
		if my != _token:
			return
	_apply_stage(n)
	if not n.has("text"):
		var w := float(n.get("wait", 0.0))
		if w > 0.0:
			_hide_box()
			await get_tree().create_timer(w).timeout
			if my != _token:
				return
		_runner.advance()
		_show_current()
		return
	_show_text(n)


func _apply_stage(n: Dictionary) -> void:
	if n.has("bg"):
		_set_bg(str(n["bg"]))
	if n.has("music"):
		Audio.music(str(n["music"]))
	if n.has("ambient"):
		Audio.ambient(str(n["ambient"]))
	if n.has("sfx"):
		Audio.sfx(str(n["sfx"]))
	_apply_hide(n)
	if n.has("cg"):
		_show_cg(str(n["cg"]))
	var show_d: Dictionary = n.get("show", {})
	# ô biểu cảm chỉ hiện trong câu thoại đặt biểu cảm đó
	for id in _actors:
		if not show_d.has(id):
			_actors[id].set_inset(null, false)
	for id in show_d:
		_show_actor(str(id), show_d[id])
	var emo: Dictionary = n.get("emote", {})
	for id in emo:
		if _actors.has(id):
			_actors[id].set_emote(str(emo[id]))
	var anim: Dictionary = n.get("anim", {})
	for id in anim:
		if _actors.has(id):
			_actors[id].animate(str(anim[id]))
	var fx = n.get("fx", [])
	if fx is String:
		fx = [fx]
	for f in fx:
		_do_fx(str(f))
	if n.has("event"):
		event.emit(str(n["event"]))


func _apply_hide(n: Dictionary) -> void:
	var hide_v = n.get("hide", [])
	if hide_v is String and hide_v == "all":
		hide_v = _actors.keys()
	for id in hide_v:
		if _actors.has(id):
			(_actors[id] as Node).call("leave")
			_actors.erase(id)


func _set_bg(key: String) -> void:
	if key == _bg_key:
		return
	_bg_key = key
	if key == "none" or key == "":
		create_tween().tween_property(_bg, "modulate:a", 0.0, 0.4)
		return
	var path := BG_DIR + key + ".jpg"
	if not ResourceLoader.exists(path):
		push_warning("Thiếu ảnh nền " + path)
		return
	var tex: Texture2D = load(path)
	if _bg.modulate.a < 0.05:
		_bg.texture = tex
		create_tween().tween_property(_bg, "modulate:a", 1.0, 0.5)
	else:
		var tw := create_tween()
		tw.tween_property(_bg, "modulate:a", 0.0, 0.25)
		tw.tween_callback(func() -> void: _bg.texture = tex)
		tw.tween_property(_bg, "modulate:a", 1.0, 0.35)


func _parse_show(v) -> Dictionary:
	var out := {"pose": "normal", "at": "", "flip": null}
	if v is String:
		var parts: PackedStringArray = (v as String).split("@")
		out["pose"] = parts[0] if parts[0] != "" else "normal"
		if parts.size() > 1:
			out["at"] = parts[1]
	elif v is Dictionary:
		out["pose"] = str(v.get("pose", "normal"))
		out["at"] = str(v.get("at", ""))
		if v.has("flip"):
			out["flip"] = bool(v["flip"])
	return out


func _slot_x(at: String) -> float:
	if SLOTS.has(at):
		return SLOTS[at]
	if at.is_valid_float():
		return float(at)
	return SLOTS["center"]


## Vị trí theo ô; Anh Đức & KyKy đứng hai bên thì xích lại gần nhau khi Rung động tăng.
func _x_for(id: String, at: String) -> float:
	var x := _slot_x(at)
	if id in ["duc", "kyky"] and at in ["left", "right", "farleft", "farright"]:
		var close := clampf(float(GameState.get_var("heart")) / float(GameState.bar_max("heart")), 0.0, 1.0)
		x += signf(640.0 - x) * close * 80.0
	return x


func _on_heart_changed(var_name: String, _value: int) -> void:
	if var_name != "heart":
		return
	for id in ["duc", "kyky"]:
		if _actors.has(id) and is_instance_valid(_actors[id]):
			var a: Node2D = _actors[id]
			var slot := str(a.get_meta("slot", ""))
			if slot in ["left", "right", "farleft", "farright"]:
				a.call("move_to", _x_for(id, slot))


func _show_actor(id: String, v) -> void:
	var c: Dictionary = characters.get(id, {})
	if c.is_empty():
		push_warning("Nhân vật chưa khai báo: " + id)
		return
	var s := _parse_show(v)
	var poses: Dictionary = c.get("poses", {})
	var pose: Dictionary = poses.get(s["pose"], poses.get("normal", {}))
	var tex := Ui.char_tex(str(pose.get("img", "")))
	var x_target: float = _x_for(id, s["at"]) if s["at"] != "" else (_actors[id].position.x if _actors.has(id) else 640.0)
	var faces := str(pose.get("faces", ""))
	var auto_flip := (faces == "right" and x_target > 640.0) or (faces == "left" and x_target < 640.0)
	var flip: bool = (bool(pose["flip"]) if pose.has("flip") else auto_flip) if s["flip"] == null else bool(s["flip"])
	var face_arr: Array = pose.get("face", c.get("face", [0.5, 0.2]))
	var face := Vector2(float(face_arr[0]), float(face_arr[1]))
	var sc := ACTOR_SCALE * float(c.get("scale", 1.0)) * float(pose.get("scale", 1.0))
	var a
	var is_new := not _actors.has(id)
	if is_new:
		a = Actor.new()
		a.setup(id, sc)
		a.position = Vector2(_x_for(id, s["at"]), BASELINE + float(c.get("baseline", 0.0)))
		_stage.add_child(a)
		_actors[id] = a
	else:
		a = _actors[id]
		a.scale = Vector2.ONE * sc
	a.set_pose(tex, flip, str(pose.get("emote", "")), face)
	var inset_name := str(pose.get("inset", ""))
	a.set_inset(Ui.char_tex(inset_name) if inset_name != "" else null, a.position.x < 640.0)
	if s["at"] != "":
		a.set_meta("slot", s["at"])
	if is_new:
		var x := _x_for(id, s["at"])
		a.enter_from(x + (60.0 if x > 640.0 else -60.0), x)
	elif s["at"] != "":
		a.move_to(_x_for(id, s["at"]))
	if pose.has("anim"):
		a.animate(str(pose["anim"]))


func _do_fx(f: String) -> void:
	match f:
		"shake":
			var tw := create_tween()
			for i in 8:
				tw.tween_property(_root, "position", Vector2(randf_range(-10, 10), randf_range(-7, 7)), 0.035)
			tw.tween_property(_root, "position", Vector2.ZERO, 0.04)
		"flash":
			_flash.modulate.a = 0.85
			create_tween().tween_property(_flash, "modulate:a", 0.0, 0.45)
		"rain_on":
			_rain.visible = true
		"rain_off":
			_rain.visible = false
		"umbrella_on":
			_umbrella.visible = true
			_umbrella.modulate.a = 0.0
			create_tween().tween_property(_umbrella, "modulate:a", 1.0, 0.6)
		"umbrella_off":
			_umbrella.visible = false
		"dark":
			create_tween().tween_property(_bg, "self_modulate", Color(0.62, 0.58, 0.66), 0.6)
		"light":
			create_tween().tween_property(_bg, "self_modulate", Color.WHITE, 0.6)
		"zoom":
			for id in _actors:
				_actors[id].animate("lean")
		"unzoom":
			for id in _actors:
				_actors[id].animate("back")


func _show_text(n: Dictionary) -> void:
	var speaker := str(n.get("speaker", ""))
	var who := str(n.get("name", character_name(speaker) if speaker != "" else ""))
	var think := bool(n.get("think", false))
	var text := str(n["text"])
	if think:
		who = who + " (nghĩ)" if who != "" else ""
		text = "[i][color=#8a6a55](" + text + ")[/color][/i]"
	elif speaker == "" and not n.has("name"):
		text = "[i]" + text + "[/i]"
	_name_plate.visible = who != ""
	_name_label.text = who
	var col: String = str((characters.get(speaker, {}) as Dictionary).get("color", "#6b3a2a"))
	_name_label.add_theme_color_override("font_color", Color(col))
	for id in _actors:
		_actors[id].set_dim(speaker != "" and id != speaker and _actors.has(speaker))
	_box.visible = true
	_skip_btn.visible = true
	_text.text = text
	_text.visible_characters = 0
	_shown = 0.0
	_tick_at = 1
	_typing = true
	_next_hint.visible = false
	history.append({"name": who, "text": text})
	if history.size() > MAX_HISTORY:
		history.pop_front()
	if n.has("voice"):
		Audio.sfx(str(n["voice"]))


func _process(delta: float) -> void:
	if _runner == null or _runner.finished:
		return
	var skipping := (Input.is_action_pressed("skip") or _skip_on) and not get_tree().paused
	if _typing:
		var total := _text.get_total_character_count()
		var speed := float(GameState.settings.get("text_speed", 45.0))
		_shown += delta * (speed if not skipping else 2000.0)
		_text.visible_characters = int(_shown)
		if not skipping and int(_shown) >= _tick_at:
			_tick_at = int(_shown) + 3
			Audio.sfx("click", -24.0, randf_range(1.45, 1.75))
		if _shown >= total:
			_finish_typing()
	elif _wait_input and skipping and _choice_box.get_child_count() == 0:
		_auto_timer += delta
		if _auto_timer > 0.07:
			_auto_timer = 0.0
			_advance()
	if _choice_time > 0.0:
		_choice_left -= delta
		_timer_bar.value = maxf(_choice_left / _choice_time, 0.0)
		if _choice_left <= 0.0:
			_choice_time = 0.0
			var to := str(_runner.current.get("timeout", ""))
			Audio.sfx("bad")
			_clear_choices()
			_runner.goto(to)
			_show_current()


func _finish_typing() -> void:
	_typing = false
	_text.visible_characters = -1
	var cs: Array = _runner.choices()
	if cs.is_empty():
		_wait_input = true
		_next_hint.visible = true
		return
	_wait_input = false
	for i in cs.size():
		var c: Dictionary = cs[i]
		var b := Ui.button(str(c.get("text", "...")), 640, 24)
		b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		b.custom_minimum_size = Vector2(640, 58)
		var idx := i
		b.pressed.connect(func() -> void: _on_choice(idx))
		_choice_box.add_child(b)
		b.modulate.a = 0.0
		create_tween().tween_property(b, "modulate:a", 1.0, 0.2).set_delay(0.05 * i)
	var timer := float(_runner.current.get("timer", 0.0))
	if timer > 0.0:
		_choice_time = timer
		_choice_left = timer
		_timer_bar.visible = true
		_timer_bar.value = 1.0
		Audio.sfx("question")


func _on_choice(i: int) -> void:
	if _runner == null:
		return
	var cs: Array = _runner.choices()
	if i >= 0 and i < cs.size():
		var c: Dictionary = cs[i]
		history.append({"name": "»", "text": "[color=#e8608c]" + str(c.get("text", "")) + "[/color]"})
	_clear_choices()
	_runner.choose(i)
	_show_current()


func _advance() -> void:
	if _runner == null or _runner.finished:
		return
	if _typing:
		_finish_typing()
		return
	if not _wait_input:
		return
	_runner.advance()
	_show_current()


func _unhandled_input(ev: InputEvent) -> void:
	if not is_active():
		return
	var pressed := false
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		pressed = true
	elif ev.is_action_pressed("interact"):
		pressed = true
	if pressed:
		get_viewport().set_input_as_handled()
		if _choice_box.get_child_count() == 0:
			_advance()


func _finish() -> void:
	var then := ""
	if _runner:
		then = str(_runner.then_step)
	var id := _id
	_runner = null
	_set_skip(false)
	_hide_box()
	if then == "":
		# hội thoại trong map: cất nhân vật đi
		for a in _actors.keys():
			(_actors[a] as Node).call("leave")
		_actors.clear()
		_set_bg("none")
		_rain.visible = false
		_hide_cg(false)
	dialogue_finished.emit(id, then)
	if then != "":
		Story.goto(then)
