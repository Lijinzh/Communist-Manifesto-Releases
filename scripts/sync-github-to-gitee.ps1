[CmdletBinding()]
param(
    [switch]$SkipCodePush,
    [switch]$ReplaceExistingAssets,
    [switch]$PruneExtraAssets
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$syncScript = Join-Path $PSScriptRoot 'gitee_release_sync.py'
$uv = (Get-Command uv -ErrorAction Stop).Source

Push-Location $repoRoot
try {
    & $uv run --no-project python scripts/sync_readmes.py --check
    if ($LASTEXITCODE -ne 0) {
        throw "README synchronization check failed with exit code $LASTEXITCODE."
    }

    if (-not $SkipCodePush) {
        $branch = git branch --show-current
        if ($LASTEXITCODE -ne 0 -or $branch -ne 'main') {
            throw 'Run Gitee publishing from the main branch.'
        }
        git push origin main
        if ($LASTEXITCODE -ne 0) {
            throw "GitHub push failed with exit code $LASTEXITCODE."
        }
        git push gitee main
        if ($LASTEXITCODE -ne 0) {
            throw "Gitee code push failed with exit code $LASTEXITCODE."
        }
        git push gitee --tags
        if ($LASTEXITCODE -ne 0) {
            throw "Gitee tag push failed with exit code $LASTEXITCODE."
        }
    }

    $arguments = @($syncScript, 'sync-latest', '--keep-latest-only')
    if ($ReplaceExistingAssets) {
        $arguments += '--replace-existing'
    }
    if ($PruneExtraAssets) {
        $arguments += '--prune'
    }
    & $uv run --no-project python @arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Gitee Release synchronization failed with exit code $LASTEXITCODE."
    }

    & $uv run --no-project python $syncScript verify --latest-only
    if ($LASTEXITCODE -ne 0) {
        throw "Gitee public verification failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}
