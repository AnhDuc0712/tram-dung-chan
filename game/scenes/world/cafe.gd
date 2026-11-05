extends Node2D
## Bản đồ quán Gờ 23 — phần chơi tự do. Biến thể "day" (chiều) / "evening" (tối, mưa) theo bước truyện.
## Dữ liệu vị trí (vùng đi được, vật cản, NPC, đồ vật) nằm ở data/roam/cafe.json.
## Thử nhanh: tools\screenshot.ps1 -Scene cafe   (thêm "-- --evening" hoặc "--debug-walk" khi chạy tay)

const Steps := preload("res://scripts/story_steps.gd")
const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const Shapes := preload("res://scripts/ui/shapes.gd")
const Player := preload("res://scenes/world/player.gd")
const DATA_PATH := "res://data/roam/cafe.json"
const CELL := 8
const INTERACT_DIST := 64.0


class FloatFx extends Node2D:
	## Trái tim / nốt nhạc bay lên rồi tan.
	var kind := "heart"
	var t := 0.0
	var seeds: Array = []

	func _ready() -> void:
		for i in 5:
			seeds.append(Vector2(randf_range(-26, 26), randf_range(0.0, 0.5)))
		z_index = 50

	func _process(delta: float) -> void:
		t += delta
		if t > 1.6:
			queue_free()
		queue_redraw()

	func _draw() -> void:
		for s in seeds:
			var k := clampf((t - s.y) / 1.1, 0.0, 1.0)
			if k <= 0.0:
				continue
			var p := Vector2(s.x + sin(k * 6.0 + s.x) * 6.0, -k * 70.0)
			var a := 1.0 - k
			if kind == "heart":
				Shapes.draw_heart(self, p, 16.0, Color(0.95, 0.35, 0.52, a))
			else:
				draw_circle(p, 5.0, Color(0.3, 0.2, 0.15, a))
				draw_line(p + Vector2(4, 0), p + Vector2(4, -16), Color(0.3, 0.2, 0.15, a), 2.0)
				draw_line(p + Vector2(4, -16), p + Vector2(11, -12), Color(0.3, 0.2, 0.15, a), 2.0)


class Marker extends Node2D:
	## Bong bóng "!" nhún nhảy trên đầu thứ chưa xem.
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()

	func _draw() -> void:
		var y := -sin(t * 4.0) * 4.0
		draw_circle(Vector2(0, y), 13.0, Color(1, 0.97, 0.93, 0.95))
		draw_arc(Vector2(0, y), 13.0, 0, TAU, 24, Color("e8608c"), 2.5)
		draw_rect(Rect2(-2, y - 8, 4, 10), Color("e8608c"))
		draw_circle(Vector2(0, y + 6), 2.2, Color("e8608c"))


var variant := "day"
var data: Dictionary = {}
var walk_poly := PackedVector2Array()
var obstacles: Array = []  # Rect2
var astar := AStarGrid2D.new()
var player
var entities: Array = []  # Dictionary
var _actors: Node2D
var _prompt: PanelContainer
var _prompt_label: Label
var _pending: Dictionary = {}  # đi tới rồi tương tác
var _nearest: Dictionary = {}
var _debug_walk := false
var _cat: Dictionary = {}
var _cat_busy := false
var _autoroam := false  # chỉ để kiểm thử: tự đi tới từng thứ và tương tác
var _autoroam_i := 0
var _autoroam_t := 0.0


func _ready() -> void:
	variant = Steps.arg(Story.current_step)
	for a in OS.get_cmdline_user_args():
		if a == "--evening":
			variant = "evening"
		elif a == "--debug-walk":
			_debug_walk = true
		elif a == "--autoroam":
			_autoroam = true
	if GameState.autoplay:
		_autoroam = true
	if not Steps.ROAM_VARIANTS.has(variant):
		variant = "day"
	if variant == "evening":
		GameState.set_flag("is_evening")
	else:
		GameState.set_flag("is_evening", false)
	data = DialogueData.load_json(DATA_PATH)
	_build_map()
	_build_entities()
	_build_prompt()
	Hud.set_visible_hud(true)
	Audio.music(str((data.get("music", {}) as Dictionary).get(variant, "roam_day")))
	Audio.ambient("rain_loop" if variant == "evening" else "")
	Dialogue.dialogue_finished.connect(_on_dialogue_finished)
	Dialogue.event.connect(_on_dialogue_event)
	_refresh()
	if variant == "day" and not GameState.has_flag("day_intro_done"):
		_start_dialogue("roam_day_intro")
	elif variant == "evening" and not GameState.has_flag("evening_intro_done"):
		_start_dialogue("roam_evening_intro")


# ======================================================================= dựng bản đồ
func _build_map() -> void:
	var bg := Sprite2D.new()
	bg.texture = load("res://assets/art/bg/%s.jpg" % str(data.get("map", "cafe_map")))
	bg.centered = false
	bg.position = Vector2(0, 3)
	add_child(bg)
	if variant == "evening":
		var cm := CanvasModulate.new()
		cm.color = Color(0.66, 0.6, 0.74)
		add_child(cm)
	for p in data.get("walk", []):
		walk_poly.append(Vector2(float(p[0]), float(p[1])))
	for r in data.get("obstacles", []):
		obstacles.append(Rect2(float(r[0]), float(r[1]), float(r[2]), float(r[3])))
	# tường = viền vùng đi được + vật cản
	var walls := StaticBody2D.new()
	add_child(walls)
	var outline := CollisionPolygon2D.new()
	outline.build_mode = CollisionPolygon2D.BUILD_SEGMENTS
	var closed := walk_poly.duplicate()
	closed.append(walk_poly[0])
	outline.polygon = closed
	walls.add_child(outline)
	for r in obstacles:
		var cs := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = r.size
		cs.shape = shape
		cs.position = r.get_center()
		walls.add_child(cs)
	_actors = Node2D.new()
	_actors.y_sort_enabled = true
	add_child(_actors)
	if _debug_walk:
		var dbg := Node2D.new()
		dbg.z_index = 100
		dbg.draw.connect(func() -> void:
			dbg.draw_colored_polygon(walk_poly, Color(0, 1, 0, 0.18))
			for r in obstacles:
				dbg.draw_rect(r, Color(1, 0, 0, 0.35))
			for e in entities:
				dbg.draw_circle(e["stand"], 6, Color(0, 0.4, 1, 0.8)))
		add_child(dbg)
		get_tree().create_timer(0.5).timeout.connect(dbg.queue_redraw)


func _build_grid() -> void:
	astar.region = Rect2i(0, 0, int(1280 / CELL), int(720 / CELL))
	astar.cell_size = Vector2(CELL, CELL)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar.update()
	for x in astar.region.size.x:
		for y in astar.region.size.y:
			var p := Vector2(x * CELL + CELL * 0.5, y * CELL + CELL * 0.5)
			astar.set_point_solid(Vector2i(x, y), not _walkable(p, 11.0))


func _walkable(p: Vector2, margin: float = 0.0) -> bool:
	if not Geometry2D.is_point_in_polygon(p, walk_poly):
		return false
	if margin > 0.0:
		for i in walk_poly.size():
			var a := walk_poly[i]
			var b := walk_poly[(i + 1) % walk_poly.size()]
			if Geometry2D.get_closest_point_to_segment(p, a, b).distance_to(p) < margin:
				return false
	for r in obstacles:
		if (r as Rect2).grow(margin).has_point(p):
			return false
	return true


func _cell_of(p: Vector2) -> Vector2i:
	return Vector2i(clampi(int(p.x / CELL), 0, astar.region.size.x - 1), clampi(int(p.y / CELL), 0, astar.region.size.y - 1))


func _nearest_free(c: Vector2i) -> Vector2i:
	if not astar.is_point_solid(c):
		return c
	for r in range(1, 30):
		for dx in range(-r, r + 1):
			for dy in range(-r, r + 1):
				var n := c + Vector2i(dx, dy)
				if astar.region.has_point(n) and not astar.is_point_solid(n):
					return n
	return c


func _path_to(target: Vector2) -> PackedVector2Array:
	var from := _nearest_free(_cell_of(player.global_position))
	var to := _nearest_free(_cell_of(target))
	var pts := astar.get_point_path(from, to)
	var out := PackedVector2Array()
	for i in pts.size():
		if i % 2 == 1 and i != pts.size() - 1:
			continue  # bớt điểm cho đường đi mượt hơn
		out.append(pts[i] + Vector2(CELL * 0.5, CELL * 0.5))
	return out


func _build_entities() -> void:
	var pl: Dictionary = data.get("player", {})
	player = Player.new()
	player.setup(Ui.char_tex(str(pl.get("sprite", "duc_front"))), Ui.char_tex(str(pl.get("walk", "duc_walk"))), float(pl.get("scale", 0.17)))
	var start: Array = (pl.get("start", {}) as Dictionary).get(variant, [640, 360])
	player.position = Vector2(float(start[0]), float(start[1]))
	if GameState.has_position and GameState.step == Story.current_step:
		player.position = GameState.player_position
	player.arrived.connect(_on_arrived)
	_actors.add_child(player)

	for n in data.get("npcs", []):
		var when: Dictionary = n.get("when", {})
		if not when.has(variant):
			continue
		var pos_a: Array = when[variant]
		var pos := Vector2(float(pos_a[0]), float(pos_a[1]))
		var holder := Node2D.new()
		holder.position = pos
		_actors.add_child(holder)
		var spr := Sprite2D.new()
		spr.centered = false
		var tex := Ui.char_tex(str(n.get("sprite", "")))
		var sc := float(n.get("scale", 0.17))
		var clip := float(n.get("clip", 1.0))
		if tex:
			if clip < 1.0:
				var at := AtlasTexture.new()
				at.atlas = tex
				at.region = Rect2(0, 0, tex.get_width(), tex.get_height() * clip)
				spr.texture = at
			else:
				spr.texture = tex
			spr.scale = Vector2.ONE * sc
			spr.position = Vector2(-tex.get_width() * sc * 0.5, -tex.get_height() * clip * sc)
		holder.add_child(spr)
		var stand_a: Array = n.get("stand", [pos.x, pos.y + 6])
		var e := {
			"id": str(n["id"]), "kind": "npc", "node": holder, "sprite": spr, "pos": pos,
			"stand": Vector2(float(stand_a[0]), float(stand_a[1])),
			"dialogue": str(n.get("dialogue", "")), "label": str(n.get("label", "Nói chuyện")),
			"height": (tex.get_height() * clip * sc) if tex else 80.0, "if": n.get("if", {}),
			"base_scale": sc,
		}
		if bool(n.get("cat", false)):
			_cat = e
			if variant == "evening" or GameState.get_var("nlong") >= 1:
				_cat_set_tex("cat_sit")
		# NPC đứng yên cũng chặn đường một chút
		if str(n["id"]) != "m":
			obstacles.append(Rect2(pos.x - 12, pos.y - 8, 24, 12))
		entities.append(e)
		_add_marker(e)

	for s in data.get("spots", []):
		if not (s.get("when", []) as Array).has(variant):
			continue
		var m: Array = s.get("marker", [0, 0])
		var st: Array = s.get("stand", m)
		var holder2 := Node2D.new()
		holder2.position = Vector2(float(m[0]), float(m[1]))
		holder2.z_index = 5
		add_child(holder2)
		var e2 := {
			"id": str(s["id"]), "kind": "spot", "node": holder2, "pos": holder2.position,
			"stand": Vector2(float(st[0]), float(st[1])), "dialogue": str(s.get("dialogue", "")),
			"label": str(s.get("label", "Xem")), "height": 10.0, "if": s.get("if", {}),
		}
		entities.append(e2)
		_add_marker(e2)
	_build_grid()  # cập nhật lại vì thêm vật cản NPC


func _add_marker(e: Dictionary) -> void:
	var mk := Marker.new()
	mk.position = Vector2(0, -float(e["height"]) - 22.0)
	(e["node"] as Node2D).add_child(mk)
	e["marker"] = mk


func _build_prompt() -> void:
	_prompt = PanelContainer.new()
	var st := Ui.box(Color(1, 0.97, 0.93, 0.95), Ui.PINK, 14, 2)
	st.content_margin_left = 12
	st.content_margin_right = 12
	st.content_margin_top = 2
	st.content_margin_bottom = 2
	_prompt.add_theme_stylebox_override("panel", st)
	_prompt.z_index = 60
	# chạm vào khung gợi ý cũng tương tác được (điện thoại không có phím E)
	_prompt.mouse_filter = Control.MOUSE_FILTER_STOP
	_prompt.gui_input.connect(_on_prompt_input)
	add_child(_prompt)
	_prompt_label = Ui.label("", 21, Ui.TEXT, Ui.font_bold)
	_prompt.add_child(_prompt_label)
	_prompt.visible = false


func _on_prompt_input(ev: InputEvent) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT and not _nearest.is_empty():
		get_viewport().set_input_as_handled()
		player.stop()
		_interact(_nearest)


# ======================================================================= vòng lặp
func _process(delta: float) -> void:
	var busy: bool = Dialogue.is_active() or Story.busy or Hud.any_open()
	if _autoroam and not busy:
		_autoroam_t += delta
		if _autoroam_t > 2.5 and player.path.is_empty():
			_autoroam_t = 0.0
			var order := ["nlong", "guitar", "books", "pen", "window", "menu", "staff", "nlong", "m", "door"]
			if GameState.autoplay:
				if variant == "evening":
					order = ["staff", "nlong", "m", "kyky"]
				elif GameState.has_flag("drink_made"):
					order = ["kyky"]
				else:
					order = ["nlong", "guitar", "pen", "books", "nlong", "kyky", "m"]
			if _autoroam_i < order.size():
				var want: String = order[_autoroam_i]
				_autoroam_i += 1
				for e in entities:
					if e["id"] == want and _available(e):
						_pending = e
						player.go_along(_path_to(e["stand"]))
						break
	player.frozen = busy
	if busy:
		_prompt.visible = false
		return
	_nearest = {}
	var best := INTERACT_DIST
	for e in entities:
		if not _available(e):
			continue
		var d: float = minf(player.global_position.distance_to(e["stand"]), player.global_position.distance_to(e["pos"]))
		if d < best:
			best = d
			_nearest = e
	if _nearest.is_empty():
		_prompt.visible = false
	else:
		_prompt_label.text = ("Chạm · " if Ui.touch else "E · ") + str(_nearest["label"])
		_prompt.visible = true
		_prompt.reset_size()
		var top: Vector2 = (_nearest["node"] as Node2D).position + Vector2(0, -float(_nearest["height"]) - 58.0)
		_prompt.position = Vector2(clampf(top.x - _prompt.size.x * 0.5, 4, 1276 - _prompt.size.x), maxf(top.y, 4))


func _available(e: Dictionary) -> bool:
	return GameState.check(e.get("if", {}))


func _refresh() -> void:
	for e in entities:
		var vis := _available(e)
		(e["node"] as Node2D).visible = vis or e["kind"] == "npc"
		var mk: Node2D = e.get("marker")
		if mk:
			mk.visible = vis and not GameState.has_flag("seen_" + str(e["id"]))
	_update_objective()


func _update_objective() -> void:
	var t := ""
	if variant == "day":
		if GameState.has_flag("drink_made"):
			t = "Mang ly nước ra cho KyKy."
		elif GameState.has_flag("promised_drink") or GameState.has_flag("talked_kyky_day"):
			t = "Pha một ly nước cho KyKy ở quầy pha chế (máy espresso sau quầy)."
		else:
			t = "KyKy trông buồn quá… Hỏi thăm cô bé, hoặc dạo quanh quán trước."
	else:
		if not GameState.has_flag("has_umbrella"):
			t = "Trời mưa! Lấy ô trong phòng nhân viên (cửa bên phải quầy)… hoặc mượn chị M."
		elif GameState.has_flag("has_treat") and not GameState.has_flag("fed_treat"):
			t = "Ra cửa gặp KyKy. (Nlong đang thèm súp thưởng…)"
		else:
			t = "Ra cửa gặp KyKy khi bạn đã sẵn sàng."
	Hud.set_objective(t)


func _unhandled_input(ev: InputEvent) -> void:
	if Dialogue.is_active() or Story.busy or Hud.any_open():
		return
	if ev.is_action_pressed("interact"):
		if not _nearest.is_empty():
			get_viewport().set_input_as_handled()
			_interact(_nearest)
		return
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var p: Vector2 = get_global_mouse_position()
		var hit := _entity_at(p)
		if not hit.is_empty():
			if player.global_position.distance_to(hit["stand"]) < INTERACT_DIST or player.global_position.distance_to(hit["pos"]) < INTERACT_DIST:
				player.stop()
				_interact(hit)
			else:
				_pending = hit
				player.go_along(_path_to(hit["stand"]))
			return
		_pending = {}
		player.go_along(_path_to(p))


func _entity_at(p: Vector2) -> Dictionary:
	for e in entities:
		if not _available(e):
			continue
		var base: Vector2 = (e["node"] as Node2D).position
		var h: float = float(e["height"])
		# vùng chạm rộng cho ngón tay (~1 đốt ngón trên điện thoại)
		var r := Rect2(base.x - 48, base.y - h - 40, 96, h + 60) if e["kind"] == "npc" else Rect2(base.x - 56, base.y - 56, 112, 112)
		if r.has_point(p):
			return e
	return {}


func _on_arrived() -> void:
	if not _pending.is_empty():
		var e := _pending
		_pending = {}
		_interact(e)


func _interact(e: Dictionary) -> void:
	if str(e.get("dialogue", "")) == "":
		return
	GameState.set_flag("seen_" + str(e["id"]))
	if _autoroam:
		print("[autoroam] ", e["id"], " heart=", GameState.get_var("heart"), " nlong=", GameState.get_var("nlong"))
	if e["kind"] == "npc" and e["id"] != "m":
		# quay mặt về phía Anh Đức
		var spr: Sprite2D = e["sprite"]
		spr.flip_h = player.global_position.x > (e["node"] as Node2D).position.x
	_start_dialogue(str(e["dialogue"]))


func _start_dialogue(id: String) -> void:
	_prompt.visible = false
	player.stop()
	Dialogue.start(id)


func _on_dialogue_finished(_id: String, then_step: String) -> void:
	_refresh()
	if then_step == "":
		GameState.save_game()
		_cat_after_dialogue()


func _on_dialogue_event(ev_name: String) -> void:
	match ev_name:
		"nlong_pet":
			if not _cat.is_empty():
				_spawn_fx("heart", (_cat["node"] as Node2D).position + Vector2(0, -40))
		"guitar":
			Audio.sfx("pop")
			_spawn_fx("note", Vector2(1100, 440))


func _spawn_fx(kind: String, at: Vector2) -> void:
	var f := FloatFx.new()
	f.kind = kind
	f.position = at
	add_child(f)


# ======================================================================= mèo Nlong
func _cat_set_tex(img: String) -> void:
	var spr: Sprite2D = _cat["sprite"]
	var tex := Ui.char_tex(img)
	if tex == null:
		return
	var sc := 0.32 if img == "cat_sit" else (0.24 if img == "cat_walk" else 0.42)
	spr.texture = tex
	spr.scale = Vector2.ONE * sc
	spr.position = Vector2(-tex.get_width() * sc * 0.5, -tex.get_height() * sc)
	_cat["height"] = tex.get_height() * sc
	var mk: Node2D = _cat.get("marker")
	if mk:
		mk.position = Vector2(0, -float(_cat["height"]) - 22.0)


func _cat_after_dialogue() -> void:
	# Ban ngày: được nựng lần đầu thì Nlong nhảy xuống và bắt đầu đi dạo quanh quán
	if _cat.is_empty() or variant != "day" or _cat_busy or GameState.get_var("nlong") < 1:
		return
	_cat_busy = true
	_cat_wander()


func _cat_wander() -> void:
	if not is_inside_tree():
		return
	var holder: Node2D = _cat["node"]
	var spots := [Vector2(700, 410), Vector2(860, 395), Vector2(480, 470), Vector2(640, 525), Vector2(960, 420), Vector2(300, 540)]
	var target: Vector2 = spots[randi() % spots.size()]
	if Dialogue.is_active():
		get_tree().create_timer(1.5).timeout.connect(_cat_wander)
		return
	_cat_set_tex("cat_walk")
	(_cat["sprite"] as Sprite2D).flip_h = target.x > holder.position.x
	var dur := holder.position.distance_to(target) / 60.0
	var tw := create_tween()
	tw.tween_property(holder, "position", target, dur)
	tw.tween_callback(func() -> void:
		_cat["pos"] = target
		_cat["stand"] = target + Vector2(0, 8)
		_cat_set_tex("cat_sit"))
	tw.tween_interval(randf_range(3.0, 6.0))
	tw.tween_callback(_cat_wander)


