@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo   SimpleIISApp Directory Finder
echo ========================================
echo.

:: Check if we're already in the right place
if exist "SimpleIISApp.csproj" (
    echo ✅ Found SimpleIISApp.csproj in current directory!
    echo ✅ You're in the right place. Running deployment...
    echo.
    goto :run_deployment
)

:: Check if we're in the parent directory
if exist "SimpleIISApp\SimpleIISApp.csproj" (
    echo ℹ️  Found SimpleIISApp folder. Navigating there...
    cd SimpleIISApp
    echo ✅ Now in SimpleIISApp directory
    goto :run_deployment
)

:: Look for the project file in common locations
echo 🔍 Searching for SimpleIISApp.csproj...
echo.

:: Check Downloads folder
for /d %%i in ("%USERPROFILE%\Downloads\simple-iis-app*") do (
    echo 🔍 Checking: %%i
    if exist "%%i\SimpleIISApp\SimpleIISApp.csproj" (
        echo ✅ Found SimpleIISApp project in: %%i\SimpleIISApp
        cd /d "%%i\SimpleIISApp"
        goto :run_deployment
    )
    if exist "%%i\SimpleIISApp.csproj" (
        echo ✅ Found SimpleIISApp project in: %%i
        cd /d "%%i"
        goto :run_deployment
    )
)

:: Check Desktop
for /d %%i in ("%USERPROFILE%\Desktop\simple-iis-app*") do (
    echo 🔍 Checking: %%i
    if exist "%%i\SimpleIISApp\SimpleIISApp.csproj" (
        echo ✅ Found SimpleIISApp project in: %%i\SimpleIISApp
        cd /d "%%i\SimpleIISApp"
        goto :run_deployment
    )
    if exist "%%i\SimpleIISApp.csproj" (
        echo ✅ Found SimpleIISApp project in: %%i
        cd /d "%%i"
        goto :run_deployment
    )
)

:: Not found
echo ❌ Could not find SimpleIISApp.csproj anywhere!
echo.
echo 📋 Manual steps:
echo 1. Extract the ZIP file to a clean folder (no spaces or special characters)
echo 2. Navigate to the SimpleIISApp subfolder
echo 3. Run deploy-admin.bat from there
echo.
echo 🔍 Current directory: %CD%
echo 📁 Files in current directory:
dir /B
echo.
pause
exit /b 1

:run_deployment
echo.
echo 📁 Current directory: %CD%
echo ✅ Found required files:
if exist "SimpleIISApp.csproj" echo   - SimpleIISApp.csproj
if exist "Program.cs" echo   - Program.cs  
if exist "deploy-admin.bat" echo   - deploy-admin.bat
if exist "deploy.bat" echo   - deploy.bat
echo.

:: Fix any path issues with parentheses
set "CURRENT_PATH=%CD%"
echo 🔍 Working directory: %CURRENT_PATH%

if "%CURRENT_PATH:~-1%"==")" (
    echo ⚠️  WARNING: Path contains parentheses which may cause issues!
    echo Consider extracting to a simpler path like C:\temp\simple-iis-app\
)

echo.
echo 🚀 Starting deployment in 3 seconds...
timeout /t 3

:: Run the deployment script
if exist "deploy-admin.bat" (
    echo Running deploy-admin.bat...
    call deploy-admin.bat
) else (
    echo ❌ deploy-admin.bat not found!
    echo Available files:
    dir /B *.bat
    pause
    exit /b 1
)
