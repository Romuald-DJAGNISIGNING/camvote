param(
  [switch]$SkipInstall = $false
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

$NpmCmd = Resolve-ToolPath @('npm.cmd', 'npm') "Install Node.js"
$NpxCmd = Resolve-ToolPath @('npx.cmd', 'npx') "Install Node.js"
$WranglerCmd = Resolve-ToolPath @('wrangler.cmd', 'wrangler') "Install wrangler: npm i -g wrangler" -Optional

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
Run-Wrangler
Pop-Location
