# Simple IIS App - Automated IIS Setup Script
# Run this on your Windows Server as Administrator

Write-Host "================================" -ForegroundColor Cyan
Write-Host "  Simple IIS App - Server Setup" -ForegroundColor Cyan  
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "❌ This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "   Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Enable IIS Features
Write-Host "[1/4] Enabling IIS Features..." -ForegroundColor Yellow
try {
    $features = @(
        "IIS-WebServerRole",
        "IIS-WebServer", 
        "IIS-CommonHttpFeatures",
        "IIS-HttpErrors",
        "IIS-HttpRedirect",
        "IIS-ApplicationDevelopment",
        "IIS-NetFxExtensibility45",
        "IIS-HealthAndDiagnostics",
        "IIS-HttpLogging",
        "IIS-Security",
        "IIS-RequestFiltering",
        "IIS-Performance",
        "IIS-WebServerManagementTools",
        "IIS-ManagementConsole",
        "IIS-IIS6ManagementCompatibility",
        "IIS-Metabase"
    )
    
    foreach ($feature in $features) {
        Enable-WindowsOptionalFeature -Online -FeatureName $feature -All -NoRestart | Out-Null
    }
    Write-Host "     ✓ IIS Features enabled" -ForegroundColor Green
} catch {
    Write-Host "     ❌ Failed to enable IIS features: $_" -ForegroundColor Red
}

# Step 2: Check .NET 9.0 Runtime
Write-Host ""
Write-Host "[2/4] Checking .NET 9.0 Runtime..." -ForegroundColor Yellow
try {
    $dotnetInfo = dotnet --info 2>$null
    if ($dotnetInfo -and ($dotnetInfo -match "9\.")) {
        Write-Host "     ✓ .NET 9.0 Runtime found" -ForegroundColor Green
    } else {
        Write-Host "     ⚠️  .NET 9.0 Runtime not found" -ForegroundColor Yellow
        Write-Host "     Please install from: https://dotnet.microsoft.com/en-us/download/dotnet/9.0" -ForegroundColor Cyan
    }
} catch {
    Write-Host "     ⚠️  .NET not found or not in PATH" -ForegroundColor Yellow
    Write-Host "     Please install .NET 9.0 Runtime from: https://dotnet.microsoft.com/en-us/download/dotnet/9.0" -ForegroundColor Cyan
}

# Step 3: Check ASP.NET Core Module
Write-Host ""
Write-Host "[3/4] Checking ASP.NET Core Module..." -ForegroundColor Yellow
try {
    Import-Module IISAdministration -ErrorAction SilentlyContinue
    $modules = Get-IISConfigSection -SectionPath "system.webServer/modules" | Get-IISConfigElement -ChildElementName "add" | Where-Object {$_.name -like "*AspNetCore*"}
    if ($modules) {
        Write-Host "     ✓ ASP.NET Core Module found" -ForegroundColor Green
    } else {
        Write-Host "     ⚠️  ASP.NET Core Module not found" -ForegroundColor Yellow
        Write-Host "     Please install ASP.NET Core Module V2 (comes with .NET Runtime)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "     ⚠️  Could not check ASP.NET Core Module" -ForegroundColor Yellow
}

# Step 4: Create Application Pool
Write-Host ""
Write-Host "[4/4] Creating Application Pool..." -ForegroundColor Yellow
try {
    Import-Module WebAdministration -ErrorAction SilentlyContinue
    $poolName = "SimpleIISAppPool"
    
    if (Get-IISAppPool -Name $poolName -ErrorAction SilentlyContinue) {
        Write-Host "     ⚠️  Application pool '$poolName' already exists" -ForegroundColor Yellow
    } else {
        New-WebAppPool -Name $poolName
        Set-ItemProperty -Path "IIS:\AppPools\$poolName" -Name processModel.identityType -Value ApplicationPoolIdentity
        Set-ItemProperty -Path "IIS:\AppPools\$poolName" -Name managedRuntimeVersion -Value ""
        Write-Host "     ✓ Application pool '$poolName' created" -ForegroundColor Green
    }
} catch {
    Write-Host "     ❌ Failed to create application pool: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "        Setup Complete!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Copy your published app to: C:\inetpub\wwwroot\SimpleIISApp\" -ForegroundColor Cyan
Write-Host "2. Create IIS site in IIS Manager pointing to that folder" -ForegroundColor Cyan
Write-Host "3. Assign the 'SimpleIISAppPool' application pool to your site" -ForegroundColor Cyan
Write-Host "4. Test by browsing to your site!" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you need to install missing components:" -ForegroundColor Yellow
Write-Host "• .NET 9.0 Runtime: https://dotnet.microsoft.com/en-us/download/dotnet/9.0" -ForegroundColor Gray
Write-Host "• ASP.NET Core Module: Included with runtime" -ForegroundColor Gray
Write-Host ""

pause
