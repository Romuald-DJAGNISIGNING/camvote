param(
  [switch]$SkipWebBuild = $false,
  [switch]$SkipWebDeploy = $false,
  [string]$PagesProject = "camvote"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Tool($cmd, $hint) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Required tool '$cmd' not found. $hint"
  }
}

Assert-Tool firebase "Install firebase-tools: npm install -g firebase-tools"
Assert-Tool npm "Install Node.js"
Assert-Tool flutter "Install Flutter SDK"

function Run-Wrangler {
  if (Get-Command wrangler -ErrorAction SilentlyContinue) {
    wrangler deploy
    return
  }
  Write-Host "wrangler not found globally; using npx wrangler" -ForegroundColor Yellow
  npx wrangler deploy
}

Write-Host "==> Deploying Firestore rules/indexes" -ForegroundColor Cyan
firebase deploy --only "firestore:rules,firestore:indexes" --force

Write-Host "==> Auditing scripts/ dependencies" -ForegroundColor Cyan
Push-Location scripts
npm install --quiet
npm audit
Pop-Location

if (-not $SkipWebBuild) {
  Write-Host "==> Building web bundle (Flutter)" -ForegroundColor Cyan
  flutter build web --release --no-wasm-dry-run
}

Write-Host "==> Deploying Cloudflare Worker" -ForegroundColor Cyan
Push-Location cf-worker
npm install --quiet
Run-Wrangler
Pop-Location

if (-not $SkipWebDeploy) {
  Write-Host "==> Deploying Cloudflare Pages ($PagesProject)" -ForegroundColor Cyan
  if (-not (Test-Path "build/web")) {
    throw "build/web not found. Run flutter build web first."
  }
  npx wrangler pages deploy build/web --project-name $PagesProject
}

Write-Host "==> Done" -ForegroundColor Green
Write-Host "Remember to set CAMVOTE_API_BASE_URL to the Worker URL in .env / AppConfig."
