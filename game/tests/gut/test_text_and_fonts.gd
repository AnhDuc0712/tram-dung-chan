extends GutTest
## Chữ hiển thị: font có đủ mọi ký tự tiếng Việt không, chữ có tràn khung thoại / nút lựa chọn không,
## ngoặc kép / BBCode có đóng mở đủ không, lỗi gõ (dấu cách đôi, khoảng trắng thừa).

const H := preload("res://tests/gut/helpers.gd")

# kích thước khung thoại trong autoload/dialogue_manager.gd
const BOX_TEXT_W := 1060.0
const BOX_TEXT_H := 132.0
const TEXT_SIZE := 27
const LINE_SEP := 6
const CHOICE_SIZE := 24
const CHOICE_MAX_W := 640.0
const MONO := preload("res://assets/fonts/JetBrainsMono.ttf")

var _strings: Array


func before_all() -> void:
	_strings = H.visible_strings()


func test_found_enough_strings() -> void:
	assert_gt(_strings.size(), 300, "thu thập chuỗi hiển thị quá ít — helper hỏng?")


func test_fonts_have_every_character() -> void:
	var fonts := {
		"Nunito": load("res://assets/fonts/Nunito.ttf"),
		"NunitoItalic": load("res://assets/fonts/NunitoItalic.ttf"),
		"Baloo2": load("res://assets/fonts/Baloo2.ttf"),
	}
	var chars := {}
	for s in _strings:
		for ch in str(s["text"]):
			chars[ch] = s["src"]
	# chữ trong code (nút, HUD, màn hình chính...)
	var re := RegEx.new()
	re.compile("\"([^\"\\n]*)\"")
	var mono: Font = MONO
	for f in H.code_files():
		for line in H.read_text(f).split("\n"):
			if line.strip_edges().begins_with("#"):
				continue  # chú thích, không hiện lên màn hình
			for m in re.search_all(line):
				for ch in m.get_string(1):
					if ch.unicode_at(0) <= 127:
						continue
					# nút code trong mini-game tìm bug dùng font mono
					if f.ends_with("debug.gd") and mono.has_char(ch.unicode_at(0)):
						continue
					chars[ch] = f
	for fname in fonts:
		var font: Font = fonts[fname]
		assert_not_null(font, "không tải được font " + fname)
		var missing: Array = []
		for ch in chars:
			var code := str(ch).unicode_at(0)
			if code < 32 or ch == "\n" or ch == "\t":
				continue
			if not font.has_char(code):
				missing.append("'%s' U+%04X (%s)" % [ch, code, chars[ch]])
		assert_eq(missing, [], "font %s thiếu ký tự -> hiện ô vuông" % fname)


func test_mono_font_has_code_characters() -> void:
	var mono: Font = MONO
	var d := H.load_data("res://data/minigames/debug_ep1.json")
	var missing := {}
	for r in d.get("rounds", []):
		for line in r.get("lines", []) + [str(r.get("fix", ""))]:
			for ch in str(line):
				if not mono.has_char(str(ch).unicode_at(0)):
					missing[ch] = true
	for ch in "Quán Gờ 23 · ghé lại một chút":
		if not mono.has_char(str(ch).unicode_at(0)):
			missing[ch] = true
	assert_eq(missing.keys(), [], "JetBrains Mono thiếu ký tự")


func test_dialogue_text_fits_in_box() -> void:
	var font: Font = Ui.font_body
	var line_h := font.get_height(TEXT_SIZE) + LINE_SEP
	var too_long: Array = []
	for s in _strings:
		if s["kind"] != "text":
			continue
		var t := H.strip_bbcode(str(s["text"]))
		if bool(s.get("think", false)):
			t = "(" + t + ")"
		var sz := font.get_multiline_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, BOX_TEXT_W, TEXT_SIZE)
		var lines := roundi(sz.y / font.get_height(TEXT_SIZE))
		if lines * line_h > BOX_TEXT_H + 4:
			too_long.append("%s (%d dòng): %s…" % [s["src"], lines, t.left(40)])
	assert_eq(too_long, [], "câu thoại dài quá 3 dòng -> tràn khỏi khung")


func test_choice_text_fits_button() -> void:
	# nút lựa chọn tự xuống dòng (autowrap) — tối đa 2 dòng là vừa, 3 dòng trở lên là che mất nhân vật
	var font: Font = Ui.font_body
	var wide: Array = []
	for s in _strings:
		if s["kind"] != "choice":
			continue
		var sz := font.get_multiline_string_size(str(s["text"]), HORIZONTAL_ALIGNMENT_LEFT, CHOICE_MAX_W - 40, CHOICE_SIZE)
		var lines := roundi(sz.y / font.get_height(CHOICE_SIZE))
		if lines > 2:
			wide.append("%s (%d dòng): %s" % [s["src"], lines, s["text"]])
	assert_eq(wide, [], "lựa chọn quá dài -> nút cao quá 2 dòng")


func test_quotes_and_brackets_balanced() -> void:
	var bad: Array = []
	for s in _strings:
		var t := str(s["text"])
		if t.count("“") != t.count("”"):
			bad.append("%s: ngoặc kép “ ” lệch" % s["src"])
		if t.count("(") != t.count(")"):
			bad.append("%s: ngoặc ( ) lệch" % s["src"])
		for tag in ["b", "i", "color", "u"]:
			var open := t.count("[" + tag + "]") + t.count("[" + tag + "=")
			if open != t.count("[/" + tag + "]"):
				bad.append("%s: thẻ [%s] chưa đóng" % [s["src"], tag])
	assert_eq(bad, [], "dấu ngoặc / thẻ BBCode không cân")


func test_no_typing_mistakes() -> void:
	var bad: Array = []
	for s in _strings:
		var t := str(s["text"])
		if t.contains("  ") and not str(s["src"]).contains("debug_ep1"):  # code có thụt lề
			bad.append("%s: dấu cách đôi" % s["src"])
		if t != t.strip_edges() and s["kind"] != "data":
			bad.append("%s: khoảng trắng thừa ở đầu/cuối" % s["src"])
		if t.contains(" ,") or t.contains(" .") and not t.contains(" ..."):
			bad.append("%s: dấu cách trước dấu câu" % s["src"])
		if t.strip_edges() == "" and s["kind"] in ["text", "choice", "name"]:
			bad.append("%s: chuỗi rỗng" % s["src"])
	assert_eq(bad, [], "lỗi gõ trong lời thoại")


func test_no_forbidden_symbols() -> void:
	# CLAUDE.md: không dùng emoji / ký tự hiếm trong chữ (font web không có) -> vẽ bằng shapes.gd
	var bad: Array = []
	for s in _strings:
		for ch in str(s["text"]):
			var c := str(ch).unicode_at(0)
			if c >= 0x2600 and c <= 0x27BF or c >= 0x1F000:
				bad.append("%s: '%s'" % [s["src"], ch])
	assert_eq(bad, [], "có emoji / ký hiệu hiếm trong chữ")
