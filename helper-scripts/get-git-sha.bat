@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: Git SHA Raw Text Extraction Demo
:: ============================================================================
:: This file demonstrates multiple ways to get Git SHA in raw text format
:: Useful for deployment scripts, versioning, and CI/CD pipelines
:: ============================================================================

echo.
echo ================================
echo Git SHA Raw Text Extraction Demo
echo ================================
echo.

:: Check if we're in a git repository
if not exist ".git" (
    echo ❌ Not in a Git repository!
    echo Please run this from a directory with a .git folder.
    pause
    exit /b 1
)

echo ✅ Git repository detected
echo.

:: Method 1: Using for /f with git rev-parse HEAD (RECOMMENDED)
echo 📋 Method 1: for /f %%i in ('git rev-parse HEAD') do set SHA=%%i
for /f %%i in ('git rev-parse HEAD 2^>nul') do set SHA1=%%i
echo    Result: %SHA1%
echo    Length: %SHA1:~0,40%
echo.

:: Method 2: Using temporary file
echo 📋 Method 2: git rev-parse HEAD > temp.txt method
git rev-parse HEAD > temp_sha.txt 2>nul
set /p SHA2=<temp_sha.txt
del temp_sha.txt >nul 2>&1
echo    Result: %SHA2%
echo.

:: Method 3: Using PowerShell
echo 📋 Method 3: PowerShell wrapper
for /f %%i in ('powershell -c "git rev-parse HEAD" 2^>nul') do set SHA3=%%i
echo    Result: %SHA3%
echo.

:: Method 4: Using git log format
echo 📋 Method 4: git log --format
for /f %%i in ('git log -1 --format^=%%H 2^>nul') do set SHA4=%%i
echo    Result: %SHA4%
echo.

:: Method 5: Short SHA
echo 📋 Method 5: Short SHA (7 characters)
for /f %%i in ('git rev-parse --short HEAD 2^>nul') do set SHA5=%%i
echo    Result: %SHA5% (length: 7)
echo.

:: Additional Git information
echo ================================
echo 🔍 Additional Git Information
echo ================================
echo.

:: Branch name
for /f %%i in ('git rev-parse --abbrev-ref HEAD 2^>nul') do set BRANCH=%%i
echo 🌿 Branch: %BRANCH%

:: Commit message
for /f "delims=" %%i in ('git log -1 --pretty^=format:"%%s" 2^>nul') do set MESSAGE=%%i
echo 💬 Message: %MESSAGE%

:: Author
for /f "delims=" %%i in ('git log -1 --pretty^=format:"%%an" 2^>nul') do set AUTHOR=%%i
echo 👤 Author: %AUTHOR%

:: Date
for /f "delims=" %%i in ('git log -1 --pretty^=format:"%%ad" --date^=short 2^>nul') do set DATE=%%i
echo 📅 Date: %DATE%

echo.
echo ================================
echo ✅ All Methods Completed
echo ================================
echo.
echo 🎯 RECOMMENDED for batch files: Method 1
echo    for /f %%i in ('git rev-parse HEAD') do set SHA=%%i
echo.
echo 💡 This is what the deployment scripts use!
echo.

pause
