# Biến dùng chung cho các script trong tools\ — chạy được trên Windows (máy bạn) và Linux (GitHub Actions).
#   $env:GODOT  : đường dẫn Godot (CI đặt sẵn). Không có thì dùng bản portable trong tools\godot (Windows).
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
$GameDir = Join-Path $Root "game"
$GodotVersion = "4.7.2"
$GodotDir = Join-Path $PSScriptRoot "godot"
$OnWindows = ($PSVersionTable.PSEdition -eq "Desktop") -or $IsWindows

if ($env:GODOT) {
    $Godot = $env:GODOT
    $GodotGui = $env:GODOT
} else {
    $Godot = Join-Path $GodotDir "Godot_v$GodotVersion-stable_win64_console.exe"
    $GodotGui = Join-Path $GodotDir "Godot_v$GodotVersion-stable_win64.exe"
    if (-not (Test-Path $Godot)) {
        Write-Host "Chưa có Godot -> chạy tools\setup.ps1 trước (hoặc đặt biến GODOT)." -ForegroundColor Yellow
        exit 1
    }
}

# Thư mục export templates của Godot
if ($OnWindows) {
    $TemplatesDir = Join-Path $env:APPDATA "Godot\export_templates\$GodotVersion.stable"
} else {
    $TemplatesDir = Join-Path $HOME ".local/share/godot/export_templates/$GodotVersion.stable"
}

# gdlint (gdtoolkit): venv riêng trên Windows, hoặc có sẵn trong PATH (CI)
$Gdlint = Join-Path $PSScriptRoot ".venv-lint\Scripts\gdlint.exe"
if (-not (Test-Path $Gdlint)) {
    $cmd = Get-Command gdlint -ErrorAction SilentlyContinue
    $Gdlint = if ($cmd) { $cmd.Source } else { "" }
}
