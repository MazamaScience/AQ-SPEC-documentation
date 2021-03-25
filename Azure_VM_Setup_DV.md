# Microsotf Azure Virtual Machine Setup for Data Viewer

**_Updated 2021-03-25_**

_Note:  These are example instructions and various specifics will need to be modified._

## Create a VM From the Web Interface

Go to https://portal.azure.com and log in

Click on "Virtual machines"

Click on "Add" or "Create a Virtual Machine"

### Basics

* Subscription: Free Trial
* Resource group: ubuntu_trial (Create new if needed)

* Virtual machine name: DataViewer01
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

No Data disk

Click "OK" button

* LUN: 0; NAME; SIZE; DIST TYPE HOST CACHING: None

### Networking

* Virtual network: (new) ubuntu_trial-vnet
* Subnet: (new) default (10.0.0.0/24)
* Public IP: (new) DataViewer01-ip
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

* DataViewer01 -- virtualMachines
* dataviewer0971 -- networkInterfaces
* DataViewer01-nsg -- networkSecurityGroups
* DataViewer01-ip -- publicIpAddresses

When everything is finished: Click "Go to resource"

----
> Setup of the VM is now finished. 
> From here on, provisioning takes place inside the instance.
----

## Log in to the VM from a terminal

```
ssh <ip address>
```
