using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
                }
            };

            _logger.LogInformation("Metrics endpoint accessed by {User}", 
                User.Identity?.Name ?? "Anonymous");

            return Json(metrics);
        }
    }
}
