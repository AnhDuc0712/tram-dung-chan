# Gán biểu cảm cho câu thoại của Anh Đức / KyKy chưa có "show" (chỉ khi cảm xúc rõ trong câu chữ).
#   python tools\auto_poses.py          -> xem trước số câu sẽ đổi
#   python tools\auto_poses.py --write  -> ghi vào data/dialogue/*.json
# Quy tắc thận trọng: bỏ qua lời nghĩ (think), câu đã đặt biểu cảm cho người nói, câu không có người nói.
import glob
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DLG = ROOT / "game/data/dialogue"
CHARS = json.load(open(ROOT / "game/data/characters.json", encoding="utf-8"))

RULES = [  # (regex trên câu chữ, pose duc, pose kyky) — dòng đầu khớp được dùng
	(r"^(haha|hihi|hì|hehe|phụt|khà)", "laugh", "laugh"),
	(r"(haha|hihi|hehe)", "laugh", "laugh"),
	(r"^(á|ơ|hả|trời|cái gì|ủa|ối|chết)[!,.… ]", "surprised", "surprised"),
	(r"^…", "think", "worried"),
	(r"(xin lỗi|tại em|lỗi của)", "awkward", "sad"),
	(r"(cảm ơn|thích quá|vui quá|tuyệt quá|dễ thương)", "happy", "happy"),
	(r"\?$", "curious", "confused"),
]


def pick(speaker: str, text: str) -> str:
	t = text.strip().lower()
	for rx, d, k in RULES:
		if re.search(rx, t):
			pose = d if speaker == "duc" else k
			return pose if pose in CHARS[speaker]["poses"] else ""
	return ""


def main(write: bool) -> None:
	total = 0
	for f in sorted(DLG.glob("*.json")):
		s = f.read_text(encoding="utf-8")
		data = json.loads(s)
		changed = 0
		for key, n in data.get("nodes", {}).items():
			sp = n.get("speaker", "")
			if sp not in ("duc", "kyky") or n.get("think") or "text" not in n:
				continue
			if sp in (n.get("show") or {}):
				continue
			pose = pick(sp, n["text"])
			if pose == "":
				continue
			# chèn "show" vào đúng dòng của node trong file (giữ nguyên định dạng 1 node / 1 dòng)
			pat = re.compile(r'(\t\t"' + re.escape(key) + r'": \{)(?!"show")')
			if "show" in n:
				pat2 = re.compile(r'(\t\t"' + re.escape(key) + r'": \{.*?"show": \{)')
				s, k = pat2.subn(lambda m: m.group(1) + '"%s": "%s", ' % (sp, pose), s, count=1)
			else:
				s, k = pat.subn(lambda m: m.group(1) + '"show": {"%s": "%s"}, ' % (sp, pose), s, count=1)
			changed += k
		if changed:
			json.loads(s)  # vẫn là JSON hợp lệ
			total += changed
			print(f"{f.name}: +{changed}")
			if write:
				f.write_text(s, encoding="utf-8", newline="\n")
	print("tổng:", total, "(đã ghi)" if write else "(xem trước — thêm --write để ghi)")


if __name__ == "__main__":
	main("--write" in sys.argv)
