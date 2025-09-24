# 🚀 Simple IIS App - Pre-Built Deployment Process

## 📋 **Overview**

The **PRE-BUILT DEPLOYMENT** process is fast and simple:
- ✅ **Application is already built** with all dependencies included
- ✅ **Only .NET Runtime required** on server (no SDK needed)
- ✅ **Fast deployment** - just copy and configure
- ✅ **Perfect for production servers** - minimal requirements

## 🎯 **Pre-Built Deployment Logic**

**✅ The application files are ready to deploy:**
- `bin\Release\net9.0\publish\simple-iis-app.dll` - Main application
- `bin\Release\net9.0\publish\web.config` - IIS configuration
- `bin\Release\net9.0\publish\appsettings.json` - App settings
- All Serilog and .NET dependencies included

## 🛠️ **Development Machine (Already Built)**

**✅ The application is already built and ready for deployment!**

The `bin\Release\net9.0\publish\` folder contains all necessary files:
- Compiled application (`.dll` files)
- Configuration files (`web.config`, `appsettings.json`)
- All dependencies (Serilog, .NET libraries)
- Everything needed to run on IIS

## 🖥️ **Server Machine (Deploy)**

### Prerequisites:
- ✅ Windows Server with IIS installed
- ✅ Administrator privileges
- ✅ .NET 9.0 Runtime (Windows Hosting Bundle) - **NO SDK needed**

### Steps:
1. **Run the pre-built deployment script:**
   ```bash
   # Right-click and "Run as administrator"
   DEPLOY.bat
   ```

2. **The script will:**
   - ✅ Verify pre-built files exist
   - ✅ Copy files to IIS directory: `C:\inetpub\wwwroot\simple-iis-app`
   - ✅ Set up Datadog environment variables
   - ✅ Provide manual IIS configuration instructions

3. **Follow manual IIS setup:**
   - Create Application Pool (`simple-iis-app`, No Managed Code)
   - Create Website (port 8080, point to `C:\inetpub\wwwroot\simple-iis-app`)
   - Set directory permissions

4. **Test deployment:**
   - Browse to `http://localhost:8080`
   - Login with `admin`/`password`
   - Test monitoring endpoints

## 🎯 **Benefits of Pre-Built Deployment**

✅ **No .NET SDK required** on server - only Runtime needed  
✅ **Fast deployment** - no build time on server  
✅ **Simple and reliable** - just copy and deploy  
✅ **Perfect for production** - minimal server requirements  
✅ **Consistent builds** - built once, deployed anywhere  

## 📁 **File Structure**

```
simple-iis-app/
├── DEPLOY.bat                     ← 🚀 PRE-BUILT DEPLOYMENT SCRIPT
├── simple-iis-app.csproj
├── Program.cs
├── Controllers/
├── Views/
└── bin/Release/net9.0/publish/   ← ✅ READY-TO-DEPLOY FILES
    ├── simple-iis-app.dll        ← Your application
    ├── web.config                 ← IIS configuration  
    ├── appsettings.json          ← App settings
    ├── All Serilog DLLs           ← Logging dependencies
    └── [All .NET dependencies]    ← Runtime libraries
```

## 🚨 **Troubleshooting**

### "Pre-built application files not found"
- Ensure the `bin\Release\net9.0\publish\` directory exists
- The application is already built - this folder should contain all deployment files
- If missing, you may have an incomplete download or copy

### Application won't start in IIS
- Verify .NET 9.0 Runtime (Windows Hosting Bundle) is installed
- Check IIS Application Pool is set to "No Managed Code"
- Verify directory permissions for `IIS AppPool\simple-iis-app`
- Ensure `simple-iis-app.dll` exists in the IIS directory

### Permission errors during deployment
- Make sure you're running `DEPLOY.bat` as Administrator
- Check that the `C:\inetpub\wwwroot\` directory is accessible

---

**🎉 This pre-built deployment process eliminates .NET SDK requirements and provides a fast, reliable deployment experience!**
