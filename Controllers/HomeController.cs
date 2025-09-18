using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace SimpleIISApp.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            ViewBag.ServerTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            ViewBag.MachineName = Environment.MachineName;
            ViewBag.UserName = Environment.UserName;
            ViewBag.OSVersion = Environment.OSVersion.ToString();
            ViewBag.DotNetVersion = Environment.Version.ToString();
            ViewBag.IsAuthenticated = User.Identity?.IsAuthenticated ?? false;
            
            return View();
        }

        [Authorize]
        public IActionResult Dashboard()
        {
            ViewBag.ServerTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            ViewBag.MachineName = Environment.MachineName;
            ViewBag.UserName = Environment.UserName;
            ViewBag.OSVersion = Environment.OSVersion.ToString();
            ViewBag.DotNetVersion = Environment.Version.ToString();
            ViewBag.LoginTime = User.FindFirst("LoginTime")?.Value ?? "Unknown";
            ViewBag.CurrentUser = User.Identity?.Name ?? "Unknown";

            // Log dashboard access for monitoring
            _logger.LogInformation("Dashboard accessed by user: {User} at {Time}", 
                User.Identity?.Name, DateTime.Now);

            return View();
        }

        public IActionResult About()
        {
            return View();
        }

        public IActionResult Error()
        {
            return View();
        }

        // Healthcheck endpoint for monitoring tools like Datadog
        [HttpGet("/api/healthcheck")]
        public IActionResult HealthCheck()
        {
            var healthData = new
            {
                Status = "Healthy",
                Timestamp = DateTime.UtcNow,
                Server = Environment.MachineName,
                Version = Environment.Version.ToString(),
                Uptime = Environment.TickCount64 / 1000, // seconds
                MemoryUsage = GC.GetTotalMemory(false) / 1024 / 1024, // MB
                ProcessId = Environment.ProcessId
            };

            // Log healthcheck for observability
            _logger.LogInformation("Health check performed: Status={Status}, Server={Server}, Memory={Memory}MB", 
                healthData.Status, healthData.Server, healthData.MemoryUsage);

            return Json(healthData);
        }

        // Additional monitoring endpoint for detailed metrics
        [HttpGet("/api/metrics")]
        public IActionResult Metrics()
        {
            var metrics = new
            {
                Timestamp = DateTime.UtcNow,
                Server = new
                {
                    Name = Environment.MachineName,
                    OS = Environment.OSVersion.ToString(),
                    ProcessorCount = Environment.ProcessorCount,
                    WorkingSet = Environment.WorkingSet / 1024 / 1024, // MB
                    UpTime = Environment.TickCount64 / 1000 // seconds
                },
                Application = new
                {
                    Version = Environment.Version.ToString(),
                    ProcessId = Environment.ProcessId,
                    MemoryUsage = GC.GetTotalMemory(false) / 1024 / 1024, // MB
                    ThreadCount = System.Diagnostics.Process.GetCurrentProcess().Threads.Count
                },
                Authentication = new
                {
                    IsAuthenticated = User.Identity?.IsAuthenticated ?? false,
                    UserName = User.Identity?.Name ?? "Anonymous"
                },
                Git = new
                {
                    CommitSha = Environment.GetEnvironmentVariable("DD_GIT_COMMIT_SHA") ?? "unknown",
                    RepositoryUrl = Environment.GetEnvironmentVariable("DD_GIT_REPOSITORY_URL") ?? "unknown"
                }
            };

            _logger.LogInformation("Metrics endpoint accessed by {User} - Git SHA: {GitSha}", 
                User.Identity?.Name ?? "Anonymous", 
                Environment.GetEnvironmentVariable("DD_GIT_COMMIT_SHA") ?? "unknown");

            return Json(metrics);
        }

        // Dedicated endpoint for git information (useful for Datadog deployment tracking)
        [HttpGet("/api/git-info")]
        public IActionResult GitInfo()
        {
            var gitInfo = new
            {
                CommitSha = Environment.GetEnvironmentVariable("DD_GIT_COMMIT_SHA") ?? "unknown",
                RepositoryUrl = Environment.GetEnvironmentVariable("DD_GIT_REPOSITORY_URL") ?? "unknown",
                DeploymentTime = DateTime.UtcNow,
                Version = "1.0.0",
                Environment = Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") ?? "Production"
            };

            _logger.LogInformation("Git info endpoint accessed - SHA: {GitSha}, Repo: {Repo}", 
                gitInfo.CommitSha, gitInfo.RepositoryUrl);

            return Json(gitInfo);
        }

        // Error testing endpoint for Datadog monitoring
        [HttpPost("/api/trigger-error")]
        public IActionResult TriggerError(string errorType = "exception")
        {
            var gitSha = Environment.GetEnvironmentVariable("DD_GIT_COMMIT_SHA") ?? "unknown";
            var user = User.Identity?.Name ?? "Anonymous";
            
            _logger.LogWarning("🚨 Error intentionally triggered by {User} - Type: {ErrorType}, Git SHA: {GitSha}", 
                user, errorType, gitSha);

            switch (errorType.ToLower())
            {
                case "nullreference":
                    _logger.LogError("Triggering NullReferenceException for Datadog testing");
                    string nullString = null;
                    return Json(new { length = nullString.Length }); // This will throw NullReferenceException

                case "argumentnull":
                    _logger.LogError("Triggering ArgumentNullException for Datadog testing");
                    throw new ArgumentNullException("testParameter", "This is a test ArgumentNullException for Datadog monitoring");

                case "invalidoperation":
                    _logger.LogError("Triggering InvalidOperationException for Datadog testing");
                    var emptyList = new List<string>();
                    return Json(new { first = emptyList.First() }); // This will throw InvalidOperationException

                case "dividebyzero":
                    _logger.LogError("Triggering DivideByZeroException for Datadog testing");
                    int zero = 0;
                    return Json(new { result = 10 / zero }); // This will throw DivideByZeroException

                case "outofrange":
                    _logger.LogError("Triggering IndexOutOfRangeException for Datadog testing");
                    var array = new int[] { 1, 2, 3 };
                    return Json(new { value = array[10] }); // This will throw IndexOutOfRangeException

                case "custom":
                    _logger.LogError("Triggering custom exception for Datadog testing");
                    throw new ApplicationException($"Custom test error triggered by {user} at {DateTime.UtcNow} (Git SHA: {gitSha})");

                case "timeout":
                    _logger.LogError("Triggering TimeoutException for Datadog testing");
                    throw new TimeoutException("Simulated timeout error for Datadog monitoring");

                default:
                    _logger.LogError("Triggering generic Exception for Datadog testing");
                    throw new Exception($"Generic test exception triggered by {user} at {DateTime.UtcNow} (Git SHA: {gitSha}) - This is for Datadog error monitoring testing");
            }
        }

        // Error testing page
        [HttpGet]
        public IActionResult ErrorTesting()
        {
            ViewBag.Title = "Error Testing - Datadog Monitoring";
            return View();
        }
    }
}
