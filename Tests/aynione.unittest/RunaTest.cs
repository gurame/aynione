using aynione.core;
using System;
using System.Collections.Generic;
using System.Text;
using Xunit;

namespace aynione.unittest
{
    public class RunaTest
    {
        [Fact]
        public void CreateRuna()
        {
            var runa = new Runa();
            runa.Create("test");
            Assert.NotNull(runa.Name);  
        }
    }
}
