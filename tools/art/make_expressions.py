"""Tạo ảnh biểu cảm cho nhân vật TỪ SPRITE GỐC (game/assets/art/chars/<base>.png).

Cách làm (không cần AI vẽ ảnh): với mỗi sprite đã đo sẵn vị trí mắt / lông mày / miệng (bảng FACES),
  1. xoá phần mặt cần đổi bằng "loang màu da" (inpaint khuếch tán, bỏ qua nét đen như gọng kính, tóc),
  2. xoay / nhấc lông mày (cắt mảng ảnh thật rồi xoay — giữ nguyên nét vẽ gốc),
  3. vẽ lại mắt nhắm, mi sụp, mắt tròn hoảng, miệng cười/há/mếu, má hồng gạch chéo, nước mắt...
     (vẽ ở độ phân giải x4 rồi thu nhỏ cho mượt).
Kết quả: game/assets/art/chars/<base>_<biểu cảm>.png  +  build/shots/expressions_sheet.png để xem nhanh.

Chạy:  tools\\.venv-art\\Scripts\\python.exe -I tools\\art\\make_expressions.py [base ...]
Thêm biểu cảm: sửa PLAN (base -> danh sách) hoặc RECIPES. Đo toạ độ mới: build/expr/zoom.py (lưới 5px).
"""
import math
import os
import sys

import numpy as np
from scipy import ndimage
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CHARS = os.path.join(ROOT, "game", "assets", "art", "chars")
SHOTS = os.path.join(ROOT, "build", "shots")
SS = 4  # vẽ phóng to 4 lần rồi thu nhỏ

# eyes: (cx, cy, rộng, cao) từng mắt · mouth: (cx, cy, rộng) · merase: (rx, ry) vùng xoá miệng
# brows: khung lông mày (x0, y0, x1, y1) — [] = không đụng lông mày · nose: x sống mũi (để biết phía trong/ngoài)
# closed: mắt gốc đã nhắm sẵn (KyKy ôm sổ) · head: khung cắt cho bảng xem trước
FACES = {
	"duc_front": dict(eyes=[(106.5, 124, 34, 20), (173, 123, 33, 20)], mouth=(140, 154, 37), merase=(21, 4),
		brows=[(87, 98, 131, 112), (149, 97, 193, 111)], nose=140, head=(40, 20, 230, 190)),
	"duc_walk": dict(eyes=[(47, 121, 20, 22), (102, 120, 34, 22)], mouth=(74, 150, 29), merase=(17, 4),
		brows=[], nose=62, head=(10, 20, 190, 190)),
	"kyky_wave": dict(em=3, lenses=[(80.5, 111, 21.5, 21), (126, 111, 25, 21)], eyes=[(76, 108, 22, 24), (126, 108, 28, 24)], mouth=(97, 142, 25), merase=(15, 11),
		brows=[(59, 74, 85, 87), (107, 73, 139, 87)], nose=100, head=(30, 20, 200, 175)),
	"kyky_hug": dict(em=3, lenses=[(57, 122, 22, 22), (118, 122, 26, 26)], eyes=[(52, 118, 26, 13), (118, 118, 36, 13)], mouth=(86, 152, 32), merase=(20, 12),
		brows=[(48, 81, 72, 95), (102, 81, 129, 94)], nose=85, closed=True, head=(10, 25, 190, 180)),
	"m_front": dict(em=3.5, lenses=[(58, 126, 18, 19), (107, 124, 19, 19)], eyes=[(61, 123, 24, 17), (111, 122, 24, 17)], mouth=(83, 149, 25), merase=(14, 4),
		brows=[], nose=84, head=(20, 40, 170, 170)),
	"m_walk": dict(em=3, lenses=[(124, 124, 16, 18), (162, 125, 11, 15)], eyes=[(120, 121, 23, 17), (162, 123, 16, 15)], mouth=(141, 149, 20), merase=(12, 4),
		brows=[(117, 96, 143, 107), (155, 99, 177, 109)], nose=145, head=(70, 40, 210, 170)),
	"tram_front": dict(eyes=[(67, 96, 26, 17), (118, 95, 24, 17)], mouth=(90, 123, 23), merase=(14, 4),
		brows=[(49, 72, 81, 85), (98, 71, 133, 84)], nose=92, head=(25, 15, 175, 150)),
	"thao_front": dict(em=3.5, lenses=[(62, 137, 17, 17), (110, 135, 19, 19)], eyes=[(62, 132, 25, 16), (112, 131, 25, 17)], mouth=(88, 159, 28), merase=(16, 5),
		brows=[(49, 108, 76, 119), (95, 107, 125, 118)], nose=83, head=(25, 50, 160, 185)),
	"ducanh_front": dict(eyes=[(88, 106, 23, 13), (140, 102, 28, 13)], mouth=(118, 127, 33), merase=(19, 7),
		brows=[(70, 79, 102, 95), (117, 73, 153, 89)], nose=110, head=(45, 20, 190, 160)),
	"hai_front": dict(eyes=[(70, 106, 28, 18), (122, 104, 25, 17)], mouth=(100, 135, 32), merase=(18, 4),
		brows=[], nose=97, head=(30, 25, 175, 160)),
	"cat_big": dict(eyes=[(141, 107, 62, 45), (247, 99, 52, 42)], mouth=None, merase=None,
		brows=[], nose=205, head=(40, 20, 300, 260)),
}

# eyes: "closed_happy" (^^) | "closed_calm" (mắt cười hiền) | "closed_tight" (> <) | "closed_flat" (nhắm hờn)
#       | "wide" (tròn xoe, con ngươi nhỏ) | ("lid", độ sụp 0..1, nghiêng: +1 giận / -1 buồn / 0)
# brows: (kiểu, độ xoay, nhấc px) kiểu = angry | worried | raise | one (nhướn một bên)
# mouth: smile | grin | laugh | o | gasp | frown | wavy | wavy_open | flat | pout | smirk | cry
RECIPES = {
	"happy": dict(eyes="closed_happy", mouth="grin", blush=1),
	"laugh": dict(eyes="closed_tight", mouth="laugh", blush=1),
	"shock": dict(eyes="wide", mouth="gasp", brows=("raise", 0, -3)),
	"surprised": dict(mouth="o", brows=("raise", 0, -3)),
	"sad": dict(eyes=("lid", 0.36, -1), teary=True, mouth="frown", brows=("worried", 14, 0)),
	"cry": dict(eyes="closed_tight", tears=True, mouth="cry", brows=("worried", 16, 0), blush=1),
	"angry": dict(eyes=("lid", 0.40, 1), mouth="frown", brows=("angry", 16, 1)),
	"pout": dict(eyes=("lid", 0.30, 1), mouth="pout", brows=("angry", 12, 1), blush=1),
	"hmph": dict(eyes="closed_flat", mouth="pout", brows=("angry", 14, 1), blush=1),
	"shy": dict(eyes=("lid", 0.42, 0), mouth="wavy", brows=("worried", 10, 0), blush=2),
	"worried": dict(mouth="wavy", brows=("worried", 14, 0)),
	"smug": dict(eyes=("lid", 0.45, 0), mouth="smirk", brows=("one", 8, -1)),
	"think": dict(eyes=("lid", 0.22, 0), mouth="flat", brows=("one", 10, -1)),
	"love": dict(eyes="closed_calm", mouth="smile", blush=2),
	"panic": dict(eyes="wide", mouth="wavy_open", brows=("worried", 16, -1), sweat=True),
	"tired": dict(eyes=("lid", 0.52, -1), mouth="flat", brows=("worried", 8, 1)),
	"glare": dict(eyes=("lid", 0.48, 1), mouth="flat", brows=("angry", 10, 1)),
	"sleep": dict(eyes="closed_calm"),
	"purr": dict(eyes="closed_calm", blush=1),
	"flustered": dict(mouth="wavy", blush=2, sweat=True),
}

PLAN = {
	"duc_front": ["happy", "laugh", "shock", "surprised", "sad", "angry", "shy", "worried", "love", "think", "panic"],
	"duc_walk": ["smug", "flustered", "worried", "think", "surprised", "glare"],
	"kyky_wave": ["shock", "panic", "worried", "sad", "angry", "surprised", "think", "smug", "pout"],
	"kyky_hug": ["hmph", "cry", "shy", "love", "laugh"],
	"m_front": ["smug", "shock", "love", "laugh", "worried", "glare"],
	"m_walk": ["worried", "surprised", "smug"],
	"tram_front": ["smug", "glare", "shock", "happy", "think", "pout"],
	"thao_front": ["happy", "shock", "worried", "smug"],
	"ducanh_front": ["happy", "shock", "tired", "laugh", "worried"],
	"hai_front": ["shy", "happy", "shock", "worried"],
	"cat_big": ["purr", "glare", "sleep"],
}

MOUTH_DARK = (112, 32, 44, 255)
TONGUE = (232, 112, 122, 255)
TEETH = (255, 253, 250, 255)
TEAR = (160, 216, 255, 185)
BLUSH = (246, 118, 140)


def lum(a):
	return a[..., 0] * 0.299 + a[..., 1] * 0.587 + a[..., 2] * 0.114


def dilate(m, n=1):
	out = m.copy()
	for _ in range(n):
		o = out.copy()
		o[1:] |= out[:-1]
		o[:-1] |= out[1:]
		o[:, 1:] |= out[:, :-1]
		o[:, :-1] |= out[:, 1:]
		out = o
	return out


def inpaint(arr, mask, dark_thr):
	"""Lấp vùng mask bằng màu xung quanh (Laplace). Điểm tối không nằm trong mask (gọng kính, tóc, viền)
	không được dùng làm nguồn màu, để vùng lấp không bị xám đen."""
	if not mask.any():
		return
	H, W = mask.shape
	ys, xs = np.nonzero(mask)
	y0, y1 = max(ys.min() - 2, 0), min(ys.max() + 3, H)
	x0, x1 = max(xs.min() - 2, 0), min(xs.max() + 3, W)
	sub = arr[y0:y1, x0:x1, :3].copy()
	m = mask[y0:y1, x0:x1]
	alpha = arr[y0:y1, x0:x1, 3]
	valid = ((lum(sub) > dark_thr) & (alpha > 200)) | m
	vf = valid.astype(np.float64)
	ring = dilate(m) & ~m & valid
	seed = sub[ring].mean(0) if ring.any() else sub[~m].mean(0)
	sub[m] = seed
	n = int(np.clip(max(y1 - y0, x1 - x0) ** 2 * 1.3, 300, 4000))
	shifts = ((1, 0), (-1, 0), (0, 1), (0, -1))
	vs = [np.roll(vf, s, (0, 1)) for s in shifts]
	cnt = np.maximum(sum(vs), 1e-6)[..., None]
	for _ in range(n):
		acc = sum(np.roll(sub, s, (0, 1)) * v[..., None] for s, v in zip(shifts, vs))
		sub[m] = (acc / cnt)[m]
	arr[y0:y1, x0:x1, :3] = sub
	arr[y0:y1, x0:x1, 3] = np.where(m, 255, alpha)


def quad(p0, c, p1, n=24):
	pts = []
	for i in range(n + 1):
		t = i / n
		a = (1 - t) ** 2
		b = 2 * (1 - t) * t
		d = t * t
		pts.append((a * p0[0] + b * c[0] + d * p1[0], a * p0[1] + b * c[1] + d * p1[1]))
	return pts


class Face:
	def __init__(self, base, spec):
		self.base = base
		self.spec = spec
		self.img = Image.open(os.path.join(CHARS, base + ".png")).convert("RGBA")
		self.arr = np.asarray(self.img).astype(np.float64)
		self.W, self.H = self.img.size
		self.ov = Image.new("RGBA", (self.W * SS, self.H * SS), (0, 0, 0, 0))
		self.d = ImageDraw.Draw(self.ov)
		self.glow = Image.new("RGBA", (self.W * SS, self.H * SS), (0, 0, 0, 0))  # lớp mờ (má hồng)
		self.gd = ImageDraw.Draw(self.glow)
		self._sample_colors()

	# ---------- màu ----------
	def _box(self, x0, y0, x1, y1):
		a = self.arr[int(y0):int(y1), int(x0):int(x1)]
		return a[a[..., 3] > 200][:, :3]

	def _sample_colors(self):
		ex, ey, ew, eh = self.spec["eyes"][0]
		px = self._box(ex - ew * 0.4, ey + eh * 0.75, ex + ew * 0.4, ey + eh * 1.3)
		self.skin = tuple(int(v) for v in np.median(px, 0)) if len(px) else (245, 205, 185)
		self.skin_lum = 0.299 * self.skin[0] + 0.587 * self.skin[1] + 0.114 * self.skin[2]
		eye = self._box(ex - ew / 2, ey - eh / 2, ex + ew / 2, ey + eh / 2)
		l = eye @ np.array([0.299, 0.587, 0.114])
		dark = eye[l <= np.percentile(l, 12)]
		c = np.median(dark, 0) * 0.85
		self.line = (int(c[0]), int(c[1]), int(c[2]), 255)
		mid = eye[(l > np.percentile(l, 25)) & (l < np.percentile(l, 55))]
		ci = np.median(mid, 0)
		self.iris = (int(ci[0]), int(ci[1]), int(ci[2]), 255)

	# ---------- vẽ cơ bản (toạ độ sprite) ----------
	def stroke(self, pts, w, color, taper="both", w_end=None, layer=None):
		d = layer or self.d
		dense = []
		for (x0, y0), (x1, y1) in zip(pts, pts[1:]):
			seg = max(1, int(math.hypot(x1 - x0, y1 - y0) * SS * 1.5))
			for i in range(seg):
				t = i / seg
				dense.append((x0 + (x1 - x0) * t, y0 + (y1 - y0) * t))
		dense.append(pts[-1])
		n = len(dense)
		for i, (x, y) in enumerate(dense):
			t = i / max(1, n - 1)
			if taper == "both":
				k = 0.35 + 0.65 * math.sin(math.pi * t) ** 0.6
			elif taper == "end":
				k = 1.0 - 0.7 * t ** 1.5
			elif taper == "start":
				k = 0.3 + 0.7 * t ** 0.7
			else:
				k = 1.0
			ww = w if w_end is None else w + (w_end - w) * t
			r = max(0.45, ww * k / 2) * SS
			d.ellipse((x * SS - r, y * SS - r, x * SS + r, y * SS + r), fill=color)

	def poly(self, pts, fill, layer=None):
		(layer or self.d).polygon([(x * SS, y * SS) for x, y in pts], fill=fill)

	def ellipse(self, cx, cy, rx, ry, fill=None, outline=None, width=0.0, layer=None):
		(layer or self.d).ellipse(((cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS),
			fill=fill, outline=outline, width=int(round(width * SS)))

	def clipped(self, shape_pts, draw_fn):
		"""Vẽ draw_fn lên lớp riêng rồi chỉ giữ phần nằm trong đa giác shape_pts."""
		lay = Image.new("RGBA", self.ov.size, (0, 0, 0, 0))
		draw_fn(ImageDraw.Draw(lay))
		mask = Image.new("L", self.ov.size, 0)
		ImageDraw.Draw(mask).polygon([(x * SS, y * SS) for x, y in shape_pts], fill=255)
		lay.putalpha(Image.fromarray(np.minimum(np.asarray(lay.getchannel("A")), np.asarray(mask))))
		self.ov.alpha_composite(lay)

	# ---------- xoá ----------
	def erase_ellipse(self, cx, cy, rx, ry, cut=None, thr=0.62):
		yy, xx = np.mgrid[0:self.H, 0:self.W]
		r2 = ((xx - cx) / rx) ** 2 + ((yy - cy) / ry) ** 2
		m = r2 <= 1.0
		if cut is not None:
			m &= yy < cut(xx)
		dark = lum(self.arr) < self.skin_lum * 0.5
		if self.spec.get("lenses"):
			# Giữ gọng kính: điểm tối nằm trên vành tròn của tròng kính.
			for (lx, ly, lrx, lry) in self.spec["lenses"]:
				dn = np.sqrt(((xx - lx) / lrx) ** 2 + ((yy - ly) / lry) ** 2)
				m &= ~(dark & (np.abs(dn - 1.0) < 3.2 / min(lrx, lry)))
		else:
			# Giữ nét tối chạy ra xa ngoài vùng xoá (lọn tóc) — chỉ xoá nét của chính con mắt.
			dk = dark & (r2 < 2.6 ** 2)
			lab, _ = ndimage.label(dk)
			keep = np.unique(lab[(r2 > 1.6 ** 2) & dk])
			keep = keep[keep > 0]
			if len(keep):
				m &= ~np.isin(lab, keep)
		inpaint(self.arr, m, self.skin_lum * thr)

	def inner_dir(self, ex):
		return 1.0 if ex < self.spec["nose"] else -1.0

	# ---------- lông mày ----------
	def _find_brow(self, box):
		"""Tìm nét lông mày (mảng tối nằm gọn trong khung, không dính vào khối tóc). None nếu dính tóc."""
		x0, y0, x1, y1 = box
		pad = 10
		X0, Y0 = max(int(x0 - pad), 0), max(int(y0 - pad), 0)
		X1, Y1 = min(int(x1 + pad), self.W), min(int(y1 + pad), self.H)
		sub = self.arr[Y0:Y1, X0:X1]
		dark = (lum(sub) < self.skin_lum * 0.72) & (sub[..., 3] > 200)
		lab, n = ndimage.label(dark)
		best = None
		for i in range(1, n + 1):
			ys, xs = np.nonzero(lab == i)
			if len(xs) < 12:
				continue
			if xs.min() + X0 < x0 - 2 or xs.max() + X0 > x1 + 2 or ys.min() + Y0 < y0 - 2 or ys.max() + Y0 > y1 + 2:
				continue
			if best is None or len(xs) > best[0]:
				best = (len(xs), ys + Y0, xs + X0)
		return best or self._brow_runs(box)

	def _brow_runs(self, box):
		"""Lông mày dính tóc: mỗi cột lấy đoạn tối thấp nhất trong khung (lông mày nằm dưới tóc),
		đoạn nào chạm mép trên (dính tóc) thì cắt bớt theo độ dày trung bình."""
		x0, y0, x1, y1 = (int(round(v)) for v in box)
		dark = lum(self.arr) < self.skin_lum * 0.72
		runs = {}
		for x in range(x0, x1 + 1):
			col = dark[y0:y1 + 1, x]
			idx = np.nonzero(col)[0]
			if not len(idx):
				continue
			b = idx.max()
			t = b
			while t > 0 and col[t - 1]:
				t -= 1
			runs[x] = (t + y0, b + y0, t == 0)
		if len(runs) < 6:
			return None
		free = [b - t + 1 for t, b, capped in runs.values() if not capped]
		med = float(np.median(free)) if free else 4.0
		bots = np.array([b for _, b, _ in runs.values()])
		bm = np.median(bots)
		ys, xs = [], []
		for x, (t, b, capped) in runs.items():
			if abs(b - bm) > max(2.5, med * 0.9) or (b >= y1 - 1 and b - bm > 1.5):
				continue
			if capped or b - t + 1 > med * 1.6:
				t = int(b - round(med) + 1)
			for y in range(t, b + 1):
				ys.append(y)
				xs.append(x)
		if len(xs) < 12:
			return None
		return (len(xs), np.array(ys), np.array(xs))

	def brows(self, kind, deg, dy):
		boxes = self.spec["brows"]
		found = [self._find_brow(b) for b in boxes]
		if any(f is None for f in found):
			print("     (bo qua long may: dinh toc)", self.base)
			return
		widths = [b[2] - b[0] for b in boxes]
		for i, (box, (_, ys, xs)) in enumerate(zip(boxes, found)):
			cx = xs.mean()
			cy = ys.mean()
			side = self.inner_dir(cx)  # +1: lông mày bên trái mặt (đầu trong ở bên phải)
			ang, ddy = 0.0, dy
			if kind == "angry":
				ang = -side * deg
			elif kind == "worried":
				ang = side * deg
				ddy = dy - 1
			elif kind == "one":
				if i != int(np.argmax(widths)):
					continue
				ang = -side * deg * 0.4
				ddy = dy - 2.5
			# đường giữa (làm mượt bằng parabol, bỏ điểm lệch do tóc) + độ dày
			cx_, cy_, thick = [], [], []
			for x in range(xs.min(), xs.max() + 1):
				col = ys[xs == x]
				if len(col):
					cx_.append(x + 0.5)
					cy_.append(col.mean() + 0.5)
					thick.append(len(col))
			cx_, cy_ = np.array(cx_), np.array(cy_)
			co = np.polyfit(cx_, cy_, 2)
			ok = np.abs(np.polyval(co, cx_) - cy_) < 1.5
			if ok.sum() > 6:
				co = np.polyfit(cx_[ok], cy_[ok], 2)
			w = float(np.median(thick))
			gx = np.linspace(cx_.min() + 0.5, cx_.max() - 0.5, 14)
			pts = [(float(x), float(np.polyval(co, x))) for x in gx]
			col = self.arr[ys, xs, :3]
			l = lum(col)
			c = np.median(col[l <= np.median(l)], 0)
			color = (int(c[0]), int(c[1]), int(c[2]), 255)
			mask = np.zeros((self.H, self.W), bool)
			mask[ys, xs] = True
			inpaint(self.arr, dilate(mask, 1), self.skin_lum * 0.72)
			th = math.radians(ang)
			np_ = []
			for x, y in pts:
				dx, dyy = x - cx, y - cy
				np_.append((cx + dx * math.cos(th) + dyy * math.sin(th), cy - dx * math.sin(th) + dyy * math.cos(th) + ddy))
			if side < 0:
				np_.reverse()
			np_.reverse()  # vẽ từ đầu trong (dày) ra đuôi (mảnh)
			self.stroke(np_, w * 1.1, color, taper="end")

	# ---------- mắt ----------
	def eyes(self, kind):
		for (ex, ey, ew, eh) in self.spec["eyes"]:
			inner = self.inner_dir(ex)
			lw = max(1.8, min(ew, eh) * 0.15)
			if isinstance(kind, tuple):  # mi mắt sụp
				_, frac, slant = kind
				top = ey - eh / 2 + frac * eh
				hw = ew / 2

				def lid(x, top=top, ex=ex, hw=hw, inner=inner, slant=slant, eh=eh):
					t = np.clip((x - ex) / hw, -1.2, 1.2) * inner  # +1 = phía trong (gần mũi)
					return top + slant * t * eh * 0.22 - (1 - np.minimum(t * t, 1)) * eh * 0.06
				em = self.spec.get("em", 4.0)
				self.erase_ellipse(ex, ey - 1.5, hw + em, eh / 2 + em, cut=lid, thr=0.88)
				xs = np.linspace(ex - hw * 1.02, ex + hw * 1.02, 16)
				pts = [(float(x), float(lid(x)) + lw * 0.3) for x in xs]
				if inner < 0:
					pts.reverse()  # vẽ từ phía trong ra ngoài: nét dày dần về đuôi mắt
				self.stroke(pts, lw * 0.55, self.line, taper="none", w_end=lw * 1.35)
				ox, oy = pts[-1]
				if not self.spec.get("lenses"):
					self.stroke([(ox, oy), (ox - inner * ew * 0.10, oy - eh * 0.10)], lw * 0.9, self.line, taper="end")
				continue
			if not self.spec.get("closed") or kind in ("closed_tight", "closed_flat", "wide"):
				em = self.spec.get("em", 4.0)
				self.erase_ellipse(ex, ey - 1, ew / 2 + em, eh / 2 + em * 0.9, thr=0.88)
			L = (ex - ew / 2, ey)
			R = (ex + ew / 2, ey)
			if kind == "closed_happy":
				self.stroke(quad((L[0], ey + eh * 0.2), (ex, ey - eh * 0.55), (R[0], ey + eh * 0.2)), lw * 1.2, self.line)
			elif kind == "closed_calm":
				pts = quad((L[0], ey - eh * 0.02), (ex, ey + eh * 0.42), (R[0], ey - eh * 0.02))
				if inner < 0:
					pts.reverse()
				self.stroke(pts, lw * 1.25, self.line, taper="start")
				ox, oy = pts[-1]
				self.stroke([(ox, oy), (ox - inner * ew * 0.12, oy + eh * 0.12)], lw * 0.8, self.line, taper="end")
			elif kind == "closed_flat":
				pts = quad((L[0], ey + eh * 0.05), (ex, ey + eh * 0.18), (R[0], ey + eh * 0.05))
				self.stroke(pts, lw * 1.2, self.line)
			elif kind == "closed_tight":  # > <  (mũi nhọn chỉ vào sống mũi)
				tip = (ex + inner * ew * 0.32, ey)
				back = ex - inner * ew * 0.45
				self.stroke([(back, ey - eh * 0.38), tip, (back, ey + eh * 0.34)], lw * 1.15, self.line, taper="none")
			elif kind == "wide":
				rx, ry = ew * 0.40, eh * 0.56
				self.ellipse(ex, ey, rx, ry, fill=(255, 255, 255, 255))
				self.ellipse(ex, ey, rx, ry, outline=self.line, width=max(1.0, lw * 0.6))
				self.stroke(quad((ex - rx * 1.05, ey - ry * 0.35), (ex, ey - ry * 1.45), (ex + rx * 1.05, ey - ry * 0.35)), lw * 1.1, self.line)
				pr = max(1.6, min(ew, eh) * 0.15)
				self.ellipse(ex, ey + ry * 0.05, pr, pr * 1.15, fill=self.iris)
				self.ellipse(ex, ey + ry * 0.05, pr * 0.55, pr * 0.6, fill=(25, 15, 15, 255))
				self.ellipse(ex - pr * 0.35, ey - pr * 0.25, pr * 0.3, pr * 0.3, fill=(255, 255, 255, 255))

	def teary(self):
		for (ex, ey, ew, eh) in self.spec["eyes"]:
			lw = max(1.4, min(ew, eh) * 0.13)
			self.stroke(quad((ex - ew * 0.38, ey + eh * 0.28), (ex, ey + eh * 0.52), (ex + ew * 0.38, ey + eh * 0.28)), lw, TEAR)
			self.ellipse(ex + ew * 0.18, ey + eh * 0.05, lw * 0.75, lw * 0.75, fill=(255, 255, 255, 235))
			self.ellipse(ex - ew * 0.12, ey + eh * 0.25, lw * 0.45, lw * 0.45, fill=(255, 255, 255, 220))

	def tears(self):
		for (ex, ey, ew, eh) in self.spec["eyes"]:
			outer = -self.inner_dir(ex)
			x0 = ex + outer * ew * 0.30
			y0 = ey + eh * 0.35
			L = eh * 1.25 + 4
			w = max(2.2, ew * 0.13)
			pts = [(x0 + outer * math.sin(t * 2.2) * 1.2, y0 + t * L) for t in np.linspace(0, 1, 12)]
			self.stroke(pts, w, TEAR, taper="end")
			self.stroke([(x - outer * w * 0.18, y) for x, y in pts[1:7]], w * 0.3, (255, 255, 255, 200), taper="both")
			self.ellipse(x0 + outer * w * 0.2, y0 + L + 2.5, w * 0.45, w * 0.6, fill=TEAR)

	def blush(self, level):
		hatch = (226, 86, 108, 210)
		for (ex, ey, ew, eh) in self.spec["eyes"]:
			outer = -self.inner_dir(ex)
			cx = ex + outer * ew * 0.08
			cy = ey + eh * 0.9 + 2
			rx, ry = ew * (0.42 + 0.1 * level), eh * (0.28 + 0.06 * level) + 1.5
			self.ellipse(cx, cy, rx, ry, fill=BLUSH + (95 + 45 * level,), layer=self.gd)
			n = 2 + level
			for i in range(n):
				x = cx - rx * 0.55 + i * rx * 1.1 / max(1, n - 1)
				self.stroke([(x + ry * 0.35, cy - ry * 0.45), (x - ry * 0.35, cy + ry * 0.45)], max(1.0, ew * 0.05), hatch)

	def sweat(self):
		ex, ey, ew, eh = max(self.spec["eyes"], key=lambda e: e[0])
		x, y = ex + ew * 0.62, ey - eh * 0.9
		s = max(3.0, ew * 0.16)
		self.poly([(x, y - s * 1.6), (x + s * 0.8, y), (x, y + s * 0.8), (x - s * 0.8, y)], fill=(170, 220, 255, 235))
		self.ellipse(x, y, s * 0.8, s * 0.8, fill=(170, 220, 255, 235))
		self.ellipse(x - s * 0.25, y - s * 0.1, s * 0.22, s * 0.3, fill=(255, 255, 255, 230))

	# ---------- miệng ----------
	def mouth(self, kind):
		if not self.spec.get("mouth"):
			return
		cx, cy, mw = self.spec["mouth"]
		rx, ry = self.spec["merase"]
		self.erase_ellipse(cx, cy, rx + 2, ry + 2)
		lw = max(1.4, mw * 0.055)
		line = self.line
		if kind == "smile":
			self.stroke(quad((cx - mw * 0.42, cy - 1), (cx, cy + mw * 0.24), (cx + mw * 0.42, cy - 1)), lw, line)
		elif kind == "flat":
			self.stroke([(cx - mw * 0.2, cy + 0.5), (cx + mw * 0.2, cy + 0.3)], lw, line)
		elif kind == "frown":
			self.stroke(quad((cx - mw * 0.3, cy + 2), (cx, cy - mw * 0.2), (cx + mw * 0.3, cy + 2)), lw, line)
		elif kind == "pout":
			self.stroke(quad((cx - mw * 0.17, cy + 1.2), (cx - mw * 0.02, cy - mw * 0.12), (cx + mw * 0.15, cy + 1.0)), lw * 1.15, line)
			self.stroke([(cx + mw * 0.15, cy + 1.0), (cx + mw * 0.2, cy + 0.2)], lw * 0.8, line, taper="end")
		elif kind == "smirk":
			self.stroke(quad((cx - mw * 0.32, cy + 0.5), (cx + mw * 0.02, cy + mw * 0.14), (cx + mw * 0.4, cy - mw * 0.14)), lw, line)
		elif kind in ("wavy", "wavy_open"):
			amp = 1.3 if kind == "wavy" else 1.2
			hw = mw * (0.3 if kind == "wavy" else 0.36)
			pts = [(cx - hw + 2 * hw * t, cy + math.sin(t * math.pi * 3) * amp) for t in np.linspace(0, 1, 30)]
			if kind == "wavy_open":
				bot = [(x, y + mw * 0.16 + math.sin(i / 29 * math.pi) * mw * 0.06) for i, (x, y) in enumerate(pts)]
				shape = pts + bot[::-1]
				self.poly(shape, MOUTH_DARK)
				self.stroke(shape + [shape[0]], lw * 0.8, line, taper="none")
			else:
				self.stroke(pts, lw, line)
		elif kind in ("grin", "laugh"):
			w = mw * (0.48 if kind == "grin" else 0.56)
			dep = mw * (0.42 if kind == "grin" else 0.62)
			top = quad((cx - w, cy - 1.5), (cx, cy + dep * 0.12), (cx + w, cy - 1.5))
			bot = quad((cx + w, cy - 1.5), (cx, cy + dep * 1.55), (cx - w, cy - 1.5))
			self._open_mouth(top + bot[1:], cx, cy - 1.5, w, dep, teeth=True)
		elif kind in ("o", "gasp"):
			erx, ery = (mw * 0.15, mw * 0.19) if kind == "o" else (mw * 0.24, mw * 0.34)
			c = (cx, cy + ery * 0.6)
			shape = [(c[0] + erx * math.cos(a), c[1] + ery * math.sin(a)) for a in np.linspace(0, 2 * math.pi, 40)]
			self._open_mouth(shape, c[0], c[1] - ery, erx, ery * 2, teeth=False)
		elif kind == "cry":
			w = mw * 0.46
			dep = mw * 0.5
			top = quad((cx - w, cy + dep * 0.35), (cx, cy - dep * 0.55), (cx + w, cy + dep * 0.35))
			bot = quad((cx + w, cy + dep * 0.35), (cx, cy + dep * 1.45), (cx - w, cy + dep * 0.35))
			self._open_mouth(top + bot[1:], cx, cy, w, dep, teeth=False)

	def _open_mouth(self, shape, cx, top_y, w, dep, teeth):
		self.poly(shape, MOUTH_DARK)

		def tongue(d):
			d.ellipse(((cx - w * 0.62) * SS, (top_y + dep * 0.72) * SS, (cx + w * 0.62) * SS, (top_y + dep * 1.9) * SS), fill=TONGUE)
			if teeth:
				d.rectangle(((cx - w * 1.2) * SS, (top_y - 3) * SS, (cx + w * 1.2) * SS, (top_y + dep * 0.24) * SS), fill=TEETH)
		self.clipped(shape, tongue)
		self.stroke(shape + [shape[0]], max(1.1, w * 0.09), self.line, taper="none")

	# ---------- ghép ----------
	def render(self, recipe):
		r = RECIPES[recipe]
		if r.get("brows") and self.spec["brows"]:
			self.brows(*r["brows"])
		if r.get("eyes"):
			self.eyes(r["eyes"])
		if r.get("mouth"):
			self.mouth(r["mouth"])
		if r.get("blush"):
			self.blush(r["blush"])
		if r.get("teary"):
			self.teary()
		if r.get("tears"):
			self.tears()
		if r.get("sweat"):
			self.sweat()
		out = Image.fromarray(self.arr.clip(0, 255).astype(np.uint8))
		glow = self.glow.filter(ImageFilter.GaussianBlur(2.2 * SS)).resize(out.size, Image.LANCZOS)
		a = np.asarray(out).copy()
		g = np.asarray(glow).astype(np.float64)
		ga = g[..., 3:4] / 255.0 * (a[..., 3:4] > 0)
		a[..., :3] = (a[..., :3] * (1 - ga) + g[..., :3] * ga).astype(np.uint8)
		out = Image.fromarray(a)
		ov = self.ov.resize(out.size, Image.LANCZOS)
		oa = np.asarray(ov).copy()
		oa[..., 3] = np.minimum(oa[..., 3], np.asarray(out)[..., 3])  # không vẽ ra ngoài thân
		out.alpha_composite(Image.fromarray(oa))
		return out


def sheet(results):
	try:
		font = ImageFont.truetype(os.path.join(ROOT, "game", "assets", "fonts", "Nunito.ttf"), 15)
	except OSError:
		font = ImageFont.load_default()
	S = 2
	rows = []
	for base, items in results:
		x0, y0, x1, y1 = FACES[base]["head"]
		tiles = [("goc", Image.open(os.path.join(CHARS, base + ".png")).convert("RGBA"))] + items
		row = []
		for label, im in tiles:
			c = im.crop((x0, y0, x1, y1))
			bg = Image.new("RGBA", c.size, (236, 226, 214, 255))
			bg.alpha_composite(c)
			bg = bg.resize((c.width * S, c.height * S), Image.LANCZOS).convert("RGB")
			cell = Image.new("RGB", (bg.width, bg.height + 20), (255, 255, 255))
			cell.paste(bg, (0, 20))
			ImageDraw.Draw(cell).text((4, 2), f"{base}:{label}" if label == "goc" else label, fill=(60, 30, 30), font=font)
			row.append(cell)
		rows.append(row)
	W = max(sum(c.width + 4 for c in r) for r in rows)
	H = sum(max(c.height for c in r) + 4 for r in rows)
	out = Image.new("RGB", (W, H), (120, 120, 120))
	y = 0
	for r in rows:
		x = 0
		for c in r:
			out.paste(c, (x, y))
			x += c.width + 4
		y += max(c.height for c in r) + 4
	os.makedirs(SHOTS, exist_ok=True)
	path = os.path.join(SHOTS, "expressions_sheet.png")
	out.save(path)
	return path


def main(argv):
	bases = argv or list(PLAN)
	results = []
	for base in bases:
		items = []
		for rec in PLAN[base]:
			im = Face(base, FACES[base]).render(rec)
			im.save(os.path.join(CHARS, f"{base}_{rec}.png"), optimize=True)
			items.append((rec, im))
			print("  ", f"{base}_{rec}.png")
		results.append((base, items))
	print("sheet:", sheet(results))


if __name__ == "__main__":
	main(sys.argv[1:])
