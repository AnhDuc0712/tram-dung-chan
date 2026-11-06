extends GutTest
## Bản web tải nhanh: nhạc nền nằm riêng trong music.pck (preset "WebMusic"), gói chính bỏ nhạc;
## ảnh import kiểu lossy (WebP) để gói chính nhẹ. Thêm nhạc mới mà quên khai báo -> test này báo.

const PRESETS := "res://export_presets.cfg"
const MUSIC_DIR := "res://assets/audio/music/"


func _preset(cfg: ConfigFile, preset_name: String) -> String:
	for s in cfg.get_sections():
		if cfg.get_value(s, "name", "") == preset_name:
			return s
	return ""


func test_music_pack_lists_every_track() -> void:
	var cfg := ConfigFile.new()
	assert_eq(cfg.load(PRESETS), OK)
	var web := _preset(cfg, "Web")
	var mus := _preset(cfg, "WebMusic")
	assert_ne(web, "", "thiếu preset Web")
	assert_ne(mus, "", "thiếu preset WebMusic")
	assert_string_contains(str(cfg.get_value(web, "exclude_filter", "")), "assets/audio/music/*")
	var listed: PackedStringArray = cfg.get_value(mus, "export_files", PackedStringArray())
	var missing: Array = []
	for f in DirAccess.get_files_at(MUSIC_DIR):
		if f.ends_with(".ogg") and not listed.has(MUSIC_DIR + f):
			missing.append(f)
	assert_eq(missing, [], "nhạc chưa có trong preset WebMusic (export_presets.cfg) -> bản web sẽ không có bài này")
	for f in listed:
		assert_true(FileAccess.file_exists(f), "WebMusic liệt kê file không tồn tại: " + f)


func test_art_imported_lossy() -> void:
	var lossless: Array = []
	for sub in ["bg", "cg", "chars", "ui"]:
		var d := "res://assets/art/%s/" % sub
		for f in DirAccess.get_files_at(d):
			if not f.ends_with(".import"):
				continue
			var cfg := ConfigFile.new()
			cfg.load(d + f)
			if int(cfg.get_value("params", "compress/mode", 0)) == 0:
				lossless.append(sub + "/" + f.get_basename())
	assert_eq(lossless, [], "ảnh đang import lossless (nặng gấp ~4 lần) -> đặt Compress Mode = Lossy")
