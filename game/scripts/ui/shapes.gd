extends RefCounted
## Vẽ hình đơn giản bằng code (trái tim, bóng đèn, ngôi sao, hoa...) để khỏi cần ảnh / emoji.


static func heart_points(c: Vector2, s: float, n: int = 36) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var t := TAU * float(i) / float(n)
		var x := 16.0 * pow(sin(t), 3)
		var y := 13.0 * cos(t) - 5.0 * cos(2 * t) - 2.0 * cos(3 * t) - cos(4 * t)
		pts.append(c + Vector2(x, -y) * (s / 32.0))
	return pts


static func draw_heart(ci: CanvasItem, c: Vector2, s: float, col: Color, outline: Color = Color(0, 0, 0, 0)) -> void:
	var pts := heart_points(c, s)
	ci.draw_colored_polygon(pts, col)
	if outline.a > 0:
		var closed := pts.duplicate()
		closed.append(pts[0])
		ci.draw_polyline(closed, outline, maxf(1.5, s * 0.07), true)
	ci.draw_circle(c + Vector2(-s * 0.2, -s * 0.12), s * 0.09, Color(1, 1, 1, 0.55 * col.a))


static func draw_bulb(ci: CanvasItem, c: Vector2, s: float, col: Color, lit: bool = true) -> void:
	var r := s * 0.36
	if lit:
		for i in 8:
			var a := TAU * i / 8.0 - PI / 2
			if absf(sin(a)) > 0.95 and sin(a) > 0:
				continue
			var d := Vector2(cos(a), sin(a))
			ci.draw_line(c + d * r * 1.35 + Vector2(0, -s * 0.08), c + d * r * 1.75 + Vector2(0, -s * 0.08), Color("f5b83c"), maxf(1.5, s * 0.06), true)
	ci.draw_circle(c + Vector2(0, -s * 0.08), r, col)
	ci.draw_circle(c + Vector2(-r * 0.35, -s * 0.08 - r * 0.35), r * 0.25, Color(1, 1, 1, 0.6))
	var base := Rect2(c.x - r * 0.45, c.y + r * 0.6, r * 0.9, r * 0.75)
	ci.draw_rect(base, Color("a59a8c"))
	var band_y := base.position.y + base.size.y * 0.4
	ci.draw_line(Vector2(base.position.x, band_y), Vector2(base.end.x, band_y), Color("7d7266"), maxf(1.0, s * 0.04))


static func draw_star(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 8:
		var r := s if i % 2 == 0 else s * 0.28
		var a := TAU * i / 8.0 - PI / 2
		pts.append(c + Vector2(cos(a), sin(a)) * r)
	ci.draw_colored_polygon(pts, col)


static func draw_flower(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	for i in 5:
		var a := TAU * i / 5.0
		ci.draw_circle(c + Vector2(cos(a), sin(a)) * s * 0.55, s * 0.45, col)
	ci.draw_circle(c, s * 0.38, Color("ffe08a"))


static func draw_drop(ci: CanvasItem, c: Vector2, s: float, col: Color) -> void:
	var pts := PackedVector2Array()
	pts.append(c + Vector2(0, -s))
	for i in 13:
		var a := PI * float(i) / 12.0
		pts.append(c + Vector2(cos(a) * s * 0.55, sin(a) * s * 0.55 + s * 0.15))
	ci.draw_colored_polygon(pts, col)
	ci.draw_circle(c + Vector2(-s * 0.15, s * 0.05), s * 0.12, Color(1, 1, 1, 0.7))
