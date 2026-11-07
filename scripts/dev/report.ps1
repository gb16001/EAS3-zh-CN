param([string]$Dir)
$ErrorActionPreference='SilentlyContinue'
$rows=@()
Get-ChildItem -Path $Dir -Filter '*.json' | ForEach-Object {
  $j=Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
  $n=0; $chars=0
  foreach($p in $j.resources.PSObject.Properties){
    if($p.Value -is [string]){ continue }
    foreach($q in $p.Value.PSObject.Properties){ if($q.Value -notmatch '^<<'){ $n++; $chars+=$q.Value.Length } }
  }
  $rows += [pscustomobject]@{Assembly=$j.assembly; Strings=$n; Chars=$chars}
}
$rows | Sort-Object Chars -Descending | Select-Object -First 25 | Format-Table -AutoSize | Out-String -Width 200
"TOTAL strings: $(($rows|Measure-Object Strings -Sum).Sum)  chars: $(($rows|Measure-Object Chars -Sum).Sum)  files: $($rows.Count)"
