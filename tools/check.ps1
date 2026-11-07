# Harness kiểm tra (chạy sau MỖI thay đổi trong game\):
#   (1) import project & bắt lỗi
#   (2) gdlint — soi lỗi tĩnh GDScript (gdtoolkit, cấu hình game\gdlintrc)
#   (3) test dữ liệu + chơi thử tự động 5 kết thúc (game\tests\run_tests.gd)
#   (4) GUT — bộ test sâu (game\tests\gut\): đồ thị kịch bản, font, chữ tràn khung, 400 lượt chơi ngẫu nhiên,
#       save hỏng, tài nguyên thiếu, chạy thật giao diện hội thoại + từng màn
#   (5) chạy thử từng màn (headless, ~2 giây)
#   (6) tự chơi trọn Tập 1 từ màn hình chính tới kết thúc
# Chạy:  powershell -ExecutionPolicy Bypass -File tools\check.ps1     -> exit 0 nếu tất cả OK
#        -Quick: chỉ (1)(2)(3) — dùng cho hook sau mỗi lần sửa file
param([switch]$Quick)
. (Join-Path $PSScriptRoot "common.ps1")
$ErrorActionPreference = "Continue"
$pattern = "SCRIPT ERROR|Parse Error|Failed to load|ERROR:|Invalid call|Nonexistent function|Invalid access|Invalid get index|Invalid set index"
$total = if ($Quick) { 3 } else { 6 }

Write-Host "== 1/$total Import project ==" -ForegroundColor Cyan
$importLog = & $Godot --headless --path $GameDir --import 2>&1 | Out-String
$bad = $importLog -split "`n" | Where-Object { $_ -match $pattern }
if ($bad) {
    $bad | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    Write-Host "Import có lỗi." -ForegroundColor Red
    exit 1
}
Write-Host "Import OK"

Write-Host "== 2/$total gdlint ==" -ForegroundColor Cyan
$gdlint = $Gdlint
if ($gdlint -and (Test-Path $gdlint)) {
    $files = Get-ChildItem -Path (Join-Path $GameDir "autoload"), (Join-Path $GameDir "scenes"), (Join-Path $GameDir "scripts"), (Join-Path $GameDir "tests") -Recurse -Filter *.gd |
        ForEach-Object { $_.FullName.Substring($GameDir.Length + 1) }
    Push-Location $GameDir
    $lintLog = & $gdlint @files 2>&1 | Out-String
    $lintCode = $LASTEXITCODE
    Pop-Location
    if ($lintCode -ne 0) {
        Write-Host $lintLog -ForegroundColor Red
        Write-Host "LINT FAILED" -ForegroundColor Red
        exit 1
    }
    Write-Host "gdlint OK ($($files.Count) file)"
} else {
    Write-Host "  (bỏ qua: chưa cài gdtoolkit -> python -m venv tools\.venv-lint; tools\.venv-lint\Scripts\pip install ""gdtoolkit==4.*"")" -ForegroundColor Yellow
}

Write-Host "== 3/$total Test dữ liệu + 5 kết thúc ==" -ForegroundColor Cyan
$testLog = & $Godot --headless --path $GameDir -s res://tests/run_tests.gd 2>&1 | Out-String
$code = $LASTEXITCODE
Write-Host $testLog
if ($code -ne 0 -or $testLog -match "SCRIPT ERROR|Parse Error") {
    Write-Host "TEST FAILED" -ForegroundColor Red
    exit 1
}

if (-not $Quick) {
    Write-Host "== 4/$total GUT (game\tests\gut) ==" -ForegroundColor Cyan
    $gutLog = & $Godot --headless --path $GameDir -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/gut -gexit -gdisable_colors 2>&1 | Out-String
    $gutCode = $LASTEXITCODE
    $summary = $gutLog -split "`n" | Where-Object { $_ -match "^(Scripts|Tests|Passing Tests|Failing Tests|Asserts|Time)\s" -or $_ -match "Phân bố|Rung động:" }
    if ($gutCode -ne 0 -or $gutLog -match "Failing Tests|SCRIPT ERROR") {
        $gutLog -split "`n" | Where-Object { $_ -match "\[Failed\]|SCRIPT ERROR|^res://|^- test_|^\s+\[" } | Select-Object -First 60 | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        Write-Host "GUT FAILED  (xem đầy đủ: chạy lại lệnh GUT trong CLAUDE.md)" -ForegroundColor Red
        exit 1
    }
    $summary | ForEach-Object { Write-Host "  $($_.Trim())" }

    Write-Host "== 5/$total Chạy thử từng màn ==" -ForegroundColor Cyan
    $scenes = @(
        @("res://scenes/ui/title_screen.tscn", ""),
        @("res://scenes/vn/vn_scene.tscn", "--talk=ep1_s1"),
        @("res://scenes/vn/vn_scene.tscn", "--talk=ep1_s4"),
        @("res://scenes/world/cafe.tscn", ""),
        @("res://scenes/world/cafe.tscn", "--evening"),
        @("res://scenes/minigames/barista.tscn", ""),
        @("res://scenes/minigames/debug.tscn", ""),
        @("res://scenes/minigames/heartbeat.tscn", ""),
        @("res://scenes/phone/phone.tscn", ""),
        @("res://scenes/ui/ending.tscn", "")
    )
    $smokeFail = $false
    foreach ($s in $scenes) {
        $gargs = @("--headless", "--path", $GameDir, "--quit-after", "150", $s[0])
        if ($s[1]) { $gargs += @("--", $s[1]) }
        $log = & $Godot @gargs 2>&1 | Out-String
        $errs = $log -split "`n" | Where-Object { $_ -match $pattern -and $_ -notmatch "still in use at exit|leaked at exit" }
        if ($errs) {
            $smokeFail = $true
            Write-Host "  FAIL $($s[0]) $($s[1])" -ForegroundColor Red
            $errs | Select-Object -First 12 | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
        } else {
            Write-Host "  OK   $($s[0]) $($s[1])"
        }
    }
    if ($smokeFail) {
        Write-Host "SMOKE FAILED" -ForegroundColor Red
        exit 1
    }
    Write-Host "== 6/$total Tự chơi trọn từng tập từ màn hình chính (headless) ==" -ForegroundColor Cyan
    foreach ($ep in 1, 2, 3) {
        $log = & $Godot --headless --path $GameDir --fixed-fps 30 --quit-after 90000 -- --autoplay "--episode=$ep" 2>&1 | Out-String
        $errs = $log -split "`n" | Where-Object { $_ -match $pattern -and $_ -notmatch "still in use at exit|leaked at exit" }
        $endLine = $log -split "`n" | Where-Object { $_ -match "\[autoplay\] K" }
        if ($errs -or -not $endLine) {
            $errs | Select-Object -First 12 | ForEach-Object { Write-Host "     $_" -ForegroundColor Red }
            if (-not $endLine) { Write-Host "  Tập ${ep}: không chơi được tới kết thúc" -ForegroundColor Red }
            Write-Host "AUTOPLAY FAILED" -ForegroundColor Red
            exit 1
        }
        Write-Host "  OK  Tập ${ep}: $endLine"
    }
}
Write-Host "ALL CHECKS PASSED" -ForegroundColor Green
exit 0
