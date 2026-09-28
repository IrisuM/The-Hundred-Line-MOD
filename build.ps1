param([switch]$RegenerateExports)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
if ($RegenerateExports) {
    python tools/generate_proxy.py
    if ($LASTEXITCODE) { throw 'Export generation failed' }
}
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$install = & $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
if (!$install) { throw 'Visual Studio C++ x64 Build Tools are required.' }
$dev = Join-Path $install 'Common7\Tools\VsDevCmd.bat'
$envLines = & $env:ComSpec /d /c "call `"$dev`" -no_logo -arch=x64 -host_arch=x64 >nul && set"
if ($LASTEXITCODE) { throw 'Developer environment initialization failed' }
$seenEnvironment = @{}
foreach ($line in $envLines) {
    if ($line -match '^([^=]+)=(.*)$' -and !$seenEnvironment.ContainsKey($matches[1])) {
        $seenEnvironment[$matches[1]] = $true
        [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process')
    }
}
New-Item -ItemType Directory -Force build,dist | Out-Null
$version = (Get-Content -Raw -LiteralPath VERSION).Trim()
if ($version -notmatch '^\d+\.\d+(\.\d+)?$') { throw 'Invalid VERSION file.' }
Set-Content -LiteralPath build/version.h -Value "#define HL_MOD_VERSION `"$version`"" -Encoding ascii
& ml64 /nologo /c /Fo build/winmm_stubs.obj src/generated/winmm_stubs.asm
if ($LASTEXITCODE) { throw 'Assembler failed' }
& cl /nologo /std:c++17 /EHsc /W4 /O2 /MT /LD /utf-8 /Ibuild src/mod.cpp build/winmm_stubs.obj /Fo:build/mod.obj /link /DEF:src/generated/winmm.def /OUT:dist/winmm.dll /IMPLIB:build/winmm.lib /INCREMENTAL:NO
if ($LASTEXITCODE) { throw 'DLL build failed' }
& ml64 /nologo /c /Fo build/invoke_gift.obj tests/invoke_gift.asm
if ($LASTEXITCODE) { throw 'Test assembler failed' }
& cl /nologo /std:c++17 /EHsc /W4 /O2 /MT /utf-8 /Isrc tests/verify.cpp build/invoke_gift.obj /Fo:build/verify.obj /Fe:dist/verify.exe /link /INCREMENTAL:NO
if ($LASTEXITCODE) { throw 'Verifier build failed' }
Copy-Item HundredLineMod.ini dist/HundredLineMod.ini
Copy-Item VERSION dist/VERSION
Write-Host 'Built dist/winmm.dll and dist/verify.exe'
