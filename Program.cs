using Microsoft.AspNetCore.Authentication.Cookies;
using Serilog;
using Serilog.Events;
using Serilog.Formatting.Compact;

// Helper function to get the correct Datadog logs URL based on DD_SITE
static string GetDatadogLogsUrl()
{
    var site = Environment.GetEnvironmentVariable("DD_SITE") ?? "datadoghq.com";
    return site switch
    {
        "datadoghq.eu" => "https://http-intake.logs.datadoghq.eu",
        "us3.datadoghq.com" => "https://http-intake.logs.us3.datadoghq.com",
        "us5.datadoghq.com" => "https://http-intake.logs.us5.datadoghq.com",
        "ddog-gov.com" => "https://http-intake.logs.ddog-gov.com",
        _ => "https://http-intake.logs.datadoghq.com" // Default US1
    };
}

// Configure Serilog for agentless Datadog logging
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .MinimumLevel.Override("Microsoft.Hosting.Lifetime", LogEventLevel.Information)
    .Enrich.FromLogContext()
    .Enrich.WithEnvironmentName()
    .Enrich.WithMachineName()
    .Enrich.WithProcessId()
    .Enrich.WithThreadId()
    .Enrich.WithProperty("Application", "SimpleIISApp")
    .Enrich.WithProperty("Environment", Environment.GetEnvironmentVariable("DD_ENV") ?? "development")
    .Enrich.WithProperty("Version", Environment.GetEnvironmentVariable("DD_DEPLOYMENT_VERSION") ?? "1.0.0")
    .WriteTo.Console(new CompactJsonFormatter())
    .WriteTo.DatadogLogs(
        apiKey: Environment.GetEnvironmentVariable("DD_API_KEY") ?? "your-datadog-api-key-here",
        source: "csharp",
        service: "simple-iis-app",
        host: Environment.MachineName,
        tags: new[] { 
            $"env:{Environment.GetEnvironmentVariable("DD_ENV") ?? "development"}", 
            "source:serilog",
            "application:simple-iis-app",
            $"version:{Environment.GetEnvironmentVariable("DD_DEPLOYMENT_VERSION") ?? "1.0.0"}"
        },
        configuration: new Serilog.Sinks.Datadog.Logs.DatadogConfiguration
        {
            Url = GetDatadogLogsUrl(),
            Port = 443
        })
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);

// Add Serilog to the logging pipeline
builder.Host.UseSerilog();

// Add services to the container.
builder.Services.AddControllersWithViews();

// Add authentication services
builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
    {
        options.LoginPath = "/Account/Login";
        options.LogoutPath = "/Account/Logout";
        options.AccessDeniedPath = "/Account/AccessDenied";
        options.ExpireTimeSpan = TimeSpan.FromHours(1);
        options.SlidingExpiration = true;
    });

// Add health checks for monitoring
builder.Services.AddHealthChecks();

var app = builder.Build();

// Log startup information with Serilog
Log.Information("🚀 Application Starting - Simple IIS App");
Log.Information("🔍 Environment: {Environment}", Environment.GetEnvironmentVariable("DD_ENV") ?? "development");
Log.Information("🔍 Git Branch: {GitBranch}", Environment.GetEnvironmentVariable("DD_GIT_BRANCH") ?? "unknown");
Log.Information("🔍 Deployment Version: {Version}", Environment.GetEnvironmentVariable("DD_DEPLOYMENT_VERSION") ?? "1.0.0");
Log.Information("🔍 Machine: {MachineName}", Environment.MachineName);
Log.Information("🔍 Datadog API Key Configured: {HasApiKey}", !string.IsNullOrEmpty(Environment.GetEnvironmentVariable("DD_API_KEY")));

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}

app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// Map health check endpoint for monitoring
app.MapHealthChecks("/health");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();

// Ensure to flush and stop internal timers/threads before application exit
Log.CloseAndFlush();
