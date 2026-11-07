param(
    [string]$AppDir = "C:\Program Files\Elmo Motion Control\Elmo Application Studio III",
    [string]$Source = (Join-Path $PSScriptRoot "zh-CN")
)
$ErrorActionPreference = 'Stop'

if (-not (Test-Path (Join-Path $AppDir 'ElmoMotionControl.View.Main.exe'))) {
    throw "未在 $AppDir 找到 ElmoMotionControl.View.Main.exe，请用 -AppDir 指定安装目录"
}
if (-not (Test-Path $Source)) {
    throw "找不到汉化包目录: $Source"
}

$target = Join-Path $AppDir 'zh-CN'
$existed = Test-Path $target
New-Item -ItemType Directory -Force -Path $target | Out-Null

$files = Get-ChildItem -Path $Source -Filter '*.resources.dll'
foreach ($f in $files) { Copy-Item $f.FullName (Join-Path $target $f.Name) -Force }

Write-Host ("已安装 {0} 个中文卫星程序集到 {1}" -f $files.Count, $target) -ForegroundColor Green
if (-not $existed) { Write-Host "（zh-CN 目录为本次新建，卸载时整体删除即可）" }
Write-Host "启动 Elmo Application Studio III 即可看到中文界面。"
