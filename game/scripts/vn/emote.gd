extends Node2D
## Biểu cảm vẽ thêm quanh đầu nhân vật (vì ảnh gốc mới có 2 tư thế / nhân vật).
## kind: "" | "!" | "?" | "sweat" | "blush" | "heart" | "sparkle" | "gloom" | "anger" | "zzz" | "flowers" | "tears" | "dots"

const Shapes := preload("res://scripts/ui/shapes.gd")

var kind := ""
var head := Vector2.ZERO  # tâm mặt (toạ độ trong actor, chưa scale)
var head_w := 100.0
var top := -500.0
var t := 0.0


func restart() -> void:
	t = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	if kind == "":
		return
	t += delta
	queue_redraw()


func _draw() -> void:
	if kind == "":
		return
	var w := head_w
	var tip := head + Vector2(w * 0.62, -w * 0.62)  # góc trên bên phải đầu
	var pop := clampf(t * 6.0, 0.0, 1.0)
	pop = 1.0 + 0.25 * sin(pop * PI) if pop < 1.0 else 1.0
	match kind:
		"!":
			var c := tip + Vector2(0, -sin(minf(t, 0.3) * 10.0) * 6.0)
			draw_rect(Rect2(c.x - w * 0.045, c.y - w * 0.3 * pop, w * 0.09, w * 0.24 * pop), Color("e8455f"))
			draw_circle(c + Vector2(0, w * 0.04), w * 0.055, Color("e8455f"))
		"?":
			_text(tip, "?", w * 0.42 * pop, Color("5b7fd6"))
		"sweat":
			var y := fmod(t * 0.6, 1.0) * w * 0.12
			Shapes.draw_drop(self, head + Vector2(w * 0.5, -w * 0.25 + y), w * 0.13, Color(0.55, 0.8, 1.0, 0.95))
		"blush":
			var a := clampf(t * 3.0, 0.0, 0.55)
			for sx in [-1.0, 1.0]:
				var cc := head + Vector2(sx * w * 0.3, w * 0.12)
				draw_set_transform(cc, 0.0, Vector2(1.0, 0.45))
				draw_circle(Vector2.ZERO, w * 0.12, Color(1.0, 0.35, 0.45, a))
				draw_set_transform(Vector2.ZERO)
				for i in 3:
					var lx := cc.x - w * 0.07 + i * w * 0.06
					draw_line(Vector2(lx, cc.y - w * 0.03), Vector2(lx - w * 0.03, cc.y + w * 0.03), Color(0.85, 0.2, 0.3, a), 2.0)
		"heart":
			for i in 3:
				var ph := fmod(t * 0.7 + i * 0.33, 1.0)
				var c2 := tip + Vector2(sin(ph * 6.0 + i) * w * 0.12 - i * w * 0.15, -ph * w * 0.6)
				Shapes.draw_heart(self, c2, w * (0.14 + 0.05 * (1.0 - ph)), Color(0.93, 0.36, 0.52, 1.0 - ph))
		"sparkle":
			for i in 3:
				var s := (0.5 + 0.5 * sin(t * 5.0 + i * 2.1)) * w * 0.12 + w * 0.03
				Shapes.draw_star(self, tip + Vector2(i * w * 0.18 - w * 0.1, (i % 2) * w * 0.2 - w * 0.05), s, Color("ffd54a"))
		"gloom":
			for i in 4:
				var x := head.x - w * 0.45 + i * w * 0.11
				var len := w * (0.35 + 0.1 * sin(t * 3.0 + i))
				draw_line(Vector2(x, head.y - w * 0.55), Vector2(x, head.y - w * 0.55 + len), Color(0.35, 0.4, 0.75, 0.6), 3.0)
		"anger":
			var c3 := tip
			var r := w * 0.13 * pop
			var col := Color("e8455f")
			for a2 in [0.0, PI / 2, PI, PI * 1.5]:
				var d := Vector2(cos(a2 + PI / 4), sin(a2 + PI / 4))
				draw_arc(c3 + d * r, r * 0.7, a2 + PI * 0.75, a2 + PI * 1.75, 8, col, 4.0)
		"zzz":
			for i in 3:
				var ph2 := fmod(t * 0.5 + i * 0.33, 1.0)
				_text(tip + Vector2(i * w * 0.12, -ph2 * w * 0.4), "z", w * (0.18 + i * 0.05), Color(0.4, 0.45, 0.7, 1.0 - ph2))
		"flowers":
			for i in 6:
				var a3 := TAU * i / 6.0 + t * 0.6
				var rr := w * (0.75 + 0.08 * sin(t * 3.0 + i))
				var cf := head + Vector2(cos(a3) * rr, sin(a3) * rr * 0.75 - w * 0.1)
				var colf := Color("ffb3c8") if i % 2 == 0 else Color("fff0a8")
				Shapes.draw_flower(self, cf, w * 0.07 * minf(t * 4.0, 1.0), colf)
		"tears":
			for sx2 in [-1.0, 1.0]:
				var ph3 := fmod(t * 1.2 + (0.5 if sx2 > 0 else 0.0), 1.0)
				Shapes.draw_drop(self, head + Vector2(sx2 * w * 0.28, w * 0.05 + ph3 * w * 0.3), w * 0.07, Color(0.55, 0.8, 1.0, 1.0 - ph3))
		"dots":
			var n := int(t * 3.0) % 4
			for i in n:
				draw_circle(tip + Vector2(i * w * 0.12 - w * 0.12, 0), w * 0.035, Color("4a2e1f"))


func _text(pos: Vector2, s: String, size: float, col: Color) -> void:
	var f: Font = Ui.font_title if Ui.font_title else ThemeDB.fallback_font
	draw_string_outline(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, -1, int(size), 6, Color(1, 1, 1, col.a))
	draw_string(f, pos, s, HORIZONTAL_ALIGNMENT_CENTER, -1, int(size), col)
