---
output:
  pdf_document: 
    latex_engine: xelatex
  word_document: default
  html_document: default
---
# Software Design Document 

**_Updated 2020-11-10_**

This document describes the overall design and maintenance of a web accessible
archive of data from SCAQMD-maintained PurpleAir sensors as well as the design
and deployment of an [R Shiny application](https://shiny.rstudio.com) providing 
web accessible products and user interfaces appropriate for dissemination to the 
public.

Software systems were created by Mazama Science for the 
[Sensor Performance and Evaluation Center](http://www.aqmd.gov/aq-spec) 
at the [South Coast Air Quality Managment District](http://www.aqmd.gov).

## System Overview

The overall system consists of the following modular components:
 
 * an R package providing core functionality for working with PurpleAir data
 * data ingest scripts for automatically processing raw PurpleAir data into
 higher level data archive files
 * a directory structure providing an API for accessing data archive files
 * an R Shiny application providing a public facing user interface to Purple 
 Air data and data products

The data archive consists of a set of flat files with URLs defined by a simple
directory and file naming protocol.

The data ingest scripts are written in R and are run at regular intervals by
the system cron job.

The only "always on" components are an Apache web server and the R Shiny Server 
which is proxied through Apache.

Both the archive scripts and the R Shiny Server are run inside docker containers
so that host machine provisioning is limited to: `apache`, `git` and `docker`.

As designed, data ingest, data archive and R Shiny Server _could_ all run on a
single, SCAQMD maintained, Microsoft Azure instance. However, for purposes of
load and process optimization, it is recommended that the data processing and 
data archive be set up one one Azure instance while the public interface be set 
up on a separate Azure instance.

Data processing is of critical imprtance and will occur at well defined
intervals so that it may be possible to configure an instance tailored to the
CPU and memory needs of these proceses.

The public facing user interface is by nature much more volatile in terms of its
CPU load and should be set up so as not to interfere with the core data
processing tasks.

That said, a single, medium capacity instance _might_ be able to handle both 
tasks under low user load situations.

## Data flow

Files in the data archive contain data at three distinct levels:

* _synoptic data_ containing primarily sensor metadata for every PurpleAir sensor
* _time series data_ containing raw PurpleAir sensor data
* _hourly aggregated data_ containing processed time series data
* _video files_ contianing 7-day mp4 files for each distinct _community_

Data ingest begins by downloading, parsing and enhancing data found in a geojson
file at https://www.purpleair.com/json. Data ingest is performed hourly by a 
dedicated data ingest script run by a cron job. The synoptic data files are
referred to as `pas` (PurpleAir Synoptic) files.

In the second stage of data processing, metadata from the synoptic file is used 
to download, parse and enhance raw timeseries data obtained from the 
ThingSpeak server at https://api.thingspeak.com/channels/. This data processing 
is performed hourly by a data processing script. The timeseries
data files are referred to as `pat` (PurpleAir Timeseries) files.

A more detailed discussion of raw data access APIs is available at:
https://www2.purpleair.com/community/faq.

The third stage of data processing involves ingesting timeseries data from
the SCAQMD archive and creating quality controlled, hourly aggregated data
files containing all sensor data in a single file. The files are compatible
with the **PWFSLSmoke** R package and allow for comparison
with federal monitoring data. This data processing is again performed by a
dedicated processing script run hourly by a cron job. The hourly aggregated
data files are referred to as `airsensor` files.

Another R script is run once per day and uses the `airsensor` files to produce
.mp4 video files fore ach community.

## Components

### **AirSensor** R package

The R package has been developed as open source software and provides much of 
the functionality that community members and data analysts have identified as 
important in assessing and communicating air sensor data.

The R package source code is available at 
https://github.com/MazamaScience/AirSensor
and is with a companion 
[documentation website](https://mazamascience.github.io/AirSensor/). 

The **AirSensor** R package provides all of the component functionality from
which data ingest scripts and user interfaces are built.

Using the open source version of the
[RStudio](https://www.rstudio.com/products/rstudio/) IDE, the package can be
loaded and used by data analysists to work with PurpleAir data on their 
desktop and laptop machines.

### Docker containers

_For background on Docker, see:_

* https://en.wikipedia.org/wiki/Docker_(software)
* https://www.docker.com

All data processing is performed by scripts running inside of docker
containers. This level of virtualization allows containers and scripts to be
loaded onto a system that has none of the other software dependencies required
to run R.

The package source code includes a `docker/` directory with the following 
contents:

```
├── Dockerfile
├── Makefile
└── README.md
```

* Dockerfile -- recipe for building a docker image
* Makefile -- targets and dependencies to simplify building the docker image
* README.md -- background and instructions for building, deploying and testing
docker images

The docker image with the tag `mazamascience/airsensor:latest` must exist on
the host machine in order to run the data ingest scripts described below.

### Data ingest scripts

The data ingest scripts not part of the **AirSensor** R package and live at
a separate Github URL: 
https://github.com/MazamaScience/AQ-SPEC-sensor-data-ingest-v1.git

This repository contains the following files and directories:

```
├── Digital_Ocean_Primer.md
├── Makefile
├── R/
├── README.md
├── createAirSensor_annual_exec.R
├── createAirSensor_extended_exec.R
├── createAirSensor_latest_exec.R
├── createAirSensor_monthly_exec.R
├── createPAS_exec.R
├── createPAT_extended_exec.R
├── createPAT_latest_exec.R
├── createPAT_monthly_exec.R
├── createVideo_exec.R
├── createVideo_monthly_exec.R
├── crontabs_etc/
├── docker/
├── test/
└── upgradePAS_exec.R
```

Each of the `~_exec.R` scripts is run on a regular schedule defined by
crontabs in the `crontabs_etc/` directory. These crontabs must be configured 
before use to reflect directory locations on the host server.  The example 
crontab `crontab_daily_joule.txt` has paths appropriate for the Mazama Science 
computer server named `joule`.

To deploy the data ingest scripts, the contents of these files should be 
configured to reflect absolute paths on the host machine and then added to a 
privileged user's crontab so the scripts will be run on a daily basis.

The `test/` directory contains a `Makefile` that allows someone typing at the
command line to test the data ingest scripts by running them inside the docker
container and then checking the results. This should be done before setting up
the cron job to run scripts automatically.

### Data directory

The data archive is a flat-file archive system using R binary files 
containing PurpleAir data. The API to this data archive consists of carefully
named files in predictable directory locations. Besides the operating system, no 
other "database" is required.

Functions inside the **AirSensor** R package assume the following 
directory structure will be available at some web accessible  `archiveBaseUrl`.

```
├── airsensor
│   ├── 2017
│   ├── 2018
│   ├── 2019
│   ├── 2020
│   └── latest
├── pas
│   ├── 2019
│   └── 2020
├── pat
│   ├── 2017
│   ├── 2018
│   ├── 2019
│   ├── 2020
│   └── latest
└── videos
    ├── 2018
    ├── 2019
    └── 2020
```

The `pas` files are generated every hour with file names similar to:

```
pas/2019/pas_20190627.rda
pas/2019/pas_20190627_archival.rda
pas/2019/pas_20190628.rda
pas/2019/pas_20190628_archival.rda
```

Each file contains synoptic data for all US PurpleAir sensors reporting for
a given `YYYYmmdd` timestamp. These files contain metadata for all sensors that
have reported within the last 24 hours. The files with `_archival` contain
metadata for all sensors including those that have stopped reporting.

The `pat` files are generated once per day for each individual SCAQMD sensor
and contain data for an entire month. They have file names built as
`pat_<locationID>_<instrumentID>_YYYYmm.rda`:

```
pat/2020/11/pat_048b4e4419f084d5_2303_202011.rda
pat/2020/11/pat_0532adaf3cd5d7d2_2309_202011.rda
pat/2020/11/pat_055497925c615bbd_2452_202011.rda
```

The `pat/latest/` subdirectory contains files that are updated hourly and contain 
7 days or 45 days of data per sensor. The have file names like:

```
pat/latest/pat_048b4e4419f084d5_2303_latest7.rda
pat/latest/pat_048b4e4419f084d5_2303_lates45.rda
pat/latest/pat_0532adaf3cd5d7d2_2309_latest7.rda
pat/latest/pat_0532adaf3cd5d7d2_2309_latest45.rda
pat/latest/pat_055497925c615bbd_2452_latest7.rda
pat/latest/pat_055497925c615bbd_2452_latest45.rda
```

The `airsensor` files are generated once per day and contain sensor data for
an entire month. A single file combines all aggregated timeseries data and
is named by "collection", in this case "scaqmd":

```
airsensor/2020/airsensor_scaqmd_202001.rda
airsensor/2020/airsensor_scaqmd_202002.rda
airsensor/2020/airsensor_scaqmd_202003.rda
```

The `airsensor/latest/` subdirectory contains files that are updated hourly and
contain either 7 or 45 days of data:

```
airsensor/latest/airsensor_scaqmd_latest7.rda
airsensor/latest/airsensor_scaqmd_latest45.rda
```

The `createVideo_exec.R` script is run once daily to generate 7-day
videos of hourly sensor data for each community. These are found in the
`videos/` directory with names like:

```
videos/2020/11/SCAH_20201101.mp4
videos/2020/11/SCAH_20201102.mp4
videos/2020/11/SCAH_20201103.mp4
```

### R Shiny application

A full-featured, web based user interface was created allowing end users to generate 
plots of recent data for specific PurpleAir sensors. Our technology of choice
was to build an [R Shiny](https://www.rstudio.com/products/shiny/) application
and to host it using [R Shiny Server](https://www.rstudio.com/products/shiny-2/).

Both of these choices are open source products supported by RStudio and 
currently enjoying widespread adoption by many members of the R/data analysis
community.

The shiny application is not part of the **AirSensor** R package and lives at
its own Github URL: https://github.com/MazamaScience/AirSensorDataViewer

This repository contains its own `README.md`, `Makefile` and `docker/` directory
as well as all necessary source code to build and deploy the application.

The user interface and back-end server are deployed to an instance of Shiny
Server running in a dedicated docker container. This service is the only 
"always-up" component of the entire system.

The Shiny Server docker container presents ports to the host (MS Azure) 
instance. The host machine's Apache web server must then be configured with
ProxyPass and Rewrite instructions so that the Shiny Server appears at a 
unique URL rather than a unique server port. For details see:

https://support.rstudio.com/hc/en-us/articles/213733868-Running-Shiny-Server-with-a-Proxy

## Interfaces

Within the Shiny application, interfaces are defined by the User Interface
specification defined in `https://github.com/MazamaScience/AirSensorDataViewer/blob/master/R/app_ui.R`.

API's to flat file data products are defined by the following naming schemes:

* pas -- `pas/<YYYY>/pas_<YYYYmmdd>.rda`
* pat -- `pat/<YYYY>/<mm>/pat_<uniqueID>_<YYYYmm>.rda`
* airsensor -- `airsensor/<YYYY>/airsensor_scaqmd_<YYYYmm>.rda`
* video -- `videos/<YYYY>/<mm>/<community>_<YYYYmmdd>.mp4`

## Security

Security issues with this system of interactive components are very minimal.

Data ingest and processing inside of docker containers on the host machine 
presents no known security issues.

Standard Apache security settings for read-only files is sufficient for access
to data files.

The public-facing Shiny user interface does not require any authentication
so the open source version of Shiny Server is appropriate for the task. As 
deployed, this server lives inside of it's own docker container, thus protecting 
the host instance from any kind of attack. Docker settings can be used to
automatically reboot the shiny server if for some reason it stops responding.

Additionally, because of the "reactive" design of Shiny applications, only 
changes to widgets defined in the application user interface can cause code to
be run on the back end.
