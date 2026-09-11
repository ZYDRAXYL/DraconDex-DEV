<#
Starts one DraconDex dev target.
  -Target Exe (default): the Windows desktop app (DraconDex-EXE, `npm start`)
  -Target Pwa: the browser build's dev server (DraconDex-PWA, `npm run serve`)
#>

param(
    [ValidateSet('Exe', 'Pwa')]
    [string]$Target = 'Exe'
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot

$map = @{
    Exe = @{ Dir = 'DraconDex-EXE'; Script = 'start' }
    Pwa = @{ Dir = 'DraconDex-PWA'; Script = 'serve' }
}
$choice = $map[$Target]
$path = Join-Path $root $choice.Dir

if (-not (Test-Path $path)) {
    throw "$($choice.Dir) not found under $root — run scripts/setup.ps1 first."
}

Write-Host "Starting $($choice.Dir) (npm run $($choice.Script))..." -ForegroundColor Cyan
npm run $choice.Script --prefix $path
