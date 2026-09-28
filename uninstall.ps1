param([string]$GameDirectory = 'D:\Game\Steam\steamapps\common\The Hundred Line -Last Defense Academy-')
$ErrorActionPreference = 'Stop'
$game = (Resolve-Path -LiteralPath $GameDirectory).Path
if (!(Test-Path -LiteralPath (Join-Path $game 'HUNDRED_LINE.exe'))) { throw 'HUNDRED_LINE.exe not found.' }
if (Get-Process HUNDRED_LINE -ErrorAction SilentlyContinue) { throw 'Close HUNDRED_LINE before uninstalling.' }
$targetDll = Join-Path $game 'winmm.dll'
$marker = Join-Path $game 'HundredLineMod.install.json'
if (!(Test-Path -LiteralPath $marker)) { throw 'No installation marker found; no files were removed.' }
$installed = Get-Content -Raw -LiteralPath $marker | ConvertFrom-Json
if ($installed.Name -ne 'HundredLineMod') { throw 'Invalid installation marker.' }
if (Test-Path -LiteralPath $targetDll) {
    if ((Get-FileHash -LiteralPath $targetDll).Hash -ne $installed.SHA256) { throw 'winmm.dll changed; no files were removed.' }
    Remove-Item -LiteralPath $targetDll
}
Remove-Item -LiteralPath $marker
Write-Host 'Mod removed. Config and log kept. Original game files were not modified.'
