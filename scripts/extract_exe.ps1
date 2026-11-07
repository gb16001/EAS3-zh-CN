param([string]$Exe,[string]$Out)
$ErrorActionPreference='Stop'
$asm=[System.Reflection.Assembly]::LoadFrom($Exe)
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
$o=[ordered]@{assembly=(Split-Path $Exe -Leaf); version=([System.Reflection.AssemblyName]::GetAssemblyName($Exe).Version.ToString()); resources=$bag}
($o|ConvertTo-Json -Depth 6)|Set-Content -Encoding UTF8 $Out
"strings=$c"
