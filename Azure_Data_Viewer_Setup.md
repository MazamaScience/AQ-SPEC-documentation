# Microsotf Azure Data Viewer Setup

**_Updated 2021-04-21_**

## Set up the VM

Example setup instructions are found in [Azure_VM_Setup_DB.md](Azure_VM_Setup_DP.md).

The MS Azure VM should be set up with the following features:

* Ubuntu Server 18.04 LTS with >= 20GB of disk
* Utilities: `make`, `vim` and `git`
* Apache with `/var/www/html/` as the server root
* docker
* docker-compose

### Install Mazama Science Repositories

```
sudo git clone https://github.com/MazamaScience/AQ-SPEC-documentation.git
sudo git clone https://github.com/MazamaScience/AirSensorDataViewer.git
```

### Set up Docker and Apache

The apache configuration for the Shiny application has a few extra steps not
needed for the Data Processing VM. Review the 
`AQ-SPEC-documentation/shiny_000-default.conf` file and make any edits related
to names, etc. Then install docker and apache with.

```
cd AQ-SPEC-documentation
make install_docker-compose
make install_apache_shiny
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
cd ~/AirSensorDataViewer
sudo make test_build
```

_... This will take some time ..._

Test with `docker images`:

```
REPOSITORY                                TAG       IMAGE ID       CREATED          SIZE
airsensor-dataviewer-test                 1.0.7     3323ed92a6bb   14 minutes ago   3.26GB
airsensor-dataviewer-test                 latest    3323ed92a6bb   14 minutes ago   3.26GB
mazamascience/airsensor-dataviewer-base   1.0.5     6290f3ce53a7   4 months ago     3.15GB
```

### Start the Shiny server

The `Makefile` has a couple of targets for starting, stopping and bouncing
the Shiny server. Start it up initially with:

```
cd ~/AirSensorDataViewer
make test_up
```

### Open up permissions in the log directory 

```
sudo chmod 777  /var/www/html/logs/airsensor-dataviewer/test/app
```

----
> Software installation is now complete. 
----

# Testing

## Test Apache

http://<ip_address>/

You should see a default Apache welcome page.

## Test the Data Viewer

http://<ip_address>:6709/asdv/test/

After a few moments, you should see the DataViewer user interface version 1.0.7. 

*Note that the final '/' is currently required*

## Log Files

Log files are written to the directory specified by `volumes:` in
`~/docker/docker-compose-test.yml `.

By default this configured to be `/var/www/html/logs` and these logs files will
be visible at:

http://52.168.86.10/logs/airsensor-dataviewer/test/app/


# Apache configuration

It is desirable to redirect the default Apache welcome page to the Data Viewer.
This is accomplished with standard Apache configuration.

## Ubuntu

Edit `/etc/apache2/sites-available/000-default.conf` to include the following:

```
  ...
  # Redirect from root to Data Viewer app ------------------------------------
  Redirect 301 / http://<ip_address>:6709/asdv/test/

  # Shiny related settings below here ----------------------------------------
  #
  ...
```

Then just restart Apache with:

```
sudo service apache2 restart
```

Alternatively, you could create an alternative html page and copy it to:

```
/var/www/html/index.html
```
