@echo off
setlocal EnableDelayedExpansion

:: Check for administrator privileges first
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: Create logs directory and set timestamp
if not exist "logs" mkdir "logs"
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
if "%timestamp%"=="" set "timestamp=deploy_%RANDOM%"

set "LOG_FILE=logs\deploy_%timestamp%.log"
set "ERROR_LOG=logs\deploy_errors_%timestamp%.log"

echo ================================
echo Simple IIS App - Admin Deploy
echo ================================
echo.
echo ✅ Running as Administrator
echo 📄 Logging to: %LOG_FILE%
echo.

:: Check if we're in the right directory
if not exist "simple-iis-app.csproj" (
    echo ❌ FATAL ERROR: simple-iis-app.csproj not found!
    echo.
    echo 🔍 Current directory: %CD%
    echo.
    echo You are NOT in the simple-iis-app project folder!
    echo Navigate to the correct folder and try again.
    echo.
    pause
    exit /b 1
)

echo ✅ Found simple-iis-app.csproj - correct directory

:: Set environment variables
set DD_GIT_COMMIT_SHA=local-deploy-%timestamp%
set DD_GIT_COMMIT_SHA_SHORT=local-%RANDOM%
set DD_GIT_BRANCH=main-local
set DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git
set DD_GIT_COMMIT_MESSAGE=Local deployment at %date% %time%
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%

echo 🔍 Environment variables set
echo.

:: Clean previous builds
echo [1/5] Cleaning previous builds...
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish" 2>nul
if exist "bin\Debug" rmdir /s /q "bin\Debug" 2>nul
if exist "obj" rmdir /s /q "obj" 2>nul
echo ✓ Cleaned build artifacts

:: Clean IIS environment
echo [2/5] Cleaning IIS environment...
if exist "C:\inetpub\wwwroot\simple-iis-app" (
    rmdir /s /q "C:\inetpub\wwwroot\simple-iis-app" 2>nul
    echo ✓ Cleaned IIS directory
)

:: Create IIS directory
mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
if not exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo ❌ Failed to create C:\inetpub\wwwroot\simple-iis-app
    echo Make sure you're running as Administrator.
    pause
    exit /b 1
)
echo ✓ Created IIS directory

:: Build application
echo [3/5] Publishing application...
dotnet publish -c Release -o bin\Release\net9.0\publish 2>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed! Check error log: %ERROR_LOG%
    pause
    exit /b 1
)
echo ✓ Published successfully

:: Copy files to IIS
echo [4/5] Copying files to IIS...
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y 2>"%ERROR_LOG%"
if %ERRORLEVEL% neq 0 (
    echo ❌ Copy failed! Check error log: %ERROR_LOG%
    pause
    exit /b 1
)
echo ✓ Files copied successfully

:: Verify deployment
echo [5/5] Verifying deployment...
if exist "C:\inetpub\wwwroot\simple-iis-app\simple-iis-app.dll" (
    echo ✅ Application DLL found
) else (
    echo ❌ Application DLL not found - deployment may have failed
)

echo.
echo ================================
echo 🎉 DEPLOYMENT COMPLETED! 🎉
echo ================================
echo.
echo ✅ Files are in: C:\inetpub\wwwroot\simple-iis-app\
echo.
echo 📋 Next steps:
echo 1. Open IIS Manager
echo 2. Create new website:
echo    • Name: simple-iis-app
echo    • Path: C:\inetpub\wwwroot\simple-iis-app
echo    • Port: 8080
echo 3. Set Application Pool to "No Managed Code"
echo 4. Browse to your site!
echo.
pause
