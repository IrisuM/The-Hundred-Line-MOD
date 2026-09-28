param([string]$GameDirectory = 'D:\Game\Steam\steamapps\common\The Hundred Line -Last Defense Academy-')
$ErrorActionPreference = 'Stop'
$game = (Resolve-Path -LiteralPath $GameDirectory).Path
if (!(Test-Path -LiteralPath (Join-Path $game 'HUNDRED_LINE.exe'))) { throw 'HUNDRED_LINE.exe not found.' }
if (Get-Process HUNDRED_LINE -ErrorAction SilentlyContinue) { throw 'Close HUNDRED_LINE before installing.' }
$package = if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'winmm.dll')) { $PSScriptRoot } else { Join-Path $PSScriptRoot 'dist' }
$sourceDll = Join-Path $package 'winmm.dll'
$targetDll = Join-Path $game 'winmm.dll'
$marker = Join-Path $game 'HundredLineMod.install.json'
if (!(Test-Path -LiteralPath $sourceDll)) { throw 'Build the mod first (build.ps1).' }
$version = (Get-Content -Raw -LiteralPath (Join-Path $package 'VERSION')).Trim()
if (Test-Path -LiteralPath $targetDll) {
    if (!(Test-Path -LiteralPath $marker)) { throw 'An existing winmm.dll belongs to another installation. It was not overwritten.' }
    $previous = Get-Content -Raw -LiteralPath $marker | ConvertFrom-Json
    if ((Get-FileHash -LiteralPath $targetDll).Hash -ne $previous.SHA256) { throw 'winmm.dll differs from this mod installation. It was not overwritten.' }
}
Copy-Item -LiteralPath $sourceDll -Destination $targetDll -Force
$targetIni = Join-Path $game 'HundredLineMod.ini'
if (!(Test-Path -LiteralPath $targetIni)) { Copy-Item -LiteralPath (Join-Path $package 'HundredLineMod.ini') -Destination $targetIni }
@{ Name='HundredLineMod'; Version=$version; SHA256=(Get-FileHash -LiteralPath $targetDll).Hash } |
    ConvertTo-Json | Set-Content -LiteralPath $marker -Encoding UTF8
Write-Host "Installed: $targetDll"
Write-Host "Config: $targetIni"
