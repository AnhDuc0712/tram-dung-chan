# Cài 3 secret cho GitHub Actions deploy lên Vercel. TỰ CHẠY trong PowerShell của bạn (1 lần):
#   powershell -ExecutionPolicy Bypass -File tools\setup_ci_secrets.ps1
# Cần: đã deploy 1 lần bằng tools\deploy_web.ps1 (có deploy\.vercel\project.json) và đã đăng nhập gh.
# Token Vercel: vercel.com > Account Settings > Tokens > Create (tên: github-actions). Token được nhập ẩn, không lưu file.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$repo = "AnhDuc0712/tram-dung-chan"
$pj = Join-Path $Root "deploy\.vercel\project.json"
if (-not (Test-Path $pj)) { Write-Host "Chưa có $pj -> chạy tools\deploy_web.ps1 -Prod trước." -ForegroundColor Red; exit 1 }
$p = Get-Content $pj -Raw | ConvertFrom-Json

$p.orgId | gh secret set VERCEL_ORG_ID --repo $repo
$p.projectId | gh secret set VERCEL_PROJECT_ID --repo $repo
Write-Host "Đã cài VERCEL_ORG_ID, VERCEL_PROJECT_ID" -ForegroundColor Green

$sec = Read-Host "Dán token Vercel (sẽ không hiện chữ) rồi Enter" -AsSecureString
$tok = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
if (-not $tok) { Write-Host "Chưa nhập token." -ForegroundColor Red; exit 1 }
$tok | gh secret set VERCEL_TOKEN --repo $repo
$tok = $null
Write-Host "Đã cài VERCEL_TOKEN. Danh sách secret:" -ForegroundColor Green
gh secret list --repo $repo
