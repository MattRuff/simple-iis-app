@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: MANUAL GIT CONFIGURATION (Optional - for ZIP downloads)
:: If you downloaded this as a ZIP file and know the commit SHA, set it here:
:: ============================================================================
:: set MANUAL_GIT_COMMIT_SHA=abc123def456...
:: set MANUAL_GIT_BRANCH=main
:: set MANUAL_GIT_COMMIT_MESSAGE=Your commit message here
:: ============================================================================

:: Check for administrator privileges first
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    echo Auto-exiting in 3 seconds...
    timeout /t 3 >nul
    exit /b 1
)

:: Prevent multiple instances
if exist "logs\deploy_admin_running.lock" (
    echo ❌ Another admin deployment is already running!
    echo If this is incorrect, delete: logs\deploy_admin_running.lock
    echo Auto-exiting in 3 seconds...
    timeout /t 3 >nul
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

:: Check for manual configuration first (for ZIP downloads)
if not "%MANUAL_GIT_COMMIT_SHA%"=="" (
    call :log_and_echo "   ✓ Using manual Git configuration..."
    set DD_GIT_COMMIT_SHA=%MANUAL_GIT_COMMIT_SHA%
    set DD_GIT_COMMIT_SHA_SHORT=%MANUAL_GIT_COMMIT_SHA:~0,7%
    if not "%MANUAL_GIT_BRANCH%"=="" (set DD_GIT_BRANCH=%MANUAL_GIT_BRANCH%) else (set DD_GIT_BRANCH=main)
    if not "%MANUAL_GIT_COMMIT_MESSAGE%"=="" (set DD_GIT_COMMIT_MESSAGE=%MANUAL_GIT_COMMIT_MESSAGE%) else (set DD_GIT_COMMIT_MESSAGE=Manual configuration)
) else if exist ".git" (
    call :log_and_echo "   ✓ Git repository detected - extracting commit information..."
    :: Get Git commit information dynamically
    for /f %%i in ('git rev-parse HEAD 2^>nul') do set DD_GIT_COMMIT_SHA=%%i
    for /f %%i in ('git rev-parse --short HEAD 2^>nul') do set DD_GIT_COMMIT_SHA_SHORT=%%i
    for /f %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set DD_GIT_BRANCH=%%i
    for /f "delims=" %%i in ('git log -1 --pretty^=format:"%%s" 2^>nul') do set DD_GIT_COMMIT_MESSAGE=%%i
    
    :: Fallback values if git commands fail
    if "%DD_GIT_COMMIT_SHA%"=="" set DD_GIT_COMMIT_SHA=git-repo-no-commits
    if "%DD_GIT_COMMIT_SHA_SHORT%"=="" set DD_GIT_COMMIT_SHA_SHORT=no-commits
    if "%DD_GIT_BRANCH%"=="" set DD_GIT_BRANCH=unknown-branch
    if "%DD_GIT_COMMIT_MESSAGE%"=="" set DD_GIT_COMMIT_MESSAGE=No commit message available
) else (
    call :log_and_echo "   ⚠️ No Git repository found (downloaded ZIP?) - using deployment-based values..."
    :: Set deployment-based values for ZIP downloads
    set DD_GIT_COMMIT_SHA=zip-download-%timestamp%
    set DD_GIT_COMMIT_SHA_SHORT=zip-%RANDOM%
    set DD_GIT_BRANCH=main-download
    set DD_GIT_COMMIT_MESSAGE=Deployed from ZIP download at %date% %time%
)

:: Set explicit repository URL for Datadog tracking (always available)
set DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git

:: Set deployment version for website display
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%

call :log_and_echo "   DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%"
call :log_and_echo "   DD_GIT_COMMIT_SHA_SHORT=%DD_GIT_COMMIT_SHA_SHORT%"
call :log_and_echo "   DD_GIT_BRANCH=%DD_GIT_BRANCH%"
call :log_and_echo "   DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%"
call :log_and_echo "   DD_GIT_COMMIT_MESSAGE=%DD_GIT_COMMIT_MESSAGE%"
call :log_and_echo "   DD_DEPLOYMENT_VERSION=%DD_DEPLOYMENT_VERSION%"
call :log_and_echo "   DD_DEPLOYMENT_TIME=%DD_DEPLOYMENT_TIME%"
call :log_and_echo ""

call :log_and_echo "[1/7] Cleaning previous builds and IIS environment..."
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish" 2>>"%ERROR_LOG%"
if exist "bin\Debug" rmdir /s /q "bin\Debug" 2>>"%ERROR_LOG%"
if exist "obj" rmdir /s /q "obj" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ Cleaned build artifacts"

call :log_and_echo "    🧹 Cleaning IIS environment..."
if exist "C:\inetpub\wwwroot\SimpleIISApp" (
    rmdir /s /q "C:\inetpub\wwwroot\SimpleIISApp" 2>>"%ERROR_LOG%"
    call :log_and_echo "    ✓ Cleaned IIS directory"
) else (
    call :log_and_echo "    ✓ IIS directory was already clean"
)

call :log_and_echo ""
call :log_and_echo "[2/7] Publishing application..."
echo [%time%] Running: dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity detailed >> "%LOG_FILE%"
echo [%time%] DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA% >> "%LOG_FILE%"
echo [%time%] DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL% >> "%LOG_FILE%"
set DD_GIT_COMMIT_SHA=%DD_GIT_COMMIT_SHA%&& set DD_GIT_COMMIT_SHA_SHORT=%DD_GIT_COMMIT_SHA_SHORT%&& set DD_GIT_BRANCH=%DD_GIT_BRANCH%&& set DD_GIT_REPOSITORY_URL=%DD_GIT_REPOSITORY_URL%&& set DD_GIT_COMMIT_MESSAGE=%DD_GIT_COMMIT_MESSAGE%&& set DD_DEPLOYMENT_VERSION=%DD_DEPLOYMENT_VERSION%&& set DD_DEPLOYMENT_TIME=%DD_DEPLOYMENT_TIME%&& dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity detailed 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
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
    echo Auto-exiting due to build failure...
    :: Clean up lock file on error
    if exist "logs\deploy_admin_running.lock" del "logs\deploy_admin_running.lock" >nul
    exit /b 1
)
call :log_and_echo "    ✓ Published"

call :log_and_echo ""
call :log_and_echo "[3/7] Creating IIS directory..."
if not exist "C:\inetpub\wwwroot\SimpleIISApp" mkdir "C:\inetpub\wwwroot\SimpleIISApp" 2>>"%ERROR_LOG%"
call :log_and_echo "    ✓ IIS directory created"

call :log_and_echo ""
call :log_and_echo "[4/7] Copying files to IIS directory..."
echo [%time%] Running: xcopy to C:\inetpub\wwwroot\SimpleIISApp\ >> "%LOG_FILE%"
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\SimpleIISApp\" /E /I /Y 1>>"%LOG_FILE%" 2>>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "    ❌ Copy failed!"
    call :log_and_echo "❌ Deployment failed. Check logs:"
    call :log_and_echo "   Main log: %LOG_FILE%"
    call :log_and_echo "   Error log: %ERROR_LOG%"
    echo.
    echo Auto-exiting due to copy failure...
    :: Clean up lock file on error
    if exist "logs\deploy_admin_running.lock" del "logs\deploy_admin_running.lock" >nul
    exit /b 1
)
call :log_and_echo "    ✓ Files copied to IIS directory"

call :log_and_echo ""
call :log_and_echo "[5/7] Final verification..."
call :log_and_echo "   ✓ Verifying published files exist"
if exist "C:\inetpub\wwwroot\SimpleIISApp\SimpleIISApp.dll" (
    call :log_and_echo "   ✓ Application DLL found"
) else (
    call :log_and_echo "   ⚠️ Application DLL not found - check copy operation"
)

call :log_and_echo ""
call :log_and_echo "[6/7] Restarting IIS..."
call :log_and_echo "   🔄 Performing IIS restart for clean deployment..."
iisreset >nul 2>>%ERROR_LOG%
if %ERRORLEVEL% neq 0 (
    call :log_and_echo "   ⚠️ IIS restart failed - application may need manual restart"
    call :log_and_echo "   Run 'iisreset' manually as Administrator if needed"
) else (
    call :log_and_echo "   ✓ IIS restarted successfully"
)

call :log_and_echo ""
call :log_and_echo "[7/7] Deployment Complete!"
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

echo Script will auto-exit in 2 seconds...
timeout /t 2 >nul
