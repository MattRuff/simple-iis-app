@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Fetch Git SHA Without Git Installed - Demo
:: ============================================================================
:: This utility demonstrates multiple methods to get the real Git SHA
:: even when Git is not installed on the machine (ZIP downloads)
:: ============================================================================

echo.
echo ========================================
echo Fetch Git SHA Without Git - Demo
echo ========================================
echo.

echo 🎯 This demo shows how to get REAL Git SHA without installing Git
echo 📦 Perfect for ZIP downloads and machines without Git
echo.

:: Check if Git is installed (this demo assumes it's NOT)
git --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  Git IS installed on this machine
    echo This demo is for machines WITHOUT Git, but we'll show the methods anyway...
) else (
    echo ✅ Git is NOT installed (perfect for this demo)
)

echo.
echo ================================
echo 🌐 Method 1: GitHub API (REST)
echo ================================
echo.

echo 📋 Fetching latest commit SHA from GitHub API...
echo    Repository: MattRuff/simple-iis-app
echo    Branch: main
echo.

:: Method 1: GitHub API with PowerShell
for /f "delims=" %%i in ('powershell -c "try { $response = Invoke-RestMethod 'https://api.github.com/repos/MattRuff/simple-iis-app/commits/main'; $response.sha } catch { 'API_FAILED' }" 2^>nul') do set API_SHA=%%i

if not "%API_SHA%"=="API_FAILED" if not "%API_SHA%"=="" (
    echo ✅ SUCCESS: %API_SHA%
    echo 🔗 Short SHA: %API_SHA:~0,7%
    
    :: Get additional info from API
    for /f "delims=" %%i in ('powershell -c "try { $r = Invoke-RestMethod 'https://api.github.com/repos/MattRuff/simple-iis-app/commits/main'; $r.commit.message.Split([char]10)[0] } catch { 'Unknown' }" 2^>nul') do set API_MESSAGE=%%i
    for /f "delims=" %%i in ('powershell -c "try { $r = Invoke-RestMethod 'https://api.github.com/repos/MattRuff/simple-iis-app/commits/main'; $r.commit.author.name } catch { 'Unknown' }" 2^>nul') do set API_AUTHOR=%%i
    for /f "delims=" %%i in ('powershell -c "try { $r = Invoke-RestMethod 'https://api.github.com/repos/MattRuff/simple-iis-app/commits/main'; $r.commit.author.date.Substring(0,10) } catch { 'Unknown' }" 2^>nul') do set API_DATE=%%i
    
    echo 💬 Message: !API_MESSAGE!
    echo 👤 Author: !API_AUTHOR!
    echo 📅 Date: !API_DATE!
) else (
    echo ❌ FAILED: Could not fetch from GitHub API
    echo    Possible reasons: No internet, API rate limit, repository private
)

echo.
echo ================================
echo 🌐 Method 2: Raw GitHub Content
echo ================================
echo.

echo 📋 Fetching SHA from GitHub's raw content API...
echo    Endpoint: /repos/MattRuff/simple-iis-app/git/refs/heads/main
echo.

:: Method 2: GitHub refs API
for /f "delims=" %%i in ('powershell -c "try { $response = Invoke-RestMethod 'https://api.github.com/repos/MattRuff/simple-iis-app/git/refs/heads/main'; $response.object.sha } catch { 'REFS_FAILED' }" 2^>nul') do set REFS_SHA=%%i

if not "%REFS_SHA%"=="REFS_FAILED" if not "%REFS_SHA%"=="" (
    echo ✅ SUCCESS: %REFS_SHA%
    echo 🔗 Short SHA: %REFS_SHA:~0,7%
) else (
    echo ❌ FAILED: Could not fetch from GitHub refs API
)

echo.
echo ================================
echo 📄 Method 3: Direct curl (if available)
echo ================================
echo.

echo 📋 Trying curl command (if available)...

curl --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ curl is available, fetching SHA...
    
    :: Method 3: Using curl
    for /f "delims=" %%i in ('curl -s "https://api.github.com/repos/MattRuff/simple-iis-app/commits/main" ^| powershell -c "$input = $input -join ''; ($input | ConvertFrom-Json).sha" 2^>nul') do set CURL_SHA=%%i
    
    if not "%CURL_SHA%"=="" (
        echo ✅ SUCCESS: %CURL_SHA%
        echo 🔗 Short SHA: %CURL_SHA:~0,7%
    ) else (
        echo ❌ FAILED: curl command failed
    )
) else (
    echo ⚠️  curl is not available on this system
    echo    (This is normal on many Windows systems)
)

echo.
echo ================================
echo 🔧 Method 4: PowerShell Download
echo ================================
echo.

echo 📋 Using PowerShell WebClient to download SHA...

:: Method 4: PowerShell WebClient
for /f "delims=" %%i in ('powershell -c "try { $wc = New-Object System.Net.WebClient; $json = $wc.DownloadString('https://api.github.com/repos/MattRuff/simple-iis-app/commits/main'); ($json | ConvertFrom-Json).sha } catch { 'WEBCLIENT_FAILED' }" 2^>nul') do set WC_SHA=%%i

if not "%WC_SHA%"=="WEBCLIENT_FAILED" if not "%WC_SHA%"=="" (
    echo ✅ SUCCESS: %WC_SHA%
    echo 🔗 Short SHA: %WC_SHA:~0,7%
) else (
    echo ❌ FAILED: PowerShell WebClient failed
)

echo.
echo ================================
echo 📊 Results Summary
echo ================================
echo.

echo 🎯 Methods that worked:
if not "%API_SHA%"=="API_FAILED" if not "%API_SHA%"=="" echo    ✅ GitHub API (REST): %API_SHA:~0,7%
if not "%REFS_SHA%"=="REFS_FAILED" if not "%REFS_SHA%"=="" echo    ✅ GitHub Refs API: %REFS_SHA:~0,7%
if not "%CURL_SHA%"=="" echo    ✅ curl: %CURL_SHA:~0,7%
if not "%WC_SHA%"=="WEBCLIENT_FAILED" if not "%WC_SHA%"=="" echo    ✅ PowerShell WebClient: %WC_SHA:~0,7%

echo.
echo 🔍 All SHAs should be identical if successful
echo.

:: Check if any method worked
set FOUND_SHA=false
if not "%API_SHA%"=="API_FAILED" if not "%API_SHA%"=="" set FOUND_SHA=true
if not "%REFS_SHA%"=="REFS_FAILED" if not "%REFS_SHA%"=="" set FOUND_SHA=true
if not "%CURL_SHA%"=="" set FOUND_SHA=true
if not "%WC_SHA%"=="WEBCLIENT_FAILED" if not "%WC_SHA%"=="" set FOUND_SHA=true

if "%FOUND_SHA%"=="true" (
    echo ================================
    echo ✅ SUCCESS: Real SHA Retrieved!
    echo ================================
    echo.
    echo 🎉 Your deployment scripts can now use the REAL Git SHA
    echo    even without Git installed on the machine!
    echo.
    if not "%API_SHA%"=="API_FAILED" if not "%API_SHA%"=="" (
        echo 📋 Recommended SHA to use: %API_SHA%
        echo 🔗 Short version: %API_SHA:~0,7%
        echo 💬 Message: !API_MESSAGE!
    )
) else (
    echo ================================
    echo ❌ All methods failed
    echo ================================
    echo.
    echo 🔍 Possible issues:
    echo    • No internet connection
    echo    • GitHub API rate limiting
    echo    • Corporate firewall blocking GitHub
    echo    • PowerShell execution policy restrictions
    echo.
    echo 💡 In this case, deployment scripts will use fallback values:
    echo    SHA: zip-download-[timestamp]
    echo    Branch: main-download
)

echo.
echo ================================
echo 🚀 How This Works in deploy.bat
echo ================================
echo.
echo When you run deploy-admin.bat on a machine without Git:
echo.
echo 1️⃣  Script detects no .git folder
echo 2️⃣  Attempts to fetch real SHA from GitHub API
echo 3️⃣  If successful: Uses real SHA for Datadog tracking
echo 4️⃣  If failed: Falls back to deployment timestamp SHA
echo 5️⃣  Either way: Deployment succeeds with meaningful tracking data
echo.
echo 🎯 This gives you the BEST of both worlds:
echo    • Real Git SHA when possible
echo    • Reliable fallback when not possible
echo    • No Git installation required
echo.

pause
