# Xuất bản Web và đưa lên Vercel TỪ MÁY BẠN (bình thường GitHub Actions tự làm khi merge vào main).
#   powershell -ExecutionPolicy Bypass -File tools\deploy_web.ps1            -> bản xem thử (preview)
#   powershell -ExecutionPolicy Bypass -File tools\deploy_web.ps1 -Prod      -> bản chính thức (production)
#   -SkipCheck: bỏ qua tools\check.ps1 (không khuyến khích)
# Lần đầu: đăng nhập Vercel bằng  ! npx vercel login
param([switch]$Prod, [switch]$SkipCheck)
. (Join-Path $PSScriptRoot "common.ps1")
$ErrorActionPreference = "Continue"
$VercelCli = "vercel@65.11.0"

if (-not $SkipCheck) {
    & (Join-Path $PSScriptRoot "check.ps1")
    if ($LASTEXITCODE -ne 0) { Write-Host "Sửa lỗi trước khi deploy." -ForegroundColor Red; exit 1 }
}

# 1) template web (~20 MB)
$py = (Get-Command python -ErrorAction SilentlyContinue).Source
& $py -I (Join-Path $PSScriptRoot "get_templates.py") $GodotVersion $TemplatesDir web
if ($LASTEXITCODE -ne 0) { exit 1 }

# 2) xuất bản web
$out = Join-Path $Root "build/tram-dung-chan"
if (Test-Path $out) { Get-ChildItem $out -Exclude ".vercel" | Remove-Item -Recurse -Force }
New-Item -ItemType Directory -Force $out | Out-Null
& $Godot --headless --path $GameDir --export-release "Web" (Join-Path $out "index.html") 2>&1 | Where-Object { $_ -match "ERROR" }
if (-not (Test-Path (Join-Path $out "index.pck"))) { Write-Host "Export web thất bại." -ForegroundColor Red; exit 1 }
Copy-Item (Join-Path $Root "deploy/vercel.json") $out

# 3) giữ liên kết project Vercel giữa các lần build (deploy/.vercel/project.json, không đưa lên git)
$link = Join-Path $Root "deploy/.vercel"
if (Test-Path (Join-Path $link "project.json")) {
    New-Item -ItemType Directory -Force (Join-Path $out ".vercel") | Out-Null
    Copy-Item (Join-Path $link "project.json") (Join-Path $out ".vercel") -Force
}

# 4) đưa lên Vercel
$vargs = @("--yes", $VercelCli, "deploy", $out, "--yes")
if ($Prod) { $vargs += "--prod" }
if ($env:VERCEL_TOKEN) { $vargs += @("--token", $env:VERCEL_TOKEN) }
$url = & npx @vargs
if ($LASTEXITCODE -ne 0) { Write-Host "Deploy thất bại (đã đăng nhập chưa? ! npx vercel login)" -ForegroundColor Red; exit 1 }
if (Test-Path (Join-Path $out ".vercel/project.json")) {
    New-Item -ItemType Directory -Force $link | Out-Null
    Copy-Item (Join-Path $out ".vercel/project.json") $link -Force
}
Write-Host ""
Write-Host ("Đã deploy " + ($(if ($Prod) { "BẢN CHÍNH THỨC" } else { "bản xem thử" })) + ": $url") -ForegroundColor Green
