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
            var timestamp = DateTime.UtcNow;
            var userAgent = Request.Headers["User-Agent"].ToString();
            var clientIp = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown";
            
            _logger.LogWarning("🚨 INTENTIONAL ERROR TRIGGER - User: {User}, Type: {ErrorType}, Git SHA: {GitSha}, Timestamp: {Timestamp}, IP: {ClientIp}, UserAgent: {UserAgent}", 
                user, errorType, gitSha, timestamp, clientIp, userAgent);

            try
            {
                switch (errorType.ToLower())
                {
                    case "nullreference":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering NullReferenceException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        string nullString = null;
                        return Json(new { length = nullString.Length }); // This will throw NullReferenceException

                    case "argumentnull":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering ArgumentNullException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        throw new ArgumentNullException("testParameter", $"DATADOG TEST: ArgumentNullException triggered by {user} at {timestamp} (Git SHA: {gitSha}) from IP: {clientIp}");

                    case "invalidoperation":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering InvalidOperationException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var emptyList = new List<string>();
                        return Json(new { first = emptyList.First() }); // This will throw InvalidOperationException

                    case "dividebyzero":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering DivideByZeroException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        int zero = 0;
                        return Json(new { result = 10 / zero }); // This will throw DivideByZeroException

                    case "outofrange":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering IndexOutOfRangeException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var array = new int[] { 1, 2, 3 };
                        return Json(new { value = array[10] }); // This will throw IndexOutOfRangeException

                    case "custom":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering custom exception for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var customEx = new ApplicationException($"DATADOG MONITORING TEST: Custom exception triggered by {user} at {timestamp} (Git SHA: {gitSha}) from IP: {clientIp} with UserAgent: {userAgent}");
                        customEx.Data.Add("GitCommitSha", gitSha);
                        customEx.Data.Add("TriggeringUser", user);
                        customEx.Data.Add("ClientIP", clientIp);
                        customEx.Data.Add("Timestamp", timestamp.ToString("O"));
                        customEx.Data.Add("ErrorType", "custom");
                        throw customEx;

                    case "timeout":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering TimeoutException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var timeoutEx = new TimeoutException($"DATADOG MONITORING TEST: Timeout error triggered by {user} at {timestamp} (Git SHA: {gitSha})");
                        timeoutEx.Data.Add("GitCommitSha", gitSha);
                        timeoutEx.Data.Add("TriggeringUser", user);
                        throw timeoutEx;

                    case "aggregate":
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering AggregateException for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var innerEx1 = new InvalidOperationException("First inner exception for testing");
                        var innerEx2 = new ArgumentException("Second inner exception for testing");
                        throw new AggregateException($"DATADOG TEST: Multiple errors occurred (triggered by {user})", innerEx1, innerEx2);

                    default:
                        _logger.LogError("🔥 STACK TRACE TEST: Triggering generic Exception for Datadog testing - User: {User}, Git: {GitSha}", user, gitSha);
                        var genericEx = new Exception($"DATADOG MONITORING TEST: Generic exception triggered by {user} at {timestamp} (Git SHA: {gitSha}) from IP: {clientIp}");
                        genericEx.Data.Add("GitCommitSha", gitSha);
                        genericEx.Data.Add("TriggeringUser", user);
                        genericEx.Data.Add("ClientIP", clientIp);
                        genericEx.Data.Add("Timestamp", timestamp.ToString("O"));
                        genericEx.Data.Add("UserAgent", userAgent);
                        genericEx.Data.Add("ErrorType", "generic");
                        throw genericEx;
                }
            }
            catch (Exception ex)
            {
                // Log the full exception with stack trace before re-throwing
                _logger.LogError(ex, "🚨 DATADOG ERROR CAPTURED - Full Stack Trace: {ExceptionType} triggered by {User} with Git SHA: {GitSha}. Stack Trace: {StackTrace}", 
                    ex.GetType().Name, user, gitSha, ex.StackTrace);
                
                // Add explicit Datadog span attributes for error tracking
                // These ensure Datadog's error.stack, error.message, and error.type span attributes are set
                _logger.LogError("🔍 DATADOG SPAN ATTRIBUTES - error.type: {ErrorType}, error.message: {ErrorMessage}, error.stack: {ErrorStack}", 
                    ex.GetType().FullName, ex.Message, ex.StackTrace);
                
                // Re-throw to ensure it propagates to Datadog
                throw;
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
