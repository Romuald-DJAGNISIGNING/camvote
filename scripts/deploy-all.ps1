param(
  [switch]$SkipWebBuild = $false,
  [switch]$SkipWebDeploy = $false,
  [switch]$SkipQualityChecks = $false,
  [switch]$AllowDirty = $false,
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

$FirebaseCmd = Resolve-ToolPath @('firebase.cmd', 'firebase') "Install firebase-tools: npm install -g firebase-tools"
$NpmCmd = Resolve-ToolPath @('npm.cmd', 'npm') "Install Node.js"
$NpxCmd = Resolve-ToolPath @('npx.cmd', 'npx') "Install Node.js"
$FlutterCmd = Resolve-ToolPath @('flutter.bat', 'flutter') "Install Flutter SDK"
$WranglerCmd = Resolve-ToolPath @('wrangler.cmd', 'wrangler') "Install wrangler: npm i -g wrangler" -Optional

if (-not $AllowDirty) {
  Assert-CleanGitWorktree
}

function Resolve-FirebaseCredentialsPath {
  $candidates = @()
  if (-not [string]::IsNullOrWhiteSpace($env:GOOGLE_APPLICATION_CREDENTIALS)) {
    $candidates += $env:GOOGLE_APPLICATION_CREDENTIALS
  }
  $repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  $candidates += @(
    (Join-Path $repoRoot 'service-account.json'),
    (Join-Path $repoRoot 'firebase-service-account.json')
  )

  foreach ($candidate in $candidates) {
    if ([string]::IsNullOrWhiteSpace($candidate)) {
      continue
    }
    if (Test-Path $candidate) {
      return (Resolve-Path $candidate).Path
    }
  }
  return $null
}

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

$firebaseCredentials = Resolve-FirebaseCredentialsPath
if (-not $firebaseCredentials) {
  throw "Firebase deploy requires a service-account key. Set GOOGLE_APPLICATION_CREDENTIALS or add service-account.json at repo root."
}
$env:GOOGLE_APPLICATION_CREDENTIALS = $firebaseCredentials
if (-not [string]::IsNullOrWhiteSpace($env:FIREBASE_TOKEN)) {
  Write-Host "Ignoring deprecated FIREBASE_TOKEN; using GOOGLE_APPLICATION_CREDENTIALS." -ForegroundColor Yellow
  Remove-Item Env:FIREBASE_TOKEN -ErrorAction SilentlyContinue
}
Assert-EnvValue -Name "CLOUDFLARE_API_TOKEN" -HelpMessage "Set a scoped token before deploy (and optionally CLOUDFLARE_ACCOUNT_ID)."

Write-Host "==> Deploying Firestore rules/indexes" -ForegroundColor Cyan
& $FirebaseCmd deploy --only "firestore:rules,firestore:indexes" --force
Assert-LastExitCode "Firebase Firestore deploy failed"

Write-Host "==> Auditing scripts/ dependencies" -ForegroundColor Cyan
Push-Location scripts
& $NpmCmd install --quiet
Assert-LastExitCode "scripts npm install failed"
& $NpmCmd audit
Assert-LastExitCode "scripts npm audit failed"
Pop-Location

if (-not $SkipQualityChecks) {
  Write-Host "==> Running Flutter quality checks" -ForegroundColor Cyan
  & $FlutterCmd analyze
  Assert-LastExitCode "flutter analyze failed"
  & $FlutterCmd test
  Assert-LastExitCode "flutter test failed"
}

if (-not $SkipWebBuild) {
  Write-Host "==> Building web bundle (Flutter)" -ForegroundColor Cyan
  & $FlutterCmd build web --release --no-wasm-dry-run
  Assert-LastExitCode "Flutter web build failed"
}

Write-Host "==> Deploying Cloudflare Worker" -ForegroundColor Cyan
Push-Location cf-worker
& $NpmCmd install --quiet
Assert-LastExitCode "cf-worker npm install failed"
if (-not $SkipQualityChecks) {
  & $NpmCmd run lint
  Assert-LastExitCode "cf-worker lint failed"
}
Run-Wrangler
Pop-Location

if (-not $SkipWebDeploy) {
  Write-Host "==> Deploying Cloudflare Pages ($PagesProject)" -ForegroundColor Cyan
  if (-not (Test-Path "build/web")) {
    throw "build/web not found. Run flutter build web first."
  }
  $commitDirty = if ($AllowDirty) { "true" } else { "false" }
  & $NpxCmd wrangler pages deploy build/web --project-name $PagesProject "--commit-dirty=$commitDirty"
  Assert-LastExitCode "Cloudflare Pages deploy failed"
}

Write-Host "==> Done" -ForegroundColor Green
Write-Host "Remember to set CAMVOTE_API_BASE_URL to the Worker URL in .env / AppConfig."
