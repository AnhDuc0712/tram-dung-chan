extends Control
## Mini-game 1 Tập 2 "Giải cứu bàn phím khỏi Hoàng thượng Nlong".
## Bước 1: gãi đúng 3 "điểm yếu" (cằm, sau tai cụp, má phúng phính) — chạm đuôi là Nlong quạu.
## Bước 2: kéo thanh súp thưởng từ balo sang cuốn sổ để dụ Nlong rời bàn phím.
## Kết quả: {"pets": 0..3, "treat": bool, "tail": bool} -> Steps.minigame_effects("nlong", ...)

const Shapes := preload("res://scripts/ui/shapes.gd")
const MiniFrame := preload("res://scripts/ui/mini_frame.gd")
const CAT_POS := Vector2(580, 540)  # chân Nlong (gốc ảnh)
const CAT_SCALE := 0.9
# điểm gãi theo toạ độ ảnh cat_big (317x460)
const SPOTS := {
	"chin": {"at": Vector2(200, 168), "name": "dưới cằm"},
	"ear": {"at": Vector2(266, 44), "name": "sau tai cụp"},
	"cheek": {"at": Vector2(96, 150), "name": "má phúng phính"},
}
const TAIL := Rect2(232, 330, 90, 130)

var time_left := 15.0
var pets: Dictionary = {}
var tail := false
var treat := false
var _phase := 1
var _done := false
var _cat: Sprite2D
var _bar: ProgressBar
var _msg: Label
var _time: Label
var _treat_node: Control
var _dragging := false
var _book := Rect2(930, 430, 220, 150)
var _bag := Rect2(110, 430, 200, 160)
var _fx: Control


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Gãi đúng 3 điểm yếu của Nlong (tránh cái đuôi!), rồi kéo súp thưởng sang cuốn sổ.")
	Audio.music("barista")
	if GameState.has_flag("petted_ep2"):
		time_left = 20.0  # sáng nay đã nựng hoàng thượng -> ngài dễ tính hơn
	_build()
	_done = true  # đồng hồ chưa chạy cho tới khi bấm "Bắt đầu!"
	await MiniFrame.intro(self, "Giải cứu bàn phím!", [
		"Hoàng thượng Nlong đang nằm chễm chệ trên laptop của Anh Đức.",
		"1. Chạm vào 3 chỗ Nlong thích được gãi: dưới cằm, sau tai cụp, má phúng phính. Tránh cái đuôi!",
		"2. Gãi đủ 3 chỗ thì kéo thanh SÚP MÈO từ balo sang cuốn sổ để dụ ngài rời bàn phím.",
		"Bạn có %d giây." % int(time_left),
	])
	_done = false
	if GameState.autoplay:
		_autoplay()


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_morning.jpg")  # Tập 2 buổi sáng
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.7, 0.66, 0.62)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var desk := Control.new()
	desk.set_anchors_preset(Control.PRESET_FULL_RECT)
	desk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desk.draw.connect(func() -> void:
		desk.draw_rect(Rect2(0, 520, 1280, 200), Color("8a5a3c"))
		desk.draw_rect(Rect2(0, 520, 1280, 10), Color("6e4630"))
		# laptop bị đè
		desk.draw_rect(Rect2(420, 470, 440, 90), Color("3b3f48"))
		desk.draw_rect(Rect2(440, 480, 400, 70), Color("2a2d33"))
		for i in 4:
			for j in 12:
				desk.draw_rect(Rect2(448 + j * 32, 486 + i * 16, 26, 11), Color("4c515c"))
		# cuốn sổ + balo
		_draw_book(desk)
		_draw_bag(desk))
	add_child(desk)
	_cat = Sprite2D.new()
	_cat.texture = Ui.char_tex("cat_big")
	_cat.centered = false
	_cat.scale = Vector2.ONE * CAT_SCALE
	_cat.position = CAT_POS - Vector2(_cat.texture.get_width() * 0.5, _cat.texture.get_height()) * CAT_SCALE
	add_child(_cat)
	_fx = Control.new()
	_fx.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fx)

	var p := PanelContainer.new()
	p.position = Vector2(850, 110)
	p.custom_minimum_size = Vector2(400, 0)
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.add_child(v)
	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(row)
	var t := Ui.label("Độ phê của Nlong", 24, Ui.PINK, Ui.font_title)
	t.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(t)
	_time = Ui.label("", 24, Ui.TEXT, Ui.font_bold)
	row.add_child(_time)
	_bar = ProgressBar.new()
	_bar.max_value = 100
	_bar.show_percentage = false
	_bar.custom_minimum_size = Vector2(360, 22)
	_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	v.add_child(_bar)
	_msg = Ui.label("Hoàng thượng nằm chễm chệ trên bàn phím. Gãi đúng chỗ ngài thích đi…", 20, Ui.TEXT)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.custom_minimum_size = Vector2(360, 0)
	v.add_child(_msg)

	_treat_node = Control.new()
	_treat_node.size = Vector2(120, 40)
	_treat_node.position = _bag.position + Vector2(40, 20)
	_treat_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_treat_node.visible = false
	_treat_node.draw.connect(func() -> void:
		_treat_node.draw_rect(Rect2(0, 8, 120, 24), Color("ff9db5"))
		_treat_node.draw_rect(Rect2(0, 8, 120, 24), Color("c2185b"), false, 3.0)
		_treat_node.draw_string(Ui.font_bold, Vector2(14, 28), "SÚP MÈO", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("7a1036")))
	add_child(_treat_node)


func _process(delta: float) -> void:
	if _done:
		return
	time_left -= delta
	_time.text = "%d giây" % ceili(maxf(time_left, 0.0))
	if time_left <= 0.0:
		_finish("Hết giờ! Nlong vẫn chưa chịu nhích…")


func _draw_book(ci: CanvasItem) -> void:
	var r := _book
	ci.draw_style_box(Ui.box(Color(0, 0, 0, 0.18), Color(0, 0, 0, 0), 14, 0, false), Rect2(r.position + Vector2(6, 8), r.size))
	ci.draw_style_box(Ui.box(Color("f2c46d"), Color("a8782c"), 14, 3, false), r)
	ci.draw_style_box(Ui.box(Color("fff6dc"), Color("d9b46a"), 8, 2, false), Rect2(r.position + Vector2(40, 34), Vector2(r.size.x - 60, 46)))
	ci.draw_string(Ui.font_title, r.position + Vector2(52, 68), "Sổ KyKy", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("8a4b1a"))
	for i in 7:  # gáy lò xo
		var y := r.position.y + 14 + i * 19
		ci.draw_arc(Vector2(r.position.x + 12, y), 7.0, -PI * 0.5, PI * 0.5, 10, Color("6b6f78"), 3.0)
	Shapes.draw_heart(ci, r.position + Vector2(r.size.x - 40, r.size.y - 34), 26.0, Color("f06292"))
	ci.draw_circle(r.position + Vector2(70, r.size.y - 34), 10, Color("8fd6a8"))  # sticker


func _draw_bag(ci: CanvasItem) -> void:
	var r := _bag
	ci.draw_arc(Vector2(r.get_center().x, r.position.y + 6), 48.0, PI, TAU, 24, Color("1f232b"), 10.0)  # quai xách
	ci.draw_style_box(Ui.box(Color(0, 0, 0, 0.2), Color(0, 0, 0, 0), 26, 0, false), Rect2(r.position + Vector2(6, 8), r.size))
	ci.draw_style_box(Ui.box(Color("394150"), Color("1f232b"), 28, 3, false), r)
	ci.draw_style_box(Ui.box(Color("454e60"), Color("1f232b"), 22, 3, false), Rect2(r.position + Vector2(0, 0), Vector2(r.size.x, 62)))  # nắp
	ci.draw_style_box(Ui.box(Color("2f3644"), Color("1f232b"), 14, 3, false), Rect2(r.position + Vector2(36, 86), Vector2(r.size.x - 72, 56)))  # túi trước
	ci.draw_line(r.position + Vector2(48, 98), r.position + Vector2(r.size.x - 48, 98), Color("aeb4c0"), 2.0)  # khoá kéo
	ci.draw_circle(r.position + Vector2(r.size.x * 0.5, 62), 7, Color("e0b44c"))  # khoá nắp
	ci.draw_string(Ui.font_bold, r.position + Vector2(52, 132), "Balo Đức", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("cfd4dc"))


## Toạ độ màn hình của một điểm trên ảnh mèo.
func _cat_point(p: Vector2) -> Vector2:
	return _cat.position + p * CAT_SCALE


func _gui_input(ev: InputEvent) -> void:
	if _done:
		return
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed:
			if _phase == 1:
				_pet_at(ev.position)
			elif _treat_node.get_rect().grow(20).has_point(ev.position):
				_dragging = true
		elif _dragging:
			_dragging = false
			_drop_treat(ev.position)
	elif ev is InputEventMouseMotion and _dragging:
		_treat_node.position = ev.position - _treat_node.size * 0.5


func _pet_at(at: Vector2) -> void:
	var local := (at - _cat.position) / CAT_SCALE
	if TAIL.has_point(local):
		tail = true
		_bar.value = maxf(_bar.value - 20.0, 0.0)
		_msg.text = "Á! Đụng vào đuôi! Nlong quạu, vẫy đuôi đen đét."
		Audio.sfx("meow", -2.0, 0.8)
		_shake_cat()
		return
	for k in SPOTS:
		if pets.has(k):
			continue
		if local.distance_to(SPOTS[k]["at"]) < 46.0:
			pets[k] = true
			_bar.value = minf(_bar.value + 34.0, 100.0)
			_msg.text = "Gãi trúng %s! Nlong nheo mắt, rừ rừ…" % SPOTS[k]["name"]
			Audio.sfx("purr")
			_heart_pop(at)
			if pets.size() >= 3:
				_start_treat()
			return
	_msg.text = "Nlong liếc bạn: “Không phải chỗ đó, thần dân.”"
	Audio.sfx("bad", -10.0)


func _start_treat() -> void:
	_phase = 2
	_treat_node.visible = true
	_msg.text = "Nlong phê lắm rồi! Giờ kéo thanh SÚP MÈO từ balo sang cuốn sổ để dụ ngài nhích khỏi bàn phím."


func _drop_treat(at: Vector2) -> void:
	if _book.grow(30).has_point(at):
		treat = true
		Audio.sfx("mew_food")
		var tw := create_tween()
		tw.tween_property(_cat, "position:x", _cat.position.x + 260.0, 0.6).set_trans(Tween.TRANS_BACK)
		_finish("Nlong phi theo thanh súp, lăn một vòng… suýt rơi khỏi bàn!")
	else:
		_treat_node.position = _bag.position + Vector2(40, 20)


func _finish(text: String) -> void:
	if _done:
		return
	_done = true
	_msg.text = text
	await get_tree().create_timer(1.0).timeout
	var win := pets.size() >= 3 and treat
	var lines := [text, "Gãi trúng: %d / 3 điểm yếu" % pets.size(),
		"Súp thưởng: " + ("dụ được hoàng thượng rời bàn phím!" if treat else "chưa kịp dùng")]
	if tail:
		lines.append("Lỡ đụng vào đuôi — Nlong sẽ nhớ chuyện này đấy.")
	await MiniFrame.result(self, win, "Giải cứu thành công!" if win else ("Gần được rồi!" if pets.size() >= 2 else "Hoàng thượng thắng…"), lines)
	Story.minigame_done("nlong", {"pets": pets.size(), "treat": treat, "tail": tail})


func _heart_pop(at: Vector2) -> void:
	var h := Control.new()
	h.position = at
	h.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.draw.connect(func() -> void: Shapes.draw_heart(h, Vector2.ZERO, 34.0, Color("f06292"), Color("c2185b")))
	_fx.add_child(h)
	var tw := h.create_tween()
	tw.tween_property(h, "position:y", at.y - 70.0, 0.8)
	tw.parallel().tween_property(h, "modulate:a", 0.0, 0.8)
	tw.tween_callback(h.queue_free)


func _shake_cat() -> void:
	var x := _cat.position.x
	var tw := create_tween()
	for i in 6:
		tw.tween_property(_cat, "position:x", x + (8.0 if i % 2 == 0 else -8.0), 0.04)
	tw.tween_property(_cat, "position:x", x, 0.04)


func _autoplay() -> void:
	for k in SPOTS:
		await get_tree().create_timer(0.4).timeout
		_pet_at(_cat_point(SPOTS[k]["at"]))
	await get_tree().create_timer(0.4).timeout
	_drop_treat(_book.get_center())
