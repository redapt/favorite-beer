using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Distributed;

namespace voting.Controllers
{
    [Route("api/[controller]")]
    public class VoteController : Controller
    {
        private readonly IDistributedCache _distributedCache;

        public VoteController(IDistributedCache distributedCache)
        {
            _distributedCache = distributedCache;
        }
        
        private static string[] BeerData = new[]
        {
            "Beer 1", "Beer 2", "Beer 3"
        };

        [HttpGet("[action]")]
        public IEnumerable<Beer> options()
        {
            return Enumerable.Range(0, 3).Select(index => new Beer
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