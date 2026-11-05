"""Tải RIÊNG export template cần dùng (web ~20 MB, windows ~90 MB) thay vì cả gói 1.3 GB.

Gói .tpz là file zip -> đọc mục lục ở cuối file rồi chỉ tải phần của các file web_*.zip
bằng HTTP Range (GitHub cho phép tải từng khoảng byte).

Chạy:  python tools/get_templates.py 4.7.2 <thư_mục_đích> [web] [windows]   (mặc định: web)
  Windows: %APPDATA%/Godot/export_templates/4.7.2.stable
  Linux (CI): ~/.local/share/godot/export_templates/4.7.2.stable
"""
import io
import os
import sys
import urllib.request
import zipfile

FILES = {
    "web": ("web_nothreads_release.zip", "web_nothreads_debug.zip"),
    "windows": ("windows_release_x86_64.exe", "windows_release_x86_64_console.exe"),
}


class HttpRangeFile(io.RawIOBase):
    """File chỉ-đọc, tua được (seek), mỗi lần read() tải đúng khoảng byte cần."""

    def __init__(self, url):
        self.url = url
        self.pos = 0
        self.size = int(self._get(0, 0)[1].split("/")[-1])

    def _get(self, start, end):
        req = urllib.request.Request(self.url, headers={"Range": "bytes=%d-%d" % (start, end), "User-Agent": "godot-template-fetch"})
        with urllib.request.urlopen(req) as r:
            return r.read(), r.headers.get("Content-Range", "")

    def seekable(self):
        return True

    def readable(self):
        return True

    def tell(self):
        return self.pos

    def seek(self, off, whence=0):
        self.pos = off if whence == 0 else (self.pos + off if whence == 1 else self.size + off)
        return self.pos

    def read(self, n=-1):
        if n is None or n < 0:
            n = self.size - self.pos
        if n == 0 or self.pos >= self.size:
            return b""
        end = min(self.pos + n, self.size) - 1
        data = self._get(self.pos, end)[0]
        self.pos += len(data)
        return data

    def readinto(self, b):
        d = self.read(len(b))
        b[:len(d)] = d
        return len(d)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    ver = sys.argv[1] if len(sys.argv) > 1 else "4.7.2"
    dest = sys.argv[2]
    platforms = sys.argv[3:] or ["web"]
    WANT = ("version.txt",) + tuple(f for p in platforms for f in FILES[p])
    os.makedirs(dest, exist_ok=True)
    if all(os.path.exists(os.path.join(dest, f)) for f in WANT):
        print("Đã có template", ", ".join(platforms), ":", dest)
        return
    url = "https://github.com/godotengine/godot/releases/download/%s-stable/Godot_v%s-stable_export_templates.tpz" % (ver, ver)
    f = HttpRangeFile(url)
    print("Gói templates: %.0f MB — chỉ tải phần %s" % (f.size / 1e6, ", ".join(platforms)))
    with zipfile.ZipFile(io.BufferedReader(f, buffer_size=1 << 20)) as z:
        for info in z.infolist():
            name = info.filename.split("/")[-1]
            if name in WANT and not os.path.exists(os.path.join(dest, name)):
                print("  tải", name, "%.1f MB" % (info.file_size / 1e6))
                with z.open(info) as src, open(os.path.join(dest, name), "wb") as out:
                    while True:
                        chunk = src.read(1 << 22)
                        if not chunk:
                            break
                        out.write(chunk)
    print("Xong:", dest)


if __name__ == "__main__":
    main()
