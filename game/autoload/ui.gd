extends Node
## Phong cách giao diện chung (màu, font, theme) + vài hàm tạo nhanh control. Autoload "Ui".
## Phong cách lấy theo bản mockup "thiết kế/env/...(3).png": khung kem bo tròn, viền nâu nhạt, điểm hồng.

const CREAM := Color("fff8ee")
const CREAM_DARK := Color("f3e6d3")
const BORDER := Color("c9a27e")
const TEXT := Color("4a2e1f")
const TEXT_SOFT := Color("8a6a55")
const PINK := Color("e8608c")
const PINK_SOFT := Color("fbd9e3")
const YELLOW := Color("f5c84c")
const SHADOW := Color(0.18, 0.1, 0.05, 0.25)

var font_body: Font
var font_bold: Font
var font_italic: Font
var font_title: Font
var font_mono: Font
var theme: Theme
## Máy cảm ứng (điện thoại / máy tính bảng) -> đổi gợi ý "E / Ctrl" thành "chạm", hiện nút tua.
## Ép bật để thử trên máy tính: tham số "-- --touch".
var touch := false


func _ready() -> void:
	font_body = _font("res://assets/fonts/Nunito.ttf", 500)
	font_bold = _font("res://assets/fonts/Nunito.ttf", 800)
	font_italic = _font("res://assets/fonts/NunitoItalic.ttf", 500)
	font_title = _font("res://assets/fonts/Baloo2.ttf", 700)
	font_mono = _font("res://assets/fonts/JetBrainsMono.ttf", 500)
	if font_mono is FontVariation:
		var ts := TextServerManager.get_primary_interface()
		(font_mono as FontVariation).opentype_features = {ts.name_to_tag("calt"): 0, ts.name_to_tag("liga"): 0}
	theme = _build_theme()
	get_tree().root.theme = theme
	var forced := OS.get_cmdline_user_args().has("--touch")
	touch = forced or DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")
	touch = touch or OS.has_feature("web_android") or OS.has_feature("web_ios")


func is_web() -> bool:
	return OS.has_feature("web")


func is_fullscreen() -> bool:
	var m := DisplayServer.window_get_mode()
	return m == DisplayServer.WINDOW_MODE_FULLSCREEN or m == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN


## Bật/tắt toàn màn hình. Trên web phải gọi từ một lần bấm (trình duyệt yêu cầu);
## khi vào toàn màn hình, trang web tự khoá màn hình nằm ngang (xem html/head_include trong export_presets.cfg).
func toggle_fullscreen() -> void:
	if is_fullscreen():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _font(path: String, weight: int) -> Font:
	if not ResourceLoader.exists(path):
		return ThemeDB.fallback_font
	var fv := FontVariation.new()
	fv.base_font = load(path)
	fv.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): weight}
	return fv


func box(bg: Color = CREAM, border: Color = BORDER, radius: int = 18, bw: int = 3, shadow: bool = true) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	s.anti_aliasing = true
	if shadow:
		s.shadow_color = SHADOW
		s.shadow_size = 6
		s.shadow_offset = Vector2(0, 3)
	return s


func _build_theme() -> Theme:
	var t := Theme.new()
	t.default_font = font_body
	t.default_font_size = 24
	t.set_color("font_color", "Label", TEXT)
	# Nút: viên thuốc màu kem
	var normal := box(CREAM, BORDER, 26, 3)
	var hover := box(Color("fff1f4"), PINK, 26, 3)
	var pressed := box(PINK_SOFT, PINK, 26, 3, false)
	var disabled := box(CREAM_DARK, Color("d8c8b4"), 26, 2, false)
	for s in [normal, hover, pressed, disabled]:
		s.content_margin_left = 28
		s.content_margin_right = 28
	t.set_stylebox("normal", "Button", normal)
	t.set_stylebox("hover", "Button", hover)
	t.set_stylebox("pressed", "Button", pressed)
	t.set_stylebox("hover_pressed", "Button", pressed)
	t.set_stylebox("focus", "Button", box(Color(0, 0, 0, 0), PINK, 26, 2, false))
	t.set_stylebox("disabled", "Button", disabled)
	t.set_color("font_color", "Button", TEXT)
	t.set_color("font_hover_color", "Button", Color("b03a64"))
	t.set_color("font_pressed_color", "Button", Color("b03a64"))
	t.set_color("font_focus_color", "Button", TEXT)
	t.set_color("font_disabled_color", "Button", Color("b8a592"))
	t.set_font("font", "Button", font_bold)
	t.set_font_size("font_size", "Button", 24)
	t.set_stylebox("panel", "PanelContainer", box())
	t.set_stylebox("panel", "Panel", box())
	t.set_font("normal_font", "RichTextLabel", font_body)
	t.set_font("bold_font", "RichTextLabel", font_bold)
	t.set_font("italics_font", "RichTextLabel", font_italic)
	t.set_color("default_color", "RichTextLabel", TEXT)
	t.set_font_size("normal_font_size", "RichTextLabel", 25)
	t.set_font_size("bold_font_size", "RichTextLabel", 25)
	t.set_font_size("italics_font_size", "RichTextLabel", 25)
	# Thanh trượt / tiến trình
	var bar_bg := box(Color("f1e4d2"), BORDER, 10, 2, false)
	var bar_fill := box(PINK, Color(0, 0, 0, 0), 10, 0, false)
	t.set_stylebox("background", "ProgressBar", bar_bg)
	t.set_stylebox("fill", "ProgressBar", bar_fill)
	t.set_stylebox("slider", "HSlider", box(Color("f1e4d2"), BORDER, 8, 2, false))
	t.set_stylebox("grabber_area", "HSlider", box(PINK_SOFT, PINK, 8, 2, false))
	t.set_stylebox("grabber_area_highlight", "HSlider", box(PINK_SOFT, PINK, 8, 2, false))
	t.set_color("font_color", "CheckButton", TEXT)
	return t


func label(text: String, size: int = 24, color: Color = TEXT, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	if font:
		l.add_theme_font_override("font", font)
	return l


func button(text: String, min_width: float = 260.0, size: int = 24) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(min_width, 54)
	b.add_theme_font_size_override("font_size", size)
	b.focus_mode = Control.FOCUS_NONE
	b.mouse_entered.connect(func() -> void: Audio.sfx("hover", -12.0))
	b.pressed.connect(func() -> void: Audio.sfx("click"))
	return b


## Lấy ảnh nhân vật đã cắt: res://assets/art/chars/<name>.png
func char_tex(img: String) -> Texture2D:
	var p := "res://assets/art/chars/%s.png" % img
	if ResourceLoader.exists(p):
		return load(p)
	return null


## Ảnh đại diện tròn (cắt phần đầu từ ảnh nhân vật) dùng cho điện thoại / danh sách.
func head_tex(img: String, frac: float = 0.36) -> Texture2D:
	var t := char_tex(img)
	if t == null:
		return null
	var a := AtlasTexture.new()
	a.atlas = t
	var w := float(t.get_width())
	var h := float(t.get_height()) * frac
	var side := minf(w, h)
	a.region = Rect2((w - side) * 0.5, 0, side, side)
	return a


## Hiện một dòng thông báo nhỏ giữa trên màn hình (vd "+1 ❤").
func toast(text: String, color: Color = PINK) -> void:
	Hud.toast(text, color)
