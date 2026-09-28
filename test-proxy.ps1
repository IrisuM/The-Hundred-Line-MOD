$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
. .\build.ps1
New-Item -ItemType Directory -Force build/proxy-test | Out-Null
& cl /nologo /std:c++17 /EHsc /W4 /O2 /MT /utf-8 /Isrc /Ibuild tests/proxy_compat.cpp /Fo:build/proxy_compat.obj /Fe:build/proxy-test/proxy_compat.exe /link /INCREMENTAL:NO
if ($LASTEXITCODE) { throw 'Proxy compatibility test build failed' }
$logPath = Join-Path $PSScriptRoot 'build/proxy-test/HundredLineMod.log'
if (Test-Path -LiteralPath $logPath) { Remove-Item -LiteralPath $logPath }
& .\build\proxy-test\proxy_compat.exe "$PSScriptRoot\dist\winmm.dll"
if ($LASTEXITCODE) { throw 'Proxy compatibility test failed' }
$log = Get-Content -Raw -LiteralPath $logPath
foreach ($message in @(
    'Unavailable system export: WOWAppExit (ordinal: 14); deferred until called',
    'Cannot forward requested system export: WOWAppExit (ordinal: 14)',
    'Invalid WinMM export index:'
)) {
    if (!$log.Contains($message)) { throw "Missing diagnostic: $message" }
}
Write-Host 'All proxy compatibility checks passed (simulated missing export; Proton validation is separate).'
