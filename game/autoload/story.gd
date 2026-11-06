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
var _fade_tw: Tween  # tween đang chỉnh màn đen (thẻ chữ dừng nó lại -> không lộ HUD giữa chừng)
var _card_tw: Tween


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


## Chơi mới một tập (mặc định Tập 1).
func new_game(ep: int = 1) -> void:
	var info: Dictionary = Steps.EPISODES.get(ep, Steps.EPISODES[1])
	GameState.start_episode(ep, str(info["first"]))
	GameState.delete_save()
	goto(str(info["first"]))


func continue_game() -> void:
	if GameState.load_game():
		goto(GameState.step, false)


func goto(step: String, save: bool = true) -> void:
	if busy:
		return
	busy = true
	current_step = step
	var k := Steps.kind(step)
	var saved := false
	# Lưu điểm kiểm tra (mini-game pha chế quay lại map nên không lưu ở đó)
	if k in ["vn", "roam", "phone"] or step in ["mini:debug", "mini:heartbeat"]:
		GameState.step = step
		if save:
			saved = GameState.save_game()
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
	if _card_tw == null or not _card_tw.is_running():  # cảnh mở bằng thẻ chữ -> để thẻ chữ tự mở màn
		_fade_tw = create_tween()
		_fade_tw.tween_property(_fade, "modulate:a", 0.0, 0.4)
	await get_tree().create_timer(0.4).timeout
	busy = false
	if saved and k != "phone":  # người chơi yên tâm: tiến độ đã được lưu
		Hud.toast("Đã tự lưu", Ui.TEXT_SOFT)


## Thẻ chữ toàn màn hình (vd "15:00 — Quán Gờ 23"). Trả về Tween -> `await tween.finished`.
## Chạm / bấm phím để tua nhanh thẻ chữ.
func show_card(text: String, hold: float = 1.1) -> Tween:
	if _fade_tw and _fade_tw.is_valid():
		_fade_tw.kill()
	_card.text = text
	var tw := create_tween()
	tw.tween_property(_fade, "modulate:a", 0.94, 0.25)
	tw.parallel().tween_property(_card, "modulate:a", 1.0, 0.3)
	tw.tween_interval(hold)
	tw.tween_property(_card, "modulate:a", 0.0, 0.3)
	tw.parallel().tween_property(_fade, "modulate:a", 0.0, 0.35)
	_card_tw = tw
	return tw


func _input(ev: InputEvent) -> void:
	if _card_tw == null or not _card_tw.is_running():
		return
	var tap: bool = ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT
	if tap or ev.is_action_pressed("interact"):
		_card_tw.set_speed_scale(6.0)
		get_viewport().set_input_as_handled()


func minigame_done(game: String, result: Dictionary) -> void:
	GameState.apply(Steps.minigame_effects(game, result))
	goto(str(Steps.MINI_NEXT.get(game, "title")))


func phone_done(id: String) -> void:
	goto(str(Steps.PHONE_NEXT.get(id, "ending")))
