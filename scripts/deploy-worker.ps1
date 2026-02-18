param(
  [switch]$SkipInstall = $false,
  [switch]$SkipLint = $false,
  [switch]$AllowDirty = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ToolPath(
  [string[]]$Candidates,
  [string]$Hint,
  [switch]$Optional = $false
) {
  foreach ($candidate in $Candidates) {
    $tool = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($tool) {
      return $tool.Source
    }
  }
  if ($Optional) {
    return $null
  }
  throw "Required tool not found ($($Candidates -join ', ')). $Hint"
}

function Assert-LastExitCode([string]$FailureMessage) {
  if ($LASTEXITCODE -ne 0) {
    throw "$FailureMessage (exit code: $LASTEXITCODE)"
  }
}

function Assert-EnvValue(
  [string]$Name,
  [string]$HelpMessage
) {
  $value = [Environment]::GetEnvironmentVariable($Name)
  if ([string]::IsNullOrWhiteSpace($value)) {
    throw "Missing required environment variable '$Name'. $HelpMessage"
  }
}

function Assert-CleanGitWorktree {
  $gitStatus = git status --porcelain
  if ($LASTEXITCODE -ne 0) {
    throw "Unable to determine git worktree status."
  }
  if (-not [string]::IsNullOrWhiteSpace($gitStatus)) {
    throw "Working tree is dirty. Commit or stash changes, or pass -AllowDirty."
  }
}

$NpmCmd = Resolve-ToolPath @('npm.cmd', 'npm') "Install Node.js"
$NpxCmd = Resolve-ToolPath @('npx.cmd', 'npx') "Install Node.js"
$WranglerCmd = Resolve-ToolPath @('wrangler.cmd', 'wrangler') "Install wrangler: npm i -g wrangler" -Optional

if (-not $AllowDirty) {
  Assert-CleanGitWorktree
}
Assert-EnvValue -Name "CLOUDFLARE_API_TOKEN" -HelpMessage "Set a scoped token before deploy (and optionally CLOUDFLARE_ACCOUNT_ID)."

function Run-Wrangler {
  if ($WranglerCmd) {
    & $WranglerCmd deploy
    Assert-LastExitCode "Cloudflare Worker deploy failed"
    return
  }
  Write-Host "wrangler not found globally; using npx wrangler" -ForegroundColor Yellow
  & $NpxCmd wrangler deploy
  Assert-LastExitCode "Cloudflare Worker deploy failed"
}

Write-Host "==> Deploying Cloudflare Worker" -ForegroundColor Cyan
Push-Location cf-worker
if (-not $SkipInstall) {
  & $NpmCmd install --quiet
  Assert-LastExitCode "cf-worker npm install failed"
}
if (-not $SkipLint) {
  & $NpmCmd run lint
  Assert-LastExitCode "cf-worker lint failed"
}
Run-Wrangler
Pop-Location
