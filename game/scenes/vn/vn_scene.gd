extends Control
## Cảnh visual novel: chỉ cần gọi Dialogue.start(<id>), phần còn lại do Dialogue lo.
## Bước truyện "vn:<id>" -> Story chuyển tới cảnh này.

const Steps := preload("res://scripts/story_steps.gd")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Hud.set_visible_hud(true)
	var id := Steps.arg(Story.current_step)
	if id == "":
		id = _debug_arg()
	if id != "":
		Dialogue.start(id)


func _debug_arg() -> String:
	# Chạy thẳng cảnh này để thử: ... vn_scene.tscn -- --talk=ep1_s2
	# Thêm cờ để thử nhánh: ... -- --talk=ep1_s4 --flags=has_umbrella,umbrella_black
	var id := "ep1_s1"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--talk="):
			id = a.substr(7)
		elif a.begins_with("--flags="):
			for f in a.substr(8).split(",", false):
				GameState.set_flag(f)
	return id
