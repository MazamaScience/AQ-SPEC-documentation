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

The overall systesm consists of the following modular components:
 
 * an R package providing core functionality for working with Purple Air data
 * data ingest scripts for automatically processing raw Purple Air data into
 higher level data objects
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

asdf

## Components

### **AirSensor** R package

The R package has been developed as open source software and provides much of 
the functionality that community members and data analysts have identified as 
important in assessing and communicating air sensor data.

The R package source code is available at 
https://github.com/MazamaScience/AirSensor
and is fully documented with package documentation and specific articles
formatted for the web. **_(Web accessible documentation will be available as soon
as the source code is made public. Mazama Science believes we are ready to do 
this.)_**

The **AirSensor** R package provides all of the component functionality from
which data ingest scripts and user interfaces are built.

### Data ingest scripts

The package source code includes 

### Data directory

asdf

### R Shiny application

asdf


## Interfaces

asdf

## Security

asdf

# Deployment Instructions

## Azure Infrastructure

asdf

## Project Infrastructure

asfd

## Installation guide

Detailed instructions or scripts for setting up all servers and software components.
 