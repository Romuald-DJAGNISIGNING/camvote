param(
  [switch]$SkipWebBuild = $false,
  [switch]$SkipWebDeploy = $false,
  [string]$PagesProject = "camvote"
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

$FirebaseCmd = Resolve-ToolPath @('firebase.cmd', 'firebase') "Install firebase-tools: npm install -g firebase-tools"
$NpmCmd = Resolve-ToolPath @('npm.cmd', 'npm') "Install Node.js"
$NpxCmd = Resolve-ToolPath @('npx.cmd', 'npx') "Install Node.js"
$FlutterCmd = Resolve-ToolPath @('flutter.bat', 'flutter') "Install Flutter SDK"
$WranglerCmd = Resolve-ToolPath @('wrangler.cmd', 'wrangler') "Install wrangler: npm i -g wrangler" -Optional

function Run-Wrangler {
  if ($WranglerCmd) {
    & $WranglerCmd deploy
    return
  }
  Write-Host "wrangler not found globally; using npx wrangler" -ForegroundColor Yellow
  & $NpxCmd wrangler deploy
}

Write-Host "==> Deploying Firestore rules/indexes" -ForegroundColor Cyan
& $FirebaseCmd deploy --only "firestore:rules,firestore:indexes" --force

Write-Host "==> Auditing scripts/ dependencies" -ForegroundColor Cyan
Push-Location scripts
& $NpmCmd install --quiet
& $NpmCmd audit
Pop-Location

if (-not $SkipWebBuild) {
  Write-Host "==> Building web bundle (Flutter)" -ForegroundColor Cyan
  & $FlutterCmd build web --release --no-wasm-dry-run
}

Write-Host "==> Deploying Cloudflare Worker" -ForegroundColor Cyan
Push-Location cf-worker
& $NpmCmd install --quiet
Run-Wrangler
Pop-Location

if (-not $SkipWebDeploy) {
  Write-Host "==> Deploying Cloudflare Pages ($PagesProject)" -ForegroundColor Cyan
  if (-not (Test-Path "build/web")) {
    throw "build/web not found. Run flutter build web first."
  }
  & $NpxCmd wrangler pages deploy build/web --project-name $PagesProject
}

Write-Host "==> Done" -ForegroundColor Green
Write-Host "Remember to set CAMVOTE_API_BASE_URL to the Worker URL in .env / AppConfig."
