extends Control
## Mini-game 1 Tập 3 "Giờ cao điểm ở Gờ 23" (Anh Đức pha, KyKy rót).
## 6 phiếu order, tối đa 3 phiếu cùng lúc. Chọn phiếu -> Anh Đức bấm đúng món -> KyKy bấm "Rót!" khi vạch chạy vào vùng xanh.
## Kết quả: {"served": 0..6 ly phục vụ được, "perfect": số ly rót đúng vùng xanh} -> Steps.minigame_effects("rush", ...)

const MiniFrame := preload("res://scripts/ui/mini_frame.gd")
const TOTAL := 6
const MAX_ACTIVE := 3
const PATIENCE := 16.0  # giây cho mỗi phiếu (nhân với cài đặt timer_scale; 0 = không giới hạn)
const DRINKS := {
	"coffee": {"name": "Cà phê sữa", "color": Color("8a5a3c")},
	"cacao": {"name": "Ca cao nóng", "color": Color("6e3b2a")},
	"ginger": {"name": "Trà gừng", "color": Color("c98a2b")},
}

var served := 0
var perfect := 0
var _spawned := 0
var _resolved := 0
var _spawn_t := 0.5
var _done := true  # đồng hồ chưa chạy cho tới khi bấm "Bắt đầu!"
var _orders: Array = []  # {drink, left, brewed, panel, bar, label}
var _selected := -1
var _queue: Array = []
var _list: VBoxContainer
var _msg: Label
var _score: Label
var _meter: Control
var _pour: Button
var _t := 0.0
var _patience := PATIENCE
var _locked := false


func _ready() -> void:
	Hud.set_visible_hud(true)
	Hud.set_objective("Chọn phiếu order, bấm đúng món cho Anh Đức pha, rồi bấm “Rót!” khi vạch chạy vào vùng xanh.")
	Audio.music("barista")
	var ts := float(GameState.settings.get("timer_scale", 1.5))
	_patience = PATIENCE * ts if ts > 0.0 else 0.0
	var keys: Array = DRINKS.keys()
	for i in TOTAL:
		_queue.append(keys[i % keys.size()])
	_queue.shuffle()
	_build()
	await MiniFrame.intro(self, "Giờ cao điểm!", [
		"Khách xếp hàng dài. Anh Đức pha, KyKy rót và trang trí.",
		"1. Bấm vào một PHIẾU ORDER để chọn.",
		"2. Anh Đức: bấm đúng MÓN của phiếu đó.",
		"3. KyKy: bấm “Rót!” đúng lúc vạch chạy vào vùng XANH để có ly hoàn hảo.",
		"Phục vụ %d ly. Phiếu nào đợi quá lâu sẽ bị khách bỏ đi." % TOTAL,
	])
	_done = false
	if GameState.autoplay:
		_autoplay()


func _build() -> void:
	var bg := TextureRect.new()
	bg.texture = load("res://assets/art/bg/cafe_day.jpg")
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.modulate = Color(0.62, 0.58, 0.55)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	# bên trái: các phiếu order
	var left := PanelContainer.new()
	left.position = Vector2(60, 165)
	left.custom_minimum_size = Vector2(520, 360)
	add_child(left)
	var lv := VBoxContainer.new()
	lv.add_theme_constant_override("separation", 10)
	left.add_child(lv)
	_score = Ui.label("", 26, Ui.PINK, Ui.font_title)
	lv.add_child(_score)
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 10)
	lv.add_child(_list)
	# bên phải: Anh Đức (chọn món) + KyKy (rót)
	var right := PanelContainer.new()
	right.position = Vector2(620, 165)
	right.custom_minimum_size = Vector2(600, 360)
	add_child(right)
	var rv := VBoxContainer.new()
	rv.add_theme_constant_override("separation", 12)
	right.add_child(rv)
	rv.add_child(Ui.label("Anh Đức pha món nào?", 26, Ui.TEXT, Ui.font_title))
	var drow := HBoxContainer.new()
	drow.add_theme_constant_override("separation", 10)
	rv.add_child(drow)
	for k in DRINKS:
		var b := Ui.button(str(DRINKS[k]["name"]), 190, 21)
		var key: String = k
		b.pressed.connect(func() -> void: _brew(key))
		drow.add_child(b)
	rv.add_child(Ui.label("KyKy rót sữa & đặt bánh", 26, Ui.TEXT, Ui.font_title))
	_meter = Control.new()
	_meter.custom_minimum_size = Vector2(560, 46)
	_meter.draw.connect(_draw_meter)
	rv.add_child(_meter)
	_pour = Ui.button("Rót!", 240, 26)
	_pour.disabled = true
	_pour.pressed.connect(_do_pour)
	rv.add_child(_pour)
	_msg = Ui.label("Chọn một phiếu order để bắt đầu.", 20, Ui.TEXT_SOFT, Ui.font_italic)
	_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_msg.custom_minimum_size = Vector2(560, 0)
	rv.add_child(_msg)
	_refresh_score()


func _refresh_score() -> void:
	_score.text = "Đã phục vụ %d / %d  ·  Hoàn hảo %d" % [served, TOTAL, perfect]


func _say(text: String, col: Color = Ui.TEXT_SOFT) -> void:
	_msg.text = text
	_msg.add_theme_color_override("font_color", col)


func _spawn() -> void:
	var drink: String = _queue[_spawned]
	_spawned += 1
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(480, 0)
	var v := VBoxContainer.new()
	panel.add_child(v)
	var lab := Ui.label("Phiếu %d: %s" % [_spawned, DRINKS[drink]["name"]], 22, Ui.TEXT, Ui.font_bold)
	v.add_child(lab)
	var bar := ProgressBar.new()
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(440, 14)
	v.add_child(bar)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	var order := {"drink": drink, "left": _patience, "brewed": false, "panel": panel, "bar": bar, "label": lab}
	panel.gui_input.connect(func(ev: InputEvent) -> void:
		if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
			_select(_orders.find(order)))
	_list.add_child(panel)
	_orders.append(order)
	Audio.sfx("bell")
	if _selected < 0:
		_select(0)


func _select(i: int) -> void:
	if _done or _locked or i < 0 or i >= _orders.size():
		return
	_selected = i
	for j in _orders.size():
		var on := j == i
		var fill: Color = Ui.PINK_SOFT if on else Ui.CREAM
		var edge: Color = Ui.PINK if on else Ui.CREAM_DARK
		(_orders[j]["panel"] as PanelContainer).add_theme_stylebox_override("panel", Ui.box(fill, edge, 14, 3 if on else 2, false))
	_pour.disabled = not bool(_orders[i]["brewed"])
	if bool(_orders[i]["brewed"]):
		_say("Ly đã pha xong. KyKy bấm “Rót!” khi vạch vào vùng xanh.")
	else:
		_say("Anh Đức, phiếu này là %s." % str(DRINKS[_orders[i]["drink"]]["name"]).to_lower())


func _brew(drink: String) -> void:
	if _done or _locked:
		return
	if _selected < 0 or _selected >= _orders.size():
		_say("Chọn một phiếu order trước đã.", Color("c0392b"))
		return
	var o: Dictionary = _orders[_selected]
	if bool(o["brewed"]):
		return
	if o["drink"] == drink:
		o["brewed"] = true
		Audio.sfx("cup")
		_pour.disabled = false
		_say("Cốt nước xong rồi! KyKy rót nhé.", Color("3f8a4a"))
	else:
		Audio.sfx("bad")
		if _patience > 0.0:
			o["left"] = maxf(float(o["left"]) - 2.0, 0.1)
		_say("Sai món rồi! Khách nhăn mặt (mất thêm chút thời gian).", Color("c0392b"))


func _do_pour() -> void:
	if _done or _locked or _selected < 0 or _selected >= _orders.size():
		return
	var o: Dictionary = _orders[_selected]
	if not bool(o["brewed"]):
		return
	var x := _marker()
	var good := absf(x - 0.5) <= 0.1
	served += 1
	if good:
		perfect += 1
		Audio.sfx("good")
		_say("Hoàn hảo! Bọt sữa tròn như trái tim.", Color("3f8a4a"))
	else:
		Audio.sfx("pop")
		_say("Rót xong, hơi lệch một chút. Khách vẫn cười.", Ui.TEXT)
	_finish_order(_selected)


func _finish_order(i: int) -> void:
	var o: Dictionary = _orders[i]
	(o["panel"] as Node).queue_free()
	_orders.remove_at(i)
	_resolved += 1
	_selected = -1
	_pour.disabled = true
	_refresh_score()
	if not _orders.is_empty():
		_select(0)
	if _resolved >= TOTAL:
		_end()


func _marker() -> float:
	return sin(_t * 2.6) * 0.5 + 0.5


func _draw_meter() -> void:
	var w := _meter.size.x
	var h := _meter.size.y
	_meter.draw_rect(Rect2(0, 8, w, h - 16), Color("e8dccb"))
	_meter.draw_rect(Rect2(w * 0.4, 8, w * 0.2, h - 16), Color("7fcf8f"))
	_meter.draw_rect(Rect2(0, 8, w, h - 16), Color("8a6a55"), false, 2.0)
	var x := _marker() * w
	_meter.draw_rect(Rect2(x - 3, 2, 6, h - 4), Color("c2185b"))


func _process(delta: float) -> void:
	_meter.queue_redraw()
	if _done:
		return
	_t += delta
	_spawn_t -= delta
	if _spawn_t <= 0.0 and _spawned < TOTAL and _orders.size() < MAX_ACTIVE:
		_spawn()
		_spawn_t = 4.5
	if _patience <= 0.0:
		return
	for i in range(_orders.size() - 1, -1, -1):
		var o: Dictionary = _orders[i]
		o["left"] = float(o["left"]) - delta
		(o["bar"] as ProgressBar).value = clampf(float(o["left"]) / _patience * 100.0, 0.0, 100.0)
		if float(o["left"]) <= 0.0:
			Audio.sfx("bad")
			_say("Khách đợi quá lâu nên bỏ đi mất… (phiếu %s)" % str(DRINKS[o["drink"]]["name"]).to_lower(), Color("c0392b"))
			_finish_order(i)
			return


func _end() -> void:
	_done = true
	_locked = true
	await get_tree().create_timer(0.8).timeout
	var win := served >= 4
	await MiniFrame.result(self, win, "Quán yên rồi!" if win else "Hơi lộn xộn… nhưng xong",
		["Phục vụ được %d / %d ly." % [served, TOTAL], "Ly hoàn hảo: %d" % perfect])
	Story.minigame_done("rush", {"served": served, "perfect": perfect})


func _autoplay() -> void:
	while not _done:
		await get_tree().create_timer(0.35).timeout
		if _orders.is_empty() or _done:
			continue
		_select(0)
		_brew(str(_orders[0]["drink"]))
		await get_tree().create_timer(0.2).timeout
		while not _done and absf(_marker() - 0.5) > 0.06:
			await get_tree().process_frame
		_do_pour()
