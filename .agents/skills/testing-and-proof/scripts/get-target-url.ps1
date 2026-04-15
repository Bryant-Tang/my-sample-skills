Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot '..\..\run-project\scripts\resolve-iis-settings.ps1')

try {
    $settings = Resolve-IisSettings -ScriptDir (Join-Path $PSScriptRoot '..\..\run-project\scripts')
    Write-Output "IIS URL: $($settings.IisUrl)"
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}