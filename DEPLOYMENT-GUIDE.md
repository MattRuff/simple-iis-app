# 🚀 Simple IIS App - Smart Deployment Process

## 📋 **Overview**

The new **SMART DEPLOYMENT** process automatically detects your deployment scenario:
- ✅ **Pre-built files exist?** Deploy them (only needs .NET Runtime)
- ✅ **No pre-built files?** Build then deploy (requires .NET SDK)
- ✅ **One script handles everything** - no confusion about which to use

## 🧠 **Smart Detection Logic**

### Scenario 1: Pre-Built Deployment 🔍
**When:** `bin\Release\net9.0\publish\simple-iis-app.dll` exists
- ✅ Uses existing pre-built files
- ✅ **No .NET SDK required** on server
- ✅ Faster deployment (no build time)
- ✅ Perfect for production servers

### Scenario 2: Build-and-Deploy 🔨
**When:** No pre-built files found
- ✅ Builds application on the server
- ✅ Requires .NET SDK installation
- ✅ Good for development/testing environments
- ✅ Provides helpful guidance if SDK missing

## 🛠️ **Development Machine (Optional Pre-Building)**

### If you want to pre-build for faster server deployment:

1. **Build the application locally:**
   ```bash
   # Manual build commands:
   dotnet build -c Release
   dotnet publish -c Release -o bin\Release\net9.0\publish
   ```

2. **Transfer to server:**
   - Copy the entire project folder (including `bin\Release\net9.0\publish\`)
   - Transfer to your server (via RDP, file share, etc.)

## 🖥️ **Server Machine (Deploy)**

### Prerequisites:
- ✅ Windows Server with IIS installed
- ✅ Administrator privileges
- ✅ **For pre-built**: .NET 9.0 Runtime (Windows Hosting Bundle)
- ✅ **For build-on-server**: .NET 9.0 SDK

### Steps:
1. **Run the smart deployment script:**
   ```bash
   # Right-click and "Run as administrator"
   DEPLOY.bat
   ```

2. **The script will automatically:**
   - 🔍 Detect if pre-built files exist
   - 🔨 Build if needed (with helpful error messages)
   - 📁 Copy files to IIS directory
   - ⚙️ Set up Datadog environment variables
   - 📝 Provide manual IIS configuration instructions

3. **Follow manual IIS setup:**
   - Create Application Pool (`simple-iis-app`, No Managed Code)
   - Create Website (port 8080, point to `C:\inetpub\wwwroot\simple-iis-app`)
   - Set directory permissions

4. **Test deployment:**
   - Browse to `http://localhost:8080`
   - Login with `admin`/`password`
   - Test monitoring endpoints

## 🎯 **Benefits of Smart Deployment**

✅ **One script, multiple scenarios** - no confusion about which file to run  
✅ **Automatic detection** - script figures out what to do  
✅ **Clear error messages** - helpful guidance when things go wrong  
✅ **Flexible deployment** - works for both dev and production workflows  
✅ **Backwards compatible** - still supports building on server when needed

## 📁 **Simplified File Structure**

```
simple-iis-app/
├── DEPLOY.bat                     ← 🆕 ONE SCRIPT FOR EVERYTHING
├── simple-iis-app.csproj
├── Program.cs
├── Controllers/
├── Views/
└── bin/Release/net9.0/publish/   ← Pre-built files (if present)
    ├── simple-iis-app.dll        ← Your application
    ├── web.config                 ← IIS configuration  
    ├── appsettings.json          ← App settings
    └── [All dependencies]         ← Runtime libraries
```

## 🚨 **Troubleshooting**

### "Pre-built application files not found"
- Run `BUILD.bat` on your development machine first
- Verify `bin\Release\net9.0\publish\` directory exists

### "No .NET SDKs were found" on server
- ✅ **Expected!** The server doesn't need SDK
- Only needs .NET Runtime (Windows Hosting Bundle)
- Use `DEPLOY-PREBUILT.bat` instead of `DEPLOY.bat`

### Application won't start in IIS
- Verify .NET 9.0 Runtime is installed
- Check IIS Application Pool is set to "No Managed Code"
- Verify directory permissions for `IIS AppPool\simple-iis-app`

---

**🎉 This new process eliminates .NET SDK issues on the server while providing a faster, more reliable deployment experience!**
