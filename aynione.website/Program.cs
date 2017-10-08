using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace aynione.website
{
    public class Program
    {
        public static void Main(string[] args)
        {
            try{
                BuildWebHost(args).Run();
			}
            catch( Exception ex ){
                Console.WriteLine(ex.Message);
            }
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                   .UseStartup<Startup>().UseUrls("http://0.0.0.0:50002")
                .Build();
    }
}
