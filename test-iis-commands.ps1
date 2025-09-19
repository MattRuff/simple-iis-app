# Test script to verify IIS PowerShell commands work
# Run this manually to test if the IIS commands will work in the batch files

Write-Host "🧪 Testing IIS PowerShell Commands..." -ForegroundColor Cyan
Write-Host ""

try {
    Write-Host "1. Testing WebAdministration module..." -ForegroundColor Yellow
    Import-Module WebAdministration -ErrorAction Stop
    Write-Host "   ✅ WebAdministration module loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "   ❌ WebAdministration module failed to load: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   ⚠️  This means IIS is not installed or not properly configured" -ForegroundColor Yellow
    exit 1
}

try {
    Write-Host "2. Testing Get-WebAppPool command..." -ForegroundColor Yellow
    $pools = Get-WebAppPool -ErrorAction Stop
    Write-Host "   ✅ Get-WebAppPool works. Found $($pools.Count) application pools" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Get-WebAppPool failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "3. Testing Get-Website command..." -ForegroundColor Yellow
    $sites = Get-Website -ErrorAction Stop
    Write-Host "   ✅ Get-Website works. Found $($sites.Count) websites" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Get-Website failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "4. Testing Stop-WebAppPool command (on DefaultAppPool)..." -ForegroundColor Yellow
    $pool = Get-WebAppPool -Name "DefaultAppPool" -ErrorAction SilentlyContinue
    if ($pool) {
        Stop-WebAppPool -Name "DefaultAppPool" -ErrorAction Stop
        Write-Host "   ✅ Stop-WebAppPool works (DefaultAppPool stopped)" -ForegroundColor Green
        
        # Start it back up
        Start-WebAppPool -Name "DefaultAppPool" -ErrorAction SilentlyContinue
        Write-Host "   ✅ DefaultAppPool restarted" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  DefaultAppPool not found - testing with available pools" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Stop-WebAppPool failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    Write-Host "5. Testing SimpleIISApp existence check..." -ForegroundColor Yellow
    $existingPool = Get-WebAppPool -Name "SimpleIISApp" -ErrorAction SilentlyContinue
    $existingSite = Get-Website -Name "SimpleIISApp" -ErrorAction SilentlyContinue
    
    if ($existingPool) {
        Write-Host "   ℹ️  SimpleIISApp application pool already exists" -ForegroundColor Blue
    } else {
        Write-Host "   ℹ️  SimpleIISApp application pool does not exist (will be created)" -ForegroundColor Blue
    }
    
    if ($existingSite) {
        Write-Host "   ℹ️  SimpleIISApp website already exists" -ForegroundColor Blue
    } else {
        Write-Host "   ℹ️  SimpleIISApp website does not exist (will be created)" -ForegroundColor Blue
    }
} catch {
    Write-Host "   ❌ SimpleIISApp check failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 Test Summary:" -ForegroundColor Cyan
Write-Host "   If all commands show ✅, the deployment batch files should work properly" -ForegroundColor Green
Write-Host "   If any commands show ❌, there may be IIS configuration issues" -ForegroundColor Yellow
Write-Host ""
Write-Host "💡 To run this test manually:" -ForegroundColor Cyan
Write-Host "   1. Open PowerShell as Administrator" -ForegroundColor White
Write-Host "   2. Run: .\test-iis-commands.ps1" -ForegroundColor White
Write-Host ""
