# Cài 3 secret cho GitHub Actions deploy lên Vercel. TỰ CHẠY trong PowerShell của bạn (1 lần):
#   powershell -ExecutionPolicy Bypass -File tools\setup_ci_secrets.ps1
# Cần: đã deploy 1 lần bằng tools\deploy_web.ps1 (có deploy\.vercel\project.json) và đã đăng nhập gh.
# Token Vercel: vercel.com > Account Settings > Tokens > Create (tên: github-actions) > bấm Copy, RỒI mới chạy script.
# Script đọc token từ clipboard, kiểm tra định dạng, cài vào GitHub rồi xoá clipboard. Không lưu file.
# (Đừng Ctrl+V vào ô nhập ẩn của Windows PowerShell 5.1: nó ghi ký tự ^V thay vì dán -> token hỏng.)
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$repo = "AnhDuc0712/tram-dung-chan"
$pj = Join-Path $Root "deploy\.vercel\project.json"
if (-not (Test-Path $pj)) { Write-Host "Chưa có $pj -> chạy tools\deploy_web.ps1 -Prod trước." -ForegroundColor Red; exit 1 }
$p = Get-Content $pj -Raw | ConvertFrom-Json

$p.orgId | gh secret set VERCEL_ORG_ID --repo $repo
$p.projectId | gh secret set VERCEL_PROJECT_ID --repo $repo
Write-Host "Đã cài VERCEL_ORG_ID, VERCEL_PROJECT_ID" -ForegroundColor Green

# Token Vercel chỉ gồm chữ/số (đúng luật của Vercel CLI: không ký tự lạ, không khoảng trắng).
$TokenRe = '^[A-Za-z0-9_]{16,}$'
function Read-Clip { try { $c = Get-Clipboard -Raw } catch { $c = "" }; if ($c) { return ([string]$c).Trim() }; return "" }

$tok = Read-Clip
if ($tok -notmatch $TokenRe) {
    Write-Host "Clipboard chưa có token Vercel hợp lệ." -ForegroundColor Yellow
    Write-Host "  - Bấm Copy token trên vercel.com rồi nhấn Enter ở đây, HOẶC"
    Write-Host "  - dán bằng CHUỘT PHẢI vào ô dưới rồi Enter (không dùng Ctrl+V)."
    $sec = Read-Host "Token (để trống + Enter = đọc lại clipboard)" -AsSecureString
    $tok = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)).Trim()
    if (-not $tok) { $tok = Read-Clip }
}
if ($tok -notmatch $TokenRe) {
    Write-Host "Token không hợp lệ (cần ~24 ký tự chữ và số). Chưa cài VERCEL_TOKEN." -ForegroundColor Red
    exit 1
}
$tok | gh secret set VERCEL_TOKEN --repo $repo
$tok = $null
cmd /c "echo off | clip"  # xoá token khỏi clipboard
Write-Host "Đã cài VERCEL_TOKEN. Danh sách secret:" -ForegroundColor Green
gh secret list --repo $repo
