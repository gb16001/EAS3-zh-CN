param([string]$Dll,[string]$KeysCsv)
$ErrorActionPreference='Stop'
$asm=[System.Reflection.Assembly]::LoadFrom($Dll)
$gname=($asm.GetManifestResourceNames() | Where-Object { $_ -match '\.g\.resources$' })
$allText=New-Object System.Text.StringBuilder
foreach($g in $gname){
  $s=$asm.GetManifestResourceStream($g)
  $rr=New-Object System.Resources.ResourceReader($s)
  $e=$rr.GetEnumerator()
  while($e.MoveNext()){
    if($e.Value -is [System.IO.Stream]){
      $ms=New-Object System.IO.MemoryStream
      $e.Value.CopyTo($ms)
      $bytes=$ms.ToArray()
      [void]$allText.Append([System.Text.Encoding]::GetEncoding(28591).GetString($bytes))
    }
  }
  $rr.Close()
}
$txt=$allText.ToString()
"BAML bytes: $($txt.Length)"
foreach($k in ($KeysCsv -split '\|')){
  "KEY '{0}': {1}" -f $k,$txt.Contains($k)
}
