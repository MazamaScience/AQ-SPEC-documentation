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
* Username: _user_
* Password: _pass_

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

... Your deployment is underway ...

Various things appear:

* UbuntuTrial01 -- virtualMachines
* ubuntutrial01295 -- networkInterfaces
* UbuntuTrial01_DataDist_0 -- disks
* ubuntutrialdiag -- storageAccounts
* UbuntuTrial01-ip -- publicIpAddresses
* UbuntuTrial01-nsg -- networkSecurityGroups
* ubuntu_trial-vnet -- virtualNetworks

When everything is finished: Click "Go to resource"

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

### Install `make`

https://tutorials.ubuntu.com/tutorial/install-and-configure-apache#0

```
sudo apt update
sudo apt install make 
```

### Install Mazama Science Repositories

```
sudo git clone https://github.com/MazamaScience/AQ-SPEC-documentation.git
sudo git clone https://github.com/MazamaScience/AirSensor.git
```

### Set up Docker and Apache

```
cd AQ-SPEC-documentation; make setup
```

At this point you have to log out and back in again for permission settings to
be updated.

```
exit
...
ssh <ip address>
```

## Mount the Data Disk

In this step we mount the "Data disk" we created and attached to the VM.

General instructions are available at: 
https://docs.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal#connect-to-the-linux-vm-to-mount-the-new-disk

Use `dmesg | grep SCSI` to find the data disk -- `sdc`.

**Skip the partitioning step**

### Write the file system

```
sudo mkfs.xfs /dev/sdc
```

From Bill Broomall:

> xfs has a number of advantages, but two are especially convenient: it's much 
> quicker to format; and it's very easy to grow (using xfs_growfs).  When you make
> the filesystem directly on the volume, you don't have to resize the partition.  
> In Azure, you have to detach the volume first (or shut down the VM), but once 
> you resize the volume, on reboot just do 'xfs_growfs /var/www/html/data'.

Write a file system with:


### Mount the file system

```
sudo mkdir -p /var/www/html/data
sudo mount /dev/sdc /var/www/html/data
```

Find the UUID of the new drive with:

```
sudo -i blkid | grep "/dev/sdc"
```

Edit `/etc/fstab` to have this line:

```
UUID=<uuid-from-blkid-cmd> /var/www/html/data    xfs    defaults    0 0
```

## Set up Data Processing

Begin by creating the archive directory structure under `/var/www/html/data`:

```
cd ~/AQ-SPEC-documentation; make create_archive_dirs
```

### Build docker images

```
cd ~/AirSensor/docker; make production_build
```

_... This will take some time ..._

Test with `docker images`:

```
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

_... This will take some time ..._

### Set up cron jobs

**TODO**

```
cd ~/AirSensor/local_executables; make install
```

Test with:

```
crontab -l
```

# Restarting the Virtual Machine

Go to https://portal.azure.com and log in.

Click on "Virtual machines"

Select the desired VM and click "Start" or "Restart" in the top bar.

## Mount external disk

https://docs.microsoft.com/en-us/azure/virtual-machines/linux/attach-disk-portal

After selecting the VM, click on "Disks" on the left.

You should see the ephemeral "OS disk" and also the "Data disk" created earlier.
If not, then create a new Data disk by repeating the "Add data disk" instructions
above.









