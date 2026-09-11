<#
Clones every DraconDex child repo that isn't already present next to this
hub, then runs `npm install` in each one that has a package.json.
Safe to re-run: existing repos are left alone (use `git pull` yourself).
#>

$ErrorActionPreference = 'Stop'

$org = 'ZYDRAXYL'
$repos = @('APK', 'APP', 'EXE', 'PKG', 'PWA', 'SDB', 'WEB')
$root = Split-Path -Parent $PSScriptRoot

foreach ($suffix in $repos) {
    $name = "DraconDex-$suffix"
    $path = Join-Path $root $name

    if (Test-Path $path) {
        Write-Host "[skip]  $name already exists" -ForegroundColor DarkGray
    } else {
        Write-Host "[clone] $name" -ForegroundColor Cyan
        git clone "https://github.com/$org/$name.git" $path
    }

    $pkgJson = Join-Path $path 'package.json'
    if (Test-Path $pkgJson) {
        Write-Host "[npm]   install in $name" -ForegroundColor Cyan
        npm install --prefix $path
    }
}

Write-Host "Done. Open DraconDex.code-workspace to get started." -ForegroundColor Green
