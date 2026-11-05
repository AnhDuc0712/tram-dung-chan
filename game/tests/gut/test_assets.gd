extends GutTest
## Tài nguyên: âm thanh/ảnh được gọi tên trong kịch bản và code có tồn tại không (Audio bỏ qua file
## thiếu trong im lặng nên lỗi gõ tên rất khó thấy), ảnh biểu cảm cùng cỡ ảnh gốc, ghi công đầy đủ.

const H := preload("res://tests/gut/helpers.gd")
const MUSIC := "res://assets/audio/music/%s.ogg"
const SFX := "res://assets/audio/sfx/%s.ogg"
const CHARS := "res://assets/art/chars/%s.png"


func test_dialogue_audio_exists() -> void:
	var missing: Array = []
	var dl := H.all_dialogues()
	for id in dl:
		var nodes: Dictionary = dl[id].get("nodes", {})
		for k in nodes:
			var n: Dictionary = nodes[k]
			if n.has("music") and str(n["music"]) != "" and not ResourceLoader.exists(MUSIC % n["music"]):
				missing.append("%s/%s: music '%s'" % [id, k, n["music"]])
			if n.has("ambient") and str(n["ambient"]) != "" and not ResourceLoader.exists(SFX % n["ambient"]):
				missing.append("%s/%s: ambient '%s'" % [id, k, n["ambient"]])
			var sfx = n.get("sfx", [])
			for t in ([sfx] if sfx is String else sfx):
				if str(t) != "" and not ResourceLoader.exists(SFX % t):
					missing.append("%s/%s: sfx '%s'" % [id, k, t])
	assert_eq(missing, [], "kịch bản gọi âm thanh không tồn tại")


func test_code_audio_and_images_exist() -> void:
	var re_audio := RegEx.new()
	re_audio.compile("Audio\\.(music|ambient|sfx)\\(\"([a-z0-9_]+)\"")
	var re_img := RegEx.new()
	re_img.compile("(?:char_tex|head_tex)\\(\"([a-z0-9_]+)\"")
	var missing: Array = []
	for f in H.code_files():
		var src := H.read_text(f)
		for m in re_audio.search_all(src):
			var path: String = (MUSIC if m.get_string(1) == "music" else SFX) % m.get_string(2)
			if not ResourceLoader.exists(path):
				missing.append("%s: %s" % [f.get_file(), path])
		for m in re_img.search_all(src):
			if not ResourceLoader.exists(CHARS % m.get_string(1)):
				missing.append("%s: ảnh %s" % [f.get_file(), m.get_string(1)])
	assert_eq(missing, [], "code gọi tài nguyên không tồn tại")


func test_roam_and_phone_images_exist() -> void:
	var missing: Array = []
	var roam := H.load_data("res://data/roam/cafe.json")
	assert_true(ResourceLoader.exists("res://assets/art/bg/%s.jpg" % roam.get("map", "")), "thiếu ảnh bản đồ")
	for v in (roam.get("music", {}) as Dictionary).values():
		if not ResourceLoader.exists(MUSIC % v):
			missing.append("cafe.json music " + str(v))
	var pl: Dictionary = roam.get("player", {})
	for e in roam.get("npcs", []) + [pl, {"sprite": pl.get("walk", "")}]:
		if e.has("sprite") and not ResourceLoader.exists(CHARS % e["sprite"]):
			missing.append("cafe.json sprite " + str(e["sprite"]))
	for id in H.DialogueData.list_ids("res://data/phone/"):
		var d := H.load_data("res://data/phone/%s.json" % id)
		for th in d.get("threads", []):
			for img in (th.get("members", {}) as Dictionary).values():
				if not ResourceLoader.exists(CHARS % img):
					missing.append("phone avatar " + str(img))
	assert_eq(missing, [], "thiếu ảnh / nhạc")


func test_every_asset_loads() -> void:
	var bad: Array = []
	for ext in [".png", ".jpg", ".ogg", ".ttf"]:
		for p in H.files_in("res://assets/", ext):
			var res = load(p)
			if res == null:
				bad.append(p)
	assert_eq(bad, [], "tài nguyên không mở được (chưa import / hỏng)")


func test_expression_images_match_base_size() -> void:
	# debug.gd / heartbeat.gd thay texture tại chỗ -> ảnh biểu cảm phải cùng cỡ ảnh gốc.
	var bases := {}
	var files := H.files_in("res://assets/art/chars/", ".png")
	for p in files:
		bases[p.get_file().get_basename()] = p
	var bad: Array = []
	var count := 0
	for name_key in bases:
		var parts: PackedStringArray = str(name_key).split("_")
		if parts.size() < 3 or str(name_key).contains("_x_"):
			continue
		var base := "_".join(parts.slice(0, 2))
		if not bases.has(base):
			continue
		count += 1
		var a: Texture2D = load(bases[base])
		var b: Texture2D = load(bases[name_key])
		if a.get_size() != b.get_size():
			bad.append("%s %s != %s %s" % [name_key, b.get_size(), base, a.get_size()])
	assert_gt(count, 50, "không thấy ảnh biểu cảm nào")
	assert_eq(bad, [], "ảnh biểu cảm khác cỡ ảnh gốc")


func test_every_pose_image_is_used_by_a_pose() -> void:
	# ảnh biểu cảm nào chưa gắn vào characters.json thì báo (để không quên dùng)
	var chars := H.load_data(H.DialogueData.CHAR_PATH)
	var used := {}
	for c in chars:
		for p in chars[c].get("poses", {}).values():
			used[str(p.get("img", ""))] = true
	var unused: Array = []
	for p in H.files_in("res://assets/art/chars/", ".png"):
		var n: String = str(p).get_file().get_basename()
		if str(n).split("_").size() >= 3 and not n.contains("_x_") and not used.has(n):
			unused.append(n)
	assert_eq(unused, [], "ảnh biểu cảm đã tạo nhưng chưa có pose nào dùng")


func test_credits_cover_audio_and_fonts() -> void:
	var credits := FileAccess.get_file_as_string(ProjectSettings.globalize_path("res://").path_join("../docs/CREDITS.md"))
	assert_ne(credits, "", "không đọc được docs/CREDITS.md")
	var missing: Array = []
	for ext in [".ogg"]:
		for p in H.files_in("res://assets/audio/", ext):
			var n: String = str(p).get_file().get_basename()
			if not credits.contains(n):
				missing.append(p.get_file())
	for p in H.files_in("res://assets/fonts/", ".ttf"):
		var fam: String = str(p).get_file().get_basename().replace("Italic", "")
		if not credits.contains(fam) and not credits.contains(fam.replace("2", " 2")):
			missing.append(p.get_file())
	assert_eq(missing, [], "tài nguyên chưa ghi công trong docs/CREDITS.md")
