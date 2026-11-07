extends GutTest
## Nền trạng thái cho Tập 3: mang kết thúc Tập 2 sang, thanh chỉ số, lưu meta.

const H := preload("res://tests/gut/helpers.gd")


func _state() -> Node:
	var s: Node = H.new_state()
	autofree(s)
	return s


func test_ep3_carries_ep2_ending_flag() -> void:
	var s := _state()
	s.ep2_last = "ep2_ao"
	s.start_episode(3, "vn:ep3_s1")
	assert_eq(s.episode, 3)
	assert_true(s.has_flag("ep2_ao"))
	assert_true(s.has_flag("gave_jacket"), "kết áo khoác -> cờ gave_jacket")
	assert_eq(s.get_var("respect"), 0)


func test_ep3_gau_sets_claw_win() -> void:
	var s := _state()
	s.ep2_last = "ep2_gau"
	s.start_episode(3, "vn:ep3_s1")
	assert_true(s.has_flag("claw_win"), "Nlong Junior (gấu) dùng cho nhiệm vụ roam")


func test_ep3_default_when_ep2_not_played() -> void:
	var s := _state()
	s.start_episode(3, "vn:ep3_s1")
	assert_true(s.has_flag("ep2_lau"), "chưa chơi Tập 2 -> theo mạch chính thức")


func test_ending_records_last_per_episode() -> void:
	var s := _state()
	s.episode = 2
	s.unlock_ending("ep2_dua")
	assert_eq(s.ep2_last, "ep2_dua")
	s.episode = 3
	s.unlock_ending("ep3_paris")
	assert_eq(s.ep3_last, "ep3_paris")
	assert_eq(s.ep1_last, "", "không ghi đè kết Tập 1")


func test_bar_max_per_episode() -> void:
	var s := _state()
	s.episode = 1
	assert_eq(s.bar_max("heart"), 18)
	s.episode = 2
	assert_eq(s.bar_max("heart"), 28)
	s.episode = 3
	assert_eq(s.bar_max("heart"), 30)


func test_meta_roundtrip_keeps_ep2_ep3_last() -> void:
	var s := _state()
	s.ep2_last = "ep2_lau"
	s.ep3_last = "ep3_hoc_cach_tin"
	s._save_meta()
	s.ep2_last = ""
	s.ep3_last = ""
	s.load_meta()
	assert_eq(s.ep2_last, "ep2_lau")
	assert_eq(s.ep3_last, "ep3_hoc_cach_tin")
