---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Setup for Data Processing

**_Updated 2019-12-14_**

## Create a VM From the Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Basics

* Subscription: Free Trial
* Resource group: ubuntu_trial (Create new if needed)

* Virtual machine name: UbuntuTrial01
* Region: East <required to get the Free Trial>
* Availability options: No infrastructure redundancy required
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
> Setup of the VM is now finished. 
> From here on, provisioning takes place inside the instance.
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
sudo git clone https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1.git
```

### Set up Docker and Apache

```
cd AQ-SPEC-documentation
make archive_setup
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
cd ~/AQ-SPEC-documentation
sudo make create_archive_dirs
```

### Install data archives

The current data archive exists on the Mazama Science server and can be
installed at `/var/www/html/data/PurpleAir` with the following targets.

They are broken up as individual targets.

```
cd ~/AQ-SPEC-documentation
make install_airsensor_archive
make install_pas_archive
make install_pat_archive
make install_video_archive
```

_... This will take some time ..._

### Build docker images

```
cd ~/AQ-SPEC-sensor-data-ingest-v1/docker
sudo make production_build
```

_... This will take some time ..._

Test with `docker images`:

```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
mazamascience/airsensor    0.5.16              675aa990bc1f        2 minutes ago       2.81GB
mazamascience/airsensor    latest              675aa990bc1f        2 minutes ago       2.81GB
```

### Configure Archive URL and crontab

Data processing scripts and configuration take place in this directory:

```
cd ~/AQ-SPEC-sensor-data-ingest-v1
```

Data proceessing scripts place data in directories are relative to an overall
`ARCHIVE_BASE_DIR`. All installation up to this point assumes this directory
will be `/var/www/html/data/PurpleAir/` and this directory is configured in
the `Makefile`.


The `EXEC_DIR` variable in this `Makefile` must also be configured with the
absolute path to `~/AQ-SPEC-sensor-data-ingest-v1`.

Once these adjustments to the `Makefile` have been made, configure the 
executable scripts and crontab files with:

```
sudo make configure
```

### Testing the scripts

The `~/AQ-SPEC-sensor-data-ingest-v1/test/` directory allows us to test the
installation up to this point. It has several targets that will run the 
configured scripts, produciing both output and logs.

Here is an example session:

```
$ sudo make createPAS
mkdir -p /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/output
mkdir -p /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/logs
touch /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/logs/cron_log.txt
docker run --rm -v /home/jonathan/AQ-SPEC-sensor-data-ingest-v1:/app -v /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/output:/app/output -v /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/logs:/app/logs -w /app mazamascience/airsensor:latest /app/createPAS_exec.R --outputDir=/app/output --logDir=/app/logs >> /home/jonathan/AQ-SPEC-sensor-data-ingest-v1/logs/cron_log.txt 2>&1 
$ ls ../logs
createPAS_DEBUG.log  createPAS_ERROR.log  createPAS_INFO.log  createPAS_TRACE.log  cron_log.txt
$ cat ../logs/createPAS_INFO.log 
INFO [2019-09-13 20:38:10] Running createPAS_exec.R version 0.1.6
INFO [2019-09-13 20:38:11] Obtaining 'pas' data for 20190913
INFO [2019-09-13 20:39:21] Writing 'pas' data to pas_20190913.rda
INFO [2019-09-13 20:39:21] Completed successfully!
```

A full test suite can be run with:

```
sudo make full_test_suite
```

### Set up crontab file

To run the scripts on a regular schedule we must uses the `crontab_daily.txt`
file we configured ealier. There should be no other crontab entries but we
should check first with:

```
cd ~/AQ-SPEC-sensor-data-ingest-v1
sudo crontab -l
```

Assuming this is empty, we can install the daily crontab with:

```
cd ~/AQ-SPEC-sensor-data-ingest-v1
sudo crontab crontab_daily.txt
```

Test that it is properly installed with:

```
sudo crontab -l
```

----
> Software installation is now complete. 
----

# Review the Logs

The crontab is set to run multiple scripts per hour, each of which generates
a log file. The log files are all visible at the URL base, something like:

http://40.117.96.252/data/PurpleAir/


