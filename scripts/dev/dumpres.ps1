param([string]$Path,[string]$ResourceName,[string]$Out)
$ErrorActionPreference='Stop'
$asm=[System.Reflection.Assembly]::LoadFrom($Path)
$s=$asm.GetManifestResourceStream($ResourceName)
$rr=New-Object System.Resources.ResourceReader($s)
$rows=@()
$enum=$rr.GetEnumerator()
while($enum.MoveNext()){
  $rows += [pscustomobject]@{Key=$enum.Key; Type=$enum.Value.GetType().Name; Value=($enum.Value -as [string])}
}
Write-Output "TOTAL: $($rows.Count)"
$rows | Export-Csv -NoTypeInformation -Encoding UTF8 -Path $Out
$rows | Select-Object -First 15 | Format-Table -AutoSize -Wrap | Out-String -Width 200
