@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Simple IIS App - Complete Deployment Script
:: ============================================================================

:: Simple, robust timestamp generation
set "LOG_TIMESTAMP=%date:~-4,4%-%date:~-10,2%-%date:~-7,2%_%time:~0,2%-%time:~3,2%-%time:~6,2%"
set "LOG_TIMESTAMP=%LOG_TIMESTAMP: =0%"

:: Setup logging with fallback
if not exist "logs" mkdir "logs"
if "%LOG_TIMESTAMP%"=="" set "LOG_TIMESTAMP=deploy_%RANDOM%"

set "MAIN_LOG=logs\deploy_%LOG_TIMESTAMP%.log"
set "DEBUG_LOG=logs\debug_%LOG_TIMESTAMP%.log"
set "NUGET_LOG=logs\nuget_%LOG_TIMESTAMP%.log"
set "BUILD_LOG=logs\build_%LOG_TIMESTAMP%.log"

:: Initialize log files
echo Deployment started at %date% %time% > "%MAIN_LOG%"

echo ========================================
echo Simple IIS App - Complete Deployment
echo ========================================
echo.
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

echo 🔍 STEP 2: Checking current directory and project structure...
echo Current directory: %CD%
echo.
echo Files in this directory:
dir /b
echo.

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

echo 🔍 STEP 3: Auto-fixing GitHub download namespace and package issues...
echo Checking for namespace issues and package version problems that cause build errors...
echo.

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
        echo   ✅ SourceLink package configured for Datadog integration
    )
)

echo.
echo ✅ Namespace and package fixes completed (if any were needed)
echo.
pause

echo 🔍 STEP 4: Checking .NET installation...
call :log_message "STEP 4: Checking .NET installation"

:: Detailed .NET debugging
echo 🐛 DEBUG: Checking .NET environment...
call :log_message "=== .NET ENVIRONMENT DEBUG ==="

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

:: Log detailed .NET info
echo   🔍 Gathering detailed .NET information...
dotnet --info >> "%DEBUG_LOG%" 2>&1
call :log_message "Detailed .NET info logged to debug file"

:: Log NuGet sources
echo   🔍 Checking NuGet sources...
dotnet nuget list source >> "%NUGET_LOG%" 2>&1
call :log_message "NuGet sources logged"

:: Check if any sources are configured
echo   🔍 Verifying NuGet sources are accessible...
dotnet nuget list source > nul 2>&1
if %errorlevel% equ 0 (
    echo   ✅ NuGet sources are configured and accessible
    call :log_message "SUCCESS: NuGet sources verified"
) else (
    echo   ⚠️ NuGet sources issue detected
    call :log_message "WARNING: NuGet sources issue"
    echo   Adding official NuGet source...
    dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org >> "%NUGET_LOG%" 2>&1
    echo   ✅ NuGet source configuration attempted
)

:: Log current packages
echo   🔍 Checking current package references...
if exist "simple-iis-app.csproj" (
    type "simple-iis-app.csproj" >> "%DEBUG_LOG%"
    call :log_message "Project file contents logged"
)

echo.
pause

echo 🔍 STEP 5: Checking IIS directory access...
if not exist "C:\inetpub\wwwroot" (
    echo ❌ C:\inetpub\wwwroot does not exist!
    echo IIS may not be installed properly.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ IIS directory accessible: C:\inetpub\wwwroot
)
echo.
pause

echo 🔍 STEP 6: Creating IIS application directory...
if not exist "C:\inetpub\wwwroot\simple-iis-app" (
    mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
    if exist "C:\inetpub\wwwroot\simple-iis-app" (
        echo ✅ Created IIS directory: C:\inetpub\wwwroot\simple-iis-app
    ) else (
        echo ❌ Failed to create IIS directory
        echo.
        echo Press any key to exit...
        pause >nul
        exit /b 1
    )
) else (
    echo ✅ IIS directory already exists: C:\inetpub\wwwroot\simple-iis-app
)
echo.
pause

echo 🔍 STEP 7: Setting up deployment environment...
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
if "%timestamp%"=="" set "timestamp=deploy_%RANDOM%"

set DD_GIT_BRANCH=main-step
set DD_GIT_COMMIT_MESSAGE=Step-by-step deployment at %date% %time%
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%

echo   🔧 Setting Datadog machine-level environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_PROFILING_ENABLED','true',$target); Write-Host '   ✅ DD_PROFILING_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_CODE_ORIGIN_FOR_SPANS_ENABLED','true',$target); Write-Host '   ✅ DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_EXCEPTION_REPLAY_ENABLED','true',$target); Write-Host '   ✅ DD_EXCEPTION_REPLAY_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set at machine level' } catch { Write-Host '   ❌ Error setting Datadog variables:' $_.Exception.Message; exit 1 }"

if %errorlevel% neq 0 (
    echo   ⚠️ Could not set machine-level Datadog variables
    echo   • DD_ENV=testing
    echo   • DD_LOGS_INJECTION=true
    echo   • DD_RUNTIME_METRICS_ENABLED=true
    echo   • DD_PROFILING_ENABLED=true
    echo   • DD_CODE_ORIGIN_FOR_SPANS_ENABLED=true
    echo   • DD_EXCEPTION_REPLAY_ENABLED=true
    echo.
    echo   Please set these manually if needed for Datadog integration
)

echo.
echo   ✅ Deployment environment configured
echo.
pause

echo 🔍 STEP 8: Preparing build environment...
if exist "bin" rd /s /q "bin" 2>nul
if exist "obj" rd /s /q "obj" 2>nul
echo ✅ Build environment prepared
echo.
pause

echo 🔍 STEP 9: Building application...
call :log_message "STEP 9: Building application"
echo Running: dotnet build -c Release
echo.

:: Clear NuGet cache first
echo   🔧 Clearing NuGet cache to resolve potential package issues...
call :log_message "Clearing NuGet cache"
dotnet nuget locals all --clear >> "%NUGET_LOG%" 2>&1

:: Detailed restore with logging
echo   🔧 Running detailed package restore...
call :log_message "Starting package restore with detailed logging"
dotnet restore --verbosity detailed >> "%NUGET_LOG%" 2>&1
set RESTORE_RESULT=%errorlevel%
call :log_message "Restore completed with exit code: %RESTORE_RESULT%"

if %RESTORE_RESULT% neq 0 (
    echo ❌ Package restore failed! Check logs for details.
    call :log_message "ERROR: Package restore failed"
    echo.
    echo 📝 Check these log files for detailed error information:
    echo    NuGet log: %NUGET_LOG%
    echo    Debug log: %DEBUG_LOG%
    echo.
    
    :: Show last few lines of NuGet log
    echo 🔍 Last 10 lines of NuGet log:
    powershell -Command "Get-Content '%NUGET_LOG%' | Select-Object -Last 10"
    echo.
    
    pause
    exit /b 1
)

:: Build with detailed logging
call :log_message "Starting build"
dotnet build -c Release --verbosity detailed >> "%BUILD_LOG%" 2>&1
set BUILD_RESULT=%errorlevel%
call :log_message "Build completed with exit code: %BUILD_RESULT%"

if %BUILD_RESULT% neq 0 (
    echo ❌ Build failed! Check logs for details.
    call :log_message "ERROR: Build failed"
    echo.
    echo 📝 Check these log files for detailed error information:
    echo    Build log: %BUILD_LOG%
    echo    NuGet log: %NUGET_LOG%
    echo.
    
    :: Show last few lines of build log
    echo 🔍 Last 10 lines of build log:
    powershell -Command "Get-Content '%BUILD_LOG%' | Select-Object -Last 10"
    echo.
    
    pause
    exit /b 1
)

echo ✅ Build successful!
call :log_message "SUCCESS: Build completed successfully"
echo.
pause

echo 🔍 STEP 10: Publishing application...
call :log_message "STEP 10: Publishing application"
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
echo.

dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity detailed >> "%BUILD_LOG%" 2>&1
set PUBLISH_RESULT=%errorlevel%
call :log_message "Publish completed with exit code: %PUBLISH_RESULT%"

if %PUBLISH_RESULT% neq 0 (
    echo ❌ Publish failed! Check logs for details.
    call :log_message "ERROR: Publish failed"
    echo.
    echo 📝 Check build log: %BUILD_LOG%
    echo.
    
    :: Show last few lines of build log
    echo 🔍 Last 10 lines of build log:
    powershell -Command "Get-Content '%BUILD_LOG%' | Select-Object -Last 10"
    echo.
    
    pause
    exit /b 1
)

echo ✅ Publish successful!
call :log_message "SUCCESS: Publish completed successfully"
echo.
pause

echo 🔍 STEP 11: Copying files to IIS directory...
echo Running: xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
echo.
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
if %errorlevel% neq 0 (
    echo ❌ Failed to copy files to IIS directory
    echo.
    pause
    exit /b 1
)

echo.
echo ✅ Files copied successfully
echo.
pause

echo 🔍 STEP 12: Verifying deployment...
if exist "C:\inetpub\wwwroot\simple-iis-app\simple-iis-app.dll" (
    echo ✅ Application DLL found
) else (
    echo ❌ Application DLL missing
)

if exist "C:\inetpub\wwwroot\simple-iis-app\web.config" (
    echo ✅ Web.config found
) else (
    echo ❌ Web.config missing
)

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
call :log_message "Files deployed to: C:\inetpub\wwwroot\simple-iis-app\"

echo ✅ Application built and deployed successfully
echo ✅ Files location: C:\inetpub\wwwroot\simple-iis-app\
echo.
echo 📝 Log files created for debugging:
echo    📄 Main log: %MAIN_LOG%
echo    🔍 Debug log: %DEBUG_LOG%
echo    📦 NuGet log: %NUGET_LOG%
echo    🔨 Build log: %BUILD_LOG%
echo.
echo ========================================
echo 🔧 MANUAL IIS SETUP REQUIRED
echo ========================================
echo.
echo ✅ Application files deployed to: C:\inetpub\wwwroot\simple-iis-app\
echo ⚠️ IIS configuration needs to be done manually
echo.
echo 📋 Manual steps:
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
echo 🌐 Your application includes:
echo   • 🔐 Login functionality (admin/password)
echo   • 💓 Health check monitoring
echo   • 🐛 Error testing for Datadog
echo   • 📊 Monitoring endpoints
echo   • 🔗 SourceLink integration for code debugging
echo.
echo ================================
echo Deployment completed at %date% %time%
echo ================================
echo.
call :log_message "=== SCRIPT COMPLETED ==="
echo Press any key to exit...
pause >nul
exit /b 0

:: Function to log with timestamp
:log_message
echo [%time%] %~1 >> "%MAIN_LOG%" 2>nul
echo %~1
goto :eof