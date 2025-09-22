@echo off
setlocal EnableDelayedExpansion

echo TEST 1: Basic script start
echo Current directory: %CD%
echo.

:: Test timestamp generation step by step
echo TEST 2: Testing timestamp generation...
echo Date: %date%
echo Time: %time%

:: Try simple timestamp first
set "TEST_TIMESTAMP=test_%RANDOM%"
echo Simple timestamp: %TEST_TIMESTAMP%

:: Test logs folder creation
echo TEST 3: Testing logs folder...
if not exist "logs" (
    echo Creating logs folder...
    mkdir "logs"
    if exist "logs" (
        echo ✅ Logs folder created
    ) else (
        echo ❌ Failed to create logs folder
    )
) else (
    echo ✅ Logs folder already exists
)

:: Test simple log file creation
echo TEST 4: Testing log file creation...
set "TEST_LOG=logs\test_%TEST_TIMESTAMP%.log"
echo Test log entry > "%TEST_LOG%"
if exist "%TEST_LOG%" (
    echo ✅ Test log file created: %TEST_LOG%
) else (
    echo ❌ Failed to create test log file
)

:: Test function call
echo TEST 5: Testing function...
call :test_function "Hello from function"

echo.
echo ========================================
echo All tests completed successfully!
echo ========================================
echo If you see this, the basic batch structure works.
echo The issue is likely in the complex timestamp parsing.
echo.
pause
exit /b 0

:test_function
echo Function called with: %~1
goto :eof
