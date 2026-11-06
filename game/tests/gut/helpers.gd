extends RefCounted
## Hàm dùng chung cho các bộ test GUT (file không bắt đầu bằng "test_" nên GUT không chạy nó như test).

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const DialogueRunner := preload("res://scripts/dialogue/dialogue_runner.gd")
const Steps := preload("res://scripts/story_steps.gd")
const GameStateScript := preload("res://autoload/game_state.gd")

const CODE_DIRS := ["res://autoload/", "res://scenes/", "res://scripts/"]
const ROAM_MAPS := ["cafe", "street"]


## GameState riêng cho test (không đụng file lưu thật của người chơi). Nhớ free()/autofree().
static func new_state() -> Node:
	var s: Node = GameStateScript.new()
	s.reset()
	s.save_path = "user://gut_save.json"
	s.meta_path = "user://gut_meta.json"
	s.settings_path = "user://gut_settings.json"
	return s


## id -> dữ liệu của mọi file hội thoại.
static func all_dialogues() -> Dictionary:
	var out := {}
	for id in DialogueData.list_ids():
		out[id] = DialogueData.load_dialogue(id)
	return out


static func load_data(path: String) -> Dictionary:
	return DialogueData.load_json(path)


## Các node mà một node có thể đi tới (next, lựa chọn, nhánh, hết giờ).
static func node_targets(n: Dictionary) -> Array:
	var out: Array = []
	if n.has("next"):
		out.append(str(n["next"]))
	for c in n.get("choices", []):
		if c.has("next") or not c.has("then"):
			out.append(str(c.get("next", "end")))
	for b in n.get("branch", []):
		out.append(str(b.get("next", "end")))
	if n.has("branch"):
		out.append(str(n.get("default", "end")))
	if n.has("timeout"):
		out.append(str(n["timeout"]))
	return out


## Mọi file .gd của game (bỏ addons/ và tests/).
static func code_files() -> Array:
	var out: Array = []
	for d in CODE_DIRS:
		_collect(d, ".gd", out)
	return out


static func _collect(dir: String, ext: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(ext):
			out.append(dir + f)
	for sub in DirAccess.get_directories_at(dir):
		_collect(dir + sub + "/", ext, out)


static func files_in(dir: String, ext: String) -> Array:
	var out: Array = []
	_collect(dir, ext, out)
	return out


static func read_text(path: String) -> String:
	return FileAccess.get_file_as_string(path)


## Tất cả chuỗi người chơi nhìn thấy: [{src, text}]
static func visible_strings() -> Array:
	var out: Array = []
	var dl := all_dialogues()
	for id in dl:
		var nodes: Dictionary = dl[id].get("nodes", {})
		for k in nodes:
			var n: Dictionary = nodes[k]
			for key in ["text", "name", "card"]:
				if n.has(key):
					out.append({"src": "%s.json/%s" % [id, k], "text": str(n[key]), "kind": key, "think": bool(n.get("think", false))})
			for c in n.get("choices", []):
				out.append({"src": "%s.json/%s (lựa chọn)" % [id, k], "text": str(c.get("text", "")), "kind": "choice"})
	var endings := load_data(DialogueData.ENDINGS_PATH)
	for e in endings:
		for key in ["title", "rank", "text", "hint"]:
			out.append({"src": "endings.json/%s.%s" % [e, key], "text": str(endings[e].get(key, "")), "kind": "ending"})
	var chars := load_data(DialogueData.CHAR_PATH)
	for c in chars:
		out.append({"src": "characters.json/%s" % c, "text": str(chars[c].get("name", "")), "kind": "name"})
	for id in DialogueData.list_ids("res://data/phone/"):
		_strings_rec(load_data("res://data/phone/%s.json" % id), "phone/%s.json" % id, out)
	for m in ROAM_MAPS:
		var roam := load_data("res://data/roam/%s.json" % m)
		for e in roam.get("npcs", []) + roam.get("spots", []):
			out.append({"src": "%s.json/%s" % [m, e.get("id")], "text": str(e.get("label", "")), "kind": "label"})
		for v in (roam.get("objectives", {}) as Dictionary):
			for o in roam["objectives"][v]:
				out.append({"src": "%s.json/objectives.%s" % [m, v], "text": str(o.get("text", "")), "kind": "data"})
	for t in load_data("res://data/nlong_thoughts.json").get("thoughts", []):
		out.append({"src": "nlong_thoughts/%s" % t.get("id"), "text": str(t.get("text", "")), "kind": "data"})
	var cgs := load_data(DialogueData.CG_PATH)
	for c in cgs:
		out.append({"src": "cgs.json/%s" % c, "text": str(cgs[c].get("title", "")), "kind": "data"})
	for f in ["barista", "debug_ep1"]:
		_strings_rec(load_data("res://data/minigames/%s.json" % f), "minigames/%s.json" % f, out)
	return out


static func _strings_rec(v, src: String, out: Array) -> void:
	if v is Dictionary:
		for k in v:
			# chuỗi hiển thị = có dấu cách hoặc chữ có dấu (tên ảnh / màu / id thì không)
			if v[k] is String and (str(v[k]).contains(" ") or str(v[k]).to_ascii_buffer().size() != str(v[k]).to_utf8_buffer().size()):
				out.append({"src": "%s/%s" % [src, k], "text": str(v[k]), "kind": "data"})
			else:
				_strings_rec(v[k], src, out)
	elif v is Array:
		for x in v:
			_strings_rec(x, src, out)


## Xoá thẻ BBCode để đo chữ.
static func strip_bbcode(t: String) -> String:
	var re := RegEx.new()
	re.compile("\\[/?[a-z_]+(=[^\\]]*)?\\]")
	return re.sub(t, "", true)


## Chơi một hội thoại với lựa chọn ngẫu nhiên. Trả về bước "then" ("" nếu không có).
static func play_random(id: String, s: Node, rng: RandomNumberGenerator) -> Dictionary:
	var r = DialogueRunner.new(DialogueData.load_dialogue(id), s)
	r.begin()
	var guard := 0
	while not r.finished and guard < 600:
		guard += 1
		var cs: Array = r.choices()
		if cs.is_empty():
			r.advance()
		elif r.current.has("timeout") and rng.randf() < 0.15:
			r.goto(str(r.current["timeout"]))
		else:
			r.choose(rng.randi_range(0, cs.size() - 1))
	return {"then": r.then_step, "finished": r.finished, "steps": guard, "last": r.current_id}
