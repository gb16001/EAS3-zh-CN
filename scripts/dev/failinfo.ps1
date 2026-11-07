param([string]$Dir)
$ErrorActionPreference='SilentlyContinue'
foreach($n in @('ElmoMotionControl.Tuner.A.dll','ElmoMotionControl.Tuner.Command.dll','ElmoMotionControl.ErrorMapping.ViewModel.dll','ElmoMotionControl.GMAS.Cad2Prt.dll','ElmoMotionControlComponents.Maestro.ProfilerSimulator.dll')){
  try{ $a=[System.Reflection.Assembly]::LoadFrom((Join-Path $Dir $n)); "OK $n : " + (($a.GetManifestResourceNames()) -join ',') }
  catch { "FAIL $n : " + $_.Exception.GetType().Name + " :: " + $_.Exception.Message }
}
