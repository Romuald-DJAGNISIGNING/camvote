param(
  [string]$ProjectName = "camvote",
  [switch]$SkipBuild = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-Tool($cmd, $hint) {
  if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
    throw "Required tool '$cmd' not found. $hint"
  }
}

Assert-Tool flutter "Install Flutter SDK"
Assert-Tool npm "Install Node.js"

function Warn-Env($path) {
  if (-not (Test-Path $path)) {
    Write-Host "Warning: $path not found. Web build will use defaults." -ForegroundColor Yellow
    return
  }
  $line = Get-Content $path | Where-Object { $_ -match '^CAMVOTE_API_BASE_URL=' } | Select-Object -First 1
  if (-not $line) {
    Write-Host "Warning: CAMVOTE_API_BASE_URL missing in $path." -ForegroundColor Yellow
  }
}

Warn-Env ".env.public"

if (-not $SkipBuild) {
  Write-Host "==> Building web bundle (Flutter)" -ForegroundColor Cyan
  flutter build web --release --no-wasm-dry-run
}

if (-not (Test-Path "build/web")) {
  throw "build/web not found. Run flutter build web first."
}

Write-Host "==> Deploying to Cloudflare Pages ($ProjectName)" -ForegroundColor Cyan
npx wrangler pages deploy build/web --project-name $ProjectName
