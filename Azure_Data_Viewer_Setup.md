# Microsotf Azure Data Viewer Setup

**_Updated 2021-03-25_**

## Set up the VM

Example setup instructions are found in [Azure_VM_Setup_DB.md](Azure_VM_Setup_DP.md).

The MS Azure VM should be set up with the following features:

* Ubuntu Server 18.04 LTS with >= 20GB of disk
* Utilities: `make`, `vim` and `git`
* Apache with `/var/www/html/` as the server root
* Docker

### Install Mazama Science Repositories

```
sudo git clone https://github.com/MazamaScience/AQ-SPEC-documentation.git
sudo git clone https://github.com/MazamaScience/AirSensorShiny.git
```

### Set up Docker and Apache

The apache configuration for the Shiny application has a few extra steps not
needed for the Data Processing VM. Review the 
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
mazamascience/airsensorshiny   1.3.7               46d13146c943        22 hours ago         2.78GB
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





