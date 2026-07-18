param(
    [switch]$NoBackup,
    [switch]$SkipValidation
)

$ErrorActionPreference = "Stop"

$sourceRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $sourceRoot
$moduleRoot = Join-Path $sourceRoot "Modules"
$manifestPath = Join-Path $sourceRoot "modules.manifest"
$temporaryBundle = Join-Path $repoRoot ".renlib-build.tmp.lua"
$betaFileName = "RenLibB" + [char]0x00EA + "ta.lua"
$outputs = @(
    (Join-Path $repoRoot "RenLib.lua"),
    (Join-Path $repoRoot $betaFileName)
)

if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Missing module manifest: $manifestPath"
}

$moduleNames = @(
    Get-Content -LiteralPath $manifestPath -Encoding utf8 |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ -ne "" -and -not $_.StartsWith("#") }
)

if ($moduleNames.Count -lt 1) {
    throw "The module manifest is empty."
}

$builder = New-Object Text.StringBuilder
[void]$builder.AppendLine("-- GENERATED FILE: edit RenLibSource/Modules, then run Build-RenLib.ps1")
[void]$builder.AppendLine("-- Module count: $($moduleNames.Count)")

foreach ($moduleName in $moduleNames) {
    $modulePath = Join-Path $moduleRoot $moduleName
    if (-not (Test-Path -LiteralPath $modulePath)) {
        throw "Manifest module does not exist: $modulePath"
    }

    [void]$builder.AppendLine("")
    [void]$builder.AppendLine("--[[ MODULE: $moduleName ]]")
    $moduleContent = Get-Content -LiteralPath $modulePath -Raw -Encoding utf8
    [void]$builder.Append($moduleContent)
    if (-not $moduleContent.EndsWith("`n")) {
        [void]$builder.AppendLine("")
    }
}

$bundle = $builder.ToString()
if ($bundle -notmatch "(?m)^return Library\s*$") {
    throw "Safety check failed: the assembled bundle does not return Library."
}

$utf8NoBom = New-Object Text.UTF8Encoding($false)
[IO.File]::WriteAllText($temporaryBundle, $bundle, $utf8NoBom)

if (-not $SkipValidation) {
    $compiler = Get-Command luau-compile -ErrorAction SilentlyContinue
    if ($compiler) {
        & $compiler.Source --null $temporaryBundle
        if ($LASTEXITCODE -ne 0) {
            Remove-Item -LiteralPath $temporaryBundle -Force
            throw "Luau compilation failed; existing bundles were preserved."
        }
    } else {
        Write-Warning "luau-compile was not found; structural checks passed, compiler validation was skipped."
    }
}

if (-not $NoBackup) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupRoot = Join-Path $repoRoot "Backups\Builds\$timestamp"
    New-Item -ItemType Directory -Path $backupRoot -Force | Out-Null
    foreach ($output in $outputs) {
        if (Test-Path -LiteralPath $output) {
            Copy-Item -LiteralPath $output -Destination (Join-Path $backupRoot (Split-Path -Leaf $output))
        }
    }
}

foreach ($output in $outputs) {
    Copy-Item -LiteralPath $temporaryBundle -Destination $output -Force
}
Remove-Item -LiteralPath $temporaryBundle -Force

$hash = (Get-FileHash -LiteralPath $outputs[0] -Algorithm SHA256).Hash
Write-Host "Built $($moduleNames.Count) modules into RenLib.lua and $betaFileName"
Write-Host "SHA256: $hash"
