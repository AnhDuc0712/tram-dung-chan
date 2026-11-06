# Tạo ảnh chờ tải (boot splash) cho bản web từ nền màn hình chính: nhỏ (<150 KB) vì trình duyệt tải nó đầu tiên.
#   tools\.venv-art\Scripts\python.exe -I tools\art\make_splash.py
from pathlib import Path

from PIL import Image, ImageDraw, ImageEnhance, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
GAME = ROOT / "game"
OUT = GAME / "assets" / "art" / "ui" / "splash.png"

W, H = 960, 540
bg = Image.open(GAME / "assets/art/bg/street_rain.jpg").convert("RGB")
bg = bg.resize((W, H), Image.LANCZOS).filter(ImageFilter.GaussianBlur(3))
bg = ImageEnhance.Brightness(bg).enhance(0.45)
img = bg.convert("RGBA")
d = ImageDraw.Draw(img)
title = ImageFont.truetype(str(GAME / "assets/fonts/Baloo2.ttf"), 92)
sub = ImageFont.truetype(str(GAME / "assets/fonts/Nunito.ttf"), 28)


def centered(text, font, y, fill, stroke=0, stroke_fill=None):
	w = d.textlength(text, font=font)
	d.text(((W - w) / 2, y), text, font=font, fill=fill, stroke_width=stroke, stroke_fill=stroke_fill)


centered("Trạm Dừng Chân", title, 150, (255, 240, 232), 5, (196, 74, 110))
centered("Quán Gờ 23 · ghé lại một chút", sub, 290, (243, 223, 210))
OUT.parent.mkdir(parents=True, exist_ok=True)
img.convert("RGB").quantize(colors=96, method=Image.Quantize.MEDIANCUT).save(OUT, optimize=True)
print(OUT, OUT.stat().st_size // 1024, "KB")
