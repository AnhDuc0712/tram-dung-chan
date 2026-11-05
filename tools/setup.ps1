# Cài môi trường lần đầu: Godot editor (portable) + Python venv cho công cụ tách nền ảnh.
# Chạy:  powershell -ExecutionPolicy Bypass -File tools\setup.ps1
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
$GodotVersion = "4.7.2"
$GodotDir = Join-Path $PSScriptRoot "godot"
$exe = Join-Path $GodotDir "Godot_v$GodotVersion-stable_win64.exe"

if (-not (Test-Path $exe)) {
    New-Item -ItemType Directory -Force $GodotDir | Out-Null
    $zip = Join-Path $GodotDir "godot.zip"
    Write-Host "Đang tải Godot $GodotVersion ..."
    Invoke-WebRequest "https://github.com/godotengine/godot/releases/download/$GodotVersion-stable/Godot_v$GodotVersion-stable_win64.exe.zip" -OutFile $zip
    Expand-Archive $zip -DestinationPath $GodotDir -Force
    Remove-Item $zip
}
Write-Host "Godot OK: $exe" -ForegroundColor Green

$venv = Join-Path $PSScriptRoot ".venv-art"
if (-not (Test-Path (Join-Path $venv "Scripts\python.exe"))) {
    Write-Host "Đang tạo Python venv + cài rembg (tách nền ảnh) ..."
    python -m venv $venv
    & "$venv\Scripts\python.exe" -m pip install --quiet --upgrade pip
    & "$venv\Scripts\python.exe" -m pip install --quiet -r (Join-Path $PSScriptRoot "art\requirements.txt")
}
Write-Host "Python art tools OK: $venv" -ForegroundColor Green
Write-Host "Mở editor: tools\edit.ps1   |   Chạy game: tools\run.ps1   |   Kiểm tra: tools\check.ps1"
