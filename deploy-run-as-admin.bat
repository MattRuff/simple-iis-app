@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: BULLETPROOF DEPLOYMENT SCRIPT - NO LOOPS, CLEAR ERRORS
:: ============================================================================

echo.
echo ✅ Script started successfully!
echo.

:: Check for administrator privileges first
echo 👤 Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo ❌ ADMIN REQUIRED: This script must run as Administrator!
    echo.
    echo 🔧 TO FIX:
    echo 1. Close this window
    echo 2. Right-click this file: deploy-run-as-admin.bat
    echo 3. Select "Run as administrator"
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ Running as Administrator
)

echo ========================================
echo   simple-iis-app - Bulletproof Deploy  
echo ========================================
echo.

:: Step 1: CRITICAL - Check if we're in the right directory
echo [STEP 1] Verifying project directory...
if not exist "simple-iis-app.csproj" (
    echo.
    echo ❌ FATAL ERROR: simple-iis-app.csproj not found!
    echo.
    echo 🔍 Current directory: %CD%
    echo.
    echo 📁 Files in current directory:
    dir /B
    echo.
    echo ❌ You are NOT in the simple-iis-app project folder!
    echo.
    echo 🔧 TO FIX THIS:
    echo 1. Extract the ZIP file completely
    echo 2. Navigate to the simple-iis-app subfolder
    echo 3. Run this script from inside that folder
    echo.
    echo 📋 Expected files in the correct directory:
    echo   - simple-iis-app.csproj
    echo   - Program.cs
    echo   - deploy-run-as-admin.bat
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Found simple-iis-app.csproj - correct directory confirmed
)

if not exist "Program.cs" (
    echo ❌ FATAL ERROR: Program.cs not found!
    echo This doesn't look like the simple-iis-app project folder.
    pause
    exit /b 1
) else (
    echo ✅ Found Program.cs - project files confirmed
)

:: Step 2: Check for .NET
echo.
echo [STEP 2] Checking .NET installation...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ FATAL ERROR: .NET CLI not found!
    echo.
    echo Install .NET 9.0 SDK from: https://dotnet.microsoft.com/download/dotnet/9.0
    pause
    exit /b 1
) else (
    for /f %%i in ('dotnet --version 2^>nul') do set DOTNET_VERSION=%%i
    echo ✅ .NET version: !DOTNET_VERSION!
)

:: Step 3: Clean and simple build
echo.
echo [STEP 3] Building application...

:: Clean first
if exist "bin" rmdir /s /q "bin" 2>nul
if exist "obj" rmdir /s /q "obj" 2>nul
echo ✅ Cleaned old build files

:: Simple publish command
echo 🔨 Publishing application...
dotnet publish -c Release -o bin\Release\net9.0\publish --verbosity minimal

if %errorlevel% neq 0 (
    echo.
    echo ❌ BUILD FAILED!
    echo.
    echo 🔍 Common fixes:
    echo 1. Make sure you're in the SimpleIISApp folder (not parent folder)
    echo 2. Check that SimpleIISApp.csproj exists
    echo 3. Try: dotnet restore
    echo 4. Try: dotnet clean
    echo.
    echo 💡 You can also try building manually:
    echo    dotnet restore
    echo    dotnet build
    echo    dotnet publish -c Release
    echo.
    pause
    exit /b 1
) else (
    echo ✅ Build successful
)

:: Step 4: Verify published files exist
echo.
echo [STEP 4] Verifying published files...
if not exist "bin\Release\net9.0\publish\simple-iis-app.dll" (
    echo ❌ FATAL ERROR: simple-iis-app.dll not found in publish folder!
    echo.
    echo 📁 Checking what was published:
    if exist "bin\Release\net9.0\publish" (
        dir "bin\Release\net9.0\publish" /B
    ) else (
        echo ❌ Publish folder doesn't exist!
    )
    pause
    exit /b 1
) else (
    echo ✅ Application DLL found in publish folder
)

:: Step 5: Prepare IIS directory
echo.
echo [STEP 5] Preparing IIS directory...

:: Stop any existing app pools
powershell -Command "try { Import-Module WebAdministration -ErrorAction SilentlyContinue; Stop-WebAppPool 'simple-iis-app' -ErrorAction SilentlyContinue; Stop-WebAppPool 'DefaultAppPool' -ErrorAction SilentlyContinue } catch { }" >nul 2>nul

:: Clean and create IIS directory
if exist "C:\inetpub\wwwroot\simple-iis-app" (
    rmdir /s /q "C:\inetpub\wwwroot\simple-iis-app"
    echo ✅ Cleaned existing IIS directory
)

mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
if not exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo ❌ FATAL ERROR: Cannot create C:\inetpub\wwwroot\simple-iis-app
    echo Make sure you're running as Administrator and IIS is installed.
    pause
    exit /b 1
) else (
    echo ✅ Created IIS directory
)

:: Step 6: Copy files
echo.
echo [STEP 6] Copying files to IIS...
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y >nul
if %errorlevel% neq 0 (
    echo ❌ FATAL ERROR: File copy failed!
    echo Make sure you're running as Administrator.
    pause
    exit /b 1
) else (
    echo ✅ Files copied successfully
)

:: Verify copy worked
if not exist "C:\inetpub\wwwroot\simple-iis-app\simple-iis-app.dll" (
    echo ❌ FATAL ERROR: simple-iis-app.dll not found in IIS directory after copy!
    pause
    exit /b 1
) else (
    echo ✅ Verified: Application files in IIS directory
)

:: Step 7: Final message
echo.
echo ========================================
echo   🎉 DEPLOYMENT SUCCESSFUL! 🎉
echo ========================================
echo.
echo ✅ Application built successfully
echo ✅ Files copied to: C:\inetpub\wwwroot\simple-iis-app\
echo.
echo 📋 NEXT STEPS:
echo 1. Open IIS Manager
echo 2. Create new website:
echo    • Name: simple-iis-app
echo    • Path: C:\inetpub\wwwroot\simple-iis-app
echo    • Port: 8080
echo 3. Set Application Pool to "No Managed Code"
echo 4. Browse to your site!
echo.
echo 🌐 IIS Physical Path: C:\inetpub\wwwroot\simple-iis-app
echo.
pause
