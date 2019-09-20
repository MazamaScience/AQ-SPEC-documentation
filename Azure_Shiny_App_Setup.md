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
needed for the data archive VM. Review the 
`AQ-SPEC-documentation/shiny_000-default.conf` file and make any edits related
to names, etc. Then install docker and apache with.

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

## Set up the Shiny Server

The Shiny server and application are built into docker files and can be
installed and run with targets in `AirSensorShiny/Makefile`.

### Build docker images

First we need to build the base image

```
cd ~/AirSensorShiny
sudo make test_build
```

_... This will take some time ..._

Test with `docker images`:

```
REPOSITORY                     TAG                 IMAGE ID            CREATED              SIZE
airsensor-shiny-test           0.5.1               914b353e1f51        About a minute ago   2.78GB
airsensor-shiny-test           latest              914b353e1f51        About a minute ago   2.78GB
mazamascience/airsensorshiny   1.3.6               46d13146c943        22 hours ago         2.78GB
```

### Start the Shiny server

The `Makefile` has a couple of targets for starting, stopping and bouncing
the Shiny server. Start it up initially with:

```
cd ~/AirSensorShiny
make test_up
```

----
> Software installation is now complete. 
----

# Testing

## Test Apache

You should see a default Apache welcome page at:

http://52.168.86.10/

## Test the Shiny Server

You should see a simple page with a single link to 

http://52.168.86.10/shiny-test/

*Note that the final '/' is currently required*

## Test the Shiny Application

The application itself will appear at:

http://52.168.86.10/airsensor-test/app/

## Log Files

Log files are written to the directory specified by `volumes:` in
`~/AirSensorShiny/docker-compose-test.yml`.

By default this configured to be `/var/www/html/logs` and these logs files will
be visible at:

http://52.168.86.10/logs





