using System;
using Azure.Storage.Queues.Models;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Receiver
{
    public class ReceiverFunction
    {
        private readonly ILogger<ReceiverFunction> _logger;

        public ReceiverFunction(ILogger<ReceiverFunction> logger)
        {
            _logger = logger;
        }

        [Function(nameof(ReceiverFunction))]
        public void Run([QueueTrigger("%QUEUE_NAME%", Connection = "AzureWebJobsStorage")] string message)
        {
            _logger.LogInformation($"C# Queue trigger function processed: {message}");
        }
    }
}
