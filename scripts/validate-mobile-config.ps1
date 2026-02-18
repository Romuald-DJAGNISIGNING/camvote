param(
  [switch]$AllowMissingNativeFiles = $false
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

$DartCmd = Resolve-ToolPath @('dart', 'dart.bat') "Install Dart SDK (bundled with Flutter)."

$argsList = @('run', 'tools/validate_firebase_mobile_config.dart')
if ($AllowMissingNativeFiles) {
  $argsList += '--allow-missing-native-files'
}

Write-Host "==> Validating Firebase mobile configuration" -ForegroundColor Cyan
& $DartCmd @argsList
