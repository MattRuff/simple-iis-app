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

echo 🔍 STEP 3: Auto-fixing GitHub download namespace issues...
echo Checking for namespace issues that cause build errors...
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

echo.
echo ✅ Namespace fixes completed (if any were needed)
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

echo 🔍 STEP 13: Checking IIS Management Tools...
echo Verifying WebAdministration module is available...
echo.
powershell -Command "try { Import-Module WebAdministration -ErrorAction Stop; Write-Host '   ✅ WebAdministration module loaded successfully' } catch { Write-Host '   ❌ WebAdministration module not available'; Write-Host '   Please install IIS Management Tools:'; Write-Host '   1. Open Server Manager or Control Panel'; Write-Host '   2. Add Windows Features'; Write-Host '   3. Enable: Web Server (IIS) → Management Tools → IIS Management Console'; Write-Host '   4. Enable: Web Server (IIS) → Management Tools → IIS Management Scripts and Tools'; exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ IIS Management Tools not properly installed!
    echo.
    echo You can still test your website manually:
    echo 1. Open IIS Manager
    echo 2. Create Application Pool: simple-iis-app (No Managed Code)
    echo 3. Create Website: simple-iis-app on port 8080
    echo 4. Browse to http://localhost:8080
    echo.
    pause
    goto :MANUAL_SETUP
)
echo.
pause

echo 🔍 STEP 14: Creating IIS Application Pool...
echo Running: New-WebAppPool -Name 'simple-iis-app'
echo.
powershell -Command "Import-Module WebAdministration; try { $existing = Get-WebAppPool -Name 'simple-iis-app' -ErrorAction SilentlyContinue; if ($existing) { Write-Host '   ⚠️ Removing existing application pool'; Remove-WebAppPool -Name 'simple-iis-app' -Confirm:$false; Start-Sleep 3 } Write-Host '   🔧 Creating application pool: simple-iis-app'; New-WebAppPool -Name 'simple-iis-app'; Write-Host '   🔧 Setting .NET CLR Version to No Managed Code'; Set-ItemProperty IIS:\AppPools\simple-iis-app managedRuntimeVersion ''; Write-Host '   ✅ Application pool created and configured' } catch { Write-Host '   ❌ Error:' $_.Exception.Message; exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ Application pool creation failed!
    pause
    goto :MANUAL_SETUP
)
echo.
pause

echo 🔍 STEP 15: Creating IIS Website on port 8080...
echo Running: New-Website -Name 'simple-iis-app' -Port 8080
echo.
powershell -Command "Import-Module WebAdministration; try { $existing = Get-Website -Name 'simple-iis-app' -ErrorAction SilentlyContinue; if ($existing) { Write-Host '   ⚠️ Removing existing website'; Remove-Website -Name 'simple-iis-app' -Confirm:$false; Start-Sleep 3 } Write-Host '   🔧 Creating website: simple-iis-app'; $site = New-Website -Name 'simple-iis-app' -PhysicalPath 'C:\inetpub\wwwroot\simple-iis-app' -Port 8080 -ApplicationPool 'simple-iis-app'; Write-Host '   ✅ Website created:' $site.name 'on port' $site.bindings.Collection[0].bindingInformation } catch { Write-Host '   ❌ Error:' $_.Exception.Message; exit 1 }"
if %ERRORLEVEL% neq 0 (
    echo.
    echo ❌ Website creation failed!
    pause
    goto :MANUAL_SETUP
)
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
powershell -Command "Import-Module WebAdministration; try { Write-Host '   🔧 Starting application pool...'; Start-WebAppPool -Name 'simple-iis-app'; Write-Host '   🔧 Starting website...'; Start-Website -Name 'simple-iis-app'; Start-Sleep 2; $pool = Get-WebAppPool -Name 'simple-iis-app'; $site = Get-Website -Name 'simple-iis-app'; Write-Host '   ✅ Application Pool:' $pool.name '(' $pool.state ')'; Write-Host '   ✅ Website:' $site.name '(' $site.state ')' } catch { Write-Host '   ⚠️ Warning:' $_.Exception.Message }"
echo.
pause

echo 🔍 STEP 18: Final verification...
echo Checking final IIS configuration...
echo.
powershell -Command "Import-Module WebAdministration; try { $pool = Get-WebAppPool -Name 'simple-iis-app'; $site = Get-Website -Name 'simple-iis-app'; Write-Host '   ✅ Application Pool:' $pool.name '(' $pool.state ') - Runtime:' $pool.managedRuntimeVersion; Write-Host '   ✅ Website:' $site.name '(' $site.state ') - Port:' $site.bindings.Collection[0].bindingInformation; Write-Host '   ✅ Physical Path:' $site.physicalPath } catch { Write-Host '   ⚠️ Could not verify configuration:' $_.Exception.Message }"
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