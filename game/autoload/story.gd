extends CanvasLayer
## Điều phối mạch truyện: chuyển giữa các bước (VN, đi lại, mini-game, điện thoại, kết thúc)
## kèm hiệu ứng mờ dần. Autoload "Story".
##   Story.goto("roam:day")
##   Story.minigame_done("barista", {"drink": "cacao", "art": "smile"})

const Steps := preload("res://scripts/story_steps.gd")

var current_step := ""
var busy := false
var _fade: ColorRect
var _card: Label


func _ready() -> void:
	layer = 50
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fade = ColorRect.new()
	_fade.color = Color(0.08, 0.05, 0.04, 1)
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.modulate.a = 0.0
	add_child(_fade)
	_card = Label.new()
	_card.set_anchors_preset(Control.PRESET_FULL_RECT)
	_card.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_card.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_card.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card.add_theme_font_size_override("font_size", 46)
	_card.add_theme_color_override("font_color", Color("fff1dc"))
	_card.modulate.a = 0.0
	_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_card)
	_card.add_theme_font_override.call_deferred("font", Ui.font_title)


func new_game() -> void:
	GameState.reset()
	GameState.delete_save()
	goto(GameState.FIRST_STEP)


func continue_game() -> void:
	if GameState.load_game():
		goto(GameState.step, false)


func goto(step: String, save: bool = true) -> void:
	if busy:
		return
	busy = true
	current_step = step
	var k := Steps.kind(step)
	# Lưu điểm kiểm tra (mini-game pha chế quay lại map nên không lưu ở đó)
	if k in ["vn", "roam", "phone"] or step in ["mini:debug", "mini:heartbeat"]:
		GameState.step = step
		if k != "roam":
			GameState.has_position = false
		if save:
			GameState.save_game()
	var scene := Steps.scene_for(step)
	if scene == "":
		push_error("Story: bước không hợp lệ '%s'" % step)
		busy = false
		return
	Hud.set_objective("")
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 1.0, 0.45)
	await tw.finished
	get_tree().paused = false
	Dialogue.clear_stage()
	get_tree().change_scene_to_file(scene)
	await get_tree().process_frame
	await get_tree().process_frame
	var tw2 := create_tween()
	tw2.tween_property(_fade, "modulate:a", 0.0, 0.5)
	await tw2.finished
	busy = false


## Thẻ chữ toàn màn hình (vd "15:00 — Quán Gờ 23"). Trả về Tween -> `await tween.finished`.
func show_card(text: String, hold: float = 1.6) -> Tween:
	_card.text = text
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 0.94, 0.35)
	tw.parallel().tween_property(_card, "modulate:a", 1.0, 0.45)
	tw.tween_interval(hold)
	tw.tween_property(_card, "modulate:a", 0.0, 0.4)
	tw.parallel().tween_property(_fade, "modulate:a", 0.0, 0.5)
	return tw


func minigame_done(game: String, result: Dictionary) -> void:
	GameState.apply(Steps.minigame_effects(game, result))
	goto(str(Steps.MINI_NEXT.get(game, "title")))


func phone_done(id: String) -> void:
	goto(str(Steps.PHONE_NEXT.get(id, "ending")))
