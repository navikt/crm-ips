param(
    [string]$ProjectFile = "sfdx-project.json",
    [string]$OutputFile
)

if (-not $OutputFile) {
    [Console]::Error.WriteLine("ERROR: -OutputFile parameter is required.")
    exit 1
}

$json = Get-Content $ProjectFile -Raw | ConvertFrom-Json
$deps = $json.packageDirectories |
    Where-Object { $_.dependencies } |
    ForEach-Object { $_.dependencies } |
    ForEach-Object { $_ }

$aliases = @{}
foreach ($prop in $json.packageAliases.PSObject.Properties) {
    $aliases[$prop.Name] = $prop.Value
}

$noKeyPackages = @{}
if ($json.packageKeyConfig) {
    foreach ($prop in $json.packageKeyConfig.PSObject.Properties) {
        if ($prop.Value -eq $false) { $noKeyPackages[$prop.Name] = $true }
    }
}

$total = ($deps | Measure-Object).Count
$current = 0
$results = [System.Collections.ArrayList]@()

foreach ($dep in $deps) {
    $pkgName = $dep.package
    $current++
    $packageId = $aliases[$pkgName]
    if (-not $packageId) {
        [Console]::Error.WriteLine("       WARNING: No alias found for $pkgName, skipping.")
        continue
    }
    [Console]::Error.WriteLine("       Resolving [$current/$total] $pkgName...")
    try {
        $raw = sf package version list --packages $packageId --released --order-by CreatedDate --json 2>&1
        $jsonText = ($raw | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }) -join "`n"
        $versionJson = $jsonText | ConvertFrom-Json
        $latest = $versionJson.result | Select-Object -Last 1
        if ($latest.SubscriberPackageVersionId) {
            $hasKey = if ($noKeyPackages.ContainsKey($pkgName)) { "NOKEY" } else { "KEY" }
            [Console]::Error.WriteLine("       -> $($latest.SubscriberPackageVersionId) [$hasKey]")
            [void]$results.Add("$pkgName|$($latest.SubscriberPackageVersionId)|$hasKey")
        } else {
            [Console]::Error.WriteLine("       FAILED: No released version for $pkgName")
            exit 1
        }
    } catch {
        [Console]::Error.WriteLine("       FAILED: $pkgName - $_")
        exit 1
    }
}

$results | Set-Content -Path $OutputFile -Encoding UTF8
[Console]::Error.WriteLine("       Resolved $($results.Count) packages -> $OutputFile")