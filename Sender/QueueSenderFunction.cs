using System.Text;
using Azure.Storage.Queues;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Sender
{
    public class QueueSenderFunction
    {
        private readonly QueueClient _queueClient;

        public QueueSenderFunction()
        {
            // Initialize the QueueClient
            var connectionString = Environment.GetEnvironmentVariable("AzureWebJobsStorage");
            var queueName = Environment.GetEnvironmentVariable("QUEUE_NAME");
            _queueClient = new QueueClient(connectionString, queueName);
        }

        [Function("QueueSenderFunction")]
        public async Task<IActionResult> SendMessage(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "send")] HttpRequestData req,
            FunctionContext context)
        {
            var message = await new StreamReader(req.Body).ReadToEndAsync();
            var bytes = Encoding.UTF8.GetBytes(message);
            await _queueClient.SendMessageAsync(Convert.ToBase64String(bytes));
            return new OkObjectResult("Message sent to the queue");
        }
    }
}
