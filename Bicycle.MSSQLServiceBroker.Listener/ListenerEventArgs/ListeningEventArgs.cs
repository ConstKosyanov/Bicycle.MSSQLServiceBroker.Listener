using System;
using System.Collections.Generic;
using System.Linq;

namespace Bicycle.MSSQLServiceBroker.Listener.ListenerEventArgs
{
    public class ListeningEventArgs<T> : EventArgs where T : new()
    {
        internal ListeningEventArgs(IEnumerable<T> items) => Items = items.ToList();
        public IEnumerable<T> Items { get; set; }
    }
}