extends GutTest
## Chế độ điện thoại: màn nhắc xoay ngang, nút "Tua", gợi ý "Chạm" trong quán, nút toàn màn hình,
## chạm vào khung gợi ý để tương tác, vùng chạm đủ lớn.

const H := preload("res://tests/gut/helpers.gd")
const TITLE := preload("res://scenes/ui/title_screen.tscn")

var _was_touch := false


func before_all() -> void:
	_was_touch = Ui.touch
	Story.busy = true  # chặn chuyển cảnh


func after_all() -> void:
	Ui.touch = _was_touch
	Story.busy = false
	Hud.update_orientation(Vector2(1280, 720))
	Dialogue._runner = null
	Dialogue.clear_stage()
	GameState.reset()


func test_portrait_shows_rotate_hint() -> void:
	Hud.update_orientation(Vector2(390, 844))  # iPhone cầm dọc
	assert_true(Hud.is_rotate_hint_visible(), "cầm dọc phải hiện nhắc xoay ngang")
	Hud.update_orientation(Vector2(844, 390))  # cầm ngang
	assert_false(Hud.is_rotate_hint_visible(), "cầm ngang thì ẩn")
	Hud.update_orientation(Vector2(1024, 768))  # iPad ngang
	assert_false(Hud.is_rotate_hint_visible())


func test_skip_button_fast_forwards_dialogue() -> void:
	GameState.reset()
	Dialogue.start("ep1_s3b")
	for _i in 120:
		if Dialogue._box.visible:
			break
		await wait_physics_frames(1)
	assert_true(Dialogue._skip_btn.visible, "nút Tua phải hiện khi có hội thoại")
	Dialogue._skip_btn.button_pressed = true
	assert_true(Dialogue._skip_on)
	var before: int = Dialogue._runner.visited.size()
	Engine.time_scale = 4.0
	await wait_seconds(1.0)
	Engine.time_scale = 1.0
	var after: int = Dialogue._runner.visited.size() if Dialogue._runner else 999
	assert_gt(after, before + 3, "bật Tua thì hội thoại phải tự chạy nhanh")
	Dialogue._runner = null
	Dialogue.clear_stage()
	Dialogue.start("roam_menu")
	assert_false(Dialogue._skip_on, "hội thoại mới phải tắt Tua")
	Dialogue._runner = null
	Dialogue.clear_stage()


func test_cafe_prompt_says_touch_and_is_tappable() -> void:
	Ui.touch = true
	GameState.reset()
	GameState.set_flag("day_intro_done")
	Story.current_step = "roam:day"
	Story.busy = false  # map ẩn gợi ý khi Story bận
	var cafe: Node = load("res://scenes/world/cafe.tscn").instantiate()
	add_child(cafe)
	await wait_physics_frames(3)
	# đặt Anh Đức đứng cạnh kệ sách
	var books: Dictionary = {}
	for e in cafe.entities:
		if e["id"] == "books":
			books = e
	cafe.player.global_position = books["stand"]
	await wait_physics_frames(3)
	cafe._process(0.016)  # một khung hình của map (tính chỗ gần nhất + gợi ý)
	assert_true(cafe._prompt.visible, "đứng gần phải hiện gợi ý")
	assert_string_starts_with(cafe._prompt_label.text, "Chạm", "điện thoại: gợi ý phải là 'Chạm', không phải phím E")
	var ev := InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	ev.pressed = true
	cafe._on_prompt_input(ev)
	assert_true(Dialogue.is_active(), "chạm vào khung gợi ý phải mở hội thoại")
	Dialogue._runner = null
	Dialogue.clear_stage()
	cafe.queue_free()
	await wait_physics_frames(2)
	Story.current_step = ""
	Story.busy = true
	Ui.touch = _was_touch


func test_title_has_fullscreen_on_touch() -> void:
	Ui.touch = true
	var title: Node = TITLE.instantiate()
	add_child(title)
	await wait_physics_frames(2)
	var texts: Array = []
	for b in title.find_children("*", "Button", true, false):
		texts.append((b as Button).text)
	assert_has(texts, "Toàn màn hình", "điện thoại/web: có nút toàn màn hình")
	assert_does_not_have(texts, "Thoát", "điện thoại/web: không có nút Thoát vô dụng")
	title.queue_free()
	await wait_physics_frames(2)
	Ui.touch = _was_touch


func test_buttons_are_big_enough_to_tap() -> void:
	# nút bấm >= 44px cao trên khung 720 (~ chuẩn 44pt của Apple khi thu nhỏ ra màn điện thoại ngang)
	var title: Node = TITLE.instantiate()
	add_child(title)
	await wait_physics_frames(2)
	var small: Array = []
	for b in title.find_children("*", "Button", true, false):
		var btn := b as Button
		if btn.is_visible_in_tree() and btn.size.y < 44:
			small.append("%s (%dpx)" % [btn.text, int(btn.size.y)])
	assert_eq(small, [], "nút quá nhỏ để chạm")
	title.queue_free()
	await wait_physics_frames(2)
