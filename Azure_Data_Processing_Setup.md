---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Setup for Data Processing

**_Updated 2020-11-11_**

## Set up the VM

The MS Azure VM should be set up with the following features:

* Ubuntu Server 18.04 LTS with >= 20GB of disk
* Utilities: `make`, `vim` and `git`
* Apache with `/var/www/html/` as the server root
* Docker

Dockerized scripts will write data and logs to `/var/www/html/logs/` and
`/var/www/html/Purpleair/v1` which must be open to the web.

## Set up Data Processing

```
git clone https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1.git
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install
```

----
> Software installation is now complete. 
----

## Review the Logs

The crontab is set to run multiple scripts per hour, each of which generates
a log file. The generated data and associated log files are all visible at the 
URL base, something like:

http://<ip-address>/PurpleAir/v1/


