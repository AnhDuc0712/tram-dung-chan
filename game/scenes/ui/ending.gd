extends Control
## Màn kết thúc Tập 1: tên kết thúc, lời kết, chỉ số, số kết thúc đã mở, lời hẹn Tập 2.

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const Icon := preload("res://scripts/ui/icon.gd")
const Steps := preload("res://scripts/story_steps.gd")


func _ready() -> void:
	Hud.set_visible_hud(false)
	Audio.ambient("")
	Audio.music("ending")
	var id := GameState.ending_id
	GameState.unlock_ending(id)
	if id != "":
		GameState.delete_save()
	var endings := DialogueData.load_json(DialogueData.ENDINGS_PATH)
	var e: Dictionary = endings.get(id, {"title": "Hết Tập %d" % GameState.episode, "text": ""})
	var total := 0
	for k in endings:
		if int(endings[k].get("episode", 1)) == GameState.episode:
			total += 1
	_build(e, total)
	if GameState.autoplay:
		print("[autoplay] KẾT THÚC: ", id, "  heart=", GameState.get_var("heart"), " brain=", GameState.get_var("brain"), " nlong=", GameState.get_var("nlong"))
		get_tree().create_timer(1.0).timeout.connect(get_tree().quit)


func _build(e: Dictionary, total: int) -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/street_rain.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.55, 0.5, 0.6)
	add_child(bg)

	var p := PanelContainer.new()
	var st := Ui.box(Color(1, 0.973, 0.933, 0.96), Ui.BORDER, 28, 4)
	st.content_margin_left = 50
	st.content_margin_right = 50
	st.content_margin_top = 30
	st.content_margin_bottom = 30
	p.add_theme_stylebox_override("panel", st)
	p.position = Vector2(190, 60)
	p.custom_minimum_size = Vector2(900, 600)
	add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 14)
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	p.add_child(v)

	var rank := Ui.label(str(e.get("rank", "Kết thúc")), 22, Ui.TEXT_SOFT, Ui.font_bold)
	rank.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(rank)
	var t := Ui.label(str(e.get("title", "")), 56, Ui.PINK, Ui.font_title)
	t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(t)
	var d := Ui.label(str(e.get("text", "")), 23, Ui.TEXT, Ui.font_italic)
	d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	d.custom_minimum_size = Vector2(800, 0)
	v.add_child(d)

	var stats := HBoxContainer.new()
	stats.alignment = BoxContainer.ALIGNMENT_CENTER
	stats.add_theme_constant_override("separation", 30)
	v.add_child(stats)
	var stat_rows := [
		["heart", "Rung động", GameState.get_var("heart")],
		["bulb", "Hiểu bài", GameState.get_var("brain")],
		["paw", "Thân với Nlong", GameState.get_var("nlong")],
	]
	if GameState.episode >= 2:
		stat_rows.append(["star", "Trâm tin tưởng", GameState.get_var("tram")])
	for info in stat_rows:
		var h := HBoxContainer.new()
		h.add_child(Icon.new(info[0], 40.0))
		h.add_child(Ui.label("%s: %d" % [info[1], info[2]], 22, Ui.TEXT, Ui.font_bold))
		stats.add_child(h)

	var mine := 0
	var all_endings := DialogueData.load_json(DialogueData.ENDINGS_PATH)
	for k in GameState.unlocked_endings:
		if int(all_endings.get(k, {}).get("episode", 1)) == GameState.episode:
			mine += 1
	var got := Ui.label("Tập %d: đã mở khóa %d / %d kết thúc" % [GameState.episode, mine, total], 20, Ui.TEXT_SOFT)
	got.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(got)

	var sep := HSeparator.new()
	v.add_child(sep)
	var next := Ui.label("Hết Tập %d" % GameState.episode, 24, Color("6b3a2a"), Ui.font_title)
	next.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(next)
	var teaser_text := str(e.get("next", ""))
	if teaser_text == "" and GameState.episode == 1:
		teaser_text = "Tập 2: Trâm — cô bạn thân “hộ vệ” — đích thân tới quán để “thẩm vấn” Anh Đức. Và một anh khóa trên lịch thiệp tên Hải bắt đầu xuất hiện bên cạnh KyKy…"
	var teaser := Ui.label(teaser_text, 19, Ui.TEXT)
	teaser.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	teaser.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	teaser.custom_minimum_size = Vector2(800, 0)
	v.add_child(teaser)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 20)
	v.add_child(row)
	var ep := GameState.episode
	if Steps.EPISODES.has(ep + 1):
		var nxt := Ui.button("Sang Tập %d  »" % (ep + 1), 260)
		nxt.pressed.connect(func() -> void: Story.new_game(ep + 1))
		row.add_child(nxt)
	var again := Ui.button("Chơi lại Tập %d" % ep, 260)
	again.pressed.connect(func() -> void: Story.new_game(ep))
	row.add_child(again)
	var home := Ui.button("Màn hình chính", 240)
	home.pressed.connect(func() -> void:
		GameState.reset()
		Story.goto("title", false))
	row.add_child(home)

	# Trâm & Hải nhá hàng cho Tập 2 (bóng mờ hai bên)
	for info in [["tram_front", Vector2(110, 740)], ["hai_front", Vector2(1170, 740)]]:
		var tex := Ui.char_tex(info[0])
		if tex:
			var s := Sprite2D.new()
			s.texture = tex
			s.centered = false
			s.offset = Vector2(-tex.get_width() * 0.5, -tex.get_height())
			s.position = info[1]
			s.scale = Vector2(0.7, 0.7)
			s.modulate = Color(0.15, 0.12, 0.2, 0.85)
			add_child(s)
			move_child(s, 1)
