param([switch]$SkipBuild)
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    if (!$SkipBuild) { & .\build.ps1 }
    $version = (Get-Content -Raw -LiteralPath VERSION).Trim()
    if ((Get-Content -Raw -LiteralPath dist/VERSION).Trim() -ne $version) {
        throw 'Build version differs from VERSION. Rebuild before packaging.'
    }
    Copy-Item -LiteralPath README.md,VALIDATION.md,install.ps1,uninstall.ps1 -Destination dist -Force
    New-Item -ItemType Directory -Force release | Out-Null
    $binaryZip = "release/HundredLineMod-winmm-v$version.zip"
    $sourceZip = "release/HundredLineMod-source-v$version.zip"
    Compress-Archive -LiteralPath dist/winmm.dll,dist/verify.exe,dist/HundredLineMod.ini,dist/VERSION,dist/README.md,dist/VALIDATION.md,dist/install.ps1,dist/uninstall.ps1,docs -DestinationPath $binaryZip -Force
    $sources = @('src','tests','tools','docs','VERSION','README.md','VALIDATION.md',
        'HundredLineMod.ini','build.ps1','test-integration.ps1','install.ps1','uninstall.ps1',
        'package.ps1','.gitignore','.gitattributes','.editorconfig','.clang-format')
    Compress-Archive -LiteralPath $sources -DestinationPath $sourceZip -Force
    Get-FileHash -LiteralPath dist/winmm.dll,$binaryZip,$sourceZip | ForEach-Object {
        '{0}  {1}' -f $_.Hash,(Split-Path $_.Path -Leaf)
    } | Set-Content -LiteralPath "release/SHA256SUMS-v$version.txt" -Encoding ascii
    Write-Host "Packaged $binaryZip and $sourceZip"
} finally {
    Pop-Location
}
