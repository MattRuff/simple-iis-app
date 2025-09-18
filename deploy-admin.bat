@echo off
setlocal EnableDelayedExpansion

:: Check for administrator privileges first
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause >nul
    exit /b 1
)

:: Prevent multiple instances
if exist "logs\deploy_admin_running.lock" (
    echo ❌ Another admin deployment is already running!
    echo If this is incorrect, delete: logs\deploy_admin_running.lock
    pause >nul
    exit /b 1
)

:: Create logs directory and lock file
if not exist "logs" mkdir "logs"
echo %date% %time% > "logs\deploy_admin_running.lock"

:: Set timestamp for log files using PowerShell (replaced wmic which was deprecated)
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
:: Fallback if PowerShell fails - use simple counter
if "%timestamp%"=="" set "timestamp=deploy_admin_%RANDOM%"

:: Set log files
set "LOG_FILE=logs\deploy_admin_%timestamp%.log"
set "ERROR_LOG=logs\deploy_admin_errors_%timestamp%.log"

:: Function to log and display
goto :main

:log_and_echo
if [%1]==[] (
    echo.
    echo. >> "%LOG_FILE%"
) else if "%~1"=="" (
    echo.
    echo. >> "%LOG_FILE%"
) else (
    echo %~1
    echo %~1 >> "%LOG_FILE%"
)
goto :eof

:main
call :log_and_echo "================================"
call :log_and_echo " Simple IIS App - Admin Deploy"
call :log_and_echo "================================"
call :log_and_echo ""
call :log_and_echo "✅ Running as Administrator"
call :log_and_echo "📄 Logging to: %LOG_FILE%"
call :log_and_echo "❌ Error log: %ERROR_LOG%"
call :log_and_echo ""
call :log_and_echo "⚠️  IMPORTANT: Ensure .NET 9.0 Hosting Bundle is installed!"
call :log_and_echo "   Download from: https://dotnet.microsoft.com/en-us/download/dotnet/9.0"
call :log_and_echo "   Get: ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"
call :log_and_echo ""

:: Set Datadog environment variables for observability
call :log_and_echo "🧹 Performing cleanup and fixes..."

:: Clean up old logs (keep last 10)
if exist "logs\" (
    echo [%time%] Cleaning up old log files... >> "%LOG_FILE%"
    for /f "skip=10 delims=" %%i in ('dir /b /o-d logs\*.log 2^>nul') do (
        del "logs\%%i" 2>>"%ERROR_LOG%"
    )
)

:: Fix .csproj file by removing problematic PackageReference entries for .NET 9.0
call :log_and_echo "   Checking and fixing .csproj file..."
if exist "SimpleIISApp.csproj" (
    echo [%time%] Fixing SimpleIISApp.csproj - removing incompatible PackageReference entries >> "%LOG_FILE%"
    
    :: Create a clean .csproj file for .NET 9.0
    (
        echo ^<Project Sdk="Microsoft.NET.Sdk.Web"^>
        echo.
        echo   ^<PropertyGroup^>
        echo     ^<TargetFramework^>net9.0^</TargetFramework^>
        echo     ^<Nullable^>enable^</Nullable^>
        echo     ^<ImplicitUsings^>enable^</ImplicitUsings^>
        echo   ^</PropertyGroup^>
        echo.
        echo ^</Project^>
    ) > "SimpleIISApp.csproj.tmp"
    
    :: Replace the original file
    move "SimpleIISApp.csproj.tmp" "SimpleIISApp.csproj" >nul 2>>"%ERROR_LOG%"
    call :log_and_echo "   ✓ Fixed .csproj file for .NET 9.0 compatibility"
) else (
    call :log_and_echo "   ⚠️ SimpleIISApp.csproj not found in current directory"
)

call :log_and_echo "🔍 Setting Datadog environment variables..."
for /f %%i in ('git rev-parse HEAD 2^>nul') do set DD_GIT_COMMIT_SHA=%%i
for /f %%i in ('git config --get remote.origin.url 2^>nul') do set DD_GIT_REPOSITORY_URL=%%i

:: Fallback values if git commands fail
if "%DD_GIT_COMMIT_SHA%"=="" set DD_GIT_COMMIT_SHA=unknown
if "%DD_GIT_REPOSITORY_URL%"=="" set DD_GIT_REPOSITORY_URL=unknown

call :log_and_echo "   DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%"
call :log_and_echo "   DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%"
call :log_and_echo ""

call :log_and_echo "[1/6] Cleaning previous builds..."
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish" 2>>"%ERROR_LOG%"
if exist "bin\Debug" rmdir /s /q "bin\Debug" 2>>"%ERROR_LOG%"
if exist "obj" rmdir /s /q "obj" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ Cleaned build artifacts"

call :log_and_echo ""
call :log_and_echo "[2/6] Publishing application..."
echo [%time%] Running: dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity detailed >> "%LOG_FILE%"
echo [%time%] DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA% >> "%LOG_FILE%"
echo [%time%] DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL% >> "%LOG_FILE%"
set DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%&& set DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%&& dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity detailed 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "    ❌ Publish failed! Check error log: %ERROR_LOG%"
    call :log_and_echo "❌ Deployment failed. Check logs:"
    call :log_and_echo "   Main log: %LOG_FILE%"
    call :log_and_echo "   Error log: %ERROR_LOG%"
    echo.
    echo ❌ BUILD ERRORS DETECTED! Check the error log for details.
    if exist "%ERROR_LOG%" (
        echo.
        echo === DETAILED ERROR ANALYSIS ===
        echo Full error log: %ERROR_LOG%
        echo.
        echo === STACK TRACE AND ERRORS ===
        powershell "Get-Content '%ERROR_LOG%' | ForEach-Object { if ($_ -match 'error|exception|stack|fail|Error|Exception|Stack|Fail') { Write-Host $_ -ForegroundColor Red } else { $_ } }"
        echo.
        echo === RECENT ERRORS (Last 15 lines) ===
        powershell "Get-Content '%ERROR_LOG%' | Select-Object -Last 15"
        echo.
        echo === BUILD ERRORS WITH STACK TRACES ===
        powershell "Get-Content '%LOG_FILE%' | Select-String -Pattern 'error|exception|fail' -Context 2,3"
    )
    echo.
    echo Press any key to exit...
    :: Clean up lock file on error
    if exist "logs\deploy_admin_running.lock" del "logs\deploy_admin_running.lock" >nul
    pause >nul
    exit /b 1
)
call :log_and_echo "    ✓ Published"

call :log_and_echo ""
call :log_and_echo "[3/6] Creating IIS directory..."
if not exist "C:\inetpub\wwwroot\SimpleIISApp" mkdir "C:\inetpub\wwwroot\SimpleIISApp" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ IIS directory created"

call :log_and_echo ""
call :log_and_echo "[4/6] Copying files to IIS directory..."
echo [%time%] Running: xcopy to C:\inetpub\wwwroot\SimpleIISApp\ >> "%LOG_FILE%"
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\SimpleIISApp\" /E /I /Y 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "    ❌ Copy failed!"
    call :log_and_echo "❌ Deployment failed. Check logs:"
    call :log_and_echo "   Main log: %LOG_FILE%"
    call :log_and_echo "   Error log: %ERROR_LOG%"
    echo.
    echo Press any key to exit...
    :: Clean up lock file on error
    if exist "logs\deploy_admin_running.lock" del "logs\deploy_admin_running.lock" >nul
    pause >nul
    exit /b 1
)
call :log_and_echo "    ✓ Files copied to IIS directory"

call :log_and_echo ""
call :log_and_echo "[5/6] Final verification..."
call :log_and_echo "   ✓ Verifying published files exist"
if exist "C:\inetpub\wwwroot\SimpleIISApp\SimpleIISApp.dll" (
    call :log_and_echo "   ✓ Application DLL found"
) else (
    call :log_and_echo "   ⚠️ Application DLL not found - check copy operation"
)

call :log_and_echo ""
call :log_and_echo "[6/6] Deployment Complete!"
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
call :log_and_echo "   (NOT to bin\Release\net9.0\publish)"
call :log_and_echo "   (NOT to your source folder)"
call :log_and_echo "   (NOT to your Desktop)"
call :log_and_echo "================================"

echo.
echo 📂 Log files created in 'logs' folder:
echo    📄 Main: %LOG_FILE%
echo    ❌ Errors: %ERROR_LOG%
echo.
echo ✅ Deployment completed successfully!
echo.

:: Clean up lock file
if exist "logs\deploy_admin_running.lock" del "logs\deploy_admin_running.lock" >nul

echo Press any key to exit...
pause >nul
