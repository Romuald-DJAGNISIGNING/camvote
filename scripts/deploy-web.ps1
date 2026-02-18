param(
  [string]$ProjectName = "camvote",
  [switch]$SkipBuild = $false,
  [switch]$SkipQualityChecks = $false,
  [switch]$AllowDirty = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ToolPath(
  [string[]]$Candidates,
  [string]$Hint
) {
  foreach ($candidate in $Candidates) {
    $tool = Get-Command $candidate -ErrorAction SilentlyContinue
    if ($tool) {
      return $tool.Source
    }
  }
  throw "Required tool not found ($($Candidates -join ', ')). $Hint"
}

function Assert-LastExitCode([string]$FailureMessage) {
  if ($LASTEXITCODE -ne 0) {
    throw "$FailureMessage (exit code: $LASTEXITCODE)"
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

$FlutterCmd = Resolve-ToolPath @('flutter.bat', 'flutter') "Install Flutter SDK"
$NpxCmd = Resolve-ToolPath @('npx.cmd', 'npx') "Install Node.js"

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

if (-not $AllowDirty) {
  Assert-CleanGitWorktree
}

if (-not $SkipQualityChecks) {
  Write-Host "==> Running Flutter quality checks" -ForegroundColor Cyan
  & $FlutterCmd analyze
  Assert-LastExitCode "flutter analyze failed"
  & $FlutterCmd test
  Assert-LastExitCode "flutter test failed"
}

if (-not $SkipBuild) {
  Write-Host "==> Building web bundle (Flutter)" -ForegroundColor Cyan
  & $FlutterCmd build web --release --no-wasm-dry-run
  Assert-LastExitCode "Flutter web build failed"
}

if (-not (Test-Path "build/web")) {
  throw "build/web not found. Run flutter build web first."
}

Write-Host "==> Deploying to Cloudflare Pages ($ProjectName)" -ForegroundColor Cyan
$commitDirty = if ($AllowDirty) { "true" } else { "false" }
& $NpxCmd wrangler pages deploy build/web --project-name $ProjectName "--commit-dirty=$commitDirty"
Assert-LastExitCode "Cloudflare Pages deploy failed"
