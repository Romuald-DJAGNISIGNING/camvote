param(
  [string]$ApiBaseUrl = "",
  [switch]$SkipPubGet = $false,
  [switch]$SkipValidation = $false,
  [switch]$SkipApk = $false,
  [switch]$SkipAab = $false
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

function Get-DotEnvValue(
  [string]$Path,
  [string]$Key
) {
  if (-not (Test-Path $Path)) {
    return $null
  }

  foreach ($line in Get-Content $Path) {
    if ($line -match "^\s*$Key=(.*)$") {
      return $Matches[1].Trim()
    }
  }

  return $null
}

function Resolve-ConfigValue(
  [string]$Primary,
  [string]$EnvName,
  [string]$Default = ""
) {
  if (-not [string]::IsNullOrWhiteSpace($Primary)) {
    return $Primary
  }

  $envValue = [Environment]::GetEnvironmentVariable($EnvName)
  if (-not [string]::IsNullOrWhiteSpace($envValue)) {
    return $envValue.Trim()
  }

  $dotEnvValue = Get-DotEnvValue -Path ".env" -Key $EnvName
  if (-not [string]::IsNullOrWhiteSpace($dotEnvValue)) {
    return $dotEnvValue
  }

  return $Default
}

$FlutterCmd = Resolve-ToolPath @('flutter.bat', 'flutter') "Install Flutter SDK"
$DartCmd = Resolve-ToolPath @('dart.bat', 'dart') "Install Dart SDK (bundled with Flutter)"

$apiBaseUrl = Resolve-ConfigValue -Primary $ApiBaseUrl -EnvName "CAMVOTE_API_BASE_URL" -Default "https://camvote.romuald-djagnisigning.workers.dev"
$firebaseWebApiKey = Resolve-ConfigValue -Primary "" -EnvName "CAMVOTE_FIREBASE_WEB_API_KEY"
$firebaseAndroidApiKey = Resolve-ConfigValue -Primary "" -EnvName "CAMVOTE_FIREBASE_ANDROID_API_KEY"
$firebaseIosApiKey = Resolve-ConfigValue -Primary "" -EnvName "CAMVOTE_FIREBASE_IOS_API_KEY"

$missingKeys = @()
if ([string]::IsNullOrWhiteSpace($firebaseWebApiKey)) {
  $missingKeys += "CAMVOTE_FIREBASE_WEB_API_KEY"
}
if ([string]::IsNullOrWhiteSpace($firebaseAndroidApiKey)) {
  $missingKeys += "CAMVOTE_FIREBASE_ANDROID_API_KEY"
}
if ([string]::IsNullOrWhiteSpace($firebaseIosApiKey)) {
  $missingKeys += "CAMVOTE_FIREBASE_IOS_API_KEY"
}
if ($missingKeys.Count -gt 0) {
  throw "Missing required Firebase API key values: $($missingKeys -join ', '). Set them in environment variables or .env before release builds."
}

$keyPropsPath = "android/key.properties"
if (-not (Test-Path $keyPropsPath)) {
  throw "Missing $keyPropsPath. Create Android signing config before running this script."
}

$storeFileLine = Get-Content $keyPropsPath | Where-Object { $_ -match '^\s*storeFile\s*=' } | Select-Object -First 1
if (-not $storeFileLine) {
  throw "storeFile entry is missing in $keyPropsPath."
}

$storeFileName = ($storeFileLine -split '=', 2)[1].Trim()
if ([string]::IsNullOrWhiteSpace($storeFileName)) {
  throw "storeFile entry in $keyPropsPath is empty."
}

$keystorePath = Join-Path "android/app" $storeFileName
if (-not (Test-Path $keystorePath)) {
  throw "Keystore file not found at $keystorePath."
}

if (-not $SkipPubGet) {
  Write-Host "==> Installing Flutter dependencies" -ForegroundColor Cyan
  & $FlutterCmd pub get
  Assert-LastExitCode "flutter pub get failed"
}

if (-not $SkipValidation) {
  Write-Host "==> Validating Firebase mobile config consistency" -ForegroundColor Cyan
  & $DartCmd run tools/validate_firebase_mobile_config.dart
  Assert-LastExitCode "Firebase config validation failed"
}

$commonArgs = @(
  "--release",
  "--dart-define=CAMVOTE_API_BASE_URL=$apiBaseUrl",
  "--dart-define=CAMVOTE_FIREBASE_WEB_API_KEY=$firebaseWebApiKey",
  "--dart-define=CAMVOTE_FIREBASE_ANDROID_API_KEY=$firebaseAndroidApiKey",
  "--dart-define=CAMVOTE_FIREBASE_IOS_API_KEY=$firebaseIosApiKey"
)

if (-not $SkipAab) {
  Write-Host "==> Building signed Android App Bundle (.aab)" -ForegroundColor Cyan
  & $FlutterCmd build appbundle @commonArgs
  Assert-LastExitCode "flutter build appbundle failed"
}

if (-not $SkipApk) {
  Write-Host "==> Building signed split APKs" -ForegroundColor Cyan
  & $FlutterCmd build apk @commonArgs --split-per-abi
  Assert-LastExitCode "flutter build apk --split-per-abi failed"
}

$artifacts = @()
$aabPath = "build/app/outputs/bundle/release/app-release.aab"
if (Test-Path $aabPath) {
  $artifacts += (Resolve-Path $aabPath).Path
}
$apkPaths = Get-ChildItem "build/app/outputs/flutter-apk" -Filter "*release*.apk" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName
if ($apkPaths) {
  $artifacts += $apkPaths
}

if ($artifacts.Count -eq 0) {
  throw "No Android release artifacts found after build."
}

$hashLines = foreach ($artifact in $artifacts) {
  $hash = Get-FileHash -Path $artifact -Algorithm SHA256
  "{0}  {1}" -f $hash.Hash.ToLowerInvariant(), $artifact
}

$hashOutPath = "build/mobile-android-sha256.txt"
$hashLines | Set-Content -Path $hashOutPath -Encoding ascii

Write-Host "==> Android release artifacts generated" -ForegroundColor Green
foreach ($artifact in $artifacts) {
  Write-Host " - $artifact"
}
Write-Host " - $((Resolve-Path $hashOutPath).Path)"
