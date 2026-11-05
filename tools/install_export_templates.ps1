# Tải export templates cần để ĐÓNG GÓI game — chỉ phần Web + Windows (~110 MB) thay vì cả gói 1.3 GB.
# Chạy 1 lần:  powershell -ExecutionPolicy Bypass -File tools\install_export_templates.ps1
. (Join-Path $PSScriptRoot "common.ps1")
$py = Get-Command python -ErrorAction SilentlyContinue
if (-not $py) { Write-Host "Cần Python 3 (python.org) để tải template." -ForegroundColor Red; exit 1 }
& $py.Source -I (Join-Path $PSScriptRoot "get_templates.py") $GodotVersion $TemplatesDir web windows
if ($LASTEXITCODE -ne 0) { exit 1 }
Write-Host "Xong: $TemplatesDir" -ForegroundColor Green
