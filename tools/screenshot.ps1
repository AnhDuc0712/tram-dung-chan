# Chụp màn hình game tự động (để Claude/bạn xem UI mà không cần chơi tay).
#   tools\screenshot.ps1 -Scene cafe -Name map
#   tools\screenshot.ps1 -Scene vn -Talk ep1_s2 -Frames 200 -Name s2
#   tools\screenshot.ps1 -Scene cafe -Extra "--evening","--debug-walk" -Name eve
# -Scene: title | vn | cafe | barista | debug | heartbeat | phone | ending  (hoặc đường dẫn res://...)
# -Clicks: số lần "bấm tiếp" tự động trong hội thoại (mỗi 25 frame) để xem các câu sau.
# Ảnh lưu ở build\shots\<tên>.png (frame cuối).
param([string]$Scene = "", [string]$Talk = "", [int]$Frames = 90, [string]$Name = "shot", [string[]]$Extra = @(), [int]$Clicks = 0, [string]$Resolution = "1280x720")
. (Join-Path $PSScriptRoot "common.ps1")
$ErrorActionPreference = "Continue"
$map = @{
    "title" = "res://scenes/ui/title_screen.tscn"; "vn" = "res://scenes/vn/vn_scene.tscn";
    "cafe" = "res://scenes/world/cafe.tscn"; "barista" = "res://scenes/minigames/barista.tscn";
    "debug" = "res://scenes/minigames/debug.tscn"; "heartbeat" = "res://scenes/minigames/heartbeat.tscn";
    "phone" = "res://scenes/phone/phone.tscn"; "ending" = "res://scenes/ui/ending.tscn"
}
$outDir = Join-Path $Root "build\shots\tmp_$Name"
New-Item -ItemType Directory -Force $outDir | Out-Null
Get-ChildItem $outDir -Filter *.png | Remove-Item
$gargs = @("--path", $GameDir, "--write-movie", (Join-Path $outDir "f.png"), "--fixed-fps", "30", "--quit-after", "$Frames", "--resolution", $Resolution)
if ($Scene) {
    if ($map.ContainsKey($Scene)) { $gargs += $map[$Scene] } else { $gargs += $Scene }
}
$user = @()
if ($Talk) { $user += "--talk=$Talk" }
if ($Clicks -gt 0) { $user += "--autoclick=$Clicks" }
foreach ($e in $Extra) { $user += ($e -split ",") | Where-Object { $_ } }
if ($user.Count -gt 0) { $gargs += "--"; $gargs += $user }
& $Godot @gargs 2>&1 | Where-Object { $_ -match "ERROR" -and $_ -notmatch "still in use at exit|leaked at exit" } | ForEach-Object { Write-Host $_ -ForegroundColor Red }
$last = Get-ChildItem $outDir -Filter *.png | Sort-Object Name | Select-Object -Last 1
if (-not $last) { Write-Host "Không chụp được ảnh" -ForegroundColor Red; exit 1 }
$dest = Join-Path $Root "build\shots\$Name.png"
Copy-Item $last.FullName $dest -Force
Remove-Item $outDir -Recurse -Force
Write-Host "Saved: $dest"
