extends Node2D
## Một nhân vật đứng trên sân khấu visual novel: ảnh + biểu cảm vẽ thêm (emote) + chuyển động.
## Gốc toạ độ (position) = điểm giữa chân nhân vật.

const Emote := preload("res://scripts/vn/emote.gd")

var char_id := ""
var sprite: Sprite2D
var emote: Node2D
var inset: Node2D  # ô biểu cảm phác thảo (manga) cạnh đầu
var _inset_sprite: Sprite2D
var _bob_tween: Tween
var _base_scale := 1.0


func setup(id: String, scale_factor: float) -> void:
	char_id = id
	_base_scale = scale_factor
	sprite = Sprite2D.new()
	sprite.centered = false
	add_child(sprite)
	emote = Emote.new()
	add_child(emote)
	inset = Node2D.new()
	inset.visible = false
	inset.draw.connect(_draw_inset_frame)
	add_child(inset)
	_inset_sprite = Sprite2D.new()
	inset.add_child(_inset_sprite)
	scale = Vector2.ONE * scale_factor


func set_pose(tex: Texture2D, flip: bool, emote_kind: String, face: Vector2) -> void:
	if tex == null:
		return
	sprite.texture = tex
	sprite.flip_h = flip
	var size := tex.get_size()
	sprite.position = Vector2(-size.x * 0.5, -size.y)
	var fx := face.x if not flip else 1.0 - face.x
	emote.head = Vector2((fx - 0.5) * size.x, -size.y + face.y * size.y)
	emote.head_w = size.x * 0.55
	emote.top = -size.y
	emote.kind = emote_kind
	emote.restart()


## Hiện ô phác thảo biểu cảm (ảnh *_x_*.png) cạnh đầu. tex = null để ẩn.
func set_inset(tex: Texture2D, on_left: bool) -> void:
	if tex == null:
		inset.visible = false
		return
	_inset_sprite.texture = tex
	var target_px := 150.0
	var k := target_px / float(tex.get_width()) / maxf(_base_scale, 0.01)
	inset.scale = Vector2.ONE * k
	var hw: float = emote.head_w
	var head_pos: Vector2 = emote.head
	inset.position = head_pos + Vector2((-1.0 if on_left else 1.0) * (hw * 0.75 + target_px * 0.5 / _base_scale), -hw * 0.35)
	inset.visible = true
	inset.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(inset, "modulate:a", 1.0, 0.15)
	inset.queue_redraw()


func _draw_inset_frame() -> void:
	if _inset_sprite.texture == null:
		return
	var sz := _inset_sprite.texture.get_size()
	var r := Rect2(-sz * 0.5 - Vector2(10, 10), sz + Vector2(20, 20))
	inset.draw_rect(Rect2(r.position + Vector2(6, 8), r.size), Color(0, 0, 0, 0.18))
	inset.draw_rect(r, Color("fdf8f0"))
	inset.draw_rect(r, Color("e8608c"), false, 6.0)


func set_emote(kind: String) -> void:
	emote.kind = kind
	emote.restart()


func set_dim(dim: bool) -> void:
	var target := Color(0.72, 0.68, 0.7) if dim else Color.WHITE
	create_tween().tween_property(sprite, "modulate", target, 0.18)


func animate(kind: String) -> void:
	if _bob_tween:
		_bob_tween.kill()
	_bob_tween = create_tween()
	match kind:
		"hop":
			_bob_tween.tween_property(sprite, "position:y", sprite.position.y - 26, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			_bob_tween.tween_property(sprite, "position:y", sprite.position.y, 0.16).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		"shake":
			var x0 := sprite.position.x
			for i in 6:
				_bob_tween.tween_property(sprite, "position:x", x0 + (12.0 if i % 2 == 0 else -12.0), 0.04)
			_bob_tween.tween_property(sprite, "position:x", x0, 0.04)
		"lean":
			_bob_tween.tween_property(self, "scale", Vector2.ONE * _base_scale * 1.06, 0.4).set_trans(Tween.TRANS_SINE)
		"back":
			_bob_tween.tween_property(self, "scale", Vector2.ONE * _base_scale, 0.4).set_trans(Tween.TRANS_SINE)


func enter_from(x_from: float, x_to: float) -> void:
	position.x = x_from
	modulate.a = 0.0
	var tw := create_tween().set_parallel()
	tw.tween_property(self, "position:x", x_to, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "modulate:a", 1.0, 0.3)


func move_to(x: float) -> void:
	create_tween().tween_property(self, "position:x", x, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func leave() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.25)
	tw.tween_callback(queue_free)
