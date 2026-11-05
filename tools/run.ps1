# Chạy game.   tools\run.ps1                        -> từ màn hình chính
#              tools\run.ps1 -Scene cafe            -> vào thẳng quán (buổi chiều)
#              tools\run.ps1 -Scene cafe -Extra "--evening"   -> quán buổi tối
#              tools\run.ps1 -Scene vn -Talk ep1_s3 -> chạy thẳng một phân cảnh
# -Scene: title | vn | cafe | barista | debug | heartbeat | phone | ending
param([string]$Scene = "", [string]$Talk = "", [string[]]$Extra = @())
. (Join-Path $PSScriptRoot "common.ps1")
$map = @{
    "title" = "res://scenes/ui/title_screen.tscn"; "vn" = "res://scenes/vn/vn_scene.tscn";
    "cafe" = "res://scenes/world/cafe.tscn"; "barista" = "res://scenes/minigames/barista.tscn";
    "debug" = "res://scenes/minigames/debug.tscn"; "heartbeat" = "res://scenes/minigames/heartbeat.tscn";
    "phone" = "res://scenes/phone/phone.tscn"; "ending" = "res://scenes/ui/ending.tscn"
}
$gargs = @("--path", $GameDir)
if ($Scene) {
    if ($map.ContainsKey($Scene)) { $gargs += $map[$Scene] } else { $gargs += $Scene }
}
$user = @()
if ($Talk) { $user += "--talk=$Talk" }
foreach ($e in $Extra) { $user += ($e -split ",") | Where-Object { $_ } }
if ($user.Count -gt 0) { $gargs += "--"; $gargs += $user }
& $GodotGui @gargs
