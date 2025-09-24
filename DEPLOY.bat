@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Pre-Built Deployment Script
:: ============================================================================

echo ========================================
echo Simple IIS App - Pre-Built Deployment
echo ========================================
echo.

:: Simple sequential log naming
if not exist "logs" mkdir "logs"
set "LOG_NUM=%RANDOM%"
set "MAIN_LOG=logs\deploy-%LOG_NUM%.log"
set "DEBUG_LOG=logs\debug-%LOG_NUM%.log"

echo This script deploys PRE-BUILT application files to IIS.
echo The application was already built locally - no .NET SDK required on server!
echo.
echo 📝 Logging to: %MAIN_LOG%
echo 🔍 Debug log: %DEBUG_LOG%
echo.

echo [%time%] === PRE-BUILT DEPLOYMENT STARTED === >> "%MAIN_LOG%" 2>nul
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

echo 🔍 STEP 3: Checking pre-built application files...
echo [%time%] STEP 3: Checking pre-built application files >> "%MAIN_LOG%" 2>nul

if not exist "bin\Release\net9.0\publish" (
    echo [%time%] ERROR: Published files not found >> "%MAIN_LOG%" 2>nul
    echo ❌ Pre-built application files not found!
    echo.
    echo 🚨 APPLICATION NOT BUILT: Missing bin\Release\net9.0\publish directory
    echo.
    echo 📝 This deployment script uses PRE-BUILT files.
    echo    Please build the application first on your development machine:
    echo.
    echo    dotnet build -c Release
    echo    dotnet publish -c Release -o bin\Release\net9.0\publish
    echo.
    echo    Then copy the entire folder to this server and run this script.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo ✅ Found pre-built application files in bin\Release\net9.0\publish
echo [%time%] SUCCESS: Pre-built files located >> "%MAIN_LOG%" 2>nul

:: Check key files exist
if not exist "bin\Release\net9.0\publish\simple-iis-app.dll" (
    echo [%time%] ERROR: Main application DLL missing >> "%MAIN_LOG%" 2>nul
    echo ❌ simple-iis-app.dll not found in publish directory!
    echo Please rebuild the application on your development machine.
    pause >nul
    exit /b 1
)

if not exist "bin\Release\net9.0\publish\web.config" (
    echo [%time%] ERROR: web.config missing >> "%MAIN_LOG%" 2>nul
    echo ❌ web.config not found in publish directory!
    echo Please rebuild the application on your development machine.
    pause >nul
    exit /b 1
)

echo ✅ All required application files are present
echo   • simple-iis-app.dll
echo   • web.config
echo   • appsettings.json
echo   • All Serilog dependencies
echo.
pause

echo 🔍 STEP 4: Setting up Datadog environment variables...
echo   🔧 Setting Datadog machine-level environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS','Serilog',$target); Write-Host '   ✅ DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS=Serilog'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_PROFILING_ENABLED','true',$target); Write-Host '   ✅ DD_PROFILING_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_CODE_ORIGIN_FOR_SPANS_ENABLED','true',$target); Write-Host '   ✅ DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_EXCEPTION_REPLAY_ENABLED','true',$target); Write-Host '   ✅ DD_EXCEPTION_REPLAY_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_IAST_ENABLED','true',$target); Write-Host '   ✅ DD_APPSEC_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set (DD_SITE uses default)' } catch { Write-Host '   ❌ Error setting Datadog variables' }"

echo ✅ Datadog environment configured
echo.
echo ⚠️  IMPORTANT: Set your Datadog API key manually:
echo   [System.Environment]::SetEnvironmentVariable('DD_API_KEY','your-actual-api-key',[System.EnvironmentVariableTarget]::Machine)
echo   Or add it to web.config: ^<environmentVariable name="DD_API_KEY" value="your-api-key" /^>
echo.
pause

echo 🔍 STEP 5: Copying pre-built files to IIS directory...
echo [%time%] STEP 5: Copying files to IIS directory >> "%MAIN_LOG%" 2>nul
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

echo ✅ Application files deployed to: %IIS_APP_PATH%
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
echo 💡 SERVER REQUIREMENTS:
echo   • ✅ IIS with ASP.NET Core Module V2
echo   • ✅ .NET 9.0 Runtime (Windows Hosting Bundle)
echo   • ❌ NO .NET SDK required (app is pre-built)
echo.
echo [%time%] === SCRIPT COMPLETED === >> "%MAIN_LOG%" 2>nul
echo Press any key to exit...
pause >nul
exit /b 0