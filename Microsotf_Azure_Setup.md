# Microsotf_Azure_Setup.md

## Create a VM From the Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Bsics

* Subscription: Free Trial
* Resource group: ubuntu_trial

* Virtual machine name: UbuntuTrial01
* Region: East <required to get the Free Trial>
* Availaability options: No ... redundancy required
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

## Provision the Virtual Machine

### Log in to the VM from a terminal

```
ssh <ip address>
```

The rest of the instructions are to be typed at the VM prompt.

### Install `make`

https://tutorials.ubuntu.com/tutorial/install-and-configure-apache#0

```
sudo apt update
sudo apt install make 
```

### Install Mazama Science Repositories

```
sudo git clone https://github.com/MazamaScience/AirSensor.git
sudo git clone https://github.com/MazamaScience/AirSensorShiny.git
sudo git clone https://github.com/MazamaScience/AQ-SPEC-documentation.git
```

### Set up Docker and Apache

```
cd AQ-SPEC-documentation; make all
```

At this point you have to log out and back in again for permission settings to
be updated.

```
exit
...
ssh <ip address>
```

## Set up Data Processing

### Build docker images

```
cd ~/AirSensor/docker; make production_build
```

Test with:

```
mazama_azure@UbuntuTrial02:~/AirSensor/docker$ docker images
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
mazamascience/airsensor    0.4.0               675aa990bc1f        2 minutes ago       2.81GB
mazamascience/airsensor    latest              675aa990bc1f        2 minutes ago       2.81GB
mazamascience/pwfslsmoke   1.2.100             23643a55c6d9        4 weeks ago         2.62GB
```

### Set up cron jobs

```
cd ~/AirSensor/local_executables; make install
```

Test with:

```
crontab -l
```




