extends GutTest
## Bắt lỗi "chạm không ăn": Control vô hình (khung trống, lớp phủ) nằm trên lớp cao (Dialogue/Hud) mà vẫn nhận chuột
## sẽ nuốt mọi cú chạm phía dưới -> nút chọn tập, mini-game, bản đồ không bấm được (lỗi thật ở bản web 1.1.0).

const SCENES := ["res://scenes/ui/title_screen.tscn", "res://scenes/world/cafe.tscn", "res://scenes/minigames/logic_puzzle.tscn",
	"res://scenes/minigames/nlong_rescue.tscn", "res://scenes/minigames/barista.tscn", "res://scenes/phone/phone.tscn"]


func _blockers(n: Node, out: Array) -> void:
	if n is CanvasItem and not (n as CanvasItem).is_visible_in_tree():
		return
	if n is Control:
		var c := n as Control
		var r := c.get_global_rect()
		# Nút / ô có chức năng thì được nhận chuột; khung bọc lớn mà không phải nút thì không.
		if c.mouse_filter != Control.MOUSE_FILTER_IGNORE and not (c is BaseButton) and r.size.x * r.size.y > 160.0 * 160.0:
			out.append("%s %s" % [c.get_path(), r])
	for ch in n.get_children():
		_blockers(ch, out)


func test_overlays_do_not_swallow_taps_when_idle() -> void:
	for path in SCENES:
		var sc: Node = load(path).instantiate()
		get_tree().root.add_child(sc)
		await wait_process_frames(3)
		if Dialogue.is_active():
			sc.queue_free()
			await wait_process_frames(2)
			continue
		var bad: Array = []
		for auto in [Dialogue, Hud]:
			_blockers(auto, bad)
		assert_eq(bad, [], "%s: lớp phủ của Dialogue/Hud chặn chạm khi không có hội thoại" % path)
		sc.queue_free()
		await wait_process_frames(2)
