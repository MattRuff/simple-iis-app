# 🐕 Datadog Integration Guide

This Simple IIS App is **optimized for Datadog monitoring** with built-in integrations for observability and error tracking.

## 🔗 **SourceLink Integration**

### **Automatic Git Information Extraction**

✅ **Microsoft SourceLink is configured** in this project for GitHub  
✅ **Datadog can automatically extract** git commit SHA and repository URL from the .NET assembly  
✅ **No manual configuration needed** - git info is embedded during build  

### **How It Works**

When you deploy this application, Datadog will automatically discover:

- 📋 **Git Commit SHA** - Exact commit that built the deployed version
- 🔗 **Repository URL** - Link to the source repository (GitHub)
- 🏷️ **Source Files** - Direct links to source code for debugging

### **Configuration Details**

The project includes:

```xml
<PropertyGroup>
  <!-- SourceLink configuration for Datadog git integration -->
  <PublishRepositoryUrl>true</PublishRepositoryUrl>
  <EmbedUntrackedSources>true</EmbedUntrackedSources>
  <IncludeSymbols>true</IncludeSymbols>
  <SymbolPackageFormat>snupkg</SymbolPackageFormat>
</PropertyGroup>

<ItemGroup>
  <!-- Microsoft SourceLink for GitHub -->
  <PackageReference Include="Microsoft.SourceLink.GitHub" Version="1.1.1" PrivateAssets="All"/>
</ItemGroup>
```

## 📊 **Monitoring Endpoints**

### **Health Checks**
- 💓 `/health` - Standard ASP.NET Core health check
- 📈 `/api/healthcheck` - Custom health check with JSON response
- 📊 `/api/metrics` - Application metrics including git information

### **Git Information API**
- 🔍 `/api/git-info` - Dedicated endpoint for deployment tracking
  - Returns commit SHA, branch, repository URL
  - Includes deployment timestamp and version
  - Perfect for Datadog deployment tracking

### **Error Testing**
- 🐛 `/api/trigger-error` - Triggers various exception types for testing monitoring
- 🔥 Multiple error types: NullReference, ArgumentNull, Timeout, etc.
- 📝 Comprehensive error logging with stack traces

## 🏷️ **Environment Variables**

The deployment script automatically sets:

### **Git & Deployment Tracking**
```bash
DD_GIT_COMMIT_SHA=<actual-git-sha>
DD_GIT_COMMIT_SHA_SHORT=<short-sha>
DD_GIT_BRANCH=<branch-name>
DD_GIT_REPOSITORY_URL=https://github.com/MattRuff/simple-iis-app.git
DD_GIT_COMMIT_MESSAGE=<commit-message>
DD_DEPLOYMENT_VERSION=<timestamp>
DD_DEPLOYMENT_TIME=<deployment-time>
```

### **Datadog .NET Tracer Configuration** ⭐ **NEW**
```bash
DD_ENV=testing
DD_LOGS_INJECTION=true
DD_RUNTIME_METRICS_ENABLED=true
DD_PROFILING_ENABLED=true
```

These machine-level variables configure the Datadog .NET tracer for:
- ✅ **Environment tagging** (testing environment)
- ✅ **Automatic log injection** with trace correlation
- ✅ **Runtime metrics** (GC, memory, CPU usage)
- ✅ **Continuous profiling** for performance analysis

All variables are available to your application and Datadog for comprehensive observability.

## 🎯 **Benefits for Datadog Users**

### **Automatic Deployment Tracking**
- ✅ No manual tagging required
- ✅ Automatic correlation between deployments and performance changes
- ✅ Direct links to source code from stack traces

### **Enhanced Error Tracking**
- ✅ Full stack traces with source links
- ✅ Automatic git context for every error
- ✅ Easy debugging from production errors back to source

### **Observability Integration**
- ✅ Health checks every 30 seconds from the UI
- ✅ Structured logging with git context
- ✅ Custom metrics with deployment information
- ✅ Error testing endpoints for validation

## 🔧 **Customization**

### **For Other Git Providers**

If your repository is hosted elsewhere, replace the SourceLink package:

```xml
<!-- For Bitbucket -->
<PackageReference Include="Microsoft.SourceLink.Bitbucket.Git" Version="1.1.1" PrivateAssets="All"/>

<!-- For GitLab -->
<PackageReference Include="Microsoft.SourceLink.GitLab" Version="1.1.1" PrivateAssets="All"/>

<!-- For Azure DevOps -->
<PackageReference Include="Microsoft.SourceLink.AzureRepos.Git" Version="1.1.1" PrivateAssets="All"/>

<!-- For Azure DevOps Server -->
<PackageReference Include="Microsoft.SourceLink.AzureDevOpsServer.Git" Version="1.1.1" PrivateAssets="All"/>
```

### **Custom Git Information**

The application includes manual fallbacks for ZIP downloads:
- API extraction from GitHub
- Deployment-based versioning
- Manual configuration options

## 📋 **Verification**

After deployment, verify SourceLink integration:

1. **Check the `/api/git-info` endpoint** - should show real git data
2. **Trigger an error** via `/api/trigger-error`
3. **View in Datadog** - errors should include git context and source links
4. **Stack traces** should link back to the exact source code

Perfect for testing Datadog's full observability stack! 🎉
