# Nền quán buổi SÁNG (Tập 2) từ cafe_day.jpg (ánh hoàng hôn vàng cam): giảm cam, tăng sáng, ám xanh nhẹ.
#   tools\.venv-art\Scripts\python.exe -I tools\art\make_morning.py
from pathlib import Path

import numpy as np
from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
BG = ROOT / "game/assets/art/bg"

im = Image.open(BG / "cafe_day.jpg").convert("RGB")
a = np.asarray(im).astype(np.float32) / 255.0
lum = a @ np.array([0.299, 0.587, 0.114], dtype=np.float32)
# bớt bão hoà màu cam: kéo về độ sáng rồi cân lại kênh màu cho trung tính / hơi lạnh
a = lum[..., None] + (a - lum[..., None]) * 0.74
a[..., 0] *= 0.93
a[..., 1] *= 1.00
a[..., 2] *= 1.07
a = np.clip(a * 1.08 + 0.03, 0, 1) ** 0.92  # sáng hơn, nắng sớm trong trẻo
out = Image.fromarray((a * 255).astype(np.uint8))
out = ImageEnhance.Contrast(out).enhance(1.04)
out.save(BG / "cafe_morning.jpg", quality=88)
print("cafe_morning.jpg", out.size)
