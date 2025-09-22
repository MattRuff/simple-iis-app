@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Safe Deployment Script (Fixed Timestamp Issue)
:: ============================================================================

echo ========================================
echo Simple IIS App - Complete Deployment
echo ========================================
echo.

:: Use simple, reliable timestamp
set "LOG_TIMESTAMP=%RANDOM%_%date:~-4%_%time:~0,2%%time:~3,2%"
set "LOG_TIMESTAMP=%LOG_TIMESTAMP: =0%"
set "LOG_TIMESTAMP=%LOG_TIMESTAMP::=-%"

:: Setup logging with fallback
if not exist "logs" mkdir "logs"
if "%LOG_TIMESTAMP%"=="" set "LOG_TIMESTAMP=deploy_%RANDOM%"

set "MAIN_LOG=logs\deploy_%LOG_TIMESTAMP%.log"
set "DEBUG_LOG=logs\debug_%LOG_TIMESTAMP%.log"
set "NUGET_LOG=logs\nuget_%LOG_TIMESTAMP%.log"
set "BUILD_LOG=logs\build_%LOG_TIMESTAMP%.log"

:: Test log function first
call :test_log_function
if %errorlevel% neq 0 (
    echo ❌ Logging system failed, using simple output only
    set "USE_LOGGING=false"
) else (
    set "USE_LOGGING=true"
)

echo This script will deploy your application step by step.
echo Press ENTER at each step to continue.
echo.
echo 📝 Logging to: %MAIN_LOG%
echo 🔍 Debug log: %DEBUG_LOG%
echo 📦 NuGet log: %NUGET_LOG%
echo 🔨 Build log: %BUILD_LOG%
echo.

call :log_message "=== DEPLOYMENT STARTED ==="
call :log_message "Timestamp: %LOG_TIMESTAMP%"
call :log_message "Current Directory: %CD%"
call :log_message "User: %USERNAME%"
call :log_message "Computer: %COMPUTERNAME%"

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
) else (
    echo ❌ simple-iis-app.csproj not found!
    echo Make sure you're running this from the correct directory
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
pause

echo 🔍 STEP 3: Checking .NET installation...
call :log_message "STEP 3: Checking .NET installation"

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
echo.
pause

echo 🔍 STEP 4: Setting up Datadog environment variables...
echo   🔧 Setting Datadog machine-level environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_CODE_ORIGIN_FOR_SPANS_ENABLED','true',$target); Write-Host '   ✅ DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_EXCEPTION_REPLAY_ENABLED','true',$target); Write-Host '   ✅ DD_EXCEPTION_REPLAY_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set at machine level' } catch { Write-Host '   ❌ Error setting Datadog variables:' $_.Exception.Message; exit 1 }"
echo.
pause

echo 🔍 STEP 5: Building application...
call :log_message "STEP 5: Building application"
echo Running: dotnet build -c Release
echo.

dotnet build -c Release
if %errorlevel% neq 0 (
    echo ❌ Build failed! Check the errors above.
    call :log_message "ERROR: Build failed"
    echo.
    pause
    exit /b 1
)

echo ✅ Build successful!
call :log_message "SUCCESS: Build completed successfully"
echo.
pause

echo 🔍 STEP 6: Publishing application...
call :log_message "STEP 6: Publishing application"
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
echo.

dotnet publish -c Release -o bin\Release\net9.0\publish
if %errorlevel% neq 0 (
    echo ❌ Publish failed!
    call :log_message "ERROR: Publish failed"
    pause
    exit /b 1
)

echo ✅ Publish successful!
call :log_message "SUCCESS: Publish completed successfully"
echo.
pause

echo 🔍 STEP 7: Copying files to IIS directory...
if not exist "C:\inetpub\wwwroot\simple-iis-app" mkdir "C:\inetpub\wwwroot\simple-iis-app"
echo Running: xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
echo.

xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
if %errorlevel% neq 0 (
    echo ❌ Failed to copy files to IIS directory
    pause
    exit /b 1
)

echo ✅ Files copied successfully
echo.
pause

echo ========================================
echo 🎉 DEPLOYMENT COMPLETED! 🎉
echo ========================================
echo.
call :log_message "=== DEPLOYMENT COMPLETED SUCCESSFULLY ==="

echo ✅ Application built and deployed successfully
echo ✅ Files location: C:\inetpub\wwwroot\simple-iis-app\
echo.
echo 📋 Manual IIS Setup Required:
echo.
echo 1. Open IIS Manager
echo 2. Create Application Pool: simple-iis-app (No Managed Code)
echo 3. Create Website: simple-iis-app on port 8080
echo 4. Set permissions for IIS AppPool\simple-iis-app
echo 5. Test: Browse to http://localhost:8080
echo.
call :log_message "=== SCRIPT COMPLETED ==="
echo Press any key to exit...
pause >nul
exit /b 0

:: Function to log with timestamp
:log_message
if "%USE_LOGGING%"=="true" (
    echo [%time%] %~1 >> "%MAIN_LOG%" 2>nul
)
echo %~1
goto :eof

:: Test the log function works
:test_log_function
echo Test log entry > "%MAIN_LOG%" 2>nul
if exist "%MAIN_LOG%" (
    exit /b 0
) else (
    exit /b 1
)
