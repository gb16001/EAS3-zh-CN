param([string]$Path)
$ErrorActionPreference='Stop'
$asm=[System.Reflection.Assembly]::LoadFrom($Path)
Write-Output "=== $([System.IO.Path]::GetFileName($Path)) ==="
$asm.GetManifestResourceNames() | ForEach-Object { $_ }
