# Dáng "đứng thường" (không vẫy tay) từ sprite vẫy tay: xoá cánh tay đang giơ, lật đối xứng cánh tay đút túi
# bên kia sang. Biểu cảm của dáng đứng do make_expressions.py sinh từ ảnh gốc này.
#   tools\.venv-art\Scripts\python.exe -I tools\art\make_stand.py
# Chỉ tạo ảnh gốc duc_stand.png; biểu cảm duc_stand_<x>.png do make_expressions.py sinh (cùng toạ độ mặt duc_front).
# Thứ tự: cut_sprites.py -> make_stand.py -> make_expressions.py
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CHARS = ROOT / "game/assets/art/chars"
# base nguồn -> (tên mới, trục đối xứng x, cắt tay giơ: x < cut_x trong y từ top_y, vùng dán lấy x < paste_max)
JOBS = {"duc_front": ("duc_stand", 141, 79, 150, 101)}


def convert(src: Image.Image, axis: int, cut_x: int, top_y: int, paste_max: int) -> Image.Image:
	im = src.copy()
	w, h = im.size
	px = im.load()
	for y in range(top_y, h):
		for x in range(0, cut_x):
			px[x, y] = (0, 0, 0, 0)
	mirror = src.transpose(Image.FLIP_LEFT_RIGHT)
	# mirror(x) = src(w-1-x); muốn đối xứng quanh trục axis: dst(x) = src(2*axis - x) = mirror(w-1-2*axis+x)
	shift = w - 1 - 2 * axis
	strip = Image.new("RGBA", im.size, (0, 0, 0, 0))
	strip.paste(mirror.crop((max(shift, 0), 0, w, h)), (max(-shift, 0), 0))
	mp = strip.load()
	for y in range(195, h):
		for x in range(0, paste_max):
			r, g, b, a = mp[x, y]
			if a == 0:
				continue
			# hoà dần ở mép phải vùng dán để không lộ đường nối trên áo
			t = 1.0 if x < paste_max - 12 else (paste_max - x) / 12.0
			o = px[x, y]
			k = a / 255.0 * t
			px[x, y] = (int(r * k + o[0] * (1 - k)), int(g * k + o[1] * (1 - k)), int(b * k + o[2] * (1 - k)), max(o[3], int(a * t)))
	return im


def main() -> None:
	outs = []
	for base, (new, axis, cut_x, top_y, paste_max) in JOBS.items():
		for f in [CHARS / (base + ".png")]:
			out = CHARS / (new + ".png")
			convert(Image.open(f).convert("RGBA"), axis, cut_x, top_y, paste_max).save(out)
			outs.append(out)
			print(out.name)
	ims = [Image.open(o) for o in outs]
	sheet = Image.new("RGBA", (sum(i.width for i in ims), max(i.height for i in ims)), (190, 190, 190, 255))
	x = 0
	for i in ims:
		sheet.alpha_composite(i, (x, 0))
		x += i.width
	sheet.save(ROOT / "build/shots/stand_sheet.png")


if __name__ == "__main__":
	main()
