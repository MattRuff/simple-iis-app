# 📝 Serilog Agentless Logging Setup

This application is configured with **Serilog v8.0+** for agentless logging directly to Datadog.

## 🎯 **Features Configured**

### **📦 Packages Installed:**
- `Serilog.AspNetCore` (8.0.2) - Main Serilog integration
- `Serilog.Sinks.Datadog.Logs` (0.5.2) - Direct Datadog integration
- `Serilog.Enrichers.Environment` (3.0.1) - Environment enrichment
- `Serilog.Enrichers.Process` (3.0.0) - Process ID enrichment
- `Serilog.Enrichers.Thread` (4.0.0) - Thread ID enrichment
- `Serilog.Formatting.Compact` (3.0.0) - Structured JSON formatting

### **🔧 Configuration:**

**Enrichers Added:**
- ✅ Environment name
- ✅ Machine name  
- ✅ Process ID
- ✅ Thread ID
- ✅ Custom application properties

**Sinks Configured:**
- ✅ **Console**: Structured JSON output for local debugging
- ✅ **Datadog**: Direct agentless logging to Datadog

## 🚀 **Setup Requirements**

### **1. Required Datadog Environment Variables**

**Set these environment variables (deployment script sets most automatically):**

```powershell
# REQUIRED - Set your Datadog API key manually
[System.Environment]::SetEnvironmentVariable("DD_API_KEY", "your-actual-api-key", [System.EnvironmentVariableTarget]::Machine)

# Optionally change site (default: datadoghq.com)
# [System.Environment]::SetEnvironmentVariable("DD_SITE", "datadoghq.eu", [System.EnvironmentVariableTarget]::Machine)
```

**Automatically configured by deployment script:**
- `DD_ENV=testing` - Environment name
- `DD_LOGS_INJECTION=true` - Links logs with traces
- `DD_LOGS_DIRECT_SUBMISSION_INTEGRATIONS=Serilog` - **Critical for agentless logging**
- `DD_DEPLOYMENT_VERSION` - Application version from deployment

**Note:** `DD_SITE` is **not set** by default - uses Datadog's default (US1/datadoghq.com)

### **2. Datadog Site Configuration**
The application automatically routes logs to the correct intake URL based on `DD_SITE`:
- **Not set** → US1 (datadoghq.com) - **Default behavior**
- `datadoghq.eu` → EU  
- `us3.datadoghq.com` → US3
- `us5.datadoghq.com` → US5
- `ddog-gov.com` → US1-FED

**To change site (optional):**
```powershell
[System.Environment]::SetEnvironmentVariable("DD_SITE", "datadoghq.eu", [System.EnvironmentVariableTarget]::Machine)
```

## 📊 **Log Structure**

**Example structured log:**
```json
{
  "@t": "2025-09-22T20:30:15.123Z",
  "@l": "Information", 
  "@m": "🏠 Home page accessed by {User} from {UserAgent} at {IpAddress}",
  "User": "admin",
  "UserAgent": "Mozilla/5.0...",
  "IpAddress": "192.168.1.100",
  "Environment": "testing",
  "MachineName": "IIS-SERVER",
  "ProcessId": 1234,
  "ThreadId": 5,
  "Application": "SimpleIISApp",
  "Version": "2025-09-22_20-30-15"
}
```

## 🔍 **Datadog Integration**

**Configured Datadog Tags:**
- `env:testing` (from DD_ENV)
- `source:serilog`
- `application:simple-iis-app`
- `service:simple-iis-app`

**Datadog Configuration:**
- **URL**: `https://http-intake.logs.datadoghq.com`
- **Port**: 443 (HTTPS)
- **Source**: `csharp`
- **Host**: Machine name

## 📝 **Usage Examples**

**Basic Logging:**
```csharp
Log.Information("User {UserId} performed action {Action}", userId, action);
```

**Error Logging:**
```csharp
Log.Error(ex, "Failed to process request for {User}", username);
```

**Structured Data:**
```csharp
Log.Information("API call completed in {Duration}ms with status {StatusCode}", 
    duration, response.StatusCode);
```

## 🎯 **Benefits**

- ✅ **Agentless**: No Datadog agent required
- ✅ **Structured**: Rich JSON logging with context
- ✅ **Real-time**: Direct streaming to Datadog
- ✅ **Enriched**: Automatic environment/process metadata
- ✅ **Integrated**: Works with existing Datadog infrastructure
- ✅ **Performance**: Async logging with buffering

## 🔧 **Troubleshooting**

**If logs don't appear in Datadog:**
1. Verify `DD_API_KEY` is set correctly
2. Check console output for JSON logs
3. Verify network connectivity to `http-intake.logs.datadoghq.com`
4. Check Datadog Log Explorer with filter: `source:serilog`

**Console Output Test:**
Look for structured JSON logs in the console/IIS logs to confirm Serilog is working.
