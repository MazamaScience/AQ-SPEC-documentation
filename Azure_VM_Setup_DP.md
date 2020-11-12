---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Virtual Machine Setup for Data Processing

**_Updated 2020-11-12_**

_Note:  These are example instructions and various specifics will need to be modified._

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

* Username: _user_
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

## Log in to the VM from a terminal

```
ssh root@<ip address>
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
> you resize the volume, on reboot just do 'xfs_growfs /var/www/html.

Write a file system with:

### Mount the file system

```
sudo mkdir -p /var/www/html
sudo mount /dev/sdc /var/www/html
```

Find the UUID of the new drive with:

```
sudo -i blkid | grep "/dev/sdc"
```

Edit `/etc/fstab` to have this line:

```
UUID=<uuid-from-blkid-cmd> /var/www/html    xfs    defaults    0 0
```

