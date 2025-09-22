@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Universal Deployment Script
:: ============================================================================
:: This script works on any clean Windows environment after downloading ZIP
:: Requirements: .NET 9.0 SDK + IIS installed + Run as Administrator
:: ============================================================================

echo.
echo ================================
echo  Simple IIS App - Deployment
echo ================================
echo.

:: Check for administrator privileges
echo [1/9] Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ REQUIRES ADMINISTRATOR PRIVILEGES!
    echo.
    echo   Right-click this file and select "Run as administrator"
    echo.
    echo Exiting in 10 seconds...
    timeout /t 10 >nul
    exit /b 1
)
echo ✅ Running as Administrator
echo.

:: Check if we're in the right directory
echo [2/9] Verifying project structure...
if not exist "simple-iis-app.csproj" (
    echo ❌ FATAL ERROR: simple-iis-app.csproj not found!
    echo.
    echo 🔍 Current directory: %CD%
    echo.
    echo Make sure you:
    echo 1. Downloaded the ZIP file from GitHub
    echo 2. Extracted it completely 
    echo 3. Are running this script from inside the project folder
    echo.
    echo Exiting in 10 seconds...
    timeout /t 10 >nul
    exit /b 1
)
echo ✅ Project structure verified
echo.

:: Fix any namespace issues from GitHub download
echo [3/9] Auto-fixing GitHub download namespace issues...

:: Fix Views\_ViewImports.cshtml
if exist "Views\_ViewImports.cshtml" (
    findstr /C:"SimpleIISApp" "Views\_ViewImports.cshtml" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing Views\_ViewImports.cshtml namespace...
        powershell -Command "(Get-Content 'Views\_ViewImports.cshtml') -replace 'SimpleIISApp', 'simple_iis_app' | Set-Content 'Views\_ViewImports.cshtml'" 2>nul
        echo   ✓ Fixed Views\_ViewImports.cshtml
    ) else (
        echo   ✓ Views\_ViewImports.cshtml already correct
    )
) else (
    echo   ⚠️ Views\_ViewImports.cshtml not found
)

:: Fix GlobalUsings.cs comment
if exist "GlobalUsings.cs" (
    findstr /C:"SimpleIISApp" "GlobalUsings.cs" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing GlobalUsings.cs comment...
        powershell -Command "(Get-Content 'GlobalUsings.cs') -replace 'SimpleIISApp', 'simple-iis-app' | Set-Content 'GlobalUsings.cs'" 2>nul
        echo   ✓ Fixed GlobalUsings.cs
    ) else (
        echo   ✓ GlobalUsings.cs already correct
    )
)

:: Fix launchSettings.json
if exist "Properties\launchSettings.json" (
    findstr /C:"SimpleIISApp" "Properties\launchSettings.json" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing Properties\launchSettings.json...
        powershell -Command "(Get-Content 'Properties\launchSettings.json') -replace '\"SimpleIISApp\":', '\"simple-iis-app\":' | Set-Content 'Properties\launchSettings.json'" 2>nul
        echo   ✓ Fixed launchSettings.json
    ) else (
        echo   ✓ launchSettings.json already correct
    )
)

echo ✅ Namespace fixes completed
echo.

:: Check .NET installation
echo [4/9] Checking .NET 9.0 SDK...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET SDK not found!
    echo.
    echo   Download and install .NET 9.0 SDK from:
    echo   https://dotnet.microsoft.com/download/dotnet/9.0
    echo.
    echo Exiting in 15 seconds...
    timeout /t 15 >nul
    exit /b 1
)

for /f %%i in ('dotnet --version 2^>nul') do set DOTNET_VERSION=%%i
echo ✅ .NET version: %DOTNET_VERSION%
echo.

:: Check IIS installation
echo [5/9] Checking IIS installation...
if not exist "C:\inetpub\wwwroot" (
    echo ❌ IIS not found!
    echo.
    echo   Please install IIS using:
    echo   1. Control Panel → Programs → Turn Windows features on/off
    echo   2. Check "Internet Information Services"
    echo   3. Check "IIS Management Console"
    echo   4. Check "ASP.NET Core Module V2"
    echo.
    echo Exiting in 15 seconds...
    timeout /t 15 >nul
    exit /b 1
)
echo ✅ IIS installation verified
echo.

:: Set deployment environment variables
echo [6/9] Setting deployment environment...
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
if "%timestamp%"=="" set "timestamp=deploy_%RANDOM%"

set DD_GIT_COMMIT_SHA=zip-deploy-%timestamp%
set DD_GIT_COMMIT_SHA_SHORT=zip-%RANDOM%
set DD_GIT_BRANCH=main-zip
set DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git
set DD_GIT_COMMIT_MESSAGE=ZIP deployment on %COMPUTERNAME% at %date% %time%
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%
echo ✅ Environment configured
echo.

:: Clean and prepare for build
echo [7/9] Preparing build environment...
if exist "bin" rmdir /s /q "bin" 2>nul
if exist "obj" rmdir /s /q "obj" 2>nul
if exist "logs" rmdir /s /q "logs" 2>nul

:: Clean IIS environment
if exist "C:\inetpub\wwwroot\simple-iis-app" (
    rmdir /s /q "C:\inetpub\wwwroot\simple-iis-app" 2>nul
)

:: Create IIS directory
mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
if not exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo ❌ Cannot create IIS directory!
    echo   Ensure you're running as Administrator
    echo.
    echo Exiting in 10 seconds...
    timeout /t 10 >nul
    exit /b 1
)
echo ✅ Build environment ready
echo.

:: Build and publish application
echo [8/9] Building and publishing application...
echo   Building...
dotnet build -c Release --verbosity quiet >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ BUILD FAILED!
    echo.
    echo   Running detailed build to show errors:
    echo.
    dotnet build -c Release
    echo.
    echo Exiting in 15 seconds...
    timeout /t 15 >nul
    exit /b 1
)

echo   Publishing...
dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity quiet >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ PUBLISH FAILED!
    echo.
    echo   Running detailed publish to show errors:
    echo.
    dotnet publish -c Release -o bin\Release\net9.0\publish
    echo.
    echo Exiting in 15 seconds...
    timeout /t 15 >nul
    exit /b 1
)

echo   Copying to IIS...
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ FILE COPY FAILED!
    echo   Ensure you're running as Administrator
    echo.
    echo Exiting in 10 seconds...
    timeout /t 10 >nul
    exit /b 1
)
echo ✅ Application deployed to IIS
echo.

:: Verify deployment
echo [9/9] Verifying deployment...
if exist "C:\inetpub\wwwroot\simple-iis-app\simple-iis-app.dll" (
    echo ✅ Application files verified
) else (
    echo ❌ Deployment verification failed
    echo   Files may not have copied correctly
)

if exist "C:\inetpub\wwwroot\simple-iis-app\web.config" (
    echo ✅ Web.config found
) else (
    echo ❌ Web.config missing
)

echo.
echo ================================
echo 🎉 DEPLOYMENT SUCCESSFUL! 🎉  
echo ================================
echo.
echo ✅ Application built and deployed
echo ✅ Files location: C:\inetpub\wwwroot\simple-iis-app\
echo ✅ Ready for IIS configuration
echo.
echo 📋 NEXT STEPS - Configure IIS:
echo.
echo 1. Open IIS Manager (search "IIS" in Start menu)
echo.
echo 2. Create Application Pool:
echo    • Right-click "Application Pools" → Add Application Pool
echo    • Name: simple-iis-app
echo    • .NET CLR Version: No Managed Code
echo    • Click OK
echo.
echo 3. Create Website:
echo    • Right-click "Sites" → Add Website
echo    • Site name: simple-iis-app
echo    • Physical path: C:\inetpub\wwwroot\simple-iis-app
echo    • Port: 8080
echo    • Application pool: simple-iis-app
echo    • Click OK
echo.
echo 4. Test your deployment:
echo    • Open browser to: http://localhost:8080
echo    • You should see the Simple IIS App homepage
echo.
echo 🔧 If you see errors, check:
echo    • Windows Event Viewer → Windows Logs → Application
echo    • IIS logs in: C:\inetpub\logs\LogFiles\
echo.
echo ================================
echo Deployment completed at %date% %time%
echo ================================
echo.
echo Press any key to exit...
pause >nul
