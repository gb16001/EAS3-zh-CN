param([string]$Dir)
$ErrorActionPreference='SilentlyContinue'
Get-ChildItem -Path $Dir -Filter "ElmoMotionControl*.dll" | ForEach-Object {
  $f=$_.Name
  try{
    $asm=[System.Reflection.Assembly]::LoadFrom($_.FullName)
    $names=$asm.GetManifestResourceNames()
    $props = $names | Where-Object { $_ -match '\.resources$' -and $_ -notmatch '\.g\.resources$' }
    $g = $names | Where-Object { $_ -match '\.g\.resources$' }
    "{0} | resx={1} | xaml={2} | {3}" -f $f, $props.Count, $g.Count, ($props -join ',')
  }catch{ "{0} | LOADFAIL: {1}" -f $f, $_.Exception.Message }
}
