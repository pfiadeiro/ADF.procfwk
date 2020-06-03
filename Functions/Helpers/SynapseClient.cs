using System;
using Microsoft.IdentityModel.Clients.ActiveDirectory;
using Microsoft.Rest;
using Microsoft.Azure.Management.Synapse;

namespace ADFprocfwk.Helpers
{
    internal class SynapseClient
    {
        public static SynapseManagementClient CreateSynapseClient(string tenantId, string applicationId, string authenticationKey, string subscriptionId)
        { 
            var context = new AuthenticationContext("https://login.windows.net/" + tenantId);

            ClientCredential cc = new ClientCredential(applicationId, authenticationKey);
            AuthenticationResult result = context.AcquireTokenAsync("https://management.azure.com/", cc).Result;
            ServiceClientCredentials cred = new TokenCredentials(result.AccessToken);

            var synClient = new SynapseManagementClient(cred)
            {
                SubscriptionId = subscriptionId
            };

            return synClient;
        }
    }
}
