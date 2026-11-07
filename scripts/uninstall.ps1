param(
    [string]$AppDir = "C:\Program Files\Elmo Motion Control\Elmo Application Studio III"
)
$ErrorActionPreference = 'Stop'
$target = Join-Path $AppDir 'zh-CN'
if (-not (Test-Path $target)) {
    Write-Host "没有找到 $target，无需卸载。"
    return
}
Remove-Item -Recurse -Force $target
Write-Host "已删除 $target，恢复到原始英文界面。" -ForegroundColor Green
