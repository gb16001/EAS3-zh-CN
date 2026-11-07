param(
    [string]$DataDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'data'),
    [string]$DistDir = (Join-Path (Split-Path -Parent $PSScriptRoot) 'dist'),
    [string]$Version = '1.0.0',
    [string]$ZipPath = '',
    [switch]$SkipRebuild
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

if (-not $ZipPath) {
    $ZipPath = Join-Path $root ("release\EAS3-zh-CN-v{0}.zip" -f $Version)
}

if (-not $SkipRebuild) {
    & (Join-Path $PSScriptRoot 'build_satellites.ps1') -DataDir $DataDir -OutDir (Join-Path $DistDir 'zh-CN')
}

Copy-Item (Join-Path $PSScriptRoot 'install.ps1')   $DistDir -Force
Copy-Item (Join-Path $PSScriptRoot 'uninstall.ps1') $DistDir -Force
Copy-Item (Join-Path $PSScriptRoot 'verify.ps1')    $DistDir -Force
Copy-Item (Join-Path $PSScriptRoot 'package-readme.md') (Join-Path $DistDir 'README.md') -Force

$count = (Get-ChildItem (Join-Path $DistDir 'zh-CN') -Filter '*.resources.dll').Count
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ZipPath) | Out-Null
if (Test-Path $ZipPath) { Remove-Item $ZipPath -Force }
Compress-Archive -Path (Join-Path $DistDir '*') -DestinationPath $ZipPath -Force

Write-Host ("打包完成: {0} 个卫星程序集 -> {1}" -f $count, $ZipPath) -ForegroundColor Green
