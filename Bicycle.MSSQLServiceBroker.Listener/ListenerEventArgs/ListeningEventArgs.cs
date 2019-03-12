using System;

namespace Bicycle.MSSQLServiceBroker.Listener.ListenerEventArgs
{
    public class ListeningEventArgs<T> : EventArgs where T : new()
    {
        internal ListeningEventArgs(T item) => Item = item;
        public T Item { get; set; }
    }
}