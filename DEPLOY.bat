@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Smart Deployment Script
:: ============================================================================

echo ========================================
echo Simple IIS App - Smart Deployment
echo ========================================
echo.

:: Simple sequential log naming
if not exist "logs" mkdir "logs"
set "LOG_NUM=%RANDOM%"
set "MAIN_LOG=logs\deploy-%LOG_NUM%.log"
set "DEBUG_LOG=logs\debug-%LOG_NUM%.log"
set "NUGET_LOG=logs\nuget-%LOG_NUM%.log"
set "BUILD_LOG=logs\build-%LOG_NUM%.log"

echo This script automatically detects your deployment scenario:
echo.
echo   🔍 Pre-built files exist? Deploy them (Runtime only)
echo   🔨 No pre-built files? Build then deploy (SDK required)
echo.
echo 📝 Logging to: %MAIN_LOG%
echo 🔍 Debug log: %DEBUG_LOG%
echo 📦 NuGet log: %NUGET_LOG%
echo 🔨 Build log: %BUILD_LOG%
echo.

echo [%time%] === SMART DEPLOYMENT STARTED === >> "%MAIN_LOG%" 2>nul
echo [%time%] Current Directory: %CD% >> "%MAIN_LOG%" 2>nul
echo [%time%] User: %USERNAME% >> "%MAIN_LOG%" 2>nul

pause

echo 🔍 STEP 1: Checking Administrator privileges...
echo [%time%] STEP 1: Checking Administrator privileges >> "%MAIN_LOG%" 2>nul
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [%time%] ERROR: Not running as Administrator >> "%MAIN_LOG%" 2>nul
    echo ❌ NOT running as Administrator!
    echo.
    echo You MUST right-click this file and select "Run as administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo [%time%] SUCCESS: Running as Administrator >> "%MAIN_LOG%" 2>nul
    echo ✅ Running as Administrator
)
echo.
pause

echo 🔍 STEP 2: Checking project structure...
if exist "simple-iis-app.csproj" (
    echo ✅ Found simple-iis-app.csproj - correct directory
    echo [%time%] SUCCESS: Found project file >> "%MAIN_LOG%" 2>nul
) else (
    echo ❌ simple-iis-app.csproj not found!
    echo Make sure you're running this from the simple-iis-app directory
    echo [%time%] ERROR: Project file not found >> "%MAIN_LOG%" 2>nul
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
pause

echo 🔍 STEP 3: Auto-fixing namespace issues...
echo Checking for namespace issues that cause build errors...
echo.

:: Fix Views\_ViewImports.cshtml
if exist "Views\_ViewImports.cshtml" (
    findstr /C:"SimpleIISApp" "Views\_ViewImports.cshtml" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   🔧 Fixing Views\_ViewImports.cshtml namespace...
        powershell -Command "(Get-Content 'Views\_ViewImports.cshtml') -replace 'SimpleIISApp', 'simple_iis_app' | Set-Content 'Views\_ViewImports.cshtml'" 2>nul
        echo   ✅ Fixed Views\_ViewImports.cshtml
    ) else (
        echo   ✅ Views\_ViewImports.cshtml already correct
    )
) else (
    echo   ⚠️ Views\_ViewImports.cshtml not found
)

:: Fix GlobalUsings.cs comment
if exist "GlobalUsings.cs" (
    findstr /C:"SimpleIISApp" "GlobalUsings.cs" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   🔧 Fixing GlobalUsings.cs comment...
        powershell -Command "(Get-Content 'GlobalUsings.cs') -replace 'SimpleIISApp', 'simple-iis-app' | Set-Content 'GlobalUsings.cs'" 2>nul
        echo   ✅ Fixed GlobalUsings.cs
    ) else (
        echo   ✅ GlobalUsings.cs already correct
    )
)

:: Fix launchSettings.json
if exist "Properties\launchSettings.json" (
    findstr /C:"SimpleIISApp" "Properties\launchSettings.json" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   🔧 Fixing Properties\launchSettings.json...
        powershell -Command "(Get-Content 'Properties\launchSettings.json') -replace 'SimpleIISApp', 'simple-iis-app' | Set-Content 'Properties\launchSettings.json'" 2>nul
        echo   ✅ Fixed Properties\launchSettings.json
    ) else (
        echo   ✅ launchSettings.json already correct
    )
)

:: Check SourceLink package version
if exist "simple-iis-app.csproj" (
    findstr /C:"8.0.0" "simple-iis-app.csproj" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   ❌ Found SourceLink version 8.0.0 (this will cause build errors)
        echo   ⚠️ Please manually edit simple-iis-app.csproj and change "8.0.0" to "1.1.1"
        echo   Then run this script again.
        echo.
        pause
        exit /b 1
    ) else (
        echo   ✅ SourceLink package version is correct
    )
)

echo ✅ Namespace fixes completed
echo.
pause

echo 🔍 STEP 4: Detecting deployment mode...
echo [%time%] STEP 4: Detecting deployment mode >> "%MAIN_LOG%" 2>nul

if exist "bin\Release\net9.0\publish" (
    if exist "bin\Release\net9.0\publish\simple-iis-app.dll" (
        echo ✅ PRE-BUILT FILES DETECTED!
        echo [%time%] SUCCESS: Pre-built files found - using pre-built deployment >> "%MAIN_LOG%" 2>nul
        echo.
        echo 🚀 DEPLOYMENT MODE: Pre-built files
        echo   • Using existing bin\Release\net9.0\publish\ files
        echo   • No .NET SDK required on this machine
        echo   • Faster deployment (no build time)
        echo.
        set "DEPLOYMENT_MODE=PREBUILT"
        goto :deploy_prebuilt
    )
)

echo 🔨 NO PRE-BUILT FILES - WILL BUILD ON THIS MACHINE
echo [%time%] No pre-built files found - using build-and-deploy mode >> "%MAIN_LOG%" 2>nul
echo.
echo 🚀 DEPLOYMENT MODE: Build and deploy
echo   • Will build application on this machine
echo   • Requires .NET SDK installed
echo   • Longer deployment (includes build time)
echo.
set "DEPLOYMENT_MODE=BUILD"
goto :check_dotnet

:check_dotnet
echo.
pause

echo 🔍 STEP 5: Checking .NET SDK installation...
echo [%time%] STEP 5: Checking .NET SDK installation >> "%MAIN_LOG%" 2>nul

dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [%time%] ERROR: .NET CLI not found >> "%MAIN_LOG%" 2>nul
    echo ❌ .NET SDK not found!
    echo.
    echo 🚨 MISSING REQUIREMENT: .NET 9.0 SDK
    echo.
    echo 📥 You have two options:
    echo.
    echo OPTION 1 - Install .NET SDK on this machine:
    echo   🔗 Go to: https://dotnet.microsoft.com/en-us/download/dotnet/9.0
    echo   📦 Download: ".NET 9.0 SDK"
    echo   🚀 Install it, then restart this script
    echo.
    echo OPTION 2 - Use pre-built deployment instead:
    echo   🔧 Build the app on a machine with .NET SDK:
    echo       dotnet build -c Release
    echo       dotnet publish -c Release -o bin\Release\net9.0\publish
    echo   📁 Copy the entire folder to this machine
    echo   🚀 Run this script again (will auto-detect pre-built files)
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    for /f %%i in ('dotnet --version 2^>nul') do set DOTNET_VERSION=%%i
    echo [%time%] SUCCESS: .NET version: !DOTNET_VERSION! >> "%MAIN_LOG%" 2>nul
    echo ✅ .NET SDK version: !DOTNET_VERSION!
)

:: Log .NET info
echo   🔍 Logging .NET environment details...
dotnet --info >> "%DEBUG_LOG%" 2>&1

:: Check NuGet sources
echo   🔍 Checking NuGet sources...
dotnet nuget list source >> "%NUGET_LOG%" 2>&1
dotnet nuget list source > nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ NuGet sources are accessible
) else (
    echo   ⚠️ Adding NuGet source...
    dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org >> "%NUGET_LOG%" 2>&1
)

echo.
pause

echo 🔍 STEP 6: Building application...
echo [%time%] STEP 6: Building application >> "%MAIN_LOG%" 2>nul
echo Running: dotnet build -c Release
echo.

:: Clear cache and restore
echo   🔧 Clearing NuGet cache...
dotnet nuget locals all --clear >> "%NUGET_LOG%" 2>&1

echo   🔧 Restoring packages...
dotnet restore >> "%NUGET_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Package restore failed! Check NuGet log: %NUGET_LOG%
    echo [%time%] ERROR: Package restore failed >> "%MAIN_LOG%" 2>nul
    pause
    exit /b 1
)

:: Build
dotnet build -c Release >> "%BUILD_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Build failed! Check build log: %BUILD_LOG%
    echo [%time%] ERROR: Build failed >> "%MAIN_LOG%" 2>nul
    echo.
    echo 🔍 Last few lines of build log:
    powershell -Command "Get-Content '%BUILD_LOG%' | Select-Object -Last 5"
    echo.
    pause
    exit /b 1
)

echo ✅ Build successful!
echo [%time%] SUCCESS: Build completed >> "%MAIN_LOG%" 2>nul
echo.
pause

echo 🔍 STEP 7: Publishing application...
echo [%time%] STEP 7: Publishing application >> "%MAIN_LOG%" 2>nul
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
echo.

dotnet publish -c Release -o bin\Release\net9.0\publish >> "%BUILD_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Publish failed! Check build log: %BUILD_LOG%
    echo [%time%] ERROR: Publish failed >> "%MAIN_LOG%" 2>nul
    pause
    exit /b 1
)

echo ✅ Publish successful!
echo [%time%] SUCCESS: Publish completed >> "%MAIN_LOG%" 2>nul
echo.
pause

goto :setup_datadog

:deploy_prebuilt
echo.
pause

echo ✅ Using pre-built application files
echo   • simple-iis-app.dll
echo   • web.config
echo   • appsettings.json
echo   • All dependencies included
echo.
pause

goto :setup_datadog

:setup_datadog
echo 🔍 STEP 5 (Pre-built) / STEP 8 (Built): Setting up Datadog environment variables...
echo   🔧 Setting Datadog machine-level environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS','Serilog',$target); Write-Host '   ✅ DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS=Serilog'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_PROFILING_ENABLED','true',$target); Write-Host '   ✅ DD_PROFILING_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_CODE_ORIGIN_FOR_SPANS_ENABLED','true',$target); Write-Host '   ✅ DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_EXCEPTION_REPLAY_ENABLED','true',$target); Write-Host '   ✅ DD_EXCEPTION_REPLAY_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_IAST_ENABLED','true',$target); Write-Host '   ✅ DD_IAST_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set (DD_SITE uses default)' } catch { Write-Host '   ❌ Error setting Datadog variables' }"

echo ✅ Datadog environment configured
echo.
echo ⚠️  IMPORTANT: Set your Datadog API key manually:
echo   [System.Environment]::SetEnvironmentVariable('DD_API_KEY','your-actual-api-key',[System.EnvironmentVariableTarget]::Machine)
echo   Or add it to web.config: ^<environmentVariable name="DD_API_KEY" value="your-api-key" /^>
echo.
pause

echo 🔍 STEP 6 (Pre-built) / STEP 9 (Built): Copying files to IIS directory...
echo [%time%] Copying files to IIS directory >> "%MAIN_LOG%" 2>nul
set "IIS_APP_PATH=C:\inetpub\wwwroot\simple-iis-app"

echo   🔧 Ensuring IIS application directory exists: %IIS_APP_PATH%
if not exist "%IIS_APP_PATH%" (
    echo [%time%] Creating IIS application directory: %IIS_APP_PATH% >> "%MAIN_LOG%" 2>nul
    mkdir "%IIS_APP_PATH%"
    if %errorlevel% neq 0 (
        echo [%time%] ERROR: Failed to create IIS application directory >> "%MAIN_LOG%" 2>nul
        echo ❌ Failed to create IIS application directory: %IIS_APP_PATH%
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    ) else (
        echo [%time%] SUCCESS: IIS application directory created >> "%MAIN_LOG%" 2>nul
        echo ✅ IIS application directory created: %IIS_APP_PATH%
    )
) else (
    echo [%time%] IIS application directory already exists >> "%MAIN_LOG%" 2>nul
    echo ✅ IIS application directory already exists: %IIS_APP_PATH%
)

echo   🔧 Cleaning existing files in %IIS_APP_PATH%...
del /Q "%IIS_APP_PATH%\*" >nul 2>&1
for /d %%d in ("%IIS_APP_PATH%\*") do rmdir /s /q "%%d" >nul 2>&1
echo [%time%] Cleaned existing files in IIS directory >> "%MAIN_LOG%" 2>nul
echo ✅ Cleaned existing files in IIS directory

echo Running: xcopy "bin\Release\net9.0\publish\*" "%IIS_APP_PATH%\" /E /I /Y
echo.
xcopy "bin\Release\net9.0\publish\*" "%IIS_APP_PATH%\" /E /I /Y
if %errorlevel% neq 0 (
    echo [%time%] ERROR: Failed to copy files to IIS directory >> "%MAIN_LOG%" 2>nul
    echo ❌ Failed to copy files to IIS directory!
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo [%time%] SUCCESS: Files deployed to IIS directory >> "%MAIN_LOG%" 2>nul
    echo ✅ Files copied successfully
)
echo.
pause

echo ========================================
echo 🚨 MANUAL IIS SETUP REQUIRED
echo ========================================
echo.
echo [%time%] === DEPLOYMENT COMPLETED SUCCESSFULLY === >> "%MAIN_LOG%" 2>nul
echo [%time%] Application files deployed to: %IIS_APP_PATH% >> "%MAIN_LOG%" 2>nul
echo [%time%] Deployment mode used: %DEPLOYMENT_MODE% >> "%MAIN_LOG%" 2>nul

echo ✅ Application files deployed to: %IIS_APP_PATH%
echo ✅ Deployment mode: %DEPLOYMENT_MODE%
echo ❌ IIS configuration needs to be done manually
echo.
echo 📝 Manual steps:
echo.
echo 1. Open IIS Manager (search "IIS" in Start menu)
echo.
echo 2. Create Application Pool:
echo    • Right-click "Application Pools" ^> Add Application Pool
echo    • Name: simple-iis-app
echo    • .NET CLR Version: No Managed Code
echo    • Click OK
echo.
echo 3. Create Website:
echo    • Right-click "Sites" ^> Add Website
echo    • Site name: simple-iis-app
echo    • Physical path: %IIS_APP_PATH%
echo    • Port: 8080
echo    • Application pool: simple-iis-app
echo    • Click OK
echo.
echo 4. Set Directory Permissions:
echo    • Right-click %IIS_APP_PATH% in Explorer
echo    • Properties ^> Security ^> Edit ^> Add
echo    • Type: IIS AppPool\simple-iis-app
echo    • Give it Read ^& Execute permissions
echo    • Click OK
echo.
echo 5. Test: Browse to http://localhost:8080
echo.
echo 🌐 Your application features:
echo   • 🔐 Login: admin/password
echo   • 💓 Health monitoring
echo   • 🐛 Error testing for Datadog
echo   • 📊 Metrics endpoints
echo   • 🔗 SourceLink for code debugging
echo   • 📝 Agentless Serilog logging to Datadog
echo.
if "%DEPLOYMENT_MODE%"=="PREBUILT" (
    echo 💡 SERVER REQUIREMENTS:
    echo   • ✅ IIS with ASP.NET Core Module V2
    echo   • ✅ .NET 9.0 Runtime (Windows Hosting Bundle)
    echo   • ❌ NO .NET SDK required (app was pre-built)
) else (
    echo 💡 SERVER REQUIREMENTS:
    echo   • ✅ IIS with ASP.NET Core Module V2
    echo   • ✅ .NET 9.0 SDK (for building applications)
    echo   • ✅ .NET 9.0 Runtime (Windows Hosting Bundle)
)
echo.
echo [%time%] === SCRIPT COMPLETED === >> "%MAIN_LOG%" 2>nul
echo Press any key to exit...
pause >nul
exit /b 0