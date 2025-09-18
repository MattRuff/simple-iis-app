# 🚀 SimpleIISApp Installation Guide

## 📥 Required Downloads

Before deploying SimpleIISApp, you need to download and install .NET 9.0 on your Windows server.

### **Step 1: Download .NET 9.0 Windows Hosting Bundle**

1. **Visit**: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)

2. **Find the "Run apps - Runtime" section**

3. **Download**: **"ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle"**
   - This is critical for IIS deployment!
   - Includes .NET Runtime + ASP.NET Core Runtime + IIS Module V2

4. **Run the installer**: `dotnet-hosting-9.0.9-win.exe`
   - Follow the installation wizard
   - Accept default settings
   - Restart may be required

### **Step 2: Verify Installation**

```powershell
# Check if .NET 9.0 is installed
dotnet --info

# Should show .NET 9.0.x in the output

# Check ASP.NET Core Module in IIS
Import-Module WebAdministration
Get-IISConfigSection -SectionPath "system.webServer/modules" | Get-IISConfigElement -ChildElementName "add" | Where-Object {$_.name -like "*AspNetCore*"}

# Should show AspNetCoreModuleV2
```

### **Step 3: Restart IIS**

```powershell
# Run as Administrator
iisreset
```

## 🎯 Why the Hosting Bundle?

The **Windows Hosting Bundle** includes everything needed for IIS:

- ✅ **.NET 9.0 Runtime** - Runs your application
- ✅ **ASP.NET Core Runtime** - Web framework support  
- ✅ **ASP.NET Core Module V2** - IIS integration (critical!)
- ✅ **Automatic IIS configuration** - Sets up modules correctly

## ❌ What NOT to Download

- **SDK** - Only needed for development, not deployment
- **Runtime only** - Missing the IIS module
- **Desktop Runtime** - For desktop apps, not web apps

## 🔍 Alternative Installation Methods

### Using Package Managers

```powershell
# Chocolatey (if you have it)
choco install dotnetcore-windowshosting

# Windows Package Manager (winget)  
winget install Microsoft.DotNet.HostingBundle.9
```

### Manual Verification

If you're unsure what's installed:

```powershell
# List all installed .NET versions
dotnet --list-runtimes

# Should show:
# Microsoft.AspNetCore.App 9.0.9
# Microsoft.NETCore.App 9.0.9
```

## 🚀 Next Steps

After installing .NET 9.0:

1. **Deploy SimpleIISApp** using `deploy-admin.bat`
2. **Configure IIS** site pointing to `C:\inetpub\wwwroot\SimpleIISApp`
3. **Test the application** at your configured URL
4. **Check monitoring endpoints** for observability

---

**📋 Quick Reference:**
- **Download**: [https://dotnet.microsoft.com/en-us/download/dotnet/9.0](https://dotnet.microsoft.com/en-us/download/dotnet/9.0)
- **File**: ASP.NET Core Runtime 9.0.9 - Windows Hosting Bundle
- **After Install**: Run `iisreset` as Administrator
- **Verify**: `dotnet --info` should show 9.0.x
