"""Xử lý ảnh thiết kế Tập 3 -> game/assets/art/{cg,bg}.

- Xoá dấu "ngôi sao" Gemini ở góc phải dưới (dùng lại remove_sparkle của process_ep2).
- Event CG -> assets/art/cg/<id>.jpg (rộng 1600). Bản đồ đi lại -> assets/art/bg/map_<id>.jpg (1280x714).

Chạy:  tools\\.venv-art\\Scripts\\python.exe -I tools\\art\\process_ep3.py
Xem lại: build/shots/ep3_assets.png
"""
import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
from process_ep2 import cover, remove_sparkle  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
ENV = ROOT / "thiết kế" / "env"
CGDIR = ROOT / "thiết kế" / "Event CG  Cutscene"
BG_OUT = ROOT / "game" / "assets" / "art" / "bg"
CG_OUT = ROOT / "game" / "assets" / "art" / "cg"

CGS = {
    "cg_burnt": CGDIR / "image18.png",  # sân trường: trả áo + bánh cháy
    "cg_asleep": CGDIR / "Gemini_Generated_Image_kwrecjkwrecjkwre.png",  # chiều tà: KyKy ngủ gục
    "cg_expo": CGDIR / "Gemini_Generated_Image_2j33ez2j33ez2j33.png",  # đêm triển lãm: Hải, Đức, KyKy
    "cg_sunrise": CGDIR / "Gemini_Generated_Image_oa8agzoa8agzoa8a.png",  # bình minh trước hiên Gờ 23
}
MAPS = {
    "map_campus": ENV / "Gemini_Generated_Image_4cv4mn4cv4mn4cv4.png",
}


def main() -> int:
    CG_OUT.mkdir(parents=True, exist_ok=True)
    BG_OUT.mkdir(parents=True, exist_ok=True)
    made = []
    for cid, f in CGS.items():
        im = remove_sparkle(Image.open(f).convert("RGB"))
        im = im.resize((1600, round(1600 * im.height / im.width)), Image.LANCZOS)
        im.save(CG_OUT / f"{cid}.jpg", quality=88, optimize=True)
        made.append(im)
        print("cg", cid, im.size)
    for bid, f in MAPS.items():
        im = remove_sparkle(Image.open(f).convert("RGB"))
        im = cover(im, (1280, 714))
        im.save(BG_OUT / f"{bid}.jpg", quality=88, optimize=True)
        made.append(im)
        print("map", bid, im.size)
    # bảng xem nhanh
    cols = 3
    th = []
    for im in made:
        t = im.copy()
        t.thumbnail((420, 260))
        th.append(t)
    out = Image.new("RGB", (cols * 424, ((len(th) + cols - 1) // cols) * 264), (40, 40, 50))
    for i, t in enumerate(th):
        out.paste(t, ((i % cols) * 424, (i // cols) * 264))
    shots = ROOT / "build" / "shots"
    shots.mkdir(parents=True, exist_ok=True)
    out.save(shots / "ep3_assets.png")
    return 0


if __name__ == "__main__":
    sys.exit(main())
