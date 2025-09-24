# Simple IIS App 🚀

A demonstration ASP.NET Core application for testing IIS deployment, authentication, and monitoring on Windows servers. **Perfect for observability testing with tools like Datadog!**

## 🌐 **AWS EC2 Setup Guide**

### **Step 1: Launch AWS EC2 Instance**

1. **Go to AWS Sandbox (mcse-sandbox):**
   - 🔗 Navigate to: [AWS EC2 Console](https://369042512949-bgy7fais.us-east-1.console.aws.amazon.com/ec2/home?region=us-east-1#Overview:)

2. **Launch EC2 Instance:**
   - Click **"Launch Instance"**
   - **AMI**: Choose **Windows** from QuickStart
   - **Instance Type**: Select **t3.micro** (free tier eligible)
   - **Key Pair**: 
     - Click **"Create new key pair"**
     - Give it a descriptive name (e.g., `simple-iis-app-key`)
     - Download and save the `.pem` file securely
   - **Network Settings** ⚠️ **CRITICAL SECURITY**:
     - ✅ Allow **RDP (port 3389)** 
     - ❌ **DO NOT** select "Anywhere (0.0.0.0/0)"
     - ✅ **Select "My IP"** to restrict RDP access to your current IP only
     - This ensures only you can access the server
   - Click **"Launch Instance"**

### **Step 2: Connect via RDP**

1. **Get Connection Details:**
   - Select your launched instance
   - Click **"Connect"** button
   - Select **"RDP Client"** tab
   - Click **"Get password"**
   - Upload your key pair file (`.pem`)
   - **Copy and save the password** to your notes

2. **Download RDP File:**
   - Click **"Download remote desktop file"**
   - Save the `.rdp` file to your computer

3. **Connect with RDP Client:**
   - **Windows**: Use built-in Remote Desktop Connection
   - **macOS**: Use **Microsoft Remote Desktop** from Mac App Store
   - **Alternative**: Use **Windows App** from Mac App Store
   - Open the `.rdp` file with your RDP client
   - Enter the password you copied earlier

### **Step 3: Configure Windows Server**

1. **Open Server Manager:**
   - Server Manager should open automatically
   - If not, click Start → Server Manager

2. **Install IIS:**
   - In Server Manager, click **"Manage"** (top right)
   - Select **"Add Roles and Features"**
   - Click **Next** through the wizard until you reach **Server Roles**
   - Check **"Web Server (IIS)"**
   - Accept any additional features it wants to install
   - Click **Next** through remaining steps
   - Click **"Install"**
   - Wait for installation to complete

3. **Verify IIS Installation:**
   - Open browser and go to `http://localhost`
   - You should see the IIS welcome page

### **Step 4: Install .NET 9.0 Runtime**

**🆕 SIMPLIFIED: Only Runtime Required on Server**

1. **Download .NET 9.0 Runtime:**
   - 🔗 Go to: [.NET 9.0 Download](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
   - **FOR SERVERS**: Download **"ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"**
   - **No SDK needed** on the server (application is pre-built)

2. **Install Hosting Bundle:**
   - Run the downloaded installer (`dotnet-hosting-9.0.9-win.exe`)
   - Follow the installation wizard
   - **Restart IIS** when prompted (or run `iisreset` in Command Prompt)

3. **Verify Installation:**
   - Open Command Prompt as Administrator
   - Run: `dotnet --info`
   - Verify .NET 9.0 Runtime is listed

**✅ New Deployment Model:**
- **Development Machine**: Needs .NET SDK (for building)
- **Server Machine**: Only needs Runtime (for running pre-built apps)
- **Result**: Faster, more secure, and simpler server setup

### **Step 5: Deploy the Application**

**🚀 PRE-BUILT DEPLOYMENT: Fast & Simple**

1. **Get the Pre-Built Application:**
   - 🔗 Go to: [https://github.com/MattRuff/simple-iis-app](https://github.com/MattRuff/simple-iis-app)
   - Click **"Code"** → **"Download ZIP"**
   - **Or** copy the pre-built folder from your development machine
   - **Important:** The `bin\Release\net9.0\publish\` folder must be included

2. **Deploy to Server:**
   - Extract/copy the folder to your Windows server
   - Navigate to the folder
   - **Right-click** on `DEPLOY.bat`
   - Select **"Run as administrator"**
   - The script will:
     - ✅ Verify pre-built files exist
     - ✅ Copy files to IIS directory: `C:\inetpub\wwwroot\simple-iis-app`
     - ✅ Set up Datadog environment variables
     - ✅ Provide IIS configuration instructions

3. **Manual IIS Configuration:**
   - Open **IIS Manager**
   - Follow the script's output instructions for:
     - Creating Application Pool (`simple-iis-app`)
     - Creating Website (port 8080)
     - Setting directory permissions

4. **Test Deployment:**
   - Browse to: `http://localhost:8080`
   - You should see the Simple IIS App running! 🎉

**💡 Benefits of Pre-Built Deployment:**
- ✅ **No .NET SDK required** on server (only Runtime)
- ✅ **Fast deployment** - no build time on server
- ✅ **Simple and reliable** - just copy and deploy
- ✅ **Perfect for production** - minimal server requirements

### **🔐 Security Notes**

- ✅ **RDP Access**: Restricted to your IP only
- ✅ **Default Website**: Consider disabling if not needed
- ✅ **Firewall**: Windows Firewall is enabled by default
- ⚠️ **Testing Only**: This setup is for development/testing, not production

### **🧹 Cleanup**

When you're done testing:
1. **Stop the EC2 instance** to avoid charges
2. **Terminate the instance** if no longer needed
3. **Delete the key pair** if not reusing

---

## ✨ Features

- 🔐 **Simple Authentication**: Built-in login system (admin/password)
- 🎛️ **Protected Dashboard**: Admin area requiring authentication
- 📊 **Auto-Monitoring**: Healthcheck every 30 seconds for observability
- 🚀 **Multiple Endpoints**: `/health`, `/api/healthcheck`, `/api/metrics`
- 🖥️ **System Information**: Displays server details to verify deployment
- 🎨 **Modern UI**: Beautiful responsive interface with auth status
- 📦 **Self-Contained**: No external dependencies or databases
- 🔒 **HTTP-Only**: Works without SSL certificates for testing
- 🔗 **SourceLink Integration**: Datadog can extract git commit SHA and repository URL from the .NET assembly

## 📥 **FIRST: Download Required Software**

**⚠️ BEFORE DEPLOYING:** You must download .NET 9.0 SDK on your Windows server!

🔗 **Go to**: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)  
📦 **Download**: "**.NET 9.0 SDK**" (required for building the application)  
🚀 **Install**: Run the installer, then restart IIS (`iisreset`)

> 💡 **SDK vs Runtime:** 
> - **SDK** = Can build AND run applications (what you need for `DEPLOY.bat`)
> - **Runtime** = Can only run pre-built applications
> - **Hosting Bundle** = Runtime + IIS integration (for production servers)

## 🛠️ Requirements

### On Development Machine:
- .NET 9.0 SDK (from [Microsoft Downloads](https://dotnet.microsoft.com/en-us/download/dotnet/9.0))

### On Windows Server:
- Windows Server 2016+ (or Windows 10/11)
- IIS with ASP.NET Core Module V2
- .NET 9.0 Runtime + ASP.NET Core Hosting Bundle ⬆️ **Download Above!**

## 🚀 Quick Deployment

### Step 0: Install .NET Runtime on Server

**🔍 Pre-Built Deployment (Server Requirements):**
1. **Download**: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
2. **Get**: "**ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle**"
3. **Install & restart IIS**: `iisreset`

**💡 No .NET SDK needed on server** - the application is already built!

### Step 1: Run Pre-Built Deployment Script

```bash
# Right-click and "Run as administrator"
DEPLOY.bat
```

**What this deployment script does:**
- ✅ **Verifies pre-built files** exist in `bin\Release\net9.0\publish\`
- ✅ **Copies deployment files** to IIS directory: `C:\inetpub\wwwroot\simple-iis-app`
- ✅ **Sets up Datadog environment variables** for monitoring
- ✅ **Provides IIS configuration instructions** for manual setup
- 📝 **Creates comprehensive logs** in `logs/` folder for debugging
  - Main deployment log
  - Debug log for troubleshooting

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

**🎉 You should see:**
- ✅ Welcome page with system information
- 🔐 Login option in navigation
- 📊 Monitoring endpoints listed
- 🔄 Real-time monitoring status indicator (top-right)

**🔐 To test authentication:**
1. Click "🔐 Login" in navigation
2. Use credentials: **admin** / **password**
3. Access the protected dashboard

**📊 To test monitoring:**
- Visit `/health` - Basic health check
- Visit `/api/healthcheck` - Detailed JSON health data  
- Visit `/api/metrics` - Application metrics
- Check browser console for auto-healthcheck logs

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
SimpleIISApp/ (Your Project Directory):
├── Controllers/                     ← Source code controllers
├── Views/                          ← View templates  
├── SimpleIISApp.csproj             ← Project file
├── Program.cs                      ← Application entry point
├── web.config                      ← IIS configuration
├── deploy-admin.bat               ← Deployment script (run this!)
├── deploy.bat                     ← Alternative deployment script
├── bin/Release/net9.0/publish/    ← Build output (DON'T point IIS here)
└── [other project files...]

IIS Directory (created by deployment script):
└── C:\inetpub\wwwroot\SimpleIISApp/ ← Point IIS HERE! ✅
    ├── SimpleIISApp.dll
    ├── web.config  
    ├── appsettings.json
    └── [other deployed files...]
```

## 🔗 **Git vs ZIP Download Configuration**

### **If You Downloaded as ZIP File (Most Common):**

The deployment scripts automatically detect this and use deployment-based Git information:

- ✅ **Repository URL**: `https://github.com/MattRuff/simple-iis-app.git`
- ✅ **Commit SHA**: `zip-download-[timestamp]`
- ✅ **Branch**: `main-download`
- ✅ **Message**: `Deployed from ZIP download at [date/time]`

### **Manual Git Configuration (Optional):**

If you know the specific commit SHA you downloaded, you can set it manually at the top of the batch files:

**In `deploy.bat` or `deploy-admin.bat`, uncomment and edit these lines:**

```batch
:: set MANUAL_GIT_COMMIT_SHA=abc123def456789...
:: set MANUAL_GIT_BRANCH=main
:: set MANUAL_GIT_COMMIT_MESSAGE=Your commit message here
```

**Example:**
```batch
set MANUAL_GIT_COMMIT_SHA=a1b2c3d4e5f6789012345678901234567890abcd
set MANUAL_GIT_BRANCH=main
set MANUAL_GIT_COMMIT_MESSAGE=Add enhanced error testing and Datadog tracking
```

### **If You Cloned with Git:**

The scripts automatically extract real Git information:
- ✅ **Auto-detects** commit SHA, branch, and commit message
- ✅ **Works with** any Git repository state
- ✅ **Updates dynamically** with each deployment

🎯 **IIS Physical Path**: `C:\inetpub\wwwroot\SimpleIISApp`

## 🔐 **Authentication & Features**

### **Login Credentials**
- **Username**: `admin`
- **Password**: `password`
- **Session Duration**: 1 hour (sliding expiration)

### **Available Pages**
- **🏠 Home**: Public landing page with system info
- **📋 About**: Feature documentation  
- **🔐 Login**: Authentication page
- **🎛️ Dashboard**: Protected admin area (requires login)

### **Monitoring Endpoints**
- **`/health`** - Built-in ASP.NET Core health check
- **`/api/healthcheck`** - Custom health data (JSON)
- **`/api/metrics`** - Application metrics (JSON)

### **Auto-Monitoring**
- ✅ **Healthcheck every 30 seconds** - generates consistent traffic
- ✅ **Metrics collection every 2 minutes** - detailed app metrics  
- ✅ **Structured logging** - for all authentication and monitoring events
- ✅ **Real-time status indicator** - visible monitoring activity

## 📋 Detailed Server Setup

### Install .NET 9.0 Runtime

**📥 Download from Microsoft:**
1. **Go to**: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
2. **Download**: "ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle" 
3. **Run the installer** (includes .NET Runtime + ASP.NET Core Module V2)

**Alternative - Package Manager:**
```powershell
# Using Chocolatey:
choco install dotnet-9.0-runtime

# Using winget:
winget install Microsoft.DotNet.Runtime.9

# Using winget for Hosting Bundle (recommended for IIS):
winget install Microsoft.DotNet.HostingBundle.9
```

**⚠️ For IIS deployment, you MUST use the "Windows Hosting Bundle" which includes the ASP.NET Core Module V2!**

### Install ASP.NET Core Module V2

**✅ Included with Hosting Bundle** - If you downloaded the Windows Hosting Bundle above, you already have this!

**Manual Download (if needed):**
```powershell
# The Hosting Bundle from https://dotnet.microsoft.com/en-us/download/dotnet/9.0
# includes the ASP.NET Core Module V2 automatically
```

**Verify Installation:**
```powershell
# Check if module is installed
Import-Module WebAdministration
Get-IISConfigSection -SectionPath "system.webServer/modules" | Get-IISConfigElement -ChildElementName "add" | Where-Object {$_.name -like "*AspNetCore*"}
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

📝 **For deployment issues**: Check the detailed logs created in the `logs/` folder. See `LOGS-README.md` for a complete guide to using the logging system for debugging.

### Common Issues:

1. **500.19 Error**: ASP.NET Core Module V2 not installed
2. **500.30 Error**: .NET 9.0 Runtime not installed
3. **403 Error**: Check folder permissions
4. **404 Error**: Verify site binding and physical path
5. **NuGet/SourceLink Issues**: Check `logs/nuget_*.log` and `logs/debug_*.log`

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
- ✅ **.NET 9.0 downloaded and installed** from [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0) (Windows Hosting Bundle)

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
# You should already be in the SimpleIISApp directory
# If not, navigate to it first

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

**Expected Result:** 
- ✅ Published files in `bin\Release\net9.0\publish\` folder
- ✅ **Clean IIS deployment** - old files removed automatically
- ✅ **Automatic IIS restart** for fresh deployment
- ✅ **Version tracking** - each deployment gets a unique version number

**What the Enhanced Scripts Do:**
1. **[1/8] Stop IIS Application:** Release file locks by stopping application pools
2. **[2/8] Clean Environment & Create Directory:** Remove old files, verify IIS installation, and create `C:\inetpub\wwwroot\SimpleIISApp` with robust error checking
3. **[3/8] Build & Publish:** Compile application with .NET 9.0
4. **[4/8] Deploy to IIS:** Copy files to IIS directory
5. **[5/8] Create IIS Application:** **AUTOMATED!** Automatically create application pool and website if they don't exist
6. **[6/8] Verify Deployment:** Check files deployed correctly
7. **[7/8] Restart IIS:** Perform clean restart for immediate changes  
8. **[8/8] Complete:** Show deployment version and success message

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

### **Step 3.2: Create IIS Site** ✅ **AUTOMATED!**
~~1. **Open IIS Manager**~~ **DONE BY SCRIPT!**
~~2. **Right-click "Sites"** → **"Add Website..."**~~ **DONE BY SCRIPT!**
~~3. **Configure EXACTLY as shown:**~~ **DONE BY SCRIPT!**
   - ✅ **Site name:** `SimpleIISApp` 
   - ✅ **Physical path:** `C:\inetpub\wwwroot\SimpleIISApp`
   - ✅ **Binding Type:** `http`
   - ✅ **Port:** `8080` (default, or updates existing)
~~4. **Click OK**~~ **DONE BY SCRIPT!**

🎯 **AUTOMATED:** The deployment script now automatically creates the IIS site and application pool for you!

### **Step 3.3: Configure Application Pool** ✅ **AUTOMATED!**
~~1. **Click "Application Pools"** in IIS Manager~~ **DONE BY SCRIPT!**
~~2. **Find your site's app pool** (usually same name as site)~~ **DONE BY SCRIPT!**
~~3. **Right-click** → **"Advanced Settings"**~~ **DONE BY SCRIPT!**
~~4. **Set:**~~ **DONE BY SCRIPT!**
   - ✅ **.NET CLR Version:** `No Managed Code`
   - ✅ **Managed Pipeline Mode:** `Integrated`
~~5. **Click OK**~~ **DONE BY SCRIPT!**

🎯 **AUTOMATED:** Application pool `SimpleIISApp` is automatically created and configured with "No Managed Code" for .NET Core!

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
1. **Download .NET 9.0 SDK or Hosting Bundle:**
   - Go to: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
   - **For building**: Download ".NET 9.0 SDK" 
   - **For runtime only**: Download "ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"

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

🔐 Want to see admin features? Login here (admin/password)

System Information:
🕒 Server Time: [Current timestamp]
💻 Machine Name: [Your server name]  
👤 User Context: [App pool identity]
🖥️ Operating System: [Windows version]
⚡ .NET Version: 9.0.x
🌐 Environment: Production
🔐 Authentication: ❌ Anonymous

📊 Monitoring Endpoints:
✅ Health Check: /health
✅ API Health: /api/healthcheck  
✅ Metrics: /api/metrics
🔄 Auto-healthcheck runs every 30 seconds for monitoring tools like Datadog
```

**Plus you should see a monitoring indicator in the top-right corner showing "🔄 Monitoring: ✅ Active"**

### **Step 5.2: Test Authentication**
1. **Click "🔐 Login"** in the navigation
2. **Enter credentials:** admin / password
3. **Verify redirect** to admin dashboard
4. **Check navigation** shows "🎛️ Dashboard" and "🚪 Logout" 
5. **Test logout** functionality

### **Step 5.3: Test Monitoring**
1. **Visit monitoring endpoints:**
   - `http://localhost:8080/health` - Should return "Healthy"
   - `http://localhost:8080/api/healthcheck` - JSON health data
   - `http://localhost:8080/api/metrics` - JSON metrics
2. **Open browser console** (F12) - Check for auto-healthcheck logs
3. **Watch monitoring indicator** - Should show "✅ Active (X checks)"

### **Step 5.4: Additional Tests**
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
- ✅ Implemented authentication with protected areas
- ✅ Set up monitoring endpoints for observability
- ✅ Configured auto-healthcheck for continuous monitoring
- ✅ Troubleshot common deployment issues
- ✅ Verified successful deployment with all features

**Key Learnings:**
- **Always use published files** (not source files) for IIS
- **ASP.NET Core Module V2** is required for .NET Core on IIS
- **Application pools** must be set to "No Managed Code"
- **Authentication** can be simple but effective for testing
- **Monitoring endpoints** are essential for observability
- **Auto-healthchecks** generate consistent traffic for monitoring tools

**Next Steps:**
- **Integrate with Datadog** or other monitoring tools
- **Set up SSL certificates** for production deployment
- **Add database connectivity** for more realistic scenarios
- **Implement CI/CD pipelines** for automated deployment
- **Add custom metrics** for business logic monitoring
- **Explore distributed tracing** with OpenTelemetry

---

## **🔍 Git SHA Extraction Utility**

Want to explore different ways to extract Git SHA in batch files? 

### **For Git Repositories:**
```bash
get-git-sha.bat
```
Shows 5 methods using `git` commands (when Git is installed)

### **For ZIP Downloads (No Git Required):**
```bash
fetch-sha-no-git.bat
```
Shows 4 methods to get **REAL SHA** without Git installed!

### **What `fetch-sha-no-git.bat` Shows:**
- 🌐 **GitHub API (REST):** `Invoke-RestMethod` to get latest commit
- 🌐 **GitHub Refs API:** Alternative API endpoint  
- 📄 **curl method:** Using curl if available
- 🔧 **PowerShell WebClient:** Direct download approach

### **Smart Deployment Process:**
1. **Manual config** (if you set `MANUAL_GIT_COMMIT_SHA`)
2. **Git commands** (if `.git` folder exists) 
3. **🆕 GitHub API** (if no Git but internet available)
4. **Fallback values** (timestamp-based as last resort)

**🎯 Result: You get REAL Git SHA even from ZIP downloads!**

---

**Perfect for testing IIS deployment with authentication and monitoring - ideal for observability tools like Datadog!** 🎉
