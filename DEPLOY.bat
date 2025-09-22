@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Complete Deployment Script (Simple Logging)
:: ============================================================================

echo ========================================
echo Simple IIS App - Complete Deployment
echo ========================================
echo.

:: Simple sequential log naming
if not exist "logs" mkdir "logs"
set "LOG_NUM=%RANDOM%"
set "MAIN_LOG=logs\deploy-%LOG_NUM%.log"
set "DEBUG_LOG=logs\debug-%LOG_NUM%.log"
set "NUGET_LOG=logs\nuget-%LOG_NUM%.log"
set "BUILD_LOG=logs\build-%LOG_NUM%.log"

echo This script will deploy your application step by step.
echo Press ENTER at each step to continue.
echo.
echo 📝 Logging to: %MAIN_LOG%
echo 🔍 Debug log: %DEBUG_LOG%
echo 📦 NuGet log: %NUGET_LOG%
echo 🔨 Build log: %BUILD_LOG%
echo.

call :log_message "=== DEPLOYMENT STARTED ==="
call :log_message "Current Directory: %CD%"
call :log_message "User: %USERNAME%"

pause

echo 🔍 STEP 1: Checking Administrator privileges...
call :log_message "STEP 1: Checking Administrator privileges"
net session >nul 2>&1
if %errorlevel% neq 0 (
    call :log_message "ERROR: Not running as Administrator"
    echo ❌ NOT running as Administrator!
    echo.
    echo You MUST right-click this file and select "Run as administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    call :log_message "SUCCESS: Running as Administrator"
    echo ✅ Running as Administrator
)
echo.
pause

echo 🔍 STEP 2: Checking project structure...
if exist "simple-iis-app.csproj" (
    echo ✅ Found simple-iis-app.csproj - correct directory
    call :log_message "SUCCESS: Found project file"
) else (
    echo ❌ simple-iis-app.csproj not found!
    echo Make sure you're running this from the correct directory
    call :log_message "ERROR: Project file not found"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
pause

echo 🔍 STEP 3: Auto-fixing namespace issues...
echo Checking for namespace issues that cause build errors...

:: Fix Views\_ViewImports.cshtml namespace
if exist "Views\_ViewImports.cshtml" (
    findstr /C:"SimpleIISApp" "Views\_ViewImports.cshtml" >nul 2>&1
    if %errorlevel% equ 0 (
        echo   🔧 Fixing Views\_ViewImports.cshtml namespace...
        powershell -Command "(Get-Content 'Views\_ViewImports.cshtml') -replace 'SimpleIISApp', 'simple_iis_app' | Set-Content 'Views\_ViewImports.cshtml'" 2>nul
        echo   ✅ Fixed Views\_ViewImports.cshtml
    ) else (
        echo   ✅ Views\_ViewImports.cshtml already correct
    )
)

echo ✅ Namespace fixes completed
echo.
pause

echo 🔍 STEP 4: Checking .NET installation...
call :log_message "STEP 4: Checking .NET installation"

dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    call :log_message "ERROR: .NET CLI not found"
    echo ❌ .NET CLI not found!
    echo.
    echo Install .NET 9.0 SDK from: https://dotnet.microsoft.com/download/dotnet/9.0
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    for /f %%i in ('dotnet --version 2^>nul') do set DOTNET_VERSION=%%i
    call :log_message "SUCCESS: .NET version: !DOTNET_VERSION!"
    echo ✅ .NET version: !DOTNET_VERSION!
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

echo 🔍 STEP 5: Setting up Datadog environment variables...
echo   🔧 Setting Datadog machine-level environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS','Serilog',$target); Write-Host '   ✅ DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS=Serilog'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_PROFILING_ENABLED','true',$target); Write-Host '   ✅ DD_PROFILING_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_CODE_ORIGIN_FOR_SPANS_ENABLED','true',$target); Write-Host '   ✅ DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_EXCEPTION_REPLAY_ENABLED','true',$target); Write-Host '   ✅ DD_EXCEPTION_REPLAY_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_IAST_ENABLED','true',$target); Write-Host '   ✅ DD_IAST_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set (DD_SITE uses default)' } catch { Write-Host '   ❌ Error setting Datadog variables' }"

echo ✅ Datadog environment configured
echo.
echo ⚠️  IMPORTANT: Set your Datadog API key manually:
echo   [System.Environment]::SetEnvironmentVariable('DD_API_KEY','your-actual-api-key',[System.EnvironmentVariableTarget]::Machine)
echo   Or add it to web.config: ^<environmentVariable name="DD_API_KEY" value="your-api-key" /^>
echo.
pause

echo 🔍 STEP 6: Building application...
call :log_message "STEP 6: Building application"
echo Running: dotnet build -c Release
echo.

:: Clear cache and restore
echo   🔧 Clearing NuGet cache...
dotnet nuget locals all --clear >> "%NUGET_LOG%" 2>&1

echo   🔧 Restoring packages...
dotnet restore >> "%NUGET_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Package restore failed! Check NuGet log: %NUGET_LOG%
    call :log_message "ERROR: Package restore failed"
    pause
    exit /b 1
)

:: Build
dotnet build -c Release >> "%BUILD_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Build failed! Check build log: %BUILD_LOG%
    call :log_message "ERROR: Build failed"
    echo.
    echo 🔍 Last few lines of build log:
    powershell -Command "Get-Content '%BUILD_LOG%' | Select-Object -Last 5"
    echo.
    pause
    exit /b 1
)

echo ✅ Build successful!
call :log_message "SUCCESS: Build completed"
echo.
pause

echo 🔍 STEP 7: Publishing application...
call :log_message "STEP 7: Publishing application"
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
echo.

dotnet publish -c Release -o bin\Release\net9.0\publish >> "%BUILD_LOG%" 2>&1
if %errorlevel% neq 0 (
    echo ❌ Publish failed! Check build log: %BUILD_LOG%
    call :log_message "ERROR: Publish failed"
    pause
    exit /b 1
)

echo ✅ Publish successful!
call :log_message "SUCCESS: Publish completed"
echo.
pause

echo 🔍 STEP 8: Copying files to IIS directory...
echo Creating IIS directory...
if not exist "C:\inetpub\wwwroot\simple-iis-app" mkdir "C:\inetpub\wwwroot\simple-iis-app"

echo Running: xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
echo.

xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
if %errorlevel% neq 0 (
    echo ❌ Failed to copy files to IIS directory
    call :log_message "ERROR: File copy failed"
    pause
    exit /b 1
)

echo ✅ Files copied successfully
call :log_message "SUCCESS: Files deployed to IIS directory"
echo.

echo Files in IIS directory:
dir "C:\inetpub\wwwroot\simple-iis-app" /b
echo.
pause

echo ========================================
echo 🎉 DEPLOYMENT COMPLETED! 🎉
echo ========================================
echo.
call :log_message "=== DEPLOYMENT COMPLETED SUCCESSFULLY ==="

echo ✅ Application built and deployed successfully
echo ✅ Files location: C:\inetpub\wwwroot\simple-iis-app\
echo ✅ SourceLink integration enabled for Datadog
echo ✅ All Datadog environment variables configured
echo.
echo 📝 Log files created:
echo    📄 Main log: %MAIN_LOG%
echo    🔍 Debug log: %DEBUG_LOG%
echo    📦 NuGet log: %NUGET_LOG%
echo    🔨 Build log: %BUILD_LOG%
echo.
echo ========================================
echo 🔧 MANUAL IIS SETUP REQUIRED
echo ========================================
echo.
echo 📋 Complete these steps in IIS Manager:
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
echo 4. Set Directory Permissions:
echo    • Right-click C:\inetpub\wwwroot\simple-iis-app in Explorer
echo    • Properties → Security → Edit → Add
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
call :log_message "=== SCRIPT COMPLETED ==="
echo Press any key to exit...
pause >nul
exit /b 0

:: Simple logging function
:log_message
echo [%time%] %~1 >> "%MAIN_LOG%" 2>nul
echo %~1
goto :eof