"""Xử lý ảnh thiết kế Tập 2 (và làm sạch ảnh nền Tập 1) cho game.

- Xoá dấu "ngôi sao" Gemini ở góc phải dưới (dò điểm sáng nổi hơn nền xung quanh rồi loang màu lấp lại).
- Event CG: cắt bỏ phụ đề in sẵn ở đáy ảnh (game tự hiện lời thoại trong khung chữ) -> assets/art/cg/<id>.jpg
- Nền mới -> assets/art/bg/<id>.jpg ; bản đồ đi lại -> assets/art/bg/map_<id>.jpg
- Cắt từ bảng thiết kế (nền kem): 3 nền nhỏ, 2 NPC học sinh, các ô biểu cảm (inset) của chị M / Trâm / Đức Anh / Hải.

Chạy:  tools\\.venv-art\\Scripts\\python.exe -I tools\\art\\process_ep2.py
Xem lại: build/shots/ep2_assets.png
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

sys.path.insert(0, str(Path(__file__).resolve().parent))
from cut_sprites import clean_alpha, flood_cut  # noqa: E402
from make_expressions import inpaint  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
ENV = ROOT / "thiết kế" / "env"
CGDIR = ROOT / "thiết kế" / "Event CG  Cutscene"
BG_OUT = ROOT / "game" / "assets" / "art" / "bg"
CG_OUT = ROOT / "game" / "assets" / "art" / "cg"
CH_OUT = ROOT / "game" / "assets" / "art" / "chars"
SHEET = ENV / "Gemini_Generated_Image_l0q5o1l0q5o1l0q5 (1).png"

# id -> (file, tỉ lệ chiều cao giữ lại (cắt phụ đề))
CGS = {
    "cg_claw": (CGDIR / "Gemini_Generated_Image_76yywl76yywl76yy.png", 0.885),
    "cg_hotpot": (CGDIR / "Gemini_Generated_Image_8htexq8htexq8hte.png", 0.885),
    "cg_jacket": (CGDIR / "Gemini_Generated_Image_9gl1vc9gl1vc9gl1.png", 0.885),
    "cg_library": (CGDIR / "Gemini_Generated_Image_fz0o7xfz0o7xfz0o.png", 0.885),
    "cg_headphones": (CGDIR / "Gemini_Generated_Image_v4r5uhv4r5uhv4r5.png", 0.885),
}
# id -> (file, khung cắt theo tỉ lệ (trái, trên, phải, dưới), kích thước xuất)
BGS = {
    "cafe_night": (ENV / "Gemini_Generated_Image_a2zvjaa2zvjaa2zv.png", (0, 0, 1, 1), (1920, 1080)),
    "arcade": (ENV / "Gemini_Generated_Image_f1uxwff1uxwff1ux.png", (0.04, 0, 0.96, 0.915), (1920, 1080)),
    "map_street": (ENV / "Gemini_Generated_Image_5y8ug35y8ug35y8u.png", (0, 0, 1, 1), (1280, 714)),
}
# cắt từ bảng thiết kế (toạ độ pixel ảnh gốc 2752x1536)
SHEET_BGS = {
    "campus": (52, 94, 918, 572),
    "library": (960, 94, 1816, 572),
    "hotpot": (1860, 94, 2700, 572),
}
SHEET_SPRITES = {  # tên -> (khung, chiều cao xuất)
    "npc_girl": ((2405, 712, 2556, 962), 300),
    "npc_boy": ((2556, 706, 2708, 962), 300),
    "m_x_smile": ((52, 722, 212, 958), 230),
    "m_x_laugh": ((212, 722, 380, 958), 230),
    "m_x_sweat": ((380, 722, 546, 958), 230),
    "tram_x_smile": ((552, 740, 700, 958), 230),
    "tram_x_angry": ((684, 728, 846, 958), 230),
    "tram_x_shock": ((846, 740, 1004, 958), 230),
    "ducanh_x_grin": ((1028, 722, 1222, 958), 230),
    "ducanh_x_confused": ((1222, 722, 1420, 958), 230),
    "hai_x_smile": ((1432, 732, 1594, 958), 230),
    "hai_x_blush": ((1594, 732, 1760, 958), 230),
}
OLD_BGS = ["cafe_day", "cafe_sunset", "street_rain", "cafe_map"]


def remove_sparkle(img: Image.Image) -> Image.Image:
    """Tìm ngôi sao sáng (dấu Gemini) ở góc phải dưới và lấp bằng màu xung quanh."""
    arr = np.asarray(img.convert("RGBA")).astype(np.float64)
    h, w = arr.shape[:2]
    rw, rh = int(w * 0.075), int(h * 0.12)
    y0, x0 = h - rh, w - rw
    reg = arr[y0:, x0:, :3]
    lum = reg @ np.array([0.299, 0.587, 0.114])
    local = ndimage.gaussian_filter(lum, sigma=max(8.0, rw / 3.0))
    sat = reg.max(2) - reg.min(2)
    mask = ((lum - local) > 18) & (sat < 60)
    lab, n = ndimage.label(mask)
    if n == 0:
        return img
    sizes = ndimage.sum(mask, lab, range(1, n + 1))
    best = int(np.argmax(sizes)) + 1
    if sizes[best - 1] < 20:
        return img
    m = ndimage.binary_fill_holes(lab == best)
    m = ndimage.binary_dilation(m, iterations=max(3, rw // 40))
    full = np.zeros((h, w), bool)
    full[y0:, x0:] = m
    inpaint(arr, full, -1.0)
    return Image.fromarray(arr.clip(0, 255).astype(np.uint8)).convert(img.mode)


def cover(img: Image.Image, size) -> Image.Image:
    tw, th = size
    s = max(tw / img.width, th / img.height)
    r = img.resize((round(img.width * s), round(img.height * s)), Image.LANCZOS)
    x = (r.width - tw) // 2
    y = (r.height - th) // 2
    return r.crop((x, y, x + tw, y + th))


def main() -> int:
    for d in (BG_OUT, CG_OUT, CH_OUT):
        d.mkdir(parents=True, exist_ok=True)
    made = []
    for cid, (f, keep) in CGS.items():
        im = remove_sparkle(Image.open(f).convert("RGB"))
        im = im.crop((0, 0, im.width, round(im.height * keep)))
        im = im.resize((1600, round(1600 * im.height / im.width)), Image.LANCZOS)
        im.save(CG_OUT / f"{cid}.jpg", quality=88, optimize=True)
        made.append((cid, im))
        print("cg", cid, im.size)
    for bid, (f, box, size) in BGS.items():
        im = remove_sparkle(Image.open(f).convert("RGB"))
        W, H = im.size
        im = im.crop((round(box[0] * W), round(box[1] * H), round(box[2] * W), round(box[3] * H)))
        im = cover(im, size)
        im.save(BG_OUT / f"{bid}.jpg", quality=88, optimize=True)
        made.append((bid, im))
        print("bg", bid, im.size)
    sheet = Image.open(SHEET).convert("RGBA")
    for bid, box in SHEET_BGS.items():
        im = sheet.crop(box).convert("RGB")
        im = cover(im, (1280, 720)).filter(ImageFilter.UnsharpMask(radius=1.4, percent=60, threshold=2))
        im.save(BG_OUT / f"{bid}.jpg", quality=90, optimize=True)
        made.append((bid, im))
        print("bg", bid, im.size)
    for name, (box, height) in SHEET_SPRITES.items():
        cut = flood_cut(sheet.crop(box))
        a = np.array(cut)
        a[:, :, 3] = clean_alpha(a[:, :, 3])
        img = Image.fromarray(a)
        bb = img.getbbox()
        if bb:
            img = img.crop(bb)
        img = img.resize((round(img.width * height / img.height), height), Image.LANCZOS)
        img.save(CH_OUT / f"{name}.png", optimize=True)
        made.append((name, img))
        print("sprite", name, img.size)
    for bid in OLD_BGS:  # làm sạch nền Tập 1
        p = BG_OUT / f"{bid}.jpg"
        im = remove_sparkle(Image.open(p).convert("RGB"))
        im.save(p, quality=90, optimize=True)
        made.append((bid, im))
        print("clean", bid)
    # bảng xem nhanh
    th = []
    for name, im in made:
        t = im.convert("RGBA").copy()
        t.thumbnail((420, 260))
        bg = Image.new("RGBA", (420, 270), (70, 70, 85, 255))
        bg.alpha_composite(t, ((420 - t.width) // 2, 0))
        th.append(bg)
    cols = 5
    out = Image.new("RGB", (cols * 424, ((len(th) + cols - 1) // cols) * 274), (40, 40, 50))
    for i, t in enumerate(th):
        out.paste(t.convert("RGB"), ((i % cols) * 424, (i // cols) * 274))
    shots = ROOT / "build" / "shots"
    shots.mkdir(parents=True, exist_ok=True)
    out.save(shots / "ep2_assets.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
