extends GutTest
## Kiểm tra CẤU TRÚC kịch bản: node thừa, vòng lặp kẹt, mọi nhánh lựa chọn đều kết thúc,
## cảnh truyện luôn dẫn sang bước tiếp theo, cờ (flag) đọc ở đâu thì phải được bật ở đâu đó.

const H := preload("res://tests/gut/helpers.gd")
const MAX_PATHS := 6000

var _dl: Dictionary


func before_all() -> void:
	_dl = H.all_dialogues()


func test_every_node_is_reachable() -> void:
	for id in _dl:
		var nodes: Dictionary = _dl[id].get("nodes", {})
		var seen := {}
		var stack: Array = [str(_dl[id].get("start", "start"))]
		while not stack.is_empty():
			var k: String = stack.pop_back()
			if seen.has(k) or not nodes.has(k):
				continue
			seen[k] = true
			stack.append_array(H.node_targets(nodes[k]))
		var dead: Array = []
		for k in nodes:
			if not seen.has(k):
				dead.append(k)
		assert_eq(dead, [], "%s.json: node không bao giờ tới được (thừa hoặc quên nối)" % id)


func test_no_auto_advance_loops() -> void:
	# Vòng lặp chỉ gồm node không có lựa chọn = game tự chạy mãi, người chơi kẹt.
	for id in _dl:
		var nodes: Dictionary = _dl[id].get("nodes", {})
		var color := {}  # 0 trắng, 1 đang thăm, 2 xong
		for start in nodes:
			var cyc := _find_cycle(nodes, str(start), color, [])
			assert_eq(cyc, [], "%s.json: vòng lặp tự chạy %s" % [id, cyc])


func _find_cycle(nodes: Dictionary, k: String, color: Dictionary, path: Array) -> Array:
	if not nodes.has(k) or int(color.get(k, 0)) == 2:
		return []
	if int(color.get(k, 0)) == 1:
		return path.slice(path.find(k)) + [k]
	var n: Dictionary = nodes[k]
	if n.has("choices"):
		color[k] = 2
		return []
	color[k] = 1
	path.append(k)
	for t in H.node_targets(n):
		var c := _find_cycle(nodes, str(t), color, path)
		if not c.is_empty():
			return c
	path.pop_back()
	color[k] = 2
	return []


func test_all_choice_paths_terminate() -> void:
	# Duyệt HẾT mọi tổ hợp lựa chọn (kể cả để hết giờ), với 2 trạng thái: trống và "đã làm mọi thứ".
	var full := _state_everything()
	var empty_state := H.new_state()
	for id in _dl:
		for s in [empty_state, full]:
			var res := _explore(id, s)
			assert_lt(int(res["paths"]), MAX_PATHS, "%s.json: quá nhiều nhánh để duyệt hết" % id)
			assert_eq(res["stuck"], [], "%s.json: nhánh không kết thúc" % id)
			if id.begins_with("ep1_"):
				assert_eq(res["no_then"], [], "%s.json: cảnh truyện kết thúc mà không sang bước tiếp theo (game sẽ đứng)" % id)
	empty_state.free()
	full.free()


func _state_everything() -> Node:
	var s := H.new_state()
	for f in _all_flags_read():
		s.set_flag(f)
	s.vars = {"heart": 18, "brain": 6, "nlong": 6}
	return s


## Trả về {paths, stuck: [đường đi], no_then: [đường đi]}
func _explore(id: String, base: Node) -> Dictionary:
	var out := {"paths": 0, "stuck": [], "no_then": []}
	var queue: Array = [[]]
	while not queue.is_empty() and int(out["paths"]) < MAX_PATHS:
		var picks: Array = queue.pop_back()
		var s := H.new_state()
		s.vars = base.vars.duplicate()
		s.flags = base.flags.duplicate()
		var r = H.DialogueRunner.new(H.DialogueData.load_dialogue(id), s)
		r.begin()
		var i := 0
		var guard := 0
		var branched := false
		var looped := false
		var menus_seen := {}
		while not r.finished and guard < 800:
			guard += 1
			var cs: Array = r.choices()
			if cs.is_empty():
				r.advance()
				continue
			if i >= picks.size() and menus_seen.has(r.current_id):
				looped = true  # quay về menu đã gặp (vd "Còn cần gì nữa không?") -> người chơi luôn có lối ra ở lượt trước
				break
			menus_seen[r.current_id] = true
			if i < picks.size():
				var p := int(picks[i])
				i += 1
				if p < 0:
					r.goto(str(r.current["timeout"]))
				else:
					r.choose(p)
				continue
			for c in cs.size():
				queue.append(picks + [c])
			if r.current.has("timeout"):
				queue.append(picks + [-1])
			branched = true
			break
		if not branched:
			out["paths"] = int(out["paths"]) + 1
			if looped:
				pass
			elif not r.finished:
				out["stuck"].append(picks)
			elif r.then_step == "" and str(_dl[id].get("then", "")) == "":
				out["no_then"].append(picks)
		s.free()
	return out


func _all_flags_read() -> Array:
	var reads := {}
	for id in _dl:
		_collect_conds(_dl[id], reads)
	_collect_conds(H.load_data("res://data/roam/cafe.json"), reads)
	for id in H.DialogueData.list_ids("res://data/phone/"):
		_collect_conds(H.load_data("res://data/phone/%s.json" % id), reads)
	return reads.keys()


func _collect_conds(v, reads: Dictionary) -> void:
	if v is Dictionary:
		for k in v:
			if str(k) == "if" and v[k] is Dictionary:
				for f in v[k].get("flags", []) + v[k].get("not_flags", []):
					reads[str(f)] = true
			else:
				_collect_conds(v[k], reads)
	elif v is Array:
		for x in v:
			_collect_conds(x, reads)


func test_flags_read_are_set_somewhere() -> void:
	var sets := {}
	for id in _dl:
		_collect_sets(_dl[id], sets)
	# cờ bật trong code: set_flag("x")
	var re := RegEx.new()
	re.compile("set_flag\\(\"([a-z0-9_]+)\"")
	for f in H.code_files():
		for m in re.search_all(H.read_text(f)):
			sets[m.get_string(1)] = true
	# cờ do mini-game sinh ra
	var b := H.load_data("res://data/minigames/barista.json")
	for d in b.get("drinks", {}):
		sets["drink_" + str(d)] = true
	for a in b.get("arts", {}):
		sets["art_" + str(a)] = true
	for f in ["drink_made", "drink_weird", "art_none", "debug_done", "debug_perfect", "calm_ok", "calm_fail"]:
		sets[f] = true
	var missing: Array = []
	for f in _all_flags_read():
		if not sets.has(f):
			missing.append(f)
	missing.sort()
	assert_eq(missing, [], "cờ được kiểm tra nhưng KHÔNG nơi nào bật -> nhánh đó không bao giờ xảy ra")


func _collect_sets(v, sets: Dictionary) -> void:
	if v is Dictionary:
		for k in v:
			if str(k) == "set_flags":
				for f in v[k]:
					sets[str(f)] = true
			else:
				_collect_sets(v[k], sets)
	elif v is Array:
		for x in v:
			_collect_sets(x, sets)


func test_minigame_result_flags_cover_scenes() -> void:
	# Mỗi kết quả mini-game phải có cảnh tiếp theo phản ứng được (không rơi vào khoảng trống).
	var s3b: Dictionary = _dl["ep1_s3b"]
	var text := JSON.stringify(s3b)
	for f in ["debug_perfect"]:
		assert_true(text.contains(f), "ep1_s3b không xử lý cờ " + f)
	var start: Dictionary = _dl["ep1_s3c"]["nodes"][str(_dl["ep1_s3c"].get("start", "start"))]
	assert_true(start.has("branch") and JSON.stringify(start).contains("calm_"), "ep1_s3c phải rẽ nhánh theo kết quả giữ bình tĩnh")
	assert_ne(str(start.get("default", "")), str(start["branch"][0].get("next", "")), "hai kết quả giữ bình tĩnh phải dẫn tới 2 đoạn khác nhau")


func test_condition_vars_are_known() -> void:
	var known := ["heart", "brain", "nlong"]
	var bad: Array = []
	for id in _dl:
		_check_vars(_dl[id], known, bad, id)
	assert_eq(bad, [], "điều kiện min/below dùng chỉ số không tồn tại (gõ sai tên?)")


func _check_vars(v, known: Array, bad: Array, src: String) -> void:
	if v is Dictionary:
		for k in v:
			if str(k) in ["min", "below", "add"] and v[k] is Dictionary:
				for name_key in v[k]:
					if not known.has(str(name_key)):
						bad.append("%s: %s" % [src, name_key])
			else:
				_check_vars(v[k], known, bad, src)
	elif v is Array:
		for x in v:
			_check_vars(x, known, bad, src)


func test_timed_choices_are_complete() -> void:
	for id in _dl:
		var nodes: Dictionary = _dl[id].get("nodes", {})
		for k in nodes:
			var n: Dictionary = nodes[k]
			if n.has("timer"):
				assert_true(n.has("choices"), "%s/%s: có timer nhưng không có lựa chọn" % [id, k])
				assert_true(n.has("timeout"), "%s/%s: có timer nhưng thiếu 'timeout'" % [id, k])
				assert_gt(float(n["timer"]), 1.5, "%s/%s: thời gian chọn quá ngắn cho người mới" % [id, k])
