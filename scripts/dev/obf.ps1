param([string]$Dir)
$ErrorActionPreference='SilentlyContinue'
$bad=@(); $ok=0
Get-ChildItem -Path $Dir -Filter "ElmoMotionControl*.dll" | ForEach-Object {
  try{
    $a=[System.Reflection.Assembly]::LoadFrom($_.FullName)
    $n=@($a.GetManifestResourceNames())
    if($n.Count -eq 0){ return }
    $weird = $n | Where-Object { $_ -notmatch '^[A-Za-z0-9_.]+\.resources$' }
    if($weird.Count -gt 0){ $bad += $_.Name } else { $ok++ }
  }catch{}
}
"Normal-named resource assemblies: $ok"
"Obfuscated-looking assemblies: $($bad.Count)"
$bad
