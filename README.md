# Forestry Data Access with R

Author: Marijana Andabaka

![Photo by Jan  Van Bizar: https://www.pexels.com/photo/trees-reflection-in-water-20532246/](img/image.jpg)

<br>

*This repository contains R functions for accessing and processing forestry and environmental data, designed to streamline research workflows. These methods transform data acquisition from a manual, time-consuming process into an efficient, automated workflow.*

## Overview

Forest researchers often spend excessive time navigating complex websites, downloading individual files, and converting different formats before they can begin analysis. This repository offers streamlined R functions that automate these processes, allowing researchers to access quality data in minutes rather than months.

## Methods Included

### 1. Downloading Historical Climate Data from CRU

Function: `download_cru_climate()`

Access high-resolution (0.5° × 0.5°) global climate data from the Climatic Research Unit (CRU) at the University of East Anglia, covering over a century of observations since 1901.

### 2. Retrieving Species Occurrence Data from GBIF

Function: `download_tree_occurrences()`

Connect to the Global Biodiversity Information Facility (GBIF) to retrieve georeferenced species occurrence data, with options to filter by country and forest habitats.

### 3. Accessing NASA MODIS Vegetation Indices

Function: `download_modis_forest_data()`

Download vegetation index data (EVI/NDVI) from NASA's MODIS satellite sensors for any location on Earth, ideal for monitoring forest health and productivity.

### 4. Downloading FAO Forestry Production and Trade Data

Function: `download_forestry_data()`

Access the comprehensive FAO Forestry Production and Trade database, containing standardized statistics on forest products from countries worldwide since 1961.

### 5. Accessing European Forest Fire Data from EFFIS

Function: `process_effis_fires()`

Process data from the European Forest Fire Information System (EFFIS), providing detailed information on fire events, including affected vegetation types.

## Installation

### Clone this repository
### Install required packages
source("install_helper.R")  
install_packages()

### Source the functions
source("cru_climate_data.R")  
source("gbif_species_data.R")  
source("modis_vegetation_data.R")  
source("fao_forestry_data.R")  
source("effis_fire_data.R")  

## Usage Examples



### Download precipitation data from CRU
precip_file <- download_cru_climate("pre")

### Get occurrence data for European beech in Croatia
beech_data <- download_tree_occurrences("Fagus sylvatica",   
                                        country = "HR")

### Download vegetation index data for a forest site
site_evi <- download_modis_forest_data(lat = 45.56628, lon = 14.52124,   
                                      start_date = "2018-01-01",   
                                      end_date = "2023-01-01")

### Access FAO forestry production data
forestry_data <- download_forestry_data()    
croatia_data <- subset(forestry_data, Area == "Croatia")

### Process European forest fire data
Note: Requires manual download from EFFIS first  
croatia_fires <- process_effis_fires(
  shape_file_path = "path/to/effis_layer/modis.ba.poly.shp",  
  country_code = "HR",  
  start_date = "2000-01-01"
)

# Requirements

- R (>= 3.5.0)
- R.utils
- rgbif
- MODISTools
- sf
- dplyr
- lubridate
- ggplot2
- maps

# Related Resources
Read more about these methods in my Medium article [5 R-Powered Methods to Access Quality Forestry Data Without Fieldwork](https://medium.com/your-username/your-article-slug) and you can dowload the full pdf guide from my [LinkedIn page](https://www.linkedin.com/in/marijana-andabaka/overlay/1740810385128/single-media-viewer/?profileId=ACoAAC_MKc4BeFdwRoSLnKAG15aJ2mJewM6o5eM).

# Licence
This project is licensed under the MIT License - see the LICENSE file for details.

# Acknowledgments
- Climatic Research Unit (CRU) at the University of East Anglia
- Global Biodiversity Information Facility (GBIF)
- NASA's MODIS (Moderate Resolution Imaging Spectroradiometer) team
- Food and Agriculture Organization (FAO) of the United Nations
- European Forest Fire Information System (EFFIS)
- R Core Team and the developers of essential packages:
    - rgbif, MODISTools, sf, dplyr, lubridate, ggplot2, maps
    
# Contributing
Contributions to improve these functions or add new data access methods are welcome. Please feel free to submit a pull request or open an issue to discuss potential improvements.

# Contact
If you have questions about implementing these methods or need help with a specific forestry data challenge, feel free to reach out:

Email: marijana@andalytics.com  
[LinkedIn](https://www.linkedin.com/in/marijana-andabaka/)  
[Website](https://andalytics.com/en/)  

