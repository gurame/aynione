using System;
using System.Collections.Generic;
using System.Text;

namespace aynione.core
{
    public  class Runa
    {
        public string Name { get; set; }
        public void Create(string name)
        {
            this.Name = name;
            if (string.IsNullOrWhiteSpace(this.Name))
            {
                throw new ApplicationException("name is required");
            }            
        }
    }
}
