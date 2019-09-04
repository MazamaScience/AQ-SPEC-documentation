# Microsotf Azure Setup for Data Processing

## Create a VM From the Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Basics

* Subscription: Free Trial
* Resource group: ubuntu_trial (Create new if needed)

* Virtual machine name: UbuntuTrial01
* Region: East <required to get the Free Trial>
* Availaability options: No infrastructure redundancy required
* Image: Ubuntu Server 18.04 LTS
* Size: Standard D2s v3 (2 vcpus, 8GiB memory)

RSA Alternative:

* Username: jonathan
* SSH public key: (contents of .ssh/id_rsa.pub) 

Password Alternative:

* Authentication type: Password
* Username: mazama_admin
* Password: MazamaScienceAzure2019!

* Public inbound ports: Allow selected ports
* Selected inbound ports: HTTP, SSH

### Disks

* OS disk type: Premium SSD
* Advanced: Use managed disks -- Yes; Use ephemeral OS disk -- No
* Data disks: Create and attach a new disk

* Name: UbuntuTrial01_DataDisk_0
* Source type: None
* Size: 1023 GiB (Premium SSD)

Click "OK" button

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

### Advanced

Nothing

### Tags

Nothing

### Review and create

Click "Create"

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

Click "Go to resource"

----

> Setup is now finished. From here on, provisioning takes place in the instance.

----

## Provision the Virtual Machine

### Log in to the VM from a terminal

```
ssh <ip address>
```

Our VM already has `vim`, `git`, `top`, `uptime`, `free`, etc. but not `docker`.

The rest of the instructions are to be typed at the VM prompt.

### Mount external disk

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal

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
mazamascience/airsensor    0.4.3               675aa990bc1f        2 minutes ago       2.81GB
mazamascience/airsensor    latest              675aa990bc1f        2 minutes ago       2.81GB
mazamascience/pwfslsmoke   1.2.100             23643a55c6d9        4 weeks ago         2.62GB
```

### Install data archives

The current data archive exists on the Mazama Science server and can be
installed at `/var/www/html/data/PurpleAir` with:

```
cd ~/AQ-SPEC-documentation; make install_data_archive
```

This will take a fairly long time.ff

### Set up cron jobs

**TODO**

```
cd ~/AirSensor/local_executables; make install
```

Test with:

```
crontab -l
```




