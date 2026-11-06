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
	"mini:nlong": "res://scenes/minigames/nlong_rescue.tscn",
	"mini:logic": "res://scenes/minigames/logic_puzzle.tscn",
	"mini:dark": "res://scenes/minigames/dark.tscn",
	"phone": "res://scenes/phone/phone.tscn",
	"ending": "res://scenes/ui/ending.tscn",
	"title": "res://scenes/ui/title_screen.tscn",
}

## Mini-game xong thì đi tiếp tới đâu.
const MINI_NEXT := {
	"barista": "roam:day",
	"debug": "vn:ep1_s3b",
	"heartbeat": "vn:ep1_s3c",
	"nlong": "vn:ep2_s1b",
	"logic": "vn:ep2_s3b",
	"dark": "vn:ep2_s4b",
}

const PHONE_NEXT := {"ep1": "ending", "ep2_night": "vn:ep2_s1", "ep2_end": "ending"}

## Biến thể bản đồ đi lại -> file data/roam/<map>.json
const ROAM_MAPS := {
	"day": "cafe",
	"evening": "cafe",
	"ep2_morning": "cafe",
	"ep2_afternoon": "cafe",
	"ep2_night": "street",
}
const ROAM_VARIANTS := ["day", "evening", "ep2_morning", "ep2_afternoon", "ep2_night"]

## Tập -> bước đầu tiên + tên hiển thị
const EPISODES := {
	1: {"first": "vn:ep1_s1", "title": "Tập 1 · Cú va chạm ở quán cà phê"},
	2: {"first": "phone:ep2_night", "title": "Tập 2 · Cơn bão nhỏ ở Gờ 23"},
}


static func roam_map(variant: String) -> String:
	return str(ROAM_MAPS.get(variant, "cafe"))


static func episode_of(step: String) -> int:
	return 2 if arg(step).begins_with("ep2") or step in ["mini:nlong", "mini:logic", "mini:dark"] else 1


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
		"nlong":
			# số điểm gãi trúng (0..3) + có dùng súp thưởng dụ hoàng thượng không
			var pets := int(result.get("pets", 0))
			var e2 := {"add": {"nlong": 1 if pets >= 2 else 0}, "set_flags": ["mg_nlong_done"]}
			if pets >= 3 and bool(result.get("treat", false)):
				e2["set_flags"].append("nlong_perfect")
			if bool(result.get("tail", false)):
				e2["set_flags"].append("nlong_tail")
			return e2
		"logic":
			var first := int(result.get("first_try", 0))  # số mảnh ghép đúng ngay lần đầu (0..3)
			var e3 := {"brain": 2 if first >= 3 else (1 if first >= 2 else 0), "set_flags": ["mg_logic_done"]}
			if first >= 3:
				e3["set_flags"].append("logic_perfect")
			return e3
		"dark":
			var h := int(result.get("hits", 0))
			return {"heart": 1 if h >= 2 else 0, "set_flags": ["dark_calm" if h >= 2 else "dark_fail"]}
	return {}
