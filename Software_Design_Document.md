# Software Design Document 

**_Updated 2019-08-12_**

This document describes the overall design and maintenance of a web accessible
archive of data from SCAQMD-maintained Purple Air sensors as well as the design
and deployment of an [R Shiny application](https://shiny.rstudio.com) providing 
web accessible products and user interfaces appropriate for dissemination to the 
public.

software systems were created by Mazama Science for the 
[Sensor Performance and Evaluation Center](http://www.aqmd.gov/aq-spec) 
at the [South Coast Air Quality Managment District](http://www.aqmd.gov).

## System Overview

The overall system consists of the following modular components:
 
 * an R package providing core functionality for working with Purple Air data
 * data ingest scripts for automatically processing raw Purple Air data into
 higher level data archive files
 * a directory structure providing an API for accessing data archive files
 * an R Shiny application providing a public facing user interface to Purple 
 Air data and data products

The data archive consists of a set of flat files with URLs defined by a simple
protocol.

The data ingest scripts are written in R and are run at regular intervals by
the system cron job.

The only "always on" components are an Apache web server and the R Shiny Server 
which is proxied through Apache.

Both the archive scripts and the R Shiny Server are run inside docker containers
so that host machine provisioning is limited to: `apache`, `git` and `docker`.

As envisioned, data ingest, data archive and R Shiny Server will all run on a
single, SCAQMD maintained, Microsoft Azure instance. However, if required for 
redundancy, load or general optimization, it would be very straightforward to 
partitiion data processing, data archive and public interface onto separate 
Azure instances.


## Data flow

Files in the data archive contain data at three distinct levels:

* synoptic data containing primarily sensor metadata for every Puruple Air sensor
* time series data containing raw Purple Air sensor data
* hourly aggregated data containing processed time series data

Data ingest begins by downloading, parsing and enhancing data found in a geojson
file at https://www.purpleair.com/json. Data ingest is performed hourly by a 
dedicated data ingest script run by a cron job. The synoptic data files are
referred to as `pas` (Purple Air Synoptic) files.

In the second stage of data processing, metadata from the synoptic file is used 
to download, parse and enhance raw timeseries data obtained from the 
ThingSpeak server at https://api.thingspeak.com/channels/. This data processing 
is performed again performed houly by a data processing script. The timeseries
data files are referred to as `pat` (Purple Air Timeseries) files.

A more detailed discussion of data access APIs is available at:
https://www2.purpleair.com/community/faq.

The final stage of data processing involves ingesting timeseries data from
the SCAQMD archive and creating quality controlled, hourly aggregated data
files containing all sensor data in a single file. The files are compatible
with capabilities found in the **PWFSLSmoke** package and allow for comparison
with federal monitoring data. This data processing is again performed by a
dedicated processing script run hourly by a cron job. The hourly aggregated
data files are referred to as `airsensor` files.

## Components

### **AirSensor** R package

The R package has been developed as open source software and provides much of 
the functionality that community members and data analysts have identified as 
important in assessing and communicating air sensor data.

The R package source code is available at 
https://github.com/MazamaScience/AirSensor
and is fully documented with package documentation and specific articles
formatted for the web. **_(Web accessible documentation will be available as soon
as the source code is made public. Mazama Science believes the code is ready
to be made public.)_**

The **AirSensor** R package provides all of the component functionality from
which data ingest scripts and user interfaces are built.

Using the open source version of 
[RStudio](https://www.rstudio.com/products/rstudio/), the package can be
loaded and used to analyze data or modified and rebuilt.

### Docker containers

_For background on Docker, see:_

* https://en.wikipedia.org/wiki/Docker_(software)
* https://www.docker.com

All data proceessing is performed by scripts running inside of docker
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

The package source code includes a `local_executables/` directory with the
following contents:

```
├── README.md
├── createLatestAirSensor_exec.R
├── createLatestPAT_exec.R
├── createMonthlyAirSensor_exec.R
├── createMonthlyPAT_exec.R
├── createPAS_archival_exec.R
├── createPAS_exec.R
├── createVideo_exec.R
├── crontab_archive.txt
├── crontab_daily.txt
└── test
    └── Makefile
```

Each of the `~_exec.R` scripts is run on a daily schedule defined by
`crontab_daily.txt`. The `crontab_archive.txt` file can be used to set up
cron jobs to build up an archive of data files starting in January of 2018.

To deploy the data ingest scripts, he contents of these files should be 
modified if necessary to reflect absolute paths and then added to a privileged 
user's crontab so the scripts will be run on a daily basis.

The `test/` directory contains a `Makefile` that allows someone typing at the
command line to test the data ingest scripts by running them inside the docker
container and checking the results. This should be done before setting up the
cron job to run scripts automatically.

### Data directory

The data archive consists of flat-file archive system using R binary files 
containing Purple Air data. The API to this data archive consists of carefully
named files in predictable directory locations. Besides the operating system, no 
other "database" is required.

R package functions assume the following directory structure will be available 
at some web accessible  `archiveBaseUrl`.

```
├── airsensor
│   ├── 2018
│   ├── 2019
│   └── latest
├── pas
│   └── 2019
├── pat
│   ├── 2018
│   ├── 2019
│   └── latest
└── videos
    ├── 2018
    └── 2019
```

The `pas` files are generated every hour with filenames similar to:

```
pas/2019/pas_20190627.rda
pas/2019/pas_2019062800.rda
pas/2019/pas_2019062801.rda
```

Each file contains synoptic data for all US Purple Air sensors reporting for
a given `YYYYmmddHH` timestamp. The file with the `YYYYmmdd` timestamp contains
the same data as the most recent hourly file for that date.

The `pat` files are generated once per day for each individual SCAQMD sensor
and contain data for an entire month. Thay have filenames like:

```
pat/2019/pat_SCAH_04_201901.rda
pat/2019/pat_SCAH_05_201901.rda
pat/2019/pat_SCAH_07_201901.rda
```

The `pat/latest/` subdirectory contains files that are updated hourly and contain 
one week of data per sensor. The have filenames like:

```
pat/latest/pat_SCAH_04_latest7.rda
pat/latest/pat_SCAH_05_latest7.rda
pat/latest/pat_SCAH_07_latest7.rda
```

The `airsensor` files are generated once per day and contain sensor data for
an entire month. A single file combines all aggregated timeseries data and
is named by "collection", in this case "scaqmd":

```
airsensor/2019/airsensor_scaqmd_201901.rda
airsensor/2019/airsensor_scaqmd_201902.rda
airsensor/2019/airsensor_scaqmd_201903.rda
```

The `airsensor/latest` subdirectory contains a file that is updated hourly and
contain one week of data:

```
airsensor/latest/airsensor_scaqmd_latest7.rda
```

The `createVideo_exec.R` script is run once daily to populate generate 7-day
videos of hourly sensor data for each community. These are found in the
`videos` directory with names like:

```
SCAH_20190802.mp4
SCAH_20190803.mp4
SCAH_20190804.mp4
```

### R Shiny application

A simple, web based user interface was created allowing end users to generate 
plots of recent data for specific Purple Air sensors. Our technology of choice
was to build an [R Shiny](https://www.rstudio.com/products/shiny/) application
and to host it using [R Shiny Server](https://www.rstudio.com/products/shiny-2/).

Both of these choices are open source products supported by RStudio and 
currently enjoying widespread adoption by many members of the R/data analysis
community.

The shiny application is not part of the **AirSensor** R package and lives at
its own Github URL: https://github.com/MazamaScience/AirSensorShiny

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
specification defined in `AirSensorShiny/app/ui.R`.

API's to flat file data products are defined by the following naming schemes:

* pas -- `pas/<YYYY>/pas_<YYYYmmdd>.rda`
* pat -- `pat/<YYYY>/pat_<label>_<YYYYmm>.rda`
* airsensor -- `airsensor/<YYYY>/airsensor_scaqmd_<YYYYmm>.rda`
* video -- `videos/<YYYY>/<community>_<YYYYmmdd>.mp4`

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
