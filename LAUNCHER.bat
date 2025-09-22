@echo off
echo ========================================
echo Simple IIS App - Deployment Launcher
echo ========================================
echo.
echo What would you like to do?
echo.
echo 1. Run DEBUG version (step-by-step analysis)
echo 2. Run NORMAL version (fast deployment)
echo 3. Exit
echo.
set /p CHOICE=Enter your choice (1-3): 

if "%CHOICE%"=="1" (
    echo.
    echo Launching DEBUG version...
    echo This will show each step and pause for you to review.
    echo.
    pause
    call DEBUG-DEPLOY.bat
) else if "%CHOICE%"=="2" (
    echo.
    echo Launching NORMAL version...
    echo.
    pause
    call DEPLOY-HERE.bat
) else if "%CHOICE%"=="3" (
    echo.
    echo Goodbye!
    exit /b 0
) else (
    echo.
    echo Invalid choice. Please run again and select 1, 2, or 3.
    pause
    exit /b 1
)

echo.
echo Script completed. Press any key to exit...
pause >nul

