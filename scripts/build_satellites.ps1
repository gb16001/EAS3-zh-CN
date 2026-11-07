param(
    [Parameter(Mandatory=$true)][string]$DataDir,
    [Parameter(Mandatory=$true)][string]$OutDir,
    [string]$AsmFilter = "*"
)
$ErrorActionPreference = 'Stop'
$Csc = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $Csc)) { throw "csc.exe not found at $Csc" }

$index = Get-Content (Join-Path $DataDir 'index.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$trans = @{}
$tobj = Get-Content (Join-Path $DataDir 'translations.json') -Raw -Encoding UTF8 | ConvertFrom-Json
foreach ($p in $tobj.PSObject.Properties) { $trans[$p.Name] = $p.Value }

$tmp = Join-Path $env:TEMP ("satbuild_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

$built = 0; $stringCount = 0
foreach ($asmProp in $index.PSObject.Properties) {
    $asmFile = $asmProp.Name
    if ($asmFile -notlike $AsmFilter) { continue }
    $asm = [System.IO.Path]::GetFileNameWithoutExtension($asmFile)
    $version = $asmProp.Value.version
    $streamPlan = @{}
    foreach ($streamProp in $asmProp.Value.resources.PSObject.Properties) {
        $pairs = @{}
        foreach ($kv in $streamProp.Value.PSObject.Properties) {
            $id = $kv.Value
            if (-not $id) { continue }
            if ($trans.ContainsKey($id)) { $pairs[$kv.Name] = $trans[$id] }
        }
        if ($pairs.Count -gt 0) { $streamPlan[$streamProp.Name] = $pairs }
    }
    if ($streamPlan.Count -eq 0) { continue }

    $resFiles = @()
    $i = 0
    foreach ($streamName in $streamPlan.Keys) {
        $resPath = Join-Path $tmp ("res$i.resources")
        $rw = New-Object System.Resources.ResourceWriter($resPath)
        foreach ($k in $streamPlan[$streamName].Keys) { $rw.AddResource($k, [string]$streamPlan[$streamName][$k]) }
        $rw.Close()
        $resFiles += @{ Path = $resPath; Name = (($streamName -replace '\.resources$', '') + '.zh-CN.resources') }
        $stringCount += $streamPlan[$streamName].Count
        $i++
    }

    $safeAsm = $asm -replace '[^A-Za-z0-9.]', '_'
    $csPath = Join-Path $tmp "$safeAsm.cs"
    @"
using System.Reflection;
[assembly: AssemblyVersion("$version")]
[assembly: AssemblyFileVersion("$version")]
[assembly: AssemblyCulture("zh-CN")]
[assembly: AssemblyTitle("$asm (Simplified Chinese)")]
[assembly: AssemblyProduct("Elmo Application Studio III")]
"@ | Set-Content -Encoding UTF8 $csPath

    $outDll = Join-Path $tmp "$asm.resources.dll"
    $args = @('/nologo', '/target:library', "/out:$outDll")
    foreach ($r in $resFiles) { $args += "/resource:$($r.Path),$($r.Name)" }
    $args += $csPath
    $p = & $Csc @args 2>&1
    if ($LASTEXITCODE -ne 0) { throw "csc failed for $asm`n$($p -join "`n")" }
    Copy-Item $outDll (Join-Path $OutDir "$asm.resources.dll") -Force
    $built++
}
Remove-Item -Recurse -Force $tmp
"Built $built satellite assemblies, $stringCount strings -> $OutDir"
