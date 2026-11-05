extends CharacterBody2D
## Anh Đức trong bản đồ: đi bằng phím (WASD/mũi tên) hoặc chạm/bấm chuột để tự tìm đường.
## Gốc toạ độ = chân nhân vật.

signal arrived

const SPEED := 230.0
const ACCEL := 1200.0  # tăng/giảm tốc mượt khi đi bằng phím

var idle_tex: Texture2D
var walk_tex: Texture2D
var path: PackedVector2Array = PackedVector2Array()
var frozen := false
var _sprite: Sprite2D
var _t := 0.0
var _scale := 0.17


func setup(idle: Texture2D, walk: Texture2D, sc: float) -> void:
	idle_tex = idle
	walk_tex = walk
	_scale = sc
	add_to_group("player")
	_sprite = Sprite2D.new()
	_sprite.centered = false
	_sprite.scale = Vector2.ONE * sc
	add_child(_sprite)
	_set_tex(idle_tex)
	var shadow := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in 16:
		var a := TAU * i / 16.0
		pts.append(Vector2(cos(a) * 18.0, sin(a) * 6.0))
	shadow.polygon = pts
	shadow.color = Color(0, 0, 0, 0.25)
	shadow.show_behind_parent = true
	add_child(shadow)
	move_child(shadow, 0)
	var col := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 9.0
	col.shape = c
	add_child(col)


func _set_tex(t: Texture2D) -> void:
	if t == null or _sprite.texture == t:
		return
	_sprite.texture = t
	_sprite.position = Vector2(-t.get_width() * _scale * 0.5, -t.get_height() * _scale)


func go_along(p: PackedVector2Array) -> void:
	path = p


func stop() -> void:
	path = PackedVector2Array()
	velocity = Vector2.ZERO


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if not frozen:
		dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if frozen:
		velocity = Vector2.ZERO
	elif dir != Vector2.ZERO:
		path = PackedVector2Array()  # phím bấm huỷ đường đi tự động
		velocity = velocity.move_toward(dir * SPEED, ACCEL * delta)
	elif path.size() > 0:
		# chạm/bấm chuột: đi theo đường tìm sẵn (vận tốc đổi ngay để không cắt góc vào vật cản)
		var to := path[0] - global_position
		if to.length() < 6.0:
			path.remove_at(0)
			if path.is_empty():
				velocity = Vector2.ZERO
				arrived.emit()
		else:
			velocity = to.normalized() * SPEED
	elif has_node("NavigationAgent2D") and not ($NavigationAgent2D as NavigationAgent2D).is_navigation_finished():
		# (tuỳ chọn) nếu sau này gắn NavigationAgent2D cho nhân vật
		var agent := $NavigationAgent2D as NavigationAgent2D
		var to_target := agent.get_next_path_position() - global_position
		velocity = velocity.move_toward(to_target.normalized() * SPEED, ACCEL * delta) if to_target.length() > 0.0 else Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, ACCEL * delta)
	move_and_slide()

	# hoạt ảnh đi bộ đơn giản
	var moving := velocity.length() > 5.0
	_set_tex(walk_tex if moving else idle_tex)
	if moving:
		_t += delta * 12.0
		_sprite.position.y = -_sprite.texture.get_height() * _scale - absf(sin(_t)) * 5.0
		if absf(velocity.x) > 8.0:
			_sprite.flip_h = velocity.x < 0
	else:
		_t = 0.0
		_sprite.position.y = -_sprite.texture.get_height() * _scale
		if _sprite.texture == idle_tex:
			_sprite.flip_h = false
