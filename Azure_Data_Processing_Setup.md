# Microsoft Azure Data Processing Setup

**_Updated 2023-04-07_**

## Set up the VM

Example setup instructions are found in [Azure_VM_Setup_DB.md](Azure_VM_Setup_DP.md).

The MS Azure VM should be set up with the following features:

- Ubuntu Server 18.04 LTS with >= 20GB of disk
- External disk or backup so that data archives survive a reboot
- Utilities: `make`, `vim` and `git`
- Apache with `/var/www/html/` as the server root
- Docker

Dockerized scripts will write data and logs to `/var/www/html/logs/` and
`/var/www/html/Purpleair/v1` which must be open to the web.

## Set up Data Processing

```
git clone https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1.git
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install
```

---

> Software installation is now complete.

---

## Review the Logs

The crontab is set to run multiple scripts per hour, each of which generates
a log file. The generated data and associated log files are all visible at the
URL base, something like:

http://<ip-address>/PurpleAir/v1/

## Archival Data

_NOTE: No archival data is available because no PAS or PAT files were generated
between May, 2022 and April 2023._

# Apache configuration

It is desirable to redirect the default Apache welcome page to the Data Archive.
This is accomplished with standard Apache configuration.

## Ubuntu

Edit `/etc/apache2/sites-available/000-default.conf` to include the following:

```
  ...
  # Redirect from root to Data Viewer app ------------------------------------
  Redirect 301 / http://<ip-address>/PurpleAir/v1/

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
