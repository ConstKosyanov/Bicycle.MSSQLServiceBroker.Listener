using System;
using System.Collections.Generic;
using System.Data.SqlClient;

using Bicycle.MSSQLServiceBroker.Listener;

using Microsoft.Extensions.CommandLineUtils;

namespace SystemTest
{
    class Program
    {
        private static string connectionString;
        private static string tableName;

        static readonly Dictionary<Guid, MyClass> data = new Dictionary<Guid, MyClass>();

        static void Main(string[] args)
        {
            if(ReadArgs(args) == -1)
            {
                Exit();
                return;
            }

            Console.WriteLine(connectionString);
            Console.WriteLine(tableName);

            PreloadData();

            using(var Ilistener = NewServiceBrokerListener(TriggerType.Insert, OnInsert))
            using(var Ulistener = NewServiceBrokerListener(TriggerType.Update, OnUpdate))
            using(var Dlistener = NewServiceBrokerListener(TriggerType.Delete, OnDelete))
            {
                Exit();
            }
        }

        static void Exit()
        {
            while(Console.KeyAvailable) Console.ReadKey(true);
            Console.WriteLine("Press Esc to exit...");
            while(Console.ReadKey(true).Key != ConsoleKey.Escape) ;
            Console.WriteLine("Stoping...");
        }

        private static int ReadArgs(string[] args)
        {
            var commandLine = new CommandLineApplication();
            var cs = commandLine.Option("-c", "connection string", CommandOptionType.SingleValue);
            var t = commandLine.Option("-t", "table name", CommandOptionType.SingleValue);
            commandLine.OnExecute(() =>
            {
                if(cs.HasValue() && t.HasValue())
                {
                    connectionString = cs.Value();
                    tableName = t.Value();
                    return 2;
                }
                else
                {
                    commandLine.ShowHelp();
                    return -1;
                }
            });
            return commandLine.Execute(args);
        }

        private static void OnInsert(object sender, MyEventArgs<MyClass> e)
        {
            foreach(var item in e.Items)
                data.Add(item.Id, item);
            Print();
        }

        private static void OnUpdate(object sender, MyEventArgs<MyClass> e)
        {
            foreach(var item in e.Items)
                data[item.Id] = item;
            Print();
        }

        private static void OnDelete(object sender, MyEventArgs<MyClass> e)
        {
            foreach(var item in e.Items)
                data.Remove(item.Id);
            Print();
        }

        private static void Print()
        {
            Console.Clear();
            foreach(var item in data.Values)
                Console.WriteLine($"{item.Id} - {item.Value}");
        }

        private static ServiceBrokerListener<MyClass> NewServiceBrokerListener(TriggerType triggerType, EventHandler<MyEventArgs<MyClass>> @delegate)
        {
            var listener = new ServiceBrokerListener<MyClass>(connectionString, tableName, triggerType, @delegate);
            listener.OnExceptoin += (s, e) =>
            {
                var ex = e.Exception;
                do
                {
                    Console.WriteLine(ex.Message);
                    ex = ex.InnerException;
                } while(ex != null);

                listener.StopListening();
            };
            listener.StartListening();
            return listener;
        }
        private static void PreloadData()
        {
            using(var connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using(var command = new SqlCommand("SELECT * FROM dbo.TestTable", connection))
                using(var reader = command.ExecuteReader())
                    NewMethod(reader);
            }

            Print();
        }

        private static void NewMethod(SqlDataReader reader)
        {
            while(reader.Read())
            {
                var item = new MyClass
                {
                    Id = reader.GetGuid(0),
                    Value = reader.GetString(1)
                };
                data[item.Id] = item;
            }
        }
    }

    public class MyClass
    {
        public Guid Id { get; set; }
        public string Value { get; set; }
    }
}
