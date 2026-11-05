# Quy trình CI/CD — sửa lỗi, cải tiến, ra tập mới

## Sơ đồ

```
 nhánh fix/... hoặc tap-2/...  ──PR──►  GitHub Actions: kiểm tra 6 bước trên Linux
                                          │ đạt
                                          ├─► xuất bản web ─► Vercel PREVIEW (link riêng, tự gắn vào PR)
 merge PR vào main  ──────────────────────┴─► Vercel PRODUCTION (link chính cho người chơi)
 gắn tag v1.2.0  ─────────────────────────────► GitHub Release: Windows .zip + Web .zip
```

- **Kiểm tra 6 bước** = `tools/check.ps1`: import · gdlint · test dữ liệu + 5 kết thúc · GUT (đồ thị kịch bản,
  font, chữ tràn khung, 400 lượt chơi ngẫu nhiên, save hỏng, tài nguyên thiếu, giao diện thật, chế độ điện thoại,
  di chuyển nhân vật) · chạy từng màn · tự chơi trọn Tập 1. **Đỏ ở bước nào thì không deploy.**
- `main` luôn là bản người chơi đang thấy. Không sửa thẳng trên `main`: luôn qua PR để có bản xem thử.
- File: `.github/workflows/ci.yml` (kiểm tra + deploy), `.github/workflows/release.yml` (phát hành).

## Việc hằng ngày

### Sửa lỗi
```powershell
git switch -c fix/ten-loi            # vd fix/kyky-khong-hien-mat-buon
# ... sửa ...
powershell -ExecutionPolicy Bypass -File tools\check.ps1   # chạy trên máy trước cho nhanh
git add -A; git commit -m "Sửa: ..."
git push -u origin fix/ten-loi
gh pr create --fill                  # GitHub chạy kiểm tra + gắn link xem thử vào PR
```
Mở link xem thử trên điện thoại → ổn thì **Merge** trên GitHub → vài phút sau bản chính thức tự cập nhật.
Mỗi lỗi đã sửa nên có 1 test trong `game/tests/gut/` để lỗi không quay lại.

### Ra tập mới (vd Tập 2)
1. `git switch -c tap-2/canh-1`
2. Viết kịch bản `game/data/dialogue/ep2_*.json` (skill `viet-hoi-thoai`, định dạng `docs/DIALOGUE_FORMAT.md`).
3. Nối bước truyện trong `game/scripts/story_steps.gd`; thêm kết thúc vào `game/data/endings.json`.
4. Ảnh/âm thanh mới → `game/assets/` + 1 dòng trong `docs/CREDITS.md` (test sẽ báo nếu quên).
5. Thêm test tuyến cho kết thúc mới (`game/tests/run_tests.gd`); bộ "người chơi ngẫu nhiên" tự kiểm tra kẹt game.
6. Cập nhật `docs/STORY.md`, tăng `config/version` trong `game/project.godot` (vd `1.2.0` → `2.0.0` khi ra tập mới).
7. PR từng phần nhỏ (mỗi cảnh một PR) — dễ xem thử, dễ quay lui.

### Phát hành phiên bản (tuỳ chọn)
```powershell
# config/version="1.2.0" trong game/project.godot đã được merge vào main
git switch main; git pull
git tag v1.2.0; git push origin v1.2.0
```
→ GitHub Release có file `TramDungChan-v1.2.0-windows.zip` và `-web.zip` để gửi bạn bè.

### Bản chính thức bị lỗi → quay lui ngay
- Trên Vercel: Project → Deployments → chọn bản trước → **Promote to Production** (hoặc `npx vercel rollback`).
- Rồi sửa lỗi qua PR như bình thường.

## Cài đặt lần đầu (đã làm / làm 1 lần)
1. Đăng nhập Vercel trên máy: `npx vercel@65.11.0 login` (đã làm). Bản chính thức: https://tram-dung-chan-beige.vercel.app
2. Deploy lần đầu để tạo project: `powershell -ExecutionPolicy Bypass -File tools\deploy_web.ps1 -Prod`
   → file `deploy/.vercel/project.json` chứa `orgId`, `projectId`.
3. Tạo token: vercel.com → Account Settings → Tokens → Create (đặt tên `github-actions`).
4. Cài 3 secrets cho GitHub — **tự chạy** trong PowerShell (token nhập ẩn, không lưu file):
   `powershell -ExecutionPolicy Bypass -File tools\setup_ci_secrets.ps1`
5. (Nên làm) GitHub → Settings → Branches → bảo vệ `main`: bắt buộc PR + bắt buộc job "Kiểm tra + xuất bản web" đạt.

## Ghi chú kỹ thuật
- Đã **ngắt** tự build Git của Vercel (`vercel git disconnect`): Vercel không chạy được Godot nên chỉ GitHub Actions deploy
  (sau khi kiểm tra 6 bước). Đừng bấm "Connect Git Repository" trên Vercel.
- Link xem thử (preview) mặc định bị Vercel khoá bằng đăng nhập (Deployment Protection). Muốn gửi link xem thử cho bạn bè:
  Vercel → Project → Settings → Deployment Protection → tắt "Vercel Authentication". Link chính thức luôn công khai.
- CI chỉ tải template **web** (~20 MB) bằng HTTP Range (`tools/get_templates.py`), không tải gói 1.3 GB; có cache.
- Bản web dùng chế độ một luồng (`variant/thread_support=false`) → chạy được trên iPhone/Safari, không cần header đặc biệt.
- `deploy/vercel.json`: header + `Cache-Control: must-revalidate` để người chơi luôn nhận bản mới sau mỗi lần deploy.
- Chạy thử bản web trên máy: `python -m http.server 8765 -d build/tram-dung-chan` rồi mở http://localhost:8765
