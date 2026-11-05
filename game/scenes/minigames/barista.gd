extends Control
## Mini-game pha chế: chọn món → kéo nguyên liệu vào ly (hoặc bấm vào lọ) → vẽ hình lên bọt sữa.
## Kết quả: Story.minigame_done("barista", {"drink": "cacao", "art": "turtle", "weird": false})

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const Shapes := preload("res://scripts/ui/shapes.gd")
const DATA_PATH := "res://data/minigames/barista.json"

const COMMENTS := {
	"chili": "Chị M: “Ơ… TƯƠNG ỚT?! Em định ám sát khách VIP à?”",
	"espresso": "Chị M: “Cà phê đậm đặc. Thơm đấy.”",
	"sugar": "Chị M: “Thêm đường, thêm ngọt ngào~”",
	"ice": "Chị M: “Lạch cạch lạch cạch.”",
	"peach": "Chị M: “Miếng đào to thế, hào phóng ghê.”",
	"cacao": "Chị M: “Thơm mùi ca cao rồi đó!”",
	"milk": "Chị M: “Sữa nóng vừa tới.”",
	"tea": "Chị M: “Trà ủ kỹ chưa đấy?”",
}


class Cup extends Control:
	## Ly nước: nhận thả nguyên liệu, vẽ chất lỏng + bọt + hình vẽ.
	var owner_game: Control
	var fill := 0.0
	var liquid := Color("8a5a3c")
	var foam := false
	var art := ""
	var wobble := 0.0

	func _can_drop_data(_p: Vector2, d: Variant) -> bool:
		return d is Dictionary and d.has("ing")

	func _drop_data(_p: Vector2, d: Variant) -> void:
		owner_game.call("add_ingredient", str(d["ing"]))

	func _process(delta: float) -> void:
		if wobble > 0.0:
			wobble = maxf(0.0, wobble - delta * 2.0)
			queue_redraw()

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var off := sin(wobble * 20.0) * wobble * 6.0
		var top := Rect2(w * 0.12 + off, h * 0.1, w * 0.76, h * 0.8)
		# quai cầm
		draw_arc(Vector2(top.end.x, top.position.y + top.size.y * 0.45), top.size.y * 0.22, -PI / 2, PI / 2, 20, Color("e9e2d6"), 14.0)
		# thân ly
		draw_rect(top, Color("fbf7f0"))
		# chất lỏng
		var lh := top.size.y * 0.85 * fill
		if lh > 0.0:
			draw_rect(Rect2(top.position.x + 8, top.end.y - 8 - lh, top.size.x - 16, lh), liquid)
		# miệng ly nhìn từ trên (elip)
		var mouth := Vector2(top.get_center().x, top.position.y)
		draw_set_transform(mouth, 0.0, Vector2(1.0, 0.32))
		draw_circle(Vector2.ZERO, top.size.x * 0.5, Color("e9e2d6"))
		var inner := top.size.x * 0.5 - 8.0
		if fill > 0.05:
			draw_circle(Vector2.ZERO, inner, Color("f3e3c8") if foam and fill >= 0.99 else liquid.lightened(0.15))
		else:
			draw_circle(Vector2.ZERO, inner, Color("d9d0c2"))
		draw_set_transform(Vector2.ZERO)
		draw_rect(top, Color("c9b8a0"), false, 3.0)
		# hình vẽ trên bọt sữa (vẽ phóng to phía trên ly cho dễ nhìn)
		if art != "":
			_draw_art(Vector2(top.get_center().x, top.position.y - 70), 60.0)

	func _draw_art(c: Vector2, r: float) -> void:
		draw_circle(c, r + 8, Color("8a5a3c"))
		draw_circle(c, r, Color("f6e7cf"))
		var ink := Color("8a5a3c")
		match art:
			"smile":
				draw_circle(c + Vector2(-r * 0.32, -r * 0.2), r * 0.1, ink)
				draw_circle(c + Vector2(r * 0.32, -r * 0.18), r * 0.1, ink)
				draw_arc(c + Vector2(0, r * 0.05), r * 0.45, 0.25, PI - 0.4, 16, ink, 5.0)
			"heart":
				Shapes.draw_heart(self, c + Vector2(0, r * 0.05), r * 1.3, Color("c27a55"))
			"turtle":
				draw_set_transform(c + Vector2(-r * 0.05, r * 0.1), 0.0, Vector2(1.0, 0.75))
				draw_circle(Vector2.ZERO, r * 0.5, Color("c9a07a"))
				draw_set_transform(Vector2.ZERO)
				for a in [-2.4, -0.7, 0.7, 2.4]:
					draw_circle(c + Vector2(cos(a) * r * 0.5, sin(a) * r * 0.42 + r * 0.1), r * 0.12, ink)
				draw_circle(c + Vector2(r * 0.62, -r * 0.05), r * 0.18, ink)
				draw_circle(c + Vector2(r * 0.66, -r * 0.09), r * 0.04, Color("f6e7cf"))
				draw_arc(c + Vector2(-r * 0.05, r * 0.1), r * 0.28, 0, TAU, 6, ink, 3.0)
			"cat":
				draw_circle(c + Vector2(0, r * 0.1), r * 0.55, Color("b0a8a0"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(-r * 0.5, -r * 0.15), c + Vector2(-r * 0.45, -r * 0.5), c + Vector2(-r * 0.15, -r * 0.38)]), Color("b0a8a0"))
				draw_colored_polygon(PackedVector2Array([c + Vector2(r * 0.5, -r * 0.15), c + Vector2(r * 0.45, -r * 0.5), c + Vector2(r * 0.15, -r * 0.38)]), Color("b0a8a0"))
				draw_circle(c + Vector2(-r * 0.2, r * 0.05), r * 0.1, Color("d99a2b"))
				draw_circle(c + Vector2(r * 0.2, r * 0.05), r * 0.1, Color("d99a2b"))
				draw_circle(c + Vector2(0, r * 0.25), r * 0.05, Color("e88a9a"))


class Jar extends Button:
	## Lọ nguyên liệu: kéo vào ly, hoặc bấm để đổ.
	var ing := ""
	var col := Color.WHITE

	func _get_drag_data(_p: Vector2) -> Variant:
		var prev := Label.new()
		prev.text = text
		prev.add_theme_font_size_override("font_size", 22)
		prev.add_theme_color_override("font_color", Color("4a2e1f"))
		set_drag_preview(prev)
		return {"ing": ing}

	func _draw() -> void:
		draw_circle(Vector2(size.x * 0.5, 30), 20, col)
		draw_arc(Vector2(size.x * 0.5, 30), 20, 0, TAU, 24, Color("8a6a55"), 2.0)


var data: Dictionary = {}
var drink := ""
var added: Array = []
var cup: Cup
var _left: VBoxContainer
var _shelf: GridContainer
var _comment: Label
var _actions: HBoxContainer
var _art_row: HBoxContainer


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Quầy pha chế: chọn món, rồi kéo nguyên liệu vào ly.")
	Audio.music("barista")
	data = DialogueData.load_json(DATA_PATH)
	_build()
	if GameState.autoplay:
		await get_tree().create_timer(0.5).timeout
		_choose_drink("cacao")
		for i in ["cacao", "milk", "sugar"]:
			add_ingredient(i)
		_done_mixing()
		await get_tree().create_timer(0.3).timeout
		print("[autoplay] pha chế xong")
		Story.minigame_done("barista", {"drink": drink, "art": "turtle", "weird": _is_weird()})


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_day.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.6, 0.55, 0.52)
	add_child(bg)
	var counter := ColorRect.new()
	counter.color = Color("6e4a33")
	counter.position = Vector2(0, 560)
	counter.size = Vector2(1280, 160)
	add_child(counter)

	var lp := PanelContainer.new()
	lp.position = Vector2(30, 150)
	lp.custom_minimum_size = Vector2(380, 0)
	add_child(lp)
	_left = VBoxContainer.new()
	_left.add_theme_constant_override("separation", 10)
	lp.add_child(_left)
	_show_menu()

	cup = Cup.new()
	cup.owner_game = self
	cup.position = Vector2(520, 290)
	cup.size = Vector2(240, 270)
	add_child(cup)

	var cp := PanelContainer.new()
	cp.position = Vector2(470, 150)
	cp.custom_minimum_size = Vector2(380, 0)
	add_child(cp)
	_comment = Ui.label("Chị M: “Pha gì cũng được, miễn có tâm!”", 19, Ui.TEXT, Ui.font_italic)
	_comment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_comment.custom_minimum_size = Vector2(340, 0)
	cp.add_child(_comment)

	var sp := PanelContainer.new()
	sp.position = Vector2(880, 150)
	add_child(sp)
	var sv := VBoxContainer.new()
	sp.add_child(sv)
	sv.add_child(Ui.label("Nguyên liệu", 24, Ui.TEXT, Ui.font_title))
	sv.add_child(Ui.label("(kéo vào ly hoặc chạm)", 18, Ui.TEXT_SOFT))
	_shelf = GridContainer.new()
	_shelf.columns = 2
	_shelf.add_theme_constant_override("h_separation", 10)
	_shelf.add_theme_constant_override("v_separation", 10)
	sv.add_child(_shelf)
	var ings: Dictionary = data.get("ingredients", {})
	for id in ings:
		var j := Jar.new()
		j.ing = str(id)
		j.col = Color(str(ings[id].get("color", "#ffffff")))
		j.text = "\n\n" + str(ings[id].get("name", id))
		j.custom_minimum_size = Vector2(170, 92)
		j.focus_mode = Control.FOCUS_NONE
		j.add_theme_font_size_override("font_size", 18)
		j.pressed.connect(func() -> void: add_ingredient(j.ing))
		_shelf.add_child(j)
	_shelf.modulate.a = 0.4

	_actions = HBoxContainer.new()
	_actions.position = Vector2(470, 600)
	_actions.add_theme_constant_override("separation", 16)
	add_child(_actions)
	var reset := Ui.button("Đổ đi làm lại", 210, 20)
	reset.pressed.connect(_reset_cup)
	_actions.add_child(reset)
	var done := Ui.button("Xong!", 150, 22)
	done.pressed.connect(_done_mixing)
	_actions.add_child(done)
	_actions.visible = false


func _show_menu() -> void:
	for c in _left.get_children():
		c.queue_free()
	_left.add_child(Ui.label("Chọn món", 30, Ui.TEXT, Ui.font_title))
	var drinks: Dictionary = data.get("drinks", {})
	for id in drinks:
		var d: Dictionary = drinks[id]
		var b := Ui.button(str(d.get("name", id)), 330, 22)
		b.tooltip_text = str(d.get("desc", ""))
		var did := str(id)
		b.pressed.connect(func() -> void: _choose_drink(did))
		_left.add_child(b)
		var desc := Ui.label(str(d.get("desc", "")), 18, Ui.TEXT_SOFT)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc.custom_minimum_size = Vector2(330, 0)
		_left.add_child(desc)


func _choose_drink(id: String) -> void:
	drink = id
	var d: Dictionary = data["drinks"][id]
	for c in _left.get_children():
		c.queue_free()
	_left.add_child(Ui.label(str(d.get("name", id)), 30, Ui.PINK, Ui.font_title))
	_left.add_child(Ui.label("Công thức:", 20, Ui.TEXT, Ui.font_bold))
	var ings: Dictionary = data.get("ingredients", {})
	for n in d.get("needs", []):
		_left.add_child(Ui.label("•  " + str(ings.get(n, {}).get("name", n)), 20, Ui.TEXT))
	var tip := Ui.label("Muốn sáng tạo thêm cũng được… nhưng khách VIP sẽ phản ứng thế nào thì chịu!", 16, Ui.TEXT_SOFT, Ui.font_italic)
	tip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tip.custom_minimum_size = Vector2(330, 0)
	_left.add_child(tip)
	var back := Ui.button("Đổi món", 200, 18)
	back.pressed.connect(func() -> void:
		_reset_cup()
		drink = ""
		_shelf.modulate.a = 0.4
		_actions.visible = false
		_show_menu())
	_left.add_child(back)
	_shelf.modulate.a = 1.0
	_actions.visible = true
	cup.liquid = Color(str(d.get("liquid", "#8a5a3c")))
	cup.foam = bool(d.get("foam", false))
	Audio.sfx("toggle")


func add_ingredient(id: String) -> void:
	if drink == "" or added.size() >= 6 or not _actions.visible:
		return
	added.append(id)
	var ings: Dictionary = data.get("ingredients", {})
	var col := Color(str(ings.get(id, {}).get("color", "#888888")))
	var d: Dictionary = data["drinks"][drink]
	var needs: Array = d.get("needs", [])
	var base := Color(str(d.get("liquid", "#8a5a3c")))
	cup.liquid = base.lerp(col, 0.25) if not needs.has(id) else base
	if id == "chili":
		cup.liquid = Color("b0402a")
	cup.fill = minf(1.0, float(added.size()) / float(maxi(needs.size(), 1)))
	cup.wobble = 1.0
	cup.queue_redraw()
	Audio.sfx("cup" if id != "ice" else "drop")
	_comment.text = str(COMMENTS.get(id, "Chị M: “Ừm…”"))


func _reset_cup() -> void:
	added.clear()
	cup.fill = 0.0
	cup.art = ""
	cup.queue_redraw()
	Audio.sfx("whoosh")
	_comment.text = "Chị M: “Làm lại từ đầu cũng là một kỹ năng.”"


func _is_weird() -> bool:
	var needs: Array = data["drinks"][drink].get("needs", [])
	for n in needs:
		if not added.has(n):
			return true
	for a in added:
		if not needs.has(a):
			return true
	return false


func _done_mixing() -> void:
	if added.is_empty():
		_comment.text = "Chị M: “Ly rỗng mà mang ra thì khách khóc thật đấy.”"
		Audio.sfx("bad")
		return
	cup.fill = 1.0
	cup.queue_redraw()
	_actions.visible = false
	_shelf.modulate.a = 0.4
	for c in _shelf.get_children():
		(c as Button).disabled = true
	Audio.sfx("good")
	if cup.foam and not _is_weird():
		_comment.text = "Chị M: “Lớp bọt sữa đẹp đấy! Vẽ gì lên đi chứ!”"
		_show_art_choices()
	else:
		_comment.text = "Chị M: “Xong rồi à? Mang ra cho khách đi!”" if not _is_weird() else "Chị M: “Cái màu này… thôi, mang ra xem phản ứng thế nào.”"
		_show_serve("none")


func _show_art_choices() -> void:
	for c in _left.get_children():
		c.queue_free()
	_left.add_child(Ui.label("Vẽ lên bọt sữa", 30, Ui.TEXT, Ui.font_title))
	var arts: Dictionary = data.get("arts", {})
	for id in arts:
		var b := Ui.button(str(arts[id]), 330, 22)
		var aid := str(id)
		b.mouse_entered.connect(func() -> void:
			cup.art = aid
			cup.queue_redraw())
		b.pressed.connect(func() -> void:
			cup.art = aid
			cup.queue_redraw()
			Audio.sfx("scribble")
			_show_serve(aid))
		_left.add_child(b)


func _show_serve(art: String) -> void:
	for c in _left.get_children():
		c.queue_free()
	_left.add_child(Ui.label("Hoàn thành!", 30, Ui.PINK, Ui.font_title))
	var d: Dictionary = data["drinks"][drink]
	_left.add_child(Ui.label(str(d.get("name", drink)) + ("  (phiên bản sáng tạo)" if _is_weird() else ""), 20, Ui.TEXT))
	var b := Ui.button("Đặt lên khay", 330)
	b.pressed.connect(func() -> void:
		Audio.sfx("bell")
		Story.minigame_done("barista", {"drink": drink, "art": art, "weird": _is_weird()}))
	_left.add_child(b)
