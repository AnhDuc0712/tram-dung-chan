extends Node
## Trạng thái toàn game. Autoload "GameState".
##  - vars: các chỉ số số nguyên. Quan trọng nhất:
##      heart  = Chỉ số Rung Động của KyKy (❤)
##      brain  = Độ Hiểu Bài của KyKy (💡)
##      nlong  = độ thân với mèo Nlong
##  - flags: cờ sự kiện (đã làm gì)
##  - step: bước truyện hiện tại (vd "roam:day") -> dùng cho "Tiếp tục"
##  - meta (lưu riêng, không mất khi chơi lại): các kết thúc đã mở khóa
##  - settings: âm lượng, tốc độ chữ

signal var_changed(var_name: String, value: int)
signal flag_changed(flag: String, value: bool)

const SAVE_VERSION := 2
const FIRST_STEP := "vn:ep1_s1"
const BAR_MAX := {"heart": 18, "brain": 6}  # Tập 1
const BAR_MAX_EP2 := {"heart": 28, "brain": 6}  # Tập 2 dài hơn, nhiều lựa chọn hơn

var save_path := "user://save.json"  # test đổi sang file khác
var meta_path := "user://meta.json"
var settings_path := "user://settings.json"

var vars: Dictionary = {}  # tên -> int
var flags: Dictionary = {}  # tên cờ -> true
var step: String = FIRST_STEP
var player_position := Vector2.ZERO
var has_position := false  # vừa tải save -> đặt lại vị trí nhân vật trong map
var ending_id := ""

var unlocked_endings: Array = []
var unlocked_cgs: Array = []  # Event CG đã xem (mục Kỷ niệm)
var seen_thoughts: Array = []  # "tâm tư Anh Đức" đã nghe từ Nlong
var ep1_last := ""  # kết thúc Tập 1 gần nhất -> Tập 2 mở đầu khác nhau
var episode := 1
## Chế độ tự chơi để kiểm thử (tham số "-- --autoplay"): tự bấm, tự chọn, tự xong mini-game.
var autoplay := OS.get_cmdline_user_args().has("--autoplay")
var settings := {"music": 0.8, "sfx": 0.9, "text_speed": 45.0}


func _ready() -> void:
	_setup_input()
	if autoplay:  # tự chơi kiểm thử -> không đụng vào file lưu thật của người chơi
		save_path = "user://autoplay_save.json"
		meta_path = "user://autoplay_meta.json"
	reset()
	load_meta()
	load_settings()


# ---------------------------------------------------------------- phím bấm
func _setup_input() -> void:
	_add_keys("move_left", [KEY_A, KEY_LEFT])
	_add_keys("move_right", [KEY_D, KEY_RIGHT])
	_add_keys("move_up", [KEY_W, KEY_UP])
	_add_keys("move_down", [KEY_S, KEY_DOWN])
	_add_keys("interact", [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER])
	_add_keys("menu", [KEY_ESCAPE])
	_add_keys("skip", [KEY_CTRL])
	_add_keys("log", [KEY_L])


func _add_keys(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


# ---------------------------------------------------------------- dữ liệu
func reset() -> void:
	vars = {"heart": 0, "brain": 0, "nlong": 0}
	flags.clear()
	episode = 1
	step = FIRST_STEP
	player_position = Vector2.ZERO
	has_position = false
	ending_id = ""


## Độ dài thanh hiển thị của chỉ số theo tập đang chơi.
func bar_max(key: String) -> int:
	var t: Dictionary = BAR_MAX_EP2 if episode >= 2 else BAR_MAX
	return int(t.get(key, 10))


func get_var(key: String) -> int:
	return int(vars.get(key, 0))


func add_var(key: String, delta: int) -> void:
	vars[key] = get_var(key) + delta
	var_changed.emit(key, vars[key])


func has_flag(flag: String) -> bool:
	return bool(flags.get(flag, false))


func set_flag(flag: String, value: bool = true) -> void:
	if value:
		flags[flag] = true
	else:
		flags.erase(flag)
	flag_changed.emit(flag, value)


## Bắt đầu một tập mới: chỉ số về 0, mang theo vài cờ từ kết thúc Tập 1 đã chơi (nếu có).
func start_episode(ep: int, first_step: String) -> void:
	reset()
	episode = ep
	step = first_step
	if ep == 2:
		vars = {"heart": 0, "brain": 0, "nlong": 0, "tram": 0, "jealous": 0}
		var last := ep1_last if ep1_last != "" else "duoi_mot_chiec_o"  # chưa chơi Tập 1 -> theo mạch chính thức
		set_flag("ep1_" + last)
		if last in ["duoi_mot_chiec_o", "hoang_thuong"]:
			set_flag("ep1_umbrella")
		elif last == "uot_sung":
			set_flag("ep1_wet")


## Điều kiện (khóa "if"):
##   {"flags": ["a"], "not_flags": ["b"], "min": {"heart": 3}, "below": {"brain": 2}}
##   min = lớn hơn hoặc bằng, below = nhỏ hơn hẳn.
func check(cond) -> bool:
	if not (cond is Dictionary) or cond.is_empty():
		return true
	for f in cond.get("flags", []):
		if not has_flag(str(f)):
			return false
	for f in cond.get("not_flags", []):
		if has_flag(str(f)):
			return false
	var mins: Dictionary = cond.get("min", {})
	for k in mins:
		if get_var(str(k)) < int(mins[k]):
			return false
	var belows: Dictionary = cond.get("below", {})
	for k in belows:
		if get_var(str(k)) >= int(belows[k]):
			return false
	return true


## Hiệu ứng (khóa "effects"):
##   {"heart": 1, "brain": 1, "add": {"nlong": 1}, "set_flags": ["x"], "clear_flags": ["y"], "ending": "id"}
func apply(effects) -> void:
	if not (effects is Dictionary):
		return
	if effects.has("heart"):
		add_var("heart", int(effects["heart"]))
	if effects.has("brain"):
		add_var("brain", int(effects["brain"]))
	var adds: Dictionary = effects.get("add", {})
	for k in adds:
		add_var(str(k), int(adds[k]))
	for f in effects.get("set_flags", []):
		set_flag(str(f))
	for f in effects.get("clear_flags", []):
		set_flag(str(f), false)
	if effects.has("ending"):
		ending_id = str(effects["ending"])


# ---------------------------------------------------------------- lưu / tải
func has_save() -> bool:
	return FileAccess.file_exists(save_path)


func save_game() -> bool:
	if is_inside_tree():
		var player := get_tree().get_first_node_in_group("player") as Node2D
		if player:
			player_position = player.global_position
			has_position = true
	var data := {
		"version": SAVE_VERSION,
		"vars": vars,
		"flags": flags.keys(),
		"step": step,
		"episode": episode,
		"ending": ending_id,
		"pos": [player_position.x, player_position.y] if has_position else [],
	}
	return _write_json(save_path, data)


func load_game() -> bool:
	if not has_save():
		return false
	var parsed = _read_json(save_path)
	if not (parsed is Dictionary) or int(parsed.get("version", 0)) != SAVE_VERSION:
		push_warning("File save cũ hoặc hỏng -> bỏ qua")
		return false
	reset()
	var v: Dictionary = parsed.get("vars", {})
	for k in v:
		vars[str(k)] = int(v[k])
	for f in parsed.get("flags", []):
		flags[str(f)] = true
	step = str(parsed.get("step", FIRST_STEP))
	episode = int(parsed.get("episode", 1))
	ending_id = str(parsed.get("ending", ""))
	var pos: Array = parsed.get("pos", [])
	if pos.size() == 2:
		player_position = Vector2(float(pos[0]), float(pos[1]))
		has_position = true
	return true


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))


# ---------------------------------------------------------------- meta & cài đặt
func unlock_ending(id: String) -> void:
	if id == "":
		return
	if not unlocked_endings.has(id):
		unlocked_endings.append(id)
	if episode == 1:
		ep1_last = id
	_save_meta()


func unlock_cg(id: String) -> void:
	if id != "" and not unlocked_cgs.has(id):
		unlocked_cgs.append(id)
		_save_meta()


func mark_thought(id: String) -> void:
	if not seen_thoughts.has(id):
		seen_thoughts.append(id)
		_save_meta()


func _save_meta() -> void:
	_write_json(meta_path, {"endings": unlocked_endings, "cgs": unlocked_cgs, "thoughts": seen_thoughts, "ep1_last": ep1_last})


func load_meta() -> void:
	var m = _read_json(meta_path)
	if m is Dictionary:
		unlocked_endings = Array(m.get("endings", []))
		unlocked_cgs = Array(m.get("cgs", []))
		seen_thoughts = Array(m.get("thoughts", []))
		ep1_last = str(m.get("ep1_last", ""))


func load_settings() -> void:
	var s = _read_json(settings_path)
	if s is Dictionary:
		for k in settings:
			if s.has(k):
				settings[k] = float(s[k])


func save_settings() -> void:
	_write_json(settings_path, settings)


func _write_json(path: String, data) -> bool:
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("Không ghi được %s: %s" % [path, FileAccess.get_open_error()])
		return false
	f.store_string(JSON.stringify(data, "\t"))
	return true


func _read_json(path: String):
	if not FileAccess.file_exists(path):
		return null
	# JSON.new().parse() thay vì JSON.parse_string(): file hỏng không in lỗi engine, chỉ trả về null
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		push_warning("File hỏng, bỏ qua: " + path)
		return null
	return json.data
