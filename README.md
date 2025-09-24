# Simple IIS App 🚀

A demonstration ASP.NET Core application for testing IIS deployment, authentication, and monitoring on Windows servers. **Perfect for observability testing with tools like Datadog!**

## ✨ **What This Is**

- 🌐 **ASP.NET Core 9.0** web application ready for IIS
- 🔐 **Cookie-based authentication** (admin/password)
- 💓 **Health monitoring** endpoints
- 🐛 **Error testing** for monitoring systems
- 📊 **Structured logging** with Serilog → Datadog
- 🔗 **SourceLink integration** for code debugging
- 🚀 **Pre-built deployment** - no SDK required on server

## 🚀 **Quick Start**

### **1. Launch AWS EC2 Instance**
- **Instance Type**: `t3.small` (Windows)
- **Security**: Allow RDP (port 3389) from **your IP only** ⚠️
- Connect via RDP using downloaded key pair

### **2. Install Prerequisites**
```powershell
# Install IIS (in Server Manager: Add Roles → Web Server IIS)
# Install .NET 9.0 Hosting Bundle
Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/93a0c5b2-5f2c-4e9a-bbe9-46822de0d62c/3d31df7c54b9d52dbae2e5fa0b1ff0c7/dotnet-hosting-9.0.9-win.exe" -OutFile "dotnet-hosting-9.0.9-win.exe"
.\dotnet-hosting-9.0.9-win.exe /install /quiet
iisreset
```

### **3. Deploy Application**
```bash
# Download project
https://github.com/MattRuff/simple-iis-app/archive/refs/heads/main.zip

# Extract and run deployment
Right-click DEPLOY.bat → "Run as administrator"
```

### **4. Install Datadog (Optional)**
```powershell
# Replace XXXXXX with your Datadog API key
$p = Start-Process -Wait -PassThru msiexec -ArgumentList '/qn /i "https://windows-agent.datadoghq.com/datadog-agent-7-latest.amd64.msi" /log C:\Windows\SystemTemp\install-datadog.log APIKEY="XXXXXX" SITE="datadoghq.com" DD_APM_INSTRUMENTATION_ENABLED="iis" DD_APM_INSTRUMENTATION_LIBRARIES="dotnet:3"'
if ($p.ExitCode -eq 0) { iisreset }
```

### **5. Manual IIS Setup**
After running `DEPLOY.bat`, configure IIS manually:

1. **Open IIS Manager**
2. **Create Application Pool**: 
   - Name: `simple-iis-app`
   - .NET CLR Version: `No Managed Code`
3. **Add Website**:
   - Name: `IISApp`
   - Physical Path: `C:\inetpub\wwwroot\simple-iis-app`
   - Port: `8080`
   - Application Pool: `simple-iis-app`
4. **Set Permissions**: Give `IIS AppPool\simple-iis-app` Read & Execute access to the physical path

### **6. Test**
- Browse to: `http://localhost:8080`
- Login: `admin` / `password`
- Check endpoints: `/health`, `/api/metrics`, `/api/trigger-error`

## 🎯 **Key Features**

| Feature | Description | Endpoint |
|---------|-------------|----------|
| 🔐 **Authentication** | Simple login system | `/Account/Login` |
| 💓 **Health Checks** | Monitoring endpoint | `/health` |
| 📊 **Metrics** | JSON metrics for monitoring | `/api/metrics` |
| 🐛 **Error Testing** | Trigger errors for testing | `/api/trigger-error` |
| 📝 **Structured Logs** | Serilog → Datadog direct | Console + Datadog |
| 🔗 **Source Linking** | Code debugging in Datadog | Automatic |

## 📚 **Documentation**

Detailed guides in the [`docs/`](docs/) folder:

- **[AWS EC2 Setup Guide](docs/README-DETAILED.md)** - Complete step-by-step deployment
- **[Datadog Integration](docs/DATADOG-INTEGRATION.md)** - APM, logging, monitoring setup
- **[Serilog Configuration](docs/SERILOG-SETUP.md)** - Agentless logging to Datadog
- **[IIS Setup Guide](docs/IIS-SETUP-GUIDE.txt)** - Manual IIS configuration
- **[Deployment Guide](docs/DEPLOYMENT-GUIDE.md)** - Pre-built deployment process

## 🔧 **For Developers**

### **Local Development**
```bash
dotnet run
# Browse to: https://localhost:7153
```

### **Build for Deployment**
```bash
dotnet publish -c Release -o bin/Release/net9.0/publish/
# Output ready for server deployment
```

## 🚨 **Troubleshooting**

| Issue | Solution |
|-------|----------|
| 500.19 Error | Check ASP.NET Core Module V2 installed |
| Permission Error | Set IIS AppPool permissions on directory |
| .NET Not Found | Install .NET 9.0 Hosting Bundle |
| Datadog Not Working | Check API key and run `iisreset` |

## 🌐 **Live Demo**

Once deployed, your app will have:
- **Main Page**: Server info, authentication status
- **Login**: Test authentication with admin/password
- **Dashboard**: Protected page for authenticated users
- **Error Testing**: Trigger various exceptions for monitoring
- **Health Monitoring**: Automatic 30-second health checks

Perfect for testing IIS deployment, .NET monitoring, and Datadog integration! 🎉

---

**📁 Repository**: https://github.com/MattRuff/simple-iis-app  
**📋 License**: MIT  
**🏷️ Version**: .NET 9.0 | IIS Ready | Datadog Integrated