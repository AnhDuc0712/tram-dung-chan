extends RefCounted
## Bộ chạy logic hội thoại (không UI). Dialogue (autoload) hiển thị, test thì gọi trực tiếp.

const DialogueData := preload("res://scripts/dialogue/dialogue_data.gd")
const MAX_BRANCH_HOPS := 64

var data: Dictionary
var state  # GameState hoặc object bất kỳ có check()/apply()
var current: Dictionary = {}
var current_id := ""
var finished := false
var then_step := ""  # bước truyện tiếp theo khi hội thoại kết thúc (khóa "then")
var visited: PackedStringArray = PackedStringArray()


func _init(p_data: Dictionary, p_state) -> void:
	data = p_data
	state = p_state


func begin() -> void:
	goto(str(data.get("start", "start")))


func goto(node_id: String) -> void:
	var nodes: Dictionary = data.get("nodes", {})
	for i in MAX_BRANCH_HOPS:
		if node_id == "end" or node_id == "":
			_end()
			return
		if not nodes.has(node_id):
			push_error("Hội thoại: không có node '%s'" % node_id)
			_end()
			return
		var node: Dictionary = nodes[node_id]
		state.apply(node.get("effects", {}))
		visited.append(node_id)
		if node.has("branch"):
			node_id = DialogueData.resolve_branch(node, state)
			continue
		current = node
		current_id = node_id
		return
	push_error("Hội thoại: branch lặp vô hạn quanh '%s'" % node_id)
	_end()


func choices() -> Array:
	if finished or not current.has("choices"):
		return []
	return DialogueData.visible_choices(current, state)


## Đi tiếp khi node hiện tại KHÔNG có lựa chọn.
func advance() -> void:
	if finished:
		return
	if current.has("next"):
		goto(str(current["next"]))
		return
	if current.has("then"):
		then_step = str(current["then"])
	_end()


func choose(index: int) -> void:
	var cs := choices()
	if index < 0 or index >= cs.size():
		return
	var c: Dictionary = cs[index]
	state.apply(c.get("effects", {}))
	if c.has("then") and not c.has("next"):
		then_step = str(c["then"])
		_end()
		return
	goto(str(c.get("next", "end")))


func _end() -> void:
	finished = true
	current = {}
	current_id = ""
