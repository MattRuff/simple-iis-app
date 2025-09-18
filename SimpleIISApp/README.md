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

### Step 1: Build and Publish

```bash
# Run the deployment script
deploy.bat

# OR manually:
dotnet publish -c Release -o bin\Release\net9.0\publish
```

### Step 2: Copy to Windows Server

Copy the entire `bin\Release\net9.0\publish\` folder to your Windows server.

### Step 3: Configure IIS

1. **Open IIS Manager**
2. **Right-click "Sites"** → **"Add Website..."**
3. **Configure:**
   - **Site name**: `SimpleIISApp`
   - **Physical path**: Point to your publish folder
   - **Port**: `80` (or any available port)
   - **Binding**: HTTP (no SSL needed)
4. **Click OK**

### Step 4: Test

Browse to `http://your-server-ip` or `http://localhost` and you should see the welcome page!

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

---

**Perfect for testing IIS deployment without the complexity of authentication, databases, or SSL certificates!** 🎉
