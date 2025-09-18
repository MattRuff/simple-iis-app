@echo off
echo ================================
echo  Simple IIS App - Admin Deploy
echo ================================
echo.

:: Check for administrator privileges
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ This script requires Administrator privileges!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo ✅ Running as Administrator
echo.

echo ⚠️  IMPORTANT: Ensure .NET 9.0 Hosting Bundle is installed!
echo    Download from: https://dotnet.microsoft.com/en-us/download/dotnet/9.0
echo    Get: "ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"
echo.

echo [1/5] Cleaning previous builds...
if exist "bin\Release\net9.0\publish" rmdir /s /q "bin\Release\net9.0\publish"
echo     ✓ Cleaned

echo.
echo [2/5] Publishing application...
dotnet publish -c Release -o bin\Release\net9.0\publish
if %ERRORLEVEL% neq 0 (
    echo     ❌ Publish failed!
    pause
    exit /b 1
)
echo     ✓ Published

echo.
echo [3/5] Creating IIS directory...
if not exist "C:\inetpub\wwwroot\SimpleIISApp" mkdir "C:\inetpub\wwwroot\SimpleIISApp"
echo     ✓ IIS directory created

echo.
echo [4/5] Copying files to IIS directory...
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\SimpleIISApp\" /E /I /Y /Q
if %ERRORLEVEL% neq 0 (
    echo     ❌ Copy failed!
    pause
    exit /b 1
)
echo     ✓ Files copied to IIS directory

echo.
echo [5/5] Deployment Complete!
echo.
echo ================================
echo     🎉 Ready for IIS Setup! 🎉
echo ================================
echo.
echo ✅ Published files are in: bin\Release\net9.0\publish\
echo ✅ IIS files are in: C:\inetpub\wwwroot\SimpleIISApp\
echo.
echo 📋 Next steps:
echo 1. Open IIS Manager
echo 2. Create new website with these EXACT settings:
echo    • Site name: SimpleIISApp
echo    • Physical path: C:\inetpub\wwwroot\SimpleIISApp
echo    • Port: 8080 (or any available port)
echo 3. Set Application Pool to "No Managed Code"
echo 4. Ensure .NET 9.0 Runtime is installed
echo 5. Browse to your site!
echo.
echo 🌐 Point IIS to: C:\inetpub\wwwroot\SimpleIISApp
echo     (NOT to bin\Release\net9.0\publish)
echo     (NOT to your source folder)
echo     (NOT to your Desktop)
echo.
echo ================================
pause
