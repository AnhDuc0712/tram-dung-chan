extends GutTest
## Các lỗi từ góp ý chơi thử (memory/fix.md) — chặn không cho quay lại.


func after_each() -> void:
	GameState.settings["timer_scale"] = 1.5
	if Dialogue.is_active():
		Dialogue._finish()
	Hud.close_all()


func test_popups_draw_above_cat() -> void:
	# mèo Nlong ở HUD từng vẽ đè tiêu đề "Nhật ký hội thoại"
	assert_lt(Hud._cat.get_index(), Hud._overlay.get_index(), "mèo phải nằm dưới lớp phủ menu")
	assert_lt(Hud._thought.get_index(), Hud._overlay.get_index())
	for p in [Hud._log_panel, Hud._pause_panel, Hud._settings_panel]:
		assert_gt(p.get_index(), Hud._overlay.get_index())


func test_choices_sit_above_dialogue_box_not_on_faces() -> void:
	var cb: VBoxContainer = Dialogue._choice_box
	assert_eq(cb.alignment, BoxContainer.ALIGNMENT_END, "nút lựa chọn dồn xuống sát hộp thoại")
	assert_lte(cb.position.y + cb.size.y, Dialogue._box.position.y, "không đè lên hộp thoại")
	assert_lte(cb.size.x, 560.0, "đủ hẹp để không che mặt hai nhân vật hai bên")


func _open_qte() -> void:
	Dialogue.start("ep1_s1")
	Dialogue._runner.goto("qte")
	Dialogue._show_current()
	Dialogue._finish_typing()


func test_timed_choice_scales_with_setting() -> void:
	GameState.settings["timer_scale"] = 1.5
	_open_qte()
	assert_almost_eq(Dialogue._choice_time, 4.5 * 1.5, 0.01, "mặc định dài hơn 1,5 lần")
	Dialogue._finish()
	GameState.settings["timer_scale"] = 0.0
	_open_qte()
	assert_eq(Dialogue._choice_time, 0.0, "Không giới hạn thời gian -> không đếm giờ")
	assert_false(Dialogue._timer_bar.visible)


func test_duc_default_pose_is_not_waving() -> void:
	var poses: Dictionary = Dialogue.characters["duc"]["poses"]
	for p in ["normal", "worried", "sad", "think", "deadpan"]:
		var img := str(poses.get(p, {}).get("img", ""))
		assert_false(img.begins_with("duc_front"), "Anh Đức '%s' không được vẫy tay (%s)" % [p, img])
	assert_false(str(Dialogue.characters["kyky"]["poses"]["normal"]["img"]).contains("wave"))


func test_talk_prompt_names_the_person() -> void:
	var cafe = load("res://scenes/world/cafe.gd").new()
	assert_eq(cafe._talk_label({"id": "m", "label": "Nói chuyện"}), "Nói chuyện với Chị M")
	assert_eq(cafe._talk_label({"id": "kyky2", "label": "Nói chuyện"}), "Nói chuyện với KyKy")
	assert_eq(cafe._talk_label({"id": "cp_girl", "label": "Cặp đôi cấp 3"}), "Cặp đôi cấp 3")
	cafe.free()


func test_new_settings_have_defaults() -> void:
	for k in ["timer_scale", "text_size", "auto", "shake"]:
		assert_true(GameState.settings.has(k), "thiếu cài đặt " + k)


func test_new_drinks_exist() -> void:
	var d: Dictionary = load("res://scripts/dialogue/dialogue_data.gd").load_json("res://data/minigames/barista.json")
	for id in ["cacao_ice", "matcha", "matcha_cheese"]:
		assert_true(d["drinks"].has(id), "thiếu món " + id)
