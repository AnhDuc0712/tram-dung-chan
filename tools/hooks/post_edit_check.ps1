# Hook PostToolUse (Claude Code / Antigravity): sửa file trong game\ -> tự chạy tools\check.ps1.
# Lỗi -> exit 2 để AI thấy và sửa ngay.
$raw = [Console]::In.ReadToEnd()
try {
    $json = $raw | ConvertFrom-Json
    $p = if ($json.tool_input.file_path) {
        $json.tool_input.file_path
    } elseif ($json.toolCall.args.Path) {
        $json.toolCall.args.Path
    } else {
        $null
    }
} catch {
    Write-Output "{}"
    exit 0
}
if (-not $p) {
    Write-Output "{}"
    exit 0
}
$norm = $p -replace '\\', '/'
if ($norm -notmatch '/game/' -or $norm -notmatch '\.(gd|json|tscn|cfg|godot)$') {
    Write-Output "{}"
    exit 0
}
$out = & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot "..\check.ps1") -Quick 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    [Console]::Error.WriteLine("tools/check.ps1 FAILED sau khi sửa $p`n$out")
    exit 2
}
Write-Output "{}"
exit 0
