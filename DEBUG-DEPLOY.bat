@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo DEBUG DEPLOY - Step by Step Analysis
echo ========================================
echo.

echo 🔍 STEP 1: Checking current directory...
echo Current directory: %CD%
echo.
echo Files in this directory:
dir /B
echo.
pause

echo 🔍 STEP 2: Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ NOT running as Administrator!
    echo.
    echo You MUST right-click this file and select "Run as administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ Running as Administrator
)
echo.
pause

echo 🔍 STEP 3: Checking for project file...
if not exist "simple-iis-app.csproj" (
    echo ❌ FATAL ERROR: simple-iis-app.csproj not found!
    echo.
    echo Files we can see:
    dir *.csproj /B 2>nul
    echo.
    echo You are NOT in the simple-iis-app project folder!
    echo Navigate to the correct folder and try again.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ Found simple-iis-app.csproj
)
echo.
pause

echo 🔍 STEP 4: Creating logs directory...
if not exist "logs" mkdir "logs"
if exist "logs" (
    echo ✅ Logs directory exists
) else (
    echo ❌ Failed to create logs directory
)
echo.
pause

echo 🔍 STEP 5: Setting timestamp...
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
if "%timestamp%"=="" set "timestamp=deploy_%RANDOM%"
echo ✅ Timestamp: %timestamp%
echo.
pause

echo 🔍 STEP 6: Setting up log files...
set "LOG_FILE=logs\deploy_%timestamp%.log"
set "ERROR_LOG=logs\deploy_errors_%timestamp%.log"
echo ✅ Log file: %LOG_FILE%
echo ✅ Error log: %ERROR_LOG%
echo.
pause

echo 🔍 STEP 7: Setting environment variables...
set DD_GIT_COMMIT_SHA=debug-deploy-%timestamp%
set DD_GIT_COMMIT_SHA_SHORT=debug-%RANDOM%
set DD_GIT_BRANCH=main-debug
set DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git
set DD_GIT_COMMIT_MESSAGE=Debug deployment at %date% %time%
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%
echo ✅ Environment variables set
echo.
pause

echo 🔍 STEP 8: Checking .NET installation...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET CLI not found!
    echo.
    echo Install .NET 9.0 SDK from: https://dotnet.microsoft.com/download/dotnet/9.0
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    for /f %%i in ('dotnet --version 2^>nul') do set DOTNET_VERSION=%%i
    echo ✅ .NET version: !DOTNET_VERSION!
)
echo.
pause

echo 🔍 STEP 9: Checking IIS directory access...
if not exist "C:\inetpub\wwwroot" (
    echo ❌ C:\inetpub\wwwroot does not exist!
    echo IIS may not be installed properly.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ C:\inetpub\wwwroot exists
)
echo.
pause

echo 🔍 STEP 10: Testing directory creation...
mkdir "C:\inetpub\wwwroot\simple-iis-app-test" 2>nul
if exist "C:\inetpub\wwwroot\simple-iis-app-test" (
    echo ✅ Can create directories in C:\inetpub\wwwroot
    rmdir "C:\inetpub\wwwroot\simple-iis-app-test" 2>nul
) else (
    echo ❌ Cannot create directories in C:\inetpub\wwwroot
    echo This usually means insufficient permissions.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
pause

echo ========================================
echo 🎉 ALL DIAGNOSTIC CHECKS PASSED! 🎉
echo ========================================
echo.
echo Your system should be able to run the deployment script.
echo If DEPLOY-HERE.bat is still failing, there may be a syntax error.
echo.
echo Would you like to continue with actual deployment? (Y/N)
set /p CONTINUE=
if /i "%CONTINUE%"=="Y" (
    echo.
    echo Starting actual deployment...
    goto DEPLOY
) else (
    echo.
    echo Debug complete. Press any key to exit...
    pause >nul
    exit /b 0
)

:DEPLOY
echo.
echo [1/5] Cleaning previous builds...
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish" 2>nul
if exist "bin\Debug" rmdir /s /q "bin\Debug" 2>nul
if exist "obj" rmdir /s /q "obj" 2>nul
echo ✓ Cleaned build artifacts
pause

echo [2/5] Cleaning IIS environment...
if exist "C:\inetpub\wwwroot\simple-iis-app" (
    rmdir /s /q "C:\inetpub\wwwroot\simple-iis-app" 2>nul
    echo ✓ Cleaned IIS directory
)
mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
echo ✓ Created IIS directory
pause

echo [3/5] Publishing application...
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
dotnet publish -c Release -o bin\Release\net9.0\publish
if %ERRORLEVEL% neq 0 (
    echo ❌ Build failed!
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo ✓ Published successfully
pause

echo [4/5] Copying files to IIS...
echo Running: xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
if %ERRORLEVEL% neq 0 (
    echo ❌ Copy failed!
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo ✓ Files copied successfully
pause

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
echo Press any key to exit...
pause >nul

