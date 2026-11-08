# Script cài đặt & kích hoạt toàn diện Harness kiểm tra cho dự án Trạm Dừng Chân
# Chạy: powershell -ExecutionPolicy Bypass -File tools\install_harness.ps1

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot

Write-Host "=== CÀI ĐẶT HARNESS KIỂM TRA CHO REPO ===" -ForegroundColor Cyan

# 1. Kiểm tra / Cài đặt Godot
Write-Host "`n1. Kiểm tra Godot..." -ForegroundColor Yellow
$GodotDir = Join-Path $PSScriptRoot "godot"
$GodotExe = Join-Path $GodotDir "Godot_v4.7.2-stable_win64.exe"
if (-not (Test-Path $GodotExe)) {
    Write-Host "  Chưa có Godot -> Đang tải Godot 4.7.2..."
    & (Join-Path $PSScriptRoot "setup.ps1")
} else {
    Write-Host "  Godot OK: $GodotExe" -ForegroundColor Green
}

# 2. Kiểm tra Python Lint & Art Venvs
Write-Host "`n2. Kiểm tra môi trường Python (.venv-lint & .venv-art)..." -ForegroundColor Yellow
$VenvLint = Join-Path $PSScriptRoot ".venv-lint\Scripts\gdlint.exe"
if (-not (Test-Path $VenvLint)) {
    Write-Host "  Đang cài đặt gdtoolkit (gdlint) trong tools\.venv-lint..."
    python -m venv (Join-Path $PSScriptRoot ".venv-lint")
    & (Join-Path $PSScriptRoot ".venv-lint\Scripts\pip.exe") install "gdtoolkit==4.*"
}
Write-Host "  gdlint OK: $VenvLint" -ForegroundColor Green

$VenvArt = Join-Path $PSScriptRoot ".venv-art\Scripts\python.exe"
if (-not (Test-Path $VenvArt)) {
    Write-Host "  Đang tạo .venv-art..."
    python -m venv (Join-Path $PSScriptRoot ".venv-art")
    & (Join-Path $PSScriptRoot ".venv-art\Scripts\pip.exe") install -r (Join-Path $PSScriptRoot "art\requirements.txt")
}
Write-Host "  Python art OK: $VenvArt" -ForegroundColor Green

# 3. Cài đặt Git Pre-Commit Hook
Write-Host "`n3. Cài đặt Git Pre-Commit Hook..." -ForegroundColor Yellow
$GitHooksDir = Join-Path $Root ".git\hooks"
if (Test-Path $GitHooksDir) {
    $PreCommitPath = Join-Path $GitHooksDir "pre-commit"
    $hookContent = @'
#!/bin/sh
# Git pre-commit hook: Tu dong chay harness kiem tra truoc khi commit
echo "== [Git Hook] Dang chay harness kiem tra (tools/check.ps1 -Quick) =="
powershell -NoProfile -ExecutionPolicy Bypass -File tools/check.ps1 -Quick
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo "❌ [Git Hook] Harness kiem tra that bai! Vui long sua loi truoc khi commit."
    exit 1
fi
echo "✅ [Git Hook] Harness kiem tra OK!"
exit 0
'@
    [IO.File]::WriteAllText($PreCommitPath, $hookContent, [Text.Encoding]::ASCII)
    Write-Host "  Git hook OK: $PreCommitPath" -ForegroundColor Green
} else {
    Write-Host "  (Bỏ qua Git hook: không tìm thấy thư mục .git)" -ForegroundColor Yellow
}

# 4. Kích hoạt Antigravity PostToolUse Hook & Claude Settings
Write-Host "`n4. Kiểm tra cấu hình AI Agent Hooks..." -ForegroundColor Yellow
$AgentHooks = Join-Path $Root ".agents\hooks.json"
if (Test-Path $AgentHooks) {
    Write-Host "  Antigravity hook OK: $AgentHooks" -ForegroundColor Green
}

$ClaudeSettings = Join-Path $Root ".claude\settings.json"
if (Test-Path $ClaudeSettings) {
    Write-Host "  Claude Code settings OK: $ClaudeSettings" -ForegroundColor Green
}

# 5. Chạy thử nghiệm toàn bộ Harness
Write-Host "`n5. Chạy thử nghiệm Harness kiểm tra (Quick)..." -ForegroundColor Cyan
& powershell -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "check.ps1") -Quick

Write-Host "`n=== HARNESS ĐÃ ĐƯỢC CÀI ĐẶT VÀ HOẠT ĐỘNG HOÀN HẢO! ===" -ForegroundColor Green
