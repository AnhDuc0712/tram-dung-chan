# Cắt font chỉ giữ chữ Latin + tiếng Việt + dấu câu -> bản web tải nhẹ hơn (Baloo 2 gốc có cả chữ Devanagari).
#   tools\.venv-art\Scripts\python.exe -I tools\art\subset_fonts.py
# Font gốc tải lại từ Google Fonts nếu cần thêm ký tự (giấy phép SIL OFL cho phép cắt bớt).
# Test test_text_and_fonts.gd kiểm tra mọi chữ trong game vẫn có trong font sau khi cắt.
from pathlib import Path

from fontTools import subset

ROOT = Path(__file__).resolve().parents[2]
FONTS = ROOT / "game/assets/fonts"
UNICODES = (
	"U+0020-007E,U+00A0-00FF,U+0100-017F,U+0180-024F,U+0300-0323,U+0340-0341,"
	"U+1E00-1EFF,U+2000-206F,U+20AB,U+20AC,U+2122,U+2190-2193,U+2026,U+00B7,U+2713,U+FFFD"
)

for f in sorted(FONTS.glob("*.ttf")):
	before = f.stat().st_size
	opts = subset.Options()
	opts.layout_features = ["*"]  # giữ kerning, ghép dấu
	opts.name_IDs = ["*"]
	opts.notdef_outline = True
	opts.glyph_names = False
	font = subset.load_font(str(f), opts)
	sub = subset.Subsetter(opts)
	sub.populate(unicodes=subset.parse_unicodes(UNICODES))
	sub.subset(font)
	subset.save_font(font, str(f), opts)
	print(f"{f.name}: {before // 1024} KB -> {f.stat().st_size // 1024} KB")
