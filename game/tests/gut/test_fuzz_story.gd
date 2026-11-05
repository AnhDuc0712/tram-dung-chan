extends GutTest
## "Người chơi ngẫu nhiên": chơi trọn Tập 1 hàng trăm lần với lựa chọn, thứ tự đi lại trong quán và
## kết quả mini-game NGẪU NHIÊN. Bắt lỗi kẹt game (soft-lock), bước truyện sai, kết thúc không hợp lệ.
## Cách đi lại mô phỏng đúng cafe.gd: chỉ nói chuyện với người / chỗ đang có mặt và thỏa điều kiện "if".

const H := preload("res://tests/gut/helpers.gd")
const RUNS := 400
const MAX_ROAM_ACTIONS := 200

var _roam: Dictionary
var _endings: Dictionary


func before_all() -> void:
	_roam = H.load_data("res://data/roam/cafe.json")
	_endings = H.load_data(H.DialogueData.ENDINGS_PATH)


func _available(s: Node, variant: String) -> Array:
	var out: Array = []
	for e in _roam.get("npcs", []) + _roam.get("spots", []):
		var w = e.get("when", [])
		var present: bool = (w as Dictionary).has(variant) if w is Dictionary else (w as Array).has(variant)
		if present and s.check(e.get("if", {})):
			out.append(str(e["dialogue"]))
	return out


## Chơi trọn một lượt. Trả về {ok, ending, why, trace, heart, brain, nlong}
func _play_once(seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var s := H.new_state()
	var step: String = H.GameStateScript.FIRST_STEP
	var trace: Array = []
	var res := {"ok": false, "ending": "", "why": "", "trace": trace}
	var ids := H.DialogueData.list_ids()
	var phones := H.DialogueData.list_ids("res://data/phone/")
	for _i in 300:
		trace.append(step)
		var err := H.Steps.validate_step(step, ids, phones)
		if err != "":
			res["why"] = err
			break
		var kind := H.Steps.kind(step)
		var arg := H.Steps.arg(step)
		if kind == "vn":
			var r := H.play_random(arg, s, rng)
			if not r["finished"]:
				res["why"] = "%s kẹt ở node %s" % [arg, r["last"]]
				break
			if r["then"] == "":
				res["why"] = "%s kết thúc mà không có bước tiếp theo" % arg
				break
			step = r["then"]
		elif kind == "roam":
			s.set_flag("is_evening", arg == "evening")
			var intro := "roam_day_intro" if arg == "day" else "roam_evening_intro"
			var intro_flag := "day_intro_done" if arg == "day" else "evening_intro_done"
			if not s.has_flag(intro_flag):
				H.play_random(intro, s, rng)
				if not s.has_flag(intro_flag):
					res["why"] = intro + " không bật cờ " + intro_flag
					break
			var next := ""
			for _a in MAX_ROAM_ACTIONS:
				var av := _available(s, arg)
				if av.is_empty():
					break
				var r := H.play_random(av[rng.randi_range(0, av.size() - 1)], s, rng)
				if r["then"] != "":
					next = r["then"]
					break
			if next == "":
				res["why"] = "kẹt khi đi lại trong quán (%s) — %d lần tương tác không có lối đi tiếp" % [arg, MAX_ROAM_ACTIONS]
				break
			step = next
		elif kind == "mini":
			var result := {}
			match arg:
				"barista":
					var drinks: Array = H.load_data("res://data/minigames/barista.json").get("drinks", {}).keys()
					var arts: Array = ["none"] + H.load_data("res://data/minigames/barista.json").get("arts", {}).keys()
					result = {"drink": drinks[rng.randi_range(0, drinks.size() - 1)], "art": arts[rng.randi_range(0, arts.size() - 1)], "weird": rng.randf() < 0.2}
				"debug":
					result = {"correct": rng.randi_range(0, 3)}
				"heartbeat":
					result = {"hits": rng.randi_range(0, 3)}
			s.apply(H.Steps.minigame_effects(arg, result))
			step = str(H.Steps.MINI_NEXT[arg])
		elif kind == "phone":
			step = str(H.Steps.PHONE_NEXT.get(arg, ""))
		elif kind == "ending":
			res["ok"] = true
			res["ending"] = s.ending_id
			break
		else:
			res["why"] = "bước lạ " + step
			break
	if not res["ok"] and res["why"] == "":
		res["why"] = "quá 300 bước mà chưa tới kết thúc (vòng lặp truyện?)"
	res["heart"] = s.get_var("heart")
	res["brain"] = s.get_var("brain")
	res["nlong"] = s.get_var("nlong")
	s.free()
	return res


func test_random_players_always_reach_a_valid_ending() -> void:
	var counts := {}
	var fails: Array = []
	var max_heart := 0
	var max_brain := 0
	var min_heart := 999
	for i in RUNS:
		var r := _play_once(1000 + i)
		if not r["ok"]:
			fails.append("seed %d: %s | %s" % [1000 + i, r["why"], " > ".join(r["trace"].slice(-6))])
			continue
		counts[r["ending"]] = int(counts.get(r["ending"], 0)) + 1
		max_heart = maxi(max_heart, int(r["heart"]))
		min_heart = mini(min_heart, int(r["heart"]))
		max_brain = maxi(max_brain, int(r["brain"]))
		if not _endings.has(str(r["ending"])):
			fails.append("seed %d: kết thúc không hợp lệ '%s'" % [1000 + i, r["ending"]])
	gut.p("Phân bố kết thúc sau %d lượt chơi ngẫu nhiên: %s" % [RUNS, counts])
	var bar: Dictionary = H.GameStateScript.BAR_MAX
	gut.p("Rung động: %d..%d (thanh tối đa %d) · Hiểu bài tối đa: %d (thanh %d)" % [min_heart, max_heart, bar["heart"], max_brain, bar["brain"]])
	assert_eq(fails.slice(0, 10), [], "%d/%d lượt chơi bị kẹt hoặc sai" % [fails.size(), RUNS])
	assert_gte(counts.size(), 4, "người chơi ngẫu nhiên chỉ gặp %d kết thúc — tuyến quá khó/hỏng?" % counts.size())
	assert_lte(max_heart, int(H.GameStateScript.BAR_MAX["heart"]), "Rung động vượt quá thanh hiển thị")
	assert_lte(max_brain, int(H.GameStateScript.BAR_MAX["brain"]), "Hiểu bài vượt quá thanh hiển thị")


func test_every_roam_spot_is_usable() -> void:
	# Mỗi người/chỗ trong quán phải được dùng ít nhất 1 lần qua các lượt chơi ngẫu nhiên.
	var used := {}
	var rng := RandomNumberGenerator.new()
	for i in 60:
		rng.seed = 5000 + i
		var s := H.new_state()
		H.play_random("ep1_s1", s, rng)
		for variant in ["day", "evening"]:
			s.set_flag("is_evening", variant == "evening")
			for _a in 40:
				var av := _available(s, variant)
				if av.is_empty():
					break
				var d: String = av[rng.randi_range(0, av.size() - 1)]
				used[d] = true
				H.play_random(d, s, rng)
		s.free()
	var never: Array = []
	for e in _roam.get("npcs", []) + _roam.get("spots", []):
		if not used.has(str(e["dialogue"])):
			never.append(e["id"])
	assert_eq(never, [], "chỗ tương tác không bao giờ dùng được (điều kiện 'if' sai?)")
