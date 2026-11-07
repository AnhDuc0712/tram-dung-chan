extends GutTest
## "Người chơi ngẫu nhiên": chơi trọn từng tập hàng trăm lần với lựa chọn, thứ tự đi lại trong bản đồ và
## kết quả mini-game NGẪU NHIÊN. Bắt lỗi kẹt game (soft-lock), bước truyện sai, kết thúc không hợp lệ.
## Đi lại mô phỏng đúng cafe.gd: bản đồ theo Steps.roam_map(), hội thoại mở màn data.intros,
## chỉ nói chuyện với người / chỗ có mặt ở biến thể đó và thoả điều kiện "if".

const H := preload("res://tests/gut/helpers.gd")
const RUNS_PER_EPISODE := 250
const MAX_ROAM_ACTIONS := 200

var _maps := {}
var _endings: Dictionary
var _results := {}  # tập -> [kết quả từng lượt]
var _used := {}  # map/id -> true (người / chỗ đã từng tương tác)


func before_all() -> void:
	for m in H.ROAM_MAPS:
		_maps[m] = H.load_data("res://data/roam/%s.json" % m)
	_endings = H.load_data(H.DialogueData.ENDINGS_PATH)
	for ep in H.Steps.EPISODES:
		var arr: Array = []
		for i in RUNS_PER_EPISODE:
			arr.append(_play_once(int(ep), 1000 * int(ep) + i))
		_results[ep] = arr


func _entities(variant: String) -> Array:
	var d: Dictionary = _maps[H.Steps.roam_map(variant)]
	var out: Array = []
	for e in d.get("npcs", []) + d.get("spots", []):
		var w = e.get("when", [])
		var present: bool = (w as Dictionary).has(variant) if w is Dictionary else (w as Array).has(variant)
		if present:
			var dlg := str((e.get("dialogue_by", {}) as Dictionary).get(variant, e.get("dialogue", "")))
			out.append({"id": "%s/%s" % [H.Steps.roam_map(variant), e["id"]], "dialogue": dlg, "if": e.get("if", {})})
	return out


func _random_mini(game: String, rng: RandomNumberGenerator) -> Dictionary:
	match game:
		"barista":
			var b := H.load_data("res://data/minigames/barista.json")
			var drinks: Array = b.get("drinks", {}).keys()
			var arts: Array = ["none"] + b.get("arts", {}).keys()
			return {"drink": drinks[rng.randi_range(0, drinks.size() - 1)], "art": arts[rng.randi_range(0, arts.size() - 1)], "weird": rng.randf() < 0.2}
		"debug":
			return {"correct": rng.randi_range(0, 3)}
		"heartbeat", "dark":
			return {"hits": rng.randi_range(0, 3)}
		"nlong":
			return {"pets": rng.randi_range(0, 3), "treat": rng.randf() < 0.6, "tail": rng.randf() < 0.3}
		"logic", "rush", "sync":  # mỗi mini-game chỉ đọc khoá của mình: cho chung một bộ số
			return {"first_try": rng.randi_range(0, 3), "served": rng.randi_range(0, 6), "perfect": rng.randi_range(0, 4), "misses": rng.randi_range(0, 5)}
	return {}


## Chơi ngẫu nhiên các lựa chọn trong điện thoại (áp hiệu ứng như phone.gd).
func _play_phone(id: String, s: Node, rng: RandomNumberGenerator) -> void:
	var d := H.load_data("res://data/phone/%s.json" % id)
	for th in d.get("threads", []):
		for m in th.get("messages", []):
			if (m as Dictionary).has("choices"):
				var cs: Array = m["choices"]
				s.apply(cs[rng.randi_range(0, cs.size() - 1)].get("effects", {}))


## Chơi trọn một tập. Trả về {ok, ending, why, trace, vars}
func _play_once(ep: int, seed_value: int) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var s := H.new_state()
	var step: String = str(H.Steps.EPISODES[ep]["first"])
	s.start_episode(ep, step)
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
			var intro: Array = (_maps[H.Steps.roam_map(arg)].get("intros", {}) as Dictionary).get(arg, [])
			if intro.size() == 2 and not s.has_flag(str(intro[1])):
				H.play_random(str(intro[0]), s, rng)
				if not s.has_flag(str(intro[1])):
					res["why"] = "%s không bật cờ %s" % [intro[0], intro[1]]
					break
			var next := ""
			for _a in MAX_ROAM_ACTIONS:
				var av: Array = []
				for e in _entities(arg):
					if s.check(e["if"]):
						av.append(e)
				if av.is_empty():
					break
				var pick: Dictionary = av[rng.randi_range(0, av.size() - 1)]
				_used[pick["id"]] = true
				var r := H.play_random(str(pick["dialogue"]), s, rng)
				if r["then"] != "":
					next = r["then"]
					break
			if next == "":
				res["why"] = "kẹt khi đi lại (%s) — %d lần tương tác không có lối đi tiếp" % [arg, MAX_ROAM_ACTIONS]
				break
			step = next
		elif kind == "mini":
			s.apply(H.Steps.minigame_effects(arg, _random_mini(arg, rng)))
			step = str(H.Steps.MINI_NEXT[arg])
		elif kind == "phone":
			_play_phone(arg, s, rng)
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
	res["vars"] = s.vars.duplicate()
	s.free()
	return res


func _check_episode(ep: int, min_endings: int) -> void:
	var counts := {}
	var fails: Array = []
	var maxv := {}
	for i in (_results[ep] as Array).size():
		var r: Dictionary = _results[ep][i]
		if not r["ok"]:
			fails.append("tập %d seed %d: %s | %s" % [ep, 1000 * ep + i, r["why"], " > ".join(r["trace"].slice(-6))])
			continue
		counts[r["ending"]] = int(counts.get(r["ending"], 0)) + 1
		var e: Dictionary = _endings.get(str(r["ending"]), {})
		if e.is_empty() or int(e.get("episode", 1)) != ep:
			fails.append("tập %d seed %d: kết thúc không thuộc tập này '%s'" % [ep, 1000 * ep + i, r["ending"]])
		for k in r["vars"]:
			maxv[k] = maxi(int(maxv.get(k, -999)), int(r["vars"][k]))
	gut.p("Tập %d — phân bố kết thúc sau %d lượt chơi ngẫu nhiên: %s" % [ep, RUNS_PER_EPISODE, counts])
	gut.p("Tập %d — chỉ số cao nhất từng đạt: %s" % [ep, maxv])
	assert_eq(fails.slice(0, 10), [], "%d lượt chơi bị kẹt hoặc sai" % fails.size())
	assert_gte(counts.size(), min_endings, "người chơi ngẫu nhiên chỉ gặp %d kết thúc ở tập %d" % [counts.size(), ep])
	var bar: Dictionary = H.GameStateScript.BAR_MAX
	if ep >= 3:
		bar = H.GameStateScript.BAR_MAX_EP3
	elif ep == 2:
		bar = H.GameStateScript.BAR_MAX_EP2
	assert_lte(int(maxv.get("heart", 0)), int(bar["heart"]), "Rung động vượt quá thanh hiển thị của tập %d" % ep)
	assert_lte(int(maxv.get("brain", 0)), int(bar["brain"]), "Hiểu bài vượt quá thanh hiển thị của tập %d" % ep)


func test_episode1_random_players() -> void:
	_check_episode(1, 4)


func test_episode2_random_players() -> void:
	_check_episode(2, 4)


func test_episode3_random_players() -> void:
	_check_episode(3, 4)


func test_every_roam_entity_is_used() -> void:
	# Người/chỗ nào trên bản đồ mà hàng trăm người chơi ngẫu nhiên chưa từng chạm tới -> điều kiện "if" sai / bị khoá chết.
	var never: Array = []
	for v in H.Steps.ROAM_VARIANTS:
		for e in _entities(v):
			if not _used.has(e["id"]) and not never.has(e["id"]):
				never.append(e["id"])
	assert_eq(never, [], "chỗ tương tác không bao giờ dùng được")
