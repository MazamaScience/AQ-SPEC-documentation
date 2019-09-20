---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Setup for Shiny App

**_Updated 2019-09-20_**

## Create a VM From the Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Basics

* Subscription: Free Trial
* Resource group: ubuntu_trial (Create new if needed)

* Virtual machine name: AirSensorDataViewer01
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

No Data disk

Click "OK" button

* LUN: 0; NAME; SIZE; DIST TYPE HOST CACHING: None

### Networking

* Virtual network: (new) ubuntu_trial-vnet
* Subnet: (new) default (10.0.0.0/24)
* Public IP: (new) AirSensorDataViewer01-ip
* NIC network security group: Basic
* Public inbound ports: Allow selected ports
* Select inboundn ports: HTTP, SSH

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

* AirSensorDataViewer01 -- virtualMachines
* airsensordataviewer0971 -- networkInterfaces
* AirSensorDataViewer01-nsg -- networkSecurityGroups
* AirSensorDataViewer01-ip -- publicIpAddresses

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
sudo git clone https://github.com/MazamaScience/AirSensorShiny.git
```

### Set up Docker and Apache

The apache configuration for the Shiny application has a few extra steps not
needed for the data archive VM.

```
cd AQ-SPEC-documentation
make shiny_setup
```

At this point you have to log out and back in again for permission settings to
be updated.

```
exit
...
ssh <ip address>
```

### Configure Apache

Following instructions for Apache here:
https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy

```
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_wstunnel
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

### Build docker images

```
cd ~/AirSensor/docker
sudo make production_build
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

### Configure Archive URL and crontab

Data proceessing scripts must have access to an ARCHIVE_BASE_URL. This could
point to another machine but makes the most sense if it points to this VM.

First, test that Apache and the archive directories have been properly installed 
by pointing a browser at http://<_ip address_>data/PurpleAir.

If this shows subdirectories for "airsensor", "logs", etc. then save this URL

Edit the `ARCHIVE_BASE_URL` field in `~/AirSensor/local_executables/Makefile`
with the URL.

The `USER_NAME` variable in this `Makefile` will default to the current user
because we have just installed the scripts in this users directory.

To configure the executable scripts and crontab files jus type

```
cd ~/AirSensor/local_executables
sudo make configure
```

### Testing the scripts

The `~/AirSensor/local_executables/test/` directory allows us to test the
installation up to this point. It has several targets that will run the 
configured scripts, produciing both output and logs.

Here is an example session:

```
$ sudo make createPAS
mkdir -p /home/jonathan/AirSensor/local_executables/output
mkdir -p /home/jonathan/AirSensor/local_executables/logs
touch /home/jonathan/AirSensor/local_executables/logs/cron_log.txt
docker run --rm -v /home/jonathan/AirSensor/local_executables:/app -v /home/jonathan/AirSensor/local_executables/output:/app/output -v /home/jonathan/AirSensor/local_executables/logs:/app/logs -w /app mazamascience/airsensor:latest /app/createPAS_exec.R --outputDir=/app/output --logDir=/app/logs >> /home/jonathan/AirSensor/local_executables/logs/cron_log.txt 2>&1 
$ ls ../logs
createPAS_DEBUG.log  createPAS_ERROR.log  createPAS_INFO.log  createPAS_TRACE.log  cron_log.txt
$ cat ../logs/createPAS_INFO.log 
INFO [2019-09-13 20:38:10] Running createPAS_exec.R version 0.1.6
INFO [2019-09-13 20:38:11] Obtaining 'pas' data for 20190913
INFO [2019-09-13 20:39:21] Writing 'pas' data to pas_20190913.rda
INFO [2019-09-13 20:39:21] Completed successfully!
```

### Set up crontab file

To run the scripts on a regular schedule we must uses the `crontab_daily.txt`
file we configured ealier. There should be no other crontab entries but we
should check first with:

```
cd ~/AirSensor/local_executables
sudo crontab -l
```

Assuming this is empty, we can install the daily crontab with:

```
cd ~/AirSensor/local_executables
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


