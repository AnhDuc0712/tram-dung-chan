"""Tách nền ảnh nhân vật -> PNG trong suốt (dùng rembg, mã nguồn mở).

Cách dùng (PowerShell, từ thư mục gốc C:\\devgame2D):
    tools\\.venv-art\\Scripts\\python.exe tools\\art\\remove_bg.py <file-hoặc-thư-mục> [--out THƯ_MỤC] [--height 600]

Ví dụ: tách nền cả thư mục biểu cảm của Linh, thu về cao 600px, lưu vào thư mục portraits của game:
    tools\\.venv-art\\Scripts\\python.exe tools\\art\\remove_bg.py raw\\linh --out game\\assets\\art\\portraits --height 600

Lần chạy đầu rembg sẽ tự tải model (~170MB).
"""
import argparse
import sys
from pathlib import Path

from PIL import Image
from rembg import new_session, remove

EXTS = {".png", ".jpg", ".jpeg", ".webp"}


def process(src: Path, out_dir: Path, height: int | None, session) -> Path:
    img = Image.open(src).convert("RGBA")
    cut = remove(img, session=session)
    bbox = cut.getbbox()  # cắt sát viền trong suốt
    if bbox:
        cut = cut.crop(bbox)
    if height and cut.height != height:
        w = round(cut.width * height / cut.height)
        cut = cut.resize((w, height), Image.LANCZOS)
    out = out_dir / (src.stem + ".png")
    cut.save(out)
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("input", type=Path)
    ap.add_argument("--out", type=Path, default=None, help="thư mục lưu (mặc định: <input>/nobg)")
    ap.add_argument("--height", type=int, default=None, help="thu/phóng về chiều cao (px)")
    ap.add_argument("--model", default="isnet-anime", help="isnet-anime (tranh anime) | u2net (ảnh thật)")
    a = ap.parse_args()

    files = [a.input] if a.input.is_file() else sorted(p for p in a.input.iterdir() if p.suffix.lower() in EXTS)
    if not files:
        print("Không tìm thấy ảnh.", file=sys.stderr)
        return 1
    out_dir = a.out or (a.input.parent if a.input.is_file() else a.input) / "nobg"
    out_dir.mkdir(parents=True, exist_ok=True)
    session = new_session(a.model)
    for f in files:
        print("->", process(f, out_dir, a.height, session))
    return 0


if __name__ == "__main__":
    sys.exit(main())
