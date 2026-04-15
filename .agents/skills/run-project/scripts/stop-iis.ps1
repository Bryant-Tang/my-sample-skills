Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SkillConfig {
    param([string]$RepoRoot)

    $configFile = Join-Path $RepoRoot '.agents/skill-scripts.psd1'

    if (-not (Test-Path -LiteralPath $configFile -PathType Leaf)) {
        return @{}
    }

    return Import-PowerShellDataFile -LiteralPath $configFile
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..\..\..'))
    $config = Get-SkillConfig -RepoRoot $repoRoot
    $iisExpressPath = $config['RUN_IIS_EXPRESS_PATH']

    if ([string]::IsNullOrWhiteSpace($iisExpressPath)) {
        throw 'Missing RUN_IIS_EXPRESS_PATH in .agents/skill-scripts.psd1'
    }

    $processName = [System.IO.Path]::GetFileNameWithoutExtension($iisExpressPath)

    if ([string]::IsNullOrWhiteSpace($processName)) {
        throw 'Missing RUN_IIS_EXPRESS_PATH in .agents/skill-scripts.psd1'
    }

    $processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

    if ($null -eq $processes) {
        Write-Output "No $processName process found."
        exit 0
    }

    $processes | Stop-Process -Force
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}