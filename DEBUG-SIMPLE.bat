@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo DEBUG - Simple Directory Check
echo ========================================
echo.

echo 🔍 Current directory: %CD%
echo.

echo 🔍 Testing dir command...
dir /B 2>&1
set DIR_RESULT=%ERRORLEVEL%
echo 🔍 Dir command result: %DIR_RESULT%
echo.

echo 🔍 Checking for simple-iis-app.csproj...
if exist "simple-iis-app.csproj" (
    echo ✅ simple-iis-app.csproj EXISTS
) else (
    echo ❌ simple-iis-app.csproj NOT FOUND
)
echo.

echo 🔍 Checking for other project files...
if exist "Program.cs" (
    echo ✅ Program.cs exists
) else (
    echo ❌ Program.cs not found
)

if exist "Views" (
    echo ✅ Views folder exists
) else (
    echo ❌ Views folder not found
)
echo.

echo 🔍 All files in current directory:
dir 2>&1
echo.

echo ========================================
echo Debug completed. Press any key to exit.
pause >nul
