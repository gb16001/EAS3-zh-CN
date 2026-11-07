param([string]$Dir,[string]$OutDir,[string]$NamesCsv)
$ErrorActionPreference='Stop'
foreach($n in ($NamesCsv -split '\|')){
  $f=Join-Path $Dir $n
  try{
    $asm=[System.Reflection.Assembly]::LoadFrom($f)
    $names=$asm.GetManifestResourceNames() | Where-Object { $_ -match '\.resources$' -and $_ -notmatch '\.g\.resources$' }
    $bag=[ordered]@{}
    $c=0
    foreach($rn in $names){
      $s=$asm.GetManifestResourceStream($rn)
      $rr=New-Object System.Resources.ResourceReader($s)
      $d=[ordered]@{}
      $e=$rr.GetEnumerator()
      while($e.MoveNext()){
        if($e.Value -is [string]){ if($e.Value.Trim().Length -gt 0){ $d[$e.Key]=$e.Value; $c++ } }
        else { $d[$e.Key]="<<NONSTRING:"+$e.Value.GetType().Name+">>" }
      }
      $rr.Close(); $bag[$rn]=$d
    }
    $o=[ordered]@{assembly=$n; version=([System.Reflection.AssemblyName]::GetAssemblyName($f).Version.ToString()); resources=$bag}
    ($o|ConvertTo-Json -Depth 6)|Set-Content -Encoding UTF8 (Join-Path $OutDir ($n -replace '\.dll$','')+'.json')
    "OK $n strings=$c"
  }catch{ "FAIL $n : " + $_.Exception.Message }
}
