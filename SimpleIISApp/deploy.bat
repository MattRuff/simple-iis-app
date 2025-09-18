@echo off
echo ================================
echo  Simple IIS App - Deployment
echo ================================
echo.

echo [1/3] Cleaning previous builds...
if exist "bin\Release\net6.0\publish" rmdir /s /q "bin\Release\net6.0\publish"
echo     ✓ Cleaned

echo.
echo [2/3] Publishing application...
dotnet publish -c Release -o bin\Release\net6.0\publish
if %ERRORLEVEL% neq 0 (
    echo     ❌ Publish failed!
    pause
    exit /b 1
)
echo     ✓ Published

echo.
echo [3/3] Deployment ready!
echo.
echo Published files are in: bin\Release\net6.0\publish\
echo.
echo Next steps:
echo 1. Copy the 'publish' folder to your Windows server
echo 2. Create IIS site pointing to the publish folder
echo 3. Ensure .NET 6.0 Runtime is installed
echo 4. Browse to your site!
echo.
echo ================================
echo      Deployment Complete! 
echo ================================
pause
