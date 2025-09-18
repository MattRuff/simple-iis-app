using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace SimpleIISApp.Controllers
{
    public class HomeController : Controller
    {
        public IActionResult Index()
        {
            ViewBag.ServerTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            ViewBag.MachineName = Environment.MachineName;
            ViewBag.UserName = Environment.UserName;
            ViewBag.OSVersion = Environment.OSVersion.ToString();
            ViewBag.DotNetVersion = Environment.Version.ToString();
            
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
    }
}
