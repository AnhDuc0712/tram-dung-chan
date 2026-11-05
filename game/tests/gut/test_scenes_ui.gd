extends GutTest
## Chạy THẬT giao diện: hộp thoại hiển thị từng câu của mọi kịch bản qua nhiều nhánh khác nhau,
## mọi nhân vật x mọi biểu cảm lên sân khấu, từng màn chơi được dựng và chạy vài chục khung hình.
## Lỗi script / push_error trong lúc chạy -> GUT đánh trượt test.
## Story.busy = true để chặn chuyển cảnh (không phá trình chạy test).

const H := preload("res://tests/gut/helpers.gd")
const SCENES := [
	"res://scenes/ui/title_screen.tscn",
	"res://scenes/world/cafe.tscn",
	"res://scenes/minigames/barista.tscn",
	"res://scenes/minigames/debug.tscn",
	"res://scenes/minigames/heartbeat.tscn",
	"res://scenes/phone/phone.tscn",
	"res://scenes/ui/ending.tscn",
]


func before_all() -> void:
	Engine.time_scale = 12.0
	Story.busy = true


func after_all() -> void:
	Engine.time_scale = 1.0
	Story.busy = false
	_stop_dialogue()
	GameState.reset()


func _stop_dialogue() -> void:
	Dialogue._runner = null
	Dialogue.clear_stage()


## Bấm qua hết hội thoại bằng chính UI. `rot` xoay vòng lựa chọn để mỗi lượt đi một nhánh khác.
func _click_through(id: String, rot: int) -> Dictionary:
	Dialogue.start(id)
	var shown := 0
	var picks := 0
	for _i in 4000:
		if not Dialogue.is_active():
			break
		if Dialogue._choice_box.get_child_count() > 0:
			var n: int = Dialogue._choice_box.get_child_count()
			Dialogue._on_choice((rot + picks) % n)
			picks += 1
		else:
			Dialogue._advance()
			shown += 1
		await wait_physics_frames(1)
	return {"done": not Dialogue.is_active(), "shown": shown}


func test_every_dialogue_plays_in_the_real_ui() -> void:
	for id in H.DialogueData.list_ids():
		for rot in 3:
			GameState.reset()
			var r: Dictionary = await _click_through(id, rot)
			assert_true(r["done"], "%s (nhánh %d): giao diện hội thoại không đi tới cuối" % [id, rot])
			_stop_dialogue()
	assert_true(Dialogue.history.size() > 50, "nhật ký hội thoại phải ghi lại các câu đã đọc")


func test_every_character_pose_renders() -> void:
	var chars := H.load_data(H.DialogueData.CHAR_PATH)
	var count := 0
	for c in chars:
		for p in chars[c].get("poses", {}):
			Dialogue._show_actor(str(c), "%s@center" % p)
			count += 1
			await wait_physics_frames(1)
			var a = Dialogue._actors.get(str(c))
			assert_not_null(a, "%s/%s không lên sân khấu" % [c, p])
		_stop_dialogue()
	assert_gt(count, 80, "quá ít biểu cảm được thử")


func test_every_scene_runs() -> void:
	for path in SCENES:
		GameState.reset()
		var sc: PackedScene = load(path)
		assert_not_null(sc, "không tải được " + path)
		var node := sc.instantiate()
		add_child(node)
		await wait_physics_frames(45)
		assert_true(is_instance_valid(node) and node.is_inside_tree(), path + " tự biến mất")
		node.queue_free()
		await wait_physics_frames(2)
		_stop_dialogue()


func test_evening_map_runs() -> void:
	GameState.reset()
	Story.current_step = "roam:evening"
	var node: Node = load("res://scenes/world/cafe.tscn").instantiate()
	add_child(node)
	await wait_physics_frames(45)
	assert_true(GameState.has_flag("is_evening"), "map buổi tối phải bật cờ is_evening")
	node.queue_free()
	await wait_physics_frames(2)
	_stop_dialogue()
	Story.current_step = ""


func test_hud_meters_follow_game_state() -> void:
	Hud.set_visible_hud(true)
	GameState.reset()
	GameState.apply({"heart": 5, "brain": 2})
	await wait_physics_frames(5)
	assert_eq(GameState.get_var("heart"), 5)
	Hud.set_visible_hud(false)
	GameState.reset()
