extends RefCounted
## Bảng "bước truyện" của Tập 1 (không dính UI -> test dùng được).
## Một bước là chuỗi "<loại>:<tham số>":
##   vn:<id hội thoại>    cảnh visual novel (file data/dialogue/<id>.json)
##   roam:day|evening     đi lại tự do trong quán Gờ 23
##   mini:barista|debug|heartbeat   mini-game
##   phone:<id>           màn hình nhắn tin (data/phone/<id>.json)
##   ending               màn kết thúc (dùng GameState.ending_id)
##   title                về màn hình chính

const SCENES := {
	"vn": "res://scenes/vn/vn_scene.tscn",
	"roam": "res://scenes/world/cafe.tscn",
	"mini:barista": "res://scenes/minigames/barista.tscn",
	"mini:debug": "res://scenes/minigames/debug.tscn",
	"mini:heartbeat": "res://scenes/minigames/heartbeat.tscn",
	"phone": "res://scenes/phone/phone.tscn",
	"ending": "res://scenes/ui/ending.tscn",
	"title": "res://scenes/ui/title_screen.tscn",
}

## Mini-game xong thì đi tiếp tới đâu.
const MINI_NEXT := {
	"barista": "roam:day",
	"debug": "vn:ep1_s3b",
	"heartbeat": "vn:ep1_s3c",
}

const PHONE_NEXT := {"ep1": "ending"}

const ROAM_VARIANTS := ["day", "evening"]


static func kind(step: String) -> String:
	return step.split(":")[0]


static func arg(step: String) -> String:
	var i := step.find(":")
	return step.substr(i + 1) if i >= 0 else ""


static func scene_for(step: String) -> String:
	if SCENES.has(step):
		return SCENES[step]
	return str(SCENES.get(kind(step), ""))


## Trả về "" nếu hợp lệ, ngược lại là mô tả lỗi.
static func validate_step(step: String, dialogue_ids: PackedStringArray, phone_ids: PackedStringArray) -> String:
	var k := kind(step)
	var a := arg(step)
	match k:
		"vn":
			return "" if dialogue_ids.has(a) else "bước '%s': không có hội thoại '%s'" % [step, a]
		"roam":
			return "" if ROAM_VARIANTS.has(a) else "bước '%s': map không có biến thể '%s'" % [step, a]
		"mini":
			return "" if MINI_NEXT.has(a) else "bước '%s': không có mini-game '%s'" % [step, a]
		"phone":
			return "" if phone_ids.has(a) else "bước '%s': không có data/phone/%s.json" % [step, a]
		"ending", "title":
			return ""
	return "bước '%s' không hợp lệ" % step


## Kết quả mini-game -> hiệu ứng (GameState.apply). Dùng chung cho scene mini-game và test.
static func minigame_effects(name: String, result: Dictionary) -> Dictionary:
	match name:
		"barista":
			var fl: Array = ["drink_made"]
			fl.append("drink_" + str(result.get("drink", "cacao")))
			fl.append("art_" + str(result.get("art", "smile")))
			if bool(result.get("weird", false)):
				fl.append("drink_weird")
			return {"set_flags": fl}
		"debug":
			var n := int(result.get("correct", 0))
			var eff := {"brain": n, "set_flags": ["debug_done"]}
			if n >= 3:
				eff["set_flags"].append("debug_perfect")
			return eff
		"heartbeat":
			var hits := int(result.get("hits", 0))
			return {"set_flags": ["calm_ok" if hits >= 2 else "calm_fail"]}
	return {}
