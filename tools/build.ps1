# Đóng gói game.  tools\build.ps1            -> Windows (.exe) + nén .zip để gửi bạn bè
#                 tools\build.ps1 -Web       -> thêm bản Web (upload lên itch.io)
param([switch]$Web)
. (Join-Path $PSScriptRoot "common.ps1")
$ErrorActionPreference = "Continue"

& (Join-Path $PSScriptRoot "check.ps1")
if ($LASTEXITCODE -ne 0) { Write-Host "Sửa lỗi trước khi build." -ForegroundColor Red; exit 1 }

$tpl = Join-Path $env:APPDATA "Godot\export_templates\$GodotVersion.stable"
if (-not (Test-Path $tpl)) {
    Write-Host "Chưa có export templates -> chạy tools\install_export_templates.ps1" -ForegroundColor Yellow
    exit 1
}

$build = Join-Path $Root "build"
New-Item -ItemType Directory -Force (Join-Path $build "windows") | Out-Null
& $Godot --headless --path $GameDir --export-release "Windows Desktop" (Join-Path $build "windows\TramDungChan.exe")
Compress-Archive -Path (Join-Path $build "windows\*") -DestinationPath (Join-Path $build "TramDungChan-windows.zip") -Force
Write-Host "Windows: build\TramDungChan-windows.zip" -ForegroundColor Green

if ($Web) {
    New-Item -ItemType Directory -Force (Join-Path $build "tram-dung-chan") | Out-Null
    & $Godot --headless --path $GameDir --export-release "Web" (Join-Path $build "tram-dung-chan\index.html")
    & $Godot --headless --path $GameDir --export-pack "WebMusic" (Join-Path $build "tram-dung-chan\music.pck")
    Compress-Archive -Path (Join-Path $build "tram-dung-chan\*") -DestinationPath (Join-Path $build "TramDungChan-web.zip") -Force
    Write-Host "Web: build\tram-dung-chan\ + build\TramDungChan-web.zip (đưa lên Vercel: tools\deploy_web.ps1)" -ForegroundColor Green
}
