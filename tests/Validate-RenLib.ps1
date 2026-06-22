$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot
$canonicalPath = Join-Path $root 'RenLib.lua'
$betaPath = (Get-ChildItem -LiteralPath $root -File -Filter 'RenLibB*.lua' | Select-Object -First 1).FullName
$testingPath = Join-Path $root 'RenLibTesting.lua'
$showcasePath = Join-Path $root 'Showcase.lua'
$source = Get-Content -LiteralPath $canonicalPath -Raw -Encoding UTF8
$showcase = Get-Content -LiteralPath $showcasePath -Raw -Encoding UTF8

function Assert-RenLib {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "RenLib validation failed: $Message" }
    Write-Host "PASS  $Message"
}

$canonicalHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $canonicalPath).Hash
Assert-RenLib ($canonicalHash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $betaPath).Hash) 'Beta mirrors the canonical runtime'
Assert-RenLib ($canonicalHash -eq (Get-FileHash -Algorithm SHA256 -LiteralPath $testingPath).Hash) 'Testing mirrors the canonical runtime'
Assert-RenLib ($source.Contains('Library.Version = "7.0.0"')) 'Runtime reports V7.0.0'

$pageVisibilityWrites = [regex]::Matches($source, '(?m)\bPage\.Visible\s*=').Count
Assert-RenLib ($pageVisibilityWrites -eq 1) 'Only the navigation controller writes page visibility'

$searchStart = $source.IndexOf('-- GLOBAL SEARCH:')
$searchEnd = $source.IndexOf('function Library:Notify', $searchStart)
Assert-RenLib ($searchStart -ge 0 -and $searchEnd -gt $searchStart) 'Search controller boundaries are discoverable'
$searchSource = $source.Substring($searchStart, $searchEnd - $searchStart)
Assert-RenLib (-not [regex]::IsMatch($searchSource, '(TabBtn|SectionFrame|Holder)\.Visible\s*=')) 'Search does not own structural visibility'

$requiredApis = @(
    'function Window:SelectTab', 'function Window:RefreshSearch', 'function Window:Prompt',
    'function Window:ShowKeybindManager', 'function Section:CreateGroup', 'function Section:CreateList',
    'function Section:CreateTable', 'function Section:CreatePlayerList',
    'function Section:CreateLogConsole', 'function Section:CreateSkeleton',
    'function Library:RegisterAddon', 'function Library:RegisterIcon'
)
foreach ($api in $requiredApis) {
    Assert-RenLib ($source.Contains($api)) "API exists: $api"
}

$showcaseApis = @('CreateGroup', 'CreateList', 'CreateTable', 'CreatePlayerList', 'CreateLogConsole', 'CreateSkeleton', 'Window:Prompt')
foreach ($api in $showcaseApis) {
    Assert-RenLib ($showcase.Contains($api)) "Showcase demonstrates: $api"
}

Write-Host 'RenLib static validation passed.'
