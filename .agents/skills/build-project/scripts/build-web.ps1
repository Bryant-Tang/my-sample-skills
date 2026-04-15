Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-SkillConfig {
    param(
        [string]$ConfigFile,
        [string]$Purpose
    )

    if (-not (Test-Path -LiteralPath $ConfigFile -PathType Leaf)) {
        throw "Missing $Purpose config: $ConfigFile"
    }

    return Import-PowerShellDataFile -LiteralPath $ConfigFile
}

function Resolve-RepoPath {
    param(
        [string]$RepoRoot,
        [string]$PathValue
    )

    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        return $PathValue
    }

    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $RepoRoot $PathValue))
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $contentPackScript = Join-Path $scriptDir 'pack-content.ps1'
    $repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..\..\..'))
    $configFile = Join-Path $repoRoot '.agents/skill-scripts.psd1'

    $config = Get-SkillConfig -ConfigFile $configFile -Purpose 'build-project'
    $projectPathRel = $config['BUILD_PROJECT_PATH']
    $msbuildPath = $config['BUILD_MSBUILD_PATH']

    if ([string]::IsNullOrWhiteSpace($projectPathRel)) {
        throw 'Missing BUILD_PROJECT_PATH in .agents/skill-scripts.psd1'
    }

    if ([string]::IsNullOrWhiteSpace($msbuildPath)) {
        throw 'Missing BUILD_MSBUILD_PATH in .agents/skill-scripts.psd1'
    }

    $projectFile = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $projectPathRel
    $msbuildPath = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $msbuildPath

    if (-not (Test-Path -LiteralPath $projectFile -PathType Leaf)) {
        throw "Configured project file does not exist: $projectFile"
    }

    if (-not (Test-Path -LiteralPath $msbuildPath -PathType Leaf)) {
        throw "Configured MSBuild executable does not exist: $msbuildPath"
    }

    $solutionDir = $repoRoot.TrimEnd('\') + '\'

    Write-Output "Running MSBuild for $projectPathRel"
    & $msbuildPath $projectFile /restore /t:Build "/p:SolutionDir=$solutionDir" /p:RestorePackagesConfig=true /p:Configuration=Release /p:Platform=AnyCPU

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }

    if (-not (Test-Path -LiteralPath $contentPackScript -PathType Leaf)) {
        Write-Warning "Content pack script not found. Skipping frontend packaging: $contentPackScript"
        exit 0
    }

    & $contentPackScript

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}