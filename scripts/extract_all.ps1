param([string]$Dir,[string]$OutDir)
$ErrorActionPreference='Stop'
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$summary=@()
$files = Get-ChildItem -Path $Dir -Filter "*.dll" | Where-Object { $_.Name -match '^ElmoMotionControl' }
foreach($f in $files){
  try{
    $asm=[System.Reflection.Assembly]::LoadFrom($f.FullName)
    $names=$asm.GetManifestResourceNames() | Where-Object { $_ -match '\.resources$' -and $_ -notmatch '\.g\.resources$' }
    if(-not $names){ continue }
    $bag=[ordered]@{}
    $strCount=0; $otherCount=0
    foreach($n in $names){
      $s=$asm.GetManifestResourceStream($n)
      if(-not $s){ continue }
      try{
        $rr=New-Object System.Resources.ResourceReader($s)
        $d=[ordered]@{}
        $e=$rr.GetEnumerator()
        while($e.MoveNext()){
          if($e.Value -is [string]){
            if($e.Value.Trim().Length -gt 0){ $d[$e.Key]=$e.Value; $strCount++ } else { $otherCount++ }
          } else { $d[$e.Key]="<<NONSTRING:"+$e.Value.GetType().Name+">>"; $otherCount++ }
        }
        $rr.Close()
        $bag[$n]=$d
      }catch{ $bag[$n]="<<READFAIL: $($_.Exception.Message)>>" }
    }
    $base=$f.BaseName
    $bag2=[ordered]@{assembly=$f.Name; version=([System.Reflection.AssemblyName]::GetAssemblyName($f.FullName).Version.ToString()); resources=$bag}
    ($bag2 | ConvertTo-Json -Depth 6) | Set-Content -Encoding UTF8 (Join-Path $OutDir ($base+'.json'))
    $summary += [pscustomobject]@{Assembly=$f.Name; ResStreams=$names.Count; Strings=$strCount; Other=$otherCount}
  }catch{
    $summary += [pscustomobject]@{Assembly=$f.Name; ResStreams=-1; Strings=-1; Other=-1}
  }
}
$summary | Sort-Object -Property Strings -Descending | Format-Table -AutoSize | Out-String -Width 200
"TOTAL ASSEMBLIES: $($summary.Count)"
"TOTAL STRINGS: $(($summary | Measure-Object -Property Strings -Sum).Sum)"
