# Hook Claude Code (PostToolUse Edit|Write): sửa file trong game\ -> tự chạy tools\check.ps1.
# Lỗi -> exit 2 để Claude thấy và sửa ngay.
$raw = [Console]::In.ReadToEnd()
try { $p = ($raw | ConvertFrom-Json).tool_input.file_path } catch { exit 0 }
if (-not $p) { exit 0 }
$norm = $p -replace '\\', '/'
if ($norm -notmatch '/game/' -or $norm -notmatch '\.(gd|json|tscn|cfg|godot)$') { exit 0 }
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "..\check.ps1") -Quick 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("tools/check.ps1 FAILED sau khi sửa $p`n$out")
    exit 2
}
exit 0
