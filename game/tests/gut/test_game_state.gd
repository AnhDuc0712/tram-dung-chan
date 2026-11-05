extends GutTest
## Lưu / tải chịu được file hỏng, file cũ, thiếu trường; kết thúc đã mở khóa không mất; cài đặt an toàn.

const H := preload("res://tests/gut/helpers.gd")

var s: Node


func before_each() -> void:
	s = H.new_state()
	for p in [s.save_path, s.meta_path, s.settings_path]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))


func after_each() -> void:
	for p in [s.save_path, s.meta_path, s.settings_path]:
		if FileAccess.file_exists(p):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(p))
	s.free()


func _write(path: String, text: String) -> void:
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_string(text)
	f.close()


func test_no_save_means_no_continue() -> void:
	assert_false(s.has_save())
	assert_false(s.load_game())


func test_corrupt_save_is_ignored() -> void:
	_write(s.save_path, "{ đây không phải JSON")
	assert_false(s.load_game(), "save hỏng phải bị bỏ qua, không crash")
	assert_eq(s.step, H.GameStateScript.FIRST_STEP)


func test_old_version_save_is_ignored() -> void:
	_write(s.save_path, JSON.stringify({"version": 1, "step": "roam:day"}))
	assert_false(s.load_game())


func test_save_with_missing_fields_uses_defaults() -> void:
	_write(s.save_path, JSON.stringify({"version": H.GameStateScript.SAVE_VERSION}))
	assert_true(s.load_game())
	assert_eq(s.step, H.GameStateScript.FIRST_STEP)
	assert_eq(s.get_var("heart"), 0)
	assert_false(s.has_position)


func test_save_with_bad_position_is_safe() -> void:
	_write(s.save_path, JSON.stringify({"version": H.GameStateScript.SAVE_VERSION, "pos": [5], "step": "roam:day"}))
	assert_true(s.load_game())
	assert_false(s.has_position, "vị trí sai định dạng phải bị bỏ qua")


func test_saved_step_is_valid_story_step() -> void:
	# step lưu trong save phải luôn là bước hợp lệ (Story.continue_game dùng nó)
	var ids := H.DialogueData.list_ids()
	var phones := H.DialogueData.list_ids("res://data/phone/")
	for st in ["vn:ep1_s1", "roam:day", "roam:evening", "mini:debug", "mini:heartbeat", "phone:ep1"]:
		assert_eq(H.Steps.validate_step(st, ids, phones), "", st)


func test_full_roundtrip() -> void:
	s.apply({"heart": 7, "brain": 2, "add": {"nlong": 3}, "set_flags": ["umbrella_black", "fed_treat"]})
	s.step = "roam:evening"
	s.ending_id = "uot_sung"
	assert_true(s.save_game())
	var t := H.new_state()
	assert_true(t.load_game())
	assert_eq([t.get_var("heart"), t.get_var("brain"), t.get_var("nlong")], [7, 2, 3])
	assert_true(t.has_flag("umbrella_black") and t.has_flag("fed_treat"))
	assert_eq(t.step, "roam:evening")
	assert_eq(t.ending_id, "uot_sung")
	t.free()


func test_unlocked_endings_persist_and_no_duplicates() -> void:
	s.unlock_ending("gia_su")
	s.unlock_ending("gia_su")
	s.unlock_ending("")
	var t := H.new_state()
	t.load_meta()
	assert_eq(t.unlocked_endings, ["gia_su"])
	t.free()


func test_corrupt_meta_and_settings_are_ignored() -> void:
	_write(s.meta_path, "[[[")
	_write(s.settings_path, "null")
	s.load_meta()
	s.load_settings()
	assert_eq(s.unlocked_endings, [])
	assert_almost_eq(float(s.settings["music"]), 0.8, 0.001)


func test_settings_roundtrip_and_unknown_keys() -> void:
	_write(s.settings_path, JSON.stringify({"music": 0.25, "hack": 99, "text_speed": "60"}))
	s.load_settings()
	assert_almost_eq(float(s.settings["music"]), 0.25, 0.001)
	assert_almost_eq(float(s.settings["text_speed"]), 60.0, 0.001)
	assert_false(s.settings.has("hack"), "khóa lạ không được lọt vào cài đặt")


func test_effects_and_conditions_edge_cases() -> void:
	s.apply(null)
	s.apply("rác")
	s.apply({"heart": -3})
	assert_eq(s.get_var("heart"), -3)
	assert_true(s.check(null))
	assert_true(s.check({}))
	assert_false(s.check({"flags": ["chua_bat"]}))
	assert_true(s.check({"not_flags": ["chua_bat"]}))
	s.apply({"set_flags": ["a"], "clear_flags": ["a"]})
	assert_false(s.has_flag("a"), "clear_flags chạy sau set_flags")


func test_reset_clears_everything() -> void:
	s.apply({"heart": 5, "set_flags": ["x"], "ending": "gia_su"})
	s.step = "roam:day"
	s.reset()
	assert_eq(s.get_var("heart"), 0)
	assert_false(s.has_flag("x"))
	assert_eq(s.ending_id, "")
	assert_eq(s.step, H.GameStateScript.FIRST_STEP)
