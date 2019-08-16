# Microsotf_Azure_Setup.md

## Install From Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Bsics

* Subscription: Free Trial
* Resource group: ubuntu_trial

* Virtual machine name: UbuntuTrial01
* Region: East <required to get the Free Trial>
* Availaability options: No ... redundance required
* Image: Ubuntu Server 18.04 LTS
* Size: Standard D2s v3

* Authentication type: Password
* Username: mazama_azure
* Password: MazamaScienceAzure2019!

* Public inbound ports: Allow selected ports
* Selected inbound ports: HTTP, HTTPS, SSH

### Disks

* OS disk type: Premium 
* Data disks: Create a new disk

* Name: UbuntuTrial01_DataDisk_0
* Source type: None
* Size: 1023 GiB (Premium SSD)

* LUN: 0; NAME; SIZE; DIST TYPE HOST CACHING: None

### Networking

* Virtual network: (new) ubuntu_trial-vnet
* Subnet: (new) default (10.0.0.0/24)
* Public IP: (new) UbunutuTrial01-ip
* NIC network security group: Basic
* Public inbound ports: Allow selected ports
* Select inboundn ports: HTTP, HTTPS, SSH

* Accelerated networking: Off
* Load balancing: No

### Management

* Enable basic plan for free

* Boot diagnostics: On
* OS guest diagnostics: Off
* Diagnosstics storage account: ubuntutrialdiag
* Identify: Off
* Azure Active Directory: Off
* Auto-shutdown: Off
* Backup: Off

### Tags

* Name: client; Value: SCAQMD

### Review and create

Validation passed -- 0.0960 USD/hr

... initializing ... submitting .... deployment ...

Various things appear:

* UbuntuTrial01 -- virtualMachines
* ubuntutrial01295 -- networkInterfaces
* UbuntuTrial01_DataDist_0 -- disks
* ubuntutrialdiag -- storageAccounts
* UbuntuTrial01-ip -- publicIpAddresses
* UbuntuTrial01-nsg -- networkSecurityGroups
* ubuntu_trial-vnet -- virtualNetworks

"Go to resource"

Using "Public IP address" and the "MazamaScienceBellevue2019!" password

```
ssh mazama_admin@13.92.141.166
```

VM already had vim, git, top, uptime, free, etc. but not docker.

From Dashboard for UbuntuTrial01 click on "Export Template" and then "Download".
The `template.json`, `parameters.json` and `deploy.sh` files should allow 
setup from the command line.

## Install from Azure Command Line Interface


### Install the Azure CLI

https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

Try to install on MacOS using Linux instructions.

_(Looks like this is going to get messy as we exclusively use MacPorts and not
Homebrew.)_

First install python 3.6.3 with `pyenv install 3.6.3`

Create directory, set default python:, get CLI installation script:

```
~/Projects/MS_Azure/SCAQMD
pyenv local 3.6.3
wget https://aka.ms/InstallAzureCli
```

Run the script:

```
bash InstallAzureCLI
```

Restart shell as recommended and now we have access to the `az` command!

Example usage:

```
az
...
az group --help
...
az group list
...
az group show --name ubuntu_trial
...
```

Always begin with `az login` which will open up a browser.

## Simplest possible setup

https://docs.microsoft.com/en-us/azure/virtual-machines/scripts/virtual-machines-linux-cli-sample-create-vm-quick-create

```
az vm create --resource-group ubuntu_trial --name UbuntuTrial02 --image UbuntuLTS
```

Yay!!

And now to delete everything:

```
az vm stop --resource-group ubuntu_trial --name UbuntuTrial02
...
az vm deallocate -g ubuntu_trial -n UbuntuTrial02
...
```

### Creating a VM from a template

https://azure.microsoft.com/en-us/resources/templates/docker-simple-on-ubuntu/

```
# use this command when you need to create a new resource group for your deployment
az group create --name <resource-group-name> --location <resource-group-location> 

# deploy a VM from a template 
az group deployment create --resource-group <my-resource-group> --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-simple-on-ubuntu/azuredeploy.json
```

First attempt:

```
$ az group deployment create --resource-group ubuntu_trial --template-uri https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/docker-simple-on-ubuntu/azuredeploy.json
Please provide string value for 'adminUsername' (? for help): mazama_azure
Please provide string value for 'dnsNameForPublicIP' (? for help): ubuntudocker01
Please provide securestring value for 'adminPasswordOrKey' (? for help): <MazamaScienceAzure2019!>
...
Deployment failed. Correlation ID: 7a746ee8-6eaf-493f-a94b-ad70813c5d56. {
  "error": {
    "code": "InvalidParameter",
    "message": "The value of parameter linuxConfiguration.ssh.publicKeys.keyData is invalid.",
    "target": "linuxConfiguration.ssh.publicKeys.keyData"
  }
}
```

