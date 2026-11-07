extends SceneTree
## Test headless: godot --headless --path game -s res://tests/run_tests.gd
## Kiểm tra dữ liệu (kịch bản, nhân vật, bản đồ, điện thoại) + chơi thử tự động cả 5 kết thúc.

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const DialogueRunner := preload("res://scripts/dialogue/dialogue_runner.gd")
const Steps := preload("res://scripts/story_steps.gd")
const GameStateScript := preload("res://autoload/game_state.gd")

var passed := 0
var failed := 0


func _init() -> void:
	var tests := [
		"test_all_dialogue_valid", "test_story_steps", "test_character_assets", "test_roam_data",
		"test_phone_data", "test_minigame_data", "test_conditions_and_effects", "test_save_roundtrip",
		"test_route_secret", "test_route_umbrella", "test_route_wet", "test_route_tutor", "test_route_kind",
		"test_timeout_choice", "test_ep2_secret", "test_ep2_sweet", "test_ep2_jealous", "test_ep2_jacket",
		"test_ep2_comedy", "test_ep3_logic", "test_ep3_paris", "test_ep3_quan", "test_ep3_tin", "test_ep3_hoang",
	]
	for t in tests:
		var before := failed
		call(t)
		if failed == before:
			passed += 1
			print("  OK   ", t)
		else:
			print("  FAIL ", t)
	print("\n%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)


func expect(cond: bool, msg: String) -> void:
	if not cond:
		failed += 1
		printerr("    ✗ ", msg)


func new_state():
	var s = GameStateScript.new()
	s.reset()
	s.save_path = "user://test_save.json"
	return s


func _step_checker() -> Callable:
	var ids := DialogueData.list_ids()
	var phones := DialogueData.list_ids("res://data/phone/")
	return func(step: String) -> String: return Steps.validate_step(step, ids, phones)


# ---------------------------------------------------------------- dữ liệu
func test_all_dialogue_valid() -> void:
	var endings := DialogueData.load_json(DialogueData.ENDINGS_PATH)
	var chars := DialogueData.load_json(DialogueData.CHAR_PATH)
	expect(not endings.is_empty(), "endings.json rỗng")
	expect(not chars.is_empty(), "characters.json rỗng")
	var ids := DialogueData.list_ids()
	expect(ids.size() >= 10, "quá ít file hội thoại")
	var used_endings := {}
	for id in ids:
		var data := DialogueData.load_dialogue(id)
		expect(not data.is_empty(), "%s.json không đọc được" % id)
		for e in DialogueData.validate(data, endings, chars, _step_checker()):
			expect(false, "%s.json: %s" % [id, e])
		for k in data.get("nodes", {}):
			var eff = data["nodes"][k].get("effects", {})
			if eff is Dictionary and eff.has("ending"):
				used_endings[str(eff["ending"])] = true
	for e in endings:
		expect(used_endings.has(e), "ending '%s' không được kịch bản nào dùng" % e)


func test_story_steps() -> void:
	var check := _step_checker()
	for k in Steps.MINI_NEXT:
		expect(check.call(Steps.MINI_NEXT[k]) == "", "MINI_NEXT[%s] sai" % k)
		expect(ResourceLoader.exists(Steps.scene_for("mini:" + k)), "thiếu scene mini-game " + k)
	for k in Steps.PHONE_NEXT:
		expect(check.call("phone:" + k) == "", "thiếu điện thoại " + k)
	for k in Steps.SCENES:
		expect(ResourceLoader.exists(Steps.SCENES[k]), "thiếu scene " + str(Steps.SCENES[k]))
	expect(check.call(GameStateScript.FIRST_STEP) == "", "FIRST_STEP sai")
	expect(check.call("vn:khong_co") != "", "validate_step phải bắt lỗi id sai")


func test_character_assets() -> void:
	var chars := DialogueData.load_json(DialogueData.CHAR_PATH)
	for id in chars:
		var poses: Dictionary = chars[id].get("poses", {})
		expect(poses.has("normal"), "%s thiếu biểu cảm 'normal'" % id)
		for p in poses:
			var img := str(poses[p].get("img", ""))
			expect(ResourceLoader.exists("res://assets/art/chars/%s.png" % img), "%s/%s: thiếu ảnh %s.png" % [id, p, img])
			var ins := str(poses[p].get("inset", ""))
			if ins != "":
				expect(ResourceLoader.exists("res://assets/art/chars/%s.png" % ins), "%s/%s: thiếu ảnh inset %s.png" % [id, p, ins])
			var em := str(poses[p].get("emote", ""))
			expect(DialogueData.KNOWN_EMOTES.has(em), "%s/%s: emote lạ '%s'" % [id, p, em])
	for bg in ["cafe_map", "cafe_day", "cafe_sunset", "street_rain"]:
		expect(ResourceLoader.exists("res://assets/art/bg/%s.jpg" % bg), "thiếu nền " + bg)


func test_roam_data() -> void:
	for m in ["cafe", "street", "campus"]:
		_check_roam_map(m)


func _check_roam_map(map_id: String) -> void:
	var d := DialogueData.load_json("res://data/roam/%s.json" % map_id)
	expect(ResourceLoader.exists("res://assets/art/bg/%s.jpg" % d.get("map", "")), map_id + ": thiếu ảnh bản đồ")
	for v in (d.get("intros", {}) as Dictionary):
		expect(DialogueData.list_ids().has(str(d["intros"][v][0])), "%s: intro %s thiếu hội thoại" % [map_id, v])
	var poly := PackedVector2Array()
	for p in d.get("walk", []):
		poly.append(Vector2(p[0], p[1]))
	expect(poly.size() >= 3, "vùng đi được không hợp lệ")
	var obs: Array = []
	for r in d.get("obstacles", []):
		obs.append(Rect2(r[0], r[1], r[2], r[3]))
	var ids := DialogueData.list_ids()
	var all: Array = d.get("npcs", []) + d.get("spots", [])
	for e in all:
		expect(ids.has(str(e.get("dialogue", ""))), "%s: thiếu hội thoại %s" % [e.get("id"), e.get("dialogue")])
		if e.has("stand"):
			var s := Vector2(e["stand"][0], e["stand"][1])
			expect(Geometry2D.is_point_in_polygon(s, poly), "%s: điểm đứng nằm ngoài vùng đi được" % e.get("id"))
			for r in obs:
				expect(not (r as Rect2).has_point(s), "%s: điểm đứng nằm trong vật cản" % e.get("id"))
	var pl: Dictionary = d.get("player", {})
	for v in pl.get("start", {}):
		var p: Array = pl["start"][v]
		expect(Geometry2D.is_point_in_polygon(Vector2(p[0], p[1]), poly), "điểm xuất phát '%s' ngoài vùng đi được" % v)


func test_phone_data() -> void:
	var chars := DialogueData.load_json(DialogueData.CHAR_PATH)
	for id in DialogueData.list_ids("res://data/phone/"):
		var d := DialogueData.load_json("res://data/phone/%s.json" % id)
		var threads: Array = d.get("threads", [])
		expect(not threads.is_empty(), "phone %s: không có threads" % id)
		for th in threads:
			var msgs: Array = th.get("messages", [])
			for m in msgs:
				_check_phone_msg(m, chars, th, id)


func _check_phone_msg(m: Dictionary, chars: Dictionary, th: Dictionary, id: String) -> void:
	if m.has("choices"):
		for c in m["choices"]:
			expect(c.has("text"), "phone %s: lựa chọn thiếu text" % id)
			if c.has("sticker"):
				expect(ResourceLoader.exists("res://assets/art/chars/%s.png" % c["sticker"]), "phone %s: thiếu sticker %s" % [id, c["sticker"]])
			for r in c.get("reply", []):
				_check_phone_msg(r, chars, th, id)
		return
	var who := str(m.get("from", ""))
	expect(chars.has(who), "phone %s: người gửi lạ '%s'" % [id, who])
	expect((th.get("members", {}) as Dictionary).has(who), "phone %s: '%s' không có trong members" % [id, who])
	if m.has("image"):
		var img := str(m["image"])
		expect(img in ["chibi", "turtle", "nlong"] or ResourceLoader.exists("res://assets/art/chars/%s.png" % img), "phone %s: ảnh lạ %s" % [id, img])


func test_minigame_data() -> void:
	var b := DialogueData.load_json("res://data/minigames/barista.json")
	var ings: Dictionary = b.get("ingredients", {})
	for dk in b.get("drinks", {}):
		for n in b["drinks"][dk].get("needs", []):
			expect(ings.has(n), "barista: món %s cần nguyên liệu lạ %s" % [dk, n])
		# mỗi món (trừ ca cao nóng = mặc định) phải có phản ứng riêng của KyKy ở Tập 1 cảnh 2
		if dk != "cacao":
			var s2 := FileAccess.get_file_as_string("res://data/dialogue/ep1_s2.json")
			expect(s2.contains("\"drink_%s\"" % dk), "barista: món %s chưa có câu phản ứng trong ep1_s2.json" % dk)
	var dbg := DialogueData.load_json("res://data/minigames/debug_ep1.json")
	for r in dbg.get("rounds", []):
		expect(int(r.get("bug", -1)) >= 0 and int(r["bug"]) < (r.get("lines", []) as Array).size(), "debug: chỉ số dòng bug sai")


# ---------------------------------------------------------------- logic
func test_conditions_and_effects() -> void:
	var s = new_state()
	expect(s.check({}), "điều kiện rỗng phải đúng")
	s.apply({"heart": 3, "brain": 1, "add": {"nlong": 2}, "set_flags": ["a", "b"], "ending": "gia_su"})
	expect(s.get_var("heart") == 3 and s.get_var("brain") == 1 and s.get_var("nlong") == 2, "apply số")
	expect(s.ending_id == "gia_su", "apply ending")
	expect(s.check({"flags": ["a"], "min": {"heart": 3}}), "min >=")
	expect(not s.check({"min": {"heart": 4}}), "min phải sai")
	expect(s.check({"below": {"brain": 2}}), "below <")
	expect(not s.check({"below": {"brain": 1}}), "below phải sai")
	s.apply({"clear_flags": ["a"]})
	expect(s.check({"not_flags": ["a"]}), "clear_flags")
	var eff := Steps.minigame_effects("barista", {"drink": "cacao", "art": "turtle", "weird": false})
	s.apply(eff)
	expect(s.has_flag("drink_made") and s.has_flag("drink_cacao") and s.has_flag("art_turtle"), "kết quả pha chế")
	s.free()


func test_save_roundtrip() -> void:
	var s = new_state()
	s.apply({"heart": 5, "set_flags": ["x"]})
	s.step = "roam:evening"
	s.player_position = Vector2(12, 34)
	s.has_position = true
	expect(s.save_game(), "ghi save")
	var t = new_state()
	expect(t.load_game(), "đọc save")
	expect(t.get_var("heart") == 5 and t.has_flag("x") and t.step == "roam:evening", "dữ liệu save")
	expect(t.player_position == Vector2(12, 34), "vị trí save")
	t.delete_save()
	expect(not t.has_save(), "xoá save")
	s.free()
	t.free()


## Chạy một hội thoại với danh sách lựa chọn (số thứ tự trong các lựa chọn đang hiện; -1 = hết giờ).
## Trả về bước truyện "then" (nếu có).
func play(id: String, s, picks: Array = []) -> String:
	var r = DialogueRunner.new(DialogueData.load_dialogue(id), s)
	r.begin()
	var guard := 0
	var i := 0
	while not r.finished and guard < 500:
		guard += 1
		if r.choices().is_empty():
			r.advance()
		else:
			if i >= picks.size():
				expect(false, "%s: hết lựa chọn tại node '%s'" % [id, r.current_id])
				return ""
			var p := int(picks[i])
			i += 1
			if p < 0:
				r.goto(str(r.current.get("timeout", "")))
			else:
				r.choose(p)
	expect(i == picks.size(), "%s: còn thừa lựa chọn chưa dùng (%d/%d)" % [id, i, picks.size()])
	return r.then_step


func run_mini(s, game: String, result: Dictionary) -> String:
	s.apply(Steps.minigame_effects(game, result))
	return str(Steps.MINI_NEXT[game])


func _common_evening(s) -> void:
	expect(play("ep1_s3c", s) == "roam:evening", "s3c -> roam:evening")
	s.set_flag("is_evening")
	play("roam_evening_intro", s)


func test_route_secret() -> void:
	var s = new_state()
	expect(play("ep1_s1", s, [0, 0, 1]) == "roam:day", "s1 -> roam:day")
	play("roam_day_intro", s)
	play("roam_nlong", s)
	play("roam_nlong", s)
	play("roam_nlong", s)
	play("roam_guitar", s)
	play("roam_pen", s)
	play("roam_books", s, [0])
	play("roam_kyky", s, [0])
	expect(play("roam_m", s, [0]) == "mini:barista", "chị M -> pha chế")
	run_mini(s, "barista", {"drink": "cacao", "art": "turtle"})
	expect(play("roam_kyky", s, [0]) == "vn:ep1_s2", "mang nước -> s2")
	expect(play("ep1_s2", s, [0]) == "vn:ep1_s3", "s2 -> s3")
	expect(play("ep1_s3", s, [0]) == "mini:debug", "s3 -> debug")
	run_mini(s, "debug", {"correct": 3})
	expect(play("ep1_s3b", s, [1]) == "mini:heartbeat", "s3b -> heartbeat")
	run_mini(s, "heartbeat", {"hits": 0})
	_common_evening(s)
	play("roam_staff", s)
	play("roam_nlong", s)
	expect(s.has_flag("fed_treat"), "đã đút súp")
	expect(play("roam_kyky", s, [0]) == "vn:ep1_s4", "ra hiên -> s4")
	expect(play("ep1_s4", s, [0, 0]) == "phone:ep1", "s4 -> điện thoại")
	expect(s.ending_id == "hoang_thuong", "kết bí mật (heart=%d nlong=%d)" % [s.get_var("heart"), s.get_var("nlong")])
	s.free()


func test_route_umbrella() -> void:
	var s = new_state()
	play("ep1_s1", s, [1, 2, 0])
	play("roam_day_intro", s)
	play("roam_nlong", s)
	play("roam_guitar", s)
	play("roam_kyky", s, [0])
	play("roam_m", s, [0])
	run_mini(s, "barista", {"drink": "cacao", "art": "smile"})
	play("roam_kyky", s, [0])
	play("ep1_s2", s, [0])
	play("ep1_s3", s, [1])
	run_mini(s, "debug", {"correct": 1})
	play("ep1_s3b", s, [2])
	run_mini(s, "heartbeat", {"hits": 2})
	_common_evening(s)
	play("roam_m", s, [0])  # mượn ô hồng của chị M
	expect(s.has_flag("umbrella_pink"), "mượn ô hồng")
	play("roam_door", s, [0])
	play("ep1_s4", s, [0, 0])
	expect(s.ending_id == "duoi_mot_chiec_o", "kết Dưới một chiếc ô (heart=%d)" % s.get_var("heart"))
	s.free()


func test_route_wet() -> void:
	var s = new_state()
	play("ep1_s1", s, [0, 1, 0])
	play("roam_day_intro", s)
	play("roam_m", s, [1, 0])
	run_mini(s, "barista", {"drink": "peach", "art": "none"})
	play("roam_kyky", s, [0])
	play("ep1_s2", s, [2])
	play("ep1_s3", s, [0])
	run_mini(s, "debug", {"correct": 2})
	play("ep1_s3b", s, [1])
	run_mini(s, "heartbeat", {"hits": 1})
	_common_evening(s)
	expect(play("roam_kyky", s, [0]) == "vn:ep1_s4", "ra hiên không ô")
	play("ep1_s4", s, [0])
	expect(s.ending_id == "uot_sung", "kết Ướt sũng (heart=%d)" % s.get_var("heart"))
	s.free()


func test_route_tutor() -> void:
	var s = new_state()
	play("ep1_s1", s, [1, 2, 1])
	play("roam_day_intro", s)
	play("roam_books", s, [0])
	expect(play("roam_kyky", s, [1]) == "vn:ep1_s2", "dạy luôn không pha nước")
	play("ep1_s2", s, [0])
	play("ep1_s3", s, [2])
	run_mini(s, "debug", {"correct": 3})
	play("ep1_s3b", s, [0])
	run_mini(s, "heartbeat", {"hits": 3})
	_common_evening(s)
	play("roam_kyky", s, [0])
	play("ep1_s4", s, [2])
	expect(s.ending_id == "gia_su", "kết Gia sư (heart=%d brain=%d)" % [s.get_var("heart"), s.get_var("brain")])
	s.free()


func test_route_kind() -> void:
	var s = new_state()
	play("ep1_s1", s, [1, 2, 1])
	play("roam_day_intro", s)
	play("roam_kyky", s, [1])
	play("ep1_s2", s, [0])
	play("ep1_s3", s, [0])
	run_mini(s, "debug", {"correct": 0})
	play("ep1_s3b", s, [0])
	run_mini(s, "heartbeat", {"hits": 2})
	_common_evening(s)
	play("roam_door", s, [0])
	play("ep1_s4", s, [2])
	expect(s.ending_id == "nguoi_tot_bung", "kết Người lạ tốt bụng (heart=%d brain=%d)" % [s.get_var("heart"), s.get_var("brain")])
	s.free()


func test_timeout_choice() -> void:
	var s = new_state()
	play("ep1_s1", s, [-1, 0, 0])
	expect(s.has_flag("notebook_wet"), "hết giờ -> sổ rơi vào cà phê")
	s.free()


# ---------------------------------------------------------------- Tập 2
## Bấm các lựa chọn trong điện thoại (mỗi khối "choices" lấy 1 chỉ số) và áp hiệu ứng.
func phone_pick(s, id: String, picks: Array) -> void:
	var d := DialogueData.load_json("res://data/phone/%s.json" % id)
	var i := 0
	for th in d.get("threads", []):
		for m in th.get("messages", []):
			if (m as Dictionary).has("choices"):
				s.apply(m["choices"][int(picks[i])].get("effects", {}))
				i += 1
	expect(i == picks.size(), "%s: số lựa chọn điện thoại không khớp" % id)


func ep2_state():
	var s = new_state()
	s.start_episode(2, "phone:ep2_night")
	return s


## Buổi sáng chung cho mọi tuyến Tập 2 (tới hết mini-game 1 + cảnh chạm tay).
func ep2_morning(s, phone: Array, s1: int, extra: Callable, nlong_res: Dictionary, s1b: int) -> void:
	phone_pick(s, "ep2_night", phone)
	expect(str(Steps.PHONE_NEXT["ep2_night"]) == "vn:ep2_s1", "điện thoại -> s1")
	expect(play("ep2_s1", s, [s1]) == "roam:ep2_morning", "s1 -> roam sáng")
	play("roam_ep2m_intro", s)
	expect(s.has_flag("ep2m_intro_done"), "intro sáng bật cờ")
	extra.call()
	expect(play("roam_ep2m_door", s, [0]) == "vn:ep2_s1k", "cửa -> s1k")
	expect(play("ep2_s1k", s) == "mini:nlong", "s1k -> mini nlong")
	expect(run_mini(s, "nlong", nlong_res) == "vn:ep2_s1b", "nlong -> s1b")
	expect(play("ep2_s1b", s, [s1b]) == "vn:ep2_s2", "s1b -> s2")


func ep2_midday(s, s2: int, s3: int, logic: int, afternoon: Callable, dark: int, s4b: int) -> void:
	expect(play("ep2_s2", s, [s2]) == "vn:ep2_s3", "s2 -> s3")
	expect(play("ep2_s3", s, [s3]) == "mini:logic", "s3 -> logic")
	expect(run_mini(s, "logic", {"first_try": logic}) == "vn:ep2_s3b", "logic -> s3b")
	expect(play("ep2_s3b", s) == "roam:ep2_afternoon", "s3b -> roam chiều")
	play("roam_ep2a_intro", s)
	afternoon.call()
	expect(play("roam_ep2a_m", s, [0]) == "vn:ep2_s4", "chị M -> s4")
	expect(play("ep2_s4", s) == "mini:dark", "s4 -> dark")
	expect(run_mini(s, "dark", {"hits": dark}) == "vn:ep2_s4b", "dark -> s4b")
	expect(play("ep2_s4b", s, [s4b]) == "roam:ep2_night", "s4b -> phố đêm")
	play("roam_ep2n_intro", s)


func ep2_finish(s, hotpot_pick: int, want: String) -> void:
	expect(play("roam_ep2n_hotpot", s, [hotpot_pick]) == "vn:ep2_end", "lẩu -> kết")
	expect(play("ep2_end", s) == "phone:ep2_end", "kết -> điện thoại")
	var info := "heart=%d tram=%d jealous=%d nlong=%d" % [s.get_var("heart"), s.get_var("tram"), s.get_var("jealous"), s.get_var("nlong")]
	expect(s.ending_id == want, "Tập 2: muốn %s, được %s (%s)" % [want, s.ending_id, info])


func test_ep2_secret() -> void:
	var s = ep2_state()
	ep2_morning(s, [1, 0], 1, func() -> void:
		play("roam_ep2_nlong", s)
		play("roam_ep2m_barista", s, [0]), {"pets": 3, "treat": true}, 0)
	ep2_midday(s, 0, 0, 3, func() -> void: play("roam_ep2a_tram", s, [0, 1]), 3, 0)
	expect(play("roam_ep2n_arcade", s, [0]) == "", "khu trò chơi là hẹn hò trong map")
	expect(s.has_flag("claw_win"), "gắp được gấu bông")
	ep2_finish(s, 0, "ep2_gau")
	s.free()


func test_ep2_sweet() -> void:
	var s = ep2_state()
	ep2_morning(s, [1, 0], 1, func() -> void: play("roam_ep2m_barista", s, [1]), {"pets": 3, "treat": true}, 0)
	ep2_midday(s, 0, 0, 3, func() -> void: play("roam_ep2a_tram", s, [0, 1]), 3, 0)
	play("roam_ep2n_books", s, [0])
	ep2_finish(s, 0, "ep2_lau")
	s.free()


func test_ep2_jealous() -> void:
	var s = ep2_state()
	ep2_morning(s, [2, 1], 0, func() -> void: pass, {"pets": 1}, 1)
	ep2_midday(s, 2, 2, 1, func() -> void: play("roam_ep2a_kyky", s, [1]), 0, 2)
	play("roam_ep2n_park", s, [0, 1])
	ep2_finish(s, 0, "ep2_dua")
	s.free()


func test_ep2_jacket() -> void:
	var s = ep2_state()
	ep2_morning(s, [0, 0], 0, func() -> void: pass, {"pets": 2}, 1)
	ep2_midday(s, 2, 0, 0, func() -> void: pass, 0, 1)
	play("roam_ep2n_bus", s, [0])
	expect(s.has_flag("gave_jacket"), "khoác áo cho KyKy ở trạm xe buýt")
	ep2_finish(s, 0, "ep2_ao")
	s.free()


func test_ep2_comedy() -> void:
	var s = ep2_state()
	ep2_morning(s, [2, 1], 2, func() -> void: pass, {"pets": 0}, -1)
	ep2_midday(s, 2, 0, 0, func() -> void: pass, 0, 1)
	ep2_finish(s, 0, "ep2_nlong")
	s.free()


# ---------------------------------------------------------------- Tập 3
## Chơi trọn Tập 3 theo cấu hình o: s1, campus (danh sách [id hội thoại, lựa chọn]), exit, tie, rush, s3, sync, expo, s4.
func ep3_play(s, o: Dictionary) -> void:
	expect(play("ep3_s1", s, o["s1"]) == "roam:ep3_campus", "s1 -> sân trường")
	play("roam_ep3c_intro", s)
	expect(s.has_flag("ep3c_intro_done"), "intro sân trường bật cờ")
	for st in o["campus"]:
		play(str(st[0]), s, st[1])
	expect(play("roam_ep3c_exit", s, o["exit"]) == "vn:ep3_s2", "ra khỏi sân trường -> s2")
	expect(play("ep3_s2", s, [o["tie"]]) == "mini:rush", "s2 -> rush")
	expect(run_mini(s, "rush", o["rush"]) == "vn:ep3_s2b", "rush -> s2b")
	expect(play("ep3_s2b", s) == "vn:ep3_s3", "s2b -> s3")
	expect(play("ep3_s3", s, [o["s3"]]) == "mini:sync", "s3 -> sync")
	expect(run_mini(s, "sync", o["sync"]) == "vn:ep3_s3b", "sync -> s3b")
	expect(play("ep3_s3b", s) == "roam:ep3_expo", "s3b -> phố triển lãm")
	play("roam_ep3e_intro", s)
	expect(s.has_flag("ep3e_intro_done"), "intro phố triển lãm bật cờ")
	for st in o["expo"]:
		play(str(st[0]), s, st[1])
	expect(play("roam_ep3e_hai", s, [0]) == "vn:ep3_s4", "Hải -> s4")
	expect(play("ep3_s4", s, o["s4"]) == "vn:ep3_s5", "s4 -> s5")
	expect(play("ep3_s5", s) == "phone:ep3_end", "s5 -> điện thoại")


func ep3_good(s4: Array) -> Dictionary:
	return {
		"s1": [0, 0],
		"campus": [["roam_ep3c_student", [0]], ["roam_ep3c_teacher", []], ["roam_ep3c_tram", []], ["roam_ep3c_thao", []], ["roam_ep3c_bikes", []]],
		"exit": [], "tie": 0, "rush": {"served": 6, "perfect": 4}, "s3": 0, "sync": {"misses": 0},
		"expo": [["roam_ep3e_stall", [0]], ["roam_ep3e_keychain", [0]], ["roam_ep3e_tea", [0]]],
		"s4": s4,
	}


func ep3_check(s, want: String) -> void:
	var info := "heart=%d brain=%d respect=%d jealous=%d" % [s.get_var("heart"), s.get_var("brain"), s.get_var("respect"), s.get_var("jealous")]
	expect(s.ending_id == want, "Tập 3: muốn %s, được %s (%s)" % [want, s.ending_id, info])


func test_ep3_logic() -> void:
	var s = new_state()
	s.start_episode(3, "vn:ep3_s1")
	ep3_play(s, ep3_good([0, 2]))
	expect(s.has_flag("kyky_fixed_bug") and s.has_flag("junior_found") and s.has_flag("kyky_heard"), "cờ tuyến chính Tập 3")
	ep3_check(s, "ep3_loi_logic")
	s.free()


func test_ep3_paris() -> void:
	var s = new_state()
	s.start_episode(3, "vn:ep3_s1")
	ep3_play(s, ep3_good([0, 0]))
	expect(s.has_flag("kyky_goes"), "KyKy chọn đi")
	ep3_check(s, "ep3_paris")
	s.free()


func test_ep3_quan() -> void:
	var s = new_state()
	s.start_episode(3, "vn:ep3_s1")
	ep3_play(s, ep3_good([0, 1]))
	expect(s.has_flag("kyky_stays"), "KyKy chọn ở lại")
	ep3_check(s, "ep3_dong_chu_quan")
	s.free()


func test_ep3_tin() -> void:
	var s = new_state()
	s.start_episode(3, "vn:ep3_s1")
	ep3_play(s, ep3_good([2, 3]))  # "tôi muốn cô ấy ở lại" -> mở khoá lựa chọn "Đừng đi"
	expect(s.has_flag("said_dont_go"), "Đức nói “đừng đi”")
	ep3_check(s, "ep3_hoc_cach_tin")
	s.free()


func test_ep3_hoang() -> void:
	var s = new_state()
	s.start_episode(3, "vn:ep3_s1")
	ep3_play(s, {
		"s1": [1, 2], "campus": [], "exit": [0], "tie": 1, "rush": {"served": 2, "perfect": 0}, "s3": 1, "sync": {"misses": 3},
		"expo": [["roam_ep3e_stall", [1]], ["roam_ep3e_keychain", [1]]], "s4": [1, 2],
	})
	expect(s.has_flag("junior_left") and not s.has_flag("kyky_fixed_bug"), "tuyến lười: bỏ Junior, Đức sửa lỗi hộ")
	ep3_check(s, "ep3_hoang_thuong")
	s.free()
