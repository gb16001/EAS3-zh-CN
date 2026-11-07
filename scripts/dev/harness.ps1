param(
    [Parameter(Mandatory=$true)][string]$AsmPath,
    [Parameter(Mandatory=$true)][string]$BaseName,
    [Parameter(Mandatory=$true)][string]$KeysCsv
)
$ErrorActionPreference = 'Stop'
[System.Threading.Thread]::CurrentThread.CurrentUICulture = New-Object System.Globalization.CultureInfo('zh-CN')
[System.Threading.Thread]::CurrentThread.CurrentCulture = [System.Globalization.CultureInfo]::InvariantCulture
$asm = [System.Reflection.Assembly]::LoadFrom($AsmPath)
$rm = New-Object System.Resources.ResourceManager($BaseName, $asm)
foreach ($k in ($KeysCsv -split '\|')) {
    $v = $null
    try { $v = $rm.GetString($k) } catch { $v = "ERR: $($_.Exception.Message)" }
    $b64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes([string]$v))
    "KEY=$k  B64UTF8=$b64"
}
# also report which satellite was actually loaded
$loc = $rm.GetType().Assembly.Location
"RESOURCE_MANAGER_ASSEMBLY=$loc"
