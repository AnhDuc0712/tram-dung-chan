extends RefCounted
## Đọc & kiểm tra file hội thoại JSON. Không dính UI -> chạy được trong test headless.
## Định dạng: xem docs/DIALOGUE_FORMAT.md

const DIALOGUE_DIR := "res://data/dialogue/"
const ENDINGS_PATH := "res://data/endings.json"
const CHAR_PATH := "res://data/characters.json"
const BG_DIR := "res://assets/art/bg/"
const CG_PATH := "res://data/cgs.json"

const KNOWN_KEYS := [
	"text", "speaker", "name", "think", "next", "then", "choices", "branch", "default", "effects",
	"bg", "music", "ambient", "sfx", "voice", "show", "hide", "emote", "anim", "fx", "event",
	"card", "card_hold", "wait", "timer", "timeout", "note", "cg",
]
const KNOWN_FX := ["shake", "flash", "rain_on", "rain_off", "umbrella_on", "umbrella_off", "dark", "light", "zoom", "unzoom"]
const KNOWN_EMOTES := ["", "!", "?", "sweat", "blush", "heart", "sparkle", "gloom", "anger", "zzz", "flowers", "tears", "dots"]


static func path_for(id: String) -> String:
	return DIALOGUE_DIR + id + ".json"


static func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Không tìm thấy file: " + path)
		return {}
	var json := JSON.new()
	var err := json.parse(FileAccess.get_file_as_string(path))
	if err != OK:
		push_error("%s dòng %d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return {}
	if json.data is Dictionary:
		return json.data
	return {}


static func load_dialogue(id: String) -> Dictionary:
	return load_json(path_for(id))


static func list_ids(dir: String = DIALOGUE_DIR) -> PackedStringArray:
	var ids := PackedStringArray()
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".json"):
			ids.append(f.get_basename())
	return ids


## Chọn nhánh đầu tiên thỏa điều kiện "if", không có thì "default".
static func resolve_branch(node: Dictionary, state) -> String:
	for b in node.get("branch", []):
		if state.check(b.get("if", {})):
			return str(b.get("next", "end"))
	return str(node.get("default", "end"))


static func visible_choices(node: Dictionary, state) -> Array:
	var out: Array = []
	for c in node.get("choices", []):
		if state.check(c.get("if", {})):
			out.append(c)
	return out


## Trả về danh sách lỗi (rỗng = hợp lệ).
##  endings: endings.json; chars: characters.json; step_check: Callable(step) -> "" hoặc lỗi
static func validate(data: Dictionary, endings: Dictionary = {}, chars: Dictionary = {}, step_check: Callable = Callable()) -> PackedStringArray:
	var errs := PackedStringArray()
	if not (data.get("nodes") is Dictionary):
		errs.append("thiếu khóa 'nodes'")
		return errs
	var nodes: Dictionary = data["nodes"]
	var start := str(data.get("start", "start"))
	if not nodes.has(start):
		errs.append("node bắt đầu '%s' không tồn tại" % start)
	if nodes.has("end"):
		errs.append("không được đặt tên node là 'end' (từ khoá kết thúc hội thoại) — đổi tên khác")
	for key in nodes:
		var n = nodes[key]
		if not (n is Dictionary):
			errs.append("node '%s' không phải object" % key)
			continue
		for k in n:
			if not KNOWN_KEYS.has(str(k)) and str(k) != "if":
				errs.append("node '%s': khóa lạ '%s' (gõ sai?)" % [key, k])
		if n.has("branch"):
			for k in n:
				if not ["branch", "default", "effects", "note"].has(str(k)):
					errs.append("node '%s' là branch nên khóa '%s' sẽ bị bỏ qua (chuyển sang node khác)" % [key, k])
			for b in n["branch"]:
				_check_ref(nodes, str(b.get("next", "")), key, errs)
			_check_ref(nodes, str(n.get("default", "end")), key, errs)
			continue
		if not n.has("text") and not n.has("card") and not n.has("wait") and not n.has("show") and not n.has("bg"):
			errs.append("node '%s' thiếu 'text'" % key)
		if n.has("choices"):
			if n["choices"].is_empty():
				errs.append("node '%s' có 'choices' rỗng" % key)
			if not n.has("text"):
				errs.append("node '%s' có lựa chọn nhưng thiếu 'text'" % key)
			for c in n["choices"]:
				if not c.has("text"):
					errs.append("một lựa chọn trong node '%s' thiếu 'text'" % key)
				if c.has("then") and not c.has("next"):
					_check_step(str(c["then"]), key, step_check, errs)
				else:
					_check_ref(nodes, str(c.get("next", "end")), key, errs)
				_check_effects(c.get("effects", {}), endings, key, errs)
			if n.has("timer"):
				_check_ref(nodes, str(n.get("timeout", "")), key, errs)
		elif n.has("next"):
			_check_ref(nodes, str(n["next"]), key, errs)
		if n.has("then"):
			_check_step(str(n["then"]), key, step_check, errs)
		_check_effects(n.get("effects", {}), endings, key, errs)
		# sân khấu
		if n.has("cg") and str(n["cg"]) != "none":
			var cgs := load_json(CG_PATH)
			if not cgs.has(str(n["cg"])):
				errs.append("node '%s': CG '%s' chưa khai báo trong data/cgs.json" % [key, n["cg"]])
		if n.has("bg"):
			var bg := str(n["bg"])
			if bg != "none" and not ResourceLoader.exists(BG_DIR + bg + ".jpg"):
				errs.append("node '%s': không có ảnh nền '%s'" % [key, bg])
		if not chars.is_empty():
			var sh: Dictionary = n.get("show", {})
			for id in sh:
				if not chars.has(id):
					errs.append("node '%s': nhân vật '%s' chưa có trong characters.json" % [key, id])
					continue
				var v = sh[id]
				var pose := str(v.get("pose", "normal")) if v is Dictionary else str(v).split("@")[0]
				if pose != "" and not (chars[id].get("poses", {}) as Dictionary).has(pose):
					errs.append("node '%s': '%s' không có biểu cảm '%s'" % [key, id, pose])
			if n.has("speaker") and str(n["speaker"]) != "" and not chars.has(str(n["speaker"])):
				errs.append("node '%s': speaker '%s' chưa có trong characters.json" % [key, n["speaker"]])
		var fx = n.get("fx", [])
		if fx is String:
			fx = [fx]
		for f in fx:
			if not KNOWN_FX.has(str(f)):
				errs.append("node '%s': hiệu ứng lạ '%s'" % [key, f])
		var em: Dictionary = n.get("emote", {})
		for id in em:
			if not KNOWN_EMOTES.has(str(em[id])):
				errs.append("node '%s': emote lạ '%s'" % [key, em[id]])
	return errs


static func _check_effects(eff, endings: Dictionary, from: String, errs: PackedStringArray) -> void:
	if eff is Dictionary and eff.has("ending") and not endings.is_empty() and not endings.has(str(eff["ending"])):
		errs.append("node '%s' dùng ending '%s' chưa khai báo trong endings.json" % [from, eff["ending"]])


static func _check_step(step: String, from: String, step_check: Callable, errs: PackedStringArray) -> void:
	if step_check.is_valid():
		var e: String = step_check.call(step)
		if e != "":
			errs.append("node '%s': %s" % [from, e])


static func _check_ref(nodes: Dictionary, ref: String, from: String, errs: PackedStringArray) -> void:
	if ref == "end":
		return
	if ref == "" or not nodes.has(ref):
		errs.append("node '%s' trỏ tới '%s' không tồn tại" % [from, ref])
