@echo off
setlocal EnableDelayedExpansion

:: Create logs directory
if not exist "logs" mkdir "logs"

:: Set timestamp for log files
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

:: Set log files
set "LOG_FILE=logs\deploy_%timestamp%.log"
set "ERROR_LOG=logs\deploy_errors_%timestamp%.log"

:: Function to log and display
goto :main

:log_and_echo
echo %~1
echo %~1 >> "%LOG_FILE%"
goto :eof

:main
call :log_and_echo "================================"
call :log_and_echo " Simple IIS App - Deployment"
call :log_and_echo "================================"
call :log_and_echo ""
call :log_and_echo "📄 Logging to: %LOG_FILE%"
call :log_and_echo "❌ Error log: %ERROR_LOG%"
call :log_and_echo ""
call :log_and_echo "⚠️  IMPORTANT: Ensure .NET 9.0 Hosting Bundle is installed!"
call :log_and_echo "   Download from: https://dotnet.microsoft.com/en-us/download/dotnet/9.0"
call :log_and_echo "   Get: ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"
call :log_and_echo ""

:: Set Datadog environment variables for observability
call :log_and_echo "🔍 Setting Datadog environment variables..."
for /f %%i in ('git rev-parse HEAD 2^>nul') do set DD_GIT_COMMIT_SHA=%%i
for /f %%i in ('git config --get remote.origin.url 2^>nul') do set DD_GIT_REPOSITORY_URL=%%i

:: Fallback values if git commands fail
if "%DD_GIT_COMMIT_SHA%"=="" set DD_GIT_COMMIT_SHA=unknown
if "%DD_GIT_REPOSITORY_URL%"=="" set DD_GIT_REPOSITORY_URL=unknown

call :log_and_echo "   DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%"
call :log_and_echo "   DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%"
call :log_and_echo ""

call :log_and_echo "[1/5] Cleaning previous builds..."
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ Cleaned"

call :log_and_echo ""
call :log_and_echo "[2/5] Publishing application..."
echo [%time%] Running: dotnet publish -c Release -o bin\Release\net9.0\publish >> "%LOG_FILE%"
echo [%time%] DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA% >> "%LOG_FILE%"
echo [%time%] DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL% >> "%LOG_FILE%"
set DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%&& set DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%&& dotnet publish -c Release -o bin\Release\net9.0\publish 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "    ❌ Publish failed! Check error log: %ERROR_LOG%"
    call :log_and_echo "❌ Deployment failed. Check logs:"
    call :log_and_echo "   Main log: %LOG_FILE%"
    call :log_and_echo "   Error log: %ERROR_LOG%"
    echo.
    echo ❌ BUILD ERRORS DETECTED! Check the error log for details.
    if exist "%ERROR_LOG%" (
        echo.
        echo === Recent Errors ===
        powershell "Get-Content '%ERROR_LOG%' | Select-Object -Last 10"
    )
    pause
    exit /b 1
)
call :log_and_echo "    ✓ Published"

call :log_and_echo ""
call :log_and_echo "[3/5] Creating IIS directory..."
if not exist "C:\inetpub\wwwroot\SimpleIISApp" mkdir "C:\inetpub\wwwroot\SimpleIISApp" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ IIS directory created"

call :log_and_echo ""
call :log_and_echo "[4/5] Copying files to IIS directory..."
echo [%time%] Running: xcopy to C:\inetpub\wwwroot\SimpleIISApp\ >> "%LOG_FILE%"
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\SimpleIISApp\" /E /I /Y 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "    ❌ Copy failed! Make sure you're running as Administrator"
    call :log_and_echo "    You can manually copy from: bin\Release\net9.0\publish\"
    call :log_and_echo "    To: C:\inetpub\wwwroot\SimpleIISApp\"
    call :log_and_echo "❌ Deployment failed. Check logs:"
    call :log_and_echo "   Main log: %LOG_FILE%"
    call :log_and_echo "   Error log: %ERROR_LOG%"
    pause
    exit /b 1
)
call :log_and_echo "    ✓ Files copied to IIS directory"

call :log_and_echo ""
call :log_and_echo "[5/5] Deployment Complete!"
call :log_and_echo ""
call :log_and_echo "================================"
call :log_and_echo "    🎉 Ready for IIS Setup! 🎉" 
call :log_and_echo "================================"
call :log_and_echo ""
call :log_and_echo "✅ Published files are in: bin\Release\net9.0\publish\"
call :log_and_echo "✅ IIS files are in: C:\inetpub\wwwroot\SimpleIISApp\"
call :log_and_echo "📄 Deployment log: %LOG_FILE%"
call :log_and_echo "❌ Error log: %ERROR_LOG%"
call :log_and_echo ""
call :log_and_echo "📋 Next steps:"
call :log_and_echo "1. Open IIS Manager"
call :log_and_echo "2. Create new website with these EXACT settings:"
call :log_and_echo "   • Site name: SimpleIISApp"
call :log_and_echo "   • Physical path: C:\inetpub\wwwroot\SimpleIISApp"
call :log_and_echo "   • Port: 8080 (or any available port)"
call :log_and_echo "3. Set Application Pool to No Managed Code"
call :log_and_echo "4. Ensure .NET 9.0 Runtime is installed"
call :log_and_echo "5. Browse to your site!"
call :log_and_echo ""
call :log_and_echo "🌐 Point IIS to: C:\inetpub\wwwroot\SimpleIISApp"
call :log_and_echo "================================"

echo.
echo 📂 Log files created in 'logs' folder:
echo    📄 Main: %LOG_FILE%
echo    ❌ Errors: %ERROR_LOG%
echo.
pause
