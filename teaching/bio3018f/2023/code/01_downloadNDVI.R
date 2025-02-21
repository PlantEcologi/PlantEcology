###Download NDVI time series for prac
library(MODISTools)
library(tidyverse)
library(readr)
library(sf)

sites <- st_read("data/Potberg_prac_sites.kml")

sites <- data.frame(site_name = sites$Name, lat = st_coordinates(sites)[,2], lon = st_coordinates(sites)[,1])

dat <- mt_batch_subset(df = sites,
                        product = "MOD13Q1",
                        band = "250m_16_days_NDVI",
                        internal = TRUE,
                        start = "2000-01-01",
                        end = "2022-01-30")

write_csv(dat, "data/modis_1Jan2022.csv")