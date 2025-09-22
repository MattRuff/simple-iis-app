@echo off
setlocal EnableDelayedExpansion

echo ========================================
echo Simple IIS App - Step-by-Step Deploy
echo ========================================
echo.
echo This script will deploy your application step by step.
echo Press ENTER at each step to continue.
echo.
pause

echo 🔍 STEP 1: Checking Administrator privileges...
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

echo 🔍 STEP 2: Checking current directory and project structure...
echo Current directory: %CD%
echo.
echo Files in this directory:
dir /B
echo.
if not exist "simple-iis-app.csproj" (
    echo ❌ FATAL ERROR: simple-iis-app.csproj not found!
    echo.
    echo You are NOT in the simple-iis-app project folder!
    echo Navigate to the correct folder and try again.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
) else (
    echo ✅ Found simple-iis-app.csproj - correct directory
)
echo.
pause

echo 🔍 STEP 3: Auto-fixing GitHub download namespace and package issues...
echo Checking for namespace issues and package version problems that cause build errors...
echo.

:: Fix Views\_ViewImports.cshtml
if exist "Views\_ViewImports.cshtml" (
    findstr /C:"SimpleIISApp" "Views\_ViewImports.cshtml" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing Views\_ViewImports.cshtml namespace...
        powershell -Command "(Get-Content 'Views\_ViewImports.cshtml') -replace 'SimpleIISApp', 'simple_iis_app' | Set-Content 'Views\_ViewImports.cshtml'" 2>nul
        echo   ✅ Fixed Views\_ViewImports.cshtml
    ) else (
        echo   ✅ Views\_ViewImports.cshtml already correct
    )
) else (
    echo   ⚠️ Views\_ViewImports.cshtml not found
)

:: Fix GlobalUsings.cs comment
if exist "GlobalUsings.cs" (
    findstr /C:"SimpleIISApp" "GlobalUsings.cs" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing GlobalUsings.cs comment...
        powershell -Command "(Get-Content 'GlobalUsings.cs') -replace 'SimpleIISApp', 'simple-iis-app' | Set-Content 'GlobalUsings.cs'" 2>nul
        echo   ✅ Fixed GlobalUsings.cs
    ) else (
        echo   ✅ GlobalUsings.cs already correct
    )
)

:: Fix launchSettings.json
if exist "Properties\launchSettings.json" (
    findstr /C:"SimpleIISApp" "Properties\launchSettings.json" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing Properties\launchSettings.json...
        powershell -Command "(Get-Content 'Properties\launchSettings.json') -replace '\"SimpleIISApp\":', '\"simple-iis-app\":' | Set-Content 'Properties\launchSettings.json'" 2>nul
        echo   ✅ Fixed launchSettings.json
    ) else (
        echo   ✅ launchSettings.json already correct
    )
)

:: Fix SourceLink package version issue (common in GitHub downloads)
if exist "simple-iis-app.csproj" (
    findstr /C:"8.0.0" "simple-iis-app.csproj" >nul 2>&1
    if !errorlevel! equ 0 (
        echo   🔧 Fixing SourceLink package version (8.0.0 doesn't exist)...
        powershell -Command "$content = Get-Content 'simple-iis-app.csproj'; $content = $content -replace '8\.0\.0', '1.1.1'; Set-Content 'simple-iis-app.csproj' $content" 2>nul
        echo   ✅ Fixed SourceLink package version to 1.1.1
    ) else (
        echo   ✅ SourceLink package version already correct
    )
)

echo.
echo ✅ Namespace and package fixes completed (if any were needed)
echo.
pause

echo 🔍 STEP 4: Checking .NET installation...
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

echo 🔍 STEP 5: Checking IIS directory access...
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

echo 🔍 STEP 6: Testing directory creation permissions...
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

echo 🔍 STEP 7: Setting up deployment environment...
for /f "usebackq delims=" %%i in (`powershell -command "Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'" 2^>nul`) do set "timestamp=%%i"
if "%timestamp%"=="" set "timestamp=deploy_%RANDOM%"

set DD_GIT_COMMIT_SHA=step-deploy-%timestamp%
set DD_GIT_COMMIT_SHA_SHORT=step-%RANDOM%
set DD_GIT_BRANCH=main-step
set DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git
set DD_GIT_COMMIT_MESSAGE=Step-by-step deployment at %date% %time%
set DD_DEPLOYMENT_VERSION=%timestamp%
set DD_DEPLOYMENT_TIME=%date% %time%

echo   🔧 Setting Datadog machine-level environment variables...
echo 🐛 DEBUG: Running PowerShell command to set Datadog environment variables...
powershell -Command "$target=[System.EnvironmentVariableTarget]::Machine; try { [System.Environment]::SetEnvironmentVariable('DD_ENV','testing',$target); Write-Host '   ✅ DD_ENV=testing'; [System.Environment]::SetEnvironmentVariable('DD_LOGS_INJECTION','true',$target); Write-Host '   ✅ DD_LOGS_INJECTION=true'; [System.Environment]::SetEnvironmentVariable('DD_RUNTIME_METRICS_ENABLED','true',$target); Write-Host '   ✅ DD_RUNTIME_METRICS_ENABLED=true'; [System.Environment]::SetEnvironmentVariable('DD_PROFILING_ENABLED','true',$target); Write-Host '   ✅ DD_PROFILING_ENABLED=true'; Write-Host '   ✅ All Datadog environment variables set at machine level' } catch { Write-Host '   ❌ Error setting Datadog variables:' $_.Exception.Message; exit 1 }"
set DATADOG_ENV_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Datadog environment variables result: %DATADOG_ENV_RESULT%

if %DATADOG_ENV_RESULT% neq 0 (
    echo   ⚠️ Could not set machine-level Datadog variables
    echo   This may happen if not running with sufficient privileges
    echo   You can set these manually in System Environment Variables:
    echo   • DD_ENV=testing
    echo   • DD_LOGS_INJECTION=true  
    echo   • DD_RUNTIME_METRICS_ENABLED=true
    echo   • DD_PROFILING_ENABLED=true
) else (
    echo   ✅ Datadog configuration applied successfully
)

echo ✅ Environment variables set
echo   Timestamp: %timestamp%
echo.
pause

echo 🔍 STEP 8: Cleaning previous builds and preparing IIS...
if exist "bin\Release\net9.0\publish" (
    echo   Cleaning previous publish folder...
    rmdir /s /q "bin\Release\net9.0\publish" 2>nul
)
if exist "bin\Debug" (
    echo   Cleaning debug folder...
    rmdir /s /q "bin\Debug" 2>nul
)
if exist "obj" (
    echo   Cleaning obj folder...
    rmdir /s /q "obj" 2>nul
)

if exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo   Cleaning existing IIS directory...
    rmdir /s /q "C:\inetpub\wwwroot\simple-iis-app" 2>nul
)

echo   Creating fresh IIS directory...
mkdir "C:\inetpub\wwwroot\simple-iis-app" 2>nul
if not exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo ❌ Failed to create C:\inetpub\wwwroot\simple-iis-app
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo ✅ Build environment prepared
echo.
pause

echo 🔍 STEP 9: Building application...
echo Running: dotnet build -c Release
echo.
dotnet build -c Release
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ Build failed! Check the errors above.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
echo ✅ Build successful!
echo.
pause

echo 🔍 STEP 10: Publishing application...
echo Running: dotnet publish -c Release -o bin\Release\net9.0\publish
echo.
dotnet publish -c Release -o bin\Release\net9.0\publish
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ Publish failed! Check the errors above.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
echo ✅ Publish successful!
echo.
pause

echo 🔍 STEP 11: Copying files to IIS directory...
echo Running: xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
echo.
xcopy "bin\Release\net9.0\publish\*" "C:\inetpub\wwwroot\simple-iis-app\" /E /I /Y
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ Copy failed! Check permissions and try running as Administrator.
    echo.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo.
echo ✅ Files copied successfully!
echo.
pause

echo 🔍 STEP 12: Verifying deployment...
if exist "C:\inetpub\wwwroot\simple-iis-app\simple-iis-app.dll" (
    echo ✅ Application DLL found
) else (
    echo ❌ Application DLL not found - deployment may have failed
)

if exist "C:\inetpub\wwwroot\simple-iis-app\web.config" (
    echo ✅ Web.config found
) else (
    echo ❌ Web.config missing
)

echo.
echo Files in IIS directory:
dir "C:\inetpub\wwwroot\simple-iis-app" /B
echo.
pause

echo 🔍 STEP 13: Checking IIS Command Line Tool...
echo Verifying appcmd.exe is available...
echo.
echo 🐛 DEBUG: Checking path: %WINDIR%\System32\inetsrv\appcmd.exe
if exist "%WINDIR%\System32\inetsrv\appcmd.exe" (
    echo ✅ appcmd.exe found - IIS command line tool available
    echo 🐛 DEBUG: Testing appcmd.exe basic functionality...
    "%WINDIR%\System32\inetsrv\appcmd.exe" list sites
    echo 🐛 DEBUG: appcmd.exe test completed (exit code: %ERRORLEVEL%)
) else (
    echo ❌ appcmd.exe not found! IIS may not be properly installed.
    echo 🐛 DEBUG: Checked path: %WINDIR%\System32\inetsrv\appcmd.exe
    echo 🐛 DEBUG: Directory contents:
    dir "%WINDIR%\System32\inetsrv\" /B 2>nul
    echo.
    echo Please ensure IIS is installed with Management Tools.
    pause
    goto :MANUAL_SETUP
)
echo.
pause

echo 🔍 STEP 14: Creating IIS Application Pool...
echo Running: appcmd add apppool /name:"simple-iis-app"
echo.

echo 🐛 DEBUG: Listing existing application pools before creation...
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool

echo.
echo 🐛 DEBUG: Checking if simple-iis-app application pool already exists...
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool "simple-iis-app" >nul 2>&1
set CHECK_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Check result: %CHECK_RESULT% (0=exists, 1=does not exist)

if %CHECK_RESULT% equ 0 (
    echo   ⚠️ Removing existing application pool...
    echo 🐛 DEBUG: Running: appcmd delete apppool "simple-iis-app"
    "%WINDIR%\System32\inetsrv\appcmd.exe" delete apppool "simple-iis-app"
    set DELETE_RESULT=%ERRORLEVEL%
    echo 🐛 DEBUG: Delete result: %DELETE_RESULT%
    timeout /t 2 >nul
)

echo   🔧 Creating application pool: simple-iis-app
echo 🐛 DEBUG: Running: appcmd add apppool /name:"simple-iis-app"
"%WINDIR%\System32\inetsrv\appcmd.exe" add apppool /name:"simple-iis-app"
set CREATE_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Create result: %CREATE_RESULT%

if %CREATE_RESULT% neq 0 (
    echo   ❌ Failed to create application pool! Error code: %CREATE_RESULT%
    echo 🐛 DEBUG: Listing all application pools after failed creation:
    "%WINDIR%\System32\inetsrv\appcmd.exe" list apppool
    pause
    goto :MANUAL_SETUP
)

echo   🔧 Setting .NET CLR Version to No Managed Code
echo 🐛 DEBUG: Running: appcmd set apppool "simple-iis-app" /managedRuntimeVersion:""
"%WINDIR%\System32\inetsrv\appcmd.exe" set apppool "simple-iis-app" /managedRuntimeVersion:""
set RUNTIME_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Runtime set result: %RUNTIME_RESULT%

if %RUNTIME_RESULT% neq 0 (
    echo   ⚠️ Could not set runtime version - may need manual configuration (Error: %RUNTIME_RESULT%)
) else (
    echo   ✅ Runtime version set to No Managed Code
)

echo 🐛 DEBUG: Verifying application pool creation:
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool "simple-iis-app"

echo   ✅ Application pool created successfully
echo.
pause

echo 🔍 STEP 15: Creating IIS Website on port 8080...
echo Running: appcmd add site /name:"simple-iis-app"
echo.

echo 🐛 DEBUG: Listing existing websites before creation...
"%WINDIR%\System32\inetsrv\appcmd.exe" list site

echo.
echo 🐛 DEBUG: Checking if simple-iis-app website already exists...
"%WINDIR%\System32\inetsrv\appcmd.exe" list site "simple-iis-app" >nul 2>&1
set SITE_CHECK_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Site check result: %SITE_CHECK_RESULT% (0=exists, 1=does not exist)

if %SITE_CHECK_RESULT% equ 0 (
    echo   ⚠️ Removing existing website...
    echo 🐛 DEBUG: Running: appcmd delete site "simple-iis-app"
    "%WINDIR%\System32\inetsrv\appcmd.exe" delete site "simple-iis-app"
    set SITE_DELETE_RESULT=%ERRORLEVEL%
    echo 🐛 DEBUG: Site delete result: %SITE_DELETE_RESULT%
    timeout /t 2 >nul
)

echo 🐛 DEBUG: Verifying physical path exists: C:\inetpub\wwwroot\simple-iis-app
if exist "C:\inetpub\wwwroot\simple-iis-app" (
    echo 🐛 DEBUG: ✅ Physical path exists
    echo 🐛 DEBUG: Directory contents:
    dir "C:\inetpub\wwwroot\simple-iis-app" /B | head -10
) else (
    echo 🐛 DEBUG: ❌ Physical path does not exist!
)

echo   🔧 Creating website: simple-iis-app on port 8080
echo 🐛 DEBUG: Full command: appcmd add site /name:"simple-iis-app" /physicalPath:"C:\inetpub\wwwroot\simple-iis-app" /bindings:http/*:8080:
"%WINDIR%\System32\inetsrv\appcmd.exe" add site /name:"simple-iis-app" /physicalPath:"C:\inetpub\wwwroot\simple-iis-app" /bindings:http/*:8080:
set SITE_CREATE_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Site create result: %SITE_CREATE_RESULT%

if %SITE_CREATE_RESULT% neq 0 (
    echo   ❌ Failed to create website! Error code: %SITE_CREATE_RESULT%
    echo 🐛 DEBUG: Listing all sites after failed creation:
    "%WINDIR%\System32\inetsrv\appcmd.exe" list site
    echo 🐛 DEBUG: Checking port 8080 usage:
    netstat -an | findstr ":8080"
    pause
    goto :MANUAL_SETUP
)

echo   🔧 Assigning application pool to website
echo 🐛 DEBUG: Running: appcmd set app "simple-iis-app/" /applicationPool:"simple-iis-app"
"%WINDIR%\System32\inetsrv\appcmd.exe" set app "simple-iis-app/" /applicationPool:"simple-iis-app"
set POOL_ASSIGN_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Pool assign result: %POOL_ASSIGN_RESULT%

if %POOL_ASSIGN_RESULT% neq 0 (
    echo   ⚠️ Could not assign application pool - may need manual configuration (Error: %POOL_ASSIGN_RESULT%)
) else (
    echo   ✅ Application pool assigned successfully
)

echo 🐛 DEBUG: Verifying website creation:
"%WINDIR%\System32\inetsrv\appcmd.exe" list site "simple-iis-app"

echo   ✅ Website created successfully
echo.
pause

echo 🔍 STEP 16: Setting Directory Permissions...
echo Granting application pool identity access to the website directory...
echo.
echo   Setting permissions for: IIS AppPool\simple-iis-app
icacls "C:\inetpub\wwwroot\simple-iis-app" /grant "IIS AppPool\simple-iis-app:(OI)(CI)R" /t
if %ERRORLEVEL% neq 0 (
    echo   ⚠️ Permission setting failed - trying alternative method...
    icacls "C:\inetpub\wwwroot\simple-iis-app" /grant "IIS_IUSRS:(OI)(CI)R" /t
    if %ERRORLEVEL% neq 0 (
        echo   ❌ Could not set permissions automatically
        echo   You may need to set permissions manually in IIS Manager
    ) else (
        echo   ✅ Permissions set using IIS_IUSRS
    )
) else (
    echo   ✅ Permissions set for application pool identity
)
echo.
pause

echo 🔍 STEP 17: Starting Services...
echo Starting application pool and website...
echo.

echo 🐛 DEBUG: Checking current status before starting...
echo 🐛 DEBUG: Application pool status:
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool "simple-iis-app"
echo 🐛 DEBUG: Website status:
"%WINDIR%\System32\inetsrv\appcmd.exe" list site "simple-iis-app"

echo   🔧 Starting application pool...
echo 🐛 DEBUG: Running: appcmd start apppool "simple-iis-app"
"%WINDIR%\System32\inetsrv\appcmd.exe" start apppool "simple-iis-app"
set POOL_START_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Pool start result: %POOL_START_RESULT%

if %POOL_START_RESULT% neq 0 (
    echo   ⚠️ Could not start application pool (Error: %POOL_START_RESULT% - may already be running)
) else (
    echo   ✅ Application pool started
)

echo   🔧 Starting website...
echo 🐛 DEBUG: Running: appcmd start site "simple-iis-app"
"%WINDIR%\System32\inetsrv\appcmd.exe" start site "simple-iis-app"
set SITE_START_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Site start result: %SITE_START_RESULT%

if %SITE_START_RESULT% neq 0 (
    echo   ⚠️ Could not start website (Error: %SITE_START_RESULT% - may already be running)
) else (
    echo   ✅ Website started
)

echo 🐛 DEBUG: Checking status after starting...
echo 🐛 DEBUG: Application pool status:
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool "simple-iis-app"
echo 🐛 DEBUG: Website status:
"%WINDIR%\System32\inetsrv\appcmd.exe" list site "simple-iis-app"
echo.
pause

echo 🔍 STEP 18: Final verification...
echo Checking final IIS configuration...
echo.

echo 🐛 DEBUG: Complete IIS configuration verification...
echo.
echo   📋 Listing created application pool:
"%WINDIR%\System32\inetsrv\appcmd.exe" list apppool "simple-iis-app"
set FINAL_POOL_CHECK=%ERRORLEVEL%
echo 🐛 DEBUG: Application pool list result: %FINAL_POOL_CHECK%

echo.
echo   📋 Listing created website:
"%WINDIR%\System32\inetsrv\appcmd.exe" list site "simple-iis-app"
set FINAL_SITE_CHECK=%ERRORLEVEL%
echo 🐛 DEBUG: Website list result: %FINAL_SITE_CHECK%

echo.
echo 🐛 DEBUG: Checking all active ports:
netstat -an | findstr "LISTENING" | findstr "80"
echo.
echo   📋 Checking if port 8080 is in use:
netstat -an | findstr ":8080 "
set PORT_CHECK=%ERRORLEVEL%
echo 🐛 DEBUG: Port 8080 check result: %PORT_CHECK% (0=found, 1=not found)

if %PORT_CHECK% equ 0 (
    echo   ✅ Port 8080 is active and listening
) else (
    echo   ⚠️ Port 8080 not showing as active - website may not be running
    echo 🐛 DEBUG: All listening ports:
    netstat -an | findstr "LISTENING"
)

echo.
echo 🐛 DEBUG: Testing HTTP connection to localhost:8080...
echo 🐛 DEBUG: Running: curl -I http://localhost:8080 (if available)
curl -I http://localhost:8080 2>nul
set CURL_RESULT=%ERRORLEVEL%
echo 🐛 DEBUG: Curl result: %CURL_RESULT%

echo.
echo 🐛 DEBUG: Final summary of what was created:
if %FINAL_POOL_CHECK% equ 0 (
    echo   ✅ Application Pool: simple-iis-app exists
) else (
    echo   ❌ Application Pool: simple-iis-app NOT found
)

if %FINAL_SITE_CHECK% equ 0 (
    echo   ✅ Website: simple-iis-app exists
) else (
    echo   ❌ Website: simple-iis-app NOT found
)

if %PORT_CHECK% equ 0 (
    echo   ✅ Port 8080: Active and listening
) else (
    echo   ❌ Port 8080: Not active
)

echo.
pause

echo ========================================
echo 🎉 DEPLOYMENT COMPLETED! 🎉
echo ========================================
echo.
echo ✅ Application built and deployed successfully
echo ✅ Files location: C:\inetpub\wwwroot\simple-iis-app\
echo ✅ IIS Application Pool: simple-iis-app (No Managed Code)
echo ✅ IIS Website: simple-iis-app on port 8080
echo.
echo 🌐 TEST YOUR DEPLOYMENT:
echo.
echo   Open your browser and navigate to:
echo   🔗 http://localhost:8080
echo.
echo   You should see the Simple IIS App homepage with:
echo   • 🔐 Login functionality (admin/password)
echo   • 💓 Health check status indicator
echo   • 🐛 Error testing buttons for monitoring
echo   • 📊 Deployment information
echo.
echo 🔧 If you see errors:
echo   • Check Windows Event Viewer → Application logs
echo   • Check IIS logs in C:\inetpub\logs\LogFiles\
echo   • Verify .NET 9.0 Hosting Bundle is installed
echo   • Ensure application pool is set to "No Managed Code"
echo.
goto :END_SUCCESS

:MANUAL_SETUP
echo ========================================
echo 🎯 MANUAL IIS SETUP REQUIRED
echo ========================================
echo.
echo ✅ Application files deployed to: C:\inetpub\wwwroot\simple-iis-app\
echo ⚠️ IIS configuration needs to be done manually
echo.
echo 📋 Manual steps:
echo.
echo 1. Open IIS Manager (search "IIS" in Start menu)
echo.
echo 2. Create Application Pool:
echo    • Right-click "Application Pools" → Add Application Pool
echo    • Name: simple-iis-app
echo    • .NET CLR Version: No Managed Code
echo    • Click OK
echo.
echo 3. Create Website:
echo    • Right-click "Sites" → Add Website
echo    • Site name: simple-iis-app
echo    • Physical path: C:\inetpub\wwwroot\simple-iis-app
echo    • Port: 8080
echo    • Application pool: simple-iis-app
echo    • Click OK
echo.
echo 4. Set Directory Permissions:
echo    • Right-click C:\inetpub\wwwroot\simple-iis-app in Explorer
echo    • Properties → Security → Edit → Add
echo    • Type: IIS AppPool\simple-iis-app
echo    • Give it Read ^& Execute permissions
echo    • Click OK
echo.
echo 5. Test: Browse to http://localhost:8080
echo.

:END_SUCCESS
echo ================================
echo Deployment completed at %date% %time%
echo ================================
echo.
echo Press any key to exit...
pause >nul