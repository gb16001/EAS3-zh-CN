param(
    [string]$AppDir = "C:\Program Files\Elmo Motion Control\Elmo Application Studio III"
)
$ErrorActionPreference = 'Stop'
$target = Join-Path $AppDir 'zh-CN'
if (-not (Test-Path $target)) { throw "未安装汉化包：$target 不存在" }

$total = 0
$satellites = 0
Get-ChildItem -Path $target -Filter '*.resources.dll' | ForEach-Object {
    $a = [System.Reflection.Assembly]::LoadFrom($_.FullName)
    foreach ($n in $a.GetManifestResourceNames()) {
        if ($n -notmatch '\.resources$') { continue }
        $s = $a.GetManifestResourceStream($n)
        $rr = New-Object System.Resources.ResourceReader($s)
        $e = $rr.GetEnumerator()
        while ($e.MoveNext()) { $total++ }
        $rr.Close()
    }
    $satellites++
}
Write-Host ("卫星程序集: {0} 个，中文条目: {1} 条" -f $satellites, $total)
Write-Host "接下来请手动启动 Elmo Application Studio III，确认界面为中文。"
