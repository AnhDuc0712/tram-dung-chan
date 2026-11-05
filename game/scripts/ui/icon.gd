extends Control
## Biểu tượng vẽ bằng code: "heart" (❤), "bulb" (💡), "paw" (mèo), "phone", "menu".

const Shapes := preload("res://scripts/ui/shapes.gd")

@export var kind := "heart"
@export var color := Color("e8608c")
var pulse := 0.0


func _init(p_kind: String = "heart", p_size: float = 48.0) -> void:
	kind = p_kind
	custom_minimum_size = Vector2(p_size, p_size)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func bump() -> void:
	pulse = 1.0


func _process(delta: float) -> void:
	if pulse > 0.0:
		pulse = maxf(pulse - delta * 3.0, 0.0)
		queue_redraw()


func _draw() -> void:
	var s := minf(size.x, size.y)
	var c := size * 0.5
	var k := 1.0 + 0.25 * sin(pulse * PI)
	match kind:
		"heart":
			Shapes.draw_heart(self, c + Vector2(0, s * 0.04), s * 0.95 * k, Color("f06292"), Color("c2185b"))
		"bulb":
			Shapes.draw_bulb(self, c, s * 0.95 * k, Color("ffd54f"))
		"paw":
			var col := Color("8d8d99")
			draw_circle(c + Vector2(0, s * 0.12), s * 0.22 * k, col)
			for i in 4:
				var a := PI + PI * (0.15 + 0.7 * i / 3.0)
				draw_circle(c + Vector2(cos(a), sin(a)) * s * 0.3 + Vector2(0, s * 0.02), s * 0.1 * k, col)
		"phone":
			var r := Rect2(c.x - s * 0.22, c.y - s * 0.36, s * 0.44, s * 0.72)
			draw_rect(r, Color("4a2e1f"), false, 3.0)
			draw_rect(Rect2(r.position + Vector2(4, 6), r.size - Vector2(8, 16)), Color("cfe8f7"))
			draw_circle(Vector2(c.x, r.end.y - 5), 2.5, Color("4a2e1f"))
		"menu":
			for i in 3:
				var y := c.y - s * 0.2 + i * s * 0.2
				draw_line(Vector2(c.x - s * 0.25, y), Vector2(c.x + s * 0.25, y), Color("4a2e1f"), 4.0, true)
