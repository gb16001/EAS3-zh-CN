param([string]$Dir)
$ErrorActionPreference='SilentlyContinue'
$files = @("ElmoMotionControl.View.Main.exe","ElmoMotionControl.Core.dll","ElmoMotionControl.Resources.dll","ElmoMotionControl.Tuner.View.dll")
foreach($f in $files){
  $p = Join-Path $Dir $f
  $an=[System.Reflection.AssemblyName]::GetAssemblyName($p)
  "{0}`n  Version={1} Culture={2}`n  PublicKeyToken={3}`n  PKTlen={4}" -f $f,$an.Version,$an.CultureName,([BitConverter]::ToString($an.GetPublicKeyToken())),($an.GetPublicKeyToken().Length)
}
