extends Node2D
## Chiếc ô đen lớn (vẽ bằng code), hơi nghiêng về phía KyKy — dùng cho cảnh kết Tập 1.

var tilt := 0.18


func _draw() -> void:
	var r := 330.0
	var pts := PackedVector2Array()
	for i in 25:
		var a := PI + PI * float(i) / 24.0
		pts.append(Vector2(cos(a) * r, sin(a) * r * 0.55))
	# mép dưới lượn sóng
	for i in range(6, -1, -1):
		var x := -r + (2.0 * r) * float(i) / 6.0
		pts.append(Vector2(x, 0))
		if i > 0:
			pts.append(Vector2(x - r / 6.0, 22))
	draw_set_transform(Vector2.ZERO, tilt)
	draw_colored_polygon(pts, Color(0.09, 0.08, 0.1, 0.97))
	for i in 5:
		var a2 := PI + PI * float(i + 1) / 6.0
		draw_line(Vector2.ZERO + Vector2(0, -r * 0.55), Vector2(cos(a2) * r, sin(a2) * r * 0.55 + 6), Color(0.25, 0.25, 0.3), 3.0)
	draw_arc(Vector2(0, -r * 0.55), 330.0, PI * 1.2, PI * 1.45, 20, Color(1, 1, 1, 0.12), 6.0)
	draw_line(Vector2(0, -r * 0.55 - 26), Vector2(0, 470), Color(0.12, 0.12, 0.14), 7.0)
	draw_arc(Vector2(-18, 470), 18, 0, PI, 10, Color(0.12, 0.12, 0.14), 7.0)
	draw_set_transform(Vector2.ZERO)
