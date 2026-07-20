[CmdletBinding()]
param(
    [switch]$DryRun,
    [string]$MetadataFile,
    [ValidateSet("auto", "codex", "claude", "generic")]
    [string]$Agent = "auto",
    [string]$ResultFile
)

$ErrorActionPreference = "Stop"
$MetadataUrl = "https://github.com/Lijinzh/Communist-Manifesto-Releases/releases/latest/download/latest.json"
$ReleasePathPattern = '^/Lijinzh/Communist-Manifesto-Releases/releases/[^/]+/download/[^/?#]+$'
$RequiredAgentBridgeVersion = 1
$TempRoot = Join-Path ([IO.Path]::GetTempPath()) ("autoclipboard-bootstrap-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $TempRoot | Out-Null

function Write-BootstrapResult {
    param([bool]$Success, [string]$Status, [string]$Message, [string]$Executable = "")
    if (-not $ResultFile) { return }
    $parent = Split-Path -Parent $ResultFile
    if ($parent) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    [ordered]@{
        schema_version = 1
        success = $Success
        status = $Status
        agent = $Agent
        message = $Message
        executable = $Executable
    } | ConvertTo-Json | Set-Content -LiteralPath $ResultFile -Encoding utf8
}

function Find-AutoClipboardExecutable {
    $command = Get-Command auto-clipboard -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    $candidates = @()
    $locations = @(
        @{ Root = $env:ProgramFiles; Relative = "Auto Clipboard/AutoClipboard.exe" },
        @{ Root = ${env:ProgramFiles(x86)}; Relative = "Auto Clipboard/AutoClipboard.exe" },
        @{ Root = $env:LOCALAPPDATA; Relative = "Programs/Auto Clipboard/AutoClipboard.exe" }
    )
    foreach ($location in $locations) {
        if (-not [string]::IsNullOrWhiteSpace([string]$location.Root)) {
            $candidates += Join-Path ([string]$location.Root) ([string]$location.Relative)
        }
    }
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate -PathType Leaf)) { return $candidate }
    }
    return $null
}

function Get-ProbeTimeoutSeconds {
    $value = $env:AUTOCLIPBOARD_BOOTSTRAP_PROBE_TIMEOUT_SECONDS
    $parsed = 0
    if ($value -and [int]::TryParse($value, [ref]$parsed) -and $parsed -gt 0) { return $parsed }
    return 30
}

function Test-SafePackageName {
    param([string]$Package)
    if ([string]::IsNullOrWhiteSpace($Package) -or $Package -in @(".", "..")) { return $false }
    if ($Package.Contains("/") -or $Package.Contains('\')) { return $false }
    return [IO.Path]::GetFileName($Package) -eq $Package
}

function ConvertTo-SafeSemVer {
    param([string]$Version, [string]$Name)
    $pattern = '^(?:v)?(?<major>0|[1-9][0-9]*)\.(?<minor>0|[1-9][0-9]*)\.(?<patch>0|[1-9][0-9]*)(?:-(?<prerelease>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$'
    $match = [regex]::Match($Version, $pattern)
    if (-not $match.Success) { throw "$Name is not valid SemVer: $Version" }
    $prerelease = [string]$match.Groups["prerelease"].Value
    if ($prerelease) {
        foreach ($identifier in $prerelease.Split('.')) {
            if ($identifier -match '^[0-9]+$' -and $identifier.Length -gt 1 -and $identifier.StartsWith("0")) {
                throw "$Name is not valid SemVer: $Version"
            }
        }
    }
    return [pscustomobject]@{
        Major = [string]$match.Groups["major"].Value
        Minor = [string]$match.Groups["minor"].Value
        Patch = [string]$match.Groups["patch"].Value
        Prerelease = $prerelease
    }
}

function Compare-DecimalString {
    param([string]$Left, [string]$Right)
    if ($Left.Length -lt $Right.Length) { return -1 }
    if ($Left.Length -gt $Right.Length) { return 1 }
    $comparison = [string]::CompareOrdinal($Left, $Right)
    if ($comparison -lt 0) { return -1 }
    if ($comparison -gt 0) { return 1 }
    return 0
}

function Compare-SafeSemVer {
    param($Installed, $Release)
    foreach ($property in @("Major", "Minor", "Patch")) {
        $comparison = Compare-DecimalString ([string]($Installed.$property)) ([string]($Release.$property))
        if ($comparison -ne 0) { return $comparison }
    }
    if (-not $Installed.Prerelease -and -not $Release.Prerelease) { return 0 }
    if (-not $Installed.Prerelease) { return 1 }
    if (-not $Release.Prerelease) { return -1 }
    $installedIdentifiers = @($Installed.Prerelease.Split('.'))
    $releaseIdentifiers = @($Release.Prerelease.Split('.'))
    $limit = [Math]::Min($installedIdentifiers.Count, $releaseIdentifiers.Count)
    for ($index = 0; $index -lt $limit; $index++) {
        $installedIdentifier = [string]$installedIdentifiers[$index]
        $releaseIdentifier = [string]$releaseIdentifiers[$index]
        if ($installedIdentifier -ceq $releaseIdentifier) { continue }
        $installedNumeric = $installedIdentifier -match '^[0-9]+$'
        $releaseNumeric = $releaseIdentifier -match '^[0-9]+$'
        if ($installedNumeric -and $releaseNumeric) {
            return Compare-DecimalString $installedIdentifier $releaseIdentifier
        }
        if ($installedNumeric) { return -1 }
        if ($releaseNumeric) { return 1 }
        $comparison = [string]::CompareOrdinal($installedIdentifier, $releaseIdentifier)
        if ($comparison -lt 0) { return -1 }
        return 1
    }
    if ($installedIdentifiers.Count -lt $releaseIdentifiers.Count) { return -1 }
    if ($installedIdentifiers.Count -gt $releaseIdentifiers.Count) { return 1 }
    return 0
}

function Wait-ForAutoClipboardExecutable {
    param([int]$TimeoutSeconds = 30)
    $deadline = [DateTime]::UtcNow.AddSeconds($TimeoutSeconds)
    do {
        $executable = Find-AutoClipboardExecutable
        if ($executable) { return $executable }
        Start-Sleep -Milliseconds 500
    } while ([DateTime]::UtcNow -lt $deadline)
    return $null
}

function Invoke-BridgeDoctor {
    param([string]$Executable, [string]$OutputPath)
    $bridgeAgent = if ($Agent -eq "generic") { "auto" } else { $Agent }
    Remove-Item -LiteralPath $OutputPath -Force -ErrorAction SilentlyContinue
    $arguments = @("--agent-bridge", "doctor", "--agent", $bridgeAgent, "--result-file", ('"' + $OutputPath + '"'), "--quiet")
    $process = Start-Process -FilePath $Executable -ArgumentList $arguments -PassThru
    if (-not $process.WaitForExit((Get-ProbeTimeoutSeconds) * 1000)) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        $process.WaitForExit()
        return [pscustomobject]@{ ExitCode = 124; HasResult = $false; TimedOut = $true; Result = $null }
    }
    $exitCode = $process.ExitCode
    if (-not (Test-Path -LiteralPath $OutputPath)) {
        return [pscustomobject]@{ ExitCode = $exitCode; HasResult = $false; TimedOut = $false; Result = $null }
    }
    $result = Get-Content -LiteralPath $OutputPath -Raw | ConvertFrom-Json
    return [pscustomobject]@{ ExitCode = $exitCode; HasResult = $true; TimedOut = $false; Result = $result }
}

function Assert-BridgeCorePreflight {
    param($Result)
    foreach ($code in @("hook_executable_available", "platform_poll_supported", "state_directory_writable")) {
        $check = @($Result.checks | Where-Object { [string]$_.code -eq $code } | Select-Object -First 1)
        if ($check.Count -eq 0 -or -not $check[0].ok) {
            throw "doctor core preflight failed: $code"
        }
    }
}

function Test-CodexTrustConfigurationRequired {
    param($Result)
    if (-not $Result -or $Result.success) { return $false }
    foreach ($code in @(
        "hook_executable_available",
        "platform_poll_supported",
        "state_directory_writable",
        "hook_config_readable",
        "hook_events_complete",
        "hook_source_command_absent",
        "hook_executable_matches",
        "hook_trust_probe_available",
        "hook_trust_metadata_complete",
        "hook_runtime_enabled",
        "hook_trust_status_known"
    )) {
        $check = @($Result.checks | Where-Object { [string]$_.code -eq $code } | Select-Object -First 1)
        if ($check.Count -eq 0 -or -not $check[0].ok) { return $false }
    }
    if (@($Result.errors).Count -ne 0) { return $false }
    $failedChecks = @($Result.checks | Where-Object { -not $_.ok })
    return $failedChecks.Count -eq 1 -and [string]$failedChecks[0].code -eq "hook_trust_granted"
}

function Configure-ExistingBridge {
    param([string]$Executable, $ReleaseSemVer, [string]$ReleaseVersion)
    $doctorBefore = Invoke-BridgeDoctor $Executable (Join-Path $TempRoot "doctor-before.json")
    if (-not $doctorBefore.HasResult) {
        Write-Host "Existing executable does not support Agent Bridge v1; upgrade required."
        return $false
    }
    if ([int]$doctorBefore.Result.agent_bridge_version -lt $RequiredAgentBridgeVersion) { return $false }
    $installedVersion = [string]$doctorBefore.Result.app_version
    $installedSemVer = ConvertTo-SafeSemVer $installedVersion "installed app version"
    if ((Compare-SafeSemVer $installedSemVer $ReleaseSemVer) -lt 0) {
        Write-Host "Installed app_version=$installedVersion is older than release $ReleaseVersion; upgrade required."
        return $false
    }
    Write-Host "Skipping download: installed app_version=$installedVersion is not older than release $ReleaseVersion"
    Assert-BridgeCorePreflight $doctorBefore.Result

    if ($Agent -eq "generic") {
        Write-Host "Generic agent selected: native install is not used; configure verified lifecycle hooks with emit."
        Write-BootstrapResult $false "configuration_required" "Configure a verified lifecycle hook to call emit, then run doctor again" $Executable
        return $true
    }
    $installResult = Join-Path $TempRoot "install.json"
    $arguments = @("--agent-bridge", "install", "--agent", $Agent)
    if ($DryRun) { $arguments += "--dry-run" }
    $arguments += @("--result-file", $installResult, "--quiet")
    & $Executable @arguments
    if ($LASTEXITCODE -ne 0) { throw "native install failed" }
    $install = Get-Content -LiteralPath $installResult -Raw | ConvertFrom-Json
    if (-not $install.success) { throw "native install returned an unsuccessful result" }
    if (@($install.changes).Count -eq 0) { throw "native install did not detect any native agent to configure" }

    $doctorAfter = Invoke-BridgeDoctor $Executable (Join-Path $TempRoot "doctor-after.json")
    if ($doctorAfter.ExitCode -ne 0 -or -not $doctorAfter.Result.success) {
        if ($doctorAfter.HasResult -and (Test-CodexTrustConfigurationRequired $doctorAfter.Result)) {
            Write-Host "Codex Hook approval is required before Agent Bridge can become ready."
            Write-BootstrapResult $false "configuration_required" "Review and approve the AutoClipboard Hooks in Codex, then rerun doctor" $Executable
            return $true
        }
        throw "doctor failed after hook configuration"
    }
    Write-BootstrapResult $true "ready" "AutoClipboard Agent Bridge is ready" $Executable
    return $true
}

try {
    if ($MetadataFile -and -not $DryRun) {
        throw "-MetadataFile is only allowed with -DryRun"
    }
    if ($MetadataFile -and -not (Test-Path -LiteralPath $MetadataFile -PathType Leaf)) {
        throw "metadata file does not exist: $MetadataFile"
    }

    $metadataPath = $MetadataFile
    if (-not $metadataPath) {
        $metadataPath = Join-Path $TempRoot "latest.json"
        Invoke-WebRequest -UseBasicParsing -Uri $MetadataUrl -OutFile $metadataPath
    }
    $metadata = Get-Content -LiteralPath $metadataPath -Raw | ConvertFrom-Json
    $asset = $metadata.app.windows
    if (-not $asset) { throw "release metadata is missing app.windows" }
    $releaseVersion = [string]$asset.version
    $releaseSemVer = ConvertTo-SafeSemVer $releaseVersion "release app version"
    if (-not (Test-SafePackageName ([string]$asset.package))) { throw "package must be a plain basename" }
    if (-not ([string]$asset.package).EndsWith(".exe", [StringComparison]::OrdinalIgnoreCase)) {
        throw "selected Windows package must be an .exe"
    }
    if ([string]$asset.sha256 -notmatch '^[0-9a-fA-F]{64}$') { throw "release metadata contains an invalid SHA-256" }
    if ([int64]$asset.size -le 0) { throw "release metadata contains an invalid size" }
    $uri = [Uri]$asset.download_url
    if ($uri.Scheme -ne "https" -or $uri.Host -ne "github.com" -or $uri.AbsolutePath -notmatch $ReleasePathPattern) {
        throw "Release URL is not an approved GitHub Release asset"
    }
    $downloadName = [Uri]::UnescapeDataString(($uri.AbsolutePath -split '/')[-1])
    if (-not [string]::Equals($downloadName, [string]$asset.package, [StringComparison]::Ordinal)) {
        throw "package does not match download URL basename"
    }

    $offlineAssetCheck = $DryRun -and $Agent -eq "generic" -and $MetadataFile
    if (-not $offlineAssetCheck) {
        $existing = Find-AutoClipboardExecutable
        if ($existing -and (Configure-ExistingBridge $existing $releaseSemVer $releaseVersion)) { exit 0 }
    }

    $assetPath = $null
    if ($MetadataFile) {
        $candidate = Join-Path (Split-Path -Parent $MetadataFile) ([string]$asset.package)
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $assetPath = $candidate }
    }
    if (-not $assetPath) {
        $assetPath = Join-Path $TempRoot ([string]$asset.package)
        Invoke-WebRequest -UseBasicParsing -Uri $uri.AbsoluteUri -OutFile $assetPath
    }
    $file = Get-Item -LiteralPath $assetPath
    if ($file.Length -ne [int64]$asset.size) {
        throw "installer size mismatch: expected $($asset.size), got $($file.Length)"
    }
    $actualHash = (Get-FileHash -LiteralPath $assetPath -Algorithm SHA256).Hash
    if ($actualHash -ne ([string]$asset.sha256).ToUpperInvariant()) { throw "installer SHA-256 mismatch" }
    Write-Host "Selected asset: $($asset.package)"

    if ($DryRun) {
        Write-Host "Dry run: run the Inno Setup .exe with silent install switches."
        Write-BootstrapResult $true "verified" "Dry run completed; installer verified"
        exit 0
    }

    $process = Start-Process -FilePath $assetPath -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART", "/SP-" -Verb RunAs -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Inno Setup installer exited with code $($process.ExitCode)" }
    $installed = Wait-ForAutoClipboardExecutable -TimeoutSeconds 30
    if (-not $installed) { throw "AutoClipboard installed, but AutoClipboard.exe was not found" }
    if (-not (Configure-ExistingBridge $installed $releaseSemVer $releaseVersion)) {
        throw "installed Agent Bridge or app version is below the release requirement"
    }
} catch {
    Write-BootstrapResult $false "failed" $_.Exception.Message
    Write-Error $_.Exception.Message
    exit 1
} finally {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force -ErrorAction SilentlyContinue
}
