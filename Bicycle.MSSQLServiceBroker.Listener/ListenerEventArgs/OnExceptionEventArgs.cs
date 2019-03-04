using System;

namespace Bicycle.MSSQLServiceBroker.Listener.ListenerEventArgs
{
    public class OnExceptionEventArgs
    {
        public OnExceptionEventArgs(Exception ex) => Exception = ex;

        public Exception Exception { get; set; }
    }
}