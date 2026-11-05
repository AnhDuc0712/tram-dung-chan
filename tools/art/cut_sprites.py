"""Cắt nhân vật từ các bảng thiết kế (thiết kế/char/*) -> PNG nền trong suốt cho game.

Chạy (từ thư mục gốc):
    tools\\.venv-art\\Scripts\\python.exe -I tools\\art\\cut_sprites.py
Kết quả: game/assets/art/chars/<tên>.png  + build/shots/sprites_sheet.png (ảnh xem nhanh).

Muốn thêm/sửa tư thế: sửa bảng CROPS bên dưới (toạ độ pixel trên ảnh gốc: trái, trên, phải, dưới).
Sau khi rembg tách nền, script giữ lại mảng lớn nhất (bỏ đường kẻ thước đo, phác thảo đầu bên cạnh).
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from rembg import new_session, remove
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[2]
SRC = ROOT / "thiết kế" / "char"
OUT = ROOT / "game" / "assets" / "art" / "chars"

MAIN = "main9.png"
SHEET_M_TRAM = "1793851149959_2271762167589626936_265984426974105102_f58601405e6fbe5149176b26042c2f9d.jpg"
SHEET_CAT = "1793851157499_2271762167589626936_265984426974105102_b26e2aabee7aaa02bc32814735449b4c.jpg"
SHEET_FRIENDS = "1793851172261_2271762167589626936_265984426974105102_dd0b5a88df546e053edca2d1200c802d.jpg"

# Các vùng tô lại màu nền trước khi tách (che phần nhân vật khác lấn vào khung cắt), toạ độ ảnh gốc.
MASK_OUT = {
    "cat_walk": [(425, 195, 562, 233)],
}
# Dùng "flood" (loang màu nền từ mép) thay cho rembg: hợp với nền kem đồng màu, nét viền liền.
FLOOD = {"cat_big", "cat_sit", "cat_walk", "cat_loaf"}

# tên -> (file, (trái, trên, phải, dưới), chiều cao xuất ra)
CROPS = {
    "duc_front": (MAIN, (129, 100, 632, 1395), 620),
    "duc_walk": (MAIN, (676, 112, 1168, 1385), 620),
    "kyky_hug": (MAIN, (1576, 165, 2027, 1372), 580),
    "kyky_wave": (MAIN, (2020, 175, 2532, 1360), 580),
    "m_front": (SHEET_M_TRAM, (82, 40, 250, 562), 600),
    "m_walk": (SHEET_M_TRAM, (232, 48, 412, 548), 600),
    "tram_walk": (SHEET_M_TRAM, (590, 58, 760, 558), 580),
    "tram_front": (SHEET_M_TRAM, (770, 52, 982, 560), 580),
    "cat_big": (SHEET_CAT, (45, 78, 378, 538), 460),
    "cat_sit": (SHEET_CAT, (425, 68, 562, 238), 170),
    "cat_walk": (SHEET_CAT, (425, 195, 772, 388), 190),
    "cat_loaf": (SHEET_CAT, (425, 415, 600, 528), 110),
    "thao_front": (SHEET_FRIENDS, (82, 40, 242, 538), 600),
    "thao_walk": (SHEET_FRIENDS, (232, 48, 412, 542), 600),
    "ducanh_front": (SHEET_FRIENDS, (408, 58, 597, 566), 620),
    "ducanh_walk": (SHEET_FRIENDS, (575, 62, 767, 566), 620),
    "hai_front": (SHEET_FRIENDS, (772, 58, 987, 562), 620),
}


def clean_alpha(alpha: np.ndarray) -> np.ndarray:
    """Giữ mảng nhân vật lớn nhất; cắt đứt các nét mảnh (thước kẻ) dính vào."""
    solid = alpha > 128
    opened = ndimage.binary_opening(solid, structure=np.ones((7, 7)))
    lab, n = ndimage.label(opened)
    if n == 0:
        return alpha
    sizes = ndimage.sum(opened, lab, range(1, n + 1))
    keep = lab == (int(np.argmax(sizes)) + 1)
    keep = ndimage.binary_dilation(keep, iterations=6)
    return (alpha * keep).astype(np.uint8)


def flood_cut(crop: Image.Image, tol: float = 28.0) -> Image.Image:
    """Nền = vùng gần màu kem nối liền với mép ảnh."""
    arr = np.array(crop).astype(np.float32)
    rgb = arr[:, :, :3]
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    bg = np.median(border, axis=0)
    near = np.linalg.norm(rgb - bg, axis=2) < tol
    lab, _ = ndimage.label(near)
    edge_labels = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
    bgmask = ndimage.binary_dilation(np.isin(lab, list(edge_labels)), iterations=1)
    # viền mềm 1px
    alpha = (~bgmask).astype(np.float32)
    alpha = ndimage.uniform_filter(alpha, size=3)
    out = np.array(crop)
    out[:, :, 3] = (np.clip(alpha, 0, 1) * 255).astype(np.uint8)
    return Image.fromarray(out)


def main() -> int:
    OUT.mkdir(parents=True, exist_ok=True)
    session = new_session("isnet-anime")
    cache: dict[str, Image.Image] = {}
    results = []
    only = set(sys.argv[1:])
    for name, (fname, box, height) in CROPS.items():
        if only and name not in only:
            continue
        if fname not in cache:
            cache[fname] = Image.open(SRC / fname).convert("RGBA")
        src = cache[fname].copy()
        for r in MASK_OUT.get(name, []):
            sample = src.getpixel((r[2] + 3, r[1] + 3))
            src.paste(sample, r)
        crop = src.crop(box)
        cut = flood_cut(crop) if name in FLOOD else remove(crop, session=session)
        arr = np.array(cut)
        arr[:, :, 3] = clean_alpha(arr[:, :, 3])
        img = Image.fromarray(arr)
        bbox = img.getbbox()
        if bbox:
            img = img.crop(bbox)
        w = round(img.width * height / img.height)
        img = img.resize((w, height), Image.LANCZOS)
        img.save(OUT / f"{name}.png", optimize=True)
        results.append((name, img))
        print("->", name, img.size)

    # ảnh xem nhanh trên nền xám kẻ ô
    if results:
        pad = 10
        W = sum(i.width for _, i in results) + pad * (len(results) + 1)
        H = max(i.height for _, i in results) + pad * 2
        sheet = Image.new("RGBA", (W, H), (90, 90, 110, 255))
        x = pad
        for _, i in results:
            sheet.alpha_composite(i, (x, pad))
            x += i.width + pad
        shots = ROOT / "build" / "shots"
        shots.mkdir(parents=True, exist_ok=True)
        sheet.convert("RGB").save(shots / "sprites_sheet.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
