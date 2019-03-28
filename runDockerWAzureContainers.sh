##################################################
# Run Azure Container Instances
###################################################
# You create a container by providing a name, a Docker image, and an Azure resource group to the az container create command. 
#You can optionally expose the container to the Internet by specifying a DNS name label. In this example, you deploy a container that hosts a small web app. 
# You can also select the location to place the image - you'll use the East US region, but you can change it to a location close to you from the following list.
# The free sandbox allows you to create resources in a subset of Azure's global regions. Select a region from the following list when creating any resources:
# westus2
# southcentralus
# centralus
# eastus
# westeurope
# southeastasia
# centralindia

az group create --name 82418006-4356-40a3-b3d5-1e66d47a9aad --location southeastasia

# You provide a DNS name to expose your container to the Internet. Your DNS name must be unique. For learning purposes, run this command from Cloud Shell to create a Bash variable that holds a unique name.
DNS_NAME_LABEL=aci-demo-$RANDOM

# Run the following az container create command to start a container instance.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name mycontainer \
  --image microsoft/aci-helloworld \
  --ports 80 \
  --dns-name-label $DNS_NAME_LABEL \
  --location southeastasia

# $DNS_NAME_LABEL specifies your DNS name. The image name, microsoft/aci-helloworld, refers to a Docker image hosted on Docker Hub that runs a basic Node.js web application.

# When the az container create command completes, run az container show to check its status.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name mycontainer \
  --query "{FQDN:ipAddress.fqdn,ProvisioningState:provisioningState}" \
  --out table

# You see your container's fully qualified domain name (FQDN) and its provisioning state. Here's an example.
# FQDN                                    ProvisioningState
# --------------------------------------  -------------------
# aci-demo.eastus.azurecontainer.io       Succeeded

# If your container is in the Creating state, wait a few moments and run the command again until you see the Succeeded state.
# From a browser, navigate to your container's FQDN to see it running. You see this.

###################################################
# Control restart behavior
###################################################
# The ease and speed of deploying containers in Azure Container Instances makes it a great fit 
# for executing run-once tasks like image rendering or building and testing applications.
# With a configurable restart policy, you can specify that your containers are stopped when their processes have completed. 
# Because container instances are billed by the second, you're charged only for the compute resources used while the container executing your task is running.

# What are container restart policies?
# Azure Container Instances has three restart-policy options:

# Restart policy  -   Description
# Always  -   Containers in the container group are always restarted. This policy makes sense for long-running tasks such as a web server. 
#This is the default setting applied when no restart policy is specified at container creation.

# Never   -   Containers in the container group are never restarted. The containers run one time only.

# OnFailure   -   Containers in the container group are restarted only when the process executed in the container fails 
#(when it terminates with a nonzero exit code). The containers are run at least once. This policy works well for containers that run short-lived tasks.

# Run a container to completion
# To see the restart policy in action, create a container instance from the microsoft/aci-wordcount Docker image and specify the OnFailure restart policy. 
# This container runs a Python script that analyzes the text of Shakespeare's Hamlet, writes the 10 most common words to standard output, and then exits.

# Run this az container create command to start the container.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name mycontainer-restart-demo \
  --image microsoft/aci-wordcount:latest \
  --restart-policy OnFailure \
  --location southeastasia

# Azure Container Instances starts the container and then stops it when its process (a script, in this case) exits. 
# When Azure Container Instances stops a container whose restart policy is Never or OnFailure, the container's status is set to Terminated.

#Run az container show to check your container's status.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name mycontainer-restart-demo \
  --query containers[0].instanceView.currentState.state

# Repeat the command until it reaches the Terminated status.

# View the container's logs to examine the output. To do so, run az container logs like this.
az container logs \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name mycontainer-restart-demo

###################################################
# Set environment variables
###################################################
# Environment variables enable you to dynamically configure the application or script the container runs. 
# You can use the Azure CLI, PowerShell, or the Azure portal to set variables when you create the container. 
# Secured environment variables enable you to prevent sensitive information from displaying in the container's output.

# Here, you'll create an Azure Cosmos DB instance and use environment variables to pass the connection information to an Azure container instance. 
# An application in the container uses the variables to write and read data from Cosmos DB. 
# You will create both an environment variable and a secured environment variable so you can see the difference between them.

# Deploy Azure Cosmos DB
# When you deploy Azure Cosmos DB, you provide a unique database name. 
# For learning purposes, run this command from Cloud Shell to create a Bash variable that holds a unique name.
COSMOS_DB_NAME=aci-cosmos-db-$RANDOM

# Run this az cosmosdb create command to create your Azure Cosmos DB instance.
COSMOS_DB_ENDPOINT=$(az cosmosdb create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name $COSMOS_DB_NAME \
  --query documentEndpoint \
  --output tsv)

# This command can take a few minutes to complete.
# $COSMOS_DB_NAME specifies your unique database name. The command prints the endpoint address for your database. 
# Here, the command saves this address to the Bash variable COSMOS_DB_ENDPOINT.

# Run az cosmosdb list-keys to get the Azure Cosmos DB connection key and store it in a Bash variable named COSMOS_DB_MASTERKEY.
COSMOS_DB_MASTERKEY=$(az cosmosdb list-keys \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name $COSMOS_DB_NAME \
  --query primaryMasterKey \
  --output tsv)

# Deploy a container that works with your database
# Here you'll create an Azure container instance that can read from and write records to your Azure Cosmos DB instance.

# The two environment variables you created in the last part, COSMOS_DB_ENDPOINT and COSMOS_DB_MASTERKEY, 
# hold the values you need to connect to the Azure Cosmos DB instance.

# Run the following az container create command to create the container.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo \
  --image microsoft/azure-vote-front:cosmosdb \
  --ip-address Public \
  --location eastus \
  --environment-variables \
    COSMOS_DB_ENDPOINT=$COSMOS_DB_ENDPOINT \
    COSMOS_DB_MASTERKEY=$COSMOS_DB_MASTERKEY

# microsoft/azure-vote-front:cosmosdb refers to a Docker image that runs a fictitious voting app.

# Note the --environment-variables argument. This argument specifies environment variables that are passed to the container when the container starts. 
# The container image is configured to look for these environment variables. Here, you pass the name of the Azure Cosmos DB endpoint and its connection key.

# Run az container show to get your container's public IP address.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo \
  --query ipAddress.ip \
  --output tsv

# From a browser, navigate to your container's IP address.
# Try casting a vote for cats or dogs. Each vote is stored in your Azure Cosmos DB instance.

# Use secured environment variables to hide connection information
# In the previous part, you used two environment variables to create your container. 
# By default, these environment variables are accessible through the Azure portal and command-line tools in plain text.

# In this part, you'll learn how to prevent sensitive information, such as connection keys, from being displayed in plain text.

# Let's start by seeing the current behavior in action. Run the following az container show command to display your container's environment variables.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo \
  --query containers[0].environmentVariables

# You see that both values appear in plain text. Here's an example.
# [
#   {
#     "name": "COSMOS_DB_ENDPOINT",
#     "secureValue": null,
#     "value": "https://aci-cosmos.documents.azure.com:443/"
#   },
#   {
#     "name": "COSMOS_DB_MASTERKEY",
#     "secureValue": null,
#     "value": "Xm5BwdLlCllBvrR26V00000000S2uOusuglhzwkE7dOPMBQ3oA30n3rKd8PKA13700000000095ynys863Ghgw=="
#   }
# ]

# Although these values don't appear to your users through the voting application, 
# it's a good security practice to ensure that sensitive information, such as connection keys, are not stored in plain text.

# Secure environment variables prevent clear text output. To use secure environment variables, 
# you use the --secure-environment-variables argument instead of the --environment-variables argument.

# Run the following command to create a second container, named aci-demo-secure, that makes use of secured environment variables.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo-secure \
  --image microsoft/azure-vote-front:cosmosdb \
  --ip-address Public \
  --location eastus \
  --secure-environment-variables \
    COSMOS_DB_ENDPOINT=$COSMOS_DB_ENDPOINT \
    COSMOS_DB_MASTERKEY=$COSMOS_DB_MASTERKEY

# Note the use of the --secure-environment-variables argument.

# Run the following az container show command to display your container's environment variables.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo-secure \
  --query containers[0].environmentVariables

# This time, you see that your environment variables do not appear in plain text.
# [
#   {
#     "name": "COSMOS_DB_ENDPOINT",
#     "secureValue": null,
#     "value": null
#   },
#   {
#     "name": "COSMOS_DB_MASTERKEY",
#     "secureValue": null,
#     "value": null
#   }
# ]

# In fact, the values of your environment variables do not appear at all. 
# That's OK because these values refer to sensitive information. Here, all you need to know is that the environment variables exist.

###################################################
# Use data volumes
###################################################
# By default, Azure Container Instances are stateless. If the container crashes or stops, all of its state is lost. 
# To persist state beyond the lifetime of the container, you must mount a volume from an external store.

# Here, you'll mount an Azure file share to an Azure container instance to you can store data and access it later.

# Create an Azure file share
# Here you'll create a storage account and a file share that you'll later make accessible to an Azure container instance.

# Your storage account requires a unique name. For learning purposes, run the following command to store a unique name in a Bash variable.
STORAGE_ACCOUNT_NAME=mystorageaccount$RANDOM

# Run the following az storage account create command to create your storage account.
az storage account create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name $STORAGE_ACCOUNT_NAME \
  --sku Standard_LRS \
  --location southeastasia

# Run the following command to place the storage account connection string into an environment variable named AZURE_STORAGE_CONNECTION_STRING.
export AZURE_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name $STORAGE_ACCOUNT_NAME \
  --output tsv)

# AZURE_STORAGE_CONNECTION_STRING is a special environment variable that's understood by the Azure CLI. 
# The export part makes this variable accessible to other CLI commands you'll run shortly.

# Run this command to create a file share, named aci-share-demo, in the storage account.
az storage share create --name aci-share-demo

# Get storage credentials
# To mount an Azure file share as a volume in Azure Container Instances, you need these three values:

# The storage account name
# The share name
# The storage account access key
# You already have the first two values. The storage account name is stored in the STORAGE_ACCOUNT_NAME Bash variable. 
# You specified aci-share-demo as the share name in the previous step. Here you'll get the remaining value — the storage account access key.

# Run the following command to get the storage account key.
STORAGE_KEY=$(az storage account keys list \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --account-name $STORAGE_ACCOUNT_NAME \
  --query "[0].value" \
  --output tsv)
# The result is stored in a Bash variable named STORAGE_KEY.

# As an optional step, print the storage key to the console.
echo $STORAGE_KEY

# Deploy a container and mount the file share
# To mount an Azure file share as a volume in a container, you specify the share and volume mount point when you create the container.

# Run this az container create command to create a container that mounts /aci/logs/ to your file share.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo-files \
  --image microsoft/aci-hellofiles \
  --location eastus \
  --ports 80 \
  --ip-address Public \
  --azure-file-volume-account-name $STORAGE_ACCOUNT_NAME \
  --azure-file-volume-account-key $STORAGE_KEY \
  --azure-file-volume-share-name aci-share-demo \
  --azure-file-volume-mount-path /aci/logs/

# Run az container show to get your container's public IP address.
az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name aci-demo-files \
  --query ipAddress.ip \
  --output tsv

# From a browser, navigate to your container's IP address.
# Enter some text into the form and click Submit. This action creates a file that contains the text you entered in the Azure file share.

# Run this az storage file list command to display the files that are contained in your file share.
az storage file list -s aci-share-demo -o table

# Run az storage file download to download a file to your Cloud Shell session. Replace <filename> with one of the files that appeared in the previous step.
az storage file download -s aci-share-demo -p <filename>

# Run the cat command to print the contents of the file.
cat <filename>

###################################################
# Troubleshoot Azure Container Instances
###################################################
# To help you understand basic ways to troubleshoot container instances, here you'll perform some basic operations such as:
# Pulling container logs
# Viewing container events
# Attaching to a container instance

# Create a container
# Run the following az container create command to create a basic container.
az container create \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name urcontainer \
  --image microsoft/sample-aks-helloworld \
  --ports 80 \
  --ip-address Public \
  --location southeastasia
# The microsoft/sample-aks-helloworld image runs a web server that displays a basic web page.

# Get logs from your container instance
# Run the following az container logs command to see the output from the container's running application.
az container logs \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name urcontainer
# You see output that resembles the following.

# Checking for script in /app/prestart.sh
# Running script /app/prestart.sh
# Running inside /app/prestart.sh, you could add migrations to this file, e.g.:
# #! /usr/bin/env bash
# # Let the DB start
# sleep 10;
# # Run migrations
# alembic upgrade head

# Get container events
# The az container attach command provides diagnostic information during container startup. 
# Once the container has started, it also writes standard output and standard error streams to your local terminal.

# Run az container attach to attach to your container.
az container attach \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name urcontainer

# You see output that resembles the following.
# Container 'mycontainer' is in state 'Running'...
# (count: 1) (last timestamp: 2018-09-21 23:48:14+00:00) pulling image "microsoft/sample-aks-helloworld"
# (count: 1) (last timestamp: 2018-09-21 23:49:09+00:00) Successfully pulled image "microsoft/sample-aks-helloworld"
# (count: 1) (last timestamp: 2018-09-21 23:49:12+00:00) Created container
# (count: 1) (last timestamp: 2018-09-21 23:49:13+00:00) Started container

# Start streaming logs:
# Checking for script in /app/prestart.sh
# Running script /app/prestart.sh

#Enter Ctrl+C to disconnect from your attached container.

# Execute a command in your container
# As you diagnose and troubleshoot issues, you may need to run commands directly on your running container.

# To see this in action, run the following az container exec command to start an interactive session on your container.
az container exec \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name urcontainer \
  --exec-command /bin/sh
# At this point, you are effectively working inside of the container.

#Run the ls command to display the contents of the working directory.
#You can explore the system further if you wish. When you're done, run the exit command to stop the interactive session.

# Monitor CPU and memory usage on your container
# Here you'll see how to monitor CPU and memory usage on your container.

# Run the following az container show command to get the ID of your Azure container instance and store the ID in a Bash variable.
CONTAINER_ID=$(az container show \
  --resource-group 82418006-4356-40a3-b3d5-1e66d47a9aad \
  --name urcontainer \
  --query id \
  --output tsv)

# Run the az monitor metrics list command to retrieve CPU usage information.
az monitor metrics list \
  --resource $CONTAINER_ID \
  --metric CPUUsage \
  --output table

# Note the --metric argument. Here, CPUUsage specifies to retrieve CPU usage.
# You see output similar to this.
# Timestamp            Name              Average
# -------------------  ------------  -----------
# 2018-08-20 21:39:00  CPU Usage
# 2018-08-20 21:40:00  CPU Usage
# 2018-08-20 21:41:00  CPU Usage
# 2018-08-20 21:42:00  CPU Usage
# 2018-08-20 21:43:00  CPU Usage      0.375
# 2018-08-20 21:44:00  CPU Usage      0.875
# 2018-08-20 21:45:00  CPU Usage      1
# 2018-08-20 21:46:00  CPU Usage      3.625
# 2018-08-20 21:47:00  CPU Usage      1.5
# 2018-08-20 21:48:00  CPU Usage      2.75
# 2018-08-20 21:49:00  CPU Usage      1.625
# 2018-08-20 21:50:00  CPU Usage      0.625
# 2018-08-20 21:51:00  CPU Usage      0.5
# 2018-08-20 21:52:00  CPU Usage      0.5
# 2018-08-20 21:53:00  CPU Usage      0.5

# Run this az monitor metrics list command to retrieve memory usage information.
az monitor metrics list \
  --resource $CONTAINER_ID \
  --metric MemoryUsage \
  --output table

# Here, you specify MemoryUsage for the --metric argument to retrieve memory usage information.

# You see output similar to this.
# Timestamp            Name              Average
# -------------------  ------------  -----------
# 2018-08-20 21:43:00  Memory Usage
# 2018-08-20 21:44:00  Memory Usage  0.0
# 2018-08-20 21:45:00  Memory Usage  15917056.0
# 2018-08-20 21:46:00  Memory Usage  16744448.0
# 2018-08-20 21:47:00  Memory Usage  16842752.0
# 2018-08-20 21:48:00  Memory Usage  17190912.0
# 2018-08-20 21:49:00  Memory Usage  17506304.0
# 2018-08-20 21:50:00  Memory Usage  17702912.0
# 2018-08-20 21:51:00  Memory Usage  17965056.0
# 2018-08-20 21:52:00  Memory Usage  18509824.0
# 2018-08-20 21:53:00  Memory Usage  18649088.0
# 2018-08-20 21:54:00  Memory Usage  18845696.0
# 2018-08-20 21:55:00  Memory Usage  19181568.0

# CPU and memory information is also available through the Azure portal. 
# To see a visual representation of CPU and memory usage information, navigate to the Azure portal overview page for your container instance.

#Clean up
DELETE https://management.azure.com/subscriptions/39c41306-127b-40a3-a2b8-1e748515d9d5/resourceGroups/82418006-4356-40a3-b3d5-1e66d47a9aad/providers/Microsoft.DocumentDB/databaseAccounts/aci-cosmos-db-18147?api-version=2015-04-08
az group delete --name 82418006-4356-40a3-b3d5-1e66d47a9aad