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
                CurrentCount = 0
            });
        }

        public class Beer
        {
            public string Name { get; set; }
            public int CurrentCount { get; set; }
        }
    }
}