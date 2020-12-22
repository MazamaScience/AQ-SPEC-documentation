---
output:
  pdf_document: default
  html_document: default
---
# Microsotf Azure Data Processing Setup

**_Updated 2020-11-11_**

## Set up the VM

Example setup instructions are found in [Azure_VM_Setup_DB.md](Azure_VM_Setup_DP.md).

The MS Azure VM should be set up with the following features:

* Ubuntu Server 18.04 LTS with >= 20GB of disk
* External disk or backup so that data archives survive a reboot
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

## Install Archival Data

Previously generated files are available on the Mazama Science server. These
can be installed with the following commands:

```
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile create_archive_dirs
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install_airsensor_archive
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install_pas_archive
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install_pat_archive
make -f AQ-SPEC-sensor-data-ingest-v1/Makefile install_video_archive
```

## Build video archive

The archive of video files copied in the previous step only goes back a few 
months. Building up the full archive requires repeatedly updating and setting up
a crontab script that will create one month's worth of video files. This is
because creation of video files requires lots of data downloads and needs to be
spread out over several days.

To see which months have already been created just look in the archive:

```
ls -1 /var/www/html/PurpleAir/v1/videos/2*
```

The crontab file to be edited is `crontabs_etc/crontab_video_monthlyArchive_DO.txt`.

Inside this file you will see individual crontab lines. _Note that cron does not 
recognize line continuation characters._ Below, we break up the line for
easier explanation:

```
00 12 13 09 *    
docker run --rm 
-v /root/AQ-SPEC-sensor-data-ingest-v1:/app -v /var/www/html/PurpleAir/v1:/data -v /var/www/html/PurpleAir/v1/logs:/logs 
-w /app mazamascience/airsensor 
/app/createVideo_monthly_exec.R --archiveBaseDir=/data --logDir=/logs --communityID=SCAP --datestamp=202009 
>> /var/www/html/PurpleAir/v1/logs/cron_log.txt 2>&1 
```

Individual parts are:

* min hr day mon day-of-week specifiers for when the command should be run
* `docker run` command with `--rm` to remove the container when finished
* volumes to be mounted into the docker container
* working directory
* command and command line flags
* route stdout and stderr to a log file

To modify this file to generate a new month's worth of videos you must do two 
things:

1. update `--datestamp=202009` to reflect the desired year and month
2. update the `00 12 13 09 *` to reflect an upcoming day and month

Then just edit the crontab file by pasting the contents of this file to replace
any previous version. _Just be sure to leave the "daily" crontab entries in place._


