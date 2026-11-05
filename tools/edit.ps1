# Mở Godot editor với project game\
. (Join-Path $PSScriptRoot "common.ps1")
Start-Process $GodotGui -ArgumentList @("--path", "`"$GameDir`"", "-e")
