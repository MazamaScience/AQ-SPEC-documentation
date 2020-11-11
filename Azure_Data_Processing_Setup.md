---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Setup for Data Processing

**_Updated 2020-11-11_**

## Set up the VM

The MS Azure VM should be set up with the following features:

* Ubuntu Server 18.04 LTS
* Utilities: `make`, `vim` and `git`
* Apache with /var/www/html/ as the root directory
* Docker

## Set up Data Processing

```
git clone https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1.git
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install
```

----
> Software installation is now complete. 
----

# Review the Logs

The crontab is set to run multiple scripts per hour, each of which generates
a log file. The generated data and associated log files are all visible at the 
URL base, something like:

http://<ip-address>/PurpleAir/v1/


