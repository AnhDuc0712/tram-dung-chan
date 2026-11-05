extends Control
## Mini-game "Tìm bug": mỗi vòng là một đoạn code của KyKy, bấm vào dòng bị sai.
## Đúng ngay lần đầu = +1 Hiểu bài. Dữ liệu: data/minigames/debug_ep1.json

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const DATA_PATH := "res://data/minigames/debug_ep1.json"

var rounds: Array = []
var idx := 0
var correct := 0
var _answered := false
var _code_box: VBoxContainer
var _bubble: Label
var _explain: Label
var _next: Button
var _title: Label
var _kyky: Sprite2D


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Bấm vào dòng code bị sai (bug) trong bài của KyKy.")
	Audio.music("study")
	rounds = DialogueData.load_json(DATA_PATH).get("rounds", [])
	_build()
	_show_round()
	if GameState.autoplay:
		for i in rounds.size():
			await get_tree().create_timer(0.4).timeout
			_pick(int(rounds[idx].get("bug", 0)))
			await get_tree().create_timer(0.2).timeout
			_on_next()


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_sunset.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.55, 0.5, 0.5)
	add_child(bg)

	var tex := Ui.char_tex("kyky_wave")
	if tex:
		_kyky = Sprite2D.new()
		_kyky.texture = tex
		_kyky.centered = false
		_kyky.scale = Vector2(0.95, 0.95)
		_kyky.offset = Vector2(-tex.get_width() * 0.5, -tex.get_height())
		_kyky.position = Vector2(1120, 760)
		add_child(_kyky)

	var editor := PanelContainer.new()
	var st := Ui.box(Color("2b2238"), Color("8f7aa8"), 18, 3)
	st.content_margin_left = 24
	st.content_margin_right = 24
	st.content_margin_top = 16
	st.content_margin_bottom = 16
	editor.add_theme_stylebox_override("panel", st)
	editor.position = Vector2(150, 196)
	editor.custom_minimum_size = Vector2(760, 330)
	add_child(editor)
	var ev := VBoxContainer.new()
	ev.add_theme_constant_override("separation", 6)
	editor.add_child(ev)
	_title = Ui.label("", 20, Color("c9b8e8"), Ui.font_mono)
	ev.add_child(_title)
	_code_box = VBoxContainer.new()
	_code_box.add_theme_constant_override("separation", 6)
	ev.add_child(_code_box)

	var bp := PanelContainer.new()
	bp.position = Vector2(300, 104)
	bp.custom_minimum_size = Vector2(610, 0)
	add_child(bp)
	_bubble = Ui.label("", 21, Ui.TEXT, Ui.font_bold)
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.custom_minimum_size = Vector2(570, 0)
	bp.add_child(_bubble)

	var xp := PanelContainer.new()
	xp.position = Vector2(150, 540)
	xp.custom_minimum_size = Vector2(760, 0)
	add_child(xp)
	var xv := VBoxContainer.new()
	xp.add_child(xv)
	_explain = Ui.label("", 21, Ui.TEXT)
	_explain.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_explain.custom_minimum_size = Vector2(720, 0)
	xv.add_child(_explain)
	_next = Ui.button("Tiếp", 200)
	_next.pressed.connect(_on_next)
	_next.visible = false
	xv.add_child(_next)


func _show_round() -> void:
	_answered = false
	_next.visible = false
	var r: Dictionary = rounds[idx]
	_title.text = "# bai_tap_kyky_%d.py   (vòng %d/%d)" % [idx + 1, idx + 1, rounds.size()]
	_bubble.text = "KyKy: “" + str(r.get("kyky", "")) + "”"
	_explain.text = "Anh Đức: Dòng nào sai nhỉ? Bấm vào dòng đó."
	_face("kyky_wave_think")
	for c in _code_box.get_children():
		c.queue_free()
	var lines: Array = r.get("lines", [])
	for i in lines.size():
		var b := Button.new()
		b.text = "%d   %s" % [i + 1, str(lines[i])]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.custom_minimum_size = Vector2(700, 46)
		b.add_theme_font_override("font", Ui.font_mono)
		b.add_theme_font_size_override("font_size", 22)
		b.add_theme_color_override("font_color", Color("f2eafc"))
		b.add_theme_color_override("font_hover_color", Color("ffd6e4"))
		b.add_theme_stylebox_override("normal", Ui.box(Color("362c46"), Color("362c46"), 8, 1, false))
		b.add_theme_stylebox_override("hover", Ui.box(Color("4a3c60"), Color("e8608c"), 8, 2, false))
		b.add_theme_stylebox_override("pressed", Ui.box(Color("4a3c60"), Color("e8608c"), 8, 2, false))
		var li := i
		b.pressed.connect(func() -> void: _pick(li))
		_code_box.add_child(b)


func _pick(i: int) -> void:
	if _answered:
		return
	_answered = true
	var r: Dictionary = rounds[idx]
	var bug := int(r.get("bug", 0))
	var btns := _code_box.get_children()
	var good_box := Ui.box(Color("2f6b4f"), Color("7be0a8"), 8, 2, false)
	var bad_box := Ui.box(Color("7a2f45"), Color("ff8fab"), 8, 2, false)
	(btns[bug] as Button).add_theme_stylebox_override("normal", good_box)
	(btns[bug] as Button).text += "      →  " + str(r.get("fix", "")).strip_edges()
	if i == bug:
		correct += 1
		Audio.sfx("good")
		_bubble.text = "KyKy: “Ơ! Em hiểu rồi!!”"
		_explain.text = "Chính xác! " + str(r.get("explain", ""))
		_face("kyky_wave")
		_hop()
	else:
		(btns[i] as Button).add_theme_stylebox_override("normal", bad_box)
		Audio.sfx("bad")
		_bubble.text = "KyKy: “Hoa cúc bảo dòng %d mà…”" % (i + 1)
		_face("kyky_wave_sad")
		_explain.text = "Chưa đúng — lỗi nằm ở dòng %d. %s" % [bug + 1, str(r.get("explain", ""))]
	_next.visible = true
	_next.text = "Tiếp" if idx < rounds.size() - 1 else "Xong"


## Đổi nét mặt KyKy (ảnh biểu cảm cùng kích thước với ảnh gốc nên giữ nguyên offset).
func _face(img: String) -> void:
	var t := Ui.char_tex(img)
	if _kyky != null and t != null:
		_kyky.texture = t


func _hop() -> void:
	if _kyky == null:
		return
	var y := _kyky.position.y
	var tw := create_tween()
	tw.tween_property(_kyky, "position:y", y - 30, 0.12)
	tw.tween_property(_kyky, "position:y", y, 0.2).set_trans(Tween.TRANS_BOUNCE)


func _on_next() -> void:
	idx += 1
	if idx >= rounds.size():
		Story.minigame_done("debug", {"correct": correct})
	else:
		_show_round()
