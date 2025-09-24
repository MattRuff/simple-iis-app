🚀 SIMPLE IIS APP - DEPLOYMENT GUIDE

📦 FOR CLEAN WINDOWS ENVIRONMENTS

===========================================
HOW TO DEPLOY:
===========================================

1. Download ZIP from GitHub
2. Extract completely  
3. Right-click "DEPLOY.bat" → "Run as administrator"
4. ** MANUALLY SET UP IIS (see detailed steps below) **
5. Browse to http://localhost:8080

** IIS SETUP IS MANUAL - DEPLOYMENT SCRIPT ONLY BUILDS THE APP **

===========================================
REQUIREMENTS:
===========================================

✅ Windows 10/11 or Windows Server
✅ .NET 9.0 SDK installed
✅ IIS with ASP.NET Core Module V2
✅ Administrator privileges

===========================================
WHAT THE SCRIPT DOES:
===========================================

[1-12] ✅ Build and deploy application files to C:\inetpub\wwwroot\simple-iis-app\
[13-18] ⚠️ Attempts IIS configuration (may fail - use manual steps below)

** MANUAL IIS SETUP REQUIRED **

===========================================
DOWNLOAD LINKS:
===========================================

.NET 9.0 SDK:
https://dotnet.microsoft.com/download/dotnet/9.0

ASP.NET Core Runtime (IIS):
https://dotnet.microsoft.com/download/dotnet/9.0/runtime

===========================================
FEATURES INCLUDED:
===========================================

🔐 Simple login (admin/password)
📊 Protected admin dashboard  
💓 Health check endpoint (/health)
📈 Metrics endpoint (/api/metrics)
🐛 Error testing for monitoring
🔍 Git deployment tracking
📝 Structured logging
🔗 SourceLink integration (Datadog can extract git info from assembly)
⚡ Automatic Datadog .NET tracer configuration (logs injection, profiling, runtime metrics)

===========================================
📋 MANUAL IIS SETUP (REQUIRED):
===========================================

After running DEPLOY.bat, you MUST manually configure IIS:

🔧 STEP 1: Open IIS Manager
   • Press Windows key + R
   • Type: inetmgr
   • Press Enter (or search "IIS" in Start menu)

🔧 STEP 2: Create Application Pool
   • In IIS Manager, expand your server name
   • Right-click "Application Pools" → "Add Application Pool"
   • Name: simple-iis-app
   • .NET CLR Version: "No Managed Code"
   • Managed Pipeline Mode: Integrated
   • Click "OK"

🔧 STEP 3: Create Website
   • Right-click "Sites" → "Add Website"
   • Site name: simple-iis-app
   • Application pool: simple-iis-app (select from dropdown)
   • Physical path: C:\inetpub\wwwroot\simple-iis-app
   • Binding Type: http
   • IP Address: All Unassigned
   • Port: 8080
   • Host name: (leave blank)
   • Click "OK"

🔧 STEP 4: Set Directory Permissions (if needed)
   • In Windows Explorer, navigate to: C:\inetpub\wwwroot\simple-iis-app
   • Right-click → Properties → Security → Edit → Add
   • Type: IIS AppPool\simple-iis-app
   • Check "Read & Execute" and "Read"
   • Click OK

🔧 STEP 5: Start the Website
   • In IIS Manager, click on "simple-iis-app" website
   • In Actions panel, click "Start" (if not already started)
   • Ensure Application Pool is also started

🔧 STEP 6: Test Your Deployment
   • Open browser
   • Navigate to: http://localhost:8080
   • You should see the Simple IIS App homepage

===========================================
TROUBLESHOOTING:
===========================================

❌ Build Errors:
   → Ensure .NET 9.0 SDK is installed
   → Check that all files extracted properly

❌ Permission Errors:
   → Must run DEPLOY.bat as Administrator
   → Check IIS is installed properly

❌ IIS Errors (500.19, 500.30):
   → Install ASP.NET Core Module V2
   → Ensure Application Pool is "No Managed Code"
   → Check directory permissions (Step 4 above)
   → Check Windows Event Viewer → Application logs

❌ Website Won't Start:
   → Check port 8080 isn't used by another application
   → Verify physical path exists: C:\inetpub\wwwroot\simple-iis-app
   → Ensure application pool is started

❌ 404 Errors:
   → Verify website binding is set to port 8080
   → Check physical path points to correct directory
   → Ensure simple-iis-app.dll exists in the directory

===========================================
