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

function Find-CommandPath {
    param([string]$CommandName)

    $command = Get-Command $CommandName -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($null -eq $command) {
        return $null
    }

    return $command.Source
}

function Get-CommandSpec {
    param(
        $CommandValue,
        [string]$SettingName
    )

    if ($null -eq $CommandValue) {
        return $null
    }

    if ($CommandValue -is [string]) {
        if ([string]::IsNullOrWhiteSpace($CommandValue)) {
            return $null
        }

        return @($CommandValue.Trim())
    }

    if ($CommandValue -is [System.Collections.IEnumerable]) {
        $items = @(
            foreach ($item in $CommandValue) {
                $value = [string]$item

                if (-not [string]::IsNullOrWhiteSpace($value)) {
                    $value.Trim()
                }
            }
        )

        if ($items.Count -eq 0) {
            return $null
        }

        return $items
    }

    throw "Invalid $SettingName value. Use a string or an array of command tokens."
}

function Resolve-CommandExecutable {
    param(
        [string[]]$CommandSpec,
        [string]$SettingName
    )

    if ($null -eq $CommandSpec -or $CommandSpec.Count -eq 0) {
        throw "Missing $SettingName command configuration"
    }

    $commandName = $CommandSpec[0]
    $commandPath = Find-CommandPath -CommandName $commandName

    if ([string]::IsNullOrWhiteSpace($commandPath)) {
        throw "Missing command in PATH for ${SettingName}: $commandName"
    }

    return $commandPath
}

function Invoke-CommandSpec {
    param(
        [string[]]$CommandSpec,
        [string]$ExecutablePath,
        [string]$WorkingDir,
        [string]$Label
    )

    $arguments = @()

    if ($CommandSpec.Count -gt 1) {
        $arguments = $CommandSpec[1..($CommandSpec.Count - 1)]
    }

    $workingDirName = Split-Path -Leaf $WorkingDir
    Write-Output "Running $Label in ${workingDirName}: $($CommandSpec -join ' ')"

    & $ExecutablePath @arguments

    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

try {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = [System.IO.Path]::GetFullPath((Join-Path $scriptDir '..\..\..\..'))
    $configFile = Join-Path $repoRoot '.agents/skill-scripts.psd1'

    $config = Get-SkillConfig -ConfigFile $configFile -Purpose 'build-project frontend'
    $frontendPathRel = $config['BUILD_FRONTEND_DIR_PATH']

    if ([string]::IsNullOrWhiteSpace($frontendPathRel)) {
        Write-Output 'BUILD_FRONTEND_DIR_PATH is not configured. Skipping frontend packaging.'
        exit 0
    }

    $frontendDir = Resolve-RepoPath -RepoRoot $repoRoot -PathValue $frontendPathRel

    if (-not (Test-Path -LiteralPath $frontendDir -PathType Container)) {
        throw "Configured frontend directory does not exist: $frontendDir"
    }

    $packageJsonFile = Join-Path $frontendDir 'package.json'

    if (-not (Test-Path -LiteralPath $packageJsonFile -PathType Leaf)) {
        throw "Missing package.json in frontend directory: $packageJsonFile"
    }

    $requiredNodeVersion = $config['BUILD_NODE_VERSION']
    $installCommandSpec = Get-CommandSpec -CommandValue $config['BUILD_FRONTEND_INSTALL_COMMAND'] -SettingName 'BUILD_FRONTEND_INSTALL_COMMAND'
    $buildCommandSpec = Get-CommandSpec -CommandValue $config['BUILD_FRONTEND_BUILD_COMMAND'] -SettingName 'BUILD_FRONTEND_BUILD_COMMAND'

    if ($null -eq $installCommandSpec) {
        $installCommandSpec = @('yarn', 'install')
    }

    if ($null -eq $buildCommandSpec) {
        $buildCommandSpec = @('yarn', 'dev-build')
    }

    $installCommandPath = Resolve-CommandExecutable -CommandSpec $installCommandSpec -SettingName 'BUILD_FRONTEND_INSTALL_COMMAND'
    $buildCommandPath = Resolve-CommandExecutable -CommandSpec $buildCommandSpec -SettingName 'BUILD_FRONTEND_BUILD_COMMAND'

    if (-not [string]::IsNullOrWhiteSpace($requiredNodeVersion)) {
        $nodeCommand = Find-CommandPath -CommandName 'node'

        if ([string]::IsNullOrWhiteSpace($nodeCommand)) {
            $nodeCommand = Find-CommandPath -CommandName 'node.exe'
        }

        if ([string]::IsNullOrWhiteSpace($nodeCommand)) {
            throw 'Missing node command in PATH'
        }

        $nodeCurrentOutput = (& $nodeCommand -v 2>&1 | Out-String).Trim()
        Write-Output "Active Node version: $nodeCurrentOutput"

        if ($nodeCurrentOutput -notlike "*$requiredNodeVersion*") {
            throw "Unexpected Node version. Required: $requiredNodeVersion"
        }
    }

    Push-Location $frontendDir

    try {
        Invoke-CommandSpec -CommandSpec $installCommandSpec -ExecutablePath $installCommandPath -WorkingDir $frontendDir -Label 'frontend install command'
        Invoke-CommandSpec -CommandSpec $buildCommandSpec -ExecutablePath $buildCommandPath -WorkingDir $frontendDir -Label 'frontend build command'
    }
    finally {
        Pop-Location
    }
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}