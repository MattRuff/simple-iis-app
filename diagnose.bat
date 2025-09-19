@echo off
echo ========================================
echo   DIAGNOSTIC SCRIPT
echo ========================================
echo.

echo ✅ Script is running!
echo.

echo 🔍 Current Directory: %CD%
echo.

echo 📁 Files in current directory:
dir /B
echo.

echo 👤 Checking Administrator privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ NOT running as Administrator
    echo 💡 Right-click this file and select "Run as administrator"
) else (
    echo ✅ Running as Administrator
)
echo.

echo 🔧 Checking for .NET...
dotnet --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ .NET CLI not found!
    echo 💡 Install .NET 9.0 SDK from: https://dotnet.microsoft.com/download/dotnet/9.0
) else (
    echo ✅ .NET found:
    dotnet --version
)
echo.

echo 📋 Checking project files...
if exist "simple-iis-app.csproj" (
    echo ✅ simple-iis-app.csproj found
) else (
    echo ❌ simple-iis-app.csproj NOT found
)

if exist "Program.cs" (
    echo ✅ Program.cs found
) else (
    echo ❌ Program.cs NOT found
)

if exist "deploy-run-as-admin.bat" (
    echo ✅ deploy-run-as-admin.bat found
) else (
    echo ❌ deploy-run-as-admin.bat NOT found
)
echo.

echo 🌐 Checking IIS...
if exist "C:\inetpub\wwwroot" (
    echo ✅ IIS directory exists: C:\inetpub\wwwroot
) else (
    echo ❌ IIS directory NOT found: C:\inetpub\wwwroot
)
echo.

echo ========================================
echo   DIAGNOSIS COMPLETE
echo ========================================
echo.
echo 💡 If you see any ❌ above, fix those issues first!
echo.
echo Press any key to exit...
pause >nul
