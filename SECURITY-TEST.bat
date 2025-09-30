@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: DATADOG ASM SECURITY TESTING SCRIPT
:: =============================================================================
:: This script generates security signals for Datadog ASM testing without
:: causing significant memory or CPU impact on the target application.
:: 
:: The attacks are designed to trigger ASM detection patterns but not
:: actually exploit vulnerabilities in the application.
:: =============================================================================

echo.
echo ========================================
echo 🛡️  DATADOG ASM SECURITY TESTING
echo ========================================
echo.
echo This script will generate security signals for testing
echo Datadog Application Security Management (ASM) detection.
echo.
echo ⚠️  SAFE TESTING: These attacks will NOT harm your application
echo ✅ ASM DETECTION: Will generate security alerts in Datadog
echo.

set /p TARGET_URL="Enter target URL (default: http://localhost:8080): "
if "%TARGET_URL%"=="" set TARGET_URL=http://localhost:8080

set /p DELAY="Enter delay between tests in seconds (default: 3): "
if "%DELAY%"=="" set DELAY=3

echo.
echo 🎯 Target: %TARGET_URL%
echo ⏱️  Delay: %DELAY% seconds between tests
echo.
pause

:: Create logs directory
if not exist "security-test-logs" mkdir security-test-logs
set LOG_FILE=security-test-logs\security-test_%date:~-4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%.log

echo Starting security test at %date% %time% > "%LOG_FILE%"
echo Target: %TARGET_URL% >> "%LOG_FILE%"

echo.
echo 📝 Logging to: %LOG_FILE%
echo.

:: Test counter
set TEST_COUNT=0

:: =============================================================================
:: TEST 1: SQL INJECTION PATTERNS (OWASP A03 - Injection)
:: =============================================================================
echo 🗃️  TEST 1: SQL Injection Detection >> "%LOG_FILE%"
echo 🗃️  TEST 1: SQL Injection Detection (OWASP A03)
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: SQL Injection - Classic OR bypass
powershell -Command "try { $body = @{errorType = \"' OR '1'='1 --\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ SQL injection pattern sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo SQL Injection test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: SQL Injection - UNION SELECT
powershell -Command "try { $body = @{errorType = \"' UNION SELECT * FROM users --\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ SQL UNION pattern sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo SQL Injection test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: SQL Injection - Comment bypass
powershell -Command "try { $body = @{errorType = \"admin'--\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ SQL comment bypass sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo SQL Injection test 3 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 2: XSS PATTERNS (OWASP A03 - Injection)
:: =============================================================================
echo. 
echo 🎭 TEST 2: XSS Detection (OWASP A03) >> "%LOG_FILE%"
echo 🎭 TEST 2: XSS Detection (OWASP A03)
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: XSS - Script tag injection
powershell -Command "try { $body = @{errorType = \"<script>alert('XSS')</script>\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ XSS script tag sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo XSS test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: XSS - Image onerror
powershell -Command "try { $body = @{errorType = \"<img src=x onerror=alert('XSS')>\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ XSS image onerror sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo XSS test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: XSS - SVG onload
powershell -Command "try { $body = @{errorType = \"<svg onload=alert('XSS')>\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ XSS SVG onload sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo XSS test 3 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 3: COMMAND INJECTION PATTERNS (OWASP A03 - Injection)
:: =============================================================================
echo.
echo 💻 TEST 3: Command Injection Detection (OWASP A03) >> "%LOG_FILE%"
echo 💻 TEST 3: Command Injection Detection (OWASP A03)
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Command Injection - Semicolon separator
powershell -Command "try { $body = @{errorType = \"; whoami\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ Command injection (;) sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Command injection test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Command Injection - Pipe operator
powershell -Command "try { $body = @{errorType = \"| dir\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ Command injection (|) sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Command injection test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Command Injection - AND operator
powershell -Command "try { $body = @{errorType = \"&& powershell.exe -Command Get-Process\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ Command injection (&&) sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Command injection test 3 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 4: PATH TRAVERSAL PATTERNS (OWASP A05 - Security Misconfiguration)
:: =============================================================================
echo.
echo 📁 TEST 4: Path Traversal Detection (OWASP A05) >> "%LOG_FILE%"
echo 📁 TEST 4: Path Traversal Detection (OWASP A05)
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Path Traversal - Unix style
powershell -Command "try { Invoke-RestMethod -Uri '%TARGET_URL%/api/metrics?file=../../../../etc/passwd' -TimeoutSec 5 | Out-Null; Write-Host '✅ Path traversal (Unix) sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Path traversal test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Path Traversal - Windows style
powershell -Command "try { Invoke-RestMethod -Uri '%TARGET_URL%/api/metrics?file=..\\..\\..\\windows\\system32\\drivers\\etc\\hosts' -TimeoutSec 5 | Out-Null; Write-Host '✅ Path traversal (Windows) sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Path traversal test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 5: AUTHENTICATION BYPASS PATTERNS (OWASP A01 - Broken Access Control)
:: =============================================================================
echo.
echo 🔐 TEST 5: Authentication Bypass Detection (OWASP A01) >> "%LOG_FILE%"
echo 🔐 TEST 5: Authentication Bypass Detection (OWASP A01)
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Auth Bypass - Fake admin cookie
powershell -Command "try { $headers = @{'Cookie' = 'admin=true; role=administrator'}; Invoke-RestMethod -Uri '%TARGET_URL%/Dashboard' -Headers $headers -TimeoutSec 5 | Out-Null; Write-Host '✅ Fake admin cookie sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Auth bypass test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Auth Bypass - Fake JWT token
powershell -Command "try { $headers = @{'Authorization' = 'Bearer fake-jwt-token-12345'}; Invoke-RestMethod -Uri '%TARGET_URL%/Dashboard' -Headers $headers -TimeoutSec 5 | Out-Null; Write-Host '✅ Fake JWT token sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Auth bypass test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 6: BUSINESS LOGIC ATTACKS
:: =============================================================================
echo.
echo 💼 TEST 6: Business Logic Attack Detection >> "%LOG_FILE%"
echo 💼 TEST 6: Business Logic Attack Detection
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Business Logic - Negative values
powershell -Command "try { $body = @{errorType = \"-999999\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ Negative value attack sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Business logic test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Business Logic - Extreme values
powershell -Command "try { $body = @{errorType = \"999999999999999\"}; Invoke-RestMethod -Uri '%TARGET_URL%/api/trigger-error' -Method Post -Body $body -TimeoutSec 5 | Out-Null; Write-Host '✅ Extreme value attack sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Business logic test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: TEST 7: RECONNAISSANCE PATTERNS
:: =============================================================================
echo.
echo 🔍 TEST 7: Reconnaissance Detection >> "%LOG_FILE%"
echo 🔍 TEST 7: Reconnaissance Detection
echo.

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Reconnaissance - System information gathering
powershell -Command "try { Invoke-RestMethod -Uri '%TARGET_URL%/api/metrics' -TimeoutSec 5 | Out-Null; Write-Host '✅ System info gathering sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Reconnaissance test 1 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

set /a TEST_COUNT+=1
echo Test %TEST_COUNT%: Reconnaissance - Git information gathering  
powershell -Command "try { Invoke-RestMethod -Uri '%TARGET_URL%/api/git-info' -TimeoutSec 5 | Out-Null; Write-Host '✅ Git info gathering sent' -ForegroundColor Green } catch { Write-Host '🚫 Request failed (possibly blocked)' -ForegroundColor Yellow }"
echo Reconnaissance test 2 completed >> "%LOG_FILE%"
timeout /t %DELAY% >nul

:: =============================================================================
:: COMPLETION
:: =============================================================================
echo.
echo ========================================
echo ✅ SECURITY TESTING COMPLETED
echo ========================================
echo.
echo 📊 Total tests executed: %TEST_COUNT%
echo 🎯 Target tested: %TARGET_URL%
echo 📝 Log file: %LOG_FILE%
echo ⏱️  Test duration: Approximately %TEST_COUNT% minutes
echo.
echo 🛡️  DATADOG ASM DASHBOARD:
echo Check your Datadog ASM dashboard for:
echo • Security signals and attack detections
echo • Attacker IP analysis and reputation
echo • Attack pattern classification
echo • Blocked vs allowed requests
echo • Security traces and spans
echo.

echo Security testing completed at %date% %time% >> "%LOG_FILE%"
echo Total tests: %TEST_COUNT% >> "%LOG_FILE%"

echo 🔗 Next Steps:
echo 1. Login to your Datadog account
echo 2. Navigate to Security ^> Application Security
echo 3. Check for new security signals from this testing
echo 4. Review attack patterns detected
echo 5. Verify ASM is properly configured and detecting threats
echo.

pause

