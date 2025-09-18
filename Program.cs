using Microsoft.AspNetCore.Authentication.Cookies;

var builder = WebApplication.CreateBuilder(args);

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

// Log Datadog environment variables for observability
var logger = app.Services.GetRequiredService<ILogger<Program>>();
var gitCommitSha = Environment.GetEnvironmentVariable("DD_GIT_COMMIT_SHA") ?? "unknown";
var gitRepositoryUrl = Environment.GetEnvironmentVariable("DD_GIT_REPOSITORY_URL") ?? "unknown";

logger.LogInformation("🔍 Datadog Git Info - Commit SHA: {CommitSha}", gitCommitSha);
logger.LogInformation("🔍 Datadog Git Info - Repository URL: {RepositoryUrl}", gitRepositoryUrl);

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
