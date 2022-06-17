# load require packages ----
## shiny environment ----
  library(shiny)
  library(shinyWidgets)
  library(shinydlplot)
  
  library(magrittr)
  library(dplyr)
  library(rdrop2)

## working with tables ----
  library(DT)

## working with plot and map ----
  library(ggplot2)
  library(raster)
  library(rgdal)
  library(leaflet)


## working with date and time ----
  library(lubridate)
  library(rsconnect)

# define last 12-weekly date ----
# Sicoral dijalankan secara rutin setiap hari Senin
# Data terakhir yang tersedia delay 2 hari (jatuh hari Sabtu)
# example:  
# today         => 6 April 2022
# data terakhir => 2 April 2022   

  today <- Sys.Date() # get current date
  weekend <- ceiling_date(today-7, unit = "week") - 1 # get last week dataset
  week_range<-seq.Date(weekend-77, weekend, by = 'week') # get 12 weeks (84 days) range dataset
  date_range<-seq.Date(as.Date('2016-01-02'), today, by = 'week') # get weekly periods dataset

# load region of interest attributes ----
# Authenticate and save token for later use2
# token <- drop_auth(new_user = T)
# token <- drop_auth()
# saveRDS(token, "droptoken.rds")
  token <- drop_auth(rdstoken = "droptoken.rds")
  drop_acc(dtoken = token)

# Retrieveing your file is as simple as
# drop_download(path = "Apps/shiny-app/roi_attributes.txt", 
#               local_path = "global_attribute/roi_attributes.txt",
#               overwrite = TRUE)
roi <- read.csv("global_attribute/roi_attributes.txt")
dat <- read.csv('global_attribute/dataset_attributes.txt', header = T)
alert <- read.csv('global_attribute/alert_attributes.txt', header = T)
rinit <- raster('global_attribute/raster_attributes.tif')

