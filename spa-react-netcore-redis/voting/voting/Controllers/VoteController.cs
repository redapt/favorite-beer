using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Options;

namespace voting.Controllers
{
    [Route("api/[controller]")]
    public class VoteController : Controller
    {
        private readonly IDistributedCache _distributedCache;
        private readonly IOptions<ServiceSettings> _serviceSettings; 
        private readonly string[] BeerData;

        public VoteController(IDistributedCache distributedCache, IOptions<ServiceSettings> serviceSettings)
        {
            _distributedCache = distributedCache;
            _serviceSettings = serviceSettings;
            BeerData = _serviceSettings.Value.Beers;
        }

        [HttpGet("[action]")]
        public IEnumerable<Beer> options()
        {
            return Enumerable.Range(0, BeerData.Length).Select(index => new Beer
            {
                Name = BeerData[index],
                CurrentCount = int.Parse(System.Text.Encoding.UTF8.GetString(_distributedCache.Get(BeerData[index]) ?? System.Text.Encoding.UTF8.GetBytes("0")))
            });
        }

        [HttpGet("[action]/{id}")]
        public ActionResult<Beer> options(string id)
        {
            var index = Array.IndexOf(BeerData, id);
            if(index >= 0)
            {
                int count = int.Parse(System.Text.Encoding.UTF8.GetString(_distributedCache.Get(BeerData[index]) ?? System.Text.Encoding.UTF8.GetBytes("0"))) + 1;
                var cacheOptions = new DistributedCacheEntryOptions {  
                    AbsoluteExpiration = DateTime.Now.AddYears(10)  
                };
                _distributedCache.Set(BeerData[index], System.Text.Encoding.UTF8.GetBytes(count.ToString()), cacheOptions);
                return new Beer
                {
                    Name = BeerData[index],
                    CurrentCount = count
                };
            } 
            else 
            {
                return NotFound();
            }
        }


        public class Beer
        {
            public string Name { get; set; }
            public int CurrentCount { get; set; }
        }
    }
}