# Simple IIS App 🚀

A minimal ASP.NET Core application designed for testing IIS deployment on bare Windows servers. **No databases, no SSL certificates, no complex dependencies!**

## ✨ Features

- 🎯 **Zero Dependencies**: No SQL Server, Entity Framework, or external services required
- 🔒 **No SSL Required**: Works with HTTP for easy testing
- 🖥️ **System Information**: Displays server details to verify deployment
- 🎨 **Modern UI**: Beautiful responsive interface
- 📦 **Self-Contained**: Everything needed is included

## 🛠️ Requirements

### On Development Machine:
- .NET 9.0 SDK

### On Windows Server:
- Windows Server 2016+ (or Windows 10/11)
- IIS with ASP.NET Core Module V2
- .NET 9.0 Runtime

## 🚀 Quick Deployment

### Step 1: Run Automated Deployment Script

**Option A: Admin-Checked Script (Recommended)**
```bash
# Right-click and "Run as administrator"
deploy-admin.bat
```

**Option B: Manual Admin Check**
```bash
# Run Command Prompt as Administrator, then run:
deploy.bat
```

**What this script does:**
- ✅ Builds the application
- ✅ Publishes to `bin\Release\net9.0\publish`
- ✅ Creates IIS directory: `C:\inetpub\wwwroot\SimpleIISApp`
- ✅ Copies files to IIS directory automatically

### Step 2: Configure IIS

1. **Open IIS Manager**
2. **Right-click "Sites"** → **"Add Website..."**
3. **Configure EXACTLY as shown:**
   - **Site name**: `SimpleIISApp`
   - **Physical path**: `C:\inetpub\wwwroot\SimpleIISApp`
   - **Port**: `8080` (or any available port)
   - **Binding**: HTTP (no SSL needed)
4. **Click OK**

### Step 3: Configure Application Pool

1. **Click "Application Pools"** in IIS Manager
2. **Right-click your SimpleIISApp pool** → **"Advanced Settings"**
3. **Set .NET CLR Version**: `No Managed Code`
4. **Click OK**

### Step 4: Test

Browse to: `http://localhost:8080`

## 📁 **CRITICAL: IIS Physical Path**

🎯 **Always point IIS to**: `C:\inetpub\wwwroot\SimpleIISApp`

**❌ DO NOT point to:**
- Source folder (where code is)
- Desktop or user folders
- `bin\Release\net9.0\publish` (this is just the build output)

**✅ DO point to:**
- `C:\inetpub\wwwroot\SimpleIISApp` (where deploy.bat copies the files)

## 📂 **Folder Structure Summary**

```
Your Project:
├── SimpleIISApp/                    ← Source code (DON'T point IIS here)
├── bin/Release/net9.0/publish/      ← Build output (DON'T point IIS here)
└── deploy-admin.bat                 ← Run this script

IIS Directory (created by script):
└── C:\inetpub\wwwroot\SimpleIISApp/ ← Point IIS HERE! ✅
    ├── SimpleIISApp.dll
    ├── web.config
    ├── appsettings.json
    └── [other files...]
```

🎯 **IIS Physical Path**: `C:\inetpub\wwwroot\SimpleIISApp`

## 📋 Detailed Server Setup

### Install .NET 9.0 Runtime

```powershell
# Download from Microsoft or use Chocolatey:
choco install dotnet-9.0-runtime

# Or download directly:
# https://dotnet.microsoft.com/download/dotnet/9.0
```

### Install ASP.NET Core Module V2

```powershell
# Download ASP.NET Core Module V2 for IIS
# https://dotnet.microsoft.com/permalink/dotnetcore-current-windows-runtime-bundle-installer
```

### Enable IIS Features

```powershell
# Enable IIS and required features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpErrors
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpRedirect
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HealthAndDiagnostics
Enable-WindowsOptionalFeature -Online -FeatureName IIS-HttpLogging
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Security
Enable-WindowsOptionalFeature -Online -FeatureName IIS-RequestFiltering
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Performance
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerManagementTools
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-IIS6ManagementCompatibility
Enable-WindowsOptionalFeature -Online -FeatureName IIS-Metabase
```

## 🔧 Configuration Files

### web.config
The `web.config` file is automatically configured for IIS deployment with ASP.NET Core Module V2.

### appsettings.json
Minimal configuration with logging settings.

## 🧪 Testing Locally

```bash
# Run locally for testing
dotnet run

# Browse to: http://localhost:5000
```

## 📊 What You'll See

When successfully deployed, the application will display:

- ✅ Success message confirming deployment
- 🕒 Current server time
- 💻 Machine name
- 👤 User context
- 🖥️ Operating system info
- ⚡ .NET version
- 🌐 Environment (Development/Production)

## 🔍 Troubleshooting

### Common Issues:

1. **500.19 Error**: ASP.NET Core Module V2 not installed
2. **500.30 Error**: .NET 9.0 Runtime not installed
3. **403 Error**: Check folder permissions
4. **404 Error**: Verify site binding and physical path

### Verify Installation:

```powershell
# Check .NET installation
dotnet --info

# Check IIS modules
Get-IISConfigSection -SectionPath "system.webServer/modules" | Get-IISConfigElement -ChildElementName "add" | Where-Object {$_.name -like "*AspNetCore*"}
```

## 📁 Project Structure

```
SimpleIISApp/
├── Controllers/
│   └── HomeController.cs          # Main controller
├── Views/
│   ├── Home/
│   │   ├── Index.cshtml           # Homepage
│   │   ├── About.cshtml           # About page
│   │   └── Error.cshtml           # Error page
│   ├── Shared/
│   │   └── _Layout.cshtml         # Layout template
│   └── _ViewStart.cshtml          # View configuration
├── Properties/
│   ├── launchSettings.json        # Development settings
│   └── PublishProfiles/
│       └── IISProfile.pubxml      # Publish profile
├── Program.cs                     # Application entry point
├── SimpleIISApp.csproj           # Project file
├── appsettings.json              # Configuration
├── web.config                    # IIS configuration
├── deploy.bat                    # Deployment script
└── README.md                     # This file
```

## 🎯 Next Steps

Once this simple app is working, you can:

1. ✅ Verify your IIS setup is correct
2. 🔄 Deploy more complex applications
3. 🔒 Add SSL certificates for production
4. 📊 Add monitoring and logging
5. 🗄️ Integrate databases if needed

# 🧪 **Complete IIS Deployment Lab Exercise**

Follow this step-by-step lab to deploy the SimpleIISApp to IIS and troubleshoot common issues.

## 🎯 **Lab Objectives**
- Deploy an ASP.NET Core 9.0 application to IIS
- Understand common deployment errors and fixes
- Configure IIS properly for ASP.NET Core hosting
- Verify successful deployment

## 📋 **Lab Prerequisites**
- ✅ Windows Server 2016+ or Windows 10/11
- ✅ Administrative access
- ✅ Internet connection for downloads

---

## **Phase 1: Environment Setup** 🛠️

### **Step 1.1: Enable IIS Features**
Run PowerShell as Administrator and execute:

```powershell
# Enable required IIS features
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole
Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServer
Enable-WindowsOptionalFeature -Online -FeatureName IIS-CommonHttpFeatures
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ApplicationDevelopment
Enable-WindowsOptionalFeature -Online -FeatureName IIS-NetFxExtensibility45
Enable-WindowsOptionalFeature -Online -FeatureName IIS-ManagementConsole
```

**Expected Result:** IIS Manager should be available in Start Menu

### **Step 1.2: Verify IIS Installation**
1. Open **IIS Manager** from Start Menu
2. Expand server node → **Sites** → **Default Web Site**
3. Browse to `http://localhost` - you should see IIS welcome page

---

## **Phase 2: Application Build & Publish** 🏗️

### **Step 2.1: Build the Application**
```bash
# Navigate to project directory
cd SimpleIISApp

# Build the application
dotnet build
```

**Expected Result:** Build succeeds with no errors

### **Step 2.2: Publish for Deployment**
```bash
# Run the admin deployment script (recommended)
# Right-click deploy-admin.bat and "Run as administrator"
deploy-admin.bat

# OR run regular script as admin:
deploy.bat

# OR manually:
dotnet publish -c Release -o bin\Release\net9.0\publish
```

**Expected Result:** Published files in `bin\Release\net9.0\publish\` folder

### **Step 2.3: Verify Published Files**
Check that these files exist in the publish folder:
- ✅ `SimpleIISApp.dll`
- ✅ `web.config`
- ✅ `appsettings.json`
- ✅ Various dependency `.dll` files

---

## **Phase 3: IIS Site Configuration** 🌐

### **Step 3.1: Create IIS Application Directory**
**⚠️ Run as Administrator**

```bash
# Right-click and "Run as administrator"
deploy-admin.bat

# OR run deploy.bat from admin command prompt
```

**This automatically:**
- Creates `C:\inetpub\wwwroot\SimpleIISApp` directory  
- Copies published files to IIS directory

**⚠️ Common Mistake:** Don't point IIS directly to your source folder or Desktop - always use `C:\inetpub\wwwroot\SimpleIISApp`!

### **Step 3.2: Create IIS Site**
1. **Open IIS Manager**
2. **Right-click "Sites"** → **"Add Website..."**
3. **Configure EXACTLY as shown:**
   - **Site name:** `SimpleIISApp`
   - **Physical path:** `C:\inetpub\wwwroot\SimpleIISApp`
   - **Binding Type:** `http`
   - **Port:** `8080` (or any available port)
4. **Click OK**

🎯 **CRITICAL:** The physical path MUST be exactly `C:\inetpub\wwwroot\SimpleIISApp` - this is where deploy.bat copied your files!

### **Step 3.3: Configure Application Pool**
1. **Click "Application Pools"** in IIS Manager
2. **Find your site's app pool** (usually same name as site)
3. **Right-click** → **"Advanced Settings"**
4. **Set:**
   - **.NET CLR Version:** `No Managed Code`
   - **Managed Pipeline Mode:** `Integrated`
5. **Click OK**

---

## **Phase 4: Testing & Troubleshooting** 🔍

### **Step 4.1: First Test**
Browse to: `http://localhost:8080`

**🎉 Success:** You see "Simple IIS App is Running!" page → **Skip to Phase 5**

**❌ Error:** Continue to troubleshooting steps below

---

## **🚨 Troubleshooting Common Issues**

### **Issue A: Permission Error (0x80070005)**
```
Config Error: Cannot read configuration file due to insufficient permissions
```

**Root Cause:** IIS can't access files (often when pointing to Desktop/user folders)

**Solution:**
```powershell
# Move files to proper IIS location
Copy-Item "C:\Users\[USERNAME]\Desktop\SimpleIISApp\bin\Release\net9.0\publish\*" -Destination "C:\inetpub\wwwroot\SimpleIISApp\" -Recurse -Force

# Update IIS site physical path to: C:\inetpub\wwwroot\SimpleIISApp\
```

### **Issue B: 500.19 Error (0x8007000d)**
```
Config Error: Problem reading configuration file
Module: IIS Web Core
```

**Root Cause:** ASP.NET Core Module V2 not installed

**Solution:**
1. **Download .NET 9.0 Windows Hosting Bundle:**
   - Go to: https://dotnet.microsoft.com/download/dotnet/9.0
   - Download: "ASP.NET Core Runtime 9.0.x - Windows Hosting Bundle"

2. **Install the bundle:**
   ```powershell
   # Run the downloaded installer: dotnet-hosting-9.0.x-win.exe
   # Follow installation wizard
   ```

3. **Restart IIS:**
   ```powershell
   iisreset
   ```

4. **Verify installation:**
   ```powershell
   Import-Module WebAdministration
   Get-IISConfigSection -SectionPath "system.webServer/modules" | Get-IISConfigElement -ChildElementName "add" | Where-Object {$_.name -like "*AspNetCore*"}
   ```

### **Issue C: 500.30 Error**
```
HTTP Error 500.30 - ASP.NET Core app failed to start
```

**Root Cause:** .NET 9.0 Runtime not installed or wrong target framework

**Solution:**
- Ensure .NET 9.0 Runtime is installed (included in Hosting Bundle)
- Verify `SimpleIISApp.csproj` targets `net9.0`

### **Issue D: 404 Error**
```
HTTP Error 404.0 - Not Found
```

**Root Cause:** Wrong physical path or site not started

**Solution:**
1. Verify physical path points to folder containing `SimpleIISApp.dll`
2. Start the site in IIS Manager
3. Check site bindings match your URL

---

## **Phase 5: Verification & Success** ✅

### **Step 5.1: Verify Successful Deployment**
When working correctly, you should see:

```
🎉 Simple IIS App is Running! 🎉

✅ Congratulations! Your ASP.NET Core application is successfully deployed on IIS.

System Information:
🕒 Server Time: [Current timestamp]
💻 Machine Name: [Your server name]  
👤 User Context: [App pool identity]
🖥️ Operating System: [Windows version]
⚡ .NET Version: 9.0.x
🌐 Environment: Production
```

### **Step 5.2: Additional Tests**
1. **Navigate to About page:** `http://localhost:8080/Home/About`
2. **Refresh page** - timestamp should update
3. **Check different browsers** - should work consistently

### **Step 5.3: Performance Verification**
```powershell
# Check Application Pool is running
Get-IISAppPool | Where-Object {$_.Name -like "*SimpleIIS*"}

# Check site status
Get-IISSite | Where-Object {$_.Name -eq "SimpleIISApp"}
```

---

## **🎓 Lab Summary**

**What You Accomplished:**
- ✅ Deployed ASP.NET Core 9.0 app to IIS
- ✅ Configured IIS properly for .NET Core hosting
- ✅ Troubleshot common deployment issues
- ✅ Verified successful deployment

**Key Learnings:**
- **Always use published files** (not source files) for IIS
- **ASP.NET Core Module V2** is required for .NET Core on IIS
- **Application pools** must be set to "No Managed Code"
- **Proper permissions** are critical for IIS deployment

**Next Steps:**
- Try deploying other ASP.NET Core applications
- Experiment with SSL certificates
- Add authentication and database connectivity
- Set up CI/CD pipelines for automated deployment

---

**Perfect for testing IIS deployment without the complexity of authentication, databases, or SSL certificates!** 🎉
