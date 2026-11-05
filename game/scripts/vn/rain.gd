extends Control
## Mưa vẽ bằng code (nhẹ, chạy được cả bản web). Đặt full màn hình, mouse_filter = IGNORE.

@export var drops := 220
@export var intensity := 1.0
var _p: PackedVector3Array = PackedVector3Array()  # x, y, tốc độ
var _splash: Array = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_p.resize(drops)
	for i in drops:
		_p[i] = Vector3(randf() * 1400.0 - 60.0, randf() * 760.0, randf_range(700.0, 1100.0))


func _process(delta: float) -> void:
	if not visible:
		return
	var h := size.y if size.y > 0 else 720.0
	for i in _p.size():
		var d := _p[i]
		d.y += d.z * delta
		d.x -= d.z * 0.12 * delta
		if d.y > h:
			if randf() < 0.35:
				_splash.append(Vector3(d.x, h - randf() * 160.0, 0.0))
			d = Vector3(randf() * 1400.0 - 60.0, -20.0, randf_range(700.0, 1100.0))
		_p[i] = d
	for s in range(_splash.size() - 1, -1, -1):
		var v: Vector3 = _splash[s]
		v.z += delta
		if v.z > 0.35:
			_splash.remove_at(s)
		else:
			_splash[s] = v
	queue_redraw()


func _draw() -> void:
	var col := Color(0.8, 0.88, 1.0, 0.35 * intensity)
	for d in _p:
		var len := d.z * 0.028
		draw_line(Vector2(d.x, d.y), Vector2(d.x + len * 0.12, d.y - len), col, 1.4)
	for v in _splash:
		var k: float = v.z / 0.35
		draw_arc(Vector2(v.x, v.y), 3.0 + k * 9.0, PI, TAU, 10, Color(0.85, 0.9, 1.0, 0.4 * (1.0 - k) * intensity), 1.2)
