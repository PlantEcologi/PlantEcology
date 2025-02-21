library(sf)
library(tidyverse)
library(readr)

## Get gpx file of sites and write out as shapefile for import into GEE
pts <- st_read("/home/jasper/GIT/BIO3018F/prac/sites.gpx")
pts <- pts %>% select(name)
st_write(pts, "/home/jasper/GIT/BIO3018F/prac/sites/dehoopsites.shp")

## Run GEE script - https://code.earthengine.google.com/cb351e15faf1509a338e2f82f7a41d14

## Download, then import GEE output
ndvi <- read_csv("/home/jasper/Downloads/dehoop_ndvi_time_series.csv", col_names = T)

## Clean GEE output
sites <- ndvi$name #Save site_point name
ndvi <- as.data.frame(t(ndvi)) #transpose
colnames(ndvi) <- sites #Set column names to site_point name
ndvi <- ndvi[-c(1, which(rownames(ndvi) %in% c("name", ".geo"))),] #remove unwanted rows
calendar_date <- as.Date(rownames(ndvi), format = "%Y%m%d") #make vector of dates and save
ndvi <- sapply(ndvi, as.numeric) #convert all to numeric data
ndvi <- as.data.frame(na_if(ndvi, -9999)) #set -9999 to NA
ndvi$calendar_date <- calendar_date #add dates

ndvi <- ndvi %>% pivot_longer(cols = contains(c("SE", "SW", "NE", "NW")), names_to = "site") # convert to long format
ndvi$scale <- 1 # Add scale factor
ndvi <- ndvi %>% separate(site, c("Point", "Site")) # Separate names into sites and point locations

write_csv(ndvi, "data/sentinel.csv")

###Plot all timeseries
ndvi %>%
  ggplot(aes(x = calendar_date, y = value*scale)) + 
  geom_line() +
  #  geom_point() +
  facet_grid(Site ~ Point) +
  ylab("NDVI")# +
#  ylim(0.2, 0.9)
