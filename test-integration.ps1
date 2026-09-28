param([string]$GameExe = 'D:\Game\Steam\steamapps\common\The Hundred Line -Last Defense Academy-\HUNDRED_LINE.exe')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
# Builds also initialize the compiler environment for this process.
. .\build.ps1
python tests/make_fixture.py $GameExe
if ($LASTEXITCODE) { throw 'Fixture extraction failed' }
New-Item -ItemType Directory -Force build/integration,build/ambiguous | Out-Null
& cl /nologo /std:c++17 /EHsc /W4 /O2 /MT /utf-8 /Isrc /Ibuild tests/host.cpp build/invoke_gift.obj /Fo:build/host.obj /Fe:build/integration/HUNDRED_LINE.exe /link /INCREMENTAL:NO /OPT:NOICF
if ($LASTEXITCODE) { throw 'Integration host build failed' }
& cl /nologo /std:c++17 /EHsc /W4 /O2 /MT /utf-8 /DDUPLICATE_GIFT /Isrc /Ibuild tests/host.cpp build/invoke_gift.obj /Fo:build/ambiguous.obj /Fe:build/ambiguous/HUNDRED_LINE.exe /link /INCREMENTAL:NO /OPT:NOICF
if ($LASTEXITCODE) { throw 'Ambiguous host build failed' }
foreach ($dir in @('build/integration','build/ambiguous')) { Copy-Item dist/winmm.dll $dir -Force }
$configPath = Join-Path $PSScriptRoot 'build/integration/HundredLineMod.ini'
if (Test-Path -LiteralPath $configPath) { Remove-Item -LiteralPath $configPath -Force }
& .\build\integration\HUNDRED_LINE.exe 500
if ($LASTEXITCODE) { throw "Default config integration failed: $LASTEXITCODE" }
if (!(Test-Path -LiteralPath $configPath -PathType Leaf)) { throw 'Default config was not generated' }
if ((Get-FileHash -LiteralPath $configPath).Hash -ne (Get-FileHash HundredLineMod.ini).Hash) {
    throw 'Generated defaults differ from the distributed configuration'
}
$ini = "[Mod]`nEnabled=1`nLockExplorationMaterials=1`nMaterialMultiplier=7.25`nShowGiftPreferences=1`n"
Set-Content build/integration/HundredLineMod.ini $ini -Encoding ascii
$existingConfigHash = (Get-FileHash -LiteralPath $configPath).Hash
& .\build\integration\HUNDRED_LINE.exe 725
if ($LASTEXITCODE) { throw "Enabled integration failed: $LASTEXITCODE" }
if ((Get-FileHash -LiteralPath $configPath).Hash -ne $existingConfigHash) {
    throw 'Existing user configuration was overwritten'
}
Set-Content build/integration/HundredLineMod.ini ($ini.Replace('Enabled=1','Enabled=0')) -Encoding ascii
& .\build\integration\HUNDRED_LINE.exe 120
if ($LASTEXITCODE) { throw "Disabled integration failed: $LASTEXITCODE" }
Set-Content build/integration/HundredLineMod.ini ($ini.Replace('7.25','NaN')) -Encoding ascii
& .\build\integration\HUNDRED_LINE.exe 120
if ($LASTEXITCODE) { throw "Invalid config integration failed: $LASTEXITCODE" }
Set-Content build/ambiguous/HundredLineMod.ini $ini -Encoding ascii
& .\build\ambiguous\HUNDRED_LINE.exe 120
if ($LASTEXITCODE) { throw "Ambiguous signature integration failed: $LASTEXITCODE" }
Get-Content build/integration/HundredLineMod.log,build/ambiguous/HundredLineMod.log
Write-Host 'All DLL integration scenarios passed.'
