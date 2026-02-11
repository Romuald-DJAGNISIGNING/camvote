param(
  [switch]$SkipInstall = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Tool($cmd, $hint) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Required tool '$cmd' not found. $hint"
  }
}

Assert-Tool npm "Install Node.js"

function Run-Wrangler {
  if (Get-Command wrangler -ErrorAction SilentlyContinue) {
    wrangler deploy
    return
  }
  Write-Host "wrangler not found globally; using npx wrangler" -ForegroundColor Yellow
  npx wrangler deploy
}

Write-Host "==> Deploying Cloudflare Worker" -ForegroundColor Cyan
Push-Location cf-worker
if (-not $SkipInstall) {
  npm install --quiet
}
Run-Wrangler
Pop-Location
