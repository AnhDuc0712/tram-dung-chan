extends GutTest
## Anh Đức phải đi được: theo đường tìm sẵn (chạm/bấm chuột) và bằng phím; đứng yên khi đang hội thoại.

const PlayerScript := preload("res://scenes/world/player.gd")

var p: CharacterBody2D


func before_each() -> void:
	p = PlayerScript.new()
	add_child_autofree(p)
	p.setup(Ui.char_tex("duc_front"), Ui.char_tex("duc_walk"), 0.17)
	p.global_position = Vector2(100, 100)


func test_follows_tap_path_and_arrives() -> void:
	watch_signals(p)
	p.go_along(PackedVector2Array([Vector2(160, 100), Vector2(160, 160)]))
	await wait_seconds(1.2)
	assert_signal_emitted(p, "arrived", "phải tới nơi và báo 'arrived'")
	assert_almost_eq(p.global_position.x, 160.0, 7.0)
	assert_almost_eq(p.global_position.y, 160.0, 7.0)


func test_keyboard_moves_player() -> void:
	Input.action_press("move_right")
	await wait_seconds(0.5)
	Input.action_release("move_right")
	assert_gt(p.global_position.x, 140.0, "giữ phím phải đi sang phải")


func test_frozen_player_does_not_move() -> void:
	p.frozen = true
	p.go_along(PackedVector2Array([Vector2(300, 100)]))
	await wait_seconds(0.4)
	assert_almost_eq(p.global_position.x, 100.0, 0.5, "đang hội thoại thì không được đi")
