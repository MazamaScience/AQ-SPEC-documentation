# Deployment Instructions

**_Updated 2019-08-12_**

## Azure Infrastructure

_(Mazama Science is hoping to get access to a SCAQMD Azure instance before
completing this section.)_

## Project Infrastructure

Infrastructure for building and installing all software components consists of
a desktop machine to run and build the R package and a (potentially virutal)
Unix host to provide web accessible data files and a web based user interface a
llowing end users to generate plots of recent data for specific Purple Air
sensors

### Desktop machine

The desktop machine can be of any time as long is it can install the open source
[RStudio](https://www.rstudio.com/products/rstudio/) IDE and `git` for access
to R package updates.

Ideally, this machine would also have `docker` installed for testing purposes.

### Unix host

The Unix host, presumably a Microsoft Azure instance, requires only the
following common utilities:

* Apache -- web server
* git -- version control
* docker -- "container" virtualization

All docker images required for data ingest and for running the "Shiny" user 
interface can be built on the host machine.

## Data Archive Installation Guide

### Provisioning the Azure instance

We recommend setting up the instance with a recent version of ubuntu.

### Installing source code

We recommend installing software into `/home/ubuntu/Projects/` with the
following commands:

```
cd /home/ubuntu/Projects
git clone https://github.com/MazamaScience/AirSensor.git
git clone https://github.com/MazamaScience/AirSensorShiny.git
https://github.com/MazamaScience/AQ-SPEC-documentation.git
```

This will create the following directories:

* `AirSensor` -- R package code also including a `local_executables/` directory
* `AirSensorsShiny` -- R Shiny application
* `AQ-SPEC-documentation` -- documentation and installation guides

### Setting up data ingest scripts

In order to set up data ingest scripts, we must first built the docker image
that the scripts will run in. This is accomplished with the following:

```
cd AirSensor/docker
make production_build
```

This will build the required docker image which can be seen with
`docker images | grep airsensor`. The output should look something like:

```
mazamascience/airsensor             0.3.14                  a81e1c6a9f6e        seconds ago          2.81GB
mazamascience/airsensor             latest                  a81e1c6a9f6e        seconds ago          2.81GB
...
```

Next, we meed to make sure that the appriate web accessible directories exist
and set up the daily crontab by adding the contents of `crontab_daily.txt` to 
the crontab with `crontab -e`.

Creation of a data archive will require that the `crontab_daily.txt` file be
modified to use dates in the near future. Once appropriate changes have been
made, generation of the data archive can be set up by adding the contents
of `crontab_daily.txt` to the crontab with `crontab -e`.

## Shiny App Installation Guide

### Configuring Apache

asdf

### Installing Shiny Server

asdf
