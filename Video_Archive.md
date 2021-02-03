---
output:
  pdf_document: default
  html_document: default
---
# Video Archive

**_Updated 2021-02-02_**


## Data Archive Structure

The data archives hosted by SCAQMD are visible at:

https://airsensor.aqmd.gov/PurpleAir/v1/

This location corresponds to `/var/www/html/Purpleair/v1` on the host machine.

Different subdirectories house the different types of objects used
by the **AirSensor** package and the **DataViewer** user interface.

```
├── airsensor
│   ├── 2017
│   ├── 2018
│   ├── 2019
│   ├── 2020
│   ├── 2021
│   └── latest
├── logs
│   ├── ... LOTS OF FILES ...
│   └── cron_log.txt
├── pas
│   ├── 2019
│   ├── 2020
│   └── 2021
├── pat
│   ├── 2017
│   ├── 2018
│   ├── 2019
│   ├── 2020
│   ├── 2021
│   └── latest
└── videos
    ├── 2020
    └── 2021
```

The structure within the `videos/` directory will look something like this:

```
├── 2020
│   ├── 08
│   ├── 09
│   ├── 10
│   ├── 11
│   └── 12
└── 2021
    ├── 01
    └── 02
```

Within each month directory, individual videos are stored with names matching
`<community>_<YYYYMMDD>.mp4`, _e.g._ `SCAH_20210201.mp4`.

## Building Video Archives

The archive of video files initially set up only goes back a few 
months. Building up the full archive requires repeatedly updating and setting up
a crontab script that will create a single month's worth of video files. This is
because creation of video files requires lots of data downloads and needs to be
spread out over several days.

The crontab file to be edited is locatied in the **AQ-SPEC-sensor-data-ingest-v1**
source code 
([repository](https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1))
and should already exist on the MS Azure Data Processing machine:

`crontabs_etc/crontab_video_monthlyArchive_DO.txt`.

### Video creation crontab

Inside `crontab_video_monthlyArchive_DO.txt` you will see individual crontab lines. _Note that cron does not 
recognize line continuation characters._ 

Below, we break up the line for easier explanation:

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

## Repeated steps

**_The following steps must be repated once per archive month._**

### Review existing archives

To see which months have already been populated just look in the archive:

```
ls -1 /var/www/html/PurpleAir/v1/videos/2*
```

According to Vasieios Papapostolou, the archives should cover every month going
back to October 2017.

### Updating `cron`

To modify this crontab to generate a new month's worth of videos you must do two 
things for each line in the video archive creation section of the crontab:

1. update `--datestamp=202009` to reflect the desired year and month
2. update the `00 12 13 09 *` to reflect an upcoming day and month

Edit `cron` as an admin user with `crontab -e`.

_NOTE 1:  Edit the loaded crontab directly if the video creation lines already exist.
Otherwise, paste in the edited crontab instructions._

_NOTE 2: The crontab on the Data Processing machine is quite large so be sure you 
are editing only the video creation section._

### _REPEAT!_

The step above needs to be repeated once every few days until the archives have
been completely populated.

