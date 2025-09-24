# 📝 Deployment Logs Guide

The `DEPLOY.bat` script automatically creates detailed log files to help debug any issues during deployment.

## 📁 Log Files Created

When you run `DEPLOY.bat`, it creates a `logs/` folder with these files:

### **📄 Main Log** (`deploy_YYYY-MM-DD_HH-mm-ss.log`)
- **Purpose**: Overall deployment progress and status
- **Contains**: Step-by-step progress, success/failure messages, timestamps
- **Use for**: Understanding which step failed and when

### **🔍 Debug Log** (`debug_YYYY-MM-DD_HH-mm-ss.log`)
- **Purpose**: Detailed system and environment information
- **Contains**: 
  - Complete `.NET` environment info (`dotnet --info`)
  - Project file contents (`simple-iis-app.csproj`)
  - System configuration details
- **Use for**: Understanding environment issues, package compatibility

### **📦 NuGet Log** (`nuget_YYYY-MM-DD_HH-mm-ss.log`)
- **Purpose**: Detailed package restore and NuGet operations
- **Contains**:
  - NuGet sources configuration
  - Package restore detailed output
  - Cache clearing operations
  - SourceLink package resolution attempts
- **Use for**: Debugging SourceLink and package restore issues

### **🔨 Build Log** (`build_YYYY-MM-DD_HH-mm-ss.log`)
- **Purpose**: Detailed build and publish operations
- **Contains**:
  - Complete build output with all warnings/errors
  - Publish operation details
  - Compilation details
- **Use for**: Understanding build failures, missing dependencies

## 🔍 How to Use the Logs

### **When SourceLink/NuGet Issues Occur:**

1. **Check NuGet Log first:**
   ```
   logs/nuget_YYYY-MM-DD_HH-mm-ss.log
   ```
   Look for:
   - Package source issues
   - Network connectivity problems
   - Version compatibility errors
   - Cache corruption indicators

2. **Check Debug Log:**
   ```
   logs/debug_YYYY-MM-DD_HH-mm-ss.log
   ```
   Look for:
   - .NET version compatibility
   - Project file syntax issues
   - Environment configuration problems

### **When Build Fails:**

1. **Check Build Log:**
   ```
   logs/build_YYYY-MM-DD_HH-mm-ss.log
   ```
   Look for:
   - Compilation errors
   - Missing package references
   - Target framework issues

2. **Cross-reference with Main Log** for timing and context

## 🛠️ Common Issues and Log Patterns

### **SourceLink Package Issues**
```
NuGet Log: "Unable to resolve 'Microsoft.SourceLink.GitHub'"
```
**Solutions:**
- Check internet connectivity
- Verify NuGet sources in debug log
- Try different SourceLink version

### **Build Environment Issues**
```
Debug Log: Shows .NET version incompatibility
```
**Solutions:**
- Update .NET SDK
- Check target framework compatibility

### **Permission Issues**
```
Main Log: "Build completed with exit code: 1"
Build Log: "Access denied" errors
```
**Solutions:**
- Run as Administrator
- Check file permissions

## 📋 Log Retention

- **Automatic**: New log files created for each deployment run
- **Manual Cleanup**: Delete old logs from `logs/` folder as needed
- **Size**: Logs are typically small (< 1MB each) unless there are extensive errors

## 🚨 Emergency Debugging

If the script fails completely:

1. **Open Command Prompt as Administrator**
2. **Navigate to project folder**
3. **Run individual commands:**
   ```cmd
   dotnet nuget locals all --clear
   dotnet restore --verbosity detailed
   dotnet build -c Release --verbosity detailed
   ```
4. **Check output for specific error messages**

The logging system provides comprehensive visibility into every aspect of the deployment process! 🔍
