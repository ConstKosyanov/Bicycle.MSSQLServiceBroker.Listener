using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Serialization;

using Bicycle.FExtensions;
using Bicycle.MSSQLServiceBroker.Listener.ListenerEventArgs;

namespace Bicycle.MSSQLServiceBroker.Listener
{
    public class ServiceBrokerListener<T> : IDisposable
        where T : new()
    {
        private static readonly XmlReaderSettings defaultXmlReaderSettings = new XmlReaderSettings
        {
            ConformanceLevel = ConformanceLevel.Fragment
        };

        private readonly XmlSerializer xmlSerializer = new XmlSerializer(typeof(T), new XmlRootAttribute("row"));
        private readonly SqlConnection sqlConnection;
        private readonly SqlCommand sqlCommand;
        private readonly CancellationTokenSource tokenSource;
        public event EventHandler<ListeningEventArgs<T>> OnNext;
        public event EventHandler<OnExceptionEventArgs> OnExceptoin;

        /// <summary></summary>
        /// <param name="connectionString">Connection string to the MS SQL server</param>
        /// <param name="tableName">Table name, what trigger will be listened</param>
        /// <param name="triggerType">What trigger of the Table will be listened</param>
        public ServiceBrokerListener(string connectionString, string tableName, TriggerType triggerType, EventHandler<ListeningEventArgs<T>> onNext)
            : this(connectionString, "dbo", tableName, triggerType, onNext) { }

        public ServiceBrokerListener(string connectionString, string schemeName, string tableName, TriggerType triggerType, EventHandler<ListeningEventArgs<T>> onNext)
        {
            sqlConnection = new SqlConnection(connectionString);
            sqlConnection.Open();
            sqlCommand = new SqlCommand(GetQueryBody(schemeName, tableName, triggerType), sqlConnection) { CommandTimeout = 0 };
            tokenSource = new CancellationTokenSource();
            OnNext += onNext;
        }

        private static string GetQueryBody(string schemeName, string tableName, TriggerType triggerType) => $"WAITFOR(RECEIVE message_body FROM [{schemeName}_{tableName}_ServiceBrokerListenerQueueFor{triggerType}])";

        public void StartListening() => Task.Run(() => ListeningAsync(tokenSource.Token), tokenSource.Token);
        public void StopListening() => tokenSource.Cancel();

        private async Task ListeningAsync(CancellationToken token)
        {
            var listening = true;
            token.Register(() => listening = false);

            while(listening)
            {
                var sqlDataReader = await Task.Run(async () => await sqlCommand.ExecuteReaderAsync(), token);
                var rows = await ReadFromQueueAsync(sqlDataReader);
                OnNext?.Invoke(this, new ListeningEventArgs<T>(rows));
            }
        }

        private async Task<IEnumerable<T>> ReadFromQueueAsync(SqlDataReader sqlDataReader)
        {
            try
            {
                using(sqlDataReader)
                    while(await sqlDataReader.ReadAsync())
                        using(var stream = sqlDataReader.GetStream(0))
                            return DeserializeStream(stream).ToList();
            }
            catch(Exception ex)
            {
                OnExceptoin?.Invoke(this, new OnExceptionEventArgs(ex));
            }

            return new T[0];
        }

        private IEnumerable<T> DeserializeStream(System.IO.Stream stream)
        {
            using(var reader = XmlReader.Create(stream, defaultXmlReaderSettings))
            {
                reader.Read();
                var sib = reader.Name;

                do yield return xmlSerializer.Deserialize(reader.ReadSubtree()).To<T>();
                while(reader.ReadToNextSibling(sib));
            }
        }

        #region Disposing
        //=================================================
        public void Dispose() => Dispose(true);
        ~ServiceBrokerListener() => Dispose(false);
        void Dispose(bool disposing)
        {
            if(disposing)
            {
                sqlConnection.Close();
                sqlCommand.Dispose();
            }
        }
        //=================================================
        #endregion
    }
}